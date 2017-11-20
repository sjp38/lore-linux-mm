Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B68946B0069
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:21:51 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u98so1448851wrb.17
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 09:21:51 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c3si1179143wrd.22.2017.11.20.09.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 09:21:49 -0800 (PST)
Date: Mon, 20 Nov 2017 18:21:45 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 08/30] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
In-Reply-To: <20171110193112.6A962D6A@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711201518490.1734@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193112.6A962D6A@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Fri, 10 Nov 2017, Dave Hansen wrote:
> diff -puN arch/x86/entry/entry_64.S~kaiser-base arch/x86/entry/entry_64.S
> --- a/arch/x86/entry/entry_64.S~kaiser-base	2017-11-10 11:22:09.007244950 -0800
> +++ b/arch/x86/entry/entry_64.S	2017-11-10 11:22:09.031244950 -0800
> @@ -145,6 +145,16 @@ ENTRY(entry_SYSCALL_64)
>  
>  	swapgs
>  	movq	%rsp, PER_CPU_VAR(rsp_scratch)
> +
> +	/*
> +	 * We need a good kernel CR3 to be able to map the process
> +	 * stack, but we need a scratch register to be able to load
> +	 * CR3.  We could create another PER_CPU_VAR(), but %rsp is
> +	 * actually clobberable right now.  Just use it.  It will only
> +	 * be insane for one a couple instructions.
> +	 */
> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp

Shouldn't this be in the patch which introduces all that SWITCH macro magic?

>  	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
>  
>  	/* Construct struct pt_regs on stack */
> @@ -169,8 +179,6 @@ GLOBAL(entry_SYSCALL_64_after_hwframe)
>  
>  	/* NB: right here, all regs except r11 are live. */

Stale comment

>  
> -	SWITCH_TO_KERNEL_CR3 scratch_reg=%r11
> -
>  	/* Must wait until we have the kernel CR3 to call C functions: */
>  	TRACE_IRQS_OFF
>  
> @@ -1269,6 +1277,7 @@ ENTRY(error_entry)
>  	 * gsbase and proceed.  We'll fix up the exception and land in
>  	 * .Lgs_change's error handler with kernel gsbase.
>  	 */
> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax

See above.

>  	SWAPGS
>  	jmp .Lerror_entry_done
>  
> @@ -1382,6 +1391,7 @@ ENTRY(nmi)
>  
>  	swapgs
>  	cld
> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdx
>  	movq	%rsp, %rdx
>  	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
>  	UNWIND_HINT_IRET_REGS base=%rdx offset=8
> @@ -1410,7 +1420,6 @@ ENTRY(nmi)
>  	UNWIND_HINT_REGS
>  	ENCODE_FRAME_POINTER
>  
> -	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi

Ditto

> +#ifdef CONFIG_KAISER
> +/*
> + * All top-level KAISER page tables are order-1 pages (8k-aligned
> + * and 8k in size).  The kernel one is at the beginning 4k and
> + * the user (shadow) one is in the last 4k.  To switch between
> + * them, you just need to flip the 12th bit in their addresses.
> + */
> +#define KAISER_PGTABLE_SWITCH_BIT	PAGE_SHIFT
> +
> +/*
> + * This generates better code than the inline assembly in
> + * __set_bit().
> + */
> +static inline void *ptr_set_bit(void *ptr, int bit)
> +{
> +	unsigned long __ptr = (unsigned long)ptr;

Newline between declaration and code please.

> +	__ptr |= (1<<bit);

  __ptr |= 1UL << bit;

> +	return (void *)__ptr;
> +}
> +static inline void *ptr_clear_bit(void *ptr, int bit)
> +{
> +	unsigned long __ptr = (unsigned long)ptr;
> +	__ptr &= ~(1<<bit);
> +	return (void *)__ptr;

Ditto

> +}

> +/*
> + * Page table pages are page-aligned.  The lower half of the top
> + * level is used for userspace and the top half for the kernel.
> + * This returns true for user pages that need to get copied into
> + * both the user and kernel copies of the page tables, and false
> + * for kernel pages that should only be in the kernel copy.
> + */
> +static inline bool is_userspace_pgd(void *__ptr)
> +{
> +	unsigned long ptr = (unsigned long)__ptr;
> +
> +	return ((ptr % PAGE_SIZE) < (PAGE_SIZE / 2));

The outer brackets are not required and the obvious way to write that is:

  	return (ptr & ~PAGE_MASK) < (PAGE_SIZE / 2);

I guess the compiler is smart enought to figure that out itself, but ...

> +}
> +
>  static inline void native_set_p4d(p4d_t *p4dp, p4d_t p4d)
>  {
> +#if defined(CONFIG_KAISER) && !defined(CONFIG_X86_5LEVEL)
> +	/*
> +	 * set_pgd() does not get called when we are running
> +	 * CONFIG_X86_5LEVEL=y.  So, just hack around it.  We
> +	 * know here that we have a p4d but that it is really at
> +	 * the top level of the page tables; it is really just a
> +	 * pgd.
> +	 */
> +	/* Do we need to also populate the shadow p4d? */
> +	if (is_userspace_pgd(p4dp))
> +		native_get_shadow_p4d(p4dp)->pgd = p4d.pgd;

native_get_shadow_p4d() is kinda confusing, as it suggest that we get the
entry not the pointer to it. native_get_shadow_p4d_ptr() is what it
actually wants to be, but a setter e.g. native_set_shadow...(), we also
have set_pgd() would be more obvious I think.

> +	/*
> +	 * Even if the entry is *mapping* userspace, ensure
> +	 * that userspace can not use it.  This way, if we
> +	 * get out to userspace with the wrong CR3 value,
> +	 * userspace will crash instead of running.
> +	 */
> +	if (!p4d.pgd.pgd)
> +		p4dp->pgd.pgd = p4d.pgd.pgd | _PAGE_NX;

Confused. Contrary to the comment this sets the NX bit on every non null
entry.

> +#else /* CONFIG_KAISER */
>  	*p4dp = p4d;
> +#endif
>  }

>  static inline void clone_pgd_range(pgd_t *dst, pgd_t *src, int count)
>  {
>         memcpy(dst, src, count * sizeof(pgd_t));
> +#ifdef CONFIG_KAISER
> +	/* Clone the shadow pgd part as well */
> +	memcpy(native_get_shadow_pgd(dst),
> +	       native_get_shadow_pgd(src),
> +	       count * sizeof(pgd_t));

Nitpick: this fits in two lines

> +#endif
>  }

>  /*
>   * Note: we only need 6*8 = 48 bytes for the espfix stack, but round
> @@ -128,6 +129,22 @@ void __init init_espfix_bsp(void)
>  	pgd = &init_top_pgt[pgd_index(ESPFIX_BASE_ADDR)];
>  	p4d = p4d_alloc(&init_mm, pgd, ESPFIX_BASE_ADDR);
>  	p4d_populate(&init_mm, p4d, espfix_pud_page);
> +	/*
> +	 * Just copy the top-level PGD that is mapping the espfix
> +	 * area to ensure it is mapped into the shadow user page
> +	 * tables.
> +	 *
> +	 * For 5-level paging, we should have already populated

should we have it populated or is it de facto populated?

> +	 * the espfix pgd when kaiser_init() pre-populated all
> +	 * the pgd entries.  The above p4d_alloc() would never do
> +	 * anything and the p4d_populate() would be done to a p4d
> +	 * already mapped in the userspace pgd.
> +	 */
> +#ifdef CONFIG_KAISER
> +	if (CONFIG_PGTABLE_LEVELS <= 4)
> +		set_pgd(native_get_shadow_pgd(pgd),
> +			__pgd(_KERNPG_TABLE | (p4d_pfn(*p4d) << PAGE_SHIFT)));

Nit: Please add curly braces on the first condition.

> +/*
> + * This "fakes" a #GP from userspace upon returning (iret'ing)
> + * from this double fault.
> + */
> +void setup_fake_gp_at_iret(struct pt_regs *regs)
> +{
> +	unsigned long *new_stack_top = (unsigned long *)
> +		(this_cpu_read(cpu_tss.x86_tss.ist[0]) - 0x1500);

0x1500? No magic numbers. Please use defines with a proper explanation.

> +	/*
> +	 * Set up a stack just like the hardware would for a #GP.
> +	 *
> +	 * This format is an "iret frame", plus the error code
> +	 * that the hardware puts on the stack for us for
> +	 * exceptions.  (see struct pt_regs).
> +	 */
> +	new_stack_top[-1] = regs->ss;
> +	new_stack_top[-2] = regs->sp;
> +	new_stack_top[-3] = regs->flags;
> +	new_stack_top[-4] = regs->cs;
> +	new_stack_top[-5] = regs->ip;
> +	new_stack_top[-6] = 0;	/* faked #GP error code */
> +
> +	/*
> +	 * 'regs' points to the "iret frame" for *this*
> +	 * exception, *not* the #GP we are faking.  Here,
> +	 * we are telling 'iret' to jump to general_protection
> +	 * when returning from this double fault.
> +	 */
> +	regs->ip = (unsigned long)general_protection;
> +	/*
> +	 * Make iret move the stack to the "fake #GP" stack
> +	 * we created above.
> +	 */
> +	regs->sp = (unsigned long)&new_stack_top[-6];
> +}
> +
>  #ifdef CONFIG_X86_64
>  /* Runs on IST stack */
>  dotraplinkage void do_double_fault(struct pt_regs *regs, long error_code)
> @@ -354,14 +391,7 @@ dotraplinkage void do_double_fault(struc
>  		regs->cs == __KERNEL_CS &&
>  		regs->ip == (unsigned long)native_irq_return_iret)
>  	{
> -		struct pt_regs *normal_regs = task_pt_regs(current);
> -
> -		/* Fake a #GP(0) from userspace. */
> -		memmove(&normal_regs->ip, (void *)regs->sp, 5*8);
> -		normal_regs->orig_ax = 0;  /* Missing (lost) #GP error code */
> -		regs->ip = (unsigned long)general_protection;
> -		regs->sp = (unsigned long)&normal_regs->orig_ax;
> -
> +		setup_fake_gp_at_iret(regs);

Please split that out into a preparatory patch and explain the difference
between the original magic and the new one which puts the fake stake at
offset 0x1500.

> +/*
> + * This is only for walking kernel addresses.  We use it too help

s/too/to/ ?

> + * recreate the "shadow" page tables which are used while we are in
> + * userspace.
> + *
> + * This can be called on any kernel memory addresses and will work
> + * with any page sizes and any types: normal linear map memory,
> + * vmalloc(), even kmap().
> + *
> + * Note: this is only used when mapping new *kernel* entries into
> + * the user/shadow page tables.  It is never used for userspace
> + * addresses.
> + *
> + * Returns -1 on error.
> + */
> +static inline unsigned long get_pa_from_kernel_map(unsigned long vaddr)
> +{
> +/*

> + * Walk the shadow copy of the page tables (optionally) trying to
> + * allocate page table pages on the way down.  Does not support
> + * large pages since the data we are mapping is (generally) not
> + * large enough or aligned to 2MB.
> + *
> + * Note: this is only used when mapping *new* kernel data into the
> + * user/shadow page tables.  It is never used for userspace data.
> + *
> + * Returns a pointer to a PTE on success, or NULL on failure.
> + */
> +#define KAISER_WALK_ATOMIC  0x1
> +static pte_t *kaiser_shadow_pagetable_walk(unsigned long address,
> +					   unsigned long flags)

Please do not glue defines right before the function definition. That's
really hard to read. That define is used at the callsite as well, so please
put that on top of the file.

> +{
> +	pte_t *pte;
> +	pmd_t *pmd;
> +	pud_t *pud;
> +	p4d_t *p4d;
> +	pgd_t *pgd = native_get_shadow_pgd(pgd_offset_k(address));
> +	gfp_t gfp = (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO);
> +
> +	if (flags & KAISER_WALK_ATOMIC) {
> +		gfp &= ~GFP_KERNEL;
> +		gfp |= __GFP_HIGH | __GFP_ATOMIC;
> +	}
> +
> +	if (address < PAGE_OFFSET) {
> +		WARN_ONCE(1, "attempt to walk user address\n");
> +		return NULL;
> +	}
> +
> +	if (pgd_none(*pgd)) {
> +		WARN_ONCE(1, "All shadow pgds should have been populated\n");
> +		return NULL;
> +	}
> +	BUILD_BUG_ON(pgd_large(*pgd) != 0);

So in get_pa_from_kernel_map() you use a WARN(). Here you use a
BUILD_BUG_ON(). Can we use one of those consistently, please?

> +	p4d = p4d_offset(pgd, address);
> +	BUILD_BUG_ON(p4d_large(*p4d) != 0);

> +/*
> + * Given a kernel address, @__start_addr, copy that mapping into
> + * the user (shadow) page tables.  This may need to allocate page
> + * table pages.
> + */
> +int kaiser_add_user_map(const void *__start_addr, unsigned long size,
> +			unsigned long flags)
> +{
> +	pte_t *pte;
> +	unsigned long start_addr = (unsigned long)__start_addr;
> +	unsigned long address = start_addr & PAGE_MASK;
> +	unsigned long end_addr = PAGE_ALIGN(start_addr + size);
> +	unsigned long target_address;
> +
> +	for (; address < end_addr; address += PAGE_SIZE) {
> +		target_address = get_pa_from_kernel_map(address);
> +		if (target_address == -1)
> +			return -EIO;
> +
> +		pte = kaiser_shadow_pagetable_walk(address, false);
> +		/*
> +		 * Errors come from either -ENOMEM for a page
> +		 * table page, or something screwy that did a
> +		 * WARN_ON().  Just return -ENOMEM.
> +		 */
> +		if (!pte)
> +			return -ENOMEM;
> +		if (pte_none(*pte)) {
> +			set_pte(pte, __pte(flags | target_address));
> +		} else {
> +			pte_t tmp;
> +			set_pte(&tmp, __pte(flags | target_address));
> +			WARN_ON_ONCE(!pte_same(*pte, tmp));

So the warning is here because these tables should only be populated once,
right? A comment to that effect would be helpful.

> +		}
> +	}
> +	return 0;
> +}
> +
> +int kaiser_add_user_map_ptrs(const void *__start_addr,
> +			     const void *__end_addr,
> +			     unsigned long flags)
> +{
> +	return kaiser_add_user_map(__start_addr,
> +				   __end_addr - __start_addr,
> +				   flags);
> +}
> +
> +/*
> + * Ensure that the top level of the (shadow) page tables are
> + * entirely populated.  This ensures that all processes that get
> + * forked have the same entries.  This way, we do not have to
> + * ever go set up new entries in older processes.
> + *
> + * Note: we never free these, so there are no updates to them
> + * after this.
> + */
> +static void __init kaiser_init_all_pgds(void)
> +{
> +	pgd_t *pgd;
> +	int i = 0;

Initializing i is pointless

> +
> +	pgd = native_get_shadow_pgd(pgd_offset_k(0UL));
> +	for (i = PTRS_PER_PGD / 2; i < PTRS_PER_PGD; i++) {
> +		unsigned long addr = PAGE_OFFSET + i * PGDIR_SIZE;

This looks wrong. The kernel address space gets incremented by PGDIR_SIZE
and does not make a jump from PAGE_OFFSET to PAGE_OFFSET + 256 * PGDIR_SIZE

	int i, j;

	for (i = PTRS_PER_PGD / 2, j = 0; i < PTRS_PER_PGD; i++, j++) {
		unsigned long addr = PAGE_OFFSET + j * PGDIR_SIZE;

Not that is has any effect right now. Neither p4d_alloc_one() nor
pud_alloc_one() are using the 'addr' argument.

> +#if CONFIG_PGTABLE_LEVELS > 4
> +		p4d_t *p4d = p4d_alloc_one(&init_mm, addr);
> +		if (!p4d) {
> +			WARN_ON(1);
> +			break;
> +		}
> +		set_pgd(pgd + i, __pgd(_KERNPG_TABLE | __pa(p4d)));
> +#else /* CONFIG_PGTABLE_LEVELS <= 4 */
> +		pud_t *pud = pud_alloc_one(&init_mm, addr);
> +		if (!pud) {
> +			WARN_ON(1);
> +			break;
> +		}
> +		set_pgd(pgd + i, __pgd(_KERNPG_TABLE | __pa(pud)));
> +#endif /* CONFIG_PGTABLE_LEVELS */
> +	}
> +}
> +
> +/*
> + * The page table allocations in here can theoretically fail, but
> + * we can not do much about it in early boot.  Do the checking
> + * and warning in a macro to make it more readable.
> + */
> +#define kaiser_add_user_map_early(start, size, flags) do {	\
> +	int __ret = kaiser_add_user_map(start, size, flags);	\
> +	WARN_ON(__ret);						\
> +} while (0)
> +
> +#define kaiser_add_user_map_ptrs_early(start, end, flags) do {		\
> +	int __ret = kaiser_add_user_map_ptrs(start, end, flags);	\
> +	WARN_ON(__ret);							\
> +} while (0)

Any reason why this cannot be an inline?

> +void kaiser_remove_mapping(unsigned long start, unsigned long size)
> +{
> +	unsigned long addr;
> +
> +	/* The shadow page tables always use small pages: */
> +	for (addr = start; addr < start + size; addr += PAGE_SIZE) {
> +		/*
> +		 * Do an "atomic" walk in case this got called from an atomic
> +		 * context.  This should not do any allocations because we
> +		 * should only be walking things that are known to be mapped.
> +		 */
> +		pte_t *pte = kaiser_shadow_pagetable_walk(addr, KAISER_WALK_ATOMIC);
> +
> +		/*
> +		 * We are removing a mapping that should
> +		 * exist.  WARN if it was not there:
> +		 */
> +		if (!pte) {
> +			WARN_ON_ONCE(1);
> +			continue;
> +		}
> +
> +		pte_clear(&init_mm, addr, pte);
> +	}
> +	/*
> +	 * This ensures that the TLB entries used to map this data are
> +	 * no longer usable on *this* CPU.  We theoretically want to
> +	 * flush the entries on all CPUs here, but that's too
> +	 * expensive right now: this is called to unmap process
> +	 * stacks in the exit() path path.

s/path path/path/

> +	 *
> +	 * This can change if we get to the point where this is not
> +	 * in a remotely hot path, like only called via write_ldt().
> +	 *
> +	 * Note: we could probably also just invalidate the individual
> +	 * addresses to take care of *this* PCID and then do a
> +	 * tlb_flush_shared_nonglobals() to ensure that all other
> +	 * PCIDs get flushed before being used again.
> +	 */
> +	__native_flush_tlb_global();
> +}

> --- a/arch/x86/mm/pageattr.c~kaiser-base	2017-11-10 11:22:09.020244950 -0800
> +++ b/arch/x86/mm/pageattr.c	2017-11-10 11:22:09.035244950 -0800
> @@ -859,7 +859,7 @@ static void unmap_pmd_range(pud_t *pud,
>  			pud_clear(pud);
>  }
>  
> -static void unmap_pud_range(p4d_t *p4d, unsigned long start, unsigned long end)
> +void unmap_pud_range(p4d_t *p4d, unsigned long start, unsigned long end)

Should go into a preparatory patch.

>  {
>  	pud_t *pud = pud_offset(p4d, start);
>  

> diff -puN /dev/null Documentation/x86/kaiser.txt
> --- /dev/null	2017-11-06 07:51:38.702108459 -0800
> +++ b/Documentation/x86/kaiser.txt	2017-11-10 11:22:09.035244950 -0800
> @@ -0,0 +1,160 @@
> +Overview
> +========
> +
> +KAISER is a countermeasure against attacks on kernel address
> +information.  There are at least three existing, published,
> +approaches using the shared user/kernel mapping and hardware features
> +to defeat KASLR.  One approach referenced in the paper locates the
> +kernel by observing differences in page fault timing between
> +present-but-inaccessable kernel pages and non-present pages.
> +
> +When we enter the kernel via syscalls, interrupts or exceptions,

When the kernel is entered via ...

> +page tables are switched to the full "kernel" copy.  When the
> +system switches back to user mode, the user/shadow copy is used.
> +
> +The minimalistic kernel portion of the user page tables try to
> +map only what is needed to enter/exit the kernel such as the
> +entry/exit functions themselves and the interrupt descriptor
> +table (IDT).

s/try to//

> +This helps ensure that side-channel attacks that leverage the

helps to ensure

> +paging structures do not function when KAISER is enabled.  It
> +can be enabled by setting CONFIG_KAISER=y
> +
> +Page Table Management
> +=====================
> +
> +KAISER logically keeps a "copy" of the page tables which unmap
> +the kernel while in userspace.  The kernel manages the page
> +tables as normal, but the "copying" is done with a few tricks
> +that mean that we do not have to manage two full copies.
> +The first trick is that for any any new kernel mapping, we
> +presume that we do not want it mapped to userspace.  That means
> +we normally have no copying to do.  We only copy the kernel
> +entries over to the shadow in response to a kaiser_add_*()
> +call which is rare.

 When KAISER is enabled the kernel manages two page tables for the kernel
 mappings. The regular page table which is used while executing in kernel
 space and a shadow copy which only contains the mapping entries which are
 required for the kernel-userspace transition. These mappings have to be
 copied into the shadow page tables explicitely with the kaiser_add_*()
 functions.

Hmm?

> +For a new userspace mapping, the kernel makes the entries in
> +its page tables like normal.  The only difference is when the
> +kernel makes entries in the top (PGD) level.  In addition to
> +setting the entry in the main kernel PGD, a copy if the entry
> +is made in the shadow PGD.
> +PGD entries always point to another page table.  Two PGD
< +entries pointing to the same thing gives us shared page tables
> +for all the lower entries.  This leaves a single, shared set of
> +userspace page tables to manage.  One PTE to lock, one set set
> +of accessed bits, dirty bits, etc...

  For user space mappings the kernel creates an entry in the kernel PGD and
  the same entry in the shadow PGD, so the underlying page table to which
  the PGD entry points is shared down to the PTE level. This leaves a
  single, shared set of userspace page tables to manage.  One PTE to
  lock, one set set of accessed bits, dirty bits, etc...

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
