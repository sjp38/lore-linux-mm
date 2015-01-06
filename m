Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9006B0131
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:45 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id n4so211928qaq.6
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:44 -0800 (PST)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id b5si65650017qat.123.2015.01.06.13.26.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:44 -0800 (PST)
Received: by mail-qg0-f46.google.com with SMTP id q107so58308qgd.33
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:43 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 08/45] writeback: let balance_dirty_pages() work on the matching cgroup bdi_writeback
Date: Tue,  6 Jan 2015 16:25:45 -0500
Message-Id: <1420579582-8516-9-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

Currently, balance_dirty_pages() always work on bdi->wb.  This patch
updates it to work on the cgwb (cgroup bdi_writeback) matching the
blkcg of the current task as that's what the pages are being dirtied
against.

balance_dirty_pages_ratelimited() now pins the current blkcg and looks
up the matching cgwb and passes it to balance_dirty_pages().  The
pinning is necessary to ensure that the cgwb stays alive while the
function is executing as a cgwb's lifetime is determined by its bdi
and blkcg.

As no filesystem has FS_CGROUP_WRITEBACK yet, this doesn't lead to
visible behavior differences.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d1fea3a..b115a57 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1335,6 +1335,7 @@ static inline void wb_dirty_limits(struct bdi_writeback *wb,
  * perform some writeout.
  */
 static void balance_dirty_pages(struct address_space *mapping,
+				struct bdi_writeback *wb,
 				unsigned long pages_dirtied)
 {
 	unsigned long nr_reclaimable;	/* = file_dirty + unstable_nfs */
@@ -1351,7 +1352,6 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long dirty_ratelimit;
 	unsigned long pos_ratio;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
-	struct bdi_writeback *wb = &bdi->wb;
 	bool strictlimit = bdi->capabilities & BDI_CAP_STRICTLIMIT;
 	unsigned long start_time = jiffies;
 
@@ -1575,13 +1575,25 @@ DEFINE_PER_CPU(int, dirty_throttle_leaks) = 0;
 void balance_dirty_pages_ratelimited(struct address_space *mapping)
 {
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
-	struct bdi_writeback *wb = &bdi->wb;
+	struct cgroup_subsys_state *blkcg_css = NULL;
+	struct bdi_writeback *wb = NULL;
 	int ratelimit;
 	int *p;
 
 	if (!bdi_cap_account_dirty(bdi))
 		return;
 
+	/*
+	 * Throttle against the cgwb of the current blkcg.  Make sure that
+	 * the cgwb stays alive by pinning the blkcg.
+	 */
+	if (mapping_cgwb_enabled(mapping)) {
+		blkcg_css = task_get_blkcg_css(current);
+		wb = cgwb_lookup(bdi, blkcg_css);
+	}
+	if (!wb)
+		wb = &bdi->wb;
+
 	ratelimit = current->nr_dirtied_pause;
 	if (wb->dirty_exceeded)
 		ratelimit = min(ratelimit, 32 >> (PAGE_SHIFT - 10));
@@ -1615,7 +1627,10 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
 	preempt_enable();
 
 	if (unlikely(current->nr_dirtied >= ratelimit))
-		balance_dirty_pages(mapping, current->nr_dirtied);
+		balance_dirty_pages(mapping, wb, current->nr_dirtied);
+
+	if (blkcg_css)
+		css_put(blkcg_css);
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited);
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
