Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D01416B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 04:56:50 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id r15so946678wrr.16
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 01:56:50 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id k16si3712863ede.3.2018.02.21.01.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 01:56:49 -0800 (PST)
Subject: Re: [RFC PATCH v16 0/6] mm: security: ro protection for dynamic data
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <CAGXu5j+ZNFX17Vxd37rPnkahFepFn77Fi9zEy+OL8nNd_2bjqQ@mail.gmail.com>
 <20180220012111.GC3728@rh> <24e65dec-f452-a444-4382-d1f88fbb334c@huawei.com>
 <20180220213604.GD3728@rh> <20180220235600.GA3706@bombadil.infradead.org>
 <20180221013636.GE3728@rh>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <46a9610a-182b-4765-9d83-cab6297377f3@huawei.com>
Date: Wed, 21 Feb 2018 11:56:22 +0200
MIME-Version: 1.0
In-Reply-To: <20180221013636.GE3728@rh>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>, Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura
 Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph
 Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On 21/02/18 03:36, Dave Chinner wrote:
> On Tue, Feb 20, 2018 at 03:56:00PM -0800, Matthew Wilcox wrote:
>> On Wed, Feb 21, 2018 at 08:36:04AM +1100, Dave Chinner wrote:
>>> FWIW, I'm not wanting to use it to replace static variables. All the
>>> structures are dynamically allocated right now, and get assigned to
>>> other dynamically allocated pointers. I'd likely split the current
>>> structures into a "ro after init" 

I would prefer to use a different terminology, because, if I have
understood the use case, this is not exactly the same as __ro_after_init

So, this is my understanding:

* "const" needs to be known at link time - there might be some
adjustments later on, ex: patching of "const" pointers, after relocation
has taken place - I am assuming we are not planning to patch const data
The compiler can perform whatever optimization it feels like and it is
allowed to do, on this.

* __ro_after_init is almost the same as a const, from a r/w perspective,
but it will become effectively read_only after the completion of the
init phase. The compiler cannot use it in any way to detect errors,
AFAIK. The system will just generate a runtime error is someone tries to
alter some __ro_after_init data, when it's read-only.
The only trick available is to use, after the protection, a different
type of handle, const.

* pmalloc pools can be protected (hence the "p") at any time, but they
start as r/w. Also, they cannot be declared statically.

* data which is either const or __ro_after_init is placed into specific
sections (on arm64 it's actually the same) and its pages are then marked
as read-only.

>>> structure and rw structure, so
>>> how does the "__ro_after_init" attribute work in that case? Is it
>>> something like this?
>>>
>>> struct xfs_mount {
>>> 	struct xfs_mount_ro{
>>> 		.......
>>> 	} *ro __ro_after_init;
>        ^^^^^^^^
> 
> pointer, not embedded structure....

I doubt this would work, because I think it's not possible to put a
field of a structure into a separate section, afaik.

__ro_after_init would refer to the ro field, not to the memory it refers to.

>>> 	......
>>
>> No, you'd do:
>>
>> struct xfs_mount_ro {
>> 	[...]
>> };

is this something that is readonly from the beginning and then shared
among mount points or is it specific to each mount point?

>> struct xfs_mount {
>> 	const struct xfs_mount_ro *ro;
>> 	[...]
>> };
> 
> .... so that's pretty much the same thing :P

The "const" modifier is a nice way to catch errors through the compiler,
iff the ro data will not be initialized through this handle, when it's
still writable.

>>> Also, what compile time checks are in place to catch writes to
>>> ro structure members? Is sparse going to be able to check this sort
>>> of thing, like is does with endian-specific variables?
>>
>> Just labelling the pointer const should be enough for the compiler to
>> catch unintended writes.
> 
> Ok.

yes, anyway the first one trying to alter it at run time, is in for some
surprise.

>>>> I'd be interested to have your review of the pmalloc API, if you think
>>>> something is missing, once I send out the next revision.
>>>
>>> I'll look at it in more depth when it comes past again. :P
>>
>> I think the key question is whether you want a slab-style interface
>> or whether you want a kmalloc-style interface.  I'd been assuming
>> the former, but Igor has implemented the latter already.
> 
> Slabs are rally only useful when you have lots of a specific type of
> object. I'm concerned mostly about one-off per-mount point
> structures, of which there are relatively few. A heap-like pool per
> mount is fine for this.

That was my same sentiment.

Actually it would be even possible to simulate caches with pools: each
pool supports a granularity parameter, during creation. One could have
multiple pools, each with different granularity, but it would probably
lead to a proliferation of pools.

Instead, I preferred to have pmalloc as a drop-in replacement for the
variants of k/v/kv malloc.

The only real issue was the - previous - inability of tracking the size
of an allocation, given its address, but that is taken care of by the
patch for the genalloc bitmap.

If I could have a pointer to a good candidate for the pmalloc treatment,
I could come up with a patch, to show how it could be done.

Then it might be easier to discuss if the API needs to be modified
and/or extended somehow.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
