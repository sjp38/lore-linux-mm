Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3E06B0279
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 16:31:38 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x6so140473848oif.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 13:31:38 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 87si24345743iok.107.2016.06.13.13.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 13:31:32 -0700 (PDT)
Subject: Re: [PATCH v2 1/7] mm/compaction: split freepages without holding the
 zone lock
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <575F1813.4020700@oracle.com>
Date: Mon, 13 Jun 2016 16:31:15 -0400
MIME-Version: 1.0
In-Reply-To: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/25/2016 10:37 PM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> We don't need to split freepages with holding the zone lock. It will cause
> more contention on zone lock so not desirable.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hey Joonsoo,

I'm seeing the following corruption/crash which seems to be related to
this patch:

[ 3777.807224] ------------[ cut here ]------------

[ 3777.807834] WARNING: CPU: 5 PID: 3270 at lib/list_debug.c:62 __list_del_entry+0x14e/0x280

[ 3777.808562] list_del corruption. next->prev should be ffffea0004a76120, but was ffffea0004a72120

[ 3777.809498] Modules linked in:

[ 3777.809923] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3777.811014]  1ffff100f9315d7b 000000000bb7299a ffff8807c98aec60 ffffffffa0035b2b

[ 3777.811816]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3777.812662]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ade0 ffff8807c98aece0

[ 3777.813493] Call Trace:

[ 3777.813796] dump_stack (lib/dump_stack.c:53)
[ 3777.814310] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3777.814947] ? is_module_text_address (kernel/module.c:4185)
[ 3777.815571] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.816174] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3777.816761] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.817381] __warn (kernel/panic.c:518)
[ 3777.817867] warn_slowpath_fmt (kernel/panic.c:526)
[ 3777.818428] ? __warn (kernel/panic.c:526)
[ 3777.819001] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3777.819541] __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.820116] ? __list_add (lib/list_debug.c:45)
[ 3777.820721] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3777.821347] list_del (lib/list_debug.c:78)
[ 3777.821829] __isolate_free_page (mm/page_alloc.c:2514)
[ 3777.822400] ? __zone_watermark_ok (mm/page_alloc.c:2493)
[ 3777.823007] isolate_freepages_block (mm/compaction.c:498)
[ 3777.823629] ? compact_unlock_should_abort (mm/compaction.c:417)
[ 3777.824312] compaction_alloc (mm/compaction.c:1112 mm/compaction.c:1156)
[ 3777.824871] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3777.825512] ? __page_cache_release (mm/swap.c:73)
[ 3777.826127] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3777.826712] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3777.827398] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3777.828109] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3777.828727] compact_zone (mm/compaction.c:1555)
[ 3777.829290] ? compaction_restarting (mm/compaction.c:1476)
[ 3777.829969] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3777.830607] compact_zone_order (mm/compaction.c:1653)
[ 3777.831204] ? kick_process (kernel/sched/core.c:2692)
[ 3777.831774] ? compact_zone (mm/compaction.c:1637)
[ 3777.832336] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3777.832934] try_to_compact_pages (mm/compaction.c:1717)
[ 3777.833550] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3777.834265] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3777.834922] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3777.835549] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3777.836210] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3777.836744] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3777.837429] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3777.838072] ? release_pages (mm/swap.c:731)
[ 3777.838610] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3777.839209] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3777.839826] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3777.840427] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3777.841071] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3777.841608] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3777.842253] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3777.842839] ? up_write (kernel/locking/rwsem.c:112)
[ 3777.843350] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3777.844125] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3777.844719] collapse_huge_page (mm/khugepaged.c:948)
[ 3777.845332] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3777.846020] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3777.846608] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3777.847181] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3777.847704] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3777.848297] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3777.848950] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3777.849555] ? default_wake_function (kernel/sched/core.c:3544)
[ 3777.850161] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3777.850724] ? __kthread_parkme (kernel/kthread.c:168)
[ 3777.851306] kthread (kernel/kthread.c:209)
[ 3777.851819] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3777.852448] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3777.853045] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3777.853605] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3777.854173] ---[ end trace 8cbbecee22435cc2 ]---

[ 3777.854602] ------------[ cut here ]------------

[ 3777.855101] WARNING: CPU: 5 PID: 3270 at lib/list_debug.c:62 __list_del_entry+0x14e/0x280

[ 3777.855863] list_del corruption. next->prev should be ffffea0004a761e0, but was ffffea0004a72020

[ 3777.856701] Modules linked in:

[ 3777.857041] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3777.858153]  1ffff100f9315d7b 000000000bb7299a ffff8807c98aec60 ffffffffa0035b2b

[ 3777.858963]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3777.859724]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ade0 ffff8807c98aece0

[ 3777.860494] Call Trace:

[ 3777.860752] dump_stack (lib/dump_stack.c:53)
[ 3777.861266] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3777.861878] ? is_module_text_address (kernel/module.c:4185)
[ 3777.862487] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.863059] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3777.863643] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.864230] __warn (kernel/panic.c:518)
[ 3777.864720] warn_slowpath_fmt (kernel/panic.c:526)
[ 3777.865314] ? __warn (kernel/panic.c:526)
[ 3777.865808] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3777.866343] __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.866911] ? __list_add (lib/list_debug.c:45)
[ 3777.867427] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3777.868045] list_del (lib/list_debug.c:78)
[ 3777.868517] __isolate_free_page (mm/page_alloc.c:2514)
[ 3777.869091] ? __zone_watermark_ok (mm/page_alloc.c:2493)
[ 3777.869676] isolate_freepages_block (mm/compaction.c:498)
[ 3777.870350] ? compact_unlock_should_abort (mm/compaction.c:417)
[ 3777.871014] compaction_alloc (mm/compaction.c:1112 mm/compaction.c:1156)
[ 3777.871561] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3777.872216] ? __page_cache_release (mm/swap.c:73)
[ 3777.872846] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3777.873416] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3777.874163] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3777.874811] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3777.875421] compact_zone (mm/compaction.c:1555)
[ 3777.875980] ? compaction_restarting (mm/compaction.c:1476)
[ 3777.876600] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3777.877256] compact_zone_order (mm/compaction.c:1653)
[ 3777.877821] ? kick_process (kernel/sched/core.c:2692)
[ 3777.878412] ? compact_zone (mm/compaction.c:1637)
[ 3777.879053] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3777.879657] try_to_compact_pages (mm/compaction.c:1717)
[ 3777.880252] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3777.880957] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3777.881624] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3777.882300] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3777.882998] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3777.883588] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3777.884319] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3777.884988] ? release_pages (mm/swap.c:731)
[ 3777.885539] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3777.886163] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3777.886756] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3777.887305] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3777.887914] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3777.888432] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3777.889092] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3777.889642] ? up_write (kernel/locking/rwsem.c:112)
[ 3777.890192] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3777.890836] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3777.891436] collapse_huge_page (mm/khugepaged.c:948)
[ 3777.892023] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3777.892630] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3777.893181] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3777.893769] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3777.894318] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3777.894912] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3777.895542] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3777.896181] ? default_wake_function (kernel/sched/core.c:3544)
[ 3777.896851] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3777.897425] ? __kthread_parkme (kernel/kthread.c:168)
[ 3777.898017] kthread (kernel/kthread.c:209)
[ 3777.898501] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3777.899086] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3777.899682] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3777.900241] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3777.900887] ---[ end trace 8cbbecee22435cc3 ]---

[ 3777.901335] ------------[ cut here ]------------

[ 3777.901782] WARNING: CPU: 5 PID: 3270 at lib/list_debug.c:62 __list_del_entry+0x14e/0x280

[ 3777.902545] list_del corruption. next->prev should be ffffea0004a76220, but was ffffea0005a4f420

[ 3777.903383] Modules linked in:

[ 3777.903706] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3777.904734]  1ffff100f9315d7b 000000000bb7299a ffff8807c98aec60 ffffffffa0035b2b

[ 3777.905497]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3777.906250]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ade0 ffff8807c98aece0

[ 3777.907002] Call Trace:

[ 3777.907258] dump_stack (lib/dump_stack.c:53)
[ 3777.907822] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3777.908425] ? is_module_text_address (kernel/module.c:4185)
[ 3777.909040] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.909633] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3777.910233] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.910813] __warn (kernel/panic.c:518)
[ 3777.911278] warn_slowpath_fmt (kernel/panic.c:526)
[ 3777.911852] ? __warn (kernel/panic.c:526)
[ 3777.912343] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3777.912883] __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.913443] ? __list_add (lib/list_debug.c:45)
[ 3777.913974] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3777.914607] list_del (lib/list_debug.c:78)
[ 3777.915064] __isolate_free_page (mm/page_alloc.c:2514)
[ 3777.915647] ? __zone_watermark_ok (mm/page_alloc.c:2493)
[ 3777.916281] isolate_freepages_block (mm/compaction.c:498)
[ 3777.916930] ? compact_unlock_should_abort (mm/compaction.c:417)
[ 3777.917646] compaction_alloc (mm/compaction.c:1112 mm/compaction.c:1156)
[ 3777.918216] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3777.918862] ? __page_cache_release (mm/swap.c:73)
[ 3777.919495] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3777.920087] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3777.920733] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3777.921345] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3777.921971] compact_zone (mm/compaction.c:1555)
[ 3777.922543] ? compaction_restarting (mm/compaction.c:1476)
[ 3777.923189] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3777.923814] compact_zone_order (mm/compaction.c:1653)
[ 3777.924397] ? kick_process (kernel/sched/core.c:2692)
[ 3777.924941] ? compact_zone (mm/compaction.c:1637)
[ 3777.925502] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3777.926102] try_to_compact_pages (mm/compaction.c:1717)
[ 3777.926708] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3777.927403] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3777.928074] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3777.928745] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3777.929384] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3777.929968] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3777.930644] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3777.931350] ? release_pages (mm/swap.c:731)
[ 3777.931963] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3777.932566] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3777.933157] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3777.936090] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3777.936721] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3777.937281] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3777.937945] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3777.938489] ? up_write (kernel/locking/rwsem.c:112)
[ 3777.938991] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3777.939604] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3777.940235] collapse_huge_page (mm/khugepaged.c:948)
[ 3777.940812] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3777.941435] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3777.941974] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3777.942552] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3777.943067] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3777.943667] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3777.944262] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3777.944846] ? default_wake_function (kernel/sched/core.c:3544)
[ 3777.945452] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3777.946076] ? __kthread_parkme (kernel/kthread.c:168)
[ 3777.946647] kthread (kernel/kthread.c:209)
[ 3777.947188] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3777.947788] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3777.948366] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3777.948892] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3777.949477] ---[ end trace 8cbbecee22435cc4 ]---

[ 3777.949918] ------------[ cut here ]------------

[ 3777.950377] WARNING: CPU: 5 PID: 3270 at lib/list_debug.c:62 __list_del_entry+0x14e/0x280

[ 3777.951149] list_del corruption. next->prev should be ffffea0004a76320, but was ffffea0004a76020

[ 3777.951976] Modules linked in:

[ 3777.952314] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3777.953347]  1ffff100f9315d7b 000000000bb7299a ffff8807c98aec60 ffffffffa0035b2b

[ 3777.954104]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3777.954896]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ade0 ffff8807c98aece0

[ 3777.955693] Call Trace:

[ 3777.955955] dump_stack (lib/dump_stack.c:53)
[ 3777.956493] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3777.957179] ? is_module_text_address (kernel/module.c:4185)
[ 3777.957781] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.958373] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3777.958999] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.959583] __warn (kernel/panic.c:518)
[ 3777.960103] warn_slowpath_fmt (kernel/panic.c:526)
[ 3777.960688] ? __warn (kernel/panic.c:526)
[ 3777.961251] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3777.961831] __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3777.962457] ? __list_add (lib/list_debug.c:45)
[ 3777.963032] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3777.963642] list_del (lib/list_debug.c:78)
[ 3777.964125] __isolate_free_page (mm/page_alloc.c:2514)
[ 3777.964716] ? __zone_watermark_ok (mm/page_alloc.c:2493)
[ 3777.965316] isolate_freepages_block (mm/compaction.c:498)
[ 3777.965944] ? compact_unlock_should_abort (mm/compaction.c:417)
[ 3777.966605] compaction_alloc (mm/compaction.c:1112 mm/compaction.c:1156)
[ 3777.967167] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3777.967804] ? __page_cache_release (mm/swap.c:73)
[ 3777.968409] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3777.969006] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3777.969700] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3777.970366] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3777.970996] compact_zone (mm/compaction.c:1555)
[ 3777.971603] ? compaction_restarting (mm/compaction.c:1476)
[ 3777.972204] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3777.972833] compact_zone_order (mm/compaction.c:1653)
[ 3777.973420] ? kick_process (kernel/sched/core.c:2692)
[ 3777.974074] ? compact_zone (mm/compaction.c:1637)
[ 3777.974679] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3777.975288] try_to_compact_pages (mm/compaction.c:1717)
[ 3777.975873] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3777.976559] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3777.977241] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3777.977915] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3777.978537] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3777.979084] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3777.979739] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3777.980373] ? release_pages (mm/swap.c:731)
[ 3777.980964] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3777.981566] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3777.982129] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3777.982684] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3777.983306] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3777.983850] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3777.984482] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3777.985070] ? up_write (kernel/locking/rwsem.c:112)
[ 3777.985559] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3777.986162] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3777.986809] collapse_huge_page (mm/khugepaged.c:948)
[ 3777.987404] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3777.988057] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3777.988595] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3777.989164] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3777.989690] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3777.990285] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3777.990916] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3777.991514] ? default_wake_function (kernel/sched/core.c:3544)
[ 3777.992122] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3777.992722] ? __kthread_parkme (kernel/kthread.c:168)
[ 3777.993291] kthread (kernel/kthread.c:209)
[ 3777.993810] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3777.994433] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3777.995060] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3777.995587] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3777.996176] ---[ end trace 8cbbecee22435cc5 ]---

[ 3777.997195] ------------[ cut here ]------------

[ 3777.997838] WARNING: CPU: 16 PID: 3730 at lib/list_debug.c:29 __list_add+0xc6/0x240

[ 3777.998568] list_add corruption. next->prev should be prev (ffff8801b7fd8068), but was ffffea0004f56420. (next=ffffea0004f48e20).

[ 3777.999804] Modules linked in:

[ 3778.000141] CPU: 16 PID: 3730 Comm: kswapd0 Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.001223]  1ffff10066e36de3 00000000be0b1ffd ffff8803371b6fa0 ffffffffa0035b2b

[ 3778.001958]  ffffffff00000010 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.002726]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ab20 ffff8803371b7020

[ 3778.003547] Call Trace:

[ 3778.003876] dump_stack (lib/dump_stack.c:53)
[ 3778.004400] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.005025] ? is_module_text_address (kernel/module.c:4185)
[ 3778.005652] ? __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.006148] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3778.006714] ? __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.007257] __warn (kernel/panic.c:518)
[ 3778.007752] ? kvm_sched_clock_read (arch/x86/kernel/kvmclock.c:104)
[ 3778.008381] warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.008958] ? __warn (kernel/panic.c:526)
[ 3778.009479] ? qstat_write (kernel/locking/qspinlock.c:411)
[ 3778.010044] ? __radix_tree_lookup (lib/radix-tree.c:673)
[ 3778.010621] __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.011109] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.011703] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.012290] free_pcppages_bulk (mm/page_alloc.c:878 mm/page_alloc.c:1135)
[ 3778.012905] ? __free_page_frag (mm/page_alloc.c:1084)
[ 3778.013468] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.014078] free_hot_cold_page (mm/page_alloc.c:2442 (discriminator 1))
[ 3778.014627] ? drain_all_pages (mm/page_alloc.c:2403)
[ 3778.015186] ? uncharge_list (mm/memcontrol.c:5536)
[ 3778.015757] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.016359] free_hot_cold_page_list (mm/page_alloc.c:2456 (discriminator 3))
[ 3778.016950] shrink_page_list (include/linux/compiler.h:222 include/linux/list.h:189 include/linux/list.h:296 mm/vmscan.c:1238)
[ 3778.017505] ? putback_lru_page (mm/vmscan.c:889)
[ 3778.018098] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.018736] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.019343] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.019964] ? __mod_zone_page_state (mm/vmstat.c:249)
[ 3778.020551] shrink_inactive_list (include/linux/spinlock.h:332 mm/vmscan.c:1629)
[ 3778.021130] ? putback_inactive_pages (mm/vmscan.c:1573)
[ 3778.021728] ? zone_reclaimable_pages (mm/vmscan.c:208)
[ 3778.022336] ? _find_next_bit (lib/find_bit.c:54)
[ 3778.022875] ? zone_reclaimable (include/linux/vmstat.h:166 mm/vmscan.c:212)
[ 3778.023432] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.024068] ? get_scan_count (mm/vmscan.c:1954)
[ 3778.024656] ? blk_start_plug (block/blk-core.c:3170 (discriminator 1))
[ 3778.025206] ? blk_lld_busy (block/blk-core.c:3170)
[ 3778.025724] shrink_zone_memcg (mm/vmscan.c:1932 mm/vmscan.c:2224)
[ 3778.026299] ? shrink_active_list (mm/vmscan.c:2181)
[ 3778.026887] ? css_next_descendant_pre (kernel/cgroup.c:4028)
[ 3778.027507] ? mem_cgroup_iter (mm/memcontrol.c:889)
[ 3778.028101] ? preempt_count_add (include/linux/ftrace.h:724 kernel/sched/core.c:3074 kernel/sched/core.c:3099)
[ 3778.028661] shrink_zone (mm/vmscan.c:2407)
[ 3778.029174] ? mem_cgroup_split_huge_fixup (mm/memcontrol.c:2607)
[ 3778.029849] ? shrink_zone_memcg (mm/vmscan.c:2374)
[ 3778.030457] ? zone_watermark_ok_safe (mm/page_alloc.c:2839)
[ 3778.031062] kswapd (./arch/x86/include/asm/bitops.h:113 mm/vmscan.c:3090 mm/vmscan.c:3239 mm/vmscan.c:3427)
[ 3778.031539] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.032270] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.033010] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3778.035456] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.036004] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.037227] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.037792] kthread (kernel/kthread.c:209)
[ 3778.038280] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.038921] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.039506] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.040082] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.040655] ---[ end trace 8cbbecee22435cc6 ]---

[ 3778.041122] ------------[ cut here ]------------

[ 3778.041560] WARNING: CPU: 16 PID: 3730 at lib/list_debug.c:33 __list_add+0x11f/0x240

[ 3778.042272] list_add corruption. prev->next should be next (ffff8801b7fd8000), but was ffffea00050f0a20. (prev=ffffea00050f09a0).

[ 3778.043351] Modules linked in:

[ 3778.043666] CPU: 16 PID: 3730 Comm: kswapd0 Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.044643]  1ffff10066e36de3 00000000be0b1ffd ffff8803371b6fa0 ffffffffa0035b2b

[ 3778.045400]  ffffffff00000010 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.046136]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2abe0 ffff8803371b7020

[ 3778.046865] Call Trace:

[ 3778.047112] dump_stack (lib/dump_stack.c:53)
[ 3778.047627] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.048251] ? is_module_text_address (kernel/module.c:4185)
[ 3778.048827] ? __list_add (lib/list_debug.c:34 (discriminator 3))
[ 3778.049325] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3778.049851] ? __list_add (lib/list_debug.c:34 (discriminator 3))
[ 3778.050346] __warn (kernel/panic.c:518)
[ 3778.050879] ? kvm_sched_clock_read (arch/x86/kernel/kvmclock.c:104)
[ 3778.051429] warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.051954] ? __warn (kernel/panic.c:526)
[ 3778.052479] ? qstat_write (kernel/locking/qspinlock.c:411)
[ 3778.053006] ? __radix_tree_lookup (lib/radix-tree.c:673)
[ 3778.053580] __list_add (lib/list_debug.c:34 (discriminator 3))
[ 3778.054154] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.054736] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.055375] ? __mod_zone_page_state (mm/vmstat.c:249)
[ 3778.055964] free_pcppages_bulk (include/linux/list.h:77 mm/page_alloc.c:870 mm/page_alloc.c:1135)
[ 3778.056548] ? __free_page_frag (mm/page_alloc.c:1084)
[ 3778.057210] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.057847] free_hot_cold_page (mm/page_alloc.c:2442 (discriminator 1))
[ 3778.058410] ? drain_all_pages (mm/page_alloc.c:2403)
[ 3778.059016] ? uncharge_list (mm/memcontrol.c:5536)
[ 3778.059627] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.060270] free_hot_cold_page_list (mm/page_alloc.c:2456 (discriminator 3))
[ 3778.060867] shrink_page_list (include/linux/compiler.h:222 include/linux/list.h:189 include/linux/list.h:296 mm/vmscan.c:1238)
[ 3778.061425] ? putback_lru_page (mm/vmscan.c:889)
[ 3778.061988] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.062631] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.063254] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.063873] ? __mod_zone_page_state (mm/vmstat.c:249)
[ 3778.064472] shrink_inactive_list (include/linux/spinlock.h:332 mm/vmscan.c:1629)
[ 3778.065054] ? putback_inactive_pages (mm/vmscan.c:1573)
[ 3778.065703] ? zone_reclaimable_pages (mm/vmscan.c:208)
[ 3778.066355] ? _find_next_bit (lib/find_bit.c:54)
[ 3778.066914] ? zone_reclaimable (include/linux/vmstat.h:166 mm/vmscan.c:212)
[ 3778.067478] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.068118] ? get_scan_count (mm/vmscan.c:1954)
[ 3778.068675] ? blk_start_plug (block/blk-core.c:3170 (discriminator 1))
[ 3778.069211] ? blk_lld_busy (block/blk-core.c:3170)
[ 3778.069807] shrink_zone_memcg (mm/vmscan.c:1932 mm/vmscan.c:2224)
[ 3778.070336] ? shrink_active_list (mm/vmscan.c:2181)
[ 3778.070891] ? css_next_descendant_pre (kernel/cgroup.c:4028)
[ 3778.071508] ? mem_cgroup_iter (mm/memcontrol.c:889)
[ 3778.072052] ? preempt_count_add (include/linux/ftrace.h:724 kernel/sched/core.c:3074 kernel/sched/core.c:3099)
[ 3778.072607] shrink_zone (mm/vmscan.c:2407)
[ 3778.073103] ? mem_cgroup_split_huge_fixup (mm/memcontrol.c:2607)
[ 3778.073756] ? shrink_zone_memcg (mm/vmscan.c:2374)
[ 3778.074310] ? zone_watermark_ok_safe (mm/page_alloc.c:2839)
[ 3778.074912] kswapd (./arch/x86/include/asm/bitops.h:113 mm/vmscan.c:3090 mm/vmscan.c:3239 mm/vmscan.c:3427)
[ 3778.075381] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.075951] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.076681] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3778.077200] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.077745] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.078319] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.078868] kthread (kernel/kthread.c:209)
[ 3778.079339] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.079972] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.080530] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.081022] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.081614] ---[ end trace 8cbbecee22435cc7 ]---

[ 3778.082029] ------------[ cut here ]------------

[ 3778.082480] WARNING: CPU: 16 PID: 3730 at lib/list_debug.c:29 __list_add+0xc6/0x240

[ 3778.083285] list_add corruption. next->prev should be prev (ffff8801b7fd80d0), but was ffffea00050f07a0. (next=ffffea00050f0820).

[ 3778.084308] Modules linked in:

[ 3778.084611] CPU: 16 PID: 3730 Comm: kswapd0 Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.085601]  1ffff10066e36de3 00000000be0b1ffd ffff8803371b6fa0 ffffffffa0035b2b

[ 3778.086387]  ffffffff00000010 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.087130]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ab20 ffff8803371b7020

[ 3778.087909] Call Trace:

[ 3778.088153] dump_stack (lib/dump_stack.c:53)
[ 3778.088644] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.089278] ? is_module_text_address (kernel/module.c:4185)
[ 3778.090006] ? __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.090511] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3778.091079] ? __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.091618] __warn (kernel/panic.c:518)
[ 3778.092094] ? kvm_sched_clock_read (arch/x86/kernel/kvmclock.c:104)
[ 3778.092680] warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.093219] ? __warn (kernel/panic.c:526)
[ 3778.093718] ? qstat_write (kernel/locking/qspinlock.c:411)
[ 3778.094303] ? __radix_tree_lookup (lib/radix-tree.c:673)
[ 3778.094912] __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.095396] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.096015] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.096627] free_pcppages_bulk (mm/page_alloc.c:878 mm/page_alloc.c:1135)
[ 3778.097182] ? __free_page_frag (mm/page_alloc.c:1084)
[ 3778.097764] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.098404] free_hot_cold_page (mm/page_alloc.c:2442 (discriminator 1))
[ 3778.098964] ? drain_all_pages (mm/page_alloc.c:2403)
[ 3778.099545] ? uncharge_list (mm/memcontrol.c:5536)
[ 3778.100084] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.100728] free_hot_cold_page_list (mm/page_alloc.c:2456 (discriminator 3))
[ 3778.101349] shrink_page_list (include/linux/compiler.h:222 include/linux/list.h:189 include/linux/list.h:296 mm/vmscan.c:1238)
[ 3778.101976] ? putback_lru_page (mm/vmscan.c:889)
[ 3778.102560] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.103184] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.103817] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.104424] ? __mod_zone_page_state (mm/vmstat.c:249)
[ 3778.105013] shrink_inactive_list (include/linux/spinlock.h:332 mm/vmscan.c:1629)
[ 3778.105585] ? putback_inactive_pages (mm/vmscan.c:1573)
[ 3778.106190] ? zone_reclaimable_pages (mm/vmscan.c:208)
[ 3778.106835] ? _find_next_bit (lib/find_bit.c:54)
[ 3778.107370] ? zone_reclaimable (include/linux/vmstat.h:166 mm/vmscan.c:212)
[ 3778.107976] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.108605] ? get_scan_count (mm/vmscan.c:1954)
[ 3778.109158] ? blk_start_plug (block/blk-core.c:3170 (discriminator 1))
[ 3778.109715] ? blk_lld_busy (block/blk-core.c:3170)
[ 3778.110221] shrink_zone_memcg (mm/vmscan.c:1932 mm/vmscan.c:2224)
[ 3778.110813] ? shrink_active_list (mm/vmscan.c:2181)
[ 3778.111384] ? css_next_descendant_pre (kernel/cgroup.c:4028)
[ 3778.111993] ? mem_cgroup_iter (mm/memcontrol.c:889)
[ 3778.112576] ? preempt_count_add (include/linux/ftrace.h:724 kernel/sched/core.c:3074 kernel/sched/core.c:3099)
[ 3778.113139] shrink_zone (mm/vmscan.c:2407)
[ 3778.113704] ? mem_cgroup_split_huge_fixup (mm/memcontrol.c:2607)
[ 3778.114336] ? shrink_zone_memcg (mm/vmscan.c:2374)
[ 3778.114904] ? zone_watermark_ok_safe (mm/page_alloc.c:2839)
[ 3778.115509] kswapd (./arch/x86/include/asm/bitops.h:113 mm/vmscan.c:3090 mm/vmscan.c:3239 mm/vmscan.c:3427)
[ 3778.115996] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.116572] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.117234] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3778.117761] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.118312] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.118892] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.119450] kthread (kernel/kthread.c:209)
[ 3778.119937] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.120624] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.121186] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.121689] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.122249] ---[ end trace 8cbbecee22435cc8 ]---

[ 3778.122683] ------------[ cut here ]------------

[ 3778.123128] WARNING: CPU: 16 PID: 3730 at lib/list_debug.c:29 __list_add+0xc6/0x240

[ 3778.124008] list_add corruption. next->prev should be prev (ffff8801b7fd8138), but was ffffea0005116820. (next=ffffea00050f0020).

[ 3778.125058] Modules linked in:

[ 3778.125367] CPU: 16 PID: 3730 Comm: kswapd0 Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.126483]  1ffff10066e36de3 00000000be0b1ffd ffff8803371b6fa0 ffffffffa0035b2b

[ 3778.127213]  ffffffff00000010 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.127952]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ab20 ffff8803371b7020

[ 3778.128693] Call Trace:

[ 3778.128941] dump_stack (lib/dump_stack.c:53)
[ 3778.129443] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.130070] ? is_module_text_address (kernel/module.c:4185)
[ 3778.130670] ? __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.131443] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3778.132001] ? __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.132506] __warn (kernel/panic.c:518)
[ 3778.133010] ? kvm_sched_clock_read (arch/x86/kernel/kvmclock.c:104)
[ 3778.134072] warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.134684] ? __warn (kernel/panic.c:526)
[ 3778.135174] ? qstat_write (kernel/locking/qspinlock.c:411)
[ 3778.135698] ? __radix_tree_lookup (lib/radix-tree.c:673)
[ 3778.136319] __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.136823] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.137421] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.138058] free_pcppages_bulk (mm/page_alloc.c:878 mm/page_alloc.c:1135)
[ 3778.138636] ? __free_page_frag (mm/page_alloc.c:1084)
[ 3778.139207] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.139817] free_hot_cold_page (mm/page_alloc.c:2442 (discriminator 1))
[ 3778.140379] ? drain_all_pages (mm/page_alloc.c:2403)
[ 3778.140929] ? uncharge_list (mm/memcontrol.c:5536)
[ 3778.141516] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.142116] free_hot_cold_page_list (mm/page_alloc.c:2456 (discriminator 3))
[ 3778.142693] shrink_page_list (include/linux/compiler.h:222 include/linux/list.h:189 include/linux/list.h:296 mm/vmscan.c:1238)
[ 3778.143295] ? putback_lru_page (mm/vmscan.c:889)
[ 3778.143850] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.144570] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.145153] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.145732] ? __mod_zone_page_state (mm/vmstat.c:249)
[ 3778.146301] shrink_inactive_list (include/linux/spinlock.h:332 mm/vmscan.c:1629)
[ 3778.146860] ? putback_inactive_pages (mm/vmscan.c:1573)
[ 3778.147428] ? zone_reclaimable_pages (mm/vmscan.c:208)
[ 3778.148055] ? _find_next_bit (lib/find_bit.c:54)
[ 3778.148613] ? zone_reclaimable (include/linux/vmstat.h:166 mm/vmscan.c:212)
[ 3778.149209] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.149817] ? get_scan_count (mm/vmscan.c:1954)
[ 3778.150349] ? blk_start_plug (block/blk-core.c:3170 (discriminator 1))
[ 3778.150895] ? blk_lld_busy (block/blk-core.c:3170)
[ 3778.151427] shrink_zone_memcg (mm/vmscan.c:1932 mm/vmscan.c:2224)
[ 3778.152028] ? shrink_active_list (mm/vmscan.c:2181)
[ 3778.152638] ? css_next_descendant_pre (kernel/cgroup.c:4028)
[ 3778.153269] ? mem_cgroup_iter (mm/memcontrol.c:889)
[ 3778.153897] ? preempt_count_add (include/linux/ftrace.h:724 kernel/sched/core.c:3074 kernel/sched/core.c:3099)
[ 3778.154489] shrink_zone (mm/vmscan.c:2407)
[ 3778.155015] ? mem_cgroup_split_huge_fixup (mm/memcontrol.c:2607)
[ 3778.155683] ? shrink_zone_memcg (mm/vmscan.c:2374)
[ 3778.156360] ? zone_watermark_ok_safe (mm/page_alloc.c:2839)
[ 3778.157029] kswapd (./arch/x86/include/asm/bitops.h:113 mm/vmscan.c:3090 mm/vmscan.c:3239 mm/vmscan.c:3427)
[ 3778.157527] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.158217] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.158972] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3778.159508] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.160112] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.160732] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.161287] kthread (kernel/kthread.c:209)
[ 3778.161811] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.162513] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.163082] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.163590] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.164229] ---[ end trace 8cbbecee22435cc9 ]---

[ 3778.170922] ------------[ cut here ]------------

[ 3778.171447] WARNING: CPU: 16 PID: 3730 at lib/list_debug.c:29 __list_add+0xc6/0x240

[ 3778.171740] ------------[ cut here ]------------

[ 3778.171760] WARNING: CPU: 5 PID: 3270 at lib/list_debug.c:62 __list_del_entry+0x14e/0x280

[ 3778.171767] list_del corruption. next->prev should be ffffea0005116820, but was ffffea0005292220

[ 3778.171772] Modules linked in:

[ 3778.171786] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.171799]  1ffff100f9315da5 000000000bb7299a ffff8807c98aedb0 ffffffffa0035b2b

[ 3778.171808]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.171818]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ade0 ffff8807c98aee30

[ 3778.171820] Call Trace:

[ 3778.171837] dump_stack (lib/dump_stack.c:53)
[ 3778.171850] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.171863] ? is_module_text_address (kernel/module.c:4185)
[ 3778.171874] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3778.171893] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3778.171905] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3778.171917] __warn (kernel/panic.c:518)
[ 3778.171928] ? kick_process (kernel/sched/core.c:2692)
[ 3778.171939] warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.171948] ? __warn (kernel/panic.c:526)
[ 3778.171964] ? kernel_poison_pages (mm/page_poison.c:169)
[ 3778.171975] __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3778.171985] ? post_alloc_hook (mm/page_alloc.c:1740 (discriminator 3) include/linux/page_owner.h:27 (discriminator 3) mm/page_alloc.c:1741 (discriminator 3))
[ 3778.171995] ? __list_add (lib/list_debug.c:45)
[ 3778.172011] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.172022] list_del (lib/list_debug.c:78)
[ 3778.172032] map_pages (mm/compaction.c:75)
[ 3778.172041] ? compaction_free (mm/compaction.c:67)
[ 3778.172051] compaction_alloc (mm/compaction.c:1136 mm/compaction.c:1156)
[ 3778.172061] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.172073] ? __page_cache_release (mm/swap.c:73)
[ 3778.172087] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3778.172097] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3778.172107] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.172119] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3778.172128] compact_zone (mm/compaction.c:1555)
[ 3778.172139] ? compaction_restarting (mm/compaction.c:1476)
[ 3778.172149] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.172159] compact_zone_order (mm/compaction.c:1653)
[ 3778.172170] ? kick_process (kernel/sched/core.c:2692)
[ 3778.172179] ? compact_zone (mm/compaction.c:1637)
[ 3778.172191] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.172202] try_to_compact_pages (mm/compaction.c:1717)
[ 3778.172213] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3778.172224] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3778.172239] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3778.172250] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3778.172265] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3778.172276] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3778.172287] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3778.172298] ? release_pages (mm/swap.c:731)
[ 3778.172308] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3778.172319] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3778.172331] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.172342] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3778.172352] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3778.172362] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3778.172372] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3778.172381] ? up_write (kernel/locking/rwsem.c:112)
[ 3778.172393] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3778.172403] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3778.172413] collapse_huge_page (mm/khugepaged.c:948)
[ 3778.172423] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3778.172434] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.172445] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.172454] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3778.172464] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.172475] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.172486] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.172496] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.172507] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3778.172516] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.172525] kthread (kernel/kthread.c:209)
[ 3778.172538] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.172548] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.172559] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.172568] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.172605] ---[ end trace 8cbbecee22435cca ]---

[ 3778.172614] ------------[ cut here ]------------

[ 3778.172628] WARNING: CPU: 5 PID: 3270 at lib/list_debug.c:62 __list_del_entry+0x14e/0x280

[ 3778.172634] list_del corruption. next->prev should be ffffea00050f07a0, but was ffffea0005293120

[ 3778.172637] Modules linked in:

[ 3778.172648] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.172658]  1ffff100f9315da5 000000000bb7299a ffff8807c98aedb0 ffffffffa0035b2b

[ 3778.172668]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.172677]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ade0 ffff8807c98aee30

[ 3778.172679] Call Trace:

[ 3778.172698] dump_stack (lib/dump_stack.c:53)
[ 3778.172711] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.172722] ? is_module_text_address (kernel/module.c:4185)
[ 3778.172733] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3778.172744] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3778.172755] ? __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3778.172765] __warn (kernel/panic.c:518)
[ 3778.172776] ? kick_process (kernel/sched/core.c:2692)
[ 3778.172786] warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.172796] ? __warn (kernel/panic.c:526)
[ 3778.172808] ? kernel_poison_pages (mm/page_poison.c:169)
[ 3778.172819] __list_del_entry (lib/list_debug.c:60 (discriminator 1))
[ 3778.172829] ? post_alloc_hook (mm/page_alloc.c:1740 (discriminator 3) include/linux/page_owner.h:27 (discriminator 3) mm/page_alloc.c:1741 (discriminator 3))
[ 3778.172839] ? __list_add (lib/list_debug.c:45)
[ 3778.172850] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.172860] list_del (lib/list_debug.c:78)
[ 3778.172869] map_pages (mm/compaction.c:75)
[ 3778.172878] ? compaction_free (mm/compaction.c:67)
[ 3778.172887] compaction_alloc (mm/compaction.c:1136 mm/compaction.c:1156)
[ 3778.172898] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.172909] ? __page_cache_release (mm/swap.c:73)
[ 3778.172920] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3778.172930] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3778.172940] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.172952] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3778.172961] compact_zone (mm/compaction.c:1555)
[ 3778.172972] ? compaction_restarting (mm/compaction.c:1476)
[ 3778.172982] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.172992] compact_zone_order (mm/compaction.c:1653)
[ 3778.173007] ? kick_process (kernel/sched/core.c:2692)
[ 3778.173020] ? compact_zone (mm/compaction.c:1637)
[ 3778.173033] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.173043] try_to_compact_pages (mm/compaction.c:1717)
[ 3778.173054] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3778.173066] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3778.173076] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3778.173087] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3778.173098] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3778.173109] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3778.173120] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3778.173131] ? release_pages (mm/swap.c:731)
[ 3778.173141] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3778.173152] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3778.173163] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.173216] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3778.173226] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3778.173237] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3778.173247] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3778.173256] ? up_write (kernel/locking/rwsem.c:112)
[ 3778.173267] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3778.173277] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3778.173287] collapse_huge_page (mm/khugepaged.c:948)
[ 3778.173298] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3778.173309] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.173320] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.173330] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3778.173339] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.173350] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.173362] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.173372] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.173382] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3778.173391] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.173400] kthread (kernel/kthread.c:209)
[ 3778.173410] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.173419] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.173429] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.173443] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.173472] ---[ end trace 8cbbecee22435ccb ]---

[ 3778.173506] ================================================================================

[ 3778.173536] UBSAN: Undefined behaviour in mm/compaction.c:76:16

[ 3778.173551] shift exponent 88341344 is too large for 32-bit type 'int'

[ 3778.173562] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.173572]  1ffff100f9315daa 000000000bb7299a ffff8807c98aedd8 ffffffffa0035b2b

[ 3778.173582]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.173591]  ffffffffa00359bc ffff8807c98aee00 ffff8807c98aeda0 000000000bb7299a

[ 3778.173593] Call Trace:

[ 3778.173606] dump_stack (lib/dump_stack.c:53)
[ 3778.173618] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.173650] ubsan_epilogue (lib/ubsan.c:165)
[ 3778.173662] __ubsan_handle_shift_out_of_bounds (lib/ubsan.c:421)
[ 3778.173672] ? warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.173684] ? __ubsan_handle_load_invalid_value (lib/ubsan.c:388)
[ 3778.173696] ? kernel_poison_pages (mm/page_poison.c:169)
[ 3778.173707] ? kasan_unpoison_shadow (mm/kasan/kasan.c:59)
[ 3778.173718] ? kasan_alloc_pages (mm/kasan/kasan.c:344)
[ 3778.173727] ? post_alloc_hook (mm/page_alloc.c:1740 (discriminator 3) include/linux/page_owner.h:27 (discriminator 3) mm/page_alloc.c:1741 (discriminator 3))
[ 3778.173738] ? __list_add (lib/list_debug.c:45)
[ 3778.173749] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.173758] map_pages (mm/compaction.c:76 (discriminator 1))
[ 3778.173766] ? map_pages (mm/compaction.c:76 (discriminator 1))
[ 3778.173775] ? compaction_free (mm/compaction.c:67)
[ 3778.173785] compaction_alloc (mm/compaction.c:1136 mm/compaction.c:1156)
[ 3778.173795] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.173805] ? __page_cache_release (mm/swap.c:73)
[ 3778.173817] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3778.173827] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3778.173836] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.173848] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3778.173857] compact_zone (mm/compaction.c:1555)
[ 3778.173867] ? compaction_restarting (mm/compaction.c:1476)
[ 3778.173877] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.173887] compact_zone_order (mm/compaction.c:1653)
[ 3778.173901] ? kick_process (kernel/sched/core.c:2692)
[ 3778.173911] ? compact_zone (mm/compaction.c:1637)
[ 3778.173923] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.173933] try_to_compact_pages (mm/compaction.c:1717)
[ 3778.173944] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3778.173955] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3778.173966] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3778.173977] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3778.173987] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3778.173998] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3778.174012] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3778.174023] ? release_pages (mm/swap.c:731)
[ 3778.174033] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3778.174044] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3778.174055] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.174066] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3778.174075] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3778.174086] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3778.174095] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3778.174104] ? up_write (kernel/locking/rwsem.c:112)
[ 3778.174115] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3778.174125] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3778.174135] collapse_huge_page (mm/khugepaged.c:948)
[ 3778.174145] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3778.174157] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.174167] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.174177] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3778.174186] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.174197] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.174208] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.174218] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.174228] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3778.174237] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.174246] kthread (kernel/kthread.c:209)
[ 3778.174255] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.174264] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.174274] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.174284] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.174287] ================================================================================

[ 3778.174354] ================================================================================

[ 3778.174362] UBSAN: Undefined behaviour in mm/page_alloc.c:1738:27

[ 3778.174369] shift exponent 88341344 is too large for 32-bit type 'int'

[ 3778.174380] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.174391]  1ffff100f9315d96 000000000bb7299a ffff8807c98aed38 ffffffffa0035b2b

[ 3778.174400]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.174410]  ffffffffa00359bc ffff8807c98aed60 ffff8807c98aed00 000000000bb7299a

[ 3778.174412] Call Trace:

[ 3778.174426] dump_stack (lib/dump_stack.c:53)
[ 3778.174438] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.174448] ubsan_epilogue (lib/ubsan.c:165)
[ 3778.174459] __ubsan_handle_shift_out_of_bounds (lib/ubsan.c:421)
[ 3778.174471] ? __ubsan_handle_load_invalid_value (lib/ubsan.c:388)
[ 3778.174481] ? _raw_spin_unlock_irqrestore (kernel/locking/spinlock.c:192)
[ 3778.174493] ? __ubsan_handle_shift_out_of_bounds (lib/ubsan.c:388 (discriminator 1))
[ 3778.174503] ? warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.174520] ? __ubsan_handle_load_invalid_value (lib/ubsan.c:388)
[ 3778.174534] ? kernel_poison_pages (mm/page_poison.c:169)
[ 3778.174544] post_alloc_hook (mm/page_alloc.c:1739 (discriminator 1))
[ 3778.174553] ? post_alloc_hook (mm/page_alloc.c:1739 (discriminator 1))
[ 3778.174563] ? clear_zone_contiguous (mm/page_alloc.c:1733)
[ 3778.174572] map_pages (mm/compaction.c:78 (discriminator 1))
[ 3778.174582] ? compaction_free (mm/compaction.c:67)
[ 3778.174592] compaction_alloc (mm/compaction.c:1136 mm/compaction.c:1156)
[ 3778.174602] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.174613] ? __page_cache_release (mm/swap.c:73)
[ 3778.174629] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3778.174640] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3778.174650] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.174661] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3778.174671] compact_zone (mm/compaction.c:1555)
[ 3778.174681] ? compaction_restarting (mm/compaction.c:1476)
[ 3778.174691] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.174701] compact_zone_order (mm/compaction.c:1653)
[ 3778.174712] ? kick_process (kernel/sched/core.c:2692)
[ 3778.174721] ? compact_zone (mm/compaction.c:1637)
[ 3778.174733] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.174743] try_to_compact_pages (mm/compaction.c:1717)
[ 3778.174754] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3778.174765] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3778.174775] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3778.174786] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3778.174796] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3778.174807] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3778.174818] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3778.174829] ? release_pages (mm/swap.c:731)
[ 3778.174839] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3778.174850] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3778.174861] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.174871] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3778.174881] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3778.174891] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3778.174901] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3778.174909] ? up_write (kernel/locking/rwsem.c:112)
[ 3778.174920] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3778.174930] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3778.174940] collapse_huge_page (mm/khugepaged.c:948)
[ 3778.174950] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3778.174962] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.174972] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.174982] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3778.174991] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.175006] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.175019] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.175029] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.175040] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3778.175049] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.175058] kthread (kernel/kthread.c:209)
[ 3778.175067] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.175077] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.175087] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.175096] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.175100] ================================================================================

[ 3778.175130] ================================================================================

[ 3778.175142] UBSAN: Undefined behaviour in mm/page_alloc.c:1739:30

[ 3778.175149] shift exponent 88341344 is too large for 32-bit type 'int'

[ 3778.175160] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.175171]  1ffff100f9315d96 000000000bb7299a ffff8807c98aed38 ffffffffa0035b2b

[ 3778.175180]  ffffffff00000005 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.175190]  ffffffffa00359bc ffff8807c98aed60 ffff8807c98aed00 000000000bb7299a

[ 3778.175192] Call Trace:

[ 3778.175205] dump_stack (lib/dump_stack.c:53)
[ 3778.175217] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.175227] ubsan_epilogue (lib/ubsan.c:165)
[ 3778.175239] __ubsan_handle_shift_out_of_bounds (lib/ubsan.c:421)
[ 3778.175250] ? __ubsan_handle_load_invalid_value (lib/ubsan.c:388)
[ 3778.175261] ? _raw_spin_unlock_irqrestore (kernel/locking/spinlock.c:192)
[ 3778.175273] ? __ubsan_handle_shift_out_of_bounds (lib/ubsan.c:388 (discriminator 1))
[ 3778.175283] ? warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.175295] ? __ubsan_handle_load_invalid_value (lib/ubsan.c:388)
[ 3778.175307] ? kernel_poison_pages (mm/page_poison.c:169)
[ 3778.175317] post_alloc_hook (mm/page_alloc.c:1739 (discriminator 3))
[ 3778.175326] ? post_alloc_hook (mm/page_alloc.c:1739 (discriminator 3))
[ 3778.175336] ? clear_zone_contiguous (mm/page_alloc.c:1733)
[ 3778.175345] map_pages (mm/compaction.c:78 (discriminator 1))
[ 3778.175354] ? compaction_free (mm/compaction.c:67)
[ 3778.175364] compaction_alloc (mm/compaction.c:1136 mm/compaction.c:1156)
[ 3778.175374] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.175385] ? __page_cache_release (mm/swap.c:73)
[ 3778.175397] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3778.175407] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3778.175417] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.175428] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3778.175438] compact_zone (mm/compaction.c:1555)
[ 3778.175448] ? compaction_restarting (mm/compaction.c:1476)
[ 3778.175458] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.175467] compact_zone_order (mm/compaction.c:1653)
[ 3778.175478] ? kick_process (kernel/sched/core.c:2692)
[ 3778.175487] ? compact_zone (mm/compaction.c:1637)
[ 3778.175499] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.175509] try_to_compact_pages (mm/compaction.c:1717)
[ 3778.175520] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3778.175531] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3778.175542] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3778.175552] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3778.175562] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3778.175573] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3778.175584] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3778.175595] ? release_pages (mm/swap.c:731)
[ 3778.175605] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3778.175616] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3778.175627] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.175637] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3778.175647] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3778.175657] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3778.175666] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3778.175675] ? up_write (kernel/locking/rwsem.c:112)
[ 3778.175686] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3778.175696] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3778.175705] collapse_huge_page (mm/khugepaged.c:948)
[ 3778.175719] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3778.175731] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.175742] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.175752] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3778.175761] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.175772] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.175784] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.175794] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.175809] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3778.175819] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.175827] kthread (kernel/kthread.c:209)
[ 3778.175837] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.175847] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.175857] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.175866] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.175870] ================================================================================

[ 3778.175918] kasan: CONFIG_KASAN_INLINE enabled

[ 3778.175937] kasan: GPF could be caused by NULL-ptr deref or user memory access

[ 3778.175938] general protection fault: 0000 [#1] PREEMPT SMP KASAN

[ 3778.175942] Modules linked in:

[ 3778.175952] CPU: 5 PID: 3270 Comm: khugepaged Tainted: G        W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.175959] task: ffff8807c9892000 ti: ffff8807c98a8000 task.ti: ffff8807c98a8000

[ 3778.175980] RIP: memset_orig (arch/x86/lib/memset_64.S:88)
[ 3778.175985] RSP: 0000:ffff8807c98aeeb8  EFLAGS: 00010216

[ 3778.175991] RAX: 0000000000000000 RBX: fffcdf0dbfebfe00 RCX: 00000007ffffffff

[ 3778.175997] RDX: 0000020000000000 RSI: 0000000000000000 RDI: fffcdd0dbfebfe00

[ 3778.176006] RBP: ffff8807c98aeed0 R08: 0000000000000001 R09: 0000000000000000

[ 3778.176012] R10: fffcdd0dbfebfe00 R11: 00000000e27286ff R12: 0000100000000000

[ 3778.176020] R13: 0000000000000008 R14: 000000000543fb60 R15: 0000000000000001

[ 3778.176028] FS:  0000000000000000(0000) GS:ffff880951c00000(0000) knlGS:0000000000000000

[ 3778.176034] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033

[ 3778.176039] CR2: 00007f2eb1c17576 CR3: 000000002ae23000 CR4: 00000000000006a0

[ 3778.176050] Stack:

[ 3778.176061]  ffffffff9e7a02a5 ffff8801b7fd7fe0 1ffff100f9315ddf ffff8807c98aeee0

[ 3778.176071]  ffffffff9e7a05e8 ffff8807c98aef80 ffffffff9e67716a 000000000543fb60

[ 3778.176080]  0000000041b58ab3 ffffffffaaaf18e0 ffffffff9e676f60 ffffea0005294f20

[ 3778.176082] Call Trace:

[ 3778.176094] ? kasan_unpoison_shadow (mm/kasan/kasan.c:59)
[ 3778.176105] kasan_alloc_pages (mm/kasan/kasan.c:344)
[ 3778.176115] post_alloc_hook (mm/page_alloc.c:1740 (discriminator 3) include/linux/page_owner.h:27 (discriminator 3) mm/page_alloc.c:1741 (discriminator 3))
[ 3778.176125] ? clear_zone_contiguous (mm/page_alloc.c:1733)
[ 3778.176135] map_pages (mm/compaction.c:78 (discriminator 1))
[ 3778.176144] ? compaction_free (mm/compaction.c:67)
[ 3778.176154] compaction_alloc (mm/compaction.c:1136 mm/compaction.c:1156)
[ 3778.176165] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.176176] ? __page_cache_release (mm/swap.c:73)
[ 3778.176188] migrate_pages (mm/migrate.c:1079 mm/migrate.c:1325)
[ 3778.176199] ? __reset_isolation_suitable (mm/compaction.c:1175)
[ 3778.176209] ? isolate_freepages_block (mm/compaction.c:1146)
[ 3778.176221] ? buffer_migrate_page (mm/migrate.c:1301)
[ 3778.176230] compact_zone (mm/compaction.c:1555)
[ 3778.176241] ? compaction_restarting (mm/compaction.c:1476)
[ 3778.176251] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.176261] compact_zone_order (mm/compaction.c:1653)
[ 3778.176272] ? kick_process (kernel/sched/core.c:2692)
[ 3778.176281] ? compact_zone (mm/compaction.c:1637)
[ 3778.176294] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.176308] try_to_compact_pages (mm/compaction.c:1717)
[ 3778.176320] ? compaction_zonelist_suitable (mm/compaction.c:1679)
[ 3778.176331] __alloc_pages_direct_compact (mm/page_alloc.c:3180)
[ 3778.176342] ? get_page_from_freelist (mm/page_alloc.c:3172)
[ 3778.176353] __alloc_pages_slowpath (mm/page_alloc.c:3741)
[ 3778.176363] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:84 arch/x86/kernel/kvmclock.c:92)
[ 3778.176375] ? __alloc_pages_direct_compact (mm/page_alloc.c:3546)
[ 3778.176386] ? get_page_from_freelist (mm/page_alloc.c:2950)
[ 3778.176397] ? release_pages (mm/swap.c:731)
[ 3778.176408] ? __isolate_free_page (mm/page_alloc.c:2883)
[ 3778.176419] ? ___might_sleep (kernel/sched/core.c:7540 (discriminator 1))
[ 3778.176431] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.176441] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[ 3778.176451] ? rwsem_wake (kernel/locking/rwsem-xadd.c:580)
[ 3778.176462] ? __alloc_pages_slowpath (mm/page_alloc.c:3757)
[ 3778.176471] ? call_rwsem_wake (arch/x86/lib/rwsem.S:129)
[ 3778.176480] ? up_write (kernel/locking/rwsem.c:112)
[ 3778.176496] ? pmdp_huge_clear_flush (mm/pgtable-generic.c:131)
[ 3778.176506] khugepaged_alloc_page (mm/khugepaged.c:752)
[ 3778.176516] collapse_huge_page (mm/khugepaged.c:948)
[ 3778.176527] ? khugepaged_scan_shmem (mm/khugepaged.c:922)
[ 3778.176538] ? __might_sleep (kernel/sched/core.c:7532 (discriminator 14))
[ 3778.176549] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.176559] khugepaged (mm/khugepaged.c:1724 mm/khugepaged.c:1799 mm/khugepaged.c:1848)
[ 3778.176569] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.176580] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.176591] ? io_schedule_timeout (kernel/sched/core.c:3266)
[ 3778.176601] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.176612] ? __wake_up_common (kernel/sched/wait.c:73)
[ 3778.176621] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.176630] kthread (kernel/kthread.c:209)
[ 3778.176640] ? collapse_huge_page (mm/khugepaged.c:1840)
[ 3778.176649] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.176660] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.176669] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.176769] Code: b8 01 01 01 01 01 01 01 01 48 0f af c1 41 89 f9 41 83 e1 07 75 70 48 89 d1 48 c1 e9 06 74 39 66 0f 1f 84 00 00 00 00 00 48 ff c9 <48> 89 07 48 89 47 08 48 89 47 10 48 89 47 18 48 89 47 20 48 89

All code
========
   0:	b8 01 01 01 01       	mov    $0x1010101,%eax
   5:	01 01                	add    %eax,(%rcx)
   7:	01 01                	add    %eax,(%rcx)
   9:	48 0f af c1          	imul   %rcx,%rax
   d:	41 89 f9             	mov    %edi,%r9d
  10:	41 83 e1 07          	and    $0x7,%r9d
  14:	75 70                	jne    0x86
  16:	48 89 d1             	mov    %rdx,%rcx
  19:	48 c1 e9 06          	shr    $0x6,%rcx
  1d:	74 39                	je     0x58
  1f:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  26:	00 00
  28:	48 ff c9             	dec    %rcx
  2b:*	48 89 07             	mov    %rax,(%rdi)		<-- trapping instruction
  2e:	48 89 47 08          	mov    %rax,0x8(%rdi)
  32:	48 89 47 10          	mov    %rax,0x10(%rdi)
  36:	48 89 47 18          	mov    %rax,0x18(%rdi)
  3a:	48 89 47 20          	mov    %rax,0x20(%rdi)
  3e:	48 89 00             	mov    %rax,(%rax)

Code starting with the faulting instruction
===========================================
   0:	48 89 07             	mov    %rax,(%rdi)
   3:	48 89 47 08          	mov    %rax,0x8(%rdi)
   7:	48 89 47 10          	mov    %rax,0x10(%rdi)
   b:	48 89 47 18          	mov    %rax,0x18(%rdi)
   f:	48 89 47 20          	mov    %rax,0x20(%rdi)
  13:	48 89 00             	mov    %rax,(%rax)
[ 3778.176779] RIP memset_orig (arch/x86/lib/memset_64.S:88)
[ 3778.176782]  RSP <ffff8807c98aeeb8>

[ 3778.177119] ---[ end trace 8cbbecee22435ccc ]---

[ 3778.177125] Kernel panic - not syncing: Fatal exception

[ 3778.443313] list_add corruption. next->prev should be prev (ffff8801b7fd8208), but was ffffea0004e45ba0. (next=ffffea0004e46020).

[ 3778.444993] Modules linked in:

[ 3778.445301] CPU: 16 PID: 3730 Comm: kswapd0 Tainted: G      D W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.446284]  1ffff10066e36de3 00000000be0b1ffd ffff8803371b6fa0 ffffffffa0035b2b

[ 3778.447026]  ffffffff00000010 fffffbfff5630bf4 0000000041b58ab3 ffffffffaaaf18e0

[ 3778.447753]  ffffffffa00359bc ffffffff9e54d4a0 ffffffffa8b2ab20 ffff8803371b7020

[ 3778.448495] Call Trace:

[ 3778.448751] dump_stack (lib/dump_stack.c:53)
[ 3778.449235] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[ 3778.449828] ? is_module_text_address (kernel/module.c:4185)
[ 3778.450417] ? __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.450911] ? vprintk_default (kernel/printk/printk.c:1886)
[ 3778.451459] ? __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.451968] __warn (kernel/panic.c:518)
[ 3778.452424] warn_slowpath_fmt (kernel/panic.c:526)
[ 3778.452954] ? __warn (kernel/panic.c:526)
[ 3778.453443] ? __radix_tree_lookup (lib/radix-tree.c:673)
[ 3778.454018] __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.454498] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.455084] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.455677] free_pcppages_bulk (mm/page_alloc.c:878 mm/page_alloc.c:1135)
[ 3778.456236] ? __free_page_frag (mm/page_alloc.c:1084)
[ 3778.456775] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.457395] free_hot_cold_page (mm/page_alloc.c:2442 (discriminator 1))
[ 3778.457940] ? drain_all_pages (mm/page_alloc.c:2403)
[ 3778.458480] ? uncharge_list (mm/memcontrol.c:5536)
[ 3778.459007] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.459587] free_hot_cold_page_list (mm/page_alloc.c:2456 (discriminator 3))
[ 3778.460152] shrink_page_list (include/linux/compiler.h:222 include/linux/list.h:189 include/linux/list.h:296 mm/vmscan.c:1238)
[ 3778.460695] ? putback_lru_page (mm/vmscan.c:889)
[ 3778.461235] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.461874] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.462474] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.463069] ? __mod_zone_page_state (mm/vmstat.c:249)
[ 3778.463648] shrink_inactive_list (include/linux/spinlock.h:332 mm/vmscan.c:1629)
[ 3778.464217] ? putback_inactive_pages (mm/vmscan.c:1573)
[ 3778.464829] ? zone_reclaimable_pages (mm/vmscan.c:208)
[ 3778.465434] ? _find_next_bit (lib/find_bit.c:54)
[ 3778.466010] ? zone_reclaimable (include/linux/vmstat.h:166 mm/vmscan.c:212)
[ 3778.466570] ? get_scan_count (mm/vmscan.c:1954)
[ 3778.467127] ? blk_start_plug (block/blk-core.c:3170 (discriminator 1))
[ 3778.467658] ? blk_lld_busy (block/blk-core.c:3170)
[ 3778.468165] shrink_zone_memcg (mm/vmscan.c:1932 mm/vmscan.c:2224)
[ 3778.468700] ? shrink_active_list (mm/vmscan.c:2181)
[ 3778.469267] ? css_next_descendant_pre (kernel/cgroup.c:4028)
[ 3778.469959] ? mem_cgroup_iter (mm/memcontrol.c:889)
[ 3778.470506] ? preempt_count_add (include/linux/ftrace.h:724 kernel/sched/core.c:3074 kernel/sched/core.c:3099)
[ 3778.471043] shrink_zone (mm/vmscan.c:2407)
[ 3778.471536] ? mem_cgroup_split_huge_fixup (mm/memcontrol.c:2607)
[ 3778.472192] ? shrink_zone_memcg (mm/vmscan.c:2374)
[ 3778.472747] ? zone_watermark_ok_safe (mm/page_alloc.c:2839)
[ 3778.473340] kswapd (./arch/x86/include/asm/bitops.h:113 mm/vmscan.c:3090 mm/vmscan.c:3239 mm/vmscan.c:3427)
[ 3778.473825] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.474407] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.475182] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3778.475703] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.476267] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.476901] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.477489] kthread (kernel/kthread.c:209)
[ 3778.478009] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.478703] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.479376] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.479951] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.480508] ---[ end trace 8cbbecee22435ccd ]---

[ 3778.480937] kasan: CONFIG_KASAN_INLINE enabled

[ 3778.481333] kasan: GPF could be caused by NULL-ptr deref or user memory access[ 3778.482013] general protection fault: 0000 [#2] PREEMPT SMP KASAN

[ 3778.482568] Modules linked in:

[ 3778.482877] CPU: 16 PID: 3730 Comm: kswapd0 Tainted: G      D W       4.7.0-rc2-next-20160609-sasha-00024-g30ecaf6 #3101

[ 3778.483856] task: ffff880337162000 ti: ffff8803371b0000 task.ti: ffff8803371b0000

[ 3778.484527] RIP: __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.485307] RSP: 0000:ffff8803371b70d8  EFLAGS: 00010002

[ 3778.485782] RAX: dffffc0000000000 RBX: ffffea0005294020 RCX: ffffea000529409c

[ 3778.486410] RDX: 1bd5a00000000040 RSI: dead000000000200 RDI: ffffea0005294020

[ 3778.487054] RBP: ffff8803371b7160 R08: dead000000000200 R09: ffff8801b7fd7000

[ 3778.487716] R10: 0000000000000010 R11: ffff880a8a24ecef R12: dead000000000200

[ 3778.488378] R13: ffff8801b7fd8000 R14: 1ffff10066e36e1b R15: ffff8801b7fd8008

[ 3778.489091] FS:  0000000000000000(0000) GS:ffff8801b1b00000(0000) knlGS:0000000000000000

[ 3778.489816] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033

[ 3778.490342] CR2: 00007f2eb1c17576 CR3: 000000002ae23000 CR4: 00000000000006a0

[ 3778.491003] Stack:

[ 3778.491204]  0000000041b58ab3 ffffffffaaaf1975 ffffffffa00adae0 000000000002fcf2

[ 3778.491943]  0000000000000014 ffff8801b7fd7000 ffff8803371b7120 ffffffffa00adadc

[ 3778.492684]  0000000000000000 ffff8803371b7160 ffffffff9e6ccc36 00000000be0b1ffd

[ 3778.493418] Call Trace:

[ 3778.493674] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.494270] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.494853] ? __mod_zone_page_state (mm/vmstat.c:249)
[ 3778.495431] free_pcppages_bulk (include/linux/list.h:77 mm/page_alloc.c:870 mm/page_alloc.c:1135)
[ 3778.496024] ? __free_page_frag (mm/page_alloc.c:1084)
[ 3778.496571] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.497222] free_hot_cold_page (mm/page_alloc.c:2442 (discriminator 1))
[ 3778.497793] ? drain_all_pages (mm/page_alloc.c:2403)
[ 3778.498370] ? uncharge_list (mm/memcontrol.c:5536)
[ 3778.498913] ? __this_cpu_preempt_check (lib/list_debug.c:25)
[ 3778.499526] free_hot_cold_page_list (mm/page_alloc.c:2456 (discriminator 3))
[ 3778.500130] shrink_page_list (include/linux/compiler.h:222 include/linux/list.h:189 include/linux/list.h:296 mm/vmscan.c:1238)
[ 3778.500704] ? putback_lru_page (mm/vmscan.c:889)
[ 3778.501271] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.501898] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[ 3778.502546] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3778.503135] ? __mod_zone_page_state (mm/vmstat.c:249)
[ 3778.503737] shrink_inactive_list (include/linux/spinlock.h:332 mm/vmscan.c:1629)
[ 3778.504310] ? putback_inactive_pages (mm/vmscan.c:1573)
[ 3778.504917] ? zone_reclaimable_pages (mm/vmscan.c:208)
[ 3778.505515] ? _find_next_bit (lib/find_bit.c:54)
[ 3778.506044] ? zone_reclaimable (include/linux/vmstat.h:166 mm/vmscan.c:212)
[ 3778.506599] ? get_scan_count (mm/vmscan.c:1954)
[ 3778.507156] ? blk_start_plug (block/blk-core.c:3170 (discriminator 1))
[ 3778.507688] ? blk_lld_busy (block/blk-core.c:3170)
[ 3778.508212] shrink_zone_memcg (mm/vmscan.c:1932 mm/vmscan.c:2224)
[ 3778.508767] ? shrink_active_list (mm/vmscan.c:2181)
[ 3778.509342] ? css_next_descendant_pre (kernel/cgroup.c:4028)
[ 3778.509935] ? mem_cgroup_iter (mm/memcontrol.c:889)
[ 3778.510493] ? preempt_count_add (include/linux/ftrace.h:724 kernel/sched/core.c:3074 kernel/sched/core.c:3099)
[ 3778.511044] shrink_zone (mm/vmscan.c:2407)
[ 3778.511540] ? mem_cgroup_split_huge_fixup (mm/memcontrol.c:2607)
[ 3778.512185] ? shrink_zone_memcg (mm/vmscan.c:2374)
[ 3778.512760] ? zone_watermark_ok_safe (mm/page_alloc.c:2839)
[ 3778.513374] kswapd (./arch/x86/include/asm/bitops.h:113 mm/vmscan.c:3090 mm/vmscan.c:3239 mm/vmscan.c:3427)
[ 3778.513911] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:92 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3778.514491] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.515141] ? __schedule (kernel/sched/core.c:2858 kernel/sched/core.c:3345)
[ 3778.515665] ? remove_wait_queue (kernel/sched/wait.c:292)
[ 3778.516212] ? default_wake_function (kernel/sched/core.c:3544)
[ 3778.516795] ? __kthread_parkme (kernel/kthread.c:168)
[ 3778.517345] kthread (kernel/kthread.c:209)
[ 3778.517816] ? mem_cgroup_shrink_node_zone (mm/vmscan.c:3351)
[ 3778.518438] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.518983] ret_from_fork (arch/x86/entry/entry_64.S:390)
[ 3778.519496] ? kthread_worker_fn (kernel/kthread.c:178)
[ 3778.520040] Code: b2 a8 e8 ea 1b 2d fe 4d 85 e4 75 0e 31 f6 48 c7 c7 40 34 71 ae e8 c3 89 08 00 48 b8 00 00 00 00 00 fc ff df 4c 89 e2 48 c1 ea 03 <80> 3c 02 00 74 08 4c 89 e7 e8 88 3d 6f fe 4d 8b 04 24 4d 39 e8

All code
========
   0:	b2 a8                	mov    $0xa8,%dl
   2:	e8 ea 1b 2d fe       	callq  0xfffffffffe2d1bf1
   7:	4d 85 e4             	test   %r12,%r12
   a:	75 0e                	jne    0x1a
   c:	31 f6                	xor    %esi,%esi
   e:	48 c7 c7 40 34 71 ae 	mov    $0xffffffffae713440,%rdi
  15:	e8 c3 89 08 00       	callq  0x889dd
  1a:	48 b8 00 00 00 00 00 	movabs $0xdffffc0000000000,%rax
  21:	fc ff df
  24:	4c 89 e2             	mov    %r12,%rdx
  27:	48 c1 ea 03          	shr    $0x3,%rdx
  2b:*	80 3c 02 00          	cmpb   $0x0,(%rdx,%rax,1)		<-- trapping instruction
  2f:	74 08                	je     0x39
  31:	4c 89 e7             	mov    %r12,%rdi
  34:	e8 88 3d 6f fe       	callq  0xfffffffffe6f3dc1
  39:	4d 8b 04 24          	mov    (%r12),%r8
  3d:	4d 39 e8             	cmp    %r13,%r8
	...

Code starting with the faulting instruction
===========================================
   0:	80 3c 02 00          	cmpb   $0x0,(%rdx,%rax,1)
   4:	74 08                	je     0xe
   6:	4c 89 e7             	mov    %r12,%rdi
   9:	e8 88 3d 6f fe       	callq  0xfffffffffe6f3d96
   e:	4d 8b 04 24          	mov    (%r12),%r8
  12:	4d 39 e8             	cmp    %r13,%r8
	...
[ 3778.522780] RIP __list_add (lib/list_debug.c:30 (discriminator 3))
[ 3778.523311]  RSP <ffff8803371b70d8>

[ 3778.523654] ---[ end trace 8cbbecee22435cce ]---

[ 3779.304858] Shutting down cpus with NMI

[ 3779.306134] Kernel Offset: 0x1d000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)

[ 3779.307309] Rebooting in 1 seconds..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
