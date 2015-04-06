Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id C0BF26B00A8
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 15:59:47 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so15137362qcb.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:47 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id 91si5132099qgh.89.2015.04.06.12.59.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 12:59:32 -0700 (PDT)
Received: by qgeb100 with SMTP id b100so14883869qge.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:31 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 23/49] writeback, blkcg: associate each blkcg_gq with the corresponding bdi_writeback_congested
Date: Mon,  6 Apr 2015 15:58:12 -0400
Message-Id: <1428350318-8215-24-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

A blkg (blkcg_gq) can be congested and decongested independently from
other blkgs on the same request_queue.  Accordingly, for cgroup
writeback support, the congestion status at bdi (backing_dev_info)
should be split and updated separately from matching blkg's.

This patch prepares by adding blkg->wb_congested and associating a
blkg with its matching per-blkcg bdi_writeback_congested on creation.

v2: Updated to associate bdi_writeback_congested instead of
    bdi_writeback.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>
---
 block/blk-cgroup.c         | 17 +++++++++++++++--
 include/linux/blk-cgroup.h |  6 ++++++
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 979cfdb..31610ae 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -182,6 +182,7 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 				    struct blkcg_gq *new_blkg)
 {
 	struct blkcg_gq *blkg;
+	struct bdi_writeback_congested *wb_congested;
 	int i, ret;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
@@ -193,22 +194,30 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 		goto err_free_blkg;
 	}
 
+	wb_congested = wb_congested_get_create(&q->backing_dev_info,
+					       blkcg->css.id, GFP_ATOMIC);
+	if (!wb_congested) {
+		ret = -ENOMEM;
+		goto err_put_css;
+	}
+
 	/* allocate */
 	if (!new_blkg) {
 		new_blkg = blkg_alloc(blkcg, q, GFP_ATOMIC);
 		if (unlikely(!new_blkg)) {
 			ret = -ENOMEM;
-			goto err_put_css;
+			goto err_put_congested;
 		}
 	}
 	blkg = new_blkg;
+	blkg->wb_congested = wb_congested;
 
 	/* link parent */
 	if (blkcg_parent(blkcg)) {
 		blkg->parent = __blkg_lookup(blkcg_parent(blkcg), q, false);
 		if (WARN_ON_ONCE(!blkg->parent)) {
 			ret = -EINVAL;
-			goto err_put_css;
+			goto err_put_congested;
 		}
 		blkg_get(blkg->parent);
 	}
@@ -245,6 +254,8 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 	blkg_put(blkg);
 	return ERR_PTR(ret);
 
+err_put_congested:
+	wb_congested_put(wb_congested);
 err_put_css:
 	css_put(&blkcg->css);
 err_free_blkg:
@@ -391,6 +402,8 @@ void __blkg_release_rcu(struct rcu_head *rcu_head)
 	if (blkg->parent)
 		blkg_put(blkg->parent);
 
+	wb_congested_put(blkg->wb_congested);
+
 	blkg_free(blkg);
 }
 EXPORT_SYMBOL_GPL(__blkg_release_rcu);
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 3033eb1..07a32b8 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -99,6 +99,12 @@ struct blkcg_gq {
 	struct hlist_node		blkcg_node;
 	struct blkcg			*blkcg;
 
+	/*
+	 * Each blkg gets congested separately and the congestion state is
+	 * propagated to the matching bdi_writeback_congested.
+	 */
+	struct bdi_writeback_congested	*wb_congested;
+
 	/* all non-root blkcg_gq's are guaranteed to have access to parent */
 	struct blkcg_gq			*parent;
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
