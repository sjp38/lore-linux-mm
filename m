Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1BEA66B0083
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 17:34:50 -0500 (EST)
Date: Thu, 28 Jan 2010 14:33:54 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] DoS on x86_64
In-Reply-To: <4B61B00D.7070202@zytor.com>
Message-ID: <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>



On Thu, 28 Jan 2010, H. Peter Anvin wrote:
> 
> - The actual point of no return in the case of binfmt_elf.c is inside
> the subroutine flush_old_exec() [which makes sense - the actual process
> switch shouldn't be dependent on the binfmt] which isn't subject to
> compat-level macro munging.

Why worry about it? We already do that additional

	SET_PERSONALITY(loc->elf_ex);

_after_ the flush_old_exec() call anyway in fs/binfmt_elf.c.

So why not just simply remove the whole early SET_PERSONALITY thing, and 
only keep that later one? The comment about "lookup of the interpreter" is 
known to be irrelevant these days, so why don't we just remove it all?

I have _not_ tested any of this, and maybe there is some crazy reason why 
this won't work, but I'm not seeing it.

I think we do have to do that "task_size" thing (which flush_old_exec() 
also does), because it depends on the personality exactly the same way 
STACK_TOP does. But why isn't the following patch "obviously correct"?

			Linus

---
 fs/binfmt_elf.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index edd90c4..c62462e 100644
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
@@ -747,6 +723,8 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	/* Do this immediately, since STACK_TOP as used in setup_arg_pages
 	   may depend on the personality.  */
 	SET_PERSONALITY(loc->elf_ex);
+	current->mm->task_size = TASK_SIZE;
+
 	if (elf_read_implies_exec(loc->elf_ex, executable_stack))
 		current->personality |= READ_IMPLIES_EXEC;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
