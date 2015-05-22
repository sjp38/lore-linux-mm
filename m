Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4585B6B02AD
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:24:22 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so23391576qkg.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:22 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id 184si635361qhy.54.2015.05.22.15.24.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:24:15 -0700 (PDT)
Received: by qgez61 with SMTP id z61so17117683qge.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:15 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 19/19] mm: vmscan: disable memcg direct reclaim stalling if cgroup writeback support is in use
Date: Fri, 22 May 2015 18:23:36 -0400
Message-Id: <1432333416-6221-20-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>

Because writeback wasn't cgroup aware before, the usual dirty
throttling mechanism in balance_dirty_pages() didn't work for
processes under memcg limit.  The writeback path didn't know how much
memory is available or how fast the dirty pages are being written out
for a given memcg and balance_dirty_pages() didn't have any measure of
IO back pressure for the memcg.

To work around the issue, memcg implemented an ad-hoc dirty throttling
mechanism in the direct reclaim path by stalling on pages under
writeback which are encountered during direct reclaim scan.  This is
rather ugly and crude - none of the configurability, fairness, or
bandwidth-proportional distribution of the normal path.

The previous patches implemented proper memcg aware dirty throttling
when cgroup writeback is in use making the ad-hoc mechanism
unnecessary.  This patch disables direct reclaim stalling for such
case.

Note: I disabled the parts which seemed obvious and it behaves fine
      while testing but my understanding of this code path is
      rudimentary and it's quite possible that I got something wrong.
      Please let me know if I got some wrong or more global_reclaim()
      sites should be updated.

v2: The original patch removed the direct stalling mechanism which
    breaks legacy hierarchies.  Conditionalize instead of removing.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/vmscan.c | 51 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 41 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f463398..8cb16eb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -154,11 +154,42 @@ static bool global_reclaim(struct scan_control *sc)
 {
 	return !sc->target_mem_cgroup;
 }
+
+/**
+ * sane_reclaim - is the usual dirty throttling mechanism operational?
+ * @sc: scan_control in question
+ *
+ * The normal page dirty throttling mechanism in balance_dirty_pages() is
+ * completely broken with the legacy memcg and direct stalling in
+ * shrink_page_list() is used for throttling instead, which lacks all the
+ * niceties such as fairness, adaptive pausing, bandwidth proportional
+ * allocation and configurability.
+ *
+ * This function tests whether the vmscan currently in progress can assume
+ * that the normal dirty throttling mechanism is operational.
+ */
+static bool sane_reclaim(struct scan_control *sc)
+{
+	struct mem_cgroup *memcg = sc->target_mem_cgroup;
+
+	if (!memcg)
+		return true;
+#ifdef CONFIG_CGROUP_WRITEBACK
+	if (cgroup_on_dfl(mem_cgroup_css(memcg)->cgroup))
+		return true;
+#endif
+	return false;
+}
 #else
 static bool global_reclaim(struct scan_control *sc)
 {
 	return true;
 }
+
+static bool sane_reclaim(struct scan_control *sc)
+{
+	return true;
+}
 #endif
 
 static unsigned long zone_reclaimable_pages(struct zone *zone)
@@ -941,10 +972,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 *    note that the LRU is being scanned too quickly and the
 		 *    caller can stall after page list has been processed.
 		 *
-		 * 2) Global reclaim encounters a page, memcg encounters a
-		 *    page that is not marked for immediate reclaim or
-		 *    the caller does not have __GFP_IO. In this case mark
-		 *    the page for immediate reclaim and continue scanning.
+		 * 2) Global or new memcg reclaim encounters a page that is
+		 *    not marked for immediate reclaim or the caller does not
+		 *    have __GFP_IO. In this case mark the page for immediate
+		 *    reclaim and continue scanning.
 		 *
 		 *    __GFP_IO is checked  because a loop driver thread might
 		 *    enter reclaim, and deadlock if it waits on a page for
@@ -958,7 +989,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 *    grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so testing
 		 *    may_enter_fs here is liable to OOM on them.
 		 *
-		 * 3) memcg encounters a page that is not already marked
+		 * 3) Legacy memcg encounters a page that is not already marked
 		 *    PageReclaim. memcg does not have any dirty pages
 		 *    throttling so we could easily OOM just because too many
 		 *    pages are in writeback and there is nothing else to
@@ -973,7 +1004,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 
 			/* Case 2 above */
-			} else if (global_reclaim(sc) ||
+			} else if (sane_reclaim(sc) ||
 			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_IO)) {
 				/*
 				 * This is slightly racy - end_page_writeback()
@@ -1422,7 +1453,7 @@ static int too_many_isolated(struct zone *zone, int file,
 	if (current_is_kswapd())
 		return 0;
 
-	if (!global_reclaim(sc))
+	if (!sane_reclaim(sc))
 		return 0;
 
 	if (file) {
@@ -1614,10 +1645,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		set_bit(ZONE_WRITEBACK, &zone->flags);
 
 	/*
-	 * memcg will stall in page writeback so only consider forcibly
-	 * stalling for global reclaim
+	 * Legacy memcg will stall in page writeback so avoid forcibly
+	 * stalling here.
 	 */
-	if (global_reclaim(sc)) {
+	if (sane_reclaim(sc)) {
 		/*
 		 * Tag a zone as congested if all the dirty pages scanned were
 		 * backed by a congested BDI and wait_iff_congested will stall.
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
