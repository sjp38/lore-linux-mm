Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 614196B0088
	for <linux-mm@kvack.org>; Tue, 19 May 2015 02:39:44 -0400 (EDT)
Received: by obblk2 with SMTP id lk2so4933115obb.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 23:39:44 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id x74si7901541oia.134.2015.05.18.23.39.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 18 May 2015 23:39:43 -0700 (PDT)
Message-ID: <555ADA36.6060507@huawei.com>
Date: Tue, 19 May 2015 14:37:42 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 0/3] Find mirrored memory, use for boot time allocations
References: <cover.1431103461.git.tony.luck@intel.com> <555AA782.2070603@huawei.com> <CA+8MBbKo=zgyftrrcLcB7D3T7npT7JvpBTj9txEr+ZumgsGuxQ@mail.gmail.com>
In-Reply-To: <CA+8MBbKo=zgyftrrcLcB7D3T7npT7JvpBTj9txEr+ZumgsGuxQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>

On 2015/5/19 12:48, Tony Luck wrote:

> On Mon, May 18, 2015 at 8:01 PM, Xishi Qiu <qiuxishi@huawei.com> wrote:
>> In part2, does it means the memory allocated from kernel should use mirrored memory?
> 
> Yes. I want to use mirrored memory for all (or as many as
> possible) kernel allocations.
> 
>> I have heard of this feature(address range mirroring) before, and I changed some
>> code to test it(implement memory allocations in specific physical areas).
>>
>> In my opinion, add a new zone(ZONE_MIRROR) to fill the mirrored memory is not a good
>> idea. If there are XX discontiguous mirrored areas in one numa node, there should be
>> XX ZONE_MIRROR zones in one pgdat, it is impossible, right?
> 
> With current h/w implementations XX is at most 2, and is possibly only 1
> on most nodes.  But we shouldn't depend on that.
> 
>> I think add a new migrate type(MIGRATE_MIRROR) will be better, the following print
>> is from my changed kernel.
> 
> This sounds interesting.
> 
>> [root@localhost ~]# cat /proc/pagetypeinfo
>> Page block order: 9
>> Pages per block:  512
>>
>> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
> ...
>> Node    0, zone      DMA, type       Mirror      0      0      0      0      0      0      0      0      0      0      0
> ...
>> Node    0, zone    DMA32, type       Mirror      0      0      0      0      0      0      0      0      0      0      0
> 
> I see all zero counts here ... which is fine.  I expect that systems
> will mirror all memory below 4GB ... but we should probably
> ignore the attribute for this range because we want to make

Hi Tony,

I think 0-4G will be all mirrored, so I change nothing, just ignore
the mirror flag.(e.g. 4 socket machine, every socket has 32G memory,
then node0: 0-4G, 4-8G mirrored, node1: 32-36G mirrored, node2:64-68G
mirrored, node3: 96-100G mirrored)

> sure that the memory is still available for users that depend
> on getting memory that legacy devices can access. On systems
> that support address range mirror the <4GB area is <2% of even
> a small system (128GB seems to be the minimum rational configuration
> for a 4 socket machine ... you end up with that much if you populate
> every channel with just one 4GB DIMM). On a big system (in the TB
> range) <4GB area is a trivial rounding error.
> 
>> Also I add a new flag(GFP_MIRROR), then we can use the mirrored form both
>> kernel-space and user-space. If there is no mirrored memory, we will allocate
>> other types memory.
> 
> But I *think* I want all kernel and no users to allocate mirror
> memory.  I'd like to not have to touch every place that allocates
> memory to add/clear this flag.
> 

If only want kernel to use the mirrored memory, it is much easier.
I have some patches, but it's a little ugly and implement both user 
and kernel.

>> 1) kernel-space(pcp, page buddy, slab/slub ...):
>>         -> use mirrored memory(e.g. /proc/sys/vm/mirrorable)
>>                 -> __alloc_pages_nodemask()
>>                         ->gfpflags_to_migratetype()
>>                                 -> use MIGRATE_MIRROR list
> 
> I think you are telling me that we can do this, but I don't understand
> how the code would look.
> 
>> 2) user-space(syscall, madvise, mmap ...):
>>         -> add VM_MIRROR flag in the vma
>>                 -> add GFP_MIRROR when page fault in the vma
>>                         -> __alloc_pages_nodemask()
>>                                 -> use MIGRATE_MIRROR list
> 
> If we do let users have access to mirrored memory, then
> madvise/mmap seem a plausible way to allow it.  Not sure
> what access privileges are appropriate to allow it. I expect
> mirrored memory to be in short supply (the whole point of

I think allocations from some key process(e.g. date base) are
as important as kernel, and in most cases MCE just kill them
if memory failure, so let user can access the mirrored memory
may be a good way to solve the problem. 

> address range mirror is to make do with a minimal amount
> of mirrored memory ... if you expect to want/have lots of
> mirrored memory, then just take the 50% hit in capacity
> and mirror everything and ignore all the s/w complexity).
> 
> Are your patches ready to be shared?

I'll rewrite and send them soon.

Thanks,
Xishi Qiu

> 
> -Tony
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
