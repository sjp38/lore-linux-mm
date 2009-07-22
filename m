Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2B08F6B00C2
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:25 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 29/60] c/r: Save and restore the [compat_]robust_list member of the task struct
Date: Wed, 22 Jul 2009 05:59:51 -0400
Message-Id: <1248256822-23416-30-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Matt Helsley <matthltc@us.ibm.com>
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

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
[orenl@cs.columbia.edu: move save/restore code to checkpoint/process.c]
---
 checkpoint/process.c           |   48 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    5 ++++
 include/linux/compat.h         |    3 +-
 include/linux/futex.h          |    1 +
 kernel/futex.c                 |   19 ++++++++++-----
 kernel/futex_compat.c          |   13 ++++++++--
 6 files changed, 78 insertions(+), 11 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index a67c389..9e459c6 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -18,6 +18,52 @@
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
@@ -46,6 +92,7 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 
 		h->set_child_tid = t->set_child_tid;
 		h->clear_child_tid = t->clear_child_tid;
+		save_task_robust_futex_list(h, t);
 	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
@@ -244,6 +291,7 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 
 		t->set_child_tid = h->set_child_tid;
 		t->clear_child_tid = h->clear_child_tid;
+		restore_task_robust_futex_list(h);
 	}
 
 	memset(t->comm, 0, TASK_COMM_LEN);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 3f2db22..ad5851d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -134,6 +134,11 @@ struct ckpt_hdr_task {
 
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
+
+	__u32 compat_robust_futex_head_len;
+	__u32 compat_robust_futex_list; /* a compat __user ptr */
+	__u32 robust_futex_head_len;
+	__u64 robust_futex_list; /* a __user ptr */
 } __attribute__((aligned(8)));
 
 /* restart blocks */
diff --git a/include/linux/compat.h b/include/linux/compat.h
index af931ee..f444cf0 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -165,7 +165,8 @@ struct compat_robust_list_head {
 };
 
 extern void compat_exit_robust_list(struct task_struct *curr);
-
+extern long do_compat_set_robust_list(struct compat_robust_list_head __user *head,
+				      compat_size_t len);
 asmlinkage long
 compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
 			   compat_size_t len);
diff --git a/include/linux/futex.h b/include/linux/futex.h
index 4326f81..2e126a9 100644
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
index dfe246f..57a46c9 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -2261,13 +2261,7 @@ out:
  * the list. There can only be one such pending lock.
  */
 
-/**
- * sys_set_robust_list - set the robust-futex list head of a task
- * @head: pointer to the list-head
- * @len: length of the list-head, as userspace expects
- */
-SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
-		size_t, len)
+long do_set_robust_list(struct robust_list_head __user *head, size_t len)
 {
 	if (!futex_cmpxchg_enabled)
 		return -ENOSYS;
@@ -2283,6 +2277,17 @@ SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
 }
 
 /**
+ * sys_set_robust_list - set the robust-futex list head of a task
+ * @head: pointer to the list-head
+ * @len: length of the list-head, as userspace expects
+ */
+SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
+		size_t, len)
+{
+	return do_set_robust_list(head, len);
+}
+
+/**
  * sys_get_robust_list - get the robust-futex list head of a task
  * @pid: pid of the process [zero for current task]
  * @head_ptr: pointer to a list-head pointer, the kernel fills it in
diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
index d607a5b..eac734c 100644
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
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
