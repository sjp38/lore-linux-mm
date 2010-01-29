Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0076B007D
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 23:44:45 -0500 (EST)
Date: Thu, 28 Jan 2010 20:43:54 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 1/2] Split 'flush_old_exec' into two functions
In-Reply-To: <alpine.LFD.2.00.1001282040160.3768@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.1001282043300.3768@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain> <4B62141E.4050107@zytor.com>
 <alpine.LFD.2.00.1001281507080.3846@localhost.localdomain> <4B621D48.4090203@zytor.com> <alpine.LFD.2.00.1001282040160.3768@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>



From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 28 Jan 2010 19:56:16 -0800
Subject: [PATCH 1/2] Split 'flush_old_exec' into two functions

'flush_old_exec()' is the point of no return when doing an execve(), and
it is pretty badly misnamed.  It doesn't just flush the old executable
environment, it also starts up the new one.

Which is very inconvenient for things like setting up the new
personality, because we want the new personality to affect the starting
of the new environment, but at the same time we do _not_ want the new
personality to take effect if flushing the old one fails.

As a result, the x86-64 '32-bit' personality is actually done using this
insane "I'm going to change the ABI, but I haven't done it yet" bit
(TIF_ABI_PENDING), with SET_PERSONALITY() not actually setting the
personality, but just the "pending" bit, so that "flush_thread()" can do
the actual personality magic.

This patch in no way changes any of that insanity, but it does split the
'flush_old_exec()' function up into a preparatory part that can fail
(still called flush_old_exec()), and a new part that will actually set
up the new exec environment (setup_new_exec()).  All callers are changed
to trivially comply with the new world order.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/sh/kernel/process_64.c |    2 +-
 arch/x86/ia32/ia32_aout.c   |    1 +
 fs/binfmt_aout.c            |    2 ++
 fs/binfmt_elf.c             |    2 ++
 fs/binfmt_elf_fdpic.c       |    2 ++
 fs/binfmt_flat.c            |    1 +
 fs/binfmt_som.c             |    2 ++
 fs/exec.c                   |   24 ++++++++++++------------
 include/linux/binfmts.h     |    1 +
 include/linux/sched.h       |    2 +-
 10 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/arch/sh/kernel/process_64.c b/arch/sh/kernel/process_64.c
index 31f80c6..ec79faf 100644
--- a/arch/sh/kernel/process_64.c
+++ b/arch/sh/kernel/process_64.c
@@ -368,7 +368,7 @@ void exit_thread(void)
 void flush_thread(void)
 {
 
-	/* Called by fs/exec.c (flush_old_exec) to remove traces of a
+	/* Called by fs/exec.c (setup_new_exec) to remove traces of a
 	 * previously running executable. */
 #ifdef CONFIG_SH_FPU
 	if (last_task_used_math == current) {
diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index 2a4d073..9bc3298 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -307,6 +307,7 @@ static int load_aout_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	retval = flush_old_exec(bprm);
 	if (retval)
 		return retval;
+	setup_new_exec(bprm);
 
 	regs->cs = __USER32_CS;
 	regs->r8 = regs->r9 = regs->r10 = regs->r11 = regs->r12 =
diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index 346b694..56ef825 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -259,6 +259,8 @@ static int load_aout_binary(struct linux_binprm * bprm, struct pt_regs * regs)
 		return retval;
 
 	/* OK, This is the point of no return */
+	setup_new_exec(bprm);
+
 #ifdef __alpha__
 	SET_AOUT_PERSONALITY(bprm, ex);
 #else
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index edd90c4..c7e6973 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -741,6 +741,8 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 		goto out_free_dentry;
 
 	/* OK, This is the point of no return */
+	setup_new_exec(bprm);
+
 	current->flags &= ~PF_FORKNOEXEC;
 	current->mm->def_flags = def_flags;
 
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index c57d9ce..26d0ba3 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -318,6 +318,8 @@ static int load_elf_fdpic_binary(struct linux_binprm *bprm,
 	/* there's now no turning back... the old userspace image is dead,
 	 * defunct, deceased, etc. after this point we have to exit via
 	 * error_kill */
+	setup_new_exec(bprm);
+
 	set_personality(PER_LINUX_FDPIC);
 	if (elf_read_implies_exec(&exec_params.hdr, executable_stack))
 		current->personality |= READ_IMPLIES_EXEC;
diff --git a/fs/binfmt_flat.c b/fs/binfmt_flat.c
index d4a00ea..d6a43eb 100644
--- a/fs/binfmt_flat.c
+++ b/fs/binfmt_flat.c
@@ -518,6 +518,7 @@ static int load_flat_file(struct linux_binprm * bprm,
 		}
 
 		/* OK, This is the point of no return */
+		setup_new_exec(bprm);
 		set_personality(PER_LINUX_32BIT);
 	}
 
diff --git a/fs/binfmt_som.c b/fs/binfmt_som.c
index 2a9b533..1189fb1 100644
--- a/fs/binfmt_som.c
+++ b/fs/binfmt_som.c
@@ -225,6 +225,8 @@ load_som_binary(struct linux_binprm * bprm, struct pt_regs * regs)
 		goto out_free;
 
 	/* OK, This is the point of no return */
+	setup_new_exec(bprm);
+
 	current->flags &= ~PF_FORKNOEXEC;
 	current->personality = PER_HPUX;
 
diff --git a/fs/exec.c b/fs/exec.c
index 632b02e..9e10e6e 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -941,9 +941,7 @@ void set_task_comm(struct task_struct *tsk, char *buf)
 
 int flush_old_exec(struct linux_binprm * bprm)
 {
-	char * name;
-	int i, ch, retval;
-	char tcomm[sizeof(current->comm)];
+	int retval;
 
 	/*
 	 * Make sure we have a private signal table and that
@@ -959,8 +957,16 @@ int flush_old_exec(struct linux_binprm * bprm)
 	 * Release all of the old mmap stuff
 	 */
 	retval = exec_mmap(bprm->mm);
-	if (retval)
-		goto out;
+out:
+	return retval;
+}
+EXPORT_SYMBOL(flush_old_exec);
+
+void setup_new_exec(struct linux_binprm * bprm)
+{
+	char * name;
+	int i, ch;
+	char tcomm[sizeof(current->comm)];
 
 	bprm->mm = NULL;		/* We're using it now */
 
@@ -1019,14 +1025,8 @@ int flush_old_exec(struct linux_binprm * bprm)
 			
 	flush_signal_handlers(current, 0);
 	flush_old_files(current->files);
-
-	return 0;
-
-out:
-	return retval;
 }
-
-EXPORT_SYMBOL(flush_old_exec);
+EXPORT_SYMBOL(setup_new_exec);
 
 /*
  * Prepare credentials and lock ->cred_guard_mutex.
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index cd4349b..89c6249 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -109,6 +109,7 @@ extern int prepare_binprm(struct linux_binprm *);
 extern int __must_check remove_arg_zero(struct linux_binprm *);
 extern int search_binary_handler(struct linux_binprm *,struct pt_regs *);
 extern int flush_old_exec(struct linux_binprm * bprm);
+extern void setup_new_exec(struct linux_binprm * bprm);
 
 extern int suid_dumpable;
 #define SUID_DUMP_DISABLE	0	/* No setuid dumping */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6f7bba9..abdfacc 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1369,7 +1369,7 @@ struct task_struct {
 	char comm[TASK_COMM_LEN]; /* executable name excluding path
 				     - access with [gs]et_task_comm (which lock
 				       it with task_lock())
-				     - initialized normally by flush_old_exec */
+				     - initialized normally by setup_new_exec */
 /* file system info */
 	int link_count, total_link_count;
 #ifdef CONFIG_SYSVIPC
-- 
1.7.0.rc0.33.g7c3932

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
