Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 62A97829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:14:32 -0400 (EDT)
Received: by qgew3 with SMTP id w3so16197052qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:32 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id u191si746238qhd.19.2015.05.22.14.14.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:14:31 -0700 (PDT)
Received: by qgew3 with SMTP id w3so16196792qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:31 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 09/51] blkcg: implement task_get_blkcg_css()
Date: Fri, 22 May 2015 17:13:23 -0400
Message-Id: <1432329245-5844-10-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

Implement a wrapper around task_get_css() to acquire the blkcg css for
a given task.  The wrapper is necessary for cgroup writeback support
as there will be places outside blkcg proper trying to acquire
blkcg_css and blkio_cgrp_id will be undefined when !CONFIG_BLK_CGROUP.

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
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
