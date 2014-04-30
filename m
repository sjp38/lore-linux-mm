Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE566B0036
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:47:03 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id z10so993259pdj.14
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 14:47:01 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id to1si14681166pab.199.2014.04.30.14.47.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 14:47:00 -0700 (PDT)
Message-ID: <53616F39.2070001@oracle.com>
Date: Wed, 30 Apr 2014 17:46:33 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list placement
 of CMA and RESERVE pages
References: <533D8015.1000106@suse.cz> <1396539618-31362-1-git-send-email-vbabka@suse.cz> <1396539618-31362-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1396539618-31362-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Dave Jones <davej@redhat.com>

On 04/03/2014 11:40 AM, Vlastimil Babka wrote:
> For the MIGRATE_RESERVE pages, it is important they do not get misplaced
> on free_list of other migratetype, otherwise the whole MIGRATE_RESERVE
> pageblock might be changed to other migratetype in try_to_steal_freepages().
> For MIGRATE_CMA, the pages also must not go to a different free_list, otherwise
> they could get allocated as unmovable and result in CMA failure.
> 
> This is ensured by setting the freepage_migratetype appropriately when placing
> pages on pcp lists, and using the information when releasing them back to
> free_list. It is also assumed that CMA and RESERVE pageblocks are created only
> in the init phase. This patch adds DEBUG_VM checks to catch any regressions
> introduced for this invariant.
> 
> Cc: Yong-Taek Lee <ytk.lee@samsung.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Two issues with this patch.

First:

[ 3446.320082] kernel BUG at mm/page_alloc.c:1197!
[ 3446.320082] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 3446.320082] Dumping ftrace buffer:
[ 3446.320082]    (ftrace buffer empty)
[ 3446.320082] Modules linked in:
[ 3446.320082] CPU: 1 PID: 8923 Comm: trinity-c42 Not tainted 3.15.0-rc3-next-20140429-sasha-00015-g7c7e0a7-dirty #427
[ 3446.320082] task: ffff88053e208000 ti: ffff88053e246000 task.ti: ffff88053e246000
[ 3446.320082] RIP: get_page_from_freelist (mm/page_alloc.c:1197 mm/page_alloc.c:1548 mm/page_alloc.c:2036)
[ 3446.320082] RSP: 0018:ffff88053e247778  EFLAGS: 00010002
[ 3446.320082] RAX: 0000000000000003 RBX: ffffea0000f40000 RCX: 0000000000000008
[ 3446.320082] RDX: 0000000000000002 RSI: 0000000000000003 RDI: 00000000000000a0
[ 3446.320082] RBP: ffff88053e247868 R08: 0000000000000007 R09: 0000000000000000
[ 3446.320082] R10: ffff88006ffcef00 R11: 0000000000000000 R12: 0000000000000014
[ 3446.335888] R13: ffffea000115ffe0 R14: ffffea000115ffe0 R15: 0000000000000000
[ 3446.335888] FS:  00007f8c9f059700(0000) GS:ffff88006ec00000(0000) knlGS:0000000000000000
[ 3446.335888] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3446.335888] CR2: 0000000002cbc048 CR3: 000000054cdb4000 CR4: 00000000000006a0
[ 3446.335888] DR0: 00000000006de000 DR1: 00000000006de000 DR2: 0000000000000000
[ 3446.335888] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000602
[ 3446.335888] Stack:
[ 3446.335888]  ffff88053e247798 ffff88006eddc0b8 0000000000000016 0000000000000000
[ 3446.335888]  ffff88006ffd2068 ffff88006ffdb008 0000000100000000 0000000000000000
[ 3446.335888]  ffff88006ffdb000 0000000000000000 0000000000000003 0000000000000001
[ 3446.335888] Call Trace:
[ 3446.335888] __alloc_pages_nodemask (mm/page_alloc.c:2731)
[ 3446.335888] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3446.335888] alloc_pages_vma (include/linux/mempolicy.h:76 mm/mempolicy.c:1998)
[ 3446.335888] ? shmem_alloc_page (mm/shmem.c:881)
[ 3446.335888] ? kvm_clock_read (arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[ 3446.335888] shmem_alloc_page (mm/shmem.c:881)
[ 3446.335888] ? __const_udelay (arch/x86/lib/delay.c:126)
[ 3446.335888] ? __rcu_read_unlock (kernel/rcu/update.c:97)
[ 3446.335888] ? find_get_entry (mm/filemap.c:979)
[ 3446.335888] ? find_get_entry (mm/filemap.c:940)
[ 3446.335888] ? find_lock_entry (mm/filemap.c:1024)
[ 3446.335888] shmem_getpage_gfp (mm/shmem.c:1130)
[ 3446.335888] ? sched_clock_local (kernel/sched/clock.c:214)
[ 3446.335888] ? do_read_fault.isra.42 (mm/memory.c:3523)
[ 3446.335888] shmem_fault (mm/shmem.c:1237)
[ 3446.335888] ? do_read_fault.isra.42 (mm/memory.c:3523)
[ 3446.335888] __do_fault (mm/memory.c:3344)
[ 3446.335888] ? _raw_spin_unlock (arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
[ 3446.335888] do_read_fault.isra.42 (mm/memory.c:3524)
[ 3446.335888] ? get_parent_ip (kernel/sched/core.c:2485)
[ 3446.335888] ? get_parent_ip (kernel/sched/core.c:2485)
[ 3446.335888] __handle_mm_fault (mm/memory.c:3662 mm/memory.c:3823 mm/memory.c:3950)
[ 3446.335888] ? __const_udelay (arch/x86/lib/delay.c:126)
[ 3446.335888] ? __rcu_read_unlock (kernel/rcu/update.c:97)
[ 3446.335888] handle_mm_fault (mm/memory.c:3973)
[ 3446.335888] __get_user_pages (mm/memory.c:1863)
[ 3446.335888] ? preempt_count_sub (kernel/sched/core.c:2541)
[ 3446.335888] __mlock_vma_pages_range (mm/mlock.c:255)
[ 3446.335888] __mm_populate (mm/mlock.c:711)
[ 3446.335888] vm_mmap_pgoff (include/linux/mm.h:1841 mm/util.c:402)
[ 3446.335888] SyS_mmap_pgoff (mm/mmap.c:1378)
[ 3446.335888] ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
[ 3446.335888] ia32_do_call (arch/x86/ia32/ia32entry.S:430)
[ 3446.335888] Code: 00 66 0f 1f 44 00 00 ba 02 00 00 00 31 f6 48 89 c7 e8 c1 c3 ff ff 48 8b 53 10 83 f8 03 74 08 83 f8 04 75 13 0f 1f 00 39 d0 74 0c <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 45 85 ff 75 15 49 8b 55 00
[ 3446.335888] RIP get_page_from_freelist (mm/page_alloc.c:1197 mm/page_alloc.c:1548 mm/page_alloc.c:2036)
[ 3446.335888]  RSP <ffff88053e247778>

And second:

[snip]

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2dbaba1..0ee9f8c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -697,6 +697,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			page = list_entry(list->prev, struct page, lru);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
> +
> +			VM_BUG_ON(!check_freepage_migratetype(page));
>  			mt = get_freepage_migratetype(page);
>  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>  			__free_one_page(page, zone, 0, mt);
> @@ -1190,6 +1192,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  		struct page *page = __rmqueue(zone, order, migratetype);
>  		if (unlikely(page == NULL))
>  			break;
> +		VM_BUG_ON(!check_freepage_migratetype(page));
>  
>  		/*
>  		 * Split buddy pages returned by expand() are received here
> 

Could the VM_BUG_ON()s be VM_BUG_ON_PAGE() instead?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
