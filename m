Message-Id: <20070605151203.626442000@chello.nl>
References: <20070605150523.786600000@chello.nl>
Date: Tue, 05 Jun 2007 17:05:25 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 2/4] audit: rework execve audit
Content-Disposition: inline; filename=execve_audit.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Ollie Wild <aaw@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>, linux-audit@redhat.com
List-ID: <linux-mm.kvack.org>

The purpose of audit_bprm() is to log the argv array to a userspace daemon at
the end of the execve system call. Since user-space hasn't had time to run,
this array is still in pristine state on the process' stack; so no need to copy
it, we can just grab it from there.

In order to minimize the damage to audit_log_*() copy each string into a
temporary kernel buffer first.

Currently the audit code requires that the full argument vector fits in a
single packet. So currently it does clip the argv size to a (sysctl) limit, but
only when execve auditing is enabled.

If the audit protocol gets extended to allow for multiple packets this check
can be removed.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Ollie Wild <aaw@google.com>
Cc: linux-audit@redhat.com
---
 fs/exec.c               |    3 +
 include/linux/binfmts.h |    1 
 include/linux/sysctl.h  |    1 
 kernel/audit.c          |   16 +++++++++
 kernel/audit.h          |    1 
 kernel/auditsc.c        |   82 ++++++++++++++++++++++++++++++++----------------
 kernel/sysctl.c         |   11 ++++++
 7 files changed, 89 insertions(+), 26 deletions(-)

Index: linux-2.6-2/kernel/auditsc.c
===================================================================
--- linux-2.6-2.orig/kernel/auditsc.c	2007-06-05 09:51:53.000000000 +0200
+++ linux-2.6-2/kernel/auditsc.c	2007-06-05 10:03:31.000000000 +0200
@@ -156,7 +156,7 @@ struct audit_aux_data_execve {
 	struct audit_aux_data	d;
 	int argc;
 	int envc;
-	char mem[0];
+	struct mm_struct *mm;
 };
 
 struct audit_aux_data_socketcall {
@@ -834,6 +834,47 @@ static int audit_log_pid_context(struct 
 	return rc;
 }
 
+static void audit_log_execve_info(struct audit_buffer *ab,
+		struct audit_aux_data_execve *axi)
+{
+	int i;
+	long len;
+	const char __user *p = (const char __user *)axi->mm->arg_start;
+
+	if (axi->mm != current->mm)
+		return; /* execve failed, no additional info */
+
+	for (i = 0; i < axi->argc; i++, p += len) {
+		long ret;
+		char *tmp;
+
+		len = strnlen_user(p, MAX_ARG_PAGES*PAGE_SIZE);
+		/*
+		 * We just created this mm, if we can't find the strings
+		 * we just copied in something is _very_ wrong.
+		 */
+		BUG_ON(!len);
+
+		tmp = kmalloc(len, GFP_KERNEL);
+		if (!tmp) {
+			audit_panic("out of memory for argv string\n");
+			break;
+		}
+
+		ret = copy_from_user(tmp, p, len);
+		/*
+		 * There is no reason for this copy to be short.
+		 */
+		BUG_ON(ret);
+
+		audit_log_format(ab, "a%d=", i);
+		audit_log_untrustedstring(ab, tmp);
+		audit_log_format(ab, "\n");
+
+		kfree(tmp);
+	}
+}
+
 static void audit_log_exit(struct audit_context *context, struct task_struct *tsk)
 {
 	int i, call_panic = 0;
@@ -974,13 +1016,7 @@ static void audit_log_exit(struct audit_
 
 		case AUDIT_EXECVE: {
 			struct audit_aux_data_execve *axi = (void *)aux;
-			int i;
-			const char *p;
-			for (i = 0, p = axi->mem; i < axi->argc; i++) {
-				audit_log_format(ab, "a%d=", i);
-				p = audit_log_untrustedstring(ab, p);
-				audit_log_format(ab, "\n");
-			}
+			audit_log_execve_info(ab, axi);
 			break; }
 
 		case AUDIT_SOCKETCALL: {
@@ -1824,32 +1860,31 @@ int __audit_ipc_set_perm(unsigned long q
 	return 0;
 }
 
+int audit_argv_kb = 32;
+
 int audit_bprm(struct linux_binprm *bprm)
 {
 	struct audit_aux_data_execve *ax;
 	struct audit_context *context = current->audit_context;
-	unsigned long p, next;
-	void *to;
 
 	if (likely(!audit_enabled || !context || context->dummy))
 		return 0;
 
-	ax = kmalloc(sizeof(*ax) + PAGE_SIZE * MAX_ARG_PAGES - bprm->p,
-				GFP_KERNEL);
+	/*
+	 * Even though the stack code doesn't limit the arg+env size any more,
+	 * the audit code requires that _all_ arguments be logged in a single
+	 * netlink skb. Hence cap it :-(
+	 */
+	if (bprm->argv_len > (audit_argv_kb << 10))
+		return -E2BIG;
+
+	ax = kmalloc(sizeof(*ax), GFP_KERNEL);
 	if (!ax)
 		return -ENOMEM;
 
 	ax->argc = bprm->argc;
 	ax->envc = bprm->envc;
-	for (p = bprm->p, to = ax->mem; p < MAX_ARG_PAGES*PAGE_SIZE; p = next) {
-		struct page *page = bprm->page[p / PAGE_SIZE];
-		void *kaddr = kmap(page);
-		next = (p + PAGE_SIZE) & ~(PAGE_SIZE - 1);
-		memcpy(to, kaddr + (p & (PAGE_SIZE - 1)), next - p);
-		to += next - p;
-		kunmap(page);
-	}
-
+	ax->mm = bprm->mm;
 	ax->d.type = AUDIT_EXECVE;
 	ax->d.next = context->aux;
 	context->aux = (void *)ax;
Index: linux-2.6-2/fs/exec.c
===================================================================
--- linux-2.6-2.orig/fs/exec.c	2007-06-05 09:51:42.000000000 +0200
+++ linux-2.6-2/fs/exec.c	2007-06-05 10:03:11.000000000 +0200
@@ -1154,6 +1154,7 @@ int do_execve(char * filename,
 {
 	struct linux_binprm *bprm;
 	struct file *file;
+	unsigned long tmp;
 	int retval;
 	int i;
 
@@ -1208,9 +1209,11 @@ int do_execve(char * filename,
 	if (retval < 0)
 		goto out;
 
+	tmp = bprm->p;
 	retval = copy_strings(bprm->argc, argv, bprm);
 	if (retval < 0)
 		goto out;
+	bprm->argv_len = tmp - bprm->p;
 
 	retval = search_binary_handler(bprm,regs);
 	if (retval >= 0) {
Index: linux-2.6-2/include/linux/binfmts.h
===================================================================
--- linux-2.6-2.orig/include/linux/binfmts.h	2007-06-05 09:51:44.000000000 +0200
+++ linux-2.6-2/include/linux/binfmts.h	2007-06-05 10:03:11.000000000 +0200
@@ -40,6 +40,7 @@ struct linux_binprm{
 	unsigned interp_flags;
 	unsigned interp_data;
 	unsigned long loader, exec;
+	unsigned long argv_len;
 };
 
 #define BINPRM_FLAGS_ENFORCE_NONDUMP_BIT 0
Index: linux-2.6-2/kernel/sysctl.c
===================================================================
--- linux-2.6-2.orig/kernel/sysctl.c	2007-06-05 09:51:53.000000000 +0200
+++ linux-2.6-2/kernel/sysctl.c	2007-06-05 10:04:05.000000000 +0200
@@ -78,6 +78,7 @@ extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int maps_protect;
 extern int sysctl_stat_interval;
+extern int audit_argv_kb;
 
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
@@ -615,6 +616,16 @@ static ctl_table kern_table[] = {
 		.proc_handler   = &proc_dointvec,
 	},
 #endif
+#ifdef CONFIG_AUDITSYSCALL
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "audit_argv_kb",
+		.data		= &audit_argv_kb,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+#endif
 
 	{ .ctl_name = 0 }
 };

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
