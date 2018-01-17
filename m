Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C473228027B
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:03 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x4so5625735pgv.2
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h63si4449519pge.435.2018.01.17.12.23.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:02 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 79/99] blk-cgroup: Convert to XArray
Date: Wed, 17 Jan 2018 12:21:43 -0800
Message-Id: <20180117202203.19756-80-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This call to radix_tree_preload is awkward.  At the point of allocation,
we're under not only a local lock, but also under the queue lock.  So we
can't back out, drop the lock and retry the allocation.  Replace this
preload call with a call to xa_reserve() which will ensure the memory is
allocated.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 block/bfq-cgroup.c         |  4 ++--
 block/blk-cgroup.c         | 52 ++++++++++++++++++++++------------------------
 block/cfq-iosched.c        |  4 ++--
 include/linux/blk-cgroup.h |  5 ++---
 4 files changed, 31 insertions(+), 34 deletions(-)

diff --git a/block/bfq-cgroup.c b/block/bfq-cgroup.c
index da1525ec4c87..0648aaa6498b 100644
--- a/block/bfq-cgroup.c
+++ b/block/bfq-cgroup.c
@@ -860,7 +860,7 @@ static int bfq_io_set_weight_legacy(struct cgroup_subsys_state *css,
 		return ret;
 
 	ret = 0;
-	spin_lock_irq(&blkcg->lock);
+	xa_lock_irq(&blkcg->blkg_array);
 	bfqgd->weight = (unsigned short)val;
 	hlist_for_each_entry(blkg, &blkcg->blkg_list, blkcg_node) {
 		struct bfq_group *bfqg = blkg_to_bfqg(blkg);
@@ -894,7 +894,7 @@ static int bfq_io_set_weight_legacy(struct cgroup_subsys_state *css,
 			bfqg->entity.prio_changed = 1;
 		}
 	}
-	spin_unlock_irq(&blkcg->lock);
+	xa_unlock_irq(&blkcg->blkg_array);
 
 	return ret;
 }
diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 4117524ca45b..37962d52f1a8 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -146,12 +146,12 @@ struct blkcg_gq *blkg_lookup_slowpath(struct blkcg *blkcg,
 	struct blkcg_gq *blkg;
 
 	/*
-	 * Hint didn't match.  Look up from the radix tree.  Note that the
+	 * Hint didn't match.  Fetch from the xarray.  Note that the
 	 * hint can only be updated under queue_lock as otherwise @blkg
-	 * could have already been removed from blkg_tree.  The caller is
+	 * could have already been removed from blkg_array.  The caller is
 	 * responsible for grabbing queue_lock if @update_hint.
 	 */
-	blkg = radix_tree_lookup(&blkcg->blkg_tree, q->id);
+	blkg = xa_load(&blkcg->blkg_array, q->id);
 	if (blkg && blkg->q == q) {
 		if (update_hint) {
 			lockdep_assert_held(q->queue_lock);
@@ -223,8 +223,8 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 	}
 
 	/* insert */
-	spin_lock(&blkcg->lock);
-	ret = radix_tree_insert(&blkcg->blkg_tree, q->id, blkg);
+	xa_lock(&blkcg->blkg_array);
+	ret = xa_err(__xa_store(&blkcg->blkg_array, q->id, blkg, GFP_NOWAIT));
 	if (likely(!ret)) {
 		hlist_add_head_rcu(&blkg->blkcg_node, &blkcg->blkg_list);
 		list_add(&blkg->q_node, &q->blkg_list);
@@ -237,7 +237,7 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 		}
 	}
 	blkg->online = true;
-	spin_unlock(&blkcg->lock);
+	xa_unlock(&blkcg->blkg_array);
 
 	if (!ret)
 		return blkg;
@@ -314,7 +314,7 @@ static void blkg_destroy(struct blkcg_gq *blkg)
 	int i;
 
 	lockdep_assert_held(blkg->q->queue_lock);
-	lockdep_assert_held(&blkcg->lock);
+	lockdep_assert_held(&blkcg->blkg_array.xa_lock);
 
 	/* Something wrong if we are trying to remove same group twice */
 	WARN_ON_ONCE(list_empty(&blkg->q_node));
@@ -334,7 +334,7 @@ static void blkg_destroy(struct blkcg_gq *blkg)
 
 	blkg->online = false;
 
-	radix_tree_delete(&blkcg->blkg_tree, blkg->q->id);
+	xa_erase(&blkcg->blkg_array, blkg->q->id);
 	list_del_init(&blkg->q_node);
 	hlist_del_init_rcu(&blkg->blkcg_node);
 
@@ -368,9 +368,9 @@ static void blkg_destroy_all(struct request_queue *q)
 	list_for_each_entry_safe(blkg, n, &q->blkg_list, q_node) {
 		struct blkcg *blkcg = blkg->blkcg;
 
-		spin_lock(&blkcg->lock);
+		xa_lock(&blkcg->blkg_array);
 		blkg_destroy(blkg);
-		spin_unlock(&blkcg->lock);
+		xa_unlock(&blkcg->blkg_array);
 	}
 
 	q->root_blkg = NULL;
@@ -443,7 +443,7 @@ static int blkcg_reset_stats(struct cgroup_subsys_state *css,
 	int i;
 
 	mutex_lock(&blkcg_pol_mutex);
-	spin_lock_irq(&blkcg->lock);
+	xa_lock_irq(&blkcg->blkg_array);
 
 	/*
 	 * Note that stat reset is racy - it doesn't synchronize against
@@ -462,7 +462,7 @@ static int blkcg_reset_stats(struct cgroup_subsys_state *css,
 		}
 	}
 
-	spin_unlock_irq(&blkcg->lock);
+	xa_unlock_irq(&blkcg->blkg_array);
 	mutex_unlock(&blkcg_pol_mutex);
 	return 0;
 }
@@ -1012,7 +1012,7 @@ static void blkcg_css_offline(struct cgroup_subsys_state *css)
 {
 	struct blkcg *blkcg = css_to_blkcg(css);
 
-	spin_lock_irq(&blkcg->lock);
+	xa_lock_irq(&blkcg->blkg_array);
 
 	while (!hlist_empty(&blkcg->blkg_list)) {
 		struct blkcg_gq *blkg = hlist_entry(blkcg->blkg_list.first,
@@ -1023,13 +1023,13 @@ static void blkcg_css_offline(struct cgroup_subsys_state *css)
 			blkg_destroy(blkg);
 			spin_unlock(q->queue_lock);
 		} else {
-			spin_unlock_irq(&blkcg->lock);
+			xa_unlock_irq(&blkcg->blkg_array);
 			cpu_relax();
-			spin_lock_irq(&blkcg->lock);
+			xa_lock_irq(&blkcg->blkg_array);
 		}
 	}
 
-	spin_unlock_irq(&blkcg->lock);
+	xa_unlock_irq(&blkcg->blkg_array);
 
 	wb_blkcg_offline(blkcg);
 }
@@ -1096,8 +1096,7 @@ blkcg_css_alloc(struct cgroup_subsys_state *parent_css)
 			pol->cpd_init_fn(cpd);
 	}
 
-	spin_lock_init(&blkcg->lock);
-	INIT_RADIX_TREE(&blkcg->blkg_tree, GFP_NOWAIT | __GFP_NOWARN);
+	xa_init_flags(&blkcg->blkg_array, XA_FLAGS_LOCK_IRQ);
 	INIT_HLIST_HEAD(&blkcg->blkg_list);
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&blkcg->cgwb_list);
@@ -1132,14 +1131,14 @@ blkcg_css_alloc(struct cgroup_subsys_state *parent_css)
 int blkcg_init_queue(struct request_queue *q)
 {
 	struct blkcg_gq *new_blkg, *blkg;
-	bool preloaded;
 	int ret;
 
 	new_blkg = blkg_alloc(&blkcg_root, q, GFP_KERNEL);
 	if (!new_blkg)
 		return -ENOMEM;
 
-	preloaded = !radix_tree_preload(GFP_KERNEL);
+	if (xa_reserve(&blkcg_root.blkg_array, q->id, GFP_KERNEL))
+		return -ENOMEM;
 
 	/*
 	 * Make sure the root blkg exists and count the existing blkgs.  As
@@ -1152,11 +1151,10 @@ int blkcg_init_queue(struct request_queue *q)
 	spin_unlock_irq(q->queue_lock);
 	rcu_read_unlock();
 
-	if (preloaded)
-		radix_tree_preload_end();
-
-	if (IS_ERR(blkg))
+	if (IS_ERR(blkg)) {
+		xa_erase(&blkcg_root.blkg_array, q->id);
 		return PTR_ERR(blkg);
+	}
 
 	q->root_blkg = blkg;
 	q->root_rl.blkg = blkg;
@@ -1374,8 +1372,8 @@ void blkcg_deactivate_policy(struct request_queue *q,
 	__clear_bit(pol->plid, q->blkcg_pols);
 
 	list_for_each_entry(blkg, &q->blkg_list, q_node) {
-		/* grab blkcg lock too while removing @pd from @blkg */
-		spin_lock(&blkg->blkcg->lock);
+		/* grab xa_lock too while removing @pd from @blkg */
+		xa_lock(&blkg->blkcg->blkg_array);
 
 		if (blkg->pd[pol->plid]) {
 			if (pol->pd_offline_fn)
@@ -1384,7 +1382,7 @@ void blkcg_deactivate_policy(struct request_queue *q,
 			blkg->pd[pol->plid] = NULL;
 		}
 
-		spin_unlock(&blkg->blkcg->lock);
+		xa_unlock(&blkg->blkcg->blkg_array);
 	}
 
 	spin_unlock_irq(q->queue_lock);
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 9f342ef1ad42..a51bef7af8df 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1827,7 +1827,7 @@ static int __cfq_set_weight(struct cgroup_subsys_state *css, u64 val,
 	if (val < min || val > max)
 		return -ERANGE;
 
-	spin_lock_irq(&blkcg->lock);
+	xa_lock_irq(&blkcg->blkg_array);
 	cfqgd = blkcg_to_cfqgd(blkcg);
 	if (!cfqgd) {
 		ret = -EINVAL;
@@ -1859,7 +1859,7 @@ static int __cfq_set_weight(struct cgroup_subsys_state *css, u64 val,
 	}
 
 out:
-	spin_unlock_irq(&blkcg->lock);
+	xa_unlock_irq(&blkcg->blkg_array);
 	return ret;
 }
 
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index e9825ff57b15..6278c49d3997 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -17,7 +17,7 @@
 #include <linux/cgroup.h>
 #include <linux/percpu_counter.h>
 #include <linux/seq_file.h>
-#include <linux/radix-tree.h>
+#include <linux/xarray.h>
 #include <linux/blkdev.h>
 #include <linux/atomic.h>
 #include <linux/kthread.h>
@@ -44,9 +44,8 @@ struct blkcg_gq;
 
 struct blkcg {
 	struct cgroup_subsys_state	css;
-	spinlock_t			lock;
 
-	struct radix_tree_root		blkg_tree;
+	struct xarray			blkg_array;
 	struct blkcg_gq	__rcu		*blkg_hint;
 	struct hlist_head		blkg_list;
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
