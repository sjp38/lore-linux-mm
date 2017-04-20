Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 288106B03C8
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:47:28 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id r16so55703680ioi.7
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 04:47:28 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i184si6725378ioi.48.2017.04.20.04.47.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 04:47:23 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
	<alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com>
	<201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1704181435560.112481@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1704181435560.112481@chino.kir.corp.google.com>
Message-Id: <201704202046.AFC86943.VFFOQLHMJtOSFO@I-love.SAKURA.ne.jp>
Date: Thu, 20 Apr 2017 20:46:57 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, mhocko@kernel.org, sgruszka@redhat.com

David Rientjes wrote:
> On Tue, 18 Apr 2017, Tetsuo Handa wrote:
> 
> > > I have a couple of suggestions for Tetsuo about this patch, though:
> > > 
> > >  - We now have show_mem_rs, stall_rs, and nopage_rs.  Ugh.  I think it's
> > >    better to get rid of show_mem_rs and let warn_alloc_common() not 
> > >    enforce any ratelimiting at all and leave it to the callers.
> > 
> > Commit aa187507ef8bb317 ("mm: throttle show_mem() from warn_alloc()") says
> > that show_mem_rs was added because a big part of the output is show_mem()
> > which can generate a lot of output even on a small machines. Thus, I think
> > ratelimiting at warn_alloc_common() makes sense for users who want to use
> > warn_alloc_stall() for reporting stalls.
> > 
> 
> The suggestion is to eliminate show_mem_rs, it has an interval of HZ and 
> burst of 1 when the calling function(s), warn_alloc() and 
> warn_alloc_stall(), will have intervals of 5 * HZ and burst of 10.  We 
> don't need show_mem_rs :)

Excuse me, but are you sure?

http://I-love.SAKURA.ne.jp/tmp/serial-20170420.txt.xz is an example output taken
with below patch (i.e. remove show_mem_rs, pr_cont(), "struct va_format" usage
(oh, why are we using "struct va_format"?) and ", nodemask=(null)" ) applied.

----------
 include/linux/mm.h |  4 ++--
 mm/page_alloc.c    | 64 ++++++++++++++++++++++++++++++++----------------------
 mm/vmalloc.c       |  4 ++--
 3 files changed, 42 insertions(+), 30 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c82e8db..3ecf44e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2016,8 +2016,8 @@ extern void memmap_init_zone(unsigned long, int, unsigned long,
 extern unsigned long arch_reserved_kernel_pages(void);
 #endif
 
-extern __printf(3, 4)
-void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...);
+extern void warn_alloc_failed(gfp_t gfp_mask, nodemask_t *nodemask,
+			      const char *fmt, ...) __printf(3, 4);
 
 extern void setup_per_cpu_pageset(void);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 362be0a..25d4cc4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3132,12 +3132,22 @@ static inline bool should_suppress_show_mem(void)
 	return ret;
 }
 
-static void warn_alloc_show_mem(gfp_t gfp_mask, nodemask_t *nodemask)
+static void warn_alloc_common(const char *msg, gfp_t gfp_mask,
+			      nodemask_t *nodemask)
 {
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
-	static DEFINE_RATELIMIT_STATE(show_mem_rs, HZ, 1);
 
-	if (should_suppress_show_mem() || !__ratelimit(&show_mem_rs))
+	if (nodemask)
+		pr_warn("%s: %s, mode:%#x(%pGg), nodemask=%*pbl\n",
+			current->comm, msg, gfp_mask, &gfp_mask,
+			nodemask_pr_args(nodemask));
+	else
+		pr_warn("%s: %s, mode:%#x(%pGg)\n", current->comm, msg,
+			gfp_mask, &gfp_mask);
+	cpuset_print_current_mems_allowed();
+
+	dump_stack();
+	if (should_suppress_show_mem())
 		return;
 
 	/*
@@ -3155,9 +3165,26 @@ static void warn_alloc_show_mem(gfp_t gfp_mask, nodemask_t *nodemask)
 	show_mem(filter, nodemask);
 }
 
-void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
+static void warn_alloc_stall(gfp_t gfp_mask, nodemask_t *nodemask,
+			     unsigned long alloc_start, int order)
+{
+	char buf[64];
+	static DEFINE_RATELIMIT_STATE(stall_rs, DEFAULT_RATELIMIT_INTERVAL,
+				      DEFAULT_RATELIMIT_BURST);
+
+	if (!__ratelimit(&stall_rs))
+		return;
+
+	snprintf(buf, sizeof(buf), "page allocation stalls for %ums, order:%u",
+		 jiffies_to_msecs(jiffies - alloc_start), order);
+	buf[sizeof(buf) - 1] = '\0';
+	warn_alloc_common(buf, gfp_mask, nodemask);
+}
+
+void warn_alloc_failed(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt,
+		       ...)
 {
-	struct va_format vaf;
+	char buf[128];
 	va_list args;
 	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
 				      DEFAULT_RATELIMIT_BURST);
@@ -3166,24 +3193,11 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	    debug_guardpage_minorder() > 0)
 		return;
 
-	pr_warn("%s: ", current->comm);
-
 	va_start(args, fmt);
-	vaf.fmt = fmt;
-	vaf.va = &args;
-	pr_cont("%pV", &vaf);
+	vsnprintf(buf, sizeof(buf), fmt, args);
 	va_end(args);
-
-	pr_cont(", mode:%#x(%pGg), nodemask=", gfp_mask, &gfp_mask);
-	if (nodemask)
-		pr_cont("%*pbl\n", nodemask_pr_args(nodemask));
-	else
-		pr_cont("(null)\n");
-
-	cpuset_print_current_mems_allowed();
-
-	dump_stack();
-	warn_alloc_show_mem(gfp_mask, nodemask);
+	buf[sizeof(buf) - 1] = '\0';
+	warn_alloc_common(buf, gfp_mask, nodemask);
 }
 
 static inline struct page *
@@ -3822,9 +3836,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
-			"page allocation stalls for %ums, order:%u",
-			jiffies_to_msecs(jiffies-alloc_start), order);
+		warn_alloc_stall(gfp_mask, ac->nodemask, alloc_start, order);
 		stall_timeout += 10 * HZ;
 	}
 
@@ -3945,8 +3957,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		goto retry;
 	}
 fail:
-	warn_alloc(gfp_mask, ac->nodemask,
-			"page allocation failure: order:%u", order);
+	warn_alloc_failed(gfp_mask, ac->nodemask,
+			  "page allocation failure: order:%u", order);
 got_pg:
 	return page;
 }
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8ef8ea1..9d684f0 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1706,7 +1706,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	return area->addr;
 
 fail:
-	warn_alloc(gfp_mask, NULL,
+	warn_alloc_failed(gfp_mask, NULL,
 			  "vmalloc: allocation failure, allocated %ld of %ld bytes",
 			  (area->nr_pages*PAGE_SIZE), area->size);
 fail_no_warn:
@@ -1769,7 +1769,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	return addr;
 
 fail:
-	warn_alloc(gfp_mask, NULL,
+	warn_alloc_failed(gfp_mask, NULL,
 			  "vmalloc: allocation failure: %lu bytes", real_size);
 	return NULL;
 }
-- 
1.8.3.1
----------

This output is "nobody can invoke the OOM killer because all __GFP_FS allocations got
stuck waiting for WQ_MEM_RECLAIM work's memory allocation" case. Mem-Info: blocks are
printed 10 times in 10 seconds as well as Call Trace: blocks are printed 10 times
in 10 seconds. I think Mem-Info: blocks are sufficient for once per a second (or
even once per 10 or 30 or 60 seconds).

----------
[  155.122831] Killed process 7863 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  161.942919] kworker/1:11: page allocation stalls for 10031ms, order:0, mode:0x1400000(GFP_NOIO)
[  161.950058] kworker/1:11 cpuset=/ mems_allowed=0
[  161.953342] CPU: 1 PID: 8904 Comm: kworker/1:11 Not tainted 4.11.0-rc7-next-20170419+ #83
[  161.959133] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  161.965282] Workqueue: events_freezable_power_ disk_events_workfn
[  161.969216] Call Trace:
(...snipped...)
[  162.016915] Mem-Info:
(...snipped...)
[  162.037616] kworker/2:6: page allocation stalls for 10024ms, order:0, mode:0x1600240(GFP_NOFS|__GFP_NOWARN|__GFP_NOTRACK)
[  162.037618] kworker/2:6 cpuset=/ mems_allowed=0
[  162.037623] CPU: 2 PID: 8893 Comm: kworker/2:6 Not tainted 4.11.0-rc7-next-20170419+ #83
[  162.037623] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  162.037663] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  162.037665] Call Trace:
(...snipped...)
[  162.037926] Mem-Info:
(...snipped...)
[  162.038511] kworker/2:8: page allocation stalls for 10025ms, order:0, mode:0x1600240(GFP_NOFS|__GFP_NOWARN|__GFP_NOTRACK)
[  162.038512] kworker/2:8 cpuset=/ mems_allowed=0
[  162.038514] CPU: 2 PID: 8903 Comm: kworker/2:8 Not tainted 4.11.0-rc7-next-20170419+ #83
[  162.038515] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  162.038534] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  162.038534] Call Trace:
(...snipped...)
[  162.038774] Mem-Info:
(...snipped...)
[  162.040006] kworker/2:7: page allocation stalls for 10022ms, order:0, mode:0x1600240(GFP_NOFS|__GFP_NOWARN|__GFP_NOTRACK)
[  162.040007] kworker/2:7 cpuset=/ mems_allowed=0
[  162.040009] CPU: 2 PID: 8898 Comm: kworker/2:7 Not tainted 4.11.0-rc7-next-20170419+ #83
[  162.040010] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  162.040028] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  162.040029] Call Trace:
(...snipped...)
[  162.040307] Mem-Info:
(...snipped...)
[  162.101366] kworker/2:5: page allocation stalls for 10084ms, order:0, mode:0x1600240(GFP_NOFS|__GFP_NOWARN|__GFP_NOTRACK)
[  162.101368] kworker/2:5 cpuset=/ mems_allowed=0
[  162.101372] CPU: 2 PID: 8887 Comm: kworker/2:5 Not tainted 4.11.0-rc7-next-20170419+ #83
[  162.101373] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  162.101411] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  162.101413] Call Trace:
(...snipped...)
[  162.101672] Mem-Info:
(...snipped...)
[  162.117612] kworker/2:1: page allocation stalls for 10103ms, order:0, mode:0x1600240(GFP_NOFS|__GFP_NOWARN|__GFP_NOTRACK)
[  162.117613] kworker/2:1 cpuset=/ mems_allowed=0
[  162.117618] CPU: 2 PID: 56 Comm: kworker/2:1 Not tainted 4.11.0-rc7-next-20170419+ #83
[  162.117618] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  162.117651] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
(...snipped...)
[  162.117909] Mem-Info:
(...snipped...)
[  162.171657] kworker/1:8: page allocation stalls for 10088ms, order:0, mode:0x1600240(GFP_NOFS|__GFP_NOWARN|__GFP_NOTRACK)
[  162.171658] kworker/1:8 cpuset=/ mems_allowed=0
[  162.171662] CPU: 1 PID: 8891 Comm: kworker/1:8 Not tainted 4.11.0-rc7-next-20170419+ #83
[  162.171663] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  162.171698] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  162.171699] Call Trace:
(...snipped...)
[  162.171952] Mem-Info:
(...snipped...)
[  162.173864] kworker/0:10: page allocation stalls for 10085ms, order:0, mode:0x1600240(GFP_NOFS|__GFP_NOWARN|__GFP_NOTRACK)
[  162.173866] kworker/0:10 cpuset=/ mems_allowed=0
[  162.173870] CPU: 0 PID: 8902 Comm: kworker/0:10 Not tainted 4.11.0-rc7-next-20170419+ #83
[  162.173871] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  162.173900] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  162.173901] Call Trace:
(...snipped...)
[  162.174170] Mem-Info:
(...snipped...)
[  162.310110] kworker/3:9: page allocation stalls for 10010ms, order:0, mode:0x1600240(GFP_NOFS|__GFP_NOWARN|__GFP_NOTRACK)
[  162.310112] kworker/3:9 cpuset=/ mems_allowed=0
[  162.310117] CPU: 3 PID: 8897 Comm: kworker/3:9 Not tainted 4.11.0-rc7-next-20170419+ #83
[  162.310118] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  162.310158] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  162.310159] Call Trace:
(...snipped...)
[  162.310423] Mem-Info:
(...snipped...)
[  162.366369] kworker/3:10: page allocation stalls for 10070ms, order:0, mode:0x1600240(GFP_NOFS|__GFP_NOWARN|__GFP_NOTRACK)
[  162.366371] kworker/3:10 cpuset=/ mems_allowed=0
[  162.366376] CPU: 3 PID: 8901 Comm: kworker/3:10 Not tainted 4.11.0-rc7-next-20170419+ #83
[  162.366377] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  162.366415] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  162.366416] Call Trace:
(...snipped...)
[  162.366676] Mem-Info:
(...snipped...)
[  171.957435] warn_alloc_stall: 65 callbacks suppressed
[  171.963050] kworker/1:11: page allocation stalls for 20051ms, order:0, mode:0x1400000(GFP_NOIO)
[  171.972997] kworker/1:11 cpuset=/ mems_allowed=0
[  171.978102] CPU: 1 PID: 8904 Comm: kworker/1:11 Not tainted 4.11.0-rc7-next-20170419+ #83
[  171.986098] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  171.995675] Workqueue: events_freezable_power_ disk_events_workfn
[  171.998968] Call Trace:
(...snipped...)
[  357.093526] sysrq: SysRq : Show State
(...snipped...)
[  360.821341] xfs-eofblocks/s D10992   404      2 0x00000000
[  360.823868] Workqueue: xfs-eofblocks/sda1 xfs_eofblocks_worker [xfs]
[  360.826625] Call Trace:
[  360.827941]  __schedule+0x403/0x940
[  360.829628]  schedule+0x3d/0x90
[  360.831215]  schedule_timeout+0x23b/0x510
[  360.833034]  ? init_timer_on_stack_key+0x60/0x60
[  360.835117]  io_schedule_timeout+0x1e/0x50
[  360.837053]  ? io_schedule_timeout+0x1e/0x50
[  360.839138]  congestion_wait+0x86/0x210
[  360.840979]  ? remove_wait_queue+0x70/0x70
[  360.842927]  __alloc_pages_slowpath+0xc4b/0x11c0
[  360.845029]  __alloc_pages_nodemask+0x2dd/0x390
[  360.847097]  alloc_pages_current+0xa1/0x1f0
[  360.849024]  xfs_buf_allocate_memory+0x177/0x2e0 [xfs]
[  360.851416]  xfs_buf_get_map+0x19b/0x3e0 [xfs]
[  360.853523]  xfs_buf_read_map+0x2c/0x350 [xfs]
[  360.855618]  xfs_trans_read_buf_map+0x180/0x720 [xfs]
[  360.857957]  xfs_btree_read_buf_block.constprop.33+0x72/0xc0 [xfs]
[  360.860751]  ? init_object+0x69/0xa0
[  360.862526]  xfs_btree_lookup_get_block+0x8a/0x180 [xfs]
[  360.865017]  xfs_btree_lookup+0x12a/0x460 [xfs]
[  360.867095]  ? deactivate_slab+0x67a/0x6a0
[  360.869075]  xfs_bmbt_lookup_eq+0x1f/0x30 [xfs]
[  360.871277]  xfs_bmap_del_extent+0x1b6/0xe30 [xfs]
[  360.873501]  ? kmem_zone_alloc+0x81/0x100 [xfs]
[  360.875618]  __xfs_bunmapi+0x4bb/0xdb0 [xfs]
[  360.877687]  xfs_bunmapi+0x20/0x40 [xfs]
[  360.879544]  xfs_itruncate_extents+0x1db/0x700 [xfs]
[  360.881838]  ? log_head_lsn_show+0x60/0x60 [xfs]
[  360.884017]  xfs_free_eofblocks+0x1dd/0x230 [xfs]
[  360.886241]  xfs_inode_free_eofblocks+0x1ba/0x390 [xfs]
[  360.888892]  xfs_inode_ag_walk.isra.11+0x28a/0x580 [xfs]
[  360.891337]  ? xfs_reclaim_inode_grab+0xa0/0xa0 [xfs]
[  360.893639]  ? radix_tree_gang_lookup_tag+0xd7/0x150
[  360.895990]  ? xfs_perag_get_tag+0x191/0x320 [xfs]
[  360.898265]  xfs_inode_ag_iterator_tag+0x71/0xa0 [xfs]
[  360.900613]  ? xfs_reclaim_inode_grab+0xa0/0xa0 [xfs]
[  360.902978]  xfs_eofblocks_worker+0x2d/0x40 [xfs]
[  360.905155]  process_one_work+0x250/0x690
[  360.907077]  rescuer_thread+0x1e9/0x390
[  360.908971]  kthread+0x117/0x150
[  360.910590]  ? cancel_delayed_work_sync+0x20/0x20
[  360.912797]  ? kthread_create_on_node+0x70/0x70
[  360.914917]  ret_from_fork+0x31/0x40
(...snipped...)
[  494.965889] Showing busy workqueues and worker pools:
[  494.968148] workqueue events: flags=0x0
[  494.969792]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  494.972264]     pending: rht_deferred_worker, check_corruption, free_work, console_callback
[  494.975646]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[  494.978233]     pending: vmpressure_work_fn, vmw_fb_dirty_flush [vmwgfx], free_work
[  494.981324]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  494.983843]     pending: e1000_watchdog [e1000], free_work
[  494.986147]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  494.988629]     pending: vmstat_shepherd, e1000_watchdog [e1000]
[  494.991186] workqueue events_long: flags=0x0
[  494.993065]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  494.995529]     pending: gc_worker [nf_conntrack]
[  494.997539] workqueue events_freezable: flags=0x4
[  494.999642]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  495.002129]     pending: vmballoon_work [vmw_balloon]
[  495.004330] workqueue events_power_efficient: flags=0x80
[  495.006605]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  495.009183]     pending: fb_flashcursor
[  495.010917]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[  495.013447]     pending: neigh_periodic_work, do_cache_clean, neigh_periodic_work
[  495.016694]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  495.019391]     pending: check_lifetime
[  495.021267] workqueue events_freezable_power_: flags=0x84
[  495.023645]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  495.026186]     in-flight: 8904:disk_events_workfn
[  495.028362] workqueue writeback: flags=0x4e
[  495.030232]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[  495.032789]     in-flight: 387:wb_workfn
[  495.034749]     pending: wb_workfn
[  495.037082] workqueue xfs-data/sda1: flags=0xc
[  495.039232]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=51/256 MAYDAY
[  495.042078]     in-flight: 8892:xfs_end_io [xfs], 491:xfs_end_io [xfs], 8901:xfs_end_io [xfs], 8897:xfs_end_io [xfs], 8884:xfs_end_io [xfs], 57:xfs_end_io [xfs], 8895:xfs_end_io [xfs], 8879:xfs_end_io [xfs], 229:xfs_end_io [xfs]
[  495.050671]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  495.079324]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=120/256 MAYDAY
[  495.082426]     in-flight: 8887:xfs_end_io [xfs], 8903:xfs_end_io [xfs], 27:xfs_end_io [xfs], 56:xfs_end_io [xfs], 8883:xfs_end_io [xfs], 8893:xfs_end_io [xfs], 250:xfs_end_io [xfs], 8898:xfs_end_io [xfs]
[  495.091070]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  495.122582] , xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  495.155254] , xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  495.172735]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=34/256 MAYDAY
[  495.176183]     in-flight: 8878:xfs_end_io [xfs], 487:xfs_end_io [xfs], 8891:xfs_end_io [xfs], 8900:xfs_end_io [xfs], 76:xfs_end_io [xfs], 51:xfs_end_io [xfs], 485:xfs_end_io [xfs], 8894:xfs_end_io [xfs], 8880:xfs_end_io [xfs], 8885:xfs_end_io [xfs], 399(RESCUER):xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs]
[  495.191709]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  495.206524]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=93/256 MAYDAY
[  495.210050]     in-flight: 8886:xfs_end_io [xfs], 8888:xfs_end_io [xfs], 8896:xfs_end_io [xfs], 41:xfs_end_io [xfs], 8902:xfs_end_io [xfs], 8899:xfs_end_io [xfs], 8890:xfs_end_io [xfs], 8882:xfs_end_io [xfs], 3:xfs_end_io [xfs], 8877:xfs_end_io [xfs]
[  495.220700]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  495.255138] , xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  495.285183] workqueue xfs-cil/sda1: flags=0xc
[  495.288397]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  495.292486]     in-flight: 35:xlog_cil_push_work [xfs] BAR(405) BAR(8359) BAR(8791) BAR(8355) BAR(8684) BAR(8844) BAR(8727) BAR(8671) BAR(8858) BAR(8851) BAR(8818) BAR(8820) BAR(8790) BAR(8688) BAR(8677) BAR(8598) BAR(8546) BAR(8543) BAR(8533) BAR(8536) BAR(8441) BAR(8700) BAR(8091) BAR(7975) BAR(8106) BAR(8097) BAR(8102) BAR(8088) BAR(8644) BAR(8309) BAR(8308) BAR(8569) BAR(8043) BAR(8196) BAR(8737) BAR(8705) BAR(8723) BAR(8850) BAR(8026) BAR(7940) BAR(7905) BAR(8398) BAR(8295) BAR(8274) BAR(8094) BAR(7951) BAR(8653) BAR(8063) BAR(8073) BAR(8319) BAR(8284) BAR(7965) BAR(7998) BAR(8214) BAR(7953) BAR(8150) BAR(8107) BAR(8108) BAR(8751) BAR(8126) BAR(8722) BAR(8382) BAR(8778) BAR(8764) BAR(8762) BAR(8282) BAR(8254) BAR(8178) BAR(8213) BAR(7966) BAR(8632) BAR(8104) BAR(8486) BAR(8475) BAR(8432) BAR(8068)
[  495.326300]  BAR(8584) BAR(7941) BAR(7982) BAR(8564) BAR(8458) BAR(8338) BAR(8812) BAR(8867) BAR(8229) BAR(8021) BAR(8044) BAR(8312) BAR(8870) BAR(8819) BAR(8434) BAR(8667) BAR(7996) BAR(8216) BAR(8201) BAR(8456) BAR(8445) BAR(8193) BAR(8154) BAR(7880) BAR(8603) BAR(7877) BAR(8366) BAR(8685)
[  495.338482] workqueue xfs-eofblocks/sda1: flags=0xc
[  495.341536]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  495.344980]     in-flight: 404(RESCUER):xfs_eofblocks_worker [xfs]
[  495.348500] workqueue xfs-sync/sda1: flags=0x4
[  495.351229]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  495.354624]     pending: xfs_log_worker [xfs]
[  495.357482] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=341s workers=11 manager: 161
[  495.361511] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=340s workers=12 manager: 19
[  495.365402] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=342s workers=9 manager: 8881
[  495.369684] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=341s workers=11 manager: 8889
[  495.373681] pool 128: cpus=0-63 flags=0x4 nice=0 hung=0s workers=3 idle: 388 385
----------

Apart from I want to serialize warn_alloc_stall() messages using a mutex,
I'm not happy with lack of ability to call warn_alloc_stall() when allocating
task is unable to reach warn_alloc_stall().

http://I-love.SAKURA.ne.jp/tmp/serial-20170420-2.txt.xz is an example output taken
with below patch (e.g. use "struct timer_list" for calling warn_alloc_stall() timely)
applied.

----------
 include/linux/cpuset.h |  5 ++++
 kernel/cgroup/cpuset.c | 10 +++++--
 mm/page_alloc.c        | 79 +++++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 74 insertions(+), 20 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 119a3f9..27d9c50 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -105,6 +105,7 @@ static inline int cpuset_do_slab_mem_spread(void)
 extern void rebuild_sched_domains(void);
 
 extern void cpuset_print_current_mems_allowed(void);
+extern void cpuset_print_task_mems_allowed(struct task_struct *task);
 
 /*
  * read_mems_allowed_begin is required when making decisions involving
@@ -245,6 +246,10 @@ static inline void cpuset_print_current_mems_allowed(void)
 {
 }
 
+static inline void cpuset_print_task_mems_allowed(struct task_struct *task)
+{
+}
+
 static inline void set_mems_allowed(nodemask_t nodemask)
 {
 }
diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index f6501f4..49f781d 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -2655,15 +2655,19 @@ int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
  */
 void cpuset_print_current_mems_allowed(void)
 {
+	cpuset_print_task_mems_allowed(current);
+}
+void cpuset_print_task_mems_allowed(struct task_struct *task)
+{
 	struct cgroup *cgrp;
 
 	rcu_read_lock();
 
-	cgrp = task_cs(current)->css.cgroup;
-	pr_info("%s cpuset=", current->comm);
+	cgrp = task_cs(task)->css.cgroup;
+	pr_info("%s cpuset=", task->comm);
 	pr_cont_cgroup_name(cgrp);
 	pr_cont(" mems_allowed=%*pbl\n",
-		nodemask_pr_args(&current->mems_allowed));
+		nodemask_pr_args(&task->mems_allowed));
 
 	rcu_read_unlock();
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 25d4cc4..501b820 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -66,6 +66,7 @@
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
 #include <linux/ftrace.h>
+#include <linux/sched/debug.h> /* sched_show_task() */
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -3165,20 +3166,48 @@ static void warn_alloc_common(const char *msg, gfp_t gfp_mask,
 	show_mem(filter, nodemask);
 }
 
-static void warn_alloc_stall(gfp_t gfp_mask, nodemask_t *nodemask,
-			     unsigned long alloc_start, int order)
+struct alloc_info {
+	struct timer_list timer;
+	struct task_struct *task;
+	gfp_t gfp_mask;
+	nodemask_t *nodemask;
+	unsigned long alloc_start;
+	int order;
+	bool stop;
+};
+
+static void warn_alloc_stall(unsigned long arg)
 {
-	char buf[64];
 	static DEFINE_RATELIMIT_STATE(stall_rs, DEFAULT_RATELIMIT_INTERVAL,
 				      DEFAULT_RATELIMIT_BURST);
+	static DEFINE_SPINLOCK(lock);
+	struct alloc_info *info = (struct alloc_info *) arg;
+	struct task_struct *task = info->task;
+	unsigned int period;
 
-	if (!__ratelimit(&stall_rs))
+	if (info->stop || !__ratelimit(&stall_rs) || !spin_trylock(&lock)) {
+		info->timer.expires = jiffies + HZ;
+		goto done;
+	}
+	period = jiffies_to_msecs(jiffies - info->alloc_start);
+	rcu_read_lock();
+	if (info->nodemask)
+		pr_warn("%s: page allocation stalls for %ums, order:%u, mode:%#x(%pGg), nodemask=%*pbl\n",
+			task->comm, period, info->order, info->gfp_mask,
+			&info->gfp_mask, nodemask_pr_args(info->nodemask));
+	else
+		pr_warn("%s: page allocation stalls for %ums, order:%u, mode:%#x(%pGg)\n",
+			task->comm, period, info->order, info->gfp_mask,
+			&info->gfp_mask);
+	cpuset_print_task_mems_allowed(task);
+	sched_show_task(task);
+	rcu_read_unlock();
+	spin_unlock(&lock);
+	info->timer.expires = jiffies + 10 * HZ;
+ done:
+	if (xchg(&info->stop, 0))
 		return;
-
-	snprintf(buf, sizeof(buf), "page allocation stalls for %ums, order:%u",
-		 jiffies_to_msecs(jiffies - alloc_start), order);
-	buf[sizeof(buf) - 1] = '\0';
-	warn_alloc_common(buf, gfp_mask, nodemask);
+	add_timer(&info->timer);
 }
 
 void warn_alloc_failed(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt,
@@ -3703,8 +3732,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	enum compact_result compact_result;
 	int compaction_retries;
 	int no_progress_loops;
-	unsigned long alloc_start = jiffies;
-	unsigned int stall_timeout = 10 * HZ;
+	bool stall_timer_initialized = false;
+	struct alloc_info alloc_info;
 	unsigned int cpuset_mems_cookie;
 
 	/*
@@ -3834,16 +3863,25 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	if (!can_direct_reclaim)
 		goto nopage;
 
-	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc_stall(gfp_mask, ac->nodemask, alloc_start, order);
-		stall_timeout += 10 * HZ;
-	}
-
 	/* Avoid recursion of direct reclaim */
 	if (current->flags & PF_MEMALLOC)
 		goto nopage;
 
+	/* Make sure we know about allocations which stall for too long */
+	if (!stall_timer_initialized) {
+		stall_timer_initialized = true;
+		alloc_info.task = current;
+		alloc_info.gfp_mask = gfp_mask;
+		alloc_info.nodemask = ac->nodemask;
+		alloc_info.alloc_start = jiffies;
+		alloc_info.order = order;
+		alloc_info.stop = 0;
+		setup_timer_on_stack(&alloc_info.timer, warn_alloc_stall,
+				     (unsigned long) &alloc_info);
+		alloc_info.timer.expires = jiffies + 10 * HZ;
+		add_timer(&alloc_info.timer);
+	}
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
 							&did_some_progress);
@@ -3960,6 +3998,13 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	warn_alloc_failed(gfp_mask, ac->nodemask,
 			  "page allocation failure: order:%u", order);
 got_pg:
+	if (stall_timer_initialized) {
+		while (try_to_del_timer_sync(&alloc_info.timer) < 0) {
+			xchg(&alloc_info.stop, 1);
+			schedule_timeout_uninterruptible(1);
+		}
+		destroy_timer_on_stack(&alloc_info.timer);
+	}
 	return page;
 }
 
-- 
1.8.3.1
----------

This output is "nobody can invoke the OOM killer because all __GFP_FS allocations got
stuck at shrink_inactive_list()" case. Maybe it was waiting for memory allocation by
"401(RESCUER):xfs_end_io". Relevant information are unavailable unless SysRq-t is used.

Although calling warn_alloc_stall() using timers gives us more hints than without
using timers, ratelimiting after all makes it impossible to obtain backtraces reliably.
If a process context were available (i.e. kmallocwd), we will be able to obtain
relevant backtraces reliably while reducing overhead of manipulating timers.

----------
[  381.076810] Out of memory: Kill process 8839 (a.out) score 999 or sacrifice child
[  381.080513] Killed process 8839 (a.out) total-vm:4168kB, anon-rss:80kB, file-rss:24kB, shmem-rss:0kB
[  381.090231] oom_reaper: reaped process 8839 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  392.161167] warn_alloc_stall: 116 callbacks suppressed
[  392.164062] a.out: page allocation stalls for 10008ms, order:0, mode:0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
[  392.169208] a.out cpuset=/ mems_allowed=0
[  392.171537] a.out           D11400  8395   7853 0x00000080
[  392.174470] Call Trace:
[  392.176199]  __schedule+0x403/0x940
[  392.178293]  schedule+0x3d/0x90
[  392.180340]  schedule_timeout+0x23b/0x510
[  392.182708]  ? init_timer_on_stack_key+0x60/0x60
[  392.185186]  ? trace_hardirqs_on+0xd/0x10
[  392.187505]  io_schedule_timeout+0x1e/0x50
[  392.189867]  ? io_schedule_timeout+0x1e/0x50
[  392.192298]  congestion_wait+0x86/0x210
[  392.194502]  ? remove_wait_queue+0x70/0x70
[  392.198476]  __alloc_pages_slowpath+0xc9c/0x11e0
[  392.200971]  ? __change_page_attr+0x93c/0xa50
[  392.203369]  ? nr_free_buffer_pages+0x20/0x20
[  392.205761]  __alloc_pages_nodemask+0x2dd/0x390
[  392.208200]  alloc_pages_current+0xa1/0x1f0
[  392.210412]  new_slab+0x2dc/0x680
[  392.212377]  ? _raw_spin_unlock+0x27/0x40
[  392.214552]  ___slab_alloc+0x443/0x640
[  392.216593]  ? kmem_zone_alloc+0x81/0x100 [xfs]
[  392.218897]  ? set_track+0x70/0x140
[  392.220846]  ? init_object+0x69/0xa0
[  392.222814]  ? kmem_zone_alloc+0x81/0x100 [xfs]
[  392.225085]  __slab_alloc+0x51/0x90
[  392.226941]  ? __slab_alloc+0x51/0x90
[  392.228928]  ? kmem_zone_alloc+0x81/0x100 [xfs]
[  392.231214]  kmem_cache_alloc+0x283/0x350
[  392.233262]  kmem_zone_alloc+0x81/0x100 [xfs]
[  392.235396]  xlog_ticket_alloc+0x37/0xe0 [xfs]
[  392.237747]  xfs_log_reserve+0xb5/0x440 [xfs]
[  392.239789]  xfs_trans_reserve+0x1f6/0x2c0 [xfs]
[  392.241989]  xfs_trans_alloc+0xc1/0x130 [xfs]
[  392.244080]  xfs_vn_update_time+0x80/0x240 [xfs]
[  392.246307]  file_update_time+0xb7/0x110
[  392.248391]  xfs_file_aio_write_checks+0x13c/0x1a0 [xfs]
[  392.250843]  xfs_file_buffered_aio_write+0x75/0x370 [xfs]
[  392.253351]  xfs_file_write_iter+0x92/0x140 [xfs]
[  392.255486]  __vfs_write+0xe7/0x140
[  392.257267]  vfs_write+0xca/0x1c0
[  392.258946]  SyS_write+0x58/0xc0
[  392.260627]  do_syscall_64+0x6c/0x1c0
[  392.262499]  entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  443.361097] warn_alloc_stall: 3322 callbacks suppressed
[  443.363619] khugepaged: page allocation stalls for 16386ms, order:9, mode:0x4742ca(GFP_TRANSHUGE|__GFP_THISNODE)
[  443.367880] khugepaged cpuset=/ mems_allowed=0
[  443.370010] khugepaged      D12016    47      2 0x00000000
[  443.372490] Call Trace:
[  443.373828]  __schedule+0x403/0x940
[  443.375532]  schedule+0x3d/0x90
[  443.377097]  schedule_timeout+0x23b/0x510
[  443.378982]  ? prepare_to_wait+0x2b/0xc0
[  443.380887]  ? init_timer_on_stack_key+0x60/0x60
[  443.383007]  io_schedule_timeout+0x1e/0x50
[  443.384934]  ? io_schedule_timeout+0x1e/0x50
[  443.386930]  congestion_wait+0x86/0x210
[  443.388806]  ? remove_wait_queue+0x70/0x70
[  443.390752]  shrink_inactive_list+0x45e/0x590
[  443.392784]  ? inactive_list_is_low+0x16b/0x300
[  443.394893]  shrink_node_memcg+0x378/0x750
[  443.396828]  shrink_node+0xe1/0x310
[  443.398524]  ? shrink_node+0xe1/0x310
[  443.400530]  do_try_to_free_pages+0xef/0x370
[  443.402522]  try_to_free_pages+0x12c/0x370
[  443.404458]  __alloc_pages_slowpath+0x4a8/0x11e0
[  443.406598]  ? get_page_from_freelist+0x546/0xe30
[  443.408744]  ? nr_free_buffer_pages+0x20/0x20
[  443.410802]  __alloc_pages_nodemask+0x2dd/0x390
[  443.412904]  khugepaged_alloc_page+0x60/0xb0
[  443.414918]  collapse_huge_page+0x85/0x10b0
[  443.416880]  ? khugepaged+0x6ad/0x1440
[  443.418689]  khugepaged+0xdb4/0x1440
[  443.420455]  ? remove_wait_queue+0x70/0x70
[  443.422496]  kthread+0x117/0x150
[  443.424104]  ? collapse_huge_page+0x10b0/0x10b0
[  443.426289]  ? kthread_create_on_node+0x70/0x70
[  443.428425]  ret_from_fork+0x31/0x40
[  448.481006] warn_alloc_stall: 3321 callbacks suppressed
[  448.483590] a.out: page allocation stalls for 66059ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  448.487801] a.out cpuset=/ mems_allowed=0
[  448.489728] a.out           D11824  8047   7853 0x00000080
[  448.492223] Call Trace:
[  448.493608]  __schedule+0x403/0x940
[  448.495358]  schedule+0x3d/0x90
[  448.496979]  schedule_timeout+0x23b/0x510
[  448.499181]  ? prepare_to_wait+0x2b/0xc0
[  448.501268]  ? init_timer_on_stack_key+0x60/0x60
[  448.503607]  io_schedule_timeout+0x1e/0x50
[  448.505728]  ? io_schedule_timeout+0x1e/0x50
[  448.507939]  congestion_wait+0x86/0x210
[  448.509984]  ? remove_wait_queue+0x70/0x70
[  448.512088]  shrink_inactive_list+0x45e/0x590
[  448.514469]  shrink_node_memcg+0x378/0x750
[  448.516413]  shrink_node+0xe1/0x310
[  448.518156]  ? shrink_node+0xe1/0x310
[  448.519921]  do_try_to_free_pages+0xef/0x370
[  448.521895]  try_to_free_pages+0x12c/0x370
[  448.523865]  __alloc_pages_slowpath+0x4a8/0x11e0
[  448.526018]  ? get_page_from_freelist+0x1ae/0xe30
[  448.528177]  ? nr_free_buffer_pages+0x20/0x20
[  448.530198]  __alloc_pages_nodemask+0x2dd/0x390
[  448.532290]  alloc_pages_current+0xa1/0x1f0
[  448.534257]  __page_cache_alloc+0x148/0x180
[  448.536201]  filemap_fault+0x3dc/0x950
[  448.538052]  ? xfs_ilock+0x290/0x320 [xfs]
[  448.540008]  ? xfs_filemap_fault+0x5b/0x180 [xfs]
[  448.542159]  ? down_read_nested+0x73/0xb0
[  448.544076]  xfs_filemap_fault+0x63/0x180 [xfs]
[  448.546147]  __do_fault+0x1e/0x140
[  448.548053]  __handle_mm_fault+0xb96/0x10f0
[  448.550020]  handle_mm_fault+0x190/0x350
[  448.551864]  __do_page_fault+0x266/0x520
[  448.553767]  do_page_fault+0x30/0x80
[  448.555501]  page_fault+0x28/0x30
[  448.557127] RIP: 0033:0x7faffa8b9c60
[  448.558857] RSP: 002b:00007ffe61b95118 EFLAGS: 00010246
[  448.561189] RAX: 0000000000000080 RBX: 0000000000000003 RCX: 00007faffa8b9c60
[  448.564275] RDX: 0000000000000080 RSI: 00000000006010c0 RDI: 0000000000000003
[  448.567329] RBP: 0000000000000000 R08: 00007ffe61b95050 R09: 00007ffe61b94e90
[  448.570386] R10: 00007ffe61b94ea0 R11: 0000000000000246 R12: 00000000004008b9
[  448.573459] R13: 00007ffe61b95220 R14: 0000000000000000 R15: 0000000000000000
[  453.089202] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 70s!
[  453.092876] Showing busy workqueues and worker pools:
[  453.095257] workqueue events: flags=0x0
[  453.097319]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=3/256
[  453.100059]     pending: vmpressure_work_fn, e1000_watchdog [e1000], check_corruption
[  453.103554]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  453.106313]     pending: e1000_watchdog [e1000]
[  453.108475]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[  453.111213]     in-flight: 458:vmw_fb_dirty_flush [vmwgfx] vmw_fb_dirty_flush [vmwgfx]
[  453.114683]     pending: vmstat_shepherd, rht_deferred_worker
[  453.117398] workqueue events_long: flags=0x0
[  453.119505]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  453.122277]     pending: gc_worker [nf_conntrack]
[  453.124587] workqueue events_freezable: flags=0x4
[  453.127077]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  453.130044]     pending: vmballoon_work [vmw_balloon]
[  453.132529] workqueue events_power_efficient: flags=0x80
[  453.135083]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=3/256
[  453.137885]     pending: do_cache_clean, neigh_periodic_work, neigh_periodic_work
[  453.141309]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  453.144109]     pending: fb_flashcursor, check_lifetime
[  453.146622] workqueue events_freezable_power_: flags=0x84
[  453.149237]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  453.152046]     pending: disk_events_workfn
[  453.154165] workqueue mm_percpu_wq: flags=0xc
[  453.156369]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  453.159180]     pending: vmstat_update
[  453.161110]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  453.163928]     pending: vmstat_update
[  453.165909] workqueue writeback: flags=0x4e
[  453.168030]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[  453.170774]     in-flight: 379:wb_workfn wb_workfn
[  453.173658] workqueue mpt_poll_0: flags=0x8
[  453.175809]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  453.178663]     pending: mpt_fault_reset_work [mptbase]
[  453.181288] workqueue xfs-data/sda1: flags=0xc
[  453.183535]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=60/256 MAYDAY
[  453.186627]     in-flight: 35:xfs_end_io [xfs], 8896:xfs_end_io [xfs], 127:xfs_end_io [xfs], 8924:xfs_end_io [xfs], 8921:xfs_end_io [xfs], 8915:xfs_end_io [xfs], 8891:xfs_end_io [xfs], 8888:xfs_end_io [xfs], 8889:xfs_end_io [xfs], 8879:xfs_end_io [xfs], 401(RESCUER):xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs], 8927:xfs_end_io [xfs], 8892:xfs_end_io [xfs], 8887:xfs_end_io [xfs], 8890:xfs_end_io [xfs], 8883:xfs_end_io [xfs], 59:xfs_end_io [xfs], 8912:xfs_end_io [xfs]
[  453.205007]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  453.234044]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=70/256 MAYDAY
[  453.237353]     in-flight: 8900:xfs_end_io [xfs], 8932:xfs_end_io [xfs], 8897:xfs_end_io [xfs], 8910:xfs_end_io [xfs], 8929:xfs_end_io [xfs], 8917:xfs_end_io [xfs], 8899:xfs_end_io [xfs], 27:xfs_end_io [xfs], 8919:xfs_end_io [xfs], 8878:xfs_end_io [xfs], 8895:xfs_end_io [xfs], 56:xfs_end_io [xfs], 8882:xfs_end_io [xfs], 76:xfs_end_io [xfs], 8905:xfs_end_io [xfs], 8903:xfs_end_io [xfs]
[  453.253011]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  453.286151] , xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  453.294728]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=42/256 MAYDAY
[  453.298328]     in-flight: 8920:xfs_end_io [xfs], 109:xfs_end_io [xfs], 8926:xfs_end_io [xfs], 8928:xfs_end_io [xfs], 487:xfs_end_io [xfs], 8908:xfs_end_io [xfs], 19:xfs_end_io [xfs], 8881:xfs_end_io [xfs], 8894:xfs_end_io [xfs], 8911:xfs_end_io [xfs], 8916:xfs_end_io [xfs], 8884:xfs_end_io [xfs], 8914:xfs_end_io [xfs], 8931:xfs_end_io [xfs], 8901:xfs_end_io [xfs]
[  453.313755]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  453.335769]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=34/256 MAYDAY
[  453.339356]     in-flight: 8904:xfs_end_io [xfs], 8930:xfs_end_io [xfs], 41:xfs_end_io [xfs], 8893:xfs_end_io [xfs], 8885:xfs_end_io [xfs], 8907:xfs_end_io [xfs], 8880:xfs_end_io [xfs], 130:xfs_end_io [xfs], 8906:xfs_end_io [xfs], 8909:xfs_end_io [xfs], 8902:xfs_end_io [xfs], 8913:xfs_end_io [xfs], 8918:xfs_end_io [xfs], 3:xfs_end_io [xfs], 8898:xfs_end_io [xfs], 8923:xfs_end_io [xfs]
[  453.355817]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  453.371521] workqueue xfs-sync/sda1: flags=0x4
[  453.374366]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  453.377786]     pending: xfs_log_worker [xfs]
[  453.380584] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=70s workers=18 manager: 8925
[  453.384655] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=71s workers=16 manager: 51
[  453.388679] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=71s workers=17 manager: 8922
[  453.392772] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=71s workers=18 manager: 8886
[  453.397088] pool 128: cpus=0-63 flags=0x4 nice=0 hung=0s workers=3 idle: 378 376
[  453.601187] warn_alloc_stall: 3289 callbacks suppressed
[  453.604485] a.out: page allocation stalls for 70221ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  453.609361] a.out cpuset=/ mems_allowed=0
[  453.612053] a.out           D10920  8858   7853 0x00000080
[  453.615197] Call Trace:
[  453.617133]  __schedule+0x403/0x940
[  453.619578]  schedule+0x3d/0x90
[  453.621838]  schedule_timeout+0x23b/0x510
[  453.624330]  ? init_timer_on_stack_key+0x60/0x60
[  453.627109]  io_schedule_timeout+0x1e/0x50
[  453.629686]  ? io_schedule_timeout+0x1e/0x50
[  453.632317]  congestion_wait+0x86/0x210
[  453.634749]  ? remove_wait_queue+0x70/0x70
[  453.637276]  shrink_inactive_list+0x45e/0x590
[  453.639862]  ? __list_lru_count_one.isra.2+0x22/0x70
[  453.642698]  ? inactive_list_is_low+0x16b/0x300
[  453.645335]  shrink_node_memcg+0x378/0x750
[  453.647780]  shrink_node+0xe1/0x310
[  453.649964]  ? shrink_node+0xe1/0x310
[  453.652206]  do_try_to_free_pages+0xef/0x370
[  453.654608]  try_to_free_pages+0x12c/0x370
[  453.656962]  __alloc_pages_slowpath+0x4a8/0x11e0
[  453.659562]  ? balance_dirty_pages.isra.30+0x2c8/0x11e0
[  453.662349]  ? _raw_spin_unlock_irqrestore+0x5b/0x60
[  453.664928]  ? trace_hardirqs_on+0xd/0x10
[  453.667196]  ? get_page_from_freelist+0x1ae/0xe30
[  453.669675]  ? nr_free_buffer_pages+0x20/0x20
[  453.672030]  __alloc_pages_nodemask+0x2dd/0x390
[  453.674400]  alloc_pages_current+0xa1/0x1f0
[  453.676702]  __page_cache_alloc+0x148/0x180
[  453.678885]  filemap_fault+0x3dc/0x950
[  453.680910]  ? xfs_ilock+0x290/0x320 [xfs]
[  453.683085]  ? xfs_filemap_fault+0x5b/0x180 [xfs]
[  453.685488]  ? down_read_nested+0x73/0xb0
[  453.687586]  xfs_filemap_fault+0x63/0x180 [xfs]
[  453.689820]  __do_fault+0x1e/0x140
[  453.691700]  __handle_mm_fault+0xb96/0x10f0
[  453.693789]  handle_mm_fault+0x190/0x350
[  453.695730]  __do_page_fault+0x266/0x520
[  453.697860]  do_page_fault+0x30/0x80
[  453.699661]  page_fault+0x28/0x30
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
