Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id A68286B0082
	for <linux-mm@kvack.org>; Tue, 19 May 2015 00:48:11 -0400 (EDT)
Received: by wibt6 with SMTP id t6so6891721wib.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 21:48:11 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id h2si18443154wjq.17.2015.05.18.21.48.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 21:48:10 -0700 (PDT)
Received: by wgjc11 with SMTP id c11so3590316wgj.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 21:48:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <555AA782.2070603@huawei.com>
References: <cover.1431103461.git.tony.luck@intel.com>
	<555AA782.2070603@huawei.com>
Date: Mon, 18 May 2015 21:48:09 -0700
Message-ID: <CA+8MBbKo=zgyftrrcLcB7D3T7npT7JvpBTj9txEr+ZumgsGuxQ@mail.gmail.com>
Subject: Re: [PATCHv2 0/3] Find mirrored memory, use for boot time allocations
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>

On Mon, May 18, 2015 at 8:01 PM, Xishi Qiu <qiuxishi@huawei.com> wrote:
> In part2, does it means the memory allocated from kernel should use mirrored memory?

Yes. I want to use mirrored memory for all (or as many as
possible) kernel allocations.

> I have heard of this feature(address range mirroring) before, and I changed some
> code to test it(implement memory allocations in specific physical areas).
>
> In my opinion, add a new zone(ZONE_MIRROR) to fill the mirrored memory is not a good
> idea. If there are XX discontiguous mirrored areas in one numa node, there should be
> XX ZONE_MIRROR zones in one pgdat, it is impossible, right?

With current h/w implementations XX is at most 2, and is possibly only 1
on most nodes.  But we shouldn't depend on that.

> I think add a new migrate type(MIGRATE_MIRROR) will be better, the following print
> is from my changed kernel.

This sounds interesting.

> [root@localhost ~]# cat /proc/pagetypeinfo
> Page block order: 9
> Pages per block:  512
>
> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
...
> Node    0, zone      DMA, type       Mirror      0      0      0      0      0      0      0      0      0      0      0
...
> Node    0, zone    DMA32, type       Mirror      0      0      0      0      0      0      0      0      0      0      0

I see all zero counts here ... which is fine.  I expect that systems
will mirror all memory below 4GB ... but we should probably
ignore the attribute for this range because we want to make
sure that the memory is still available for users that depend
on getting memory that legacy devices can access. On systems
that support address range mirror the <4GB area is <2% of even
a small system (128GB seems to be the minimum rational configuration
for a 4 socket machine ... you end up with that much if you populate
every channel with just one 4GB DIMM). On a big system (in the TB
range) <4GB area is a trivial rounding error.

> Also I add a new flag(GFP_MIRROR), then we can use the mirrored form both
> kernel-space and user-space. If there is no mirrored memory, we will allocate
> other types memory.

But I *think* I want all kernel and no users to allocate mirror
memory.  I'd like to not have to touch every place that allocates
memory to add/clear this flag.

> 1) kernel-space(pcp, page buddy, slab/slub ...):
>         -> use mirrored memory(e.g. /proc/sys/vm/mirrorable)
>                 -> __alloc_pages_nodemask()
>                         ->gfpflags_to_migratetype()
>                                 -> use MIGRATE_MIRROR list

I think you are telling me that we can do this, but I don't understand
how the code would look.

> 2) user-space(syscall, madvise, mmap ...):
>         -> add VM_MIRROR flag in the vma
>                 -> add GFP_MIRROR when page fault in the vma
>                         -> __alloc_pages_nodemask()
>                                 -> use MIGRATE_MIRROR list

If we do let users have access to mirrored memory, then
madvise/mmap seem a plausible way to allow it.  Not sure
what access privileges are appropriate to allow it. I expect
mirrored memory to be in short supply (the whole point of
address range mirror is to make do with a minimal amount
of mirrored memory ... if you expect to want/have lots of
mirrored memory, then just take the 50% hit in capacity
and mirror everything and ignore all the s/w complexity).

Are your patches ready to be shared?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
