Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA0B6B0038
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:51:03 -0400 (EDT)
Received: by qkoo18 with SMTP id o18so31841518qko.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:03 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id j60si3257468qgf.98.2015.05.28.11.51.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 11:51:02 -0700 (PDT)
Received: by qgg60 with SMTP id 60so20446698qgg.2
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:02 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/9] writeback: relocate wb[_try]_get(), wb_put(), inode_{attach|detach}_wb()
Date: Thu, 28 May 2015 14:50:49 -0400
Message-Id: <1432839057-17609-2-git-send-email-tj@kernel.org>
In-Reply-To: <1432839057-17609-1-git-send-email-tj@kernel.org>
References: <1432839057-17609-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

Currently, majority of cgroup writeback support including all the
above functions are implemented in include/linux/backing-dev.h and
mm/backing-dev.c; however, the portion closely related to writeback
logic implemented in include/linux/writeback.h and mm/page-writeback.c
will expand to support foreign writeback detection and correction.

This patch moves wb[_try]_get() and wb_put() to
include/linux/backing-dev-defs.h so that they can be used from
writeback.h and inode_{attach|detach}_wb() to writeback.h and
page-writeback.c.

This is pure reorganization and doesn't introduce any functional
changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c                | 31 +++++++++++++++
 include/linux/backing-dev-defs.h | 50 ++++++++++++++++++++++++
 include/linux/backing-dev.h      | 82 ----------------------------------------
 include/linux/writeback.h        | 46 ++++++++++++++++++++++
 mm/backing-dev.c                 | 30 ---------------
 5 files changed, 127 insertions(+), 112 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index da35587..cf6ccfb 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -27,6 +27,7 @@
 #include <linux/backing-dev.h>
 #include <linux/tracepoint.h>
 #include <linux/device.h>
+#include <linux/memcontrol.h>
 #include "internal.h"
 
 /*
@@ -213,6 +214,36 @@ static void wb_wait_for_completion(struct backing_dev_info *bdi,
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
+void __inode_attach_wb(struct inode *inode, struct page *page)
+{
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
+	struct bdi_writeback *wb = NULL;
+
+	if (inode_cgwb_enabled(inode)) {
+		struct cgroup_subsys_state *memcg_css;
+
+		if (page) {
+			memcg_css = mem_cgroup_css_from_page(page);
+			wb = wb_get_create(bdi, memcg_css, GFP_ATOMIC);
+		} else {
+			/* must pin memcg_css, see wb_get_create() */
+			memcg_css = task_get_css(current, memory_cgrp_id);
+			wb = wb_get_create(bdi, memcg_css, GFP_ATOMIC);
+			css_put(memcg_css);
+		}
+	}
+
+	if (!wb)
+		wb = &bdi->wb;
+
+	/*
+	 * There may be multiple instances of this function racing to
+	 * update the same inode.  Use cmpxchg() to tell the winner.
+	 */
+	if (unlikely(cmpxchg(&inode->i_wb, NULL, wb)))
+		wb_put(wb);
+}
+
 /**
  * inode_congested - test whether an inode is congested
  * @inode: inode to test for congestion
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 8d470b7..e047b49 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -186,4 +186,54 @@ static inline void set_bdi_congested(struct backing_dev_info *bdi, int sync)
 	set_wb_congested(bdi->wb.congested, sync);
 }
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+/**
+ * wb_tryget - try to increment a wb's refcount
+ * @wb: bdi_writeback to get
+ */
+static inline bool wb_tryget(struct bdi_writeback *wb)
+{
+	if (wb != &wb->bdi->wb)
+		return percpu_ref_tryget(&wb->refcnt);
+	return true;
+}
+
+/**
+ * wb_get - increment a wb's refcount
+ * @wb: bdi_writeback to get
+ */
+static inline void wb_get(struct bdi_writeback *wb)
+{
+	if (wb != &wb->bdi->wb)
+		percpu_ref_get(&wb->refcnt);
+}
+
+/**
+ * wb_put - decrement a wb's refcount
+ * @wb: bdi_writeback to put
+ */
+static inline void wb_put(struct bdi_writeback *wb)
+{
+	if (wb != &wb->bdi->wb)
+		percpu_ref_put(&wb->refcnt);
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static inline bool wb_tryget(struct bdi_writeback *wb)
+{
+	return true;
+}
+
+static inline void wb_get(struct bdi_writeback *wb)
+{
+}
+
+static inline void wb_put(struct bdi_writeback *wb)
+{
+}
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 #endif	/* __LINUX_BACKING_DEV_DEFS_H */
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index e9d7373..5c978a9 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -243,7 +243,6 @@ void wb_congested_put(struct bdi_writeback_congested *congested);
 struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 				    struct cgroup_subsys_state *memcg_css,
 				    gfp_t gfp);
-void __inode_attach_wb(struct inode *inode, struct page *page);
 void wb_memcg_offline(struct mem_cgroup *memcg);
 void wb_blkcg_offline(struct blkcg *blkcg);
 int inode_congested(struct inode *inode, int cong_bits);
@@ -265,37 +264,6 @@ static inline bool inode_cgwb_enabled(struct inode *inode)
 }
 
 /**
- * wb_tryget - try to increment a wb's refcount
- * @wb: bdi_writeback to get
- */
-static inline bool wb_tryget(struct bdi_writeback *wb)
-{
-	if (wb != &wb->bdi->wb)
-		return percpu_ref_tryget(&wb->refcnt);
-	return true;
-}
-
-/**
- * wb_get - increment a wb's refcount
- * @wb: bdi_writeback to get
- */
-static inline void wb_get(struct bdi_writeback *wb)
-{
-	if (wb != &wb->bdi->wb)
-		percpu_ref_get(&wb->refcnt);
-}
-
-/**
- * wb_put - decrement a wb's refcount
- * @wb: bdi_writeback to put
- */
-static inline void wb_put(struct bdi_writeback *wb)
-{
-	if (wb != &wb->bdi->wb)
-		percpu_ref_put(&wb->refcnt);
-}
-
-/**
  * wb_find_current - find wb for %current on a bdi
  * @bdi: bdi of interest
  *
@@ -354,35 +322,6 @@ wb_get_create_current(struct backing_dev_info *bdi, gfp_t gfp)
 }
 
 /**
- * inode_attach_wb - associate an inode with its wb
- * @inode: inode of interest
- * @page: page being dirtied (may be NULL)
- *
- * If @inode doesn't have its wb, associate it with the wb matching the
- * memcg of @page or, if @page is NULL, %current.  May be called w/ or w/o
- * @inode->i_lock.
- */
-static inline void inode_attach_wb(struct inode *inode, struct page *page)
-{
-	if (!inode->i_wb)
-		__inode_attach_wb(inode, page);
-}
-
-/**
- * inode_detach_wb - disassociate an inode from its wb
- * @inode: inode of interest
- *
- * @inode is being freed.  Detach from its wb.
- */
-static inline void inode_detach_wb(struct inode *inode)
-{
-	if (inode->i_wb) {
-		wb_put(inode->i_wb);
-		inode->i_wb = NULL;
-	}
-}
-
-/**
  * inode_to_wb - determine the wb of an inode
  * @inode: inode of interest
  *
@@ -471,19 +410,6 @@ static inline void wb_congested_put(struct bdi_writeback_congested *congested)
 {
 }
 
-static inline bool wb_tryget(struct bdi_writeback *wb)
-{
-	return true;
-}
-
-static inline void wb_get(struct bdi_writeback *wb)
-{
-}
-
-static inline void wb_put(struct bdi_writeback *wb)
-{
-}
-
 static inline struct bdi_writeback *wb_find_current(struct backing_dev_info *bdi)
 {
 	return &bdi->wb;
@@ -495,14 +421,6 @@ wb_get_create_current(struct backing_dev_info *bdi, gfp_t gfp)
 	return &bdi->wb;
 }
 
-static inline void inode_attach_wb(struct inode *inode, struct page *page)
-{
-}
-
-static inline void inode_detach_wb(struct inode *inode)
-{
-}
-
 static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
 {
 	return &inode_to_bdi(inode)->wb;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 3b73e97..6726b7e 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -8,6 +8,7 @@
 #include <linux/workqueue.h>
 #include <linux/fs.h>
 #include <linux/flex_proportions.h>
+#include <linux/backing-dev-defs.h>
 
 DECLARE_PER_CPU(int, dirty_throttle_leaks);
 
@@ -173,6 +174,51 @@ static inline void wait_on_inode(struct inode *inode)
 	wait_on_bit(&inode->i_state, __I_NEW, TASK_UNINTERRUPTIBLE);
 }
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+void __inode_attach_wb(struct inode *inode, struct page *page);
+
+/**
+ * inode_attach_wb - associate an inode with its wb
+ * @inode: inode of interest
+ * @page: page being dirtied (may be NULL)
+ *
+ * If @inode doesn't have its wb, associate it with the wb matching the
+ * memcg of @page or, if @page is NULL, %current.  May be called w/ or w/o
+ * @inode->i_lock.
+ */
+static inline void inode_attach_wb(struct inode *inode, struct page *page)
+{
+	if (!inode->i_wb)
+		__inode_attach_wb(inode, page);
+}
+
+/**
+ * inode_detach_wb - disassociate an inode from its wb
+ * @inode: inode of interest
+ *
+ * @inode is being freed.  Detach from its wb.
+ */
+static inline void inode_detach_wb(struct inode *inode)
+{
+	if (inode->i_wb) {
+		wb_put(inode->i_wb);
+		inode->i_wb = NULL;
+	}
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static inline void inode_attach_wb(struct inode *inode, struct page *page)
+{
+}
+
+static inline void inode_detach_wb(struct inode *inode)
+{
+}
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 /*
  * mm/page-writeback.c
  */
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 84ebf7c..887d72a8 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -660,36 +660,6 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 	return wb;
 }
 
-void __inode_attach_wb(struct inode *inode, struct page *page)
-{
-	struct backing_dev_info *bdi = inode_to_bdi(inode);
-	struct bdi_writeback *wb = NULL;
-
-	if (inode_cgwb_enabled(inode)) {
-		struct cgroup_subsys_state *memcg_css;
-
-		if (page) {
-			memcg_css = mem_cgroup_css_from_page(page);
-			wb = wb_get_create(bdi, memcg_css, GFP_ATOMIC);
-		} else {
-			/* must pin memcg_css, see wb_get_create() */
-			memcg_css = task_get_css(current, memory_cgrp_id);
-			wb = wb_get_create(bdi, memcg_css, GFP_ATOMIC);
-			css_put(memcg_css);
-		}
-	}
-
-	if (!wb)
-		wb = &bdi->wb;
-
-	/*
-	 * There may be multiple instances of this function racing to
-	 * update the same inode.  Use cmpxchg() to tell the winner.
-	 */
-	if (unlikely(cmpxchg(&inode->i_wb, NULL, wb)))
-		wb_put(wb);
-}
-
 static void cgwb_bdi_init(struct backing_dev_info *bdi)
 {
 	bdi->wb.memcg_css = mem_cgroup_root_css;
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
