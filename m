Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3900590014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 02:41:25 -0400 (EDT)
Subject: [patch]mm: fix a vmscan warning
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 01 Aug 2011 14:41:17 +0800
Message-ID: <1312180877.15392.426.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I get below warnning:
BUG: using smp_processor_id() in preemptible [00000000] code: bash/746
caller is native_sched_clock+0x37/0x6e
Pid: 746, comm: bash Tainted: G        W   3.0.0+ #254
Call Trace:
 [<ffffffff813435c6>] debug_smp_processor_id+0xc2/0xdc
 [<ffffffff8104158d>] native_sched_clock+0x37/0x6e
 [<ffffffff81116219>] try_to_free_mem_cgroup_pages+0x7d/0x270
 [<ffffffff8114f1f8>] mem_cgroup_force_empty+0x24b/0x27a
 [<ffffffff8114ff21>] ? sys_close+0x38/0x138
 [<ffffffff8114ff21>] ? sys_close+0x38/0x138
 [<ffffffff8114f257>] mem_cgroup_force_empty_write+0x17/0x19
 [<ffffffff810c72fb>] cgroup_file_write+0xa8/0xba
 [<ffffffff811522d2>] vfs_write+0xb3/0x138
 [<ffffffff8115241a>] sys_write+0x4a/0x71
 [<ffffffff8114ffd9>] ? sys_close+0xf0/0x138
 [<ffffffff8176deab>] system_call_fastpath+0x16/0x1b

sched_clock() can't be used with preempt enabled. And we don't
need fast approach to get clock here, so let's use ktime API.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7ef6912..22631e0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2283,7 +2283,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.mem_cgroup = mem,
 		.memcg_record = rec,
 	};
-	unsigned long start, end;
+	ktime_t start, end;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2292,7 +2292,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						      sc.may_writepage,
 						      sc.gfp_mask);
 
-	start = sched_clock();
+	start = ktime_get();
 	/*
 	 * NOTE: Although we can get the priority field, using it
 	 * here is not a good idea, since it limits the pages we can scan.
@@ -2301,10 +2301,10 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 	 * the priority and make it zero.
 	 */
 	shrink_zone(0, zone, &sc);
-	end = sched_clock();
+	end = ktime_get();
 
 	if (rec)
-		rec->elapsed += end - start;
+		rec->elapsed += ktime_to_ns(ktime_sub(end, start));
 	*scanned = sc.nr_scanned;
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
@@ -2319,7 +2319,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
-	unsigned long start, end;
+	ktime_t start, end;
 	int nid;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
@@ -2337,7 +2337,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.gfp_mask = sc.gfp_mask,
 	};
 
-	start = sched_clock();
+	start = ktime_get();
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
 	 * take care of from where we get pages. So the node where we start the
@@ -2352,9 +2352,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					    sc.gfp_mask);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
-	end = sched_clock();
+	end = ktime_get();
 	if (rec)
-		rec->elapsed += end - start;
+		rec->elapsed += ktime_to_ns(ktime_sub(end, start));
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
