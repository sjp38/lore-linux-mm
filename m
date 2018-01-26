Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFA636B000D
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 06:46:57 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e195so5635956wmd.9
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 03:46:57 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id y33si4073697edy.458.2018.01.26.03.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 03:46:56 -0800 (PST)
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
 <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <20180126053542.GA30189@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <4788245d-c8e1-3587-c1e0-09c18245fe9a@huawei.com>
Date: Fri, 26 Jan 2018 13:46:55 +0200
MIME-Version: 1.0
In-Reply-To: <20180126053542.GA30189@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>
Cc: jglisse@redhat.com, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On 26/01/18 07:35, Matthew Wilcox wrote:
> On Wed, Jan 24, 2018 at 08:10:53PM +0100, Jann Horn wrote:
>> I'm not entirely convinced by the approach of marking small parts of
>> kernel memory as readonly for hardening.
> 
> It depends how significant the data stored in there are.  For example,
> storing function pointers in read-only memory provides significant
> hardening.
> 
>> You're allocating with vmalloc(), which, as far as I know, establishes
>> a second mapping in the vmalloc area for pages that are already mapped
>> as RW through the physmap. AFAICS, later, when you're trying to make
>> pages readonly, you're only changing the protections on the second
>> mapping in the vmalloc area, therefore leaving the memory writable
>> through the physmap. Is that correct? If so, please either document
>> the reasoning why this is okay or change it.
> 
> Yes, this is still vulnerable to attacks through the physmap.  That's also
> true for marking structs as const.  We should probably fix that at some
> point, but at least they're not vulnerable to heap overruns by small
> amounts ... you have to be able to overrun some other array by terabytes.

Actually, I think there is something to say in favor of using a vmalloc
based approach, precisely because of the physmap :-P

If I understood correctly, the physmap is primarily meant to speed up
access to physical memory through the TLB. In particular, for kmalloc
based allocations.

Which means that, to perform a physmap-based attack to a kmalloced
allocation, one needs to know:

- the address of the target variable in the kmalloc range
- the randomized offset of the kernel
- the location of the physmap

But, for a vmalloc based allocation, there is one extra hoop: since the
mapping is really per page, now the attacker has actually to walk the
page table, to figure out where to poke in the physmap.


One more thought about physmap: does it map also code?
Because, if it does, and one wants to use it for an attack, isn't it
easier to look for some security test and replace a bne with be or
equivalent?


> It's worth having a discussion about whether we want the pmalloc API
> or whether we want a slab-based API.

pmalloc is meant to be useful where the attack surface is made up of
lots of small allocations - my first use case was the SE Linux policy
DB, where there is a variety of elements being allocated, in large
amount. To the point where having ready made caches would be wasteful.


Then there is the issue I already mentioned about arm/arm64 which would
require to break down large mappings, which seems to be against current
policy, as described in my previous mail:

http://www.openwall.com/lists/kernel-hardening/2018/01/24/11


I do not know exactly what you have in mind wrt slab, but my impression
is that it will most likely gravitate toward the pmalloc implementation.
It will need:

- "pools" or anyway some means to lock only a certain group of pages,
related to a specific kernel user

- (mostly) lockless allocation

- a way to manage granularity (or order of allocation)

Most of this is already provided by genalloc, which is what I ended up
almost re-implementing, before being pointed to it :-)

I only had to add the tracking of end of allocations, which is what the
patch 1/6 does - as side note, is anybody maintaining it?
I could not find an entry in MAINTAINERS

As I mentioned above, using vmalloc adds even an extra layer of protection.

The major downside is the increased TLB use, however this is not so
relevant for the volumes of data that I had to deal with so far:
only few 4K pages.

But you might have in mind something else.
I'd be interested to know what and what would be an obstacle in using
pmalloc. Maybe it can be solved.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
