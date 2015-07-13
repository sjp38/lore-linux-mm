Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 84ECA6B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 01:08:16 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so25470773pac.3
        for <linux-mm@kvack.org>; Sun, 12 Jul 2015 22:08:16 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id z1si26430403pda.165.2015.07.12.22.08.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 12 Jul 2015 22:08:15 -0700 (PDT)
Message-ID: <55A3450E.6050707@huawei.com>
Date: Mon, 13 Jul 2015 12:56:46 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy
 allocations
References: <558E084A.60900@huawei.com> <20150630094149.GA6812@suse.de> <20150630104654.GA24932@gmail.com> <20150630115353.GB6812@suse.de>
In-Reply-To: <20150630115353.GB6812@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/30 19:53, Mel Gorman wrote:

> On Tue, Jun 30, 2015 at 12:46:54PM +0200, Ingo Molnar wrote:
>>
>> * Mel Gorman <mgorman@suse.de> wrote:
>>
>>> [...]
>>>
>>> Basically, overall I feel this series is the wrong approach but not knowing who 
>>> the users are making is much harder to judge. I strongly suspect that if 
>>> mirrored memory is to be properly used then it needs to be available before the 
>>> page allocator is even active. Once active, there needs to be controlled access 
>>> for allocation requests that are really critical to mirror and not just all 
>>> kernel allocations. None of that would use a MIGRATE_TYPE approach. It would be 
>>> alterations to the bootmem allocator and access to an explicit reserve that is 
>>> not accounted for as "free memory" and accessed via an explicit GFP flag.
>>
>> So I think the main goal is to avoid kernel crashes when a #MC memory fault 
>> arrives on a piece of memory that is owned by the kernel.
>>
> 
> Sounds logical. In that case, bootmem awareness would be crucial.
> Enabling support in just the page allocator is too late.
> 
>> In that sense 'protecting' all kernel allocations is natural: we don't know how to 
>> recover from faults that affect kernel memory.
>>
> 
> It potentially uses all mirrored memory on memory that does not need that
> sort of guarantee. For example, if there was a MC on memory backing the
> inode cache then potentially that is recoverable as long as the inodes
> were not dirty. That's a minor detail as the kernel could later protect
> only MIGRATE_UNMOVABLE requests instead of all kernel allocations if fatal
> MC in kernel space could be distinguished from non-fatal checks.
> 
> Bootmem awareness is much more important either way. If that was addressed
> then potentially a MIGRATE_UNMOVABLE_MIRROR type could be created that
> is only used for MIGRATE_UNMOVABLE allocations and never for user-space.
> That misses MIGRATE_RECLAIMABLE so if that is required then we need
> something else that both preserves fragmentation avoidance and avoid
> introducing loads of new migratetypes.
> 
> Reclaim-related issues could be partially avoided by forbidding use from
> userspace and accounting for the size of MIGRATE_UNMOVABLE_MIRROR during
> watermark checks.
> 
>> We do know how to recover from faults that affect user-space memory alone.
>>
>> So if a mechanism is in place that prioritizes 3 groups of allocators:
>>
>>   - non-recoverable memory (kernel allocations mostly)
>>
> 
> So bootmem at the very least followed by MIGRATE_UNMOVABLE requests whether
> they are accounted for by zones of MIGRATE_TYPES.
> 
>>   - high priority user memory (critical apps that must never fail)
>>
> 
> This one is problematic with a MIGRATE_TYPE-based approach such as the one in
> this series. If a high priority requires memory and MIGRATE_MIRROR is full
> then some of it must be reclaimed. With a MIGRATE_TYPE approach, the kernel
> may reclaim a lot of unnecessary memory trying to free some MIGRATE_MIRROR
> memory with no guarantee of success. It'll look like unnecessary thrashing
> from userspace but difficult to diagnose as reclaim stats are per-zone based.
> Dealing with this needs either a zone-based approach or a lot of surgery
> to reclaim (similar to what the node-based LRU series does actually when
> it skips pages when the caller requires lowmem pages).
> 

Hi Mel,

Thank you for your comment. Sorry for replying late and some of it is not
very understanding for me.

If fatal memory faults in kernel space could be distinguished from non-fatal,
we can use only MIGRATE_UNMOVABLE_MIRROR, if can't, use two types for
MIGRATE_RECLAIMABLE and MIGRATE_UNMOVABLE, right?

Reclaim-related issues is similar to CMA in zone_watermark_ok(), right?

If we protect high priority user memory, use a new mirrored zone may be
better, right?

How about use a flag(e.g. GFP_MIRROR) to in kernel space allocation?
Can we use it to sort kernel space allocation? And it can also called by 
user space via madvise and mmap.

Thanks,
Xishi Qiu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
