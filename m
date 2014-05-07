Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id BF7916B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 10:59:12 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so846934eek.12
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:59:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si16598096eef.352.2014.05.07.07.59.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 07:59:10 -0700 (PDT)
Message-ID: <536A4A3B.1090403@suse.cz>
Date: Wed, 07 May 2014 16:59:07 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list placement
 of CMA and RESERVE pages
References: <533D8015.1000106@suse.cz> <1396539618-31362-1-git-send-email-vbabka@suse.cz> <1396539618-31362-2-git-send-email-vbabka@suse.cz> <53616F39.2070001@oracle.com> <53638ADA.5040200@suse.cz> <5367A1E5.2020903@oracle.com> <5367B356.1030403@suse.cz> <20140507013333.GB26212@bbox>
In-Reply-To: <20140507013333.GB26212@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Dave Jones <davej@redhat.com>

On 05/07/2014 03:33 AM, Minchan Kim wrote:
> On Mon, May 05, 2014 at 05:50:46PM +0200, Vlastimil Babka wrote:
>> On 05/05/2014 04:36 PM, Sasha Levin wrote:
>>> On 05/02/2014 08:08 AM, Vlastimil Babka wrote:
>>>> On 04/30/2014 11:46 PM, Sasha Levin wrote:
>>>>>> On 04/03/2014 11:40 AM, Vlastimil Babka wrote:
>>>>>>>> For the MIGRATE_RESERVE pages, it is important they do not get misplaced
>>>>>>>> on free_list of other migratetype, otherwise the whole MIGRATE_RESERVE
>>>>>>>> pageblock might be changed to other migratetype in try_to_steal_freepages().
>>>>>>>> For MIGRATE_CMA, the pages also must not go to a different free_list, otherwise
>>>>>>>> they could get allocated as unmovable and result in CMA failure.
>>>>>>>>
>>>>>>>> This is ensured by setting the freepage_migratetype appropriately when placing
>>>>>>>> pages on pcp lists, and using the information when releasing them back to
>>>>>>>> free_list. It is also assumed that CMA and RESERVE pageblocks are created only
>>>>>>>> in the init phase. This patch adds DEBUG_VM checks to catch any regressions
>>>>>>>> introduced for this invariant.
>>>>>>>>
>>>>>>>> Cc: Yong-Taek Lee <ytk.lee@samsung.com>
>>>>>>>> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
>>>>>>>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>>>>>> Cc: Mel Gorman <mgorman@suse.de>
>>>>>>>> Cc: Minchan Kim <minchan@kernel.org>
>>>>>>>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>>>>>> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>>>>>>>> Cc: Hugh Dickins <hughd@google.com>
>>>>>>>> Cc: Rik van Riel <riel@redhat.com>
>>>>>>>> Cc: Michal Nazarewicz <mina86@mina86.com>
>>>>>>>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>>>>>>
>>>>>> Two issues with this patch.
>>>>>>
>>>>>> First:
>>>>>>
>>>>>> [ 3446.320082] kernel BUG at mm/page_alloc.c:1197!
>>>>>> [ 3446.320082] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>>>>> [ 3446.320082] Dumping ftrace buffer:
>>>>>> [ 3446.320082]    (ftrace buffer empty)
>>>>>> [ 3446.320082] Modules linked in:
>>>>>> [ 3446.320082] CPU: 1 PID: 8923 Comm: trinity-c42 Not tainted 3.15.0-rc3-next-20140429-sasha-00015-g7c7e0a7-dirty #427
>>>>>> [ 3446.320082] task: ffff88053e208000 ti: ffff88053e246000 task.ti: ffff88053e246000
>>>>>> [ 3446.320082] RIP: get_page_from_freelist (mm/page_alloc.c:1197 mm/page_alloc.c:1548 mm/page_alloc.c:2036)
>>>>>> [ 3446.320082] RSP: 0018:ffff88053e247778  EFLAGS: 00010002
>>>>>> [ 3446.320082] RAX: 0000000000000003 RBX: ffffea0000f40000 RCX: 0000000000000008
>>>>>> [ 3446.320082] RDX: 0000000000000002 RSI: 0000000000000003 RDI: 00000000000000a0
>>>>>> [ 3446.320082] RBP: ffff88053e247868 R08: 0000000000000007 R09: 0000000000000000
>>>>>> [ 3446.320082] R10: ffff88006ffcef00 R11: 0000000000000000 R12: 0000000000000014
>>>>>> [ 3446.335888] R13: ffffea000115ffe0 R14: ffffea000115ffe0 R15: 0000000000000000
>>>>>> [ 3446.335888] FS:  00007f8c9f059700(0000) GS:ffff88006ec00000(0000) knlGS:0000000000000000
>>>>>> [ 3446.335888] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>>>>> [ 3446.335888] CR2: 0000000002cbc048 CR3: 000000054cdb4000 CR4: 00000000000006a0
>>>>>> [ 3446.335888] DR0: 00000000006de000 DR1: 00000000006de000 DR2: 0000000000000000
>>>>>> [ 3446.335888] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000602
>>>>>> [ 3446.335888] Stack:
>>>>>> [ 3446.335888]  ffff88053e247798 ffff88006eddc0b8 0000000000000016 0000000000000000
>>>>>> [ 3446.335888]  ffff88006ffd2068 ffff88006ffdb008 0000000100000000 0000000000000000
>>>>>> [ 3446.335888]  ffff88006ffdb000 0000000000000000 0000000000000003 0000000000000001
>>>>>> [ 3446.335888] Call Trace:
>>>>>> [ 3446.335888] __alloc_pages_nodemask (mm/page_alloc.c:2731)
>>>>>> [ 3446.335888] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
>>>>>> [ 3446.335888] alloc_pages_vma (include/linux/mempolicy.h:76 mm/mempolicy.c:1998)
>>>>>> [ 3446.335888] ? shmem_alloc_page (mm/shmem.c:881)
>>>>>> [ 3446.335888] ? kvm_clock_read (arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
>>>>>> [ 3446.335888] shmem_alloc_page (mm/shmem.c:881)
>>>>>> [ 3446.335888] ? __const_udelay (arch/x86/lib/delay.c:126)
>>>>>> [ 3446.335888] ? __rcu_read_unlock (kernel/rcu/update.c:97)
>>>>>> [ 3446.335888] ? find_get_entry (mm/filemap.c:979)
>>>>>> [ 3446.335888] ? find_get_entry (mm/filemap.c:940)
>>>>>> [ 3446.335888] ? find_lock_entry (mm/filemap.c:1024)
>>>>>> [ 3446.335888] shmem_getpage_gfp (mm/shmem.c:1130)
>>>>>> [ 3446.335888] ? sched_clock_local (kernel/sched/clock.c:214)
>>>>>> [ 3446.335888] ? do_read_fault.isra.42 (mm/memory.c:3523)
>>>>>> [ 3446.335888] shmem_fault (mm/shmem.c:1237)
>>>>>> [ 3446.335888] ? do_read_fault.isra.42 (mm/memory.c:3523)
>>>>>> [ 3446.335888] __do_fault (mm/memory.c:3344)
>>>>>> [ 3446.335888] ? _raw_spin_unlock (arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
>>>>>> [ 3446.335888] do_read_fault.isra.42 (mm/memory.c:3524)
>>>>>> [ 3446.335888] ? get_parent_ip (kernel/sched/core.c:2485)
>>>>>> [ 3446.335888] ? get_parent_ip (kernel/sched/core.c:2485)
>>>>>> [ 3446.335888] __handle_mm_fault (mm/memory.c:3662 mm/memory.c:3823 mm/memory.c:3950)
>>>>>> [ 3446.335888] ? __const_udelay (arch/x86/lib/delay.c:126)
>>>>>> [ 3446.335888] ? __rcu_read_unlock (kernel/rcu/update.c:97)
>>>>>> [ 3446.335888] handle_mm_fault (mm/memory.c:3973)
>>>>>> [ 3446.335888] __get_user_pages (mm/memory.c:1863)
>>>>>> [ 3446.335888] ? preempt_count_sub (kernel/sched/core.c:2541)
>>>>>> [ 3446.335888] __mlock_vma_pages_range (mm/mlock.c:255)
>>>>>> [ 3446.335888] __mm_populate (mm/mlock.c:711)
>>>>>> [ 3446.335888] vm_mmap_pgoff (include/linux/mm.h:1841 mm/util.c:402)
>>>>>> [ 3446.335888] SyS_mmap_pgoff (mm/mmap.c:1378)
>>>>>> [ 3446.335888] ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
>>>>>> [ 3446.335888] ia32_do_call (arch/x86/ia32/ia32entry.S:430)
>>>>>> [ 3446.335888] Code: 00 66 0f 1f 44 00 00 ba 02 00 00 00 31 f6 48 89 c7 e8 c1 c3 ff ff 48 8b 53 10 83 f8 03 74 08 83 f8 04 75 13 0f 1f 00 39 d0 74 0c <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 45 85 ff 75 15 49 8b 55 00
>>>>>> [ 3446.335888] RIP get_page_from_freelist (mm/page_alloc.c:1197 mm/page_alloc.c:1548 mm/page_alloc.c:2036)
>>>>>> [ 3446.335888]  RSP <ffff88053e247778>
>>>> Hey, that's not an issue, that means the patch works as intended :) And
>>>> I believe it's not a bug introduced by PATCH 1/2.
>>>>
>>>> So, according to my decodecode reading, RAX is the results of
>>>> get_pageblock_migratetype() and it's MIGRATE_RESERVE. RDX is the result
>>>> of get_freepage_migratetype() and it's MIGRATE_UNMOVABLE. The
>>>> freepage_migratetype has just been set either by __rmqueue_smallest() or
>>>> __rmqueue_fallback(), according to the free_list the page has been taken
>>>> from. So this looks like a page from MIGRATE_RESERVE pageblock found on
>>>> the !MIGRATE_RESERVE free_list, which is exactly what the patch intends
>>>> to catch.
>>>>
>>>> I think there are two possible explanations.
>>>>
>>>> 1) the pageblock is genuinely MIGRATE_RESERVE and it was misplaced by
>>>> mistake. I think it wasn't in free_pcppages_bulk() as there's the same
>>>> VM_BUG_ON which would supposedly trigger at the moment of displacing. In
>>>> theory it's possible that there's a race through __free_pages_ok() ->
>>>> free_one_page() where the get_pageblock_migratetype() in
>>>> __free_pages_ok() would race with set_pageblock_migratetype() and result
>>>> in bogus value. But nobody should be calling set_pageblock_migratetype()
>>>> on a MIGRATE_RESERVE pageblock.
>>>>
>>>> 2) the pageblock was marked as MIGRATE_RESERVE due to a race between
>>>> set_pageblock_migratetype() and set_pageblock_skip(). The latter is
>>>> currently not serialized by zone->lock, nor it uses atomic bit set. So
>>>> it may result in lost updates in a racing set_pageblock_migratetype(). I
>>>> think a well-placed race when changing pageblock from MIGRATE_MOVABLE to
>>>> MIGRATE_RECLAIMABLE could result in MIGRATE_RESERVE value. Similar races
>>>> have been already observed to be a problem where frequent changing
>>>> to/from MIGRATE_ISOLATE is involved, and I did a patch series to address
>>>> this, but it was not complete and I postponed it after Mel's changes
>>>> that remove the racy for-cycles completely. So it might be that his
>>>> "[PATCH 08/17] mm: page_alloc: Use word-based accesses for get/set
>>>> pageblock bitmaps" already solves this bug (but maybe only on certain
>>>> architectures where you don't need atomic operations). You might try
>>>> that patch if you can reproduce this bug frequently enough?
>>>
>>> I've tried that patch, but still see the same BUG_ON.
>>
>> Oh damn, I've realized that my assumptions about MIGRATE_RESERVE
>> pageblocks being created only on zone init time were wrong.
>> setup_zone_migrate_reserve() is called also from the handler of
>> min_free_kbytes sysctl... does trinity try to change that while
>> running?
>> The function will change MOVABLE pageblocks to RESERVE and try to
>> move all free pages to the RESERVE free_list, but of course pages on
>> pcplists will remain MOVABLE and may trigger the VM_BUG_ON. You
>> triggered the bug with page on MOVABLE free_list (in the first reply
>> I said its UNMOVABLE by mistake) so this might be good explanation
>> if trinity changes min_free_kbytes.
>>
>> Furthermore, I think there's a problem that
>> setup_zone_migrate_reserve() operates on pageblocks, but as MAX_ODER
>> is higher than pageblock_order, RESERVE pages might be merged with
>> buddies of different migratetype and end up on their free_list. That
>> seems to me like a flaw in the design of reserves, but perhaps
>> others won't think it's serious enough to fix?
>>
>> So in the end this VM_DEBUG check probably cannot work anymore for
>> MIGRATE_RESERVE, only for CMA. I'm not sure if it's worth keeping it
>> only for CMA, what are the CMA guys' opinions on that?
> 
> I really don't want it. That was I didn't add my Acked-by at that time.
> For a long time, I never wanted to add more overhead hot path due to
> CMA unless it's really critical. It's same to this.
> Although such debug patch helps to notice something goes wrong for CMA,
> more information would be helpful to know why CMA failed because
> there are another potential reasons to fail CMA allocation.
> 
> One of the idea about that is to store alloc trace into somewhere(ex,
> naive idea is page description like page-owner) and then we could investigate
> what's the owner of that page so we could know why we fail to migrate it out.
> With that, we would figure out how on earth such page is allocated from CMA
> and it would be more helpful rather just VM_BUG_ON notice.
> 
> The whole point is I'd like to avoid adding more overhead to hot path for
> rare case although it's debugging feature.

OK. I'm not that concerned with VM_DEBUG overhead as it's intended for
testing, not production. But as you say the patch is not that useful
without the MIGRATE_RESERVE part, so Andrew could you please drop the
patch (mm-page_alloc-debug_vm-checks-for-free_list-placement-of-cma-and-reserve-pages.patch)?

It would be also nice to change the commit log of patch
(mm-page_alloc-prevent-migrate_reserve-pages-from-being-misplaced.patch)
to reflect the recent findings. I will send another patch to deal with
MIGRATE_RESERVE pageblock stealing, as we clearly cannot prevent
misplaced MIGRATE_RESERVE pages when MIGRATE_RESERVE pageblocks are
created dynamically through min_free_kbytes sysctl.

Thanks.

---8<---
From: Vlastimil Babka <vbabka@suse.cz>
Subject: mm/page_alloc: prevent rmqueue_bulk misplacing MIGRATE_RESERVE pages

For the MIGRATE_RESERVE pages, it is useful when they do not get misplaced on
free_list of other migratetype, otherwise they might get allocated prematurely
and e.g. fragment the MIGRATE_RESEVE pageblocks. While this cannot be avoided
completely when allocating new MIGRATE_RESERVE pageblocks in min_free_kbytes
sysctl handler, we should prevent the misplacement where possible.

Currently, it is possible for the misplacement to happen when a MIGRATE_RESERVE
page is allocated on pcplist through rmqueue_bulk() as a fallback for other
desired migratetype, and then later freed back through free_pcppages_bulk()
without being actually used. This happens because free_pcppages_bulk() uses
get_freepage_migratetype() to choose the free_list, and rmqueue_bulk() calls
set_freepage_migratetype() with the *desired* migratetype and not the page's
original MIGRATE_RESERVE migratetype.

This patch fixes the problem by moving the call to set_freepage_migratetype()
from rmqueue_bulk() down to __rmqueue_smallest() and __rmqueue_fallback() where
the actual page's migratetype (e.g. from which free_list the page is taken from)
is used. Note that this migratetype might be different from the pageblock's
migratetype due to freepage stealing decisions. This is OK, as page stealing
never uses MIGRATE_RESERVE as a fallback, and also takes care to leave all
MIGRATE_CMA pages on the correct freelist.

Therefore, as an additional benefit, the call to get_pageblock_migratetype()
from rmqueue_bulk() when CMA is enabled, can be removed completely.  This
relies on the fact that MIGRATE_CMA pageblocks are created only during system
init, and the above. The related is_migrate_isolate() check is also
unnecessary, as memory isolation has other ways to move pages between
freelists, and drain pcp lists containing pages that should be isolated. The
buffered_rmqueue() can also benefit from calling get_freepage_migratetype()
instead of get_pageblock_migratetype().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
Reported-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Suggested-by: Mel Gorman <mgorman@suse.de>
Acked-by: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
