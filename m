Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 387DE6B02AD
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:24:20 -0400 (EDT)
Received: by qgez61 with SMTP id z61so17118495qge.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:20 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id p202si1852686qha.79.2015.05.22.15.24.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:24:13 -0700 (PDT)
Received: by qgfa63 with SMTP id a63so17137335qgf.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:13 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 18/19] writeback: implement memcg writeback domain based throttling
Date: Fri, 22 May 2015 18:23:35 -0400
Message-Id: <1432333416-6221-19-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

While cgroup writeback support now connects memcg and blkcg so that
writeback IOs are properly attributed and controlled, the IO back
pressure propagation mechanism implemented in balance_dirty_pages()
and its subroutines wasn't aware of cgroup writeback.

Processes belonging to a memcg may have access to only subset of total
memory available in the system and not factoring this into dirty
throttling rendered it completely ineffective for processes under
memcg limits and memcg ended up building a separate ad-hoc degenerate
mechanism directly into vmscan code to limit page dirtying.

The previous patches updated balance_dirty_pages() and its subroutines
so that they can deal with multiple wb_domain's (writeback domains)
and defined per-memcg wb_domain.  Processes belonging to a non-root
memcg are bound to two wb_domains, global wb_domain and memcg
wb_domain, and should be throttled according to IO pressures from both
domains.  This patch updates dirty throttling code so that it repeats
similar calculations for the two domains - the differences between the
two are few and minor - and applies the lower of the two sets of
resulting constraints.

wb_over_bg_thresh(), which controls when background writeback
terminates, is also updated to consider both global and memcg
wb_domains.  It returns true if dirty is over bg_thresh for either
domain.

This makes the dirty throttling mechanism operational for memcg
domains including writeback-bandwidth-proportional dirty page
distribution inside them but the ad-hoc memcg throttling mechanism in
vmscan is still in place.  The next patch will rip it out.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h |   9 +++
 mm/memcontrol.c            |  43 ++++++++++++
 mm/page-writeback.c        | 158 ++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 188 insertions(+), 22 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e3177be..c3eb19e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -392,6 +392,8 @@ enum {
 
 struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg);
 struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb);
+void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pavail,
+			 unsigned long *pdirty, unsigned long *pwriteback);
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
@@ -400,6 +402,13 @@ static inline struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
 	return NULL;
 }
 
+static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
+				       unsigned long *pavail,
+				       unsigned long *pdirty,
+				       unsigned long *pwriteback)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 struct sock;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8fbd501..7bde293 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4001,6 +4001,49 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
 	return &memcg->cgwb_domain;
 }
 
+/**
+ * mem_cgroup_wb_stats - retrieve writeback related stats from its memcg
+ * @wb: bdi_writeback in question
+ * @pavail: out parameter for number of available pages
+ * @pdirty: out parameter for number of dirty pages
+ * @pwriteback: out parameter for number of pages under writeback
+ *
+ * Determine the numbers of available, dirty, and writeback pages in @wb's
+ * memcg.  Dirty and writeback are self-explanatory.  Available is a bit
+ * more involved.
+ *
+ * A memcg's headroom is "min(max, high) - used".  The available memory is
+ * calculated as the lowest headroom of itself and the ancestors plus the
+ * number of pages already being used for file pages.  Note that this
+ * doesn't consider the actual amount of available memory in the system.
+ * The caller should further cap *@pavail accordingly.
+ */
+void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pavail,
+			 unsigned long *pdirty, unsigned long *pwriteback)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
+	struct mem_cgroup *parent;
+	unsigned long head_room = PAGE_COUNTER_MAX;
+	unsigned long file_pages;
+
+	*pdirty = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_DIRTY);
+
+	/* this should eventually include NR_UNSTABLE_NFS */
+	*pwriteback = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
+
+	file_pages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
+						    (1 << LRU_ACTIVE_FILE));
+	while ((parent = parent_mem_cgroup(memcg))) {
+		unsigned long ceiling = min(memcg->memory.limit, memcg->high);
+		unsigned long used = page_counter_read(&memcg->memory);
+
+		head_room = min(head_room, ceiling - min(ceiling, used));
+		memcg = parent;
+	}
+
+	*pavail = file_pages + head_room;
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static int memcg_wb_domain_init(struct mem_cgroup *memcg, gfp_t gfp)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index a146e33..e890335 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -160,6 +160,14 @@ struct dirty_throttle_control {
 #define GDTC_INIT(__wb)		.dom = &global_wb_domain,		\
 				DTC_INIT_COMMON(__wb)
 #define GDTC_INIT_NO_WB		.dom = &global_wb_domain
+#define MDTC_INIT(__wb, __gdtc)	.dom = mem_cgroup_wb_domain(__wb),	\
+				.gdtc = __gdtc,				\
+				DTC_INIT_COMMON(__wb)
+
+static bool mdtc_valid(struct dirty_throttle_control *dtc)
+{
+	return dtc->dom;
+}
 
 static struct wb_domain *dtc_dom(struct dirty_throttle_control *dtc)
 {
@@ -207,6 +215,12 @@ static void wb_min_max_ratio(struct bdi_writeback *wb,
 
 #define GDTC_INIT(__wb)		DTC_INIT_COMMON(__wb)
 #define GDTC_INIT_NO_WB
+#define MDTC_INIT(__wb, __gdtc)
+
+static bool mdtc_valid(struct dirty_throttle_control *dtc)
+{
+	return false;
+}
 
 static struct wb_domain *dtc_dom(struct dirty_throttle_control *dtc)
 {
@@ -668,6 +682,15 @@ static unsigned long hard_dirty_limit(struct wb_domain *dom,
 	return max(thresh, dom->dirty_limit);
 }
 
+/* memory available to a memcg domain is capped by system-wide clean memory */
+static void mdtc_cap_avail(struct dirty_throttle_control *mdtc)
+{
+	struct dirty_throttle_control *gdtc = mdtc_gdtc(mdtc);
+	unsigned long clean = gdtc->avail - min(gdtc->avail, gdtc->dirty);
+
+	mdtc->avail = min(mdtc->avail, clean);
+}
+
 /**
  * __wb_calc_thresh - @wb's share of dirty throttling threshold
  * @dtc: dirty_throttle_context of interest
@@ -1269,11 +1292,12 @@ static void wb_update_dirty_ratelimit(struct dirty_throttle_control *dtc,
 	trace_bdi_dirty_ratelimit(wb->bdi, dirty_rate, task_ratelimit);
 }
 
-static void __wb_update_bandwidth(struct dirty_throttle_control *dtc,
+static void __wb_update_bandwidth(struct dirty_throttle_control *gdtc,
+				  struct dirty_throttle_control *mdtc,
 				  unsigned long start_time,
 				  bool update_ratelimit)
 {
-	struct bdi_writeback *wb = dtc->wb;
+	struct bdi_writeback *wb = gdtc->wb;
 	unsigned long now = jiffies;
 	unsigned long elapsed = now - wb->bw_time_stamp;
 	unsigned long dirtied;
@@ -1298,8 +1322,17 @@ static void __wb_update_bandwidth(struct dirty_throttle_control *dtc,
 		goto snapshot;
 
 	if (update_ratelimit) {
-		domain_update_bandwidth(dtc, now);
-		wb_update_dirty_ratelimit(dtc, dirtied, elapsed);
+		domain_update_bandwidth(gdtc, now);
+		wb_update_dirty_ratelimit(gdtc, dirtied, elapsed);
+
+		/*
+		 * @mdtc is always NULL if !CGROUP_WRITEBACK but the
+		 * compiler has no way to figure that out.  Help it.
+		 */
+		if (IS_ENABLED(CONFIG_CGROUP_WRITEBACK) && mdtc) {
+			domain_update_bandwidth(mdtc, now);
+			wb_update_dirty_ratelimit(mdtc, dirtied, elapsed);
+		}
 	}
 	wb_update_write_bandwidth(wb, elapsed, written);
 
@@ -1313,7 +1346,7 @@ void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time)
 {
 	struct dirty_throttle_control gdtc = { GDTC_INIT(wb) };
 
-	__wb_update_bandwidth(&gdtc, start_time, false);
+	__wb_update_bandwidth(&gdtc, NULL, start_time, false);
 }
 
 /*
@@ -1480,7 +1513,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 				unsigned long pages_dirtied)
 {
 	struct dirty_throttle_control gdtc_stor = { GDTC_INIT(wb) };
+	struct dirty_throttle_control mdtc_stor = { MDTC_INIT(wb, &gdtc_stor) };
 	struct dirty_throttle_control * const gdtc = &gdtc_stor;
+	struct dirty_throttle_control * const mdtc = mdtc_valid(&mdtc_stor) ?
+						     &mdtc_stor : NULL;
+	struct dirty_throttle_control *sdtc;
 	unsigned long nr_reclaimable;	/* = file_dirty + unstable_nfs */
 	long period;
 	long pause;
@@ -1497,6 +1534,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	for (;;) {
 		unsigned long now = jiffies;
 		unsigned long dirty, thresh, bg_thresh;
+		unsigned long m_dirty, m_thresh, m_bg_thresh;
 
 		/*
 		 * Unstable writes are a feature of certain networked
@@ -1523,6 +1561,32 @@ static void balance_dirty_pages(struct address_space *mapping,
 			bg_thresh = gdtc->bg_thresh;
 		}
 
+		if (mdtc) {
+			unsigned long writeback;
+
+			/*
+			 * If @wb belongs to !root memcg, repeat the same
+			 * basic calculations for the memcg domain.
+			 */
+			mem_cgroup_wb_stats(wb, &mdtc->avail, &mdtc->dirty,
+					    &writeback);
+			mdtc_cap_avail(mdtc);
+			mdtc->dirty += writeback;
+
+			domain_dirty_limits(mdtc);
+
+			if (unlikely(strictlimit)) {
+				wb_dirty_limits(mdtc);
+				m_dirty = mdtc->wb_dirty;
+				m_thresh = mdtc->wb_thresh;
+				m_bg_thresh = mdtc->wb_bg_thresh;
+			} else {
+				m_dirty = mdtc->dirty;
+				m_thresh = mdtc->thresh;
+				m_bg_thresh = mdtc->bg_thresh;
+			}
+		}
+
 		/*
 		 * Throttle it only when the background writeback cannot
 		 * catch-up. This avoids (excessively) small writeouts
@@ -1531,18 +1595,31 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * In strictlimit case make decision based on the wb counters
 		 * and limits. Small writeouts when the wb limits are ramping
 		 * up are the price we consciously pay for strictlimit-ing.
+		 *
+		 * If memcg domain is in effect, @dirty should be under
+		 * both global and memcg freerun ceilings.
 		 */
-		if (dirty <= dirty_freerun_ceiling(thresh, bg_thresh)) {
+		if (dirty <= dirty_freerun_ceiling(thresh, bg_thresh) &&
+		    (!mdtc ||
+		     m_dirty <= dirty_freerun_ceiling(m_thresh, m_bg_thresh))) {
+			unsigned long intv = dirty_poll_interval(dirty, thresh);
+			unsigned long m_intv = ULONG_MAX;
+
 			current->dirty_paused_when = now;
 			current->nr_dirtied = 0;
-			current->nr_dirtied_pause =
-				dirty_poll_interval(dirty, thresh);
+			if (mdtc)
+				m_intv = dirty_poll_interval(m_dirty, m_thresh);
+			current->nr_dirtied_pause = min(intv, m_intv);
 			break;
 		}
 
 		if (unlikely(!writeback_in_progress(wb)))
 			wb_start_background_writeback(wb);
 
+		/*
+		 * Calculate global domain's pos_ratio and select the
+		 * global dtc by default.
+		 */
 		if (!strictlimit)
 			wb_dirty_limits(gdtc);
 
@@ -1550,6 +1627,25 @@ static void balance_dirty_pages(struct address_space *mapping,
 			((gdtc->dirty > gdtc->thresh) || strictlimit);
 
 		wb_position_ratio(gdtc);
+		sdtc = gdtc;
+
+		if (mdtc) {
+			/*
+			 * If memcg domain is in effect, calculate its
+			 * pos_ratio.  @wb should satisfy constraints from
+			 * both global and memcg domains.  Choose the one
+			 * w/ lower pos_ratio.
+			 */
+			if (!strictlimit)
+				wb_dirty_limits(mdtc);
+
+			dirty_exceeded |= (mdtc->wb_dirty > mdtc->wb_thresh) &&
+				((mdtc->dirty > mdtc->thresh) || strictlimit);
+
+			wb_position_ratio(mdtc);
+			if (mdtc->pos_ratio < gdtc->pos_ratio)
+				sdtc = mdtc;
+		}
 
 		if (dirty_exceeded && !wb->dirty_exceeded)
 			wb->dirty_exceeded = 1;
@@ -1557,14 +1653,15 @@ static void balance_dirty_pages(struct address_space *mapping,
 		if (time_is_before_jiffies(wb->bw_time_stamp +
 					   BANDWIDTH_INTERVAL)) {
 			spin_lock(&wb->list_lock);
-			__wb_update_bandwidth(gdtc, start_time, true);
+			__wb_update_bandwidth(gdtc, mdtc, start_time, true);
 			spin_unlock(&wb->list_lock);
 		}
 
+		/* throttle according to the chosen dtc */
 		dirty_ratelimit = wb->dirty_ratelimit;
-		task_ratelimit = ((u64)dirty_ratelimit * gdtc->pos_ratio) >>
+		task_ratelimit = ((u64)dirty_ratelimit * sdtc->pos_ratio) >>
 							RATELIMIT_CALC_SHIFT;
-		max_pause = wb_max_pause(wb, gdtc->wb_dirty);
+		max_pause = wb_max_pause(wb, sdtc->wb_dirty);
 		min_pause = wb_min_pause(wb, max_pause,
 					 task_ratelimit, dirty_ratelimit,
 					 &nr_dirtied_pause);
@@ -1587,11 +1684,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 */
 		if (pause < min_pause) {
 			trace_balance_dirty_pages(bdi,
-						  gdtc->thresh,
-						  gdtc->bg_thresh,
-						  gdtc->dirty,
-						  gdtc->wb_thresh,
-						  gdtc->wb_dirty,
+						  sdtc->thresh,
+						  sdtc->bg_thresh,
+						  sdtc->dirty,
+						  sdtc->wb_thresh,
+						  sdtc->wb_dirty,
 						  dirty_ratelimit,
 						  task_ratelimit,
 						  pages_dirtied,
@@ -1616,11 +1713,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 
 pause:
 		trace_balance_dirty_pages(bdi,
-					  gdtc->thresh,
-					  gdtc->bg_thresh,
-					  gdtc->dirty,
-					  gdtc->wb_thresh,
-					  gdtc->wb_dirty,
+					  sdtc->thresh,
+					  sdtc->bg_thresh,
+					  sdtc->dirty,
+					  sdtc->wb_thresh,
+					  sdtc->wb_dirty,
 					  dirty_ratelimit,
 					  task_ratelimit,
 					  pages_dirtied,
@@ -1651,7 +1748,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * more page. However wb_dirty has accounting errors.  So use
 		 * the larger and more IO friendly wb_stat_error.
 		 */
-		if (gdtc->wb_dirty <= wb_stat_error(wb))
+		if (sdtc->wb_dirty <= wb_stat_error(wb))
 			break;
 
 		if (fatal_signal_pending(current))
@@ -1775,7 +1872,10 @@ EXPORT_SYMBOL(balance_dirty_pages_ratelimited);
 bool wb_over_bg_thresh(struct bdi_writeback *wb)
 {
 	struct dirty_throttle_control gdtc_stor = { GDTC_INIT(wb) };
+	struct dirty_throttle_control mdtc_stor = { MDTC_INIT(wb, &gdtc_stor) };
 	struct dirty_throttle_control * const gdtc = &gdtc_stor;
+	struct dirty_throttle_control * const mdtc = mdtc_valid(&mdtc_stor) ?
+						     &mdtc_stor : NULL;
 
 	/*
 	 * Similar to balance_dirty_pages() but ignores pages being written
@@ -1792,6 +1892,20 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 	if (wb_stat(wb, WB_RECLAIMABLE) > __wb_calc_thresh(gdtc))
 		return true;
 
+	if (mdtc) {
+		unsigned long writeback;
+
+		mem_cgroup_wb_stats(wb, &mdtc->avail, &mdtc->dirty, &writeback);
+		mdtc_cap_avail(mdtc);
+		domain_dirty_limits(mdtc);	/* ditto, ignore writeback */
+
+		if (mdtc->dirty > mdtc->bg_thresh)
+			return true;
+
+		if (wb_stat(wb, WB_RECLAIMABLE) > __wb_calc_thresh(mdtc))
+			return true;
+	}
+
 	return false;
 }
 
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
