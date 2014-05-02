Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3720D6B0037
	for <linux-mm@kvack.org>; Fri,  2 May 2014 08:09:04 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so3102180eek.34
        for <linux-mm@kvack.org>; Fri, 02 May 2014 05:09:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n46si1464877eeo.67.2014.05.02.05.09.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 05:09:02 -0700 (PDT)
Message-ID: <53638ADA.5040200@suse.cz>
Date: Fri, 02 May 2014 14:08:58 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list placement
 of CMA and RESERVE pages
References: <533D8015.1000106@suse.cz> <1396539618-31362-1-git-send-email-vbabka@suse.cz> <1396539618-31362-2-git-send-email-vbabka@suse.cz> <53616F39.2070001@oracle.com>
In-Reply-To: <53616F39.2070001@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Dave Jones <davej@redhat.com>

On 04/30/2014 11:46 PM, Sasha Levin wrote:
> On 04/03/2014 11:40 AM, Vlastimil Babka wrote:
>> For the MIGRATE_RESERVE pages, it is important they do not get misplaced
>> on free_list of other migratetype, otherwise the whole MIGRATE_RESERVE
>> pageblock might be changed to other migratetype in try_to_steal_freepages().
>> For MIGRATE_CMA, the pages also must not go to a different free_list, otherwise
>> they could get allocated as unmovable and result in CMA failure.
>>
>> This is ensured by setting the freepage_migratetype appropriately when placing
>> pages on pcp lists, and using the information when releasing them back to
>> free_list. It is also assumed that CMA and RESERVE pageblocks are created only
>> in the init phase. This patch adds DEBUG_VM checks to catch any regressions
>> introduced for this invariant.
>>
>> Cc: Yong-Taek Lee <ytk.lee@samsung.com>
>> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Michal Nazarewicz <mina86@mina86.com>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Two issues with this patch.
> 
> First:
> 
> [ 3446.320082] kernel BUG at mm/page_alloc.c:1197!
> [ 3446.320082] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 3446.320082] Dumping ftrace buffer:
> [ 3446.320082]    (ftrace buffer empty)
> [ 3446.320082] Modules linked in:
> [ 3446.320082] CPU: 1 PID: 8923 Comm: trinity-c42 Not tainted 3.15.0-rc3-next-20140429-sasha-00015-g7c7e0a7-dirty #427
> [ 3446.320082] task: ffff88053e208000 ti: ffff88053e246000 task.ti: ffff88053e246000
> [ 3446.320082] RIP: get_page_from_freelist (mm/page_alloc.c:1197 mm/page_alloc.c:1548 mm/page_alloc.c:2036)
> [ 3446.320082] RSP: 0018:ffff88053e247778  EFLAGS: 00010002
> [ 3446.320082] RAX: 0000000000000003 RBX: ffffea0000f40000 RCX: 0000000000000008
> [ 3446.320082] RDX: 0000000000000002 RSI: 0000000000000003 RDI: 00000000000000a0
> [ 3446.320082] RBP: ffff88053e247868 R08: 0000000000000007 R09: 0000000000000000
> [ 3446.320082] R10: ffff88006ffcef00 R11: 0000000000000000 R12: 0000000000000014
> [ 3446.335888] R13: ffffea000115ffe0 R14: ffffea000115ffe0 R15: 0000000000000000
> [ 3446.335888] FS:  00007f8c9f059700(0000) GS:ffff88006ec00000(0000) knlGS:0000000000000000
> [ 3446.335888] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 3446.335888] CR2: 0000000002cbc048 CR3: 000000054cdb4000 CR4: 00000000000006a0
> [ 3446.335888] DR0: 00000000006de000 DR1: 00000000006de000 DR2: 0000000000000000
> [ 3446.335888] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000602
> [ 3446.335888] Stack:
> [ 3446.335888]  ffff88053e247798 ffff88006eddc0b8 0000000000000016 0000000000000000
> [ 3446.335888]  ffff88006ffd2068 ffff88006ffdb008 0000000100000000 0000000000000000
> [ 3446.335888]  ffff88006ffdb000 0000000000000000 0000000000000003 0000000000000001
> [ 3446.335888] Call Trace:
> [ 3446.335888] __alloc_pages_nodemask (mm/page_alloc.c:2731)
> [ 3446.335888] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [ 3446.335888] alloc_pages_vma (include/linux/mempolicy.h:76 mm/mempolicy.c:1998)
> [ 3446.335888] ? shmem_alloc_page (mm/shmem.c:881)
> [ 3446.335888] ? kvm_clock_read (arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
> [ 3446.335888] shmem_alloc_page (mm/shmem.c:881)
> [ 3446.335888] ? __const_udelay (arch/x86/lib/delay.c:126)
> [ 3446.335888] ? __rcu_read_unlock (kernel/rcu/update.c:97)
> [ 3446.335888] ? find_get_entry (mm/filemap.c:979)
> [ 3446.335888] ? find_get_entry (mm/filemap.c:940)
> [ 3446.335888] ? find_lock_entry (mm/filemap.c:1024)
> [ 3446.335888] shmem_getpage_gfp (mm/shmem.c:1130)
> [ 3446.335888] ? sched_clock_local (kernel/sched/clock.c:214)
> [ 3446.335888] ? do_read_fault.isra.42 (mm/memory.c:3523)
> [ 3446.335888] shmem_fault (mm/shmem.c:1237)
> [ 3446.335888] ? do_read_fault.isra.42 (mm/memory.c:3523)
> [ 3446.335888] __do_fault (mm/memory.c:3344)
> [ 3446.335888] ? _raw_spin_unlock (arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
> [ 3446.335888] do_read_fault.isra.42 (mm/memory.c:3524)
> [ 3446.335888] ? get_parent_ip (kernel/sched/core.c:2485)
> [ 3446.335888] ? get_parent_ip (kernel/sched/core.c:2485)
> [ 3446.335888] __handle_mm_fault (mm/memory.c:3662 mm/memory.c:3823 mm/memory.c:3950)
> [ 3446.335888] ? __const_udelay (arch/x86/lib/delay.c:126)
> [ 3446.335888] ? __rcu_read_unlock (kernel/rcu/update.c:97)
> [ 3446.335888] handle_mm_fault (mm/memory.c:3973)
> [ 3446.335888] __get_user_pages (mm/memory.c:1863)
> [ 3446.335888] ? preempt_count_sub (kernel/sched/core.c:2541)
> [ 3446.335888] __mlock_vma_pages_range (mm/mlock.c:255)
> [ 3446.335888] __mm_populate (mm/mlock.c:711)
> [ 3446.335888] vm_mmap_pgoff (include/linux/mm.h:1841 mm/util.c:402)
> [ 3446.335888] SyS_mmap_pgoff (mm/mmap.c:1378)
> [ 3446.335888] ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
> [ 3446.335888] ia32_do_call (arch/x86/ia32/ia32entry.S:430)
> [ 3446.335888] Code: 00 66 0f 1f 44 00 00 ba 02 00 00 00 31 f6 48 89 c7 e8 c1 c3 ff ff 48 8b 53 10 83 f8 03 74 08 83 f8 04 75 13 0f 1f 00 39 d0 74 0c <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 45 85 ff 75 15 49 8b 55 00
> [ 3446.335888] RIP get_page_from_freelist (mm/page_alloc.c:1197 mm/page_alloc.c:1548 mm/page_alloc.c:2036)
> [ 3446.335888]  RSP <ffff88053e247778>

Hey, that's not an issue, that means the patch works as intended :) And
I believe it's not a bug introduced by PATCH 1/2.

So, according to my decodecode reading, RAX is the results of
get_pageblock_migratetype() and it's MIGRATE_RESERVE. RDX is the result
of get_freepage_migratetype() and it's MIGRATE_UNMOVABLE. The
freepage_migratetype has just been set either by __rmqueue_smallest() or
__rmqueue_fallback(), according to the free_list the page has been taken
from. So this looks like a page from MIGRATE_RESERVE pageblock found on
the !MIGRATE_RESERVE free_list, which is exactly what the patch intends
to catch.

I think there are two possible explanations.

1) the pageblock is genuinely MIGRATE_RESERVE and it was misplaced by
mistake. I think it wasn't in free_pcppages_bulk() as there's the same
VM_BUG_ON which would supposedly trigger at the moment of displacing. In
theory it's possible that there's a race through __free_pages_ok() ->
free_one_page() where the get_pageblock_migratetype() in
__free_pages_ok() would race with set_pageblock_migratetype() and result
in bogus value. But nobody should be calling set_pageblock_migratetype()
on a MIGRATE_RESERVE pageblock.

2) the pageblock was marked as MIGRATE_RESERVE due to a race between
set_pageblock_migratetype() and set_pageblock_skip(). The latter is
currently not serialized by zone->lock, nor it uses atomic bit set. So
it may result in lost updates in a racing set_pageblock_migratetype(). I
think a well-placed race when changing pageblock from MIGRATE_MOVABLE to
MIGRATE_RECLAIMABLE could result in MIGRATE_RESERVE value. Similar races
have been already observed to be a problem where frequent changing
to/from MIGRATE_ISOLATE is involved, and I did a patch series to address
this, but it was not complete and I postponed it after Mel's changes
that remove the racy for-cycles completely. So it might be that his
"[PATCH 08/17] mm: page_alloc: Use word-based accesses for get/set
pageblock bitmaps" already solves this bug (but maybe only on certain
architectures where you don't need atomic operations). You might try
that patch if you can reproduce this bug frequently enough?


> And second:
> 
> [snip]
> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 2dbaba1..0ee9f8c 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -697,6 +697,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>>   			page = list_entry(list->prev, struct page, lru);
>>   			/* must delete as __free_one_page list manipulates */
>>   			list_del(&page->lru);
>> +
>> +			VM_BUG_ON(!check_freepage_migratetype(page));
>>   			mt = get_freepage_migratetype(page);
>>   			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>>   			__free_one_page(page, zone, 0, mt);
>> @@ -1190,6 +1192,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>>   		struct page *page = __rmqueue(zone, order, migratetype);
>>   		if (unlikely(page == NULL))
>>   			break;
>> +		VM_BUG_ON(!check_freepage_migratetype(page));
>>   
>>   		/*
>>   		 * Split buddy pages returned by expand() are received here
>>
> 
> Could the VM_BUG_ON()s be VM_BUG_ON_PAGE() instead?

Right, Andrew can you please add and fold this:

-----8<-----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 2 May 2014 13:20:48 +0200
Subject: [PATCH] 
 mm-page_alloc-debug_vm-checks-for-free_list-placement-of-cma-and-reserve-pages-fix

Use VM_BUG_ON_PAGE instead of VM_BUG_ON as suggested by Sasha Levin.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 343c684..a64d672 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -700,7 +700,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
 
-			VM_BUG_ON(!check_freepage_migratetype(page));
+			VM_BUG_ON_PAGE(!check_freepage_migratetype(page), page);
 			mt = get_freepage_migratetype(page);
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, mt);
@@ -1194,7 +1194,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		struct page *page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
 			break;
-		VM_BUG_ON(!check_freepage_migratetype(page));
+		VM_BUG_ON_PAGE(!check_freepage_migratetype(page), page);
 
 		/*
 		 * Split buddy pages returned by expand() are received here
-- 
1.8.4.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
