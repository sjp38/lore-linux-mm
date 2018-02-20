Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C024E6B0011
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 13:04:18 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 62so8690372wrg.0
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 10:04:18 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id t57si1723792edd.20.2018.02.20.10.04.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 10:04:17 -0800 (PST)
Subject: Re: [RFC PATCH v16 0/6] mm: security: ro protection for dynamic data
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <CAGXu5j+ZNFX17Vxd37rPnkahFepFn77Fi9zEy+OL8nNd_2bjqQ@mail.gmail.com>
 <20180220012111.GC3728@rh>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <24e65dec-f452-a444-4382-d1f88fbb334c@huawei.com>
Date: Tue, 20 Feb 2018 20:03:49 +0200
MIME-Version: 1.0
In-Reply-To: <20180220012111.GC3728@rh>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>, Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph
 Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>



On 20/02/18 03:21, Dave Chinner wrote:
> On Mon, Feb 12, 2018 at 03:32:36PM -0800, Kees Cook wrote:
>> On Mon, Feb 12, 2018 at 8:52 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>>> This patch-set introduces the possibility of protecting memory that has
>>> been allocated dynamically.
>>>
>>> The memory is managed in pools: when a memory pool is turned into R/O,
>>> all the memory that is part of it, will become R/O.
>>>
>>> A R/O pool can be destroyed, to recover its memory, but it cannot be
>>> turned back into R/W mode.
>>>
>>> This is intentional. This feature is meant for data that doesn't need
>>> further modifications after initialization.
>>
>> This series came up in discussions with Dave Chinner (and Matthew
>> Wilcox, already part of the discussion, and others) at LCA. I wonder
>> if XFS would make a good initial user of this, as it could allocate
>> all the function pointers and other const information about a
>> superblock in pmalloc(), keeping it separate from the R/W portions?
>> Could other filesystems do similar things?
> 
> I wasn't cc'd on this patchset, (please use david@fromorbit.com for
> future postings) 

Apologies, somehow I didn't realize that I should have put you too in
CC. It will be fixed at the next iteration.

> so I can't really say anything about it right
> now. My interest for XFS was that we have a fair amount of static
> data in XFS that we set up at mount time and it never gets modified
> after that.

This is the typical use case I had in mind, although it requires a
conversion.
Ex:

before:

static int a;


void set_a(void)
{
	a = 4;
}



after:

static int *a __ro_after_init;
struct gen_pool *pool;

void init_a(void)
{
	pool = pmalloc_create_pool("pool", 0);
	a = (int *)pmalloc(pool, sizeof(int), GFP_KERNEL);
}

void set_a(void)
{
	*a = 4;
	pmalloc_protect_pool(pool);
}

> I'm not so worried about VFS level objects (that's a
> much more complex issue) but there is a lot of low hanging fruit in
> the XFS structures we could convert to write-once structures.

I'd be interested to have your review of the pmalloc API, if you think
something is missing, once I send out the next revision.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
