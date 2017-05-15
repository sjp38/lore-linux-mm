Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B61406B02FA
	for <linux-mm@kvack.org>; Mon, 15 May 2017 09:34:48 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t26so46441264qtg.12
        for <linux-mm@kvack.org>; Mon, 15 May 2017 06:34:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s25si10583220qtb.260.2017.05.15.06.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 06:34:47 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH v2 06/17] cgroup: Fix reference counting bug in cgroup_procs_write()
Date: Mon, 15 May 2017 09:34:05 -0400
Message-Id: <1494855256-12558-7-git-send-email-longman@redhat.com>
In-Reply-To: <1494855256-12558-1-git-send-email-longman@redhat.com>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, longman@redhat.com

The cgroup_procs_write_start() took a reference to the task structure
which was not properly released within cgroup_procs_write() and so
on. So a put_task_struct() call is added to cgroup_procs_write_finish()
to match the get_task_struct() in cgroup_procs_write_start() to fix
this reference counting error.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/cgroup/cgroup-internal.h |  2 +-
 kernel/cgroup/cgroup-v1.c       |  2 +-
 kernel/cgroup/cgroup.c          | 10 ++++++----
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup/cgroup-internal.h b/kernel/cgroup/cgroup-internal.h
index f0a0dba..2c8e3a9 100644
--- a/kernel/cgroup/cgroup-internal.h
+++ b/kernel/cgroup/cgroup-internal.h
@@ -182,7 +182,7 @@ int cgroup_attach_task(struct cgroup *dst_cgrp, struct task_struct *leader,
 		       bool threadgroup);
 struct task_struct *cgroup_procs_write_start(char *buf, bool threadgroup)
 	__acquires(&cgroup_threadgroup_rwsem);
-void cgroup_procs_write_finish(void)
+void cgroup_procs_write_finish(struct task_struct *task)
 	__releases(&cgroup_threadgroup_rwsem);
 
 void cgroup_lock_and_drain_offline(struct cgroup *cgrp);
diff --git a/kernel/cgroup/cgroup-v1.c b/kernel/cgroup/cgroup-v1.c
index c212856..1e101b9 100644
--- a/kernel/cgroup/cgroup-v1.c
+++ b/kernel/cgroup/cgroup-v1.c
@@ -549,7 +549,7 @@ static ssize_t __cgroup1_procs_write(struct kernfs_open_file *of,
 	ret = cgroup_attach_task(cgrp, task, threadgroup);
 
 out_finish:
-	cgroup_procs_write_finish();
+	cgroup_procs_write_finish(task);
 out_unlock:
 	cgroup_kn_unlock(of->kn);
 
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index d7bab5e..f14deca 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -2492,12 +2492,15 @@ struct task_struct *cgroup_procs_write_start(char *buf, bool threadgroup)
 	return tsk;
 }
 
-void cgroup_procs_write_finish(void)
+void cgroup_procs_write_finish(struct task_struct *task)
 	__releases(&cgroup_threadgroup_rwsem)
 {
 	struct cgroup_subsys *ss;
 	int ssid;
 
+	/* release reference from cgroup_procs_write_start() */
+	put_task_struct(task);
+
 	percpu_up_write(&cgroup_threadgroup_rwsem);
 	for_each_subsys(ss, ssid)
 		if (ss->post_attach)
@@ -3300,7 +3303,6 @@ static int cgroup_addrm_files(struct cgroup_subsys_state *css,
 
 static int cgroup_apply_cftypes(struct cftype *cfts, bool is_add)
 {
-	LIST_HEAD(pending);
 	struct cgroup_subsys *ss = cfts[0].ss;
 	struct cgroup *root = &ss->root->cgrp;
 	struct cgroup_subsys_state *css;
@@ -4065,7 +4067,7 @@ static ssize_t cgroup_procs_write(struct kernfs_open_file *of,
 	ret = cgroup_attach_task(cgrp, task, true);
 
 out_finish:
-	cgroup_procs_write_finish();
+	cgroup_procs_write_finish(task);
 out_unlock:
 	cgroup_kn_unlock(of->kn);
 
@@ -4135,7 +4137,7 @@ static ssize_t cgroup_threads_write(struct kernfs_open_file *of,
 	ret = cgroup_attach_task(cgrp, task, false);
 
 out_finish:
-	cgroup_procs_write_finish();
+	cgroup_procs_write_finish(task);
 out_unlock:
 	cgroup_kn_unlock(of->kn);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
