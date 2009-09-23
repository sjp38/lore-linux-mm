Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D22DD6B0092
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:29 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 64/80] c/r: [signal 2/4] checkpoint/restart of rlimit
Date: Wed, 23 Sep 2009 19:51:44 -0400
Message-Id: <1253749920-18673-65-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This patch adds checkpoint and restart of rlimit information
that is part of shared signal_struct.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Louis Rilling <Louis.Rilling@kerlabs.com>
---
 checkpoint/checkpoint.c        |    2 ++
 checkpoint/restart.c           |    3 +++
 checkpoint/signal.c            |   27 +++++++++++++++++++++++----
 include/linux/checkpoint_hdr.h |   17 +++++++++++++++++
 include/linux/resource.h       |    4 ++++
 kernel/sys.c                   |   36 +++++++++++++++++++++++-------------
 6 files changed, 72 insertions(+), 17 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 3460c03..ae79df7 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -297,6 +297,8 @@ static void fill_kernel_const(struct ckpt_const *h)
 	h->uts_version_len = sizeof(uts->version);
 	h->uts_machine_len = sizeof(uts->machine);
 	h->uts_domainname_len = sizeof(uts->domainname);
+	/* rlimit */
+	h->rlimit_nlimits = RLIM_NLIMITS;
 }
 
 /* write the checkpoint header */
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 73c4e72..340698a 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -399,6 +399,9 @@ static int check_kernel_const(struct ckpt_const *h)
 		return -EINVAL;
 	if (h->uts_domainname_len != sizeof(uts->domainname))
 		return -EINVAL;
+	/* rlimit */
+	if (h->rlimit_nlimits != RLIM_NLIMITS)
+		return -EINVAL;
 
 	return 0;
 }
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 3fac75c..04013ef 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -14,6 +14,7 @@
 #include <linux/sched.h>
 #include <linux/signal.h>
 #include <linux/errno.h>
+#include <linux/resource.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -169,13 +170,22 @@ int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
 static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_signal *h;
+	struct signal_struct *signal;
+	struct rlimit *rlim;
 	int ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
 	if (!h)
 		return -ENOMEM;
 
-	/* fill in later */
+	signal = t->signal;
+	rlim = signal->rlim;
+
+	/* rlimit */
+	for (i = 0; i < RLIM_NLIMITS; i++) {
+		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
+		h->rlim[i].rlim_max = rlim[i].rlim_max;
+	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -191,15 +201,24 @@ int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 static int restore_signal(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_signal *h;
+	struct rlimit rlim;
+	int i, ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	/* fill in later */
-
+	/* rlimit */
+	for (i = 0; i < RLIM_NLIMITS; i++) {
+		rlim.rlim_cur = h->rlim[i].rlim_cur;
+		rlim.rlim_max = h->rlim[i].rlim_max;
+		ret = do_setrlimit(i, &rlim);
+		if (ret < 0)
+			break;
+	}
+ out:
 	ckpt_hdr_put(ctx, h);
-	return 0;
+	return ret;
 }
 
 int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index ee949b5..203b4ee 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -144,6 +144,8 @@ struct ckpt_const {
 	__u16 uts_version_len;
 	__u16 uts_machine_len;
 	__u16 uts_domainname_len;
+	/* rlimit */
+	__u16 rlimit_nlimits;
 } __attribute__((aligned(8)));
 
 /* checkpoint image header */
@@ -440,8 +442,23 @@ struct ckpt_hdr_sighand {
 	struct ckpt_sigaction action[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_rlimit {
+	__u64 rlim_cur;
+	__u64 rlim_max;
+} __attribute__((aligned(8)));
+
+/* cannot include <linux/resource.h> from userspace, so define: */
+#define CKPT_RLIM_NLIMITS  16
+#ifdef __KERNEL__
+#include <linux/resource.h>
+#if CKPT_RLIM_NLIMITS != RLIM_NLIMITS
+#error CKPT_RLIM_NLIMIT size is wrong per asm-generic/resource.h
+#endif
+#endif
+
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
+	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
diff --git a/include/linux/resource.h b/include/linux/resource.h
index 40fc7e6..87e1bf3 100644
--- a/include/linux/resource.h
+++ b/include/linux/resource.h
@@ -72,4 +72,8 @@ struct rlimit {
 
 int getrusage(struct task_struct *p, int who, struct rusage __user *ru);
 
+#ifdef __KERNEL__
+extern int do_setrlimit(unsigned int resource, struct rlimit *rlim);
+#endif
+
 #endif
diff --git a/kernel/sys.c b/kernel/sys.c
index da4f9e0..0979a3f 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1144,40 +1144,39 @@ SYSCALL_DEFINE2(old_getrlimit, unsigned int, resource,
 
 #endif
 
-SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
+int do_setrlimit(unsigned int resource, struct rlimit *new_rlim)
 {
-	struct rlimit new_rlim, *old_rlim;
+	struct rlimit *old_rlim;
 	int retval;
 
 	if (resource >= RLIM_NLIMITS)
 		return -EINVAL;
-	if (copy_from_user(&new_rlim, rlim, sizeof(*rlim)))
-		return -EFAULT;
-	if (new_rlim.rlim_cur > new_rlim.rlim_max)
+	if (new_rlim->rlim_cur > new_rlim->rlim_max)
 		return -EINVAL;
+
 	old_rlim = current->signal->rlim + resource;
-	if ((new_rlim.rlim_max > old_rlim->rlim_max) &&
+	if ((new_rlim->rlim_max > old_rlim->rlim_max) &&
 	    !capable(CAP_SYS_RESOURCE))
 		return -EPERM;
-	if (resource == RLIMIT_NOFILE && new_rlim.rlim_max > sysctl_nr_open)
+	if (resource == RLIMIT_NOFILE && new_rlim->rlim_max > sysctl_nr_open)
 		return -EPERM;
 
-	retval = security_task_setrlimit(resource, &new_rlim);
+	retval = security_task_setrlimit(resource, new_rlim);
 	if (retval)
 		return retval;
 
-	if (resource == RLIMIT_CPU && new_rlim.rlim_cur == 0) {
+	if (resource == RLIMIT_CPU && new_rlim->rlim_cur == 0) {
 		/*
 		 * The caller is asking for an immediate RLIMIT_CPU
 		 * expiry.  But we use the zero value to mean "it was
 		 * never set".  So let's cheat and make it one second
 		 * instead
 		 */
-		new_rlim.rlim_cur = 1;
+		new_rlim->rlim_cur = 1;
 	}
 
 	task_lock(current->group_leader);
-	*old_rlim = new_rlim;
+	*old_rlim = *new_rlim;
 	task_unlock(current->group_leader);
 
 	if (resource != RLIMIT_CPU)
@@ -1189,14 +1188,25 @@ SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
 	 * very long-standing error, and fixing it now risks breakage of
 	 * applications, so we live with it
 	 */
-	if (new_rlim.rlim_cur == RLIM_INFINITY)
+	if (new_rlim->rlim_cur == RLIM_INFINITY)
 		goto out;
 
-	update_rlimit_cpu(new_rlim.rlim_cur);
+	update_rlimit_cpu(new_rlim->rlim_cur);
 out:
 	return 0;
 }
 
+SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
+{
+	struct rlimit new_rlim;
+
+	if (resource >= RLIM_NLIMITS)
+		return -EINVAL;
+	if (copy_from_user(&new_rlim, rlim, sizeof(*rlim)))
+		return -EFAULT;
+	return do_setrlimit(resource, &new_rlim);
+}
+
 /*
  * It would make sense to put struct rusage in the task_struct,
  * except that would make the task_struct be *really big*.  After
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
