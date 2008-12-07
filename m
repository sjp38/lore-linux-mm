Date: Sat, 6 Dec 2008 22:07:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] - support inheritance of mlocks across fork/exec V2
Message-Id: <20081206220729.042a926e.akpm@linux-foundation.org>
In-Reply-To: <1228331069.6693.73.camel@lts-notebook>
References: <1227561707.6937.61.camel@lts-notebook>
	<20081125152651.b4c3c18f.akpm@linux-foundation.org>
	<1228331069.6693.73.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, riel@redhat.com, hugh@veritas.com, kosaki.motohiro@jp.fujitsu.com, linux-abi@vger.kernel.org
List-ID: <linux-mm.kvack.org>


(cc linux-abi.  Again.)

On Wed, 03 Dec 2008 14:04:29 -0500 Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> 
> 
> Against;  2.6.28-rc7-mmotm-081203
> 
> V02:	rework vetting of flags argument as suggested by
> 	Kosaki Motohiro.
> 	enhance description as requested by Andrew Morton.
> 
> Add support for mlockall(MCL_INHERIT|MCL_RECURSIVE):
> 
> 	MCL_CURRENT[|MCL_FUTURE]|MCL_INHERIT - inherit memory locks
> 		[vmas' VM_LOCKED flags] across fork(), and inherit
> 		MCL_FUTURE behavior [mm's def_flags] across fork()
> 		and exec().  Behaves as if child and/or new task
> 		called mlockall(MCL_CURRENT|MCL_FUTURE) as first
> 		instruction.
> 
> 	MCL_RECURSIVE - inherit MCL_CURRENT|MCL_FUTURE|MCL_INHERIT
> 		[vmas' VM_LOCKED flags for fork() and mm's def_flags
> 		and mcl_inherit across fork() and exec()] for all
> 		future generations of calling process's descendants.
> 		Behaves as if child and/or new task called
> 		mlockall(MCL_CURRENT|MCL_FUTURE|MCL_INHERIT|MCL_RECURSIVE)
> 		as the first instruction.
> 
> In support of a "lock prefix command"--e.g., mlock <cmd> <args> ...
> Analogous to taskset(1) for cpu affinity or numactl(8) for numa memory
> policy.
> 
> Together with patches to keep mlocked pages off the LRU, this will
> allow users/admins to lock down applications without modifying them,
> if their RLIMIT_MEMLOCK is sufficiently large, keeping their pages
> off the LRU and out of consideration for reclaim.
> 
> Potentially useful, as well, in real-time environments to force
> prefaulting and residency for applications that don't mlock themselves.
> 
> Jeff Sharkey at Montana State developed a similar patch for Linux
> [link no longer accessible], but apparently he never submitted the patch.
> 
> I submitted an earlier version of this patch around a year ago.  I
> resurrected it to test the unevictable lru/mlocked pages patches--
> e.g., by "mlock -r make -j<N*nr_cpus> all".  This did shake out a few
> races and vmstat accounting bugs, but NOT something I'd recommend as
> general practice--for kernel builds, that is.
> 
> ----
> 
> Define MCL_INHERIT, MCL_RECURSIVE in <asm-*/mman.h>.
> + x86 and  ia64 versions included.
> + other arch can/will be created, if this patch deemed merge-worthy.
> 
> Similarly, I'll provide kernel man page update if/when needed.
> 
> Example "lock prefix command" in Documentation/vm/mlock.c
> 
>
> ...
>
> --- linux-2.6.28-rc7-mmotm-081203.orig/mm/mlock.c	2008-12-03 10:33:11.000000000 -0500
> +++ linux-2.6.28-rc7-mmotm-081203/mm/mlock.c	2008-12-03 10:33:29.000000000 -0500
> @@ -573,15 +573,18 @@ asmlinkage long sys_munlock(unsigned lon
>  static int do_mlockall(int flags)
>  {
>  	struct vm_area_struct * vma, * prev = NULL;
> +	struct mm_struct *mm = current->mm;
>  	unsigned int def_flags = 0;
>  
>  	if (flags & MCL_FUTURE)
> -		def_flags = VM_LOCKED;
> -	current->mm->def_flags = def_flags;
> -	if (flags == MCL_FUTURE)
> +		def_flags = VM_LOCKED;;

You get paid by the semicolon?

> +	mm->def_flags = def_flags;
> +	if (flags & MCL_INHERIT)
> +		mm->mcl_inherit = flags & (MCL_INHERIT | MCL_RECURSIVE);

aaaaaaarrrrrrggggggghhhhhhh!

So mm->mcl_inherit is _not_ a boolean meaning "this mm has MCL_INHERIT
set", as I naively believed when I saw it.  Is it in fact a composite
of both MCL_INHERIT and MCL_RECURSIVE, given a badly misleading name
and a waffly comment.

Can we please make this clearer?

>
> ...
>
> --- linux-2.6.28-rc7-mmotm-081203.orig/kernel/fork.c	2008-12-03 10:18:15.000000000 -0500
> +++ linux-2.6.28-rc7-mmotm-081203/kernel/fork.c	2008-12-03 10:33:29.000000000 -0500
> @@ -278,7 +278,8 @@ static int dup_mmap(struct mm_struct *mm
>  	 */
>  	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
>  
> -	mm->locked_vm = 0;
> +	if (!mm->mcl_inherit)
> +		mm->locked_vm = 0;
>  	mm->mmap = NULL;
>  	mm->mmap_cache = NULL;
>  	mm->free_area_cache = oldmm->mmap_base;
> @@ -316,7 +317,8 @@ static int dup_mmap(struct mm_struct *mm
>  		if (IS_ERR(pol))
>  			goto fail_nomem_policy;
>  		vma_set_policy(tmp, pol);
> -		tmp->vm_flags &= ~VM_LOCKED;
> +		if (!mm->mcl_inherit)
> +			tmp->vm_flags &= ~VM_LOCKED;
>  		tmp->vm_mm = mm;
>  		tmp->vm_next = NULL;
>  		anon_vma_link(tmp);
> @@ -406,6 +408,8 @@ __cacheline_aligned_in_smp DEFINE_SPINLO
>  
>  static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
>  {
> +	unsigned long def_flags = 0;
> +
>  	atomic_set(&mm->mm_users, 1);
>  	atomic_set(&mm->mm_count, 1);
>  	init_rwsem(&mm->mmap_sem);
> @@ -422,9 +426,14 @@ static struct mm_struct * mm_init(struct
>  	mm->free_area_cache = TASK_UNMAPPED_BASE;
>  	mm->cached_hole_size = ~0UL;
>  	mm_init_owner(mm, p);
> +	if (current->mm && current->mm->mcl_inherit) {
> +		def_flags = current->mm->def_flags & VM_LOCKED;
> +		if (mm->mcl_inherit & MCL_RECURSIVE)
> +			mm->mcl_inherit  = current->mm->mcl_inherit;
> +	}

hm.  That code looks familiar.  Not worth a helper function?

>  	if (likely(!mm_alloc_pgd(mm))) {
> -		mm->def_flags = 0;
> +		mm->def_flags = def_flags;
>  		mmu_notifier_mm_init(mm);
>  		return mm;
>  	}
> Index: linux-2.6.28-rc7-mmotm-081203/fs/binfmt_elf.c
> ===================================================================
> --- linux-2.6.28-rc7-mmotm-081203.orig/fs/binfmt_elf.c	2008-12-03 10:19:21.000000000 -0500
> +++ linux-2.6.28-rc7-mmotm-081203/fs/binfmt_elf.c	2008-12-03 10:33:29.000000000 -0500
> @@ -585,6 +585,7 @@ static int load_elf_binary(struct linux_
>  	unsigned long reloc_func_desc = 0;
>  	int executable_stack = EXSTACK_DEFAULT;
>  	unsigned long def_flags = 0;
> +	int mcl_inherit = 0;
>  	struct {
>  		struct elfhdr elf_ex;
>  		struct elfhdr interp_elf_ex;
> @@ -749,6 +750,13 @@ static int load_elf_binary(struct linux_
>  		SET_PERSONALITY(loc->elf_ex);
>  	}
>  
> +	/* Optionally inherit MCL_FUTURE state before destroying old mm */
> +	if (current->mm && current->mm->mcl_inherit) {

umm, OK, it looks like current->mm can be null here.

> +		def_flags = current->mm->def_flags & VM_LOCKED;

ooh, we finally used local variable def_flags for something.  That's
been wasting space since 2.2.26 (or earlier).

> +		if (current->mm->mcl_inherit & MCL_RECURSIVE)
> +			mcl_inherit  = current->mm->mcl_inherit;
> +	}
> +
>  	/* Flush all traces of the currently running executable */
>  	retval = flush_old_exec(bprm);
>  	if (retval)
> @@ -757,6 +765,7 @@ static int load_elf_binary(struct linux_
>  	/* OK, This is the point of no return */
>  	current->flags &= ~PF_FORKNOEXEC;
>  	current->mm->def_flags = def_flags;
> +	current->mm->mcl_inherit = mcl_inherit;
>  
>  	/* Do this immediately, since STACK_TOP as used in setup_arg_pages
>  	   may depend on the personality.  */

Why is this done in binfmt_elf.c?  Doesn't this preclude the operation
of these new flags for other binary formats?

> Index: linux-2.6.28-rc7-mmotm-081203/arch/x86/include/asm/mman.h
> ===================================================================
> --- linux-2.6.28-rc7-mmotm-081203.orig/arch/x86/include/asm/mman.h	2008-12-03 10:16:26.000000000 -0500
> +++ linux-2.6.28-rc7-mmotm-081203/arch/x86/include/asm/mman.h	2008-12-03 10:33:29.000000000 -0500
> @@ -16,5 +16,8 @@
>  
>  #define MCL_CURRENT	1		/* lock all current mappings */
>  #define MCL_FUTURE	2		/* lock all future mappings */
> +#define MCL_INHERIT	4		/* inherit mlocks across fork */
> +					/* inherit '_FUTURE flag across fork/exec */
> +#define MCL_RECURSIVE	8		/* inherit mlocks recursively */
>  
>  #endif /* _ASM_X86_MMAN_H */
> Index: linux-2.6.28-rc7-mmotm-081203/include/linux/mm_types.h
> ===================================================================
> --- linux-2.6.28-rc7-mmotm-081203.orig/include/linux/mm_types.h	2008-12-03 10:18:01.000000000 -0500
> +++ linux-2.6.28-rc7-mmotm-081203/include/linux/mm_types.h	2008-12-03 10:33:29.000000000 -0500
> @@ -235,6 +235,8 @@ struct mm_struct {
>  	unsigned int token_priority;
>  	unsigned int last_interval;
>  
> +	int mcl_inherit;		/* inherit current/future locks */
> +
>  	unsigned long flags; /* Must use atomic bitops to access the bits */

I was thinking that the boolean mcl_inherit could become a bit in
mm.flags.  That was before I unmisled myself about it.

Perhaps we could use two bits.  That might get a bit nasty.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
