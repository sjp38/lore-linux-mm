Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD026B025F
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:10:35 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l85so2372294qkh.19
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:10:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z8si4437847qkz.250.2017.10.26.06.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 06:10:34 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9QD9tY5078251
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:10:33 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dudc69rs2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:10:31 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Oct 2017 14:08:15 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] pids: introduce find_get_task_by_vpid helper
Date: Thu, 26 Oct 2017 16:07:58 +0300
Message-Id: <1509023278-20604-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

There are several functions that do find_task_by_vpid() followed by
get_task_struct(). We can use a helper function instead.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/sched.h  |  5 +++++
 kernel/futex.c         |  7 +------
 kernel/pid.c           | 13 +++++++++++++
 kernel/ptrace.c        |  6 +-----
 kernel/taskstats.c     |  6 +-----
 mm/process_vm_access.c |  6 +-----
 6 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 26a7df4e558c..4c3af5255fcf 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1484,6 +1484,11 @@ static inline struct thread_info *task_thread_info(struct task_struct *task)
 extern struct task_struct *find_task_by_vpid(pid_t nr);
 extern struct task_struct *find_task_by_pid_ns(pid_t nr, struct pid_namespace *ns);
 
+/*
+ * find a task by its virtual pid and get the task struct
+ */
+extern struct task_struct *find_get_task_by_vpid(pid_t nr);
+
 extern int wake_up_state(struct task_struct *tsk, unsigned int state);
 extern int wake_up_process(struct task_struct *tsk);
 extern void wake_up_new_task(struct task_struct *tsk);
diff --git a/kernel/futex.c b/kernel/futex.c
index 0518a0bfc746..6446aa9f2288 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -870,12 +870,7 @@ static struct task_struct *futex_find_get_task(pid_t pid)
 {
 	struct task_struct *p;
 
-	rcu_read_lock();
-	p = find_task_by_vpid(pid);
-	if (p)
-		get_task_struct(p);
-
-	rcu_read_unlock();
+	p = find_get_task_by_vpid(pid);
 
 	return p;
 }
diff --git a/kernel/pid.c b/kernel/pid.c
index 020dedbdf066..ead086b0ef8e 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -462,6 +462,19 @@ struct task_struct *find_task_by_vpid(pid_t vnr)
 	return find_task_by_pid_ns(vnr, task_active_pid_ns(current));
 }
 
+struct task_struct *find_get_task_by_vpid(pid_t nr)
+{
+	struct task_struct *task;
+
+	rcu_read_lock();
+	task = find_task_by_vpid(nr);
+	if (task)
+		get_task_struct(task);
+	rcu_read_unlock();
+
+	return task;
+}
+
 struct pid *get_task_pid(struct task_struct *task, enum pid_type type)
 {
 	struct pid *pid;
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 84b1367935e4..91efc97674ce 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -1103,11 +1103,7 @@ static struct task_struct *ptrace_get_task_struct(pid_t pid)
 {
 	struct task_struct *child;
 
-	rcu_read_lock();
-	child = find_task_by_vpid(pid);
-	if (child)
-		get_task_struct(child);
-	rcu_read_unlock();
+	child = find_get_task_by_vpid(pid);
 
 	if (!child)
 		return ERR_PTR(-ESRCH);
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index 4559e914452b..4e62a4a8fa91 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -194,11 +194,7 @@ static int fill_stats_for_pid(pid_t pid, struct taskstats *stats)
 {
 	struct task_struct *tsk;
 
-	rcu_read_lock();
-	tsk = find_task_by_vpid(pid);
-	if (tsk)
-		get_task_struct(tsk);
-	rcu_read_unlock();
+	tsk = find_get_task_by_vpid(pid);
 	if (!tsk)
 		return -ESRCH;
 	fill_stats(current_user_ns(), task_active_pid_ns(current), tsk, stats);
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 8973cd231ece..16424b9ae424 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -197,11 +197,7 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
 	}
 
 	/* Get process information */
-	rcu_read_lock();
-	task = find_task_by_vpid(pid);
-	if (task)
-		get_task_struct(task);
-	rcu_read_unlock();
+	task = find_get_task_by_vpid(pid);
 	if (!task) {
 		rc = -ESRCH;
 		goto free_proc_pages;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
