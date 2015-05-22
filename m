Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 37D83829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:14:30 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so22232597qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:30 -0700 (PDT)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id z92si1638209qgd.1.2015.05.22.14.14.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:14:29 -0700 (PDT)
Received: by qgew3 with SMTP id w3so16196342qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:29 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 08/51] cgroup, block: implement task_get_css() and use it in bio_associate_current()
Date: Fri, 22 May 2015 17:13:22 -0400
Message-Id: <1432329245-5844-9-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

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
index c2ff8a8..cb7faac 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -2011,7 +2011,6 @@ EXPORT_SYMBOL(bioset_create_nobvec);
 int bio_associate_current(struct bio *bio)
 {
 	struct io_context *ioc;
-	struct cgroup_subsys_state *css;
 
 	if (bio->bi_ioc)
 		return -EBUSY;
@@ -2020,17 +2019,9 @@ int bio_associate_current(struct bio *bio)
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
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
