Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9A25F829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:14:23 -0400 (EDT)
Received: by qgew3 with SMTP id w3so16195027qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:23 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id i111si3470539qgi.6.2015.05.22.14.14.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:14:22 -0700 (PDT)
Received: by qkx62 with SMTP id 62so22131772qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:22 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 05/51] blkcg: always create the blkcg_gq for the root blkcg
Date: Fri, 22 May 2015 17:13:19 -0400
Message-Id: <1432329245-5844-6-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

Currently, blkcg does a minor optimization where the root blkcg is
created when the first blkcg policy is activated on a queue and
destroyed on the deactivation of the last.  On systems where blkcg is
configured but not used, this saves one blkcg_gq struct per queue.  On
systems where blkcg is actually used, there's no difference.  The only
case where this can lead to any meaninful, albeit still minute, save
in memory consumption is when all blkcg policies are deactivated after
being widely used in the system, which is a hihgly unlikely scenario.

The conditional existence of root blkcg_gq has already created several
bugs in blkcg and became an issue once again for the new per-cgroup
wb_congested mechanism for cgroup writeback support leading to a NULL
dereference when no blkcg policy is active.  This is really not worth
bothering with.  This patch makes blkcg always allocate and link the
root blkcg_gq and release it only on queue destruction.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
---
 block/blk-cgroup.c | 96 +++++++++++++++++++++++-------------------------------
 1 file changed, 41 insertions(+), 55 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index c3226ce..2a4f77f 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -235,13 +235,8 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 	blkg->online = true;
 	spin_unlock(&blkcg->lock);
 
-	if (!ret) {
-		if (blkcg == &blkcg_root) {
-			q->root_blkg = blkg;
-			q->root_rl.blkg = blkg;
-		}
+	if (!ret)
 		return blkg;
-	}
 
 	/* @blkg failed fully initialized, use the usual release path */
 	blkg_put(blkg);
@@ -340,15 +335,6 @@ static void blkg_destroy(struct blkcg_gq *blkg)
 		rcu_assign_pointer(blkcg->blkg_hint, NULL);
 
 	/*
-	 * If root blkg is destroyed.  Just clear the pointer since root_rl
-	 * does not take reference on root blkg.
-	 */
-	if (blkcg == &blkcg_root) {
-		blkg->q->root_blkg = NULL;
-		blkg->q->root_rl.blkg = NULL;
-	}
-
-	/*
 	 * Put the reference taken at the time of creation so that when all
 	 * queues are gone, group can be destroyed.
 	 */
@@ -855,9 +841,45 @@ blkcg_css_alloc(struct cgroup_subsys_state *parent_css)
  */
 int blkcg_init_queue(struct request_queue *q)
 {
-	might_sleep();
+	struct blkcg_gq *new_blkg, *blkg;
+	bool preloaded;
+	int ret;
+
+	new_blkg = blkg_alloc(&blkcg_root, q, GFP_KERNEL);
+	if (!new_blkg)
+		return -ENOMEM;
+
+	preloaded = !radix_tree_preload(GFP_KERNEL);
 
-	return blk_throtl_init(q);
+	/*
+	 * Make sure the root blkg exists and count the existing blkgs.  As
+	 * @q is bypassing at this point, blkg_lookup_create() can't be
+	 * used.  Open code insertion.
+	 */
+	rcu_read_lock();
+	spin_lock_irq(q->queue_lock);
+	blkg = blkg_create(&blkcg_root, q, new_blkg);
+	spin_unlock_irq(q->queue_lock);
+	rcu_read_unlock();
+
+	if (preloaded)
+		radix_tree_preload_end();
+
+	if (IS_ERR(blkg)) {
+		kfree(new_blkg);
+		return PTR_ERR(blkg);
+	}
+
+	q->root_blkg = blkg;
+	q->root_rl.blkg = blkg;
+
+	ret = blk_throtl_init(q);
+	if (ret) {
+		spin_lock_irq(q->queue_lock);
+		blkg_destroy_all(q);
+		spin_unlock_irq(q->queue_lock);
+	}
+	return ret;
 }
 
 /**
@@ -958,52 +980,20 @@ int blkcg_activate_policy(struct request_queue *q,
 			  const struct blkcg_policy *pol)
 {
 	LIST_HEAD(pds);
-	struct blkcg_gq *blkg, *new_blkg;
+	struct blkcg_gq *blkg;
 	struct blkg_policy_data *pd, *n;
 	int cnt = 0, ret;
-	bool preloaded;
 
 	if (blkcg_policy_enabled(q, pol))
 		return 0;
 
-	/* preallocations for root blkg */
-	new_blkg = blkg_alloc(&blkcg_root, q, GFP_KERNEL);
-	if (!new_blkg)
-		return -ENOMEM;
-
+	/* count and allocate policy_data for all existing blkgs */
 	blk_queue_bypass_start(q);
-
-	preloaded = !radix_tree_preload(GFP_KERNEL);
-
-	/*
-	 * Make sure the root blkg exists and count the existing blkgs.  As
-	 * @q is bypassing at this point, blkg_lookup_create() can't be
-	 * used.  Open code it.
-	 */
 	spin_lock_irq(q->queue_lock);
-
-	rcu_read_lock();
-	blkg = __blkg_lookup(&blkcg_root, q, false);
-	if (blkg)
-		blkg_free(new_blkg);
-	else
-		blkg = blkg_create(&blkcg_root, q, new_blkg);
-	rcu_read_unlock();
-
-	if (preloaded)
-		radix_tree_preload_end();
-
-	if (IS_ERR(blkg)) {
-		ret = PTR_ERR(blkg);
-		goto out_unlock;
-	}
-
 	list_for_each_entry(blkg, &q->blkg_list, q_node)
 		cnt++;
-
 	spin_unlock_irq(q->queue_lock);
 
-	/* allocate policy_data for all existing blkgs */
 	while (cnt--) {
 		pd = kzalloc_node(pol->pd_size, GFP_KERNEL, q->node);
 		if (!pd) {
@@ -1072,10 +1062,6 @@ void blkcg_deactivate_policy(struct request_queue *q,
 
 	__clear_bit(pol->plid, q->blkcg_pols);
 
-	/* if no policy is left, no need for blkgs - shoot them down */
-	if (bitmap_empty(q->blkcg_pols, BLKCG_MAX_POLS))
-		blkg_destroy_all(q);
-
 	list_for_each_entry(blkg, &q->blkg_list, q_node) {
 		/* grab blkcg lock too while removing @pd from @blkg */
 		spin_lock(&blkg->blkcg->lock);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
