Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id E4DF06B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:26:07 -0400 (EDT)
Received: by oiar126 with SMTP id r126so37432998oia.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:26:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m67si9047326oia.134.2015.10.12.08.26.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 08:26:06 -0700 (PDT)
Subject: Silent hang up caused by pages being not scanned?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
	<201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
	<201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
In-Reply-To: <201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
Message-Id: <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
Date: Tue, 13 Oct 2015 00:25:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Tetsuo Handa wrote:
> Uptime between 101 and 300 is a silent hang up (i.e. no OOM killer messages,
> no SIGKILL pending tasks, no TIF_MEMDIE tasks) which I solved using SysRq-f
> at uptime = 289. I don't know the reason of this silent hang up, but the
> memory unzapping kernel thread will not help because there is no OOM victim.
> 
> ----------
> [  101.438951] MemAlloc-Info: 10 stalling task, 0 dying task, 0 victim task.
> (...snipped...)
> [  111.817922] MemAlloc-Info: 12 stalling task, 0 dying task, 0 victim task.
> (...snipped...)
> [  122.281828] MemAlloc-Info: 13 stalling task, 0 dying task, 0 victim task.
> (...snipped...)
> [  132.793724] MemAlloc-Info: 14 stalling task, 0 dying task, 0 victim task.
> (...snipped...)
> [  143.336154] MemAlloc-Info: 16 stalling task, 0 dying task, 0 victim task.
> (...snipped...)
> [  289.343187] sysrq: SysRq : Manual OOM execution
> (...snipped...)
> [  292.065650] MemAlloc-Info: 16 stalling task, 0 dying task, 0 victim task.
> (...snipped...)
> [  302.590736] kworker/3:2 invoked oom-killer: gfp_mask=0x24000c0, order=-1, oom_score_adj=0
> (...snipped...)
> [  302.690047] MemAlloc-Info: 4 stalling task, 0 dying task, 0 victim task.
> ----------

I examined this hang up using additional debug printk() patch. And it was
observed that when this silent hang up occurs, zone_reclaimable() called from
shrink_zones() called from a __GFP_FS memory allocation request is returning
true forever. Since the __GFP_FS memory allocation request can never call
out_of_memory() due to did_some_progree > 0, the system will silently hang up
with 100% CPU usage.

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0473eec..fda0bb5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2821,6 +2821,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 }
 #endif /* CONFIG_COMPACTION */
 
+pid_t dump_target_pid;
+
 /* Perform direct synchronous page reclaim */
 static int
 __perform_reclaim(gfp_t gfp_mask, unsigned int order,
@@ -2847,6 +2849,9 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 
 	cond_resched();
 
+	if (dump_target_pid == current->pid)
+		printk(KERN_INFO "__perform_reclaim returned %u at line %u\n",
+		       progress, __LINE__);
 	return progress;
 }
 
@@ -3007,6 +3012,7 @@ static int malloc_watchdog(void *unused)
 	unsigned int memdie_pending;
 	unsigned int stalling_tasks;
 	u8 index;
+	pid_t pid;
 
  not_stalling: /* Healty case. */
 	/*
@@ -3025,12 +3031,16 @@ static int malloc_watchdog(void *unused)
 	 * and stop_memalloc_timer() within timeout duration.
 	 */
 	if (likely(!memalloc_counter[index]))
+	{
+		dump_target_pid = 0;
 		goto not_stalling;
+	}
  maybe_stalling: /* Maybe something is wrong. Let's check. */
 	/* First, report whether there are SIGKILL tasks and/or OOM victims. */
 	sigkill_pending = 0;
 	memdie_pending = 0;
 	stalling_tasks = 0;
+	pid = 0;
 	preempt_disable();
 	rcu_read_lock();
 	for_each_process_thread(g, p) {
@@ -3062,8 +3072,11 @@ static int malloc_watchdog(void *unused)
 			(fatal_signal_pending(p) ? "-dying" : ""),
 			p->comm, p->pid, m->gfp, m->order, spent);
 		show_stack(p, NULL);
+		if (!pid && (m->gfp & __GFP_FS))
+			pid = p->pid;
 	}
 	spin_unlock(&memalloc_list_lock);
+	dump_target_pid = -pid;
 	/* Wait until next timeout duration. */
 	schedule_timeout_interruptible(timeout);
 	if (memalloc_counter[index])
@@ -3155,6 +3168,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 retry:
+	if (dump_target_pid == -current->pid)
+		dump_target_pid = -dump_target_pid;
+
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
@@ -3280,6 +3296,11 @@ retry:
 		goto noretry;
 
 	/* Keep reclaiming pages as long as there is reasonable progress */
+	if (dump_target_pid == current->pid) {
+		printk(KERN_INFO "did_some_progress=%lu at line %u\n",
+		       did_some_progress, __LINE__);
+		dump_target_pid = 0;
+	}
 	pages_reclaimed += did_some_progress;
 	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
 	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 27d580b..cb0c22e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2527,6 +2527,8 @@ static inline bool compaction_ready(struct zone *zone, int order)
 	return watermark_ok;
 }
 
+extern pid_t dump_target_pid;
+
 /*
  * This is the direct reclaim path, for page-allocating processes.  We only
  * try to reclaim pages from zones which will satisfy the caller's allocation
@@ -2619,16 +2621,41 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			sc->nr_reclaimed += nr_soft_reclaimed;
 			sc->nr_scanned += nr_soft_scanned;
 			if (nr_soft_reclaimed)
+			{
+				if (dump_target_pid == current->pid)
+					printk(KERN_INFO "nr_soft_reclaimed=%lu at line %u\n",
+					       nr_soft_reclaimed, __LINE__);
 				reclaimable = true;
+			}
 			/* need some check for avoid more shrink_zone() */
 		}
 
 		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
+		{
+			if (dump_target_pid == current->pid)
+				printk(KERN_INFO "shrink_zone returned 1 at line %u\n",
+				       __LINE__);
 			reclaimable = true;
+		}
 
 		if (global_reclaim(sc) &&
 		    !reclaimable && zone_reclaimable(zone))
+		{
+			if (dump_target_pid == current->pid) {
+				printk(KERN_INFO "zone_reclaimable returned 1 at line %u\n",
+				       __LINE__);
+				printk(KERN_INFO "(ACTIVE_FILE=%lu+INACTIVE_FILE=%lu",
+				       zone_page_state(zone, NR_ACTIVE_FILE),
+				       zone_page_state(zone, NR_INACTIVE_FILE));
+				if (get_nr_swap_pages() > 0)
+					printk(KERN_CONT "+ACTIVE_ANON=%lu+INACTIVE_ANON=%lu",
+					       zone_page_state(zone, NR_ACTIVE_ANON),
+					       zone_page_state(zone, NR_INACTIVE_ANON));
+				printk(KERN_CONT ") * 6 > PAGES_SCANNED=%lu\n",
+				       zone_page_state(zone, NR_PAGES_SCANNED));
+			}
 			reclaimable = true;
+		}
 	}
 
 	/*
@@ -2674,6 +2701,9 @@ retry:
 				sc->priority);
 		sc->nr_scanned = 0;
 		zones_reclaimable = shrink_zones(zonelist, sc);
+		if (dump_target_pid == current->pid)
+			printk(KERN_INFO "shrink_zones returned %u at line %u\n",
+			       zones_reclaimable, __LINE__);
 
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -2707,11 +2737,21 @@ retry:
 	delayacct_freepages_end();
 
 	if (sc->nr_reclaimed)
+	{
+		if (dump_target_pid == current->pid)
+			printk(KERN_INFO "sc->nr_reclaimed=%lu at line %u\n",
+			       sc->nr_reclaimed, __LINE__);
 		return sc->nr_reclaimed;
+	}
 
 	/* Aborted reclaim to try compaction? don't OOM, then */
 	if (sc->compaction_ready)
+	{
+		if (dump_target_pid == current->pid)
+			printk(KERN_INFO "sc->compaction_ready=%u at line %u\n",
+			       sc->compaction_ready, __LINE__);
 		return 1;
+	}
 
 	/* Untapped cgroup reserves?  Don't OOM, retry. */
 	if (!sc->may_thrash) {
@@ -2720,6 +2760,9 @@ retry:
 		goto retry;
 	}
 
+	if (dump_target_pid == current->pid)
+		printk(KERN_INFO "zones_reclaimable=%u at line %u\n",
+		       zones_reclaimable, __LINE__);
 	/* Any of the zones still reclaimable?  Don't OOM. */
 	if (zones_reclaimable)
 		return 1;
@@ -2875,7 +2918,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	 * point.
 	 */
 	if (throttle_direct_reclaim(gfp_mask, zonelist, nodemask))
+	{
+		if (dump_target_pid == current->pid)
+			printk(KERN_INFO "throttle_direct_reclaim returned 1 at line %u\n",
+			       __LINE__);
 		return 1;
+	}
 
 	trace_mm_vmscan_direct_reclaim_begin(order,
 				sc.may_writepage,
@@ -2885,6 +2933,9 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 
 	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
 
+	if (dump_target_pid == current->pid)
+		printk(KERN_INFO "do_try_to_free_pages returned %lu at line %u\n",
+		       nr_reclaimed, __LINE__);
 	return nr_reclaimed;
 }
 
----------

What is strange, the values printed by this debug printk() patch did not
change as time went by. Thus, I think that this is not a problem of lack of
CPU time for scanning pages. I suspect that there is a bug that nobody is
scanning pages.

----------
[   66.821450] zone_reclaimable returned 1 at line 2646
[   66.823020] (ACTIVE_FILE=26+INACTIVE_FILE=10) * 6 > PAGES_SCANNED=32
[   66.824935] shrink_zones returned 1 at line 2706
[   66.826392] zones_reclaimable=1 at line 2765
[   66.827865] do_try_to_free_pages returned 1 at line 2938
[   67.102322] __perform_reclaim returned 1 at line 2854
[   67.103968] did_some_progress=1 at line 3301
(...snipped...)
[  281.439977] zone_reclaimable returned 1 at line 2646
[  281.439977] (ACTIVE_FILE=26+INACTIVE_FILE=10) * 6 > PAGES_SCANNED=32
[  281.439978] shrink_zones returned 1 at line 2706
[  281.439978] zones_reclaimable=1 at line 2765
[  281.439979] do_try_to_free_pages returned 1 at line 2938
[  281.439979] __perform_reclaim returned 1 at line 2854
[  281.439980] did_some_progress=1 at line 3301
----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20151013.txt.xz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
