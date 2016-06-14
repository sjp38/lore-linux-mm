Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31283828FF
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 01:50:55 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y82so103351332oig.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 22:50:55 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id u4si3514374pal.94.2016.06.13.22.50.53
        for <linux-mm@kvack.org>;
        Mon, 13 Jun 2016 22:50:54 -0700 (PDT)
Date: Tue, 14 Jun 2016 14:52:58 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 1/7] mm/compaction: split freepages without holding
 the zone lock
Message-ID: <20160614055257.GA13753@js1304-P5Q-DELUXE>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <575F1813.4020700@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <575F1813.4020700@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 13, 2016 at 04:31:15PM -0400, Sasha Levin wrote:
> On 05/25/2016 10:37 PM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > We don't need to split freepages with holding the zone lock. It will cause
> > more contention on zone lock so not desirable.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hey Joonsoo,

Hello, Sasha.
> 
> I'm seeing the following corruption/crash which seems to be related to
> this patch:

Could you tell me why you think that following corruption is related
to this patch? list_del() in __isolate_free_page() is unchanged part.

Before this patch, we did it by split_free_page() ->
__isolate_free_page() -> list_del(). With this patch, we do it by
calling __isolate_free_page() directly.

Thanks.


> [ 3777.807224] ------------[ cut here ]------------
> 
> [ 3777.807834] WARNING: CPU: 5 PID: 3270 at lib/list_debug.c:62 __list_del_entry+0x14e/0x280
> 
> [ 3777.808562] list_del corruption. next->prev should be ffffea0004a76120, but was ffffea0004a72120
> 
> [ 3777.809498] Modules linked in:
> 
> [ 3777.809923] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101
> 
> [ 3777.811014]  1ffff100f9315d7b 000000000bb7299a ffff8807c98aec60 ffffffffa0035b2b
> 
> [ 3777.811816]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0
> 
> [ 3777.812662]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ade0 ffff8807c98aece0
> 
> [ 3777.813493] Call Trace:
> 
> [ 3777.813796] dump_stack (lib/dump_stack.c:53)
> [ 3777.814310] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
> [ 3777.814947] ? is_module_text_address (kernel/module.c:4185)
> [ 3777.815571] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
> [ 3777.816174] ? vprintk_default (kernel/printk/printk.c:1886)
> [ 3777.816761] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
> [ 3777.817381] __warn (kernel/panic.c:518)
> [ 3777.817867] warn_slowpath_fmt (kernel/panic.c:526)
> [ 3777.818428] ? __warn (kernel/panic.c:526)
> [ 3777.819001] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
> [ 3777.819541] __list_del_entry (lib/list_debug.c:60 (discriminator 1))
> [ 3777.820116] ? __list_add (lib/list_debug.c:45)
> [ 3777.820721] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [ 3777.821347] list_del (lib/list_debug.c:78)
> [ 3777.821829] __isolate_free_page (mm/page_alloc.c:2514)
> [ 3777.822400] ? __zone_watermark_ok (mm/page_alloc.c:2493)
> [ 3777.823007] isolate_freepages_block (mm/compaction.c:498)
> [ 3777.823629] ? compact_unlock_should_abort (mm/compaction.c:417)
> [ 3777.824312] compaction_alloc (mm/compaction.c:1112 mm/compaction.c:1156)
> [ 3777.824871] ? isolate_freepages_block (mm/compaction.c:1146)
> [ 3777.825512] ? __page_cache_release (mm/swap.c:73)
> [ 3777.826127] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
> [ 3777.826712] ? __reset_isolation_suitable (mm/compaction.c:1175)
> [ 3777.827398] ? isolate_freepages_block (mm/compaction.c:1146)
> [ 3777.828109] ? buffer_migrate_page (mm/migrate.c:1301)
> [ 3777.828727] compact_zone (mm/compaction.c:1555)
> [ 3777.829290] ? compaction_restarting (mm/compaction.c:1476)
> [ 3777.829969] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
> [ 3777.830607] compact_zone_order (mm/compaction.c:1653)
> [ 3777.831204] ? kick_process (kernel/sched/core.c:2692)
> [ 3777.831774] ? compact_zone (mm/compaction.c:1637)
> [ 3777.832336] ? io_schedule_timeout (kernel/sched/core.c:3266)
> [ 3777.832934] try_to_compact_pages (mm/compaction.c:1717)
> [ 3777.833550] ? compaction_zonelist_suitable (mm/compaction.c:1679)
> [ 3777.834265] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
> [ 3777.834922] ? get_page_from_freelist (mm/page_alloc.c:3172)
> [ 3777.835549] __alloc_pages_slowpath (mm/page_alloc.c:3741)
> [ 3777.836210] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
> [ 3777.836744] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
> [ 3777.837429] ? get_page_from_freelist (mm/page_alloc.c:2950)
> [ 3777.838072] ? release_pages (mm/swap.c:731)
> [ 3777.838610] ? __isolate_free_page (mm/page_alloc.c:2883)
> [ 3777.839209] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
> [ 3777.839826] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
> [ 3777.840427] __alloc_pages_nodemask (mm/page_alloc.c:3841)
> [ 3777.841071] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
> [ 3777.841608] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
> [ 3777.842253] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
> [ 3777.842839] ? up_write (kernel/locking/rwsem.c:112)
> [ 3777.843350] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
> [ 3777.844125] khugepaged_alloc_page (mm/khugepaged.c:752)
> [ 3777.844719] collapse_huge_page (mm/khugepaged.c:948)
> [ 3777.845332] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
> [ 3777.846020] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
> [ 3777.846608] ? remove_wait_queue (kernel/sched/wait.c:292)
> [ 3777.847181] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
> [ 3777.847704] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
> [ 3777.848297] ? collapse_huge_page (mm/khugepaged.c:1840)
> [ 3777.848950] ? io_schedule_timeout (kernel/sched/core.c:3266)
> [ 3777.849555] ? default_wake_function (kernel/sched/core.c:3544)
> [ 3777.850161] ? __wake_up_common (kernel/sched/wait.c:73)
> [ 3777.850724] ? __kthread_parkme (kernel/kthread.c:168)
> [ 3777.851306] kthread (kernel/kthread.c:209)
> [ 3777.851819] ? collapse_huge_page (mm/khugepaged.c:1840)
> [ 3777.852448] ? kthread_worker_fn (kernel/kthread.c:178)
> [ 3777.853045] ret_from_fork (arch/x86/entry/entry_64.S:390)
> [ 3777.853605] ? kthread_worker_fn (kernel/kthread.c:178)
> [ 3777.854173] ---[ end trace 8cbbecee22435cc2 ]---
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
