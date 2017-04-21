Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BAC16B03A2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:05:01 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u68so22863337qkd.20
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:05:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x70si533109qkx.312.2017.04.21.07.04.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:05:00 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 06/14] cgroup: Fix reference counting bug in cgroup_procs_write()
Date: Fri, 21 Apr 2017 10:04:04 -0400
Message-Id: <1492783452-12267-7-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, Waiman Long <longman@redhat.com>

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
index 6ef662a..bea3928 100644
--- a/kernel/cgroup/cgroup-internal.h
+++ b/kernel/cgroup/cgroup-internal.h
@@ -181,7 +181,7 @@ int cgroup_attach_task(struct cgroup *dst_cgrp, struct task_struct *leader,
 		       bool threadgroup);
 struct task_struct *cgroup_procs_write_start(char *buf, bool threadgroup)
 	__acquires(&cgroup_threadgroup_rwsem);
-void cgroup_procs_write_finish(void)
+void cgroup_procs_write_finish(struct task_struct *task)
 	__releases(&cgroup_threadgroup_rwsem);
 
 void cgroup_lock_and_drain_offline(struct cgroup *cgrp);
diff --git a/kernel/cgroup/cgroup-v1.c b/kernel/cgroup/cgroup-v1.c
index b837e1a..e80bc8e 100644
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
index 6748207..d48eedd 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -2487,12 +2487,15 @@ struct task_struct *cgroup_procs_write_start(char *buf, bool threadgroup)
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
@@ -3295,7 +3298,6 @@ static int cgroup_addrm_files(struct cgroup_subsys_state *css,
 
 static int cgroup_apply_cftypes(struct cftype *cfts, bool is_add)
 {
-	LIST_HEAD(pending);
 	struct cgroup_subsys *ss = cfts[0].ss;
 	struct cgroup *root = &ss->root->cgrp;
 	struct cgroup_subsys_state *css;
@@ -4060,7 +4062,7 @@ static ssize_t cgroup_procs_write(struct kernfs_open_file *of,
 	ret = cgroup_attach_task(cgrp, task, true);
 
 out_finish:
-	cgroup_procs_write_finish();
+	cgroup_procs_write_finish(task);
 out_unlock:
 	cgroup_kn_unlock(of->kn);
 
@@ -4130,7 +4132,7 @@ static ssize_t cgroup_threads_write(struct kernfs_open_file *of,
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
