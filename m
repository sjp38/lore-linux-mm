Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E02F6B0288
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:54 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id f22so7589942yba.12
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h8si1482621ywk.503.2017.12.15.14.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:53 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 68/78] mm: Convert cgroup writeback to XArray
Date: Fri, 15 Dec 2017 14:04:40 -0800
Message-Id: <20171215220450.7899-69-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a fairly naive conversion, leaving in place the GFP_ATOMIC
allocation.  By switching the locking around, we could use GFP_KERNEL
and probably simplify the error handling.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/backing-dev-defs.h |  2 +-
 include/linux/backing-dev.h      |  2 +-
 mm/backing-dev.c                 | 23 +++++++++++------------
 3 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index bfe86b54f6c1..074a54aad33c 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -187,7 +187,7 @@ struct backing_dev_info {
 	struct bdi_writeback wb;  /* the root writeback info for this bdi */
 	struct list_head wb_list; /* list of all wbs */
 #ifdef CONFIG_CGROUP_WRITEBACK
-	struct radix_tree_root cgwb_tree; /* radix tree of active cgroup wbs */
+	struct xarray cgwb_xa;		/* radix tree of active cgroup wbs */
 	struct rb_root cgwb_congested_tree; /* their congested states */
 #else
 	struct bdi_writeback_congested *wb_congested;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 2af5b8a62d1e..715e7582fa03 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -271,7 +271,7 @@ static inline struct bdi_writeback *wb_find_current(struct backing_dev_info *bdi
 	if (!memcg_css->parent)
 		return &bdi->wb;
 
-	wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
+	wb = xa_load(&bdi->cgwb_xa, memcg_css->id);
 
 	/*
 	 * %current's blkcg equals the effective blkcg of its memcg.  No
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 84b2dc76f140..04efdf2b401a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -417,8 +417,8 @@ static void wb_exit(struct bdi_writeback *wb)
 #include <linux/memcontrol.h>
 
 /*
- * cgwb_lock protects bdi->cgwb_tree, bdi->cgwb_congested_tree,
- * blkcg->cgwb_list, and memcg->cgwb_list.  bdi->cgwb_tree is also RCU
+ * cgwb_lock protects bdi->cgwb_xa, bdi->cgwb_congested_tree,
+ * blkcg->cgwb_list, and memcg->cgwb_list.  bdi->cgwb_xa is also RCU
  * protected.
  */
 static DEFINE_SPINLOCK(cgwb_lock);
@@ -539,7 +539,7 @@ static void cgwb_kill(struct bdi_writeback *wb)
 {
 	lockdep_assert_held(&cgwb_lock);
 
-	WARN_ON(!radix_tree_delete(&wb->bdi->cgwb_tree, wb->memcg_css->id));
+	WARN_ON(xa_erase(&wb->bdi->cgwb_xa, wb->memcg_css->id) != wb);
 	list_del(&wb->memcg_node);
 	list_del(&wb->blkcg_node);
 	percpu_ref_kill(&wb->refcnt);
@@ -571,7 +571,7 @@ static int cgwb_create(struct backing_dev_info *bdi,
 
 	/* look up again under lock and discard on blkcg mismatch */
 	spin_lock_irqsave(&cgwb_lock, flags);
-	wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
+	wb = xa_load(&bdi->cgwb_xa, memcg_css->id);
 	if (wb && wb->blkcg_css != blkcg_css) {
 		cgwb_kill(wb);
 		wb = NULL;
@@ -614,8 +614,8 @@ static int cgwb_create(struct backing_dev_info *bdi,
 	spin_lock_irqsave(&cgwb_lock, flags);
 	if (test_bit(WB_registered, &bdi->wb.state) &&
 	    blkcg_cgwb_list->next && memcg_cgwb_list->next) {
-		/* we might have raced another instance of this function */
-		ret = radix_tree_insert(&bdi->cgwb_tree, memcg_css->id, wb);
+		ret = xa_store_empty(&bdi->cgwb_xa, memcg_css->id, wb,
+					GFP_ATOMIC);
 		if (!ret) {
 			list_add_tail_rcu(&wb->bdi_node, &bdi->wb_list);
 			list_add(&wb->memcg_node, memcg_cgwb_list);
@@ -682,7 +682,7 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 
 	do {
 		rcu_read_lock();
-		wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
+		wb = xa_load(&bdi->cgwb_xa, memcg_css->id);
 		if (wb) {
 			struct cgroup_subsys_state *blkcg_css;
 
@@ -704,7 +704,7 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 {
 	int ret;
 
-	INIT_RADIX_TREE(&bdi->cgwb_tree, GFP_ATOMIC);
+	xa_init(&bdi->cgwb_xa);
 	bdi->cgwb_congested_tree = RB_ROOT;
 
 	ret = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
@@ -717,15 +717,14 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 
 static void cgwb_bdi_unregister(struct backing_dev_info *bdi)
 {
-	struct radix_tree_iter iter;
-	void **slot;
+	XA_STATE(xas, &bdi->cgwb_xa, 0);
 	struct bdi_writeback *wb;
 
 	WARN_ON(test_bit(WB_registered, &bdi->wb.state));
 
 	spin_lock_irq(&cgwb_lock);
-	radix_tree_for_each_slot(slot, &bdi->cgwb_tree, &iter, 0)
-		cgwb_kill(*slot);
+	xas_for_each(&xas, wb, ULONG_MAX)
+		cgwb_kill(wb);
 
 	while (!list_empty(&bdi->wb_list)) {
 		wb = list_first_entry(&bdi->wb_list, struct bdi_writeback,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
