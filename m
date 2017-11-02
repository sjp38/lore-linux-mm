Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 464806B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 01:54:02 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u20so3298550qtu.0
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 22:54:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m9si2330127qke.204.2017.11.01.22.54.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 22:54:01 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA25rs4O093372
	for <linux-mm@kvack.org>; Thu, 2 Nov 2017 01:54:00 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dyvp1u8nf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Nov 2017 01:53:59 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 2 Nov 2017 05:53:56 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v3] pids: introduce find_get_task_by_vpid helper
Date: Thu,  2 Nov 2017 07:53:47 +0200
Message-Id: <1509602027-11337-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Tony Luck <tony.luck@intel.com>, Kees Cook <keescook@chromium.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

There are several functions that do find_task_by_vpid() followed by
get_task_struct(). We can use a helper function instead.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Oleg Nesterov <oleg@redhat.com>
---

v3: update arch/ia64/kernel/perfmon.c and security/yama/yama_lsm.c that
were missing in the previous versions
v2: remove  futex_find_get_task() and ptrace_get_task_struct() as Oleg
suggested

 arch/ia64/kernel/perfmon.c | 13 +++----------
 include/linux/sched.h      |  5 +++++
 kernel/futex.c             | 20 +-------------------
 kernel/pid.c               | 13 +++++++++++++
 kernel/ptrace.c            | 27 ++++++---------------------
 kernel/taskstats.c         |  6 +-----
 mm/process_vm_access.c     |  6 +-----
 security/yama/yama_lsm.c   | 11 +++--------
 8 files changed, 33 insertions(+), 68 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 09f86ebfcc7b..496b3f87ffab 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2610,17 +2610,10 @@ pfm_get_task(pfm_context_t *ctx, pid_t pid, struct task_struct **task)
 	if (pid < 2) return -EPERM;
 
 	if (pid != task_pid_vnr(current)) {
-
-		read_lock(&tasklist_lock);
-
-		p = find_task_by_vpid(pid);
-
 		/* make sure task cannot go away while we operate on it */
-		if (p) get_task_struct(p);
-
-		read_unlock(&tasklist_lock);
-
-		if (p == NULL) return -ESRCH;
+		p = find_get_task_by_vpid(pid);
+		if (!p)
+			return -ESRCH;
 	}
 
 	ret = pfm_task_incompatible(ctx, p);
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
index 0518a0bfc746..e2a160549a0c 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -862,24 +862,6 @@ static void put_pi_state(struct futex_pi_state *pi_state)
 	}
 }
 
-/*
- * Look up the task based on what TID userspace gave us.
- * We dont trust it.
- */
-static struct task_struct *futex_find_get_task(pid_t pid)
-{
-	struct task_struct *p;
-
-	rcu_read_lock();
-	p = find_task_by_vpid(pid);
-	if (p)
-		get_task_struct(p);
-
-	rcu_read_unlock();
-
-	return p;
-}
-
 #ifdef CONFIG_FUTEX_PI
 
 /*
@@ -1166,7 +1148,7 @@ static int attach_to_pi_owner(u32 uval, union futex_key *key,
 	 */
 	if (!pid)
 		return -ESRCH;
-	p = futex_find_get_task(pid);
+	p = find_get_task_by_vpid(pid);
 	if (!p)
 		return -ESRCH;
 
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
index 84b1367935e4..6f3de14313f5 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -1099,21 +1099,6 @@ int ptrace_request(struct task_struct *child, long request,
 	return ret;
 }
 
-static struct task_struct *ptrace_get_task_struct(pid_t pid)
-{
-	struct task_struct *child;
-
-	rcu_read_lock();
-	child = find_task_by_vpid(pid);
-	if (child)
-		get_task_struct(child);
-	rcu_read_unlock();
-
-	if (!child)
-		return ERR_PTR(-ESRCH);
-	return child;
-}
-
 #ifndef arch_ptrace_attach
 #define arch_ptrace_attach(child)	do { } while (0)
 #endif
@@ -1131,9 +1116,9 @@ SYSCALL_DEFINE4(ptrace, long, request, long, pid, unsigned long, addr,
 		goto out;
 	}
 
-	child = ptrace_get_task_struct(pid);
-	if (IS_ERR(child)) {
-		ret = PTR_ERR(child);
+	child = find_get_task_by_vpid(pid);
+	if (!child) {
+		ret = -ESRCH;
 		goto out;
 	}
 
@@ -1278,9 +1263,9 @@ COMPAT_SYSCALL_DEFINE4(ptrace, compat_long_t, request, compat_long_t, pid,
 		goto out;
 	}
 
-	child = ptrace_get_task_struct(pid);
-	if (IS_ERR(child)) {
-		ret = PTR_ERR(child);
+	child = find_get_task_by_vpid(pid);
+	if (!child) {
+		ret = -ESRCH;
 		goto out;
 	}
 
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
diff --git a/security/yama/yama_lsm.c b/security/yama/yama_lsm.c
index 8298e094f4f7..ffda91a4a1aa 100644
--- a/security/yama/yama_lsm.c
+++ b/security/yama/yama_lsm.c
@@ -250,15 +250,10 @@ int yama_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 		} else {
 			struct task_struct *tracer;
 
-			rcu_read_lock();
-			tracer = find_task_by_vpid(arg2);
-			if (tracer)
-				get_task_struct(tracer);
-			else
+			tracer = find_get_task_by_vpid(arg2);
+			if (!tracer) {
 				rc = -EINVAL;
-			rcu_read_unlock();
-
-			if (tracer) {
+			} else {
 				rc = yama_ptracer_add(tracer, myself);
 				put_task_struct(tracer);
 			}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
