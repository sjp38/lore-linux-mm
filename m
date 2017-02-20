Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82E536B0388
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 05:49:26 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f21so44034430pgi.4
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 02:49:26 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m24si2290284pfa.104.2017.02.20.02.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 02:49:25 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 1/5] mm: convert bdi_writeback_congested.refcnt from atomic_t to refcount_t
Date: Mon, 20 Feb 2017 12:49:10 +0200
Message-Id: <1487587754-10610-2-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1487587754-10610-1-git-send-email-elena.reshetova@intel.com>
References: <1487587754-10610-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Elena Reshetova <elena.reshetova@intel.com>, Hans Liljestrand <ishkamiel@gmail.com>, Kees Cook <keescook@chromium.org>, David Windsor <dwindsor@gmail.com>

refcount_t type and corresponding API should be used instead of
atomic_t when the variable is used as a reference counter.
This allows to avoid accidental refcounter overflows that might
lead to use-after-free situations.

Switch bdi_writeback_congested.refcnt from atomic_t to refcount_t and
increment initial value by 1. The incrementation affecs the function
wb_congested_get_create which previously incremented both found and
created objects. After this patch the function will increment only found
objects and instead set the refcount of new objects to 1. Note that
new_congested is initially NULL, and will be discarded unless exiting
via the 'if (new_congested)' section.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/linux/backing-dev-defs.h |  3 ++-
 include/linux/backing-dev.h      |  4 ++--
 mm/backing-dev.c                 | 11 ++++++-----
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index ad95581..609ee6f 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <linux/radix-tree.h>
 #include <linux/rbtree.h>
+#include <linux/refcount.h>
 #include <linux/spinlock.h>
 #include <linux/percpu_counter.h>
 #include <linux/percpu-refcount.h>
@@ -51,7 +52,7 @@ enum wb_stat_item {
  */
 struct bdi_writeback_congested {
 	unsigned long state;		/* WB_[a]sync_congested flags */
-	atomic_t refcnt;		/* nr of attached wb's and blkg */
+	refcount_t refcnt;		/* nr of attached wb's and blkg */
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct backing_dev_info *bdi;	/* the associated bdi */
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index c52a48c..4726d81 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -430,13 +430,13 @@ static inline bool inode_cgwb_enabled(struct inode *inode)
 static inline struct bdi_writeback_congested *
 wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
 {
-	atomic_inc(&bdi->wb_congested->refcnt);
+	refcount_inc(&bdi->wb_congested->refcnt);
 	return bdi->wb_congested;
 }
 
 static inline void wb_congested_put(struct bdi_writeback_congested *congested)
 {
-	if (atomic_dec_and_test(&congested->refcnt))
+	if (refcount_dec_and_test(&congested->refcnt))
 		kfree(congested);
 }
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 6d861d0..2df3ed7 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -417,14 +417,17 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
 			node = &parent->rb_left;
 		else if (congested->blkcg_id > blkcg_id)
 			node = &parent->rb_right;
-		else
-			goto found;
+		else {
+			refcount_inc(&congested->refcnt);
+ 			goto found;
+		}
 	}
 
 	if (new_congested) {
 		/* !found and storage for new one already allocated, insert */
 		congested = new_congested;
 		new_congested = NULL;
+		refcount_set(&congested->refcnt, 1);
 		rb_link_node(&congested->rb_node, parent, node);
 		rb_insert_color(&congested->rb_node, &bdi->cgwb_congested_tree);
 		goto found;
@@ -437,13 +440,11 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
 	if (!new_congested)
 		return NULL;
 
-	atomic_set(&new_congested->refcnt, 0);
 	new_congested->bdi = bdi;
 	new_congested->blkcg_id = blkcg_id;
 	goto retry;
 
 found:
-	atomic_inc(&congested->refcnt);
 	spin_unlock_irqrestore(&cgwb_lock, flags);
 	kfree(new_congested);
 	return congested;
@@ -460,7 +461,7 @@ void wb_congested_put(struct bdi_writeback_congested *congested)
 	unsigned long flags;
 
 	local_irq_save(flags);
-	if (!atomic_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
+	if (!refcount_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
 		local_irq_restore(flags);
 		return;
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
