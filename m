Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 179CB6B00F3
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 14:29:35 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id z107so6115409qgd.18
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:34 -0800 (PST)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id h76si34329102qge.54.2015.01.06.11.29.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 11:29:30 -0800 (PST)
Received: by mail-qg0-f45.google.com with SMTP id z107so6105867qgd.32
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:30 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 05/16] blkcg: implement task_get_blkcg_css()
Date: Tue,  6 Jan 2015 14:29:06 -0500
Message-Id: <1420572557-11572-6-git-send-email-tj@kernel.org>
In-Reply-To: <1420572557-11572-1-git-send-email-tj@kernel.org>
References: <1420572557-11572-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, Tejun Heo <tj@kernel.org>

Implement a wrapper around task_get_css() to acquire the blkcg css for
a given task.  The wrapper is necessary for !CONFIG_BLK_CGROUP as
blkio_cgrp_id would be undefined.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/blk-cgroup.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 65f0c17..4dc643f 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -195,6 +195,12 @@ static inline struct blkcg *bio_blkcg(struct bio *bio)
 	return task_blkcg(current);
 }
 
+static inline struct cgroup_subsys_state *
+task_get_blkcg_css(struct task_struct *task)
+{
+	return task_get_css(task, blkio_cgrp_id);
+}
+
 /**
  * blkcg_parent - get the parent of a blkcg
  * @blkcg: blkcg of interest
@@ -573,6 +579,12 @@ struct blkcg_policy {
 
 #define blkcg_root_css	((struct cgroup_subsys_state *)ERR_PTR(-EINVAL))
 
+static inline struct cgroup_subsys_state *
+task_get_blkcg_css(struct task_struct *task)
+{
+	return NULL;
+}
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
