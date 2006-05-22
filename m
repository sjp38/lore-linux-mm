Date: Mon, 22 May 2006 07:21:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Extract have_task_perm() from kill and migrate functions.
Message-ID: <Pine.LNX.4.64.0605220719310.3432@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Various kernel function check if they are allowed to do something to another
task. The ones that I have found are

1. The check for kill permissions

2. sys_migrate_pages() checking if a process is allowed to
   migrate the pages of another process.

3. sys_move_pages() checking if a process is allowed to
   migrate individual pages that are part of another process.

Extract the common code in these checks to form a new function
in kernel/signal.c have_task_perm(task, capability). The check
is successful if

1. The current process has the indicated capability

2. The current effective userid is equal to the suid or uid
   of the target process.

3. The current userid is equal to the suid or uid of the
   target process.

Note that there are similar checks for uid/gid/euid that are
stored in a variety of structures in the kernel. Maybe those may also
be extracted by a similar function that would not take a task parameter
but an explicit specification of permission ids?

ptrace() has a variation on the have_task_perm() check in may_attach().
ptrace checks for uid equal to euid, suid, uid or gid equal to
egid sgid,gid. So one may not be able to kill a process explicyly
but be able to ptrace() (and then PTRACE_KILL it) if one is a member
of the same group? Weird.

Plus ptrace does not support eid comparision. So explicit rights
for ptracing cannot be set via the super user bit.

Maybe we could consolidate all these checks and make them work in
a coherent way? I dont think I am deep enough into this issue to
takle that though.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc4-mm2.orig/mm/mempolicy.c	2006-05-20 20:53:11.000000000 -0700
+++ linux-2.6.17-rc4-mm2/mm/mempolicy.c	2006-05-20 20:53:14.000000000 -0700
@@ -926,15 +926,7 @@
 	if (!mm)
 		return -EINVAL;
 
-	/*
-	 * Check if this process has the right to modify the specified
-	 * process. The right exists if the process has administrative
-	 * capabilities, superuser privileges or the same
-	 * userid as the target process.
-	 */
-	if ((current->euid != task->suid) && (current->euid != task->uid) &&
-	    (current->uid != task->suid) && (current->uid != task->uid) &&
-	    !capable(CAP_SYS_NICE)) {
+	if (!have_task_perm(task, CAP_SYS_NICE)) {
 		err = -EPERM;
 		goto out;
 	}
Index: linux-2.6.17-rc4-mm2/mm/migrate.c
===================================================================
--- linux-2.6.17-rc4-mm2.orig/mm/migrate.c	2006-05-20 20:53:11.000000000 -0700
+++ linux-2.6.17-rc4-mm2/mm/migrate.c	2006-05-20 20:53:32.000000000 -0700
@@ -781,15 +781,7 @@
 	if (!mm)
 		return -EINVAL;
 
-	/*
-	 * Check if this process has the right to modify the specified
-	 * process. The right exists if the process has administrative
-	 * capabilities, superuser privileges or the same
-	 * userid as the target process.
-	 */
-	if ((current->euid != task->suid) && (current->euid != task->uid) &&
-	    (current->uid != task->suid) && (current->uid != task->uid) &&
-	    !capable(CAP_SYS_NICE)) {
+	if (!have_task_perm(task, CAP_SYS_NICE)) {
 		err = -EPERM;
 		goto out2;
 	}
Index: linux-2.6.17-rc4-mm2/kernel/signal.c
===================================================================
--- linux-2.6.17-rc4-mm2.orig/kernel/signal.c	2006-05-20 20:53:11.000000000 -0700
+++ linux-2.6.17-rc4-mm2/kernel/signal.c	2006-05-20 20:53:14.000000000 -0700
@@ -567,6 +567,25 @@
 }
 
 /*
+ * Check if this process has the rights to do something
+ * with another process.
+ *
+ * The right exists if either
+ * 1. The current process has the indicated capability
+ * 2. The current effective user id is the user or superuser
+ * 	id of the other process.
+ * 3. The current user id is the user or superuser id of the other process.
+ */
+int have_task_perm(struct task_struct *t, int capability)
+{
+	if (capable(capability))
+		return 1;
+
+	return (current->euid == t->suid || current->euid == t->uid ||
+		  current->uid == t->suid || current->uid == t->uid);
+}
+
+/*
  * Bad permissions for sending the signal
  */
 static int check_kill_permission(int sig, struct siginfo *info,
@@ -579,9 +598,7 @@
 	if ((info == SEND_SIG_NOINFO || (!is_si_special(info) && SI_FROMUSER(info)))
 	    && ((sig != SIGCONT) ||
 		(current->signal->session != t->signal->session))
-	    && (current->euid ^ t->suid) && (current->euid ^ t->uid)
-	    && (current->uid ^ t->suid) && (current->uid ^ t->uid)
-	    && !capable(CAP_KILL))
+	    && have_task_perm(t, CAP_KILL))
 		return error;
 
 	error = security_task_kill(t, info, sig);
Index: linux-2.6.17-rc4-mm2/include/linux/signal.h
===================================================================
--- linux-2.6.17-rc4-mm2.orig/include/linux/signal.h	2006-05-20 20:53:11.000000000 -0700
+++ linux-2.6.17-rc4-mm2/include/linux/signal.h	2006-05-20 20:53:14.000000000 -0700
@@ -267,6 +267,8 @@
 struct pt_regs;
 extern int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka, struct pt_regs *regs, void *cookie);
 
+extern int have_task_perm(struct task_struct *, int);
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SIGNAL_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
