Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D9C716B0214
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:11 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 33/96] c/r: Save and restore the [compat_]robust_list member of the task struct
Date: Wed, 17 Mar 2010 12:08:21 -0400
Message-Id: <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Matt Helsley <matthltc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Matt Helsley <matthltc@us.ibm.com>

These lists record which futexes the task holds. To keep the overhead of
robust futexes low the list is kept in userspace. When the task exits the
kernel carefully walks these lists to recover held futexes that
other tasks may be attempting to acquire with FUTEX_WAIT.

Because they point to userspace memory that is saved/restored by
checkpoint/restart saving the list pointers themselves is safe.

While saving the pointers is safe during checkpoint, restart is tricky
because the robust futex ABI contains provisions for changes based on
checking the size of the list head. So we need to save the length of
the list head too in order to make sure that the kernel used during
restart is capable of handling that ABI. Since there is only one ABI
supported at the moment taking the list head's size is simple. Should
the ABI change we will need to use the same size as specified during
sys_set_robust_list() and hence some new means of determining the length
of this userspace structure in sys_checkpoint would be required.

Rather than rewrite the logic that checks and handles the ABI we reuse
sys_set_robust_list() by factoring out the body of the function and
calling it during restart.

Changelog [v19]:
  - Keep __u32s in even groups for 32-64 bit compatibility

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
[orenl@cs.columbia.edu: move save/restore code to checkpoint/process.c]
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/process.c           |   49 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    5 ++++
 include/linux/compat.h         |    3 +-
 include/linux/futex.h          |    1 +
 kernel/futex.c                 |   19 +++++++++-----
 kernel/futex_compat.c          |   13 ++++++++--
 6 files changed, 79 insertions(+), 11 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index c47dea1..f36e320 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -14,10 +14,57 @@
 #include <linux/sched.h>
 #include <linux/posix-timers.h>
 #include <linux/futex.h>
+#include <linux/compat.h>
 #include <linux/poll.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+
+#ifdef CONFIG_FUTEX
+static void save_task_robust_futex_list(struct ckpt_hdr_task *h,
+					struct task_struct *t)
+{
+	/*
+	 * These are __user pointers and thus can be saved without
+	 * the objhash.
+	 */
+	h->robust_futex_list = (unsigned long)t->robust_list;
+	h->robust_futex_head_len = sizeof(*t->robust_list);
+#ifdef CONFIG_COMPAT
+	h->compat_robust_futex_list = ptr_to_compat(t->compat_robust_list);
+	h->compat_robust_futex_head_len = sizeof(*t->compat_robust_list);
+#endif
+}
+
+static void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
+{
+	/* Since we restore the memory map the address remains the same and
+	 * this is safe. This is the same as [compat_]sys_set_robust_list() */
+	if (h->robust_futex_list) {
+		struct robust_list_head __user *rfl;
+		rfl = (void __user *)(unsigned long) h->robust_futex_list;
+		do_set_robust_list(rfl, h->robust_futex_head_len);
+	}
+#ifdef CONFIG_COMPAT
+	if (h->compat_robust_futex_list) {
+		struct compat_robust_list_head __user *crfl;
+		crfl = compat_ptr(h->compat_robust_futex_list);
+		do_compat_set_robust_list(crfl, h->compat_robust_futex_head_len);
+	}
+#endif
+}
+#else /* !CONFIG_FUTEX */
+static inline void save_task_robust_futex_list(struct ckpt_hdr_task *h,
+					       struct task_struct *t)
+{
+}
+
+static inline void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
+{
+}
+#endif /* CONFIG_FUTEX */
+
+
 /***********************************************************************
  * Checkpoint
  */
@@ -46,6 +93,7 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 
 		h->set_child_tid = (unsigned long) t->set_child_tid;
 		h->clear_child_tid = (unsigned long) t->clear_child_tid;
+		save_task_robust_futex_list(h, t);
 	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
@@ -249,6 +297,7 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 			(int __user *) (unsigned long) h->set_child_tid;
 		t->clear_child_tid =
 			(int __user *) (unsigned long) h->clear_child_tid;
+		restore_task_robust_futex_list(h);
 	}
 
 	memset(t->comm, 0, TASK_COMM_LEN);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index f85b673..651255f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -162,6 +162,11 @@ struct ckpt_hdr_task {
 	__u32 exit_signal;
 	__u32 pdeath_signal;
 
+	__u32 compat_robust_futex_head_len;
+	__u32 compat_robust_futex_list; /* a compat __user ptr */
+	__u32 robust_futex_head_len;
+	__u64 robust_futex_list; /* a __user ptr */
+
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
 } __attribute__((aligned(8)));
diff --git a/include/linux/compat.h b/include/linux/compat.h
index ef68119..50ef270 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -209,7 +209,8 @@ struct compat_robust_list_head {
 };
 
 extern void compat_exit_robust_list(struct task_struct *curr);
-
+extern long do_compat_set_robust_list(struct compat_robust_list_head __user *head,
+				      compat_size_t len);
 asmlinkage long
 compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
 			   compat_size_t len);
diff --git a/include/linux/futex.h b/include/linux/futex.h
index ae755f6..c825790 100644
--- a/include/linux/futex.h
+++ b/include/linux/futex.h
@@ -185,6 +185,7 @@ union futex_key {
 #define FUTEX_KEY_INIT (union futex_key) { .both = { .ptr = NULL } }
 
 #ifdef CONFIG_FUTEX
+extern long do_set_robust_list(struct robust_list_head __user *head, size_t len);
 extern void exit_robust_list(struct task_struct *curr);
 extern void exit_pi_state_list(struct task_struct *curr);
 extern int futex_cmpxchg_enabled;
diff --git a/kernel/futex.c b/kernel/futex.c
index 23419c9..baaecb4 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -2342,13 +2342,7 @@ out:
  * the list. There can only be one such pending lock.
  */
 
-/**
- * sys_set_robust_list() - Set the robust-futex list head of a task
- * @head:	pointer to the list-head
- * @len:	length of the list-head, as userspace expects
- */
-SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
-		size_t, len)
+long do_set_robust_list(struct robust_list_head __user *head, size_t len)
 {
 	if (!futex_cmpxchg_enabled)
 		return -ENOSYS;
@@ -2364,6 +2358,17 @@ SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
 }
 
 /**
+ * sys_set_robust_list() - Set the robust-futex list head of a task
+ * @head:	pointer to the list-head
+ * @len:	length of the list-head, as userspace expects
+ */
+SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
+		size_t, len)
+{
+	return do_set_robust_list(head, len);
+}
+
+/**
  * sys_get_robust_list() - Get the robust-futex list head of a task
  * @pid:	pid of the process [zero for current task]
  * @head_ptr:	pointer to a list-head pointer, the kernel fills it in
diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
index 2357165..5e1a169 100644
--- a/kernel/futex_compat.c
+++ b/kernel/futex_compat.c
@@ -114,9 +114,9 @@ void compat_exit_robust_list(struct task_struct *curr)
 	}
 }
 
-asmlinkage long
-compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
-			   compat_size_t len)
+long
+do_compat_set_robust_list(struct compat_robust_list_head __user *head,
+			  compat_size_t len)
 {
 	if (!futex_cmpxchg_enabled)
 		return -ENOSYS;
@@ -130,6 +130,13 @@ compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
 }
 
 asmlinkage long
+compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
+			   compat_size_t len)
+{
+	return do_compat_set_robust_list(head, len);
+}
+
+asmlinkage long
 compat_sys_get_robust_list(int pid, compat_uptr_t __user *head_ptr,
 			   compat_size_t __user *len_ptr)
 {
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
