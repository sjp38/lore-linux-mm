Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B21506B007B
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 00:18:15 -0500 (EST)
Message-ID: <4B626F66.3080508@zytor.com>
Date: Thu, 28 Jan 2010 21:17:26 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Split 'flush_old_exec' into two functions
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain> <4B62141E.4050107@zytor.com> <alpine.LFD.2.00.1001281507080.3846@localhost.localdomain> <4B621D48.4090203@zytor.com> <alpine.LFD.2.00.1001282040160.3768@localhost.localdomain> <alpine.LFD.2.00.1001282043300.3768@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.1001282043300.3768@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 01/28/2010 08:43 PM, Linus Torvalds wrote:
> --- a/fs/binfmt_elf_fdpic.c
> +++ b/fs/binfmt_elf_fdpic.c
> @@ -318,6 +318,8 @@ static int load_elf_fdpic_binary(struct linux_binprm *bprm,
>  	/* there's now no turning back... the old userspace image is dead,
>  	 * defunct, deceased, etc. after this point we have to exit via
>  	 * error_kill */
> +	setup_new_exec(bprm);
> +
>  	set_personality(PER_LINUX_FDPIC);
>  	if (elf_read_implies_exec(&exec_params.hdr, executable_stack))
>  		current->personality |= READ_IMPLIES_EXEC;
> diff --git a/fs/binfmt_flat.c b/fs/binfmt_flat.c
> index d4a00ea..d6a43eb 100644
> --- a/fs/binfmt_flat.c
> +++ b/fs/binfmt_flat.c
> @@ -518,6 +518,7 @@ static int load_flat_file(struct linux_binprm * bprm,
>  		}
>  
>  		/* OK, This is the point of no return */
> +		setup_new_exec(bprm);
>  		set_personality(PER_LINUX_32BIT);
>  	}

For all of these, wouldn't it make more sense to call set_personality()
*before* calling setup_new_exec()?  The sequencing that would seem sane
to me is:

	flush_old_exec();
	set_personality();
	setup_new_exec();

... since setup_new_exec() should be able to depend on the target
personality, including TASK_SIZE and arch_pick_mmap_layout().

Similarly, for binfmt_elf the following sequence would seem to make sense:


/* OK, This is the point of no return */

/* Do this immediately, since STACK_TOP as used in setup_arg_pages
   may depend on the personality.  */
SET_PERSONALITY(loc->elf_ex);
if (elf_read_implies_exec(loc->elf_ex, executable_stack))
	current->personality |= READ_IMPLIES_EXEC;

if (!(current->personality & ADDR_NO_RANDOMIZE) && randomize_va_space)
	current->flags |= PF_RANDOMIZE;

setup_new_exec(bprm);

current->flags &= ~PF_FORKNOEXEC;
current->mm->def_flags = def_flags;

... then there shouldn't be a need to call SET_PERSONALITY() and
arch_pick_mmap_layout() twice...

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
