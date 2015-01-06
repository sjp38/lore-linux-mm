Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id ECFF26B00F1
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 14:29:32 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id i50so16797198qgf.38
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:32 -0800 (PST)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com. [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id u46si22366909qge.42.2015.01.06.11.29.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 11:29:28 -0800 (PST)
Received: by mail-qc0-f178.google.com with SMTP id p6so1323642qcv.9
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:28 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 04/16] cgroup, block: implement task_get_css() and use it in bio_associate_current()
Date: Tue,  6 Jan 2015 14:29:05 -0500
Message-Id: <1420572557-11572-5-git-send-email-tj@kernel.org>
In-Reply-To: <1420572557-11572-1-git-send-email-tj@kernel.org>
References: <1420572557-11572-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, Tejun Heo <tj@kernel.org>

bio_associate_current() currently open codes task_css() and
css_tryget_online() to find and pin $current's blkcg css.  Abstract it
into task_get_css() which is implemented from cgroup side.  As a task
is always associated with an online css for every subsystem except
while the css_set update is propagating, task_get_css() retries till
css_tryget_online() succeeds.

This is a cleanup and shouldn't lead to noticeable behavior changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Vivek Goyal <vgoyal@redhat.com>
---
 block/bio.c            | 11 +----------
 include/linux/cgroup.h | 25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 471d738..a1e0b00 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -2031,7 +2031,6 @@ EXPORT_SYMBOL(bioset_create_nobvec);
 int bio_associate_current(struct bio *bio)
 {
 	struct io_context *ioc;
-	struct cgroup_subsys_state *css;
 
 	if (bio->bi_ioc)
 		return -EBUSY;
@@ -2040,17 +2039,9 @@ int bio_associate_current(struct bio *bio)
 	if (!ioc)
 		return -ENOENT;
 
-	/* acquire active ref on @ioc and associate */
 	get_io_context_active(ioc);
 	bio->bi_ioc = ioc;
-
-	/* associate blkcg if exists */
-	rcu_read_lock();
-	css = task_css(current, blkio_cgrp_id);
-	if (css && css_tryget_online(css))
-		bio->bi_css = css;
-	rcu_read_unlock();
-
+	bio->bi_css = task_get_css(current, blkio_cgrp_id);
 	return 0;
 }
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b9cb94c..e7da0aa 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -774,6 +774,31 @@ static inline struct cgroup_subsys_state *task_css(struct task_struct *task,
 }
 
 /**
+ * task_get_css - find and get the css for (task, subsys)
+ * @task: the target task
+ * @subsys_id: the target subsystem ID
+ *
+ * Find the css for the (@task, @subsys_id) combination, increment a
+ * reference on and return it.  This function is guaranteed to return a
+ * valid css.
+ */
+static inline struct cgroup_subsys_state *
+task_get_css(struct task_struct *task, int subsys_id)
+{
+	struct cgroup_subsys_state *css;
+
+	rcu_read_lock();
+	while (true) {
+		css = task_css(task, subsys_id);
+		if (likely(css_tryget_online(css)))
+			break;
+		cpu_relax();
+	}
+	rcu_read_unlock();
+	return css;
+}
+
+/**
  * task_css_is_root - test whether a task belongs to the root css
  * @task: the target task
  * @subsys_id: the target subsystem ID
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
