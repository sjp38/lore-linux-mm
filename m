Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 61D626B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 06:49:48 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id do7so4650416pab.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 03:49:48 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n26si33481240pfi.159.2016.01.06.03.49.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Jan 2016 03:49:46 -0800 (PST)
Subject: Re: [RFC][PATCH] sysrq: ensure manual invocation of the OOM killerunder OOM livelock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201512301533.JDJ18237.QOFOMVSFtHOJLF@I-love.SAKURA.ne.jp>
	<20160105162246.GH15324@dhcp22.suse.cz>
	<20160105180507.GB23326@dhcp22.suse.cz>
In-Reply-To: <20160105180507.GB23326@dhcp22.suse.cz>
Message-Id: <201601062049.CIB17682.VtMHSQFOJOOLFF@I-love.SAKURA.ne.jp>
Date: Wed, 6 Jan 2016 20:49:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 05-01-16 17:22:46, Michal Hocko wrote:
> > On Wed 30-12-15 15:33:47, Tetsuo Handa wrote:
> [...]
> > > I wish for a kernel thread that does OOM-kill operation.
> > > Maybe we can change the OOM reaper kernel thread to do it.
> > > What do you think?
> > 
> > I do no think a separate kernel thread would help much if the
> > allocations have to keep looping in the allocator. oom_reaper is a
> > separate kernel thread only due to locking required for the exit_mmap
> > path.
> 
> Let me clarify what I've meant here. What you actually want is to do
> select_bad_process and oom_kill_process (including oom_reap_vmas) in
> the kernel thread context, right?

Right.

>                                   That should be doable because we do
> not depend on the allocation context there. That would certainly save
> 1 kernel thread for the sysrq+f part but it would make the regular
> case more complicated AFAICS.

Below patch did SysRq-f part for me. Nothing complicated.

----------
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index e513940..e42c4f0 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -357,27 +357,9 @@ static struct sysrq_key_op sysrq_term_op = {
 	.enable_mask	= SYSRQ_ENABLE_SIGNAL,
 };
 
-static void moom_callback(struct work_struct *ignored)
-{
-	const gfp_t gfp_mask = GFP_KERNEL;
-	struct oom_control oc = {
-		.zonelist = node_zonelist(first_memory_node, gfp_mask),
-		.nodemask = NULL,
-		.gfp_mask = gfp_mask,
-		.order = -1,
-	};
-
-	mutex_lock(&oom_lock);
-	if (!out_of_memory(&oc))
-		pr_info("OOM request ignored because killer is disabled\n");
-	mutex_unlock(&oom_lock);
-}
-
-static DECLARE_WORK(moom_work, moom_callback);
-
 static void sysrq_handle_moom(int key)
 {
-	schedule_work(&moom_work);
+	request_moom();
 }
 static struct sysrq_key_op sysrq_moom_op = {
 	.handler	= sysrq_handle_moom,
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 03e6257..9cf2797 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -113,6 +113,10 @@ static inline bool task_will_free_mem(struct task_struct *task)
 		!(task->signal->flags & SIGNAL_GROUP_COREDUMP);
 }
 
+#ifdef CONFIG_MAGIC_SYSRQ
+extern void request_moom(void);
+#endif
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b8a4210..3282eaf 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -498,13 +498,50 @@ static void oom_reap_vmas(struct mm_struct *mm)
 	mmdrop(mm);
 }
 
+#ifdef CONFIG_MAGIC_SYSRQ
+static bool moom_pending;
+void request_moom(void)
+{
+	if (!oom_reaper_th) {
+		pr_info("OOM request ignored because killer is disabled\n");
+		return;
+	}
+	moom_pending = true;
+	wake_up(&oom_reaper_wait);
+}
+
+static void run_moom(void)
+{
+	const gfp_t gfp_mask = GFP_KERNEL;
+	struct oom_control oc = {
+		.zonelist = node_zonelist(first_memory_node, gfp_mask),
+		.nodemask = NULL,
+		.gfp_mask = gfp_mask,
+		.order = -1,
+	};
+
+	mutex_lock(&oom_lock);
+	if (!out_of_memory(&oc))
+		pr_info("OOM request ignored because killer is disabled\n");
+	mutex_unlock(&oom_lock);
+	moom_pending = false;
+}
+#else
+#define moom_pending 0
+#define run_moom() do { } while (0)
+#endif
+
 static int oom_reaper(void *unused)
 {
 	while (true) {
 		struct mm_struct *mm;
 
 		wait_event_freezable(oom_reaper_wait,
-				     (mm = READ_ONCE(mm_to_reap)));
+				     (mm = READ_ONCE(mm_to_reap)) || moom_pending);
+		if (moom_pending) {
+			run_moom();
+			continue;
+		}
 		oom_reap_vmas(mm);
 		WRITE_ONCE(mm_to_reap, NULL);
 	}
----------

While testing above patch, I once hit depletion of memory reserves.

----------
[  280.260980] kthreadd invoked oom-killer: order=1, oom_score_adj=0, gfp_mask=0x26040c0(GFP_KERNEL|GFP_COMP|GFP_NOTRACK)
[  280.286661] kthreadd cpuset=/ mems_allowed=0
[  280.298765] CPU: 2 PID: 2 Comm: kthreadd Not tainted 4.4.0-rc8-next-20160105+ #21
(...snipped...)
[  280.418223] Mem-Info:
[  280.419835] active_anon:310834 inactive_anon:2104 isolated_anon:0
[  280.419835]  active_file:1834 inactive_file:110234 isolated_file:0
[  280.419835]  unevictable:0 dirty:89151 writeback:21082 unstable:0
[  280.419835]  slab_reclaimable:3917 slab_unreclaimable:4622
[  280.419835]  mapped:2372 shmem:2167 pagetables:1736 bounce:0
[  280.419835]  free:3016 free_pcp:186 free_cma:0
[  280.439315] Node 0 DMA free:6968kB min:44kB low:52kB high:64kB active_anon:6628kB inactive_anon:100kB active_file:76kB inactive_file:684kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:504kB writeback:180kB mapped:80kB shmem:104kB slab_reclaimable:148kB slab_unreclaimable:284kB kernel_stack:128kB pagetables:304kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:10116 all_unreclaimable? yes
[  280.463445] lowmem_reserve[]: 0 1731 1731 1731
[  280.466464] Node 0 DMA32 free:5096kB min:5200kB low:6500kB high:7800kB active_anon:1236708kB inactive_anon:8316kB active_file:7260kB inactive_file:440252kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1826688kB managed:1775176kB mlocked:0kB dirty:356100kB writeback:84148kB mapped:9412kB shmem:8564kB slab_reclaimable:15520kB slab_unreclaimable:18204kB kernel_stack:3776kB pagetables:6640kB unstable:0kB bounce:0kB free_pcp:744kB local_pcp:284kB free_cma:0kB writeback_tmp:0kB pages_scanned:3020316 all_unreclaimable? yes
[  280.492381] lowmem_reserve[]: 0 0 0 0
[  280.495050] Node 0 DMA: 6*4kB (UE) 4*8kB (ME) 8*16kB (ME) 0*32kB 2*64kB (ME) 4*128kB (U) 2*256kB (UE) 3*512kB (UME) 2*1024kB (UE) 1*2048kB (U) 0*4096kB = 6968kB
[  280.504275] Node 0 DMA32: 198*4kB (UME) 38*8kB (UME) 40*16kB (UE) 9*32kB (UE) 6*64kB (UME) 5*128kB (UM) 8*256kB (UE) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5096kB
[  280.513565] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  280.518646] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  280.523496] 114235 total pagecache pages
[  280.526110] 0 pages in swap cache
[  280.528437] Swap cache stats: add 0, delete 0, find 0/0
[  280.531695] Free swap  = 0kB
[  280.533807] Total swap = 0kB
[  280.535913] 460669 pages RAM
[  280.538048] 0 pages HighMem/MovableOnly
[  280.540622] 12899 pages reserved
[  280.542909] 0 pages cma reserved
[  280.545166] 0 pages hwpoisoned
(...snipped...)
[  347.891645] Mem-Info:
[  347.891647] active_anon:310834 inactive_anon:2104 isolated_anon:0
[  347.891647]  active_file:1834 inactive_file:110234 isolated_file:0
[  347.891647]  unevictable:0 dirty:89151 writeback:21082 unstable:0
[  347.891647]  slab_reclaimable:3896 slab_unreclaimable:7848
[  347.891647]  mapped:2381 shmem:2167 pagetables:1736 bounce:0
[  347.891647]  free:0 free_pcp:7 free_cma:0
[  347.891649] Node 0 DMA free:0kB min:44kB low:52kB high:64kB active_anon:6636kB inactive_anon:100kB active_file:76kB inactive_file:684kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:504kB writeback:180kB mapped:84kB shmem:104kB slab_reclaimable:148kB slab_unreclaimable:7240kB kernel_stack:128kB pagetables:304kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:558052 all_unreclaimable? yes
[  347.891650] lowmem_reserve[]: 0 1731 1731 1731
[  347.891652] Node 0 DMA32 free:0kB min:5200kB low:6500kB high:7800kB active_anon:1236700kB inactive_anon:8316kB active_file:7260kB inactive_file:440252kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1826688kB managed:1775176kB mlocked:0kB dirty:356100kB writeback:84148kB mapped:9440kB shmem:8564kB slab_reclaimable:15436kB slab_unreclaimable:24152kB kernel_stack:3728kB pagetables:6640kB unstable:0kB bounce:0kB free_pcp:28kB local_pcp:4kB free_cma:0kB writeback_tmp:0kB pages_scanned:6965216 all_unreclaimable? yes
[  347.891653] lowmem_reserve[]: 0 0 0 0
[  347.891655] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[  347.891657] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[  347.891658] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  347.891658] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  347.891659] 114235 total pagecache pages
[  347.891659] 0 pages in swap cache
[  347.891659] Swap cache stats: add 0, delete 0, find 0/0
[  347.891660] Free swap  = 0kB
[  347.891660] Total swap = 0kB
[  347.891660] 460669 pages RAM
[  347.891660] 0 pages HighMem/MovableOnly
[  347.891660] 12899 pages reserved
[  347.891660] 0 pages cma reserved
[  347.891660] 0 pages hwpoisoned
----------
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160106.txt.xz .

I don't think this depletion was caused by above patch because the last
invocation was not SysRq-f. I believe we should add a workaround for
the worst case now. It is impossible to add it after we made the code
more and more difficult to test.

>                               We would have to handle queuing of the
> oom requests because multiple oom killers might be active in different
> allocation domains (cpusets, memcgs) so I am not so sure this would be a
> great win in the end. But I haven't tried to do it so I might be wrong
> and it will turn up being much more easier than I expect.

I could not catch what you want to say. If you are worrying about failing
to call oom_reap_vmas() for second victim due to invoking the OOM killer
again before mm_to_reap is updated from first victim to NULL, we can walk
on the process list.

By the way, it would be nice if console_callback() can work as well as
moom_callback(), for sometimes updating console text is deferred until
OOM livelock is solved by pressing SysRq-f. Under such situation, serial
console and/or netconsole which are updated by synchronously emitted
printk() is the only way for checking progress.

----------
[  228.561671] Showing busy workqueues and worker pools:
[  228.563546] workqueue events: flags=0x0
[  228.565259]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=5/256
[  228.567408]     pending: e1000_watchdog [e1000], push_to_pool, console_callback, vmw_fb_dirty_flush [vmwgfx], sysrq_reinject_alt_sysrq
[  228.570772] workqueue events_power_efficient: flags=0x80
[  228.572701]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  228.575204]     pending: neigh_periodic_work, neigh_periodic_work
[  228.577380] workqueue events_freezable_power_: flags=0x84
[  228.579323]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  228.581513]     pending: disk_events_workfn
[  228.583306] workqueue writeback: flags=0x4e
[  228.585057]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[  228.587107]     in-flight: 396:wb_workfn
[  228.588799]     pending: wb_workfn
[  228.590441] workqueue xfs-data/sda1: flags=0xc
[  228.592180]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=51/256 MAYDAY
[  228.594440]     in-flight: 266:xfs_end_io, 43:xfs_end_io, 413(RESCUER):xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io xfs_end_io, 9572:xfs_end_io, 9573:xfs_end_io, 9571:xfs_end_io, 9570:xfs_end_io, 9569:xfs_end_io, 9567:xfs_end_io, 9565:xfs_end_io, 9566:xfs_end_io, 9564:xfs_end_io, 4:xfs_end_io, 9559:xfs_end_io, 9568:xfs_end_io, 9560:xfs_end_io, 9561:xfs_end_io, 9563:xfs_end_io, 9562:xfs_end_io
[  228.605666]     pending: xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io, xfs_end_io
[  228.612566] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=135s workers=19 manager: 9574
[  228.615129] pool 16: cpus=0-7 flags=0x4 nice=0 hung=3s workers=32 idle: 395 394 393 392 391 390 389 388 387 386 385 384 383 382 381 380 379 378 377 376 375 374 373 372 272 282 6 273 73 398 397
----------
[ 1138.877252] Showing busy workqueues and worker pools:
[ 1138.878945] workqueue events: flags=0x0
[ 1138.880560]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[ 1138.882494]     pending: e1000_watchdog [e1000], console_callback, vmw_fb_dirty_flush [vmwgfx]
[ 1138.884944] workqueue events_power_efficient: flags=0x80
[ 1138.886658]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[ 1138.888675]     pending: neigh_periodic_work, neigh_periodic_work
[ 1138.890602] workqueue events_freezable_power_: flags=0x84
[ 1138.892357]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1138.894256]     pending: disk_events_workfn
[ 1138.895939] workqueue writeback: flags=0x4e
[ 1138.897428]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=2/256
[ 1138.899223]     in-flight: 9701:wb_workfn wb_workfn
[ 1138.901027] workqueue xfs-data/sda1: flags=0xc
[ 1138.902555]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=6/256
[ 1138.904500]     in-flight: 9689:xfs_end_io, 9838:xfs_end_io, 9752:xfs_end_io, 86:xfs_end_io, 9750:xfs_end_io, 88:xfs_end_io
[ 1138.907322]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[ 1138.909206]     in-flight: 9778:xfs_end_io, 9779:xfs_end_io
[ 1138.910988]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=3/256
[ 1138.912927]     in-flight: 14:xfs_end_io, 9717:xfs_end_io, 420:xfs_end_io
[ 1138.914892]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=25/256
[ 1138.916852]     in-flight: 9855:xfs_end_io, 9856:xfs_end_io, 413(RESCUER):xfs_end_io, 9724:xfs_end_io, 9726:xfs_end_io, 9857:xfs_end_io, 9858:xfs_end_io, 9725:xfs_end_io, 9854:xfs_end_io, 9727:xfs_end_io, 9852:xfs_end_io, 9686:xfs_end_io, 9730:xfs_end_io, 9851:xfs_end_io, 9678:xfs_end_io, 9582:xfs_end_io, 9861:xfs_end_io, 9732:xfs_end_io, 9729:xfs_end_io, 9859:xfs_end_io, 9863:xfs_end_io, 9723:xfs_end_io, 9853:xfs_end_io, 9860:xfs_end_io, 9728:xfs_end_io
[ 1138.926489] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=39s workers=25 manager: 9862
[ 1138.928792] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=2s workers=4 manager: 9731
[ 1138.931110] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=63 idle: 9777 9780 9781 9782 9783 9784 9785 9786 9787 9788 9789 9790 9791 9792 9793 9794 9795 9796 9797 9798 9799 9800 9776 9775 9774 9773 9772 9771 9770 9769 9768 9767 9766 9765 9764 9763 9762 9761 9760 9759 9758 9757 9756 9755 9754 9753 9751 9749 9747 9746 9720 9719 9721 9734 9718 44 9679 9722 9705 9801 9802
[ 1138.940913] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=19 idle: 9735 9733 9736 9737 9738 9739 9740 9741 9742 9745 9743 9744 9748
[ 1138.944429] pool 16: cpus=0-7 flags=0x4 nice=0 hung=0s workers=3 idle: 396 395
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
