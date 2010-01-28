Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 81B766001DA
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 18:07:44 -0500 (EST)
Date: Thu, 28 Jan 2010 15:06:32 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] DoS on x86_64
In-Reply-To: <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.1001281449220.3846@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Mathias Krause <minipli@googlemail.com>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>



On Thu, 28 Jan 2010, Linus Torvalds wrote:
> 
> I have _not_ tested any of this, and maybe there is some crazy reason why 
> this won't work, but I'm not seeing it.

Grr. We also do "arch_pick_mmap_layout()" in "flush_old_exec()".

That whole function is mis-named. It doesn't actually flush the old exec, 
it also creates the new one.

However, we then re-do it afterwards in fs/binfmt_elf.c, so again, that 
doesn't really matter.

What _does_ matter, however, is the crazy stuff we do in flush_thread() 
wrt TIF_ABI_PENDING. That's just crazy.

So no, the trivial patch won't work.

How about splitting up "flush_old_exec()" into two pieces? We'd have a 
"flush_old_exec()" and a "setup_new_exec()" piece, and all existing 
callers of flush_old_exec() would just be changed to call both?

So here's a new patch. Again, TOTALLY UNTESTED. It may be equally broken, 
for some other reason I haven't noticed yet (or because I just screwed 
up). I've verified that it compiles for me, but that's it.

Caveat patchor.

			Linus

---
 arch/sh/kernel/process_64.c |    2 +-
 arch/x86/ia32/ia32_aout.c   |    1 +
 fs/binfmt_aout.c            |    1 +
 fs/binfmt_elf.c             |   27 ++-------------------------
 fs/binfmt_elf_fdpic.c       |    1 +
 fs/binfmt_flat.c            |    1 +
 fs/binfmt_som.c             |    1 +
 fs/exec.c                   |   24 ++++++++++++++----------
 include/linux/binfmts.h     |    1 +
 include/linux/sched.h       |    2 +-
 10 files changed, 24 insertions(+), 37 deletions(-)

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
index 346b694..19ae369 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -257,6 +257,7 @@ static int load_aout_binary(struct linux_binprm * bprm, struct pt_regs * regs)
 	retval = flush_old_exec(bprm);
 	if (retval)
 		return retval;
+	setup_new_exec();
 
 	/* OK, This is the point of no return */
 #ifdef __alpha__
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index edd90c4..fd5b2ea 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -662,27 +662,6 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 			if (elf_interpreter[elf_ppnt->p_filesz - 1] != '\0')
 				goto out_free_interp;
 
-			/*
-			 * The early SET_PERSONALITY here is so that the lookup
-			 * for the interpreter happens in the namespace of the 
-			 * to-be-execed image.  SET_PERSONALITY can select an
-			 * alternate root.
-			 *
-			 * However, SET_PERSONALITY is NOT allowed to switch
-			 * this task into the new images's memory mapping
-			 * policy - that is, TASK_SIZE must still evaluate to
-			 * that which is appropriate to the execing application.
-			 * This is because exit_mmap() needs to have TASK_SIZE
-			 * evaluate to the size of the old image.
-			 *
-			 * So if (say) a 64-bit application is execing a 32-bit
-			 * application it is the architecture's responsibility
-			 * to defer changing the value of TASK_SIZE until the
-			 * switch really is going to happen - do this in
-			 * flush_thread().	- akpm
-			 */
-			SET_PERSONALITY(loc->elf_ex);
-
 			interpreter = open_exec(elf_interpreter);
 			retval = PTR_ERR(interpreter);
 			if (IS_ERR(interpreter))
@@ -730,9 +709,6 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 		/* Verify the interpreter has a valid arch */
 		if (!elf_check_arch(&loc->interp_elf_ex))
 			goto out_free_dentry;
-	} else {
-		/* Executables without an interpreter also need a personality  */
-		SET_PERSONALITY(loc->elf_ex);
 	}
 
 	/* Flush all traces of the currently running executable */
@@ -752,7 +728,8 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 
 	if (!(current->personality & ADDR_NO_RANDOMIZE) && randomize_va_space)
 		current->flags |= PF_RANDOMIZE;
-	arch_pick_mmap_layout(current->mm);
+
+	setup_new_exec(bprm);
 
 	/* Do this so that we can load the interpreter, if need be.  We will
 	   change some of these later */
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index c57d9ce..c38d396 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -314,6 +314,7 @@ static int load_elf_fdpic_binary(struct linux_binprm *bprm,
 	retval = flush_old_exec(bprm);
 	if (retval)
 		goto error;
+	setup_new_exec(bprm);
 
 	/* there's now no turning back... the old userspace image is dead,
 	 * defunct, deceased, etc. after this point we have to exit via
diff --git a/fs/binfmt_flat.c b/fs/binfmt_flat.c
index d4a00ea..42c6b4a 100644
--- a/fs/binfmt_flat.c
+++ b/fs/binfmt_flat.c
@@ -519,6 +519,7 @@ static int load_flat_file(struct linux_binprm * bprm,
 
 		/* OK, This is the point of no return */
 		set_personality(PER_LINUX_32BIT);
+		setup_new_exec(bprm);
 	}
 
 	/*
diff --git a/fs/binfmt_som.c b/fs/binfmt_som.c
index 2a9b533..cc8560f 100644
--- a/fs/binfmt_som.c
+++ b/fs/binfmt_som.c
@@ -227,6 +227,7 @@ load_som_binary(struct linux_binprm * bprm, struct pt_regs * regs)
 	/* OK, This is the point of no return */
 	current->flags &= ~PF_FORKNOEXEC;
 	current->personality = PER_HPUX;
+	setup_new_exec(bprm);
 
 	/* Set the task size for HP-UX processes such that
 	 * the gateway page is outside the address space.
diff --git a/fs/exec.c b/fs/exec.c
index 632b02e..4bc488d 100644
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
@@ -963,6 +961,18 @@ int flush_old_exec(struct linux_binprm * bprm)
 		goto out;
 
 	bprm->mm = NULL;		/* We're using it now */
+	return 0;
+
+out:
+	return retval;
+}
+EXPORT_SYMBOL(flush_old_exec);
+
+void setup_new_exec(struct linux_binprm * bprm)
+{
+	int i, ch;
+	char * name;
+	char tcomm[sizeof(current->comm)];
 
 	/* This is the point of no return */
 	current->sas_ss_sp = current->sas_ss_size = 0;
@@ -1019,14 +1029,8 @@ int flush_old_exec(struct linux_binprm * bprm)
 			
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
