Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 70C396B007B
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 23:48:08 -0500 (EST)
Date: Thu, 28 Jan 2010 20:47:19 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 2/2] x86: get rid of the insane TIF_ABI_PENDING bit
In-Reply-To: <alpine.LFD.2.00.1001282043300.3768@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.1001282043580.3768@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain> <4B62141E.4050107@zytor.com>
 <alpine.LFD.2.00.1001281507080.3846@localhost.localdomain> <4B621D48.4090203@zytor.com> <alpine.LFD.2.00.1001282040160.3768@localhost.localdomain> <alpine.LFD.2.00.1001282043300.3768@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 28 Jan 2010 20:37:30 -0800
Subject: [PATCH 2/2] x86: get rid of the insane TIF_ABI_PENDING bit

Now that the previous commit made it possible to do the personality
setting at the point of no return, we do just that for ELF binaries.
And suddenly all the reasons for that insane TIF_ABI_PENDING bit go
away, and we can just make SET_PERSONALITY() just do the obvious thing
for a 32-bit compat process.

Everything becomes much more straightforward this way.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---

This not only makes things more straightforward, it removes more lines of 
code than it adds too. Partly because we don't need that comment about the 
crazy case any more.

What say you guys? For a change, I've actually tested these two patches. I 
never saw the problem that Mathias saw, but I _could_ see the incorrect 
64-bit [vsyscall] vma in /proc/xyz/maps after the failed execve, and that 
is gone with this patch.

That said, I don't really have any 32-bit binaries. The only 32-bit binary 
I tested was Mathias test-case. It worked. The code looks sane. What can I 
say?

 arch/x86/ia32/ia32_aout.c          |    1 -
 arch/x86/include/asm/elf.h         |    6 ++----
 arch/x86/include/asm/thread_info.h |    3 +--
 arch/x86/kernel/process.c          |   12 ------------
 fs/binfmt_elf.c                    |   26 ++------------------------
 fs/exec.c                          |    2 +-
 6 files changed, 6 insertions(+), 44 deletions(-)

diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index 9bc3298..a6b35c9 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -316,7 +316,6 @@ static int load_aout_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	/* OK, This is the point of no return */
 	set_personality(PER_LINUX);
 	set_thread_flag(TIF_IA32);
-	clear_thread_flag(TIF_ABI_PENDING);
 
 	current->mm->end_code = ex.a_text +
 		(current->mm->start_code = N_TXTADDR(ex));
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index b4501ee..4c17e20 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -183,11 +183,9 @@ void start_thread_ia32(struct pt_regs *regs, u32 new_ip, u32 new_sp);
 
 #define COMPAT_SET_PERSONALITY(ex)			\
 do {							\
-	if (test_thread_flag(TIF_IA32))			\
-		clear_thread_flag(TIF_ABI_PENDING);	\
-	else						\
-		set_thread_flag(TIF_ABI_PENDING);	\
+	set_thread_flag(TIF_IA32);			\
 	current->personality |= force_personality32;	\
+	current_thread_info()->status |= TS_COMPAT;	\
 } while (0)
 
 #define COMPAT_ELF_PLATFORM			("i686")
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index 375c917..4ce5b15 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -87,7 +87,7 @@ struct thread_info {
 #define TIF_NOTSC		16	/* TSC is not accessible in userland */
 #define TIF_IA32		17	/* 32bit process */
 #define TIF_FORK		18	/* ret_from_fork */
-#define TIF_ABI_PENDING		19
+					/* 19 - unused */
 #define TIF_MEMDIE		20
 #define TIF_DEBUG		21	/* uses debug registers */
 #define TIF_IO_BITMAP		22	/* uses I/O bitmap */
@@ -112,7 +112,6 @@ struct thread_info {
 #define _TIF_NOTSC		(1 << TIF_NOTSC)
 #define _TIF_IA32		(1 << TIF_IA32)
 #define _TIF_FORK		(1 << TIF_FORK)
-#define _TIF_ABI_PENDING	(1 << TIF_ABI_PENDING)
 #define _TIF_DEBUG		(1 << TIF_DEBUG)
 #define _TIF_IO_BITMAP		(1 << TIF_IO_BITMAP)
 #define _TIF_FREEZE		(1 << TIF_FREEZE)
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 02c3ee0..c9b3522 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -115,18 +115,6 @@ void flush_thread(void)
 {
 	struct task_struct *tsk = current;
 
-#ifdef CONFIG_X86_64
-	if (test_tsk_thread_flag(tsk, TIF_ABI_PENDING)) {
-		clear_tsk_thread_flag(tsk, TIF_ABI_PENDING);
-		if (test_tsk_thread_flag(tsk, TIF_IA32)) {
-			clear_tsk_thread_flag(tsk, TIF_IA32);
-		} else {
-			set_tsk_thread_flag(tsk, TIF_IA32);
-			current_thread_info()->status |= TS_COMPAT;
-		}
-	}
-#endif
-
 	flush_ptrace_hw_breakpoint(tsk);
 	memset(tsk->thread.tls_array, 0, sizeof(tsk->thread.tls_array));
 	/*
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index c7e6973..bcf5ddb 100644
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
@@ -740,6 +716,8 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	if (retval)
 		goto out_free_dentry;
 
+	SET_PERSONALITY(loc->elf_ex);
+
 	/* OK, This is the point of no return */
 	setup_new_exec(bprm);
 
diff --git a/fs/exec.c b/fs/exec.c
index 9e10e6e..5835fe2 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -723,7 +723,6 @@ static int exec_mmap(struct mm_struct *mm)
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
 	task_unlock(tsk);
-	arch_pick_mmap_layout(mm);
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);
 		BUG_ON(active_mm != old_mm);
@@ -969,6 +968,7 @@ void setup_new_exec(struct linux_binprm * bprm)
 	char tcomm[sizeof(current->comm)];
 
 	bprm->mm = NULL;		/* We're using it now */
+	arch_pick_mmap_layout(current->mm);
 
 	/* This is the point of no return */
 	current->sas_ss_sp = current->sas_ss_size = 0;
-- 
1.7.0.rc0.33.g7c3932

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
