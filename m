Date: Tue, 5 Jun 2007 16:39:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: variable length argument support
Message-Id: <20070605163925.bfc417ca.akpm@linux-foundation.org>
In-Reply-To: <20070605151203.790585000@chello.nl>
References: <20070605150523.786600000@chello.nl>
	<20070605151203.790585000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 05 Jun 2007 17:05:27 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> From: Ollie Wild <aaw@google.com>
> 
> Remove the arg+env limit of MAX_ARG_PAGES by copying the strings directly
> from the old mm into the new mm.
> 
> We create the new mm before the binfmt code runs, and place the new stack
> at the very top of the address space. Once the binfmt code runs and figures
> out where the stack should be, we move it downwards.
> 
> It is a bit peculiar in that we have one task with two mm's, one of which is
> inactive.
> 
> ..
>
> 
> Index: linux-2.6-2/fs/binfmt_elf.c
> ===================================================================
> --- linux-2.6-2.orig/fs/binfmt_elf.c	2007-06-05 16:23:16.000000000 +0200
> +++ linux-2.6-2/fs/binfmt_elf.c	2007-06-05 16:29:45.000000000 +0200
> @@ -148,6 +148,7 @@ create_elf_tables(struct linux_binprm *b
>  	elf_addr_t *elf_info;
>  	int ei_index = 0;
>  	struct task_struct *tsk = current;
> +	struct vm_area_struct *vma;
>  
>  	/*
>  	 * If this architecture has a platform capability string, copy it
> @@ -234,6 +235,15 @@ create_elf_tables(struct linux_binprm *b
>  	sp = (elf_addr_t __user *)bprm->p;
>  #endif
>  
> +
> +	/*
> +	 * Grow the stack manually; some architectures have a limit on how
> +	 * far ahead a user-space access may be in order to grow the stack.
> +	 */
> +	vma = find_extend_vma(current->mm, bprm->p);
> +	if (!vma)
> +		return -EFAULT;
> +
>  	/* Now, let's put argc (and argv, envp if appropriate) on the stack */
>  	if (__put_user(argc, sp++))
>  		return -EFAULT;
> @@ -254,8 +264,8 @@ create_elf_tables(struct linux_binprm *b
>  		size_t len;
>  		if (__put_user((elf_addr_t)p, argv++))
>  			return -EFAULT;
> -		len = strnlen_user((void __user *)p, PAGE_SIZE*MAX_ARG_PAGES);
> -		if (!len || len > PAGE_SIZE*MAX_ARG_PAGES)
> +		len = strnlen_user((void __user *)p, MAX_ARG_STRLEN);
> +		if (!len || len > MAX_ARG_STRLEN)

strnlen_user() is a scary function.  Please do remember that if the memory
we just strlen'ed is writeable by any user thread then that thread can at
any time invalidate the number which the kernel now holds.

>  			return 0;
>  		p += len;
>  	}
> @@ -266,8 +276,8 @@ create_elf_tables(struct linux_binprm *b
>  		size_t len;
>  		if (__put_user((elf_addr_t)p, envp++))
>  			return -EFAULT;
> -		len = strnlen_user((void __user *)p, PAGE_SIZE*MAX_ARG_PAGES);
> -		if (!len || len > PAGE_SIZE*MAX_ARG_PAGES)
> +		len = strnlen_user((void __user *)p, MAX_ARG_STRLEN);
> +		if (!len || len > MAX_ARG_STRLEN)
>  			return 0;
>  		p += len;
>  	}
>
> ...
>
> Index: linux-2.6-2/fs/compat.c
> ===================================================================
> --- linux-2.6-2.orig/fs/compat.c	2007-06-05 16:23:16.000000000 +0200
> +++ linux-2.6-2/fs/compat.c	2007-06-05 16:29:45.000000000 +0200
> @@ -1257,6 +1257,7 @@ static int compat_copy_strings(int argc,
>  {
>  	struct page *kmapped_page = NULL;
>  	char *kaddr = NULL;
> +	unsigned long kpos = 0;
>  	int ret;
>  
>  	while (argc-- > 0) {
> @@ -1265,92 +1266,84 @@ static int compat_copy_strings(int argc,
>  		unsigned long pos;
>  
>  		if (get_user(str, argv+argc) ||
> -			!(len = strnlen_user(compat_ptr(str), bprm->p))) {
> +		    !(len = strnlen_user(compat_ptr(str), MAX_ARG_STRLEN))) {
>  			ret = -EFAULT;
>  			goto out;
>  		}
>  
> -		if (bprm->p < len)  {
> +		if (MAX_ARG_STRLEN < len) {
>  			ret = -E2BIG;
>  			goto out;
>  		}

Do we have an off-by-one here?  Should it be <=?

If not, then this code is relying upon the string's terminating \0 coming
from userspace?  If so, that's buggy: userspace can overwrite the \0 after
we ran the strnlen_user(), perhaps, and confound the kernel?

I could be complete crap, but please check all this very closely.


> +/*
> + * Create a new mm_struct and populate it with a temporary stack
> + * vm_area_struct.  We don't have enough context at this point to set the stack
> + * flags, permissions, and offset, so we use temporary values.  We'll update
> + * them later in setup_arg_pages().
> + */
> +int bprm_mm_init(struct linux_binprm *bprm)
> +{
> +	int err;
> +	struct mm_struct *mm = NULL;
> +	struct vm_area_struct *vma = NULL;
> +
> +	bprm->mm = mm = mm_alloc();
> +	err = -ENOMEM;
> +	if (!mm)
> +		goto err;
> +
> +	if ((err = init_new_context(current, mm)))
> +		goto err;

	err = init_new_context(current, mm));
	if (err)
		goto err;

> +#ifdef CONFIG_MMU
> +	bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
> +	err = -ENOMEM;
> +	if (!vma)
> +		goto err;
> +
> +	down_write(&mm->mmap_sem);
> +	{
> +		vma->vm_mm = mm;

Let's lose the unneeded brace and indent here?

> +		/*
> +		 * Place the stack at the top of user memory.  Later, we'll
> +		 * move this to an appropriate place.  We don't use STACK_TOP
> +		 * because that can depend on attributes which aren't
> +		 * configured yet.
> +		 */
> +		vma->vm_end = STACK_TOP_MAX;
> +		vma->vm_start = vma->vm_end - PAGE_SIZE;
> +
> +		vma->vm_flags = VM_STACK_FLAGS;
> +		vma->vm_page_prot = protection_map[vma->vm_flags & 0x7];
> +		if ((err = insert_vm_struct(mm, vma))) {
> +			up_write(&mm->mmap_sem);
> +			goto err;
> +		}
> +
> +		mm->stack_vm = mm->total_vm = 1;
> +	}
> +	up_write(&mm->mmap_sem);
> +
> +	bprm->p = vma->vm_end - sizeof(void *);
> +#else
> +	bprm->p = PAGE_SIZE * MAX_ARG_PAGES - sizeof(void *);
> +#endif
> +
> +	return 0;
> +
> +err:
> +#ifdef CONFIG_MMU
> +	if (vma) {
> +		bprm->vma = NULL;
> +		kmem_cache_free(vm_area_cachep, vma);
> +	}
> +#endif
> +
> +	if (mm) {
> +		bprm->mm = NULL;
> +		mmdrop(mm);
> +	}
> +
> +	return err;
> +}
> +
> +EXPORT_SYMBOL(bprm_mm_init);

Preferred style is to have zero blank lines between the ^}$ and the
EXPORT_SYMBOL().

>  /*
> - * 'copy_strings()' copies argument/environment strings from user
> - * memory to free pages in kernel mem. These are in a format ready
> - * to be put directly into the top of new user memory.
> + * 'copy_strings()' copies argument/environment strings from the old
> + * processes's memory to the new process's stack.  The call to get_user_pages()
> + * ensures the destination page is created and not swapped out.
>   */
>  static int copy_strings(int argc, char __user * __user * argv,
>  			struct linux_binprm *bprm)
>  {
>  	struct page *kmapped_page = NULL;
>  	char *kaddr = NULL;
> +	unsigned long kpos = 0;
>  	int ret;
>  
>  	while (argc-- > 0) {
> @@ -220,69 +373,77 @@ static int copy_strings(int argc, char _
>  		unsigned long pos;
>  
>  		if (get_user(str, argv+argc) ||
> -				!(len = strnlen_user(str, bprm->p))) {
> +				!(len = strnlen_user(str, MAX_ARG_STRLEN))) {
>  			ret = -EFAULT;
>  			goto out;
>  		}
>  
> -		if (bprm->p < len)  {
> +#ifdef CONFIG_MMU
> +		if (MAX_ARG_STRLEN < len) {
> +			ret = -E2BIG;
> +			goto out;
> +		}

strnlen_user() scariness.  Please check for off-by-ones.

> +#else
> +		if (bprm->p < len) {
>  			ret = -E2BIG;
>  			goto out;
>  		}
> +#endif
>  
> ...
>
>  EXPORT_SYMBOL(copy_strings_kernel);
>  
>  #ifdef CONFIG_MMU
> -/*
> - * This routine is used to map in a page into an address space: needed by
> - * execve() for the initial stack and environment pages.
> - *
> - * vma->vm_mm->mmap_sem is held for writing.
> - */
> -void install_arg_page(struct vm_area_struct *vma,
> -			struct page *page, unsigned long address)
> +
> +static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
>  {

Needs a comment explaining why it exists, what it does, how it does it. 
For maintainability.

>  	struct mm_struct *mm = vma->vm_mm;
> -	pte_t * pte;
> -	spinlock_t *ptl;
> +	unsigned long old_start = vma->vm_start;
> +	unsigned long old_end = vma->vm_end;
> +	unsigned long length = old_end - old_start;
> +	unsigned long new_start = old_start + shift;
> +	unsigned long new_end = old_end + shift;
> +	struct mmu_gather *tlb;
> +
> +	BUG_ON(new_start > new_end);
> +
> +	if (new_start < old_start) {
> +		if (vma != find_vma(mm, new_start))
> +			return -EFAULT;
> +
> +		vma_adjust(vma, new_start, old_end,
> +			   vma->vm_pgoff - (-shift >> PAGE_SHIFT), NULL);

hm, a right-shift of a negated unsigned value.  That's pretty unusual.  I
hope you know what you're doing ;)


> +		if (length != move_page_tables(vma, old_start,
> +					       vma, new_start, length))
> +			return -ENOMEM;
> +
> +		lru_add_drain();
> +		tlb = tlb_gather_mmu(mm, 0);
> +		if (new_end > old_start)
> +			free_pgd_range(&tlb, new_end, old_end, new_end,
> +				vma->vm_next ? vma->vm_next->vm_start : 0);
> +		else
> +			free_pgd_range(&tlb, old_start, old_end, new_end,
> +				vma->vm_next ? vma->vm_next->vm_start : 0);
> +		tlb_finish_mmu(tlb, new_end, old_end);
>  
> -	if (unlikely(anon_vma_prepare(vma)))
> -		goto out;
> +		vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
> +	} else {
> +		struct vm_area_struct *tmp, *prev;
>  
> -	flush_dcache_page(page);
> -	pte = get_locked_pte(mm, address, &ptl);
> -	if (!pte)
> -		goto out;
> -	if (!pte_none(*pte)) {
> -		pte_unmap_unlock(pte, ptl);
> -		goto out;
> +		tmp = find_vma_prev(mm, new_end, &prev);
> +		if ((tmp && tmp->vm_start < new_end) || prev != vma)
> +			return -EFAULT;

This reader is all lost.  Perhaps a few comments explaining what tests like
the above are doing would help him regain his bearings.

Not having an overall description of what this code is doing doesn't help.

> +		find_vma_prev(mm, vma->vm_start, &prev);
> +
> +		vma_adjust(vma, old_start, new_end, vma->vm_pgoff, NULL);
> +
> +		if (length != move_page_tables_up(vma, old_start,
> +					       vma, new_start, length))
> +			return -ENOMEM;
> +
> +		lru_add_drain();
> +		tlb = tlb_gather_mmu(mm, 0);
> +		free_pgd_range(&tlb, old_start, new_start,
> +			       prev ? prev->vm_end: 0, new_start);
> +		tlb_finish_mmu(tlb, old_start, new_start);
> +
> +		vma_adjust(vma, new_start, new_end,
> +			   vma->vm_pgoff + (shift >> PAGE_SHIFT), NULL);
>  	}
> -	inc_mm_counter(mm, anon_rss);
> -	lru_cache_add_active(page);
> -	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
> -					page, vma->vm_page_prot))));
> -	page_add_new_anon_rmap(page, vma, address);
> -	pte_unmap_unlock(pte, ptl);
>  
> -	/* no need for flush_tlb */
> -	return;
> -out:
> -	__free_page(page);
> -	force_sig(SIGKILL, current);
> +	return 0;
>  }
>  
>  #define EXTRA_STACK_VM_PAGES	20	/* random */
>  
> +/* Finalizes the stack vm_area_struct.  The flags and permissions are updated,
> + * the stack is optionally relocated, and some extra space is added.
> + */

That's better.

But what extra space is added, and why?

>  int setup_arg_pages(struct linux_binprm *bprm,
>  		    unsigned long stack_top,
>  		    int executable_stack)
>  {
> -	unsigned long stack_base;
> -	struct vm_area_struct *mpnt;
> +	unsigned long ret;
> +	unsigned long stack_base, stack_shift;
>  	struct mm_struct *mm = current->mm;
> -	int i, ret;
> -	long arg_size;
> +	struct vm_area_struct *vma = bprm->vma;
>  
>  #ifdef CONFIG_STACK_GROWSUP
> -	/* Move the argument and environment strings to the bottom of the
> -	 * stack space.
> -	 */
> -	int offset, j;
> -	char *to, *from;
> -
> -	/* Start by shifting all the pages down */
> -	i = 0;
> -	for (j = 0; j < MAX_ARG_PAGES; j++) {
> -		struct page *page = bprm->page[j];
> -		if (!page)
> -			continue;
> -		bprm->page[i++] = page;
> -	}
> -
> -	/* Now move them within their pages */
> -	offset = bprm->p % PAGE_SIZE;
> -	to = kmap(bprm->page[0]);
> -	for (j = 1; j < i; j++) {
> -		memmove(to, to + offset, PAGE_SIZE - offset);
> -		from = kmap(bprm->page[j]);
> -		memcpy(to + PAGE_SIZE - offset, from, offset);
> -		kunmap(bprm->page[j - 1]);
> -		to = from;
> -	}
> -	memmove(to, to + offset, PAGE_SIZE - offset);
> -	kunmap(bprm->page[j - 1]);
> -
>  	/* Limit stack size to 1GB */
>  	stack_base = current->signal->rlim[RLIMIT_STACK].rlim_max;
>  	if (stack_base > (1 << 30))
>  		stack_base = 1 << 30;
> -	stack_base = PAGE_ALIGN(stack_top - stack_base);
>  
> -	/* Adjust bprm->p to point to the end of the strings. */
> -	bprm->p = stack_base + PAGE_SIZE * i - offset;
> +	/* Make sure we didn't let the argument array grow too large. */
> +	if (vma->vm_end - vma->vm_start > stack_base)
> +		return -ENOMEM;
>  
> -	mm->arg_start = stack_base;
> -	arg_size = i << PAGE_SHIFT;
> +	stack_base = PAGE_ALIGN(stack_top - stack_base);
>  
> -	/* zero pages that were copied above */
> -	while (i < MAX_ARG_PAGES)
> -		bprm->page[i++] = NULL;
> +	stack_shift = stack_base - vma->vm_start;
> +	mm->arg_start = bprm->p + stack_shift;
> +	bprm->p = vma->vm_end + stack_shift;
>  #else
> -	stack_base = arch_align_stack(stack_top - MAX_ARG_PAGES*PAGE_SIZE);
> -	stack_base = PAGE_ALIGN(stack_base);
> -	bprm->p += stack_base;
> +	BUG_ON(stack_top & ~PAGE_MASK);

Is there much point in this BUG_ON, given that we're about to align
stack_top anyway?

> +	stack_top = arch_align_stack(stack_top);
> +	stack_top = PAGE_ALIGN(stack_top);
> +	stack_shift = stack_top - vma->vm_end;
> +
> +	bprm->p += stack_shift;
>  	mm->arg_start = bprm->p;
> -	arg_size = stack_top - (PAGE_MASK & (unsigned long) mm->arg_start);
>  #endif
>  
> -	arg_size += EXTRA_STACK_VM_PAGES * PAGE_SIZE;
> -
>  	if (bprm->loader)
> -		bprm->loader += stack_base;
> -	bprm->exec += stack_base;
> -
> -	mpnt = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
> -	if (!mpnt)
> -		return -ENOMEM;
> +		bprm->loader += stack_shift;
> +	bprm->exec += stack_shift;
>  
>  	down_write(&mm->mmap_sem);
>  	{
> -		mpnt->vm_mm = mm;
> -#ifdef CONFIG_STACK_GROWSUP
> -		mpnt->vm_start = stack_base;
> -		mpnt->vm_end = stack_base + arg_size;
> -#else
> -		mpnt->vm_end = stack_top;
> -		mpnt->vm_start = mpnt->vm_end - arg_size;
> -#endif
> +		struct vm_area_struct *prev = NULL;
> +		unsigned long vm_flags = vma->vm_flags;
> +
>  		/* Adjust stack execute permissions; explicitly enable
>  		 * for EXSTACK_ENABLE_X, disable for EXSTACK_DISABLE_X
>  		 * and leave alone (arch default) otherwise. */
>  		if (unlikely(executable_stack == EXSTACK_ENABLE_X))
> -			mpnt->vm_flags = VM_STACK_FLAGS |  VM_EXEC;
> +			vm_flags |= VM_EXEC;
>  		else if (executable_stack == EXSTACK_DISABLE_X)
> -			mpnt->vm_flags = VM_STACK_FLAGS & ~VM_EXEC;
> -		else
> -			mpnt->vm_flags = VM_STACK_FLAGS;
> -		mpnt->vm_flags |= mm->def_flags;
> -		mpnt->vm_page_prot = protection_map[mpnt->vm_flags & 0x7];
> -		if ((ret = insert_vm_struct(mm, mpnt))) {
> +			vm_flags &= ~VM_EXEC;
> +		vm_flags |= mm->def_flags;
> +
> +		ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
> +				vm_flags);
> +		if (ret) {
>  			up_write(&mm->mmap_sem);
> -			kmem_cache_free(vm_area_cachep, mpnt);
>  			return ret;
>  		}
> -		mm->stack_vm = mm->total_vm = vma_pages(mpnt);
> -	}
> +		BUG_ON(prev != vma);

:(

> -	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
> -		struct page *page = bprm->page[i];
> -		if (page) {
> -			bprm->page[i] = NULL;
> -			install_arg_page(mpnt, page, stack_base);
> +		/* Move stack pages down in memory. */
> +		if (stack_shift) {
> +			ret = shift_arg_pages(vma, stack_shift);
> +			if (ret) {
> +				up_write(&mm->mmap_sem);
> +				return ret;
> +			}
> +		}
> +
> +#ifdef CONFIG_STACK_GROWSUP
> +		if (expand_stack(vma, vma->vm_end +
> +					EXTRA_STACK_VM_PAGES * PAGE_SIZE)) {
> +			up_write(&mm->mmap_sem);
> +			return -EFAULT;
> +		}
> +#else
> +		if (expand_stack(vma, vma->vm_start -
> +					EXTRA_STACK_VM_PAGES * PAGE_SIZE)) {
> +			up_write(&mm->mmap_sem);
> +			return -EFAULT;
>  		}
> -		stack_base += PAGE_SIZE;
> +#endif
>  	}
>
> ...
>
> Index: linux-2.6-2/include/linux/binfmts.h
> ===================================================================
> --- linux-2.6-2.orig/include/linux/binfmts.h	2007-06-05 16:29:41.000000000 +0200
> +++ linux-2.6-2/include/linux/binfmts.h	2007-06-05 16:29:45.000000000 +0200
> @@ -5,12 +5,9 @@
>  
>  struct pt_regs;
>  
> -/*
> - * MAX_ARG_PAGES defines the number of pages allocated for arguments
> - * and envelope for the new program. 32 should suffice, this gives
> - * a maximum env+arg of 128kB w/4KB pages!
> - */
> -#define MAX_ARG_PAGES 32
> +/* FIXME: Find real limits, or none. */
> +#define MAX_ARG_STRLEN (PAGE_SIZE * 32)
> +#define MAX_ARG_STRINGS 0x7FFFFFFF

DOCUMENTME!

>  /* sizeof(linux_binprm->buf) */
>  #define BINPRM_BUF_SIZE 128
> @@ -24,7 +21,12 @@ struct pt_regs;
>   */
>
> ...
>
> +#ifdef CONFIG_STACK_GROWSUP
> +extern int expand_downwards(struct vm_area_struct *vma, unsigned long address);
> +#endif

We don't (or shouldn't) need the ifdefs here.

> -		return NULL;
> -	if (prev->vm_flags & VM_LOCKED) {
> -		make_pages_present(addr, prev->vm_end);
> -	}
> -	return prev;
> -}
> -#else
>  /*
>   * vma is the first one with address < vma->vm_start.  Have to extend vma.
>   */
> -int expand_stack(struct vm_area_struct *vma, unsigned long address)
> +#ifndef CONFIG_STACK_GROWSUP
> +static inline
> +#endif
> +int expand_downwards(struct vm_area_struct *vma, unsigned long address)
>  {

eww, that was a bit rude.

Can we just leave this as static int then do

int expand_stack_downwards(....)

?

That's a better name anyway.

>  	int error;
>  
> @@ -1620,6 +1600,34 @@ int expand_stack(struct vm_area_struct *
>  	return error;
>  }
>  
> +#ifdef CONFIG_STACK_GROWSUP
> +int expand_stack(struct vm_area_struct *vma, unsigned long address)
> +{
> +	return expand_upwards(vma, address);
> +}
> +
> +struct vm_area_struct *
> +find_extend_vma(struct mm_struct *mm, unsigned long addr)
> +{
> +	struct vm_area_struct *vma, *prev;
> +
> +	addr &= PAGE_MASK;
> +	vma = find_vma_prev(mm, addr, &prev);
> +	if (vma && (vma->vm_start <= addr))
> +		return vma;
> +	if (!prev || expand_stack(prev, addr))
> +		return NULL;
> +	if (prev->vm_flags & VM_LOCKED) {
> +		make_pages_present(addr, prev->vm_end);
> +	}

unneeded braces

We really should check and propagate the make_pages_present() return value
when appropriate.  It can fail under -ENOMEM, ulimit exceeded, overcommit,
etc.


> +	return prev;
> +}
> +#else
> +int expand_stack(struct vm_area_struct *vma, unsigned long address)
> +{
> +	return expand_downwards(vma, address);
> +}
> +
>  struct vm_area_struct *
>  find_extend_vma(struct mm_struct * mm, unsigned long addr)
>  {
> Index: linux-2.6-2/mm/mprotect.c
> ===================================================================
> --- linux-2.6-2.orig/mm/mprotect.c	2007-06-05 16:23:16.000000000 +0200
> +++ linux-2.6-2/mm/mprotect.c	2007-06-05 16:29:45.000000000 +0200
> @@ -128,7 +128,7 @@ static void change_protection(struct vm_
>  	flush_tlb_range(vma, start, end);
>  }
>  
> -static int
> +int
>  mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>  	unsigned long start, unsigned long end, unsigned long newflags)
>  {
> Index: linux-2.6-2/arch/ia64/ia32/binfmt_elf32.c
> ===================================================================
> --- linux-2.6-2.orig/arch/ia64/ia32/binfmt_elf32.c	2007-06-05 16:23:16.000000000 +0200
> +++ linux-2.6-2/arch/ia64/ia32/binfmt_elf32.c	2007-06-05 16:29:45.000000000 +0200
> @@ -195,62 +195,23 @@ ia64_elf32_init (struct pt_regs *regs)
>  	ia32_load_state(current);
>  }
>  
> +#undef setup_arg_pages

What's this for?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
