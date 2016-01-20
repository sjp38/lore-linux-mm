Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0826B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 06:14:03 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id 65so3264453pff.2
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 03:14:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 22si54664575pfp.196.2016.01.20.03.14.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 03:14:02 -0800 (PST)
Subject: Re: [PATCH 1/3] mm, oom: rework oom detection
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<1450203586-10959-2-git-send-email-mhocko@kernel.org>
	<alpine.DEB.2.10.1601141436410.22665@chino.kir.corp.google.com>
	<201601161007.DDG56185.QOHMOFOLtSFJVF@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601191444520.7346@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1601191444520.7346@chino.kir.corp.google.com>
Message-Id: <201601202013.EHC65659.QOtOHLOFJVFFSM@I-love.SAKURA.ne.jp>
Date: Wed, 20 Jan 2016 20:13:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

David Rientjes wrote:
> Are you able to precisely identify why __zone_watermark_ok() is failing 
> and triggering the oom in the log you posted January 3?
> 
> [  154.829582] zone=DMA32 reclaimable=308907 available=312734 no_progress_loops=0 did_some_progress=50
> [  154.831562] zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=50
> // here //
> [  154.838499] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
> [  154.841167] fork cpuset=/ mems_allowed=0
> [  154.842348] CPU: 1 PID: 9599 Comm: fork Tainted: G        W       4.4.0-rc7-next-20151231+ #273
> ...
> [  154.852386] Call Trace:
> [  154.853350]  [<ffffffff81398b83>] dump_stack+0x4b/0x68
> [  154.854731]  [<ffffffff811bc81c>] dump_header+0x5b/0x3b0
> [  154.856309]  [<ffffffff810bdd79>] ? trace_hardirqs_on_caller+0xf9/0x1c0
> [  154.858046]  [<ffffffff810bde4d>] ? trace_hardirqs_on+0xd/0x10
> [  154.859593]  [<ffffffff81143d36>] oom_kill_process+0x366/0x540
> [  154.861142]  [<ffffffff8114414f>] out_of_memory+0x1ef/0x5a0
> [  154.862655]  [<ffffffff8114420d>] ? out_of_memory+0x2ad/0x5a0
> [  154.864194]  [<ffffffff81149c72>] __alloc_pages_nodemask+0xda2/0xde0
> [  154.865852]  [<ffffffff810bdd00>] ? trace_hardirqs_on_caller+0x80/0x1c0
> [  154.867844]  [<ffffffff81149e6c>] alloc_kmem_pages_node+0x4c/0xc0
> [  154.868726] zone=DMA32 reclaimable=309003 available=312677 no_progress_loops=0 did_some_progress=48
> [  154.868727] zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=48
> // and also here, if we didn't serialize the oom killer //
> 
> I think that would help in fixing the issue you reported.
> 
Does "why __zone_watermark_ok() is failing" mean "which 'return false;' statement
in __zone_watermark_ok() I'm hitting on my specific workload"? Then, answer is
the former for DMA zone and the latter for DMA32 zone.

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d70a80..dd36f01 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2390,7 +2390,7 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
  */
 static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 			unsigned long mark, int classzone_idx, int alloc_flags,
-			long free_pages)
+				long free_pages, bool *no_free)
 {
 	long min = mark;
 	int o;
@@ -2423,6 +2423,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 	 * are not met, then a high-order request also cannot go ahead
 	 * even if a suitable page happened to be free.
 	 */
+	*no_free = false;
 	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
 		return false;
 
@@ -2453,26 +2454,30 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 		}
 #endif
 	}
+	*no_free = true;
 	return false;
 }
 
 bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 		      int classzone_idx, int alloc_flags)
 {
+	bool unused;
+
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
-					zone_page_state(z, NR_FREE_PAGES));
+				   zone_page_state(z, NR_FREE_PAGES), &unused);
 }
 
 bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
 			unsigned long mark, int classzone_idx)
 {
+	bool unused;
 	long free_pages = zone_page_state(z, NR_FREE_PAGES);
 
 	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
 		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
 
 	return __zone_watermark_ok(z, order, mark, classzone_idx, 0,
-								free_pages);
+				   free_pages, &unused);
 }
 
 #ifdef CONFIG_NUMA
@@ -3014,7 +3019,7 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
 static inline bool
 should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		     struct alloc_context *ac, int alloc_flags,
-		     bool did_some_progress,
+		     unsigned long did_some_progress,
 		     int no_progress_loops)
 {
 	struct zone *zone;
@@ -3024,8 +3029,10 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 	 * Make sure we converge to OOM if we cannot make any progress
 	 * several times in the row.
 	 */
-	if (no_progress_loops > MAX_RECLAIM_RETRIES)
+	if (no_progress_loops > MAX_RECLAIM_RETRIES) {
+		printk(KERN_INFO "Reached MAX_RECLAIM_RETRIES.\n");
 		return false;
+	}
 
 	/* Do not retry high order allocations unless they are __GFP_REPEAT */
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
@@ -3039,6 +3046,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
 			ac->high_zoneidx, ac->nodemask) {
+		bool no_free;
 		unsigned long available;
 		unsigned long reclaimable;
 
@@ -3052,7 +3060,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		 * available?
 		 */
 		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
-				ac->high_zoneidx, alloc_flags, available)) {
+					ac->high_zoneidx, alloc_flags, available, &no_free)) {
 			unsigned long writeback;
 			unsigned long dirty;
 
@@ -3086,6 +3094,8 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 
 			return true;
 		}
+		printk(KERN_INFO "zone=%s reclaimable=%lu available=%lu no_progress_loops=%u did_some_progress=%lu nr_reserved_highatomic=%lu no_free=%u\n",
+		       zone->name, reclaimable, available, no_progress_loops, did_some_progress, zone->nr_reserved_highatomic, no_free);
 	}
 
 	return false;
@@ -3273,7 +3283,7 @@ retry:
 		no_progress_loops++;
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
-				 did_some_progress > 0, no_progress_loops))
+				 did_some_progress, no_progress_loops))
 		goto retry;
 
 	/* Reclaim has failed us, start killing things */
----------

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160120.txt.xz .
----------
[  141.987548] zone=DMA32 reclaimable=367085 available=371232 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0 no_free=1
[  141.990091] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0 no_free=0
[  141.997360] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  142.055908] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB active_anon:3208kB inactive_anon:188kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB\
 dirty:0kB writeback:0kB mapped:60kB shmem:188kB slab_reclaimable:2792kB slab_unreclaimable:360kB kernel_stack:224kB pagetables:260kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_\
unreclaimable? no
[  142.066690] lowmem_reserve[]: 0 1970 1970 1970

[  142.914557] zone=DMA32 reclaimable=345975 available=348821 no_progress_loops=0 did_some_progress=58 nr_reserved_highatomic=0 no_free=1
[  142.914558] zone=DMA reclaimable=2 available=1980 no_progress_loops=0 did_some_progress=58 nr_reserved_highatomic=0 no_free=0
[  142.921113] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  153.615466] zone=DMA32 reclaimable=385567 available=389678 no_progress_loops=0 did_some_progress=36 nr_reserved_highatomic=0 no_free=1
[  153.615467] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=36 nr_reserved_highatomic=0 no_free=0
[  153.620507] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  153.658621] zone=DMA32 reclaimable=384064 available=388833 no_progress_loops=0 did_some_progress=37 nr_reserved_highatomic=0 no_free=1
[  153.658623] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=37 nr_reserved_highatomic=0 no_free=0
[  153.663401] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  159.614894] zone=DMA32 reclaimable=356635 available=361925 no_progress_loops=0 did_some_progress=32 nr_reserved_highatomic=0 no_free=1
[  159.614895] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=32 nr_reserved_highatomic=0 no_free=0
[  159.622374] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  164.781516] zone=DMA32 reclaimable=393457 available=397561 no_progress_loops=0 did_some_progress=40 nr_reserved_highatomic=0 no_free=1
[  164.781518] zone=DMA reclaimable=1 available=1983 no_progress_loops=0 did_some_progress=40 nr_reserved_highatomic=0 no_free=0
[  164.786560] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  171.006952] zone=DMA32 reclaimable=405821 available=410137 no_progress_loops=0 did_some_progress=34 nr_reserved_highatomic=0 no_free=1
[  171.006954] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=34 nr_reserved_highatomic=0 no_free=0
[  171.010690] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  171.030121] zone=DMA32 reclaimable=405016 available=409801 no_progress_loops=0 did_some_progress=34 nr_reserved_highatomic=0 no_free=1
[  171.030123] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=34 nr_reserved_highatomic=0 no_free=0
[  171.033530] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  184.631660] zone=DMA32 reclaimable=356652 available=359338 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0 no_free=1
[  184.634207] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=60 nr_reserved_highatomic=0 no_free=0
[  184.642800] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  190.499877] zone=DMA32 reclaimable=382152 available=384996 no_progress_loops=0 did_some_progress=32 nr_reserved_highatomic=0 no_free=1
[  190.499878] zone=DMA reclaimable=2 available=1983 no_progress_loops=0 did_some_progress=32 nr_reserved_highatomic=0 no_free=0
[  190.504901] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  196.146728] zone=DMA32 reclaimable=371941 available=374605 no_progress_loops=0 did_some_progress=61 nr_reserved_highatomic=0 no_free=1
[  196.146730] zone=DMA reclaimable=1 available=1982 no_progress_loops=0 did_some_progress=61 nr_reserved_highatomic=0 no_free=0
[  196.152546] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  201.837825] zone=DMA32 reclaimable=364569 available=370359 no_progress_loops=0 did_some_progress=59 nr_reserved_highatomic=0 no_free=1
[  201.837826] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=59 nr_reserved_highatomic=0 no_free=0
[  201.844879] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  212.862325] zone=DMA32 reclaimable=381542 available=387785 no_progress_loops=0 did_some_progress=39 nr_reserved_highatomic=0 no_free=1
[  212.862327] zone=DMA reclaimable=2 available=1982 no_progress_loops=0 did_some_progress=39 nr_reserved_highatomic=0 no_free=0
[  212.866857] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)

[  212.866914] Node 0 DMA free:7920kB min:40kB low:48kB high:60kB active_anon:440kB inactive_anon:196kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB \
dirty:8kB writeback:0kB mapped:0kB shmem:280kB slab_reclaimable:480kB slab_unreclaimable:3856kB kernel_stack:1776kB pagetables:240kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_u\
nreclaimable? no
[  212.866915] lowmem_reserve[]: 0 1970 1970 1970
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
