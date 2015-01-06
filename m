Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8A84B6B012D
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:41 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id s7so242522qap.0
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:41 -0800 (PST)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id bh8si1497955qcb.45.2015.01.06.13.26.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:40 -0800 (PST)
Received: by mail-qg0-f46.google.com with SMTP id q107so74649qgd.5
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:40 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 06/45] writeback, blkcg: associate each blkcg_gq with the corresponding bdi_writeback
Date: Tue,  6 Jan 2015 16:25:43 -0500
Message-Id: <1420579582-8516-7-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

A blkg (blkcg_gq) can be congested and decongested independently from
other blkgs on the same request_queue.  Accordingly, for cgroup
writeback support, the congestion status at bdi (backing_dev_info)
should be split to per-cgroup wb's (bdi_writeback's) and updated
separately from matching blkg's.

This patch prepares by adding blkg->wb and associating a blkg with its
matching per-cgroup wb on creation.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>
---
 block/blk-cgroup.c         | 15 +++++++++++++++
 include/linux/blk-cgroup.h |  6 ++++++
 2 files changed, 21 insertions(+)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 8bebaa9..6fe085c 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -182,6 +182,7 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 				    struct blkcg_gq *new_blkg)
 {
 	struct blkcg_gq *blkg;
+	struct bdi_writeback *wb;
 	int i, ret;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
@@ -193,6 +194,19 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 		goto err_free_blkg;
 	}
 
+	/*
+	 * Once created, @wb will stay alive longer than @blkg.  @wb is
+	 * destroyed iff either its bdi or @blkcg is destroyed.  The bdi is
+	 * part of the request_queue and will outlive @blkg, and, while
+	 * @blkcg is being brought down, @wb will be destroyed the last in
+	 * ->css_released().
+	 */
+	wb = cgwb_lookup_create(&q->backing_dev_info, &blkcg->css);
+	if (!wb) {
+		ret = -ENOMEM;
+		goto err_free_blkg;
+	}
+
 	/* allocate */
 	if (!new_blkg) {
 		new_blkg = blkg_alloc(blkcg, q, GFP_ATOMIC);
@@ -202,6 +216,7 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 		}
 	}
 	blkg = new_blkg;
+	blkg->wb = wb;
 
 	/* link parent */
 	if (blkcg_parent(blkcg)) {
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 3033eb1..97ceee3 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -99,6 +99,12 @@ struct blkcg_gq {
 	struct hlist_node		blkcg_node;
 	struct blkcg			*blkcg;
 
+	/*
+	 * Each blkg gets congested separately and the congestion state is
+	 * propagated to the matching cgroup wb.
+	 */
+	struct bdi_writeback		*wb;
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
