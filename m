Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4736B0072
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:55:21 -0400 (EDT)
Received: by qgep97 with SMTP id p97so5685337qge.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:21 -0700 (PDT)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com. [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id u194si11178617qhd.72.2015.03.22.21.55.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:55:16 -0700 (PDT)
Received: by qcbkw5 with SMTP id kw5so136820277qcb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:16 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 05/48] blkcg: add blkcg_root_css
Date: Mon, 23 Mar 2015 00:54:16 -0400
Message-Id: <1427086499-15657-6-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Add global constant blkcg_root_css which points to &blkcg_root.css.
This will be used by cgroup writeback support.  If blkcg is disabled,
it's defined as ERR_PTR(-EINVAL).

v2: The declarations moved to include/linux/blk-cgroup.h as suggested
    by Vivek.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>
---
 block/blk-cgroup.c         | 2 ++
 include/linux/blk-cgroup.h | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index c3226ce..9e0fe38 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -30,6 +30,8 @@ struct blkcg blkcg_root = { .cfq_weight = 2 * CFQ_WEIGHT_DEFAULT,
 			    .cfq_leaf_weight = 2 * CFQ_WEIGHT_DEFAULT, };
 EXPORT_SYMBOL_GPL(blkcg_root);
 
+struct cgroup_subsys_state * const blkcg_root_css = &blkcg_root.css;
+
 static struct blkcg_policy *blkcg_policy[BLKCG_MAX_POLS];
 
 static bool blkcg_policy_enabled(struct request_queue *q,
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 51f95b3..65f0c17 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -134,6 +134,7 @@ struct blkcg_policy {
 };
 
 extern struct blkcg blkcg_root;
+extern struct cgroup_subsys_state * const blkcg_root_css;
 
 struct blkcg_gq *blkg_lookup(struct blkcg *blkcg, struct request_queue *q);
 struct blkcg_gq *blkg_lookup_create(struct blkcg *blkcg,
@@ -570,6 +571,8 @@ struct blkcg_gq {
 struct blkcg_policy {
 };
 
+#define blkcg_root_css	((struct cgroup_subsys_state *)ERR_PTR(-EINVAL))
+
 #ifdef CONFIG_BLOCK
 
 static inline struct blkcg_gq *blkg_lookup(struct blkcg *blkcg, void *key) { return NULL; }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
