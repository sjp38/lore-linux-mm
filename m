Message-ID: <41C945E7.1040409@yahoo.com.au>
Date: Wed, 22 Dec 2004 21:01:11 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 11/11] convert x86_64 to 4 level page tables
References: <41C94361.6070909@yahoo.com.au> <41C943F0.4090006@yahoo.com.au> <41C94427.9020601@yahoo.com.au> <41C94449.20004@yahoo.com.au> <41C94473.7050804@yahoo.com.au> <41C9449A.4020607@yahoo.com.au> <41C944CC.4040801@yahoo.com.au> <41C944F3.1060208@yahoo.com.au> <41C9456A.9040107@yahoo.com.au> <41C945A9.6050202@yahoo.com.au> <41C945C2.80701@yahoo.com.au>
In-Reply-To: <41C945C2.80701@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------070901020204040204070905"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070901020204040204070905
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

11/11

--------------070901020204040204070905
Content-Type: text/plain;
 name="4level-x86-64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-x86-64.patch"



From: Andi Kleen <ak@suse.de>

Converted to true 4levels.  The address space per process is expanded to
47bits now, the supported physical address space is 46bits.

Lmbench fork/exit numbers are down a few percent because it has to walk much
more pagetables, but some planned future optimizations will hopefully recover
it.

See Documentation/x86_64/mm.txt for more details on the memory map.

Converted to pud_t by Nick Piggin.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/Documentation/x86_64/mm.txt      |  168 ++-------------------
 linux-2.6-npiggin/arch/x86_64/ia32/syscall32.c     |   31 ++-
 linux-2.6-npiggin/arch/x86_64/kernel/acpi/sleep.c  |    8 -
 linux-2.6-npiggin/arch/x86_64/kernel/head.S        |    1 
 linux-2.6-npiggin/arch/x86_64/kernel/init_task.c   |    2 
 linux-2.6-npiggin/arch/x86_64/kernel/reboot.c      |    2 
 linux-2.6-npiggin/arch/x86_64/kernel/setup64.c     |   13 -
 linux-2.6-npiggin/arch/x86_64/mm/fault.c           |  111 ++++++++-----
 linux-2.6-npiggin/arch/x86_64/mm/init.c            |  101 +++++-------
 linux-2.6-npiggin/arch/x86_64/mm/ioremap.c         |   43 ++++-
 linux-2.6-npiggin/arch/x86_64/mm/pageattr.c        |   34 ++--
 linux-2.6-npiggin/include/asm-x86_64/e820.h        |    3 
 linux-2.6-npiggin/include/asm-x86_64/mmu_context.h |    5 
 linux-2.6-npiggin/include/asm-x86_64/page.h        |   12 -
 linux-2.6-npiggin/include/asm-x86_64/pda.h         |    1 
 linux-2.6-npiggin/include/asm-x86_64/pgalloc.h     |   38 ++++
 linux-2.6-npiggin/include/asm-x86_64/pgtable.h     |  140 +++++++----------
 linux-2.6-npiggin/include/asm-x86_64/processor.h   |    4 
 18 files changed, 314 insertions(+), 403 deletions(-)

diff -puN Documentation/x86_64/mm.txt~4level-x86-64 Documentation/x86_64/mm.txt
--- linux-2.6/Documentation/x86_64/mm.txt~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/Documentation/x86_64/mm.txt	2004-12-22 20:33:05.000000000 +1100
@@ -1,148 +1,24 @@
-The paging design used on the x86-64 linux kernel port in 2.4.x provides:
 
-o	per process virtual address space limit of 512 Gigabytes
-o	top of userspace stack located at address 0x0000007fffffffff
-o	PAGE_OFFSET = 0xffff800000000000
-o	start of the kernel = 0xffffffff800000000
-o	global RAM per system 2^64-PAGE_OFFSET-sizeof(kernel) = 128 Terabytes - 2 Gigabytes
-o	no need of any common code change
-o	no need to use highmem to handle the 128 Terabytes of RAM
-
-Description:
-
-	Userspace is able to modify and it sees only the 3rd/2nd/1st level
-	pagetables (pgd_offset() implicitly walks the 1st slot of the 4th
-	level pagetable and it returns an entry into the 3rd level pagetable).
-	This is where the per-process 512 Gigabytes limit cames from.
-
-	The common code pgd is the PDPE, the pmd is the PDE, the
-	pte is the PTE. The PML4E remains invisible to the common
-	code.
-
-	The kernel uses all the first 47 bits of the negative half
-	of the virtual address space to build the direct mapping using
-	2 Mbytes page size. The kernel virtual	addresses have bit number
-	47 always set to 1 (and in turn also bits 48-63 are set to 1 too,
-	due the sign extension). This is where the 128 Terabytes - 2 Gigabytes global
-	limit of RAM cames from.
-
-	Since the per-process limit is 512 Gigabytes (due to kernel common
-	code 3 level pagetable limitation), the higher virtual address mapped
-	into userspace is 0x7fffffffff and it makes sense to use it
-	as the top of the userspace stack to allow the stack to grow as
-	much as possible.
-
-	Setting the PAGE_OFFSET to 2^39 (after the last userspace
-	virtual address) wouldn't make much difference compared to
-	setting PAGE_OFFSET to 0xffff800000000000 because we have an
-	hole into the virtual address space. The last byte mapped by the
-	255th slot in the 4th level pagetable is at virtual address
-	0x00007fffffffffff and the first byte mapped by the 256th slot in the
-	4th level pagetable is at address 0xffff800000000000. Due to this
-	hole we can't trivially build a direct mapping across all the
-	512 slots of the 4th level pagetable, so we simply use only the
-	second (negative) half of the 4th level pagetable for that purpose
-	(that provides us 128 Terabytes of contigous virtual addresses).
-	Strictly speaking we could build a direct mapping also across the hole
-	using some DISCONTIGMEM trick, but we don't need such a large
-	direct mapping right now.
-
-Future:
-
-	During 2.5.x we can break the 512 Gigabytes per-process limit
-	possibly by removing from the common code any knowledge about the
-	architectural dependent physical layout of the virtual to physical
-	mapping.
-
-	Once the 512 Gigabytes limit will be removed the kernel stack will
-	be moved (most probably to virtual address 0x00007fffffffffff).
-	Nothing	will break in userspace due that move, as nothing breaks
-	in IA32 compiling the kernel with CONFIG_2G.
-
-Linus agreed on not breaking common code and to live with the 512 Gigabytes
-per-process limitation for the 2.4.x timeframe and he has given me and Andi
-some very useful hints... (thanks! :)
-
-Thanks also to H. Peter Anvin for his interesting and useful suggestions on
-the x86-64-discuss lists!
-
-Other memory management related issues follows:
-
-PAGE_SIZE:
-
-	If somebody is wondering why these days we still have a so small
-	4k pagesize (16 or 32 kbytes would be much better for performance
-	of course), the PAGE_SIZE have to remain 4k for 32bit apps to
-	provide 100% backwards compatible IA32 API (we can't allow silent
-	fs corruption or as best a loss of coherency with the page cache
-	by allocating MAP_SHARED areas in MAP_ANONYMOUS memory with a
-	do_mmap_fake). I think it could be possible to have a dynamic page
-	size between 32bit and 64bit apps but it would need extremely
-	intrusive changes in the common code as first for page cache and
-	we sure don't want to depend on them right now even if the
-	hardware would support that.
-
-PAGETABLE SIZE:
-
-	In turn we can't afford to have pagetables larger than 4k because
-	we could not be able to allocate them due physical memory
-	fragmentation, and failing to allocate the kernel stack is a minor
-	issue compared to failing the allocation of a pagetable. If we
-	fail the allocation of a pagetable the only thing we can do is to
-	sched_yield polling the freelist (deadlock prone) or to segfault
-	the task (not even the sighandler would be sure to run).
-
-KERNEL STACK:
-
-	1st stage:
-
-	The kernel stack will be at first allocated with an order 2 allocation
-	(16k) (the utilization of the stack for a 64bit platform really
-	isn't exactly the double of a 32bit platform because the local
-	variables may not be all 64bit wide, but not much less). This will
-	make things even worse than they are right now on IA32 with
-	respect of failing fork/clone due memory fragmentation.
-
-	2nd stage:
-
-	We'll benchmark if reserving one register as task_struct
-	pointer will improve performance of the kernel (instead of
-	recalculating the task_struct pointer starting from the stack
-	pointer each time). My guess is that recalculating will be faster
-	but it worth a try.
-
-		If reserving one register for the task_struct pointer
-		will be faster we can as well split task_struct and kernel
-		stack. task_struct can be a slab allocation or a
-		PAGE_SIZEd allocation, and the kernel stack can then be
-		allocated in a order 1 allocation. Really this is risky,
-		since 8k on a 64bit platform is going to be less than 7k
-		on a 32bit platform but we could try it out. This would
-		reduce the fragmentation problem of an order of magnitude
-		making it equal to the current IA32.
-
-		We must also consider the x86-64 seems to provide in hardware a
-		per-irq stack that could allow us to remove the irq handler
-		footprint from the regular per-process-stack, so it could allow
-		us to live with a smaller kernel stack compared to the other
-		linux architectures.
-
-	3rd stage:
-
-	Before going into production if we still have the order 2
-	allocation we can add a sysctl that allows the kernel stack to be
-	allocated with vmalloc during memory fragmentation. This have to
-	remain turned off during benchmarks :) but it should be ok in real
-	life.
-
-Order of PAGE_CACHE_SIZE and other allocations:
-
-	On the long run we can increase the PAGE_CACHE_SIZE to be
-	an order 2 allocations and also the slab/buffercache etc.ec..
-	could be all done with order 2 allocations. To make the above
-	to work we should change lots of common code thus it can be done
-	only once the basic port will be in a production state. Having
-	a working PAGE_CACHE_SIZE would be a benefit also for
-	IA32 and other architectures of course.
+<previous description obsolete, deleted>
 
-Andrea <andrea@suse.de> SuSE
+Virtual memory map with 4 level page tables:
+
+0000000000000000 - 00007fffffffffff (=47bits) user space, different per mm
+hole caused by [48:63] sign extension
+ffff800000000000 - ffff80ffffffffff (=40bits) guard hole
+ffff810000000000 - ffffc0ffffffffff (=46bits) direct mapping of phys. memory
+ffffc10000000000 - ffffc1ffffffffff (=40bits) hole
+ffffc20000000000 - ffffe1ffffffffff (=45bits) vmalloc/ioremap space
+... unused hole ...
+ffffffff80000000 - ffffffff82800000 (=40MB)   kernel text mapping, from phys 0
+... unused hole ...
+ffffffff88000000 - fffffffffff00000 (=1919MB) module mapping space
+
+vmalloc space is lazily synchronized into the different PML4 pages of
+the processes using the page fault handler, with init_level4_pgt as
+reference.
+
+Current X86-64 implementations only support 40 bit of address space,
+but we support upto 46bits. This expands into MBZ space in the page tables.
+
+-Andi Kleen, Jul 2004
diff -puN arch/x86_64/ia32/syscall32.c~4level-x86-64 arch/x86_64/ia32/syscall32.c
--- linux-2.6/arch/x86_64/ia32/syscall32.c~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/ia32/syscall32.c	2004-12-22 20:33:05.000000000 +1100
@@ -40,23 +40,30 @@ static int use_sysenter = -1;
  */
 int __map_syscall32(struct mm_struct *mm, unsigned long address)
 { 
+	pgd_t *pgd;
+	pgd_t *pud;
 	pte_t *pte;
 	pmd_t *pmd;
-	int err = 0;
+	int err = -ENOMEM;
 
 	spin_lock(&mm->page_table_lock); 
-	pmd = pmd_alloc(mm, pgd_offset(mm, address), address); 
-	if (pmd && (pte = pte_alloc_map(mm, pmd, address)) != NULL) { 
-		if (pte_none(*pte)) { 
-			set_pte(pte, 
-				mk_pte(virt_to_page(syscall32_page), 
-				       PAGE_KERNEL_VSYSCALL)); 
+ 	pgd = pgd_offset(mm, address);
+ 	pud = pud_alloc(mm, pgd, address);
+ 	if (pud) {
+ 		pmd = pmd_alloc(mm, pud, address);
+ 		if (pmd && (pte = pte_alloc_map(mm, pmd, address)) != NULL) {
+ 			if (pte_none(*pte)) {
+ 				set_pte(pte,
+ 					mk_pte(virt_to_page(syscall32_page),
+ 					       PAGE_KERNEL_VSYSCALL));
+ 			}
+ 			/* Flush only the local CPU. Other CPUs taking a fault
+ 			   will just end up here again
+			   This probably not needed and just paranoia. */
+ 			__flush_tlb_one(address);
+ 			err = 0;
 		}
-		/* Flush only the local CPU. Other CPUs taking a fault
-		   will just end up here again */
-		__flush_tlb_one(address); 
-	} else
-		err = -ENOMEM; 
+	}
 	spin_unlock(&mm->page_table_lock);
 	return err;
 }
diff -puN arch/x86_64/kernel/acpi/sleep.c~4level-x86-64 arch/x86_64/kernel/acpi/sleep.c
--- linux-2.6/arch/x86_64/kernel/acpi/sleep.c~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/kernel/acpi/sleep.c	2004-12-22 20:33:05.000000000 +1100
@@ -61,9 +61,13 @@ extern char wakeup_start, wakeup_end;
 
 extern unsigned long FASTCALL(acpi_copy_wakeup_routine(unsigned long));
 
+static pgd_t low_ptr;
+
 static void init_low_mapping(void)
 {
-	cpu_pda[0].level4_pgt[0] = cpu_pda[0].level4_pgt[pml4_index(PAGE_OFFSET)];
+	pgd_t *slot0 = pgd_offset(current->mm, 0UL);
+	low_ptr = *slot0;
+	set_pgd(slot0, *pgd_offset(current->mm, PAGE_OFFSET));
 	flush_tlb_all();
 }
 
@@ -97,7 +101,7 @@ int acpi_save_state_disk (void)
  */
 void acpi_restore_state_mem (void)
 {
-	cpu_pda[0].level4_pgt[0] = 0;
+	set_pgd(pgd_offset(current->mm, 0UL), low_ptr);
 	flush_tlb_all();
 }
 
diff -puN arch/x86_64/kernel/head.S~4level-x86-64 arch/x86_64/kernel/head.S
--- linux-2.6/arch/x86_64/kernel/head.S~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/kernel/head.S	2004-12-22 20:33:05.000000000 +1100
@@ -225,7 +225,6 @@ ENTRY(init_level4_pgt)
 	.quad	0x0000000000103007		/* -> level3_kernel_pgt */
 
 .org 0x2000
-/* Kernel does not "know" about 4-th level of page tables. */
 ENTRY(level3_ident_pgt)
 	.quad	0x0000000000104007
 	.fill	511,8,0
diff -puN arch/x86_64/kernel/init_task.c~4level-x86-64 arch/x86_64/kernel/init_task.c
--- linux-2.6/arch/x86_64/kernel/init_task.c~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/kernel/init_task.c	2004-12-22 20:33:05.000000000 +1100
@@ -47,5 +47,3 @@ EXPORT_SYMBOL(init_task);
 DEFINE_PER_CPU(struct tss_struct, init_tss) ____cacheline_maxaligned_in_smp;
 
 #define ALIGN_TO_4K __attribute__((section(".data.init_task")))
-
-pgd_t boot_vmalloc_pgt[512]  ALIGN_TO_4K;
diff -puN arch/x86_64/kernel/setup64.c~4level-x86-64 arch/x86_64/kernel/setup64.c
--- linux-2.6/arch/x86_64/kernel/setup64.c~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/kernel/setup64.c	2004-12-22 20:33:05.000000000 +1100
@@ -66,7 +66,7 @@ __setup("noexec=", nonx_setup); 
 
 /*
  * Great future plan:
- * Declare PDA itself and support (irqstack,tss,pml4) as per cpu data.
+ * Declare PDA itself and support (irqstack,tss,pgd) as per cpu data.
  * Always point %gs to its beginning
  */
 void __init setup_per_cpu_areas(void)
@@ -100,7 +100,6 @@ void __init setup_per_cpu_areas(void)
 
 void pda_init(int cpu)
 { 
-        pml4_t *level4;
 	struct x8664_pda *pda = &cpu_pda[cpu];
 
 	/* Setup up data that may be needed in __get_free_pages early */
@@ -119,22 +118,14 @@ void pda_init(int cpu)
 		/* others are initialized in smpboot.c */
 		pda->pcurrent = &init_task;
 		pda->irqstackptr = boot_cpu_stack; 
-		level4 = init_level4_pgt; 
 	} else {
-		level4 = (pml4_t *)__get_free_pages(GFP_ATOMIC, 0); 
-		if (!level4) 
-			panic("Cannot allocate top level page for cpu %d", cpu); 
 		pda->irqstackptr = (char *)
 			__get_free_pages(GFP_ATOMIC, IRQSTACK_ORDER);
 		if (!pda->irqstackptr)
 			panic("cannot allocate irqstack for cpu %d", cpu); 
 	}
 
-	pda->level4_pgt = (unsigned long *)level4; 
-	if (level4 != init_level4_pgt)
-		memcpy(level4, &init_level4_pgt, PAGE_SIZE); 
-	set_pml4(level4 + 510, mk_kernel_pml4(__pa_symbol(boot_vmalloc_pgt)));
-	asm volatile("movq %0,%%cr3" :: "r" (__pa(level4))); 
+	asm volatile("movq %0,%%cr3" :: "r" (__pa_symbol(&init_level4_pgt)));
 
 	pda->irqstackptr += IRQSTACKSIZE-64;
 } 
diff -puN arch/x86_64/mm/fault.c~4level-x86-64 arch/x86_64/mm/fault.c
--- linux-2.6/arch/x86_64/mm/fault.c~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/mm/fault.c	2004-12-22 20:33:05.000000000 +1100
@@ -143,25 +143,25 @@ static int bad_address(void *p) 
 
 void dump_pagetable(unsigned long address)
 {
-	pml4_t *pml4;
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
-	asm("movq %%cr3,%0" : "=r" (pml4));
+	asm("movq %%cr3,%0" : "=r" (pgd));
 
-	pml4 = __va((unsigned long)pml4 & PHYSICAL_PAGE_MASK); 
-	pml4 += pml4_index(address);
-	printk("PML4 %lx ", pml4_val(*pml4));
-	if (bad_address(pml4)) goto bad;
-	if (!pml4_present(*pml4)) goto ret; 
-
-	pgd = __pgd_offset_k((pgd_t *)pml4_page(*pml4), address);
+	pgd = __va((unsigned long)pgd & PHYSICAL_PAGE_MASK); 
+	pgd += pgd_index(address);
+	printk("PGD %lx ", pgd_val(*pgd));
 	if (bad_address(pgd)) goto bad;
-	printk("PGD %lx ", pgd_val(*pgd)); 
-	if (!pgd_present(*pgd))	goto ret;
+	if (!pgd_present(*pgd)) goto ret; 
+
+	pud = __pud_offset_k((pud_t *)pgd_page(*pgd), address);
+	if (bad_address(pud)) goto bad;
+	printk("PUD %lx ", pud_val(*pud));
+	if (!pud_present(*pud))	goto ret;
 
-	pmd = pmd_offset(pgd, address);
+	pmd = pmd_offset(pud, address);
 	if (bad_address(pmd)) goto bad;
 	printk("PMD %lx ", pmd_val(*pmd));
 	if (!pmd_present(*pmd))	goto ret;	 
@@ -232,7 +232,53 @@ static noinline void pgtable_bad(unsigne
 	do_exit(SIGKILL);
 }
 
-int page_fault_trace; 
+/*
+ * Handle a fault on the vmalloc or module mapping area
+ */
+static int vmalloc_fault(unsigned long address)
+{
+	pgd_t *pgd, *pgd_ref;
+	pud_t *pud, *pud_ref;
+	pmd_t *pmd, *pmd_ref;
+	pte_t *pte, *pte_ref;
+
+	/* Copy kernel mappings over when needed. This can also
+	   happen within a race in page table update. In the later
+	   case just flush. */
+
+	pgd = pgd_offset(current->mm ?: &init_mm, address);
+	pgd_ref = pgd_offset_k(address);
+	if (pgd_none(*pgd_ref))
+		return -1;
+	if (pgd_none(*pgd))
+		set_pgd(pgd, *pgd_ref);
+
+	/* Below here mismatches are bugs because these lower tables
+	   are shared */
+
+	pud = pud_offset(pgd, address);
+	pud_ref = pud_offset(pgd_ref, address);
+	if (pud_none(*pud_ref))
+		return -1;
+	if (pud_none(*pud) || pud_page(*pud) != pud_page(*pud_ref))
+		BUG();
+	pmd = pmd_offset(pud, address);
+	pmd_ref = pmd_offset(pud_ref, address);
+	if (pmd_none(*pmd_ref))
+		return -1;
+	if (pmd_none(*pmd) || pmd_page(*pmd) != pmd_page(*pmd_ref))
+		BUG();
+	pte_ref = pte_offset_kernel(pmd_ref, address);
+	if (!pte_present(*pte_ref))
+		return -1;
+	pte = pte_offset_kernel(pmd, address);
+	if (!pte_present(*pte) || pte_page(*pte) != pte_page(*pte_ref))
+		BUG();
+	__flush_tlb_all();
+	return 0;
+}
+
+int page_fault_trace = 0;
 int exception_trace = 1;
 
 /*
@@ -300,8 +346,11 @@ asmlinkage void do_page_fault(struct pt_
 	 * protection error (error_code & 1) == 0.
 	 */
 	if (unlikely(address >= TASK_SIZE)) {
-		if (!(error_code & 5))
-			goto vmalloc_fault;
+		if (!(error_code & 5)) {
+			if (vmalloc_fault(address) < 0)
+				goto bad_area_nosemaphore;
+			return;
+		}
 		/*
 		 * Don't take the mm semaphore here. If we fixup a prefetch
 		 * fault we could otherwise deadlock.
@@ -310,7 +359,7 @@ asmlinkage void do_page_fault(struct pt_
 	}
 
 	if (unlikely(error_code & (1 << 3)))
-		goto page_table_corruption;
+		pgtable_bad(address, regs, error_code);
 
 	/*
 	 * If we're in an interrupt or have no user
@@ -524,34 +573,4 @@ do_sigbus:
 	info.si_addr = (void __user *)address;
 	force_sig_info(SIGBUS, &info, tsk);
 	return;
-
-vmalloc_fault:
-	{
-		pgd_t *pgd;
-		pmd_t *pmd;
-		pte_t *pte; 
-
-		/*
-		 * x86-64 has the same kernel 3rd level pages for all CPUs.
-		 * But for vmalloc/modules the TLB synchronization works lazily,
-		 * so it can happen that we get a page fault for something
-		 * that is really already in the page table. Just check if it
-		 * is really there and when yes flush the local TLB. 
-		 */
-		pgd = pgd_offset_k(address);
-		if (!pgd_present(*pgd))
-			goto bad_area_nosemaphore;
-		pmd = pmd_offset(pgd, address);
-		if (!pmd_present(*pmd))
-			goto bad_area_nosemaphore;
-		pte = pte_offset_kernel(pmd, address); 
-		if (!pte_present(*pte))
-			goto bad_area_nosemaphore;
-
-		__flush_tlb_all();		
-		return;
-	}
-
-page_table_corruption:
-	pgtable_bad(address, regs, error_code);
 }
diff -puN arch/x86_64/mm/init.c~4level-x86-64 arch/x86_64/mm/init.c
--- linux-2.6/arch/x86_64/mm/init.c~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/mm/init.c	2004-12-22 20:33:05.000000000 +1100
@@ -108,28 +108,28 @@ static void *spp_getpage(void)
 static void set_pte_phys(unsigned long vaddr,
 			 unsigned long phys, pgprot_t prot)
 {
-	pml4_t *level4;
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte, new_pte;
 
 	Dprintk("set_pte_phys %lx to %lx\n", vaddr, phys);
 
-	level4 = pml4_offset_k(vaddr);
-	if (pml4_none(*level4)) {
-		printk("PML4 FIXMAP MISSING, it should be setup in head.S!\n");
+	pgd = pgd_offset_k(vaddr);
+	if (pgd_none(*pgd)) {
+		printk("PGD FIXMAP MISSING, it should be setup in head.S!\n");
 		return;
 	}
-	pgd = level3_offset_k(level4, vaddr);
-	if (pgd_none(*pgd)) {
+	pud = pud_offset(pgd, vaddr);
+	if (pud_none(*pud)) {
 		pmd = (pmd_t *) spp_getpage(); 
-		set_pgd(pgd, __pgd(__pa(pmd) | _KERNPG_TABLE | _PAGE_USER));
-		if (pmd != pmd_offset(pgd, 0)) {
-			printk("PAGETABLE BUG #01! %p <-> %p\n", pmd, pmd_offset(pgd,0));
+		set_pud(pud, __pud(__pa(pmd) | _KERNPG_TABLE | _PAGE_USER));
+		if (pmd != pmd_offset(pud, 0)) {
+			printk("PAGETABLE BUG #01! %p <-> %p\n", pmd, pmd_offset(pud,0));
 			return;
 		}
 	}
-	pmd = pmd_offset(pgd, vaddr);
+	pmd = pmd_offset(pud, vaddr);
 	if (pmd_none(*pmd)) {
 		pte = (pte_t *) spp_getpage();
 		set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE | _PAGE_USER));
@@ -210,31 +210,31 @@ static __init void unmap_low_page(int i)
 	ti->allocated = 0; 
 } 
 
-static void __init phys_pgd_init(pgd_t *pgd, unsigned long address, unsigned long end)
+static void __init phys_pud_init(pud_t *pud, unsigned long address, unsigned long end)
 { 
 	long i, j; 
 
-	i = pgd_index(address);
-	pgd = pgd + i;
-	for (; i < PTRS_PER_PGD; pgd++, i++) {
+	i = pud_index(address);
+	pud = pud + i;
+	for (; i < PTRS_PER_PUD; pud++, i++) {
 		int map; 
 		unsigned long paddr, pmd_phys;
 		pmd_t *pmd;
 
-		paddr = (address & PML4_MASK) + i*PGDIR_SIZE;
+		paddr = address + i*PUD_SIZE;
 		if (paddr >= end) { 
-			for (; i < PTRS_PER_PGD; i++, pgd++) 
-				set_pgd(pgd, __pgd(0)); 
+			for (; i < PTRS_PER_PUD; i++, pud++) 
+				set_pud(pud, __pud(0)); 
 			break;
 		} 
 
-		if (!e820_mapped(paddr, paddr+PGDIR_SIZE, 0)) { 
-			set_pgd(pgd, __pgd(0)); 
+		if (!e820_mapped(paddr, paddr+PUD_SIZE, 0)) { 
+			set_pud(pud, __pud(0)); 
 			continue;
 		} 
 
 		pmd = alloc_low_page(&map, &pmd_phys);
-		set_pgd(pgd, __pgd(pmd_phys | _KERNPG_TABLE));
+		set_pud(pud, __pud(pmd_phys | _KERNPG_TABLE));
 		for (j = 0; j < PTRS_PER_PMD; pmd++, j++, paddr += PMD_SIZE) {
 			unsigned long pe;
 
@@ -260,7 +260,7 @@ void __init init_memory_mapping(void) 
 	unsigned long adr;	       
 	unsigned long end;
 	unsigned long next; 
-	unsigned long pgds, pmds, tables; 
+	unsigned long puds, pmds, tables; 
 
 	Dprintk("init_memory_mapping\n");
 
@@ -273,9 +273,9 @@ void __init init_memory_mapping(void) 
 	 * discovered.
 	 */
 
-	pgds = (end + PGDIR_SIZE - 1) >> PGDIR_SHIFT;
+	puds = (end + PUD_SIZE - 1) >> PUD_SHIFT;
 	pmds = (end + PMD_SIZE - 1) >> PMD_SHIFT; 
-	tables = round_up(pgds*8, PAGE_SIZE) + round_up(pmds * 8, PAGE_SIZE); 
+	tables = round_up(puds*8, PAGE_SIZE) + round_up(pmds * 8, PAGE_SIZE); 
 
 	table_start = find_e820_area(0x8000, __pa_symbol(&_text), tables); 
 	if (table_start == -1UL) 
@@ -288,13 +288,13 @@ void __init init_memory_mapping(void) 
 
 	for (adr = PAGE_OFFSET; adr < end; adr = next) { 
 		int map;
-		unsigned long pgd_phys; 
-		pgd_t *pgd = alloc_low_page(&map, &pgd_phys);
-		next = adr + PML4_SIZE;
+		unsigned long pud_phys; 
+		pud_t *pud = alloc_low_page(&map, &pud_phys);
+		next = adr + PGDIR_SIZE;
 		if (next > end) 
 			next = end; 
-		phys_pgd_init(pgd, adr-PAGE_OFFSET, next-PAGE_OFFSET); 
-		set_pml4(init_level4_pgt + pml4_index(adr), mk_kernel_pml4(pgd_phys));
+		phys_pud_init(pud, adr-PAGE_OFFSET, next-PAGE_OFFSET); 
+		set_pgd(init_level4_pgt + pgd_index(adr), mk_kernel_pgd(pud_phys));
 		unmap_low_page(map);   
 	} 
 	asm volatile("movq %%cr4,%0" : "=r" (mmu_cr4_features));
@@ -306,25 +306,12 @@ void __init init_memory_mapping(void) 
 
 extern struct x8664_pda cpu_pda[NR_CPUS];
 
-static unsigned long low_pml4[NR_CPUS];
-
-void swap_low_mappings(void)
-{
-	int i;
-	for (i = 0; i < NR_CPUS; i++) {
-	        unsigned long t;
-		if (!cpu_pda[i].level4_pgt) 
-			continue;
-		t = cpu_pda[i].level4_pgt[0];
-		cpu_pda[i].level4_pgt[0] = low_pml4[i];
-		low_pml4[i] = t;
-	}
-	flush_tlb_all();
-}
-
+/* Assumes all CPUs still execute in init_mm */
 void zap_low_mappings(void)
 {
-	swap_low_mappings();
+	pgd_t *pgd = pgd_offset_k(0UL);
+	pgd_clear(pgd);
+	flush_tlb_all();
 }
 
 #ifndef CONFIG_DISCONTIGMEM
@@ -361,10 +348,14 @@ void __init clear_kernel_mapping(unsigne
 	
 	for (; address < end; address += LARGE_PAGE_SIZE) { 
 		pgd_t *pgd = pgd_offset_k(address);
-               pmd_t *pmd;
-		if (!pgd || pgd_none(*pgd))
+		pud_t *pud;
+		pmd_t *pmd;
+		if (pgd_none(*pgd))
+			continue;
+		pud = pud_offset(pgd, address);
+		if (pud_none(*pud))
 			continue; 
-               pmd = pmd_offset(pgd, address);
+		pmd = pmd_offset(pud, address);
 		if (!pmd || pmd_none(*pmd))
 			continue; 
 		if (0 == (pmd_val(*pmd) & _PAGE_PSE)) { 
@@ -531,29 +522,29 @@ void __init reserve_bootmem_generic(unsi
 int kern_addr_valid(unsigned long addr) 
 { 
 	unsigned long above = ((long)addr) >> __VIRTUAL_MASK_SHIFT;
-       pml4_t *pml4;
        pgd_t *pgd;
+       pud_t *pud;
        pmd_t *pmd;
        pte_t *pte;
 
 	if (above != 0 && above != -1UL)
 		return 0; 
 	
-       pml4 = pml4_offset_k(addr);
-	if (pml4_none(*pml4))
+	pgd = pgd_offset_k(addr);
+	if (pgd_none(*pgd))
 		return 0;
 
-       pgd = pgd_offset_k(addr);
-	if (pgd_none(*pgd))
+	pud = pud_offset(pgd, addr);
+	if (pud_none(*pud))
 		return 0; 
 
-       pmd = pmd_offset(pgd, addr);
+	pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd))
 		return 0;
 	if (pmd_large(*pmd))
 		return pfn_valid(pmd_pfn(*pmd));
 
-       pte = pte_offset_kernel(pmd, addr);
+	pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte))
 		return 0;
 	return pfn_valid(pte_pfn(*pte));
diff -puN arch/x86_64/mm/ioremap.c~4level-x86-64 arch/x86_64/mm/ioremap.c
--- linux-2.6/arch/x86_64/mm/ioremap.c~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/mm/ioremap.c	2004-12-22 20:33:05.000000000 +1100
@@ -49,10 +49,10 @@ static inline int remap_area_pmd(pmd_t *
 {
 	unsigned long end;
 
-	address &= ~PGDIR_MASK;
+	address &= ~PUD_MASK;
 	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
+	if (end > PUD_SIZE)
+		end = PUD_SIZE;
 	phys_addr -= address;
 	if (address >= end)
 		BUG();
@@ -67,31 +67,54 @@ static inline int remap_area_pmd(pmd_t *
 	return 0;
 }
 
+static inline int remap_area_pud(pud_t * pud, unsigned long address, unsigned long size,
+	unsigned long phys_addr, unsigned long flags)
+{
+	unsigned long end;
+
+	address &= ~PGDIR_MASK;
+	end = address + size;
+	if (end > PGDIR_SIZE)
+		end = PGDIR_SIZE;
+	phys_addr -= address;
+	if (address >= end)
+		BUG();
+	do {
+		pmd_t * pmd = pmd_alloc(&init_mm, pud, address);
+		if (!pmd)
+			return -ENOMEM;
+		remap_area_pmd(pmd, address, end - address, address + phys_addr, flags);
+		address = (address + PUD_SIZE) & PUD_MASK;
+		pmd++;
+	} while (address && (address < end));
+	return 0;
+}
+
 static int remap_area_pages(unsigned long address, unsigned long phys_addr,
 				 unsigned long size, unsigned long flags)
 {
 	int error;
-	pgd_t * dir;
+	pgd_t *pgd;
 	unsigned long end = address + size;
 
 	phys_addr -= address;
-	dir = pgd_offset_k(address);
+	pgd = pgd_offset_k(address);
 	flush_cache_all();
 	if (address >= end)
 		BUG();
 	spin_lock(&init_mm.page_table_lock);
 	do {
-		pmd_t *pmd;
-		pmd = pmd_alloc(&init_mm, dir, address);
+		pud_t *pud;
+		pud = pud_alloc(&init_mm, pgd, address);
 		error = -ENOMEM;
-		if (!pmd)
+		if (!pud)
 			break;
-		if (remap_area_pmd(pmd, address, end - address,
+		if (remap_area_pud(pud, address, end - address,
 					 phys_addr + address, flags))
 			break;
 		error = 0;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
+		pgd++;
 	} while (address && (address < end));
 	spin_unlock(&init_mm.page_table_lock);
 	flush_tlb_all();
diff -puN arch/x86_64/mm/pageattr.c~4level-x86-64 arch/x86_64/mm/pageattr.c
--- linux-2.6/arch/x86_64/mm/pageattr.c~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/mm/pageattr.c	2004-12-22 20:33:05.000000000 +1100
@@ -16,12 +16,16 @@
 
 static inline pte_t *lookup_address(unsigned long address) 
 { 
-	pgd_t *pgd = pgd_offset_k(address); 
+	pgd_t *pgd = pgd_offset_k(address);
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
-	if (!pgd || !pgd_present(*pgd))
+	if (pgd_none(*pgd))
+		return NULL;
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
 		return NULL; 
-	pmd = pmd_offset(pgd, address); 	       
+	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		return NULL; 
 	if (pmd_large(*pmd))
@@ -98,16 +102,20 @@ static inline void save_page(unsigned lo
  */
 static void revert_page(unsigned long address, pgprot_t ref_prot)
 {
-       pgd_t *pgd;
-       pmd_t *pmd; 
-       pte_t large_pte; 
-       
-       pgd = pgd_offset_k(address); 
-       pmd = pmd_offset(pgd, address);
-       BUG_ON(pmd_val(*pmd) & _PAGE_PSE); 
-       pgprot_val(ref_prot) |= _PAGE_PSE;
-       large_pte = mk_pte_phys(__pa(address) & LARGE_PAGE_MASK, ref_prot);
-       set_pte((pte_t *)pmd, large_pte);
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t large_pte;
+
+	pgd = pgd_offset_k(address);
+	BUG_ON(pgd_none(*pgd));
+	pud = pud_offset(pgd,address);
+	BUG_ON(pud_none(*pud));
+	pmd = pmd_offset(pud, address);
+	BUG_ON(pmd_val(*pmd) & _PAGE_PSE);
+	pgprot_val(ref_prot) |= _PAGE_PSE;
+	large_pte = mk_pte_phys(__pa(address) & LARGE_PAGE_MASK, ref_prot);
+	set_pte((pte_t *)pmd, large_pte);
 }      
 
 static int
diff -puN include/asm-x86_64/e820.h~4level-x86-64 include/asm-x86_64/e820.h
--- linux-2.6/include/asm-x86_64/e820.h~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/include/asm-x86_64/e820.h	2004-12-22 20:33:05.000000000 +1100
@@ -26,9 +26,6 @@
 
 #define LOWMEMSIZE()	(0x9f000)
 
-#define MAXMEM		(120UL * 1024 * 1024 * 1024 * 1024)  /* 120TB */ 
-
-
 #ifndef __ASSEMBLY__
 struct e820entry {
 	u64 addr;	/* start of memory segment */
diff -puN include/asm-x86_64/mmu_context.h~4level-x86-64 include/asm-x86_64/mmu_context.h
--- linux-2.6/include/asm-x86_64/mmu_context.h~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/include/asm-x86_64/mmu_context.h	2004-12-22 20:33:05.000000000 +1100
@@ -40,10 +40,7 @@ static inline void switch_mm(struct mm_s
 		write_pda(active_mm, next);
 #endif
 		set_bit(cpu, &next->cpu_vm_mask);
-		/* Re-load page tables */
-		*read_pda(level4_pgt) = __pa(next->pgd) | _PAGE_TABLE;
-		__flush_tlb();
-
+		asm volatile("movq %0,%%cr3" :: "r" (__pa(next->pgd)) : "memory");
 		if (unlikely(next->context.ldt != prev->context.ldt)) 
 			load_LDT_nolock(&next->context, cpu);
 	}
diff -puN include/asm-x86_64/page.h~4level-x86-64 include/asm-x86_64/page.h
--- linux-2.6/include/asm-x86_64/page.h~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/include/asm-x86_64/page.h	2004-12-22 20:33:05.000000000 +1100
@@ -43,22 +43,22 @@ void copy_page(void *, void *);
  */
 typedef struct { unsigned long pte; } pte_t;
 typedef struct { unsigned long pmd; } pmd_t;
+typedef struct { unsigned long pud; } pud_t;
 typedef struct { unsigned long pgd; } pgd_t;
-typedef struct { unsigned long pml4; } pml4_t;
 #define PTE_MASK	PHYSICAL_PAGE_MASK
 
 typedef struct { unsigned long pgprot; } pgprot_t;
 
 #define pte_val(x)	((x).pte)
 #define pmd_val(x)	((x).pmd)
+#define pud_val(x)	((x).pud)
 #define pgd_val(x)	((x).pgd)
-#define pml4_val(x)	((x).pml4)
 #define pgprot_val(x)	((x).pgprot)
 
 #define __pte(x) ((pte_t) { (x) } )
 #define __pmd(x) ((pmd_t) { (x) } )
+#define __pud(x) ((pud_t) { (x) } )
 #define __pgd(x) ((pgd_t) { (x) } )
-#define __pml4(x) ((pml4_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
 extern unsigned long vm_stack_flags, vm_stack_flags32;
@@ -67,19 +67,19 @@ extern unsigned long vm_force_exec32;
 
 #define __START_KERNEL		0xffffffff80100000UL
 #define __START_KERNEL_map	0xffffffff80000000UL
-#define __PAGE_OFFSET           0x0000010000000000UL	/* 1 << 40 */
+#define __PAGE_OFFSET           0xffff810000000000UL
 
 #else
 #define __START_KERNEL		0xffffffff80100000
 #define __START_KERNEL_map	0xffffffff80000000
-#define __PAGE_OFFSET           0x0000010000000000	/* 1 << 40 */
+#define __PAGE_OFFSET           0xffff810000000000
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
 #define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
 
 /* See Documentation/x86_64/mm.txt for a description of the memory map. */
-#define __PHYSICAL_MASK_SHIFT	40
+#define __PHYSICAL_MASK_SHIFT	46
 #define __PHYSICAL_MASK		((1UL << __PHYSICAL_MASK_SHIFT) - 1)
 #define __VIRTUAL_MASK_SHIFT	48
 #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
diff -puN include/asm-x86_64/pda.h~4level-x86-64 include/asm-x86_64/pda.h
--- linux-2.6/include/asm-x86_64/pda.h~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/include/asm-x86_64/pda.h	2004-12-22 20:33:05.000000000 +1100
@@ -17,7 +17,6 @@ struct x8664_pda {
         int irqcount;		    /* Irq nesting counter. Starts with -1 */  	
 	int cpunumber;		    /* Logical CPU number */
 	char *irqstackptr;	/* top of irqstack */
-	unsigned long volatile *level4_pgt; /* Per CPU top level page table */
 	unsigned int __softirq_pending;
 	unsigned int __nmi_count;	/* number of NMI on this CPUs */
 	struct mm_struct *active_mm;
diff -puN include/asm-x86_64/pgalloc.h~4level-x86-64 include/asm-x86_64/pgalloc.h
--- linux-2.6/include/asm-x86_64/pgalloc.h~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/include/asm-x86_64/pgalloc.h	2004-12-22 20:33:05.000000000 +1100
@@ -9,8 +9,10 @@
 
 #define pmd_populate_kernel(mm, pmd, pte) \
 		set_pmd(pmd, __pmd(_PAGE_TABLE | __pa(pte)))
-#define pgd_populate(mm, pgd, pmd) \
-		set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(pmd)))
+#define pud_populate(mm, pud, pmd) \
+		set_pud(pud, __pud(_PAGE_TABLE | __pa(pmd)))
+#define pgd_populate(mm, pgd, pud) \
+		set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(pud)))
 
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *pte)
 {
@@ -33,12 +35,37 @@ static inline pmd_t *pmd_alloc_one (stru
 	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline pgd_t *pgd_alloc (struct mm_struct *mm)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pgd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 }
 
-static inline void pgd_free (pgd_t *pgd)
+static inline void pud_free (pud_t *pud)
+{
+	BUG_ON((unsigned long)pud & (PAGE_SIZE-1));
+	free_page((unsigned long)pud);
+}
+
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	unsigned boundary;
+	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	if (!pgd)
+		return NULL;
+	/*
+	 * Copy kernel pointers in from init.
+	 * Could keep a freelist or slab cache of those because the kernel
+	 * part never changes.
+	 */
+	boundary = pgd_index(__PAGE_OFFSET);
+	memset(pgd, 0, boundary * sizeof(pgd_t));
+	memcpy(pgd + boundary,
+	       init_level4_pgt + boundary,
+	       (PTRS_PER_PGD - boundary) * sizeof(pgd_t));
+	return pgd;
+}
+
+static inline void pgd_free(pgd_t *pgd)
 {
 	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
 	free_page((unsigned long)pgd);
@@ -73,5 +100,6 @@ extern inline void pte_free(struct page 
 
 #define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
 #define __pmd_free_tlb(tlb,x)   pmd_free(x)
+#define __pud_free_tlb(tlb,x)   pud_free(x)
 
 #endif /* _X86_64_PGALLOC_H */
diff -puN include/asm-x86_64/pgtable.h~4level-x86-64 include/asm-x86_64/pgtable.h
--- linux-2.6/include/asm-x86_64/pgtable.h~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/include/asm-x86_64/pgtable.h	2004-12-22 20:34:25.000000000 +1100
@@ -1,17 +1,9 @@
 #ifndef _X86_64_PGTABLE_H
 #define _X86_64_PGTABLE_H
 
-#include <asm-generic/4level-fixup.h>
-
 /*
  * This file contains the functions and defines necessary to modify and use
  * the x86-64 page table tree.
- * 
- * x86-64 has a 4 level table setup. Generic linux MM only supports
- * three levels. The fourth level is currently a single static page that
- * is shared by everybody and just contains a pointer to the current
- * three level page setup on the beginning and some kernel mappings at 
- * the end. For more details see Documentation/x86_64/mm.txt
  */
 #include <asm/processor.h>
 #include <asm/fixmap.h>
@@ -19,15 +11,14 @@
 #include <linux/threads.h>
 #include <asm/pda.h>
 
-extern pgd_t level3_kernel_pgt[512];
-extern pgd_t level3_physmem_pgt[512];
-extern pgd_t level3_ident_pgt[512];
+extern pud_t level3_kernel_pgt[512];
+extern pud_t level3_physmem_pgt[512];
+extern pud_t level3_ident_pgt[512];
 extern pmd_t level2_kernel_pgt[512];
-extern pml4_t init_level4_pgt[];
-extern pgd_t boot_vmalloc_pgt[];
+extern pgd_t init_level4_pgt[];
 extern unsigned long __supported_pte_mask;
 
-#define swapper_pg_dir NULL
+#define swapper_pg_dir init_level4_pgt
 
 extern void paging_init(void);
 extern void clear_kernel_mapping(unsigned long addr, unsigned long size);
@@ -41,16 +32,19 @@ extern unsigned long pgkern_mask;
 extern unsigned long empty_zero_page[PAGE_SIZE/sizeof(unsigned long)];
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
 
-#define PML4_SHIFT	39
-#define PTRS_PER_PML4	512
-
 /*
  * PGDIR_SHIFT determines what a top-level page table entry can map
  */
-#define PGDIR_SHIFT	30
+#define PGDIR_SHIFT	39
 #define PTRS_PER_PGD	512
 
 /*
+ * 3rd level page
+ */
+#define PUD_SHIFT	30
+#define PTRS_PER_PUD	512
+
+/*
  * PMD_SHIFT determines the size of the area a middle-level
  * page table can map
  */
@@ -66,14 +60,13 @@ extern unsigned long empty_zero_page[PAG
 	printk("%s:%d: bad pte %p(%016lx).\n", __FILE__, __LINE__, &(e), pte_val(e))
 #define pmd_ERROR(e) \
 	printk("%s:%d: bad pmd %p(%016lx).\n", __FILE__, __LINE__, &(e), pmd_val(e))
+#define pud_ERROR(e) \
+	printk("%s:%d: bad pud %p(%016lx).\n", __FILE__, __LINE__, &(e), pud_val(e))
 #define pgd_ERROR(e) \
 	printk("%s:%d: bad pgd %p(%016lx).\n", __FILE__, __LINE__, &(e), pgd_val(e))
 
-
-#define pml4_none(x)	(!pml4_val(x))
 #define pgd_none(x)	(!pgd_val(x))
-
-extern inline int pgd_present(pgd_t pgd)	{ return !pgd_none(pgd); }
+#define pud_none(x)	(!pud_val(x))
 
 static inline void set_pte(pte_t *dst, pte_t val)
 {
@@ -85,6 +78,16 @@ static inline void set_pmd(pmd_t *dst, p
         pmd_val(*dst) = pmd_val(val); 
 } 
 
+static inline void set_pud(pud_t *dst, pud_t val)
+{
+	pud_val(*dst) = pud_val(val);
+}
+
+extern inline void pud_clear (pud_t *pud)
+{
+	set_pud(pud, __pud(0));
+}
+
 static inline void set_pgd(pgd_t *dst, pgd_t val)
 {
 	pgd_val(*dst) = pgd_val(val); 
@@ -95,45 +98,30 @@ extern inline void pgd_clear (pgd_t * pg
 	set_pgd(pgd, __pgd(0));
 }
 
-static inline void set_pml4(pml4_t *dst, pml4_t val)
-{
-	pml4_val(*dst) = pml4_val(val); 
-}
-
-#define pgd_page(pgd) \
-((unsigned long) __va(pgd_val(pgd) & PHYSICAL_PAGE_MASK))
+#define pud_page(pud) \
+((unsigned long) __va(pud_val(pud) & PHYSICAL_PAGE_MASK))
 
 #define ptep_get_and_clear(xp)	__pte(xchg(&(xp)->pte, 0))
 #define pte_same(a, b)		((a).pte == (b).pte)
 
-#define PML4_SIZE	(1UL << PML4_SHIFT)
-#define PML4_MASK       (~(PML4_SIZE-1))
 #define PMD_SIZE	(1UL << PMD_SHIFT)
 #define PMD_MASK	(~(PMD_SIZE-1))
+#define PUD_SIZE	(1UL << PUD_SHIFT)
+#define PUD_MASK	(~(PUD_SIZE-1))
 #define PGDIR_SIZE	(1UL << PGDIR_SHIFT)
 #define PGDIR_MASK	(~(PGDIR_SIZE-1))
 
 #define USER_PTRS_PER_PGD	(TASK_SIZE/PGDIR_SIZE)
 #define FIRST_USER_PGD_NR	0
 
-#define USER_PGD_PTRS (PAGE_OFFSET >> PGDIR_SHIFT)
-#define KERNEL_PGD_PTRS (PTRS_PER_PGD-USER_PGD_PTRS)
-
-#define TWOLEVEL_PGDIR_SHIFT	20
-#define BOOT_USER_L4_PTRS 1
-#define BOOT_KERNEL_L4_PTRS 511	/* But we will do it in 4rd level */
-
-
-
 #ifndef __ASSEMBLY__
-#define VMALLOC_START    0xffffff0000000000UL
-#define VMALLOC_END      0xffffff7fffffffffUL
-#define MODULES_VADDR    0xffffffffa0000000UL
-#define MODULES_END      0xffffffffafffffffUL
+#define MAXMEM		 0x3fffffffffffUL
+#define VMALLOC_START    0xffffc20000000000UL
+#define VMALLOC_END      0xffffe1ffffffffffUL
+#define MODULES_VADDR    0xffffffff88000000
+#define MODULES_END      0xfffffffffff00000
 #define MODULES_LEN   (MODULES_END - MODULES_VADDR)
 
-#define IOMAP_START      0xfffffe8000000000UL
-
 #define _PAGE_BIT_PRESENT	0
 #define _PAGE_BIT_RW		1
 #define _PAGE_BIT_USER		2
@@ -224,6 +212,14 @@ static inline unsigned long pgd_bad(pgd_
        return val & ~(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED);      
 } 
 
+static inline unsigned long pud_bad(pud_t pud)
+{
+       unsigned long val = pud_val(pud);
+       val &= ~PTE_MASK;
+       val &= ~(_PAGE_USER | _PAGE_DIRTY);
+       return val & ~(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED);
+}
+
 #define pte_none(x)	(!pte_val(x))
 #define pte_present(x)	(pte_val(x) & (_PAGE_PRESENT | _PAGE_PROTNONE))
 #define pte_clear(xp)	do { set_pte(xp, __pte(0)); } while (0)
@@ -302,54 +298,32 @@ static inline int pmd_large(pmd_t pte) {
 
 /*
  * Level 4 access.
- * Never use these in the common code.
  */
-#define pml4_page(pml4) ((unsigned long) __va(pml4_val(pml4) & PTE_MASK))
-#define pml4_index(address) ((address >> PML4_SHIFT) & (PTRS_PER_PML4-1))
-#define pml4_offset_k(address) (init_level4_pgt + pml4_index(address))
-#define pml4_present(pml4) (pml4_val(pml4) & _PAGE_PRESENT)
-#define mk_kernel_pml4(address) ((pml4_t){ (address) | _KERNPG_TABLE })
-#define level3_offset_k(dir, address) ((pgd_t *) pml4_page(*(dir)) + pgd_index(address))
+#define pgd_page(pgd) ((unsigned long) __va((unsigned long)pgd_val(pgd) & PTE_MASK))
+#define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
+#define pgd_offset(mm, addr) ((mm)->pgd + pgd_index(addr))
+#define pgd_offset_k(address) (init_level4_pgt + pgd_index(address))
+#define pgd_present(pgd) (pgd_val(pgd) & _PAGE_PRESENT)
+#define mk_kernel_pgd(address) ((pgd_t){ (address) | _KERNPG_TABLE })
 
-/* PGD - Level3 access */
+/* PUD - Level3 access */
 /* to find an entry in a page-table-directory. */
-#define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
-static inline pgd_t *__pgd_offset_k(pgd_t *pgd, unsigned long address)
+#define pud_index(address) (((address) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
+#define pud_offset(pgd, address) ((pud_t *) pgd_page(*(pgd)) + pud_index(address))
+#define pud_offset_k(pgd, addr) pud_offset(pgd, addr)
+#define pud_present(pud) (pud_val(pud) & _PAGE_PRESENT)
+
+static inline pud_t *__pud_offset_k(pud_t *pud, unsigned long address)
 { 
-	return pgd + pgd_index(address);
+	return pud + pud_index(address);
 } 
 
-/* Find correct pgd via the hidden fourth level page level: */
-
-/* This accesses the reference page table of the boot cpu. 
-   Other CPUs get synced lazily via the page fault handler. */
-static inline pgd_t *pgd_offset_k(unsigned long address)
-{
-	unsigned long addr;
-
-	addr = pml4_val(init_level4_pgt[pml4_index(address)]);
-	addr &= PHYSICAL_PAGE_MASK;
-	return __pgd_offset_k((pgd_t *)__va(addr), address);
-}
-
-/* Access the pgd of the page table as seen by the current CPU. */ 
-static inline pgd_t *current_pgd_offset_k(unsigned long address)
-{
-	unsigned long addr;
-
-	addr = read_pda(level4_pgt)[pml4_index(address)];
-	addr &= PHYSICAL_PAGE_MASK;
-	return __pgd_offset_k((pgd_t *)__va(addr), address);
-}
-
-#define pgd_offset(mm, address) ((mm)->pgd+pgd_index(address))
-
 /* PMD  - Level 2 access */
 #define pmd_page_kernel(pmd) ((unsigned long) __va(pmd_val(pmd) & PTE_MASK))
 #define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 
 #define pmd_index(address) (((address) >> PMD_SHIFT) & (PTRS_PER_PMD-1))
-#define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
+#define pmd_offset(dir, address) ((pmd_t *) pud_page(*(dir)) + \
 			pmd_index(address))
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
diff -puN include/asm-x86_64/processor.h~4level-x86-64 include/asm-x86_64/processor.h
--- linux-2.6/include/asm-x86_64/processor.h~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/include/asm-x86_64/processor.h	2004-12-22 20:33:05.000000000 +1100
@@ -165,9 +165,9 @@ static inline void clear_in_cr4 (unsigne
 
 
 /*
- * User space process size: 512GB - 1GB (default).
+ * User space process size. 47bits.
  */
-#define TASK_SIZE	(0x0000007fc0000000UL)
+#define TASK_SIZE	(0x800000000000)
 
 /* This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
diff -puN arch/x86_64/kernel/reboot.c~4level-x86-64 arch/x86_64/kernel/reboot.c
--- linux-2.6/arch/x86_64/kernel/reboot.c~4level-x86-64	2004-12-22 20:33:05.000000000 +1100
+++ linux-2.6-npiggin/arch/x86_64/kernel/reboot.c	2004-12-22 20:33:05.000000000 +1100
@@ -74,7 +74,7 @@ static void reboot_warm(void)
 	local_irq_disable(); 
 		
 	/* restore identity mapping */
-	init_level4_pgt[0] = __pml4(__pa(level3_ident_pgt) | 7); 
+	init_level4_pgt[0] = __pgd(__pa(level3_ident_pgt) | 7); 
 	__flush_tlb_all(); 
 
 	/* Move the trampoline to low memory */

_

--------------070901020204040204070905--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
