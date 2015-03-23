Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id D39326B009D
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:56:02 -0400 (EDT)
Received: by qgf74 with SMTP id 74so11438542qgf.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:56:02 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id p76si11242024qkh.27.2015.03.22.21.55.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:55:50 -0700 (PDT)
Received: by qgez102 with SMTP id z102so48339733qge.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:49 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 24/48] writeback: let balance_dirty_pages() work on the matching cgroup bdi_writeback
Date: Mon, 23 Mar 2015 00:54:35 -0400
Message-Id: <1427086499-15657-25-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Currently, balance_dirty_pages() always work on bdi->wb.  This patch
updates it to work on the wb (bdi_writeback) matching memcg and blkcg
of the current task as that's what the inode is being dirtied against.

balance_dirty_pages_ratelimited() now pins the current wb and passes
it to balance_dirty_pages().

As no filesystem has FS_CGROUP_WRITEBACK yet, this doesn't lead to
visible behavior differences.

v2: Updated for per-inode wb association.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d5635cf..bfbd8d2 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1337,6 +1337,7 @@ static inline void wb_dirty_limits(struct bdi_writeback *wb,
  * perform some writeout.
  */
 static void balance_dirty_pages(struct address_space *mapping,
+				struct bdi_writeback *wb,
 				unsigned long pages_dirtied)
 {
 	unsigned long nr_reclaimable;	/* = file_dirty + unstable_nfs */
@@ -1352,8 +1353,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long task_ratelimit;
 	unsigned long dirty_ratelimit;
 	unsigned long pos_ratio;
-	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
-	struct bdi_writeback *wb = &bdi->wb;
+	struct backing_dev_info *bdi = wb->bdi;
 	bool strictlimit = bdi->capabilities & BDI_CAP_STRICTLIMIT;
 	unsigned long start_time = jiffies;
 
@@ -1575,14 +1575,20 @@ DEFINE_PER_CPU(int, dirty_throttle_leaks) = 0;
  */
 void balance_dirty_pages_ratelimited(struct address_space *mapping)
 {
-	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
-	struct bdi_writeback *wb = &bdi->wb;
+	struct inode *inode = mapping->host;
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
+	struct bdi_writeback *wb = NULL;
 	int ratelimit;
 	int *p;
 
 	if (!bdi_cap_account_dirty(bdi))
 		return;
 
+	if (inode_cgwb_enabled(inode))
+		wb = wb_get_create_current(bdi, GFP_KERNEL);
+	if (!wb)
+		wb = &bdi->wb;
+
 	ratelimit = current->nr_dirtied_pause;
 	if (wb->dirty_exceeded)
 		ratelimit = min(ratelimit, 32 >> (PAGE_SHIFT - 10));
@@ -1616,7 +1622,9 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
 	preempt_enable();
 
 	if (unlikely(current->nr_dirtied >= ratelimit))
-		balance_dirty_pages(mapping, current->nr_dirtied);
+		balance_dirty_pages(mapping, wb, current->nr_dirtied);
+
+	wb_put(wb);
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited);
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
