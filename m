Date: Sat, 6 Nov 2004 01:28:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <418C55A7.9030100@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
References: <4189EC67.40601@yahoo.com.au>  <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com>
  <418AD329.3000609@yahoo.com.au>  <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com>
  <418AE0F0.5050908@yahoo.com.au>  <418AE9BB.1000602@yahoo.com.au>
 <1099622957.29587.101.camel@gaston> <418C55A7.9030100@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

My page scalability patches need to make rss atomic and now with the
addition of anon_rss I would also have to make that atomic.

But when I looked at the code I found that the only significant use of
both is in for proc statistics. There are 3 other uses in mm/rmap.c where
the use of mm->rss may be replaced by mm->total_vm.

So I removed all uses of mm->rss and anon_rss from the kernel and
introduced a bean counter count_vm() that is only run when the
corresponding /proc file is used. count_vm then runs throught the vm
and counts all the page types. This could also add additional page types to our
statistics and solve some of the consistency issues.

The patch is by no means perfect. If you think this is worth pursuing then
I will finish the support for other archs and deal with the locking
issues etc. This patch may also remove hot spot issues that may arise with
the use of these two variables and so is of interest to us.

But a kernel with this patch boots fine and the statistics in /proc look
still okay (its late though....)

Index: linux-2.6.9/kernel/fork.c
===================================================================
--- linux-2.6.9.orig/kernel/fork.c	2004-11-03 13:36:35.000000000 -0800
+++ linux-2.6.9/kernel/fork.c	2004-11-05 18:09:53.000000000 -0800
@@ -172,8 +172,6 @@
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
 	mm->map_count = 0;
-	mm->rss = 0;
-	mm->anon_rss = 0;
 	cpus_clear(mm->cpu_vm_mask);
 	mm->mm_rb = RB_ROOT;
 	rb_link = &mm->mm_rb.rb_node;
Index: linux-2.6.9/include/linux/sched.h
===================================================================
--- linux-2.6.9.orig/include/linux/sched.h	2004-11-03 13:36:35.000000000 -0800
+++ linux-2.6.9/include/linux/sched.h	2004-11-05 18:09:33.000000000 -0800
@@ -216,7 +216,7 @@
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
-	spinlock_t page_table_lock;		/* Protects page tables, mm->rss, mm->anon_rss */
+	spinlock_t page_table_lock;		/* Protects page tables */

 	struct list_head mmlist;		/* List of maybe swapped mm's.  These are globally strung
 						 * together off init_mm.mmlist, and are protected
@@ -226,7 +226,7 @@
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;
-	unsigned long rss, anon_rss, total_vm, locked_vm, shared_vm;
+	unsigned long total_vm, locked_vm, shared_vm;
 	unsigned long exec_vm, stack_vm, reserved_vm, def_flags, nr_ptes;

 	unsigned long saved_auxv[42]; /* for /proc/PID/auxv */
Index: linux-2.6.9/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.9.orig/fs/proc/task_mmu.c	2004-11-03 13:36:34.000000000 -0800
+++ linux-2.6.9/fs/proc/task_mmu.c	2004-11-06 00:41:11.000000000 -0800
@@ -7,10 +7,13 @@
 char *task_mem(struct mm_struct *mm, char *buffer)
 {
 	unsigned long data, text, lib;
+	struct vm_count c;
+

 	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
+	count_vm(mm, &c);
 	buffer += sprintf(buffer,
 		"VmSize:\t%8lu kB\n"
 		"VmLck:\t%8lu kB\n"
@@ -22,7 +25,7 @@
 		"VmPTE:\t%8lu kB\n",
 		(mm->total_vm - mm->reserved_vm) << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
-		mm->rss << (PAGE_SHIFT-10),
+		c.resident << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10);
@@ -37,11 +40,14 @@
 int task_statm(struct mm_struct *mm, int *shared, int *text,
 	       int *data, int *resident)
 {
-	*shared = mm->rss - mm->anon_rss;
+	struct vm_count c;
+
+	count_vm(mm, &c);
+	*shared = c.shared;
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
-	*resident = mm->rss;
+	*resident = c.resident;
 	return mm->total_vm;
 }

Index: linux-2.6.9/mm/mmap.c
===================================================================
--- linux-2.6.9.orig/mm/mmap.c	2004-11-03 13:36:36.000000000 -0800
+++ linux-2.6.9/mm/mmap.c	2004-11-05 18:12:00.000000000 -0800
@@ -1850,7 +1850,6 @@
 	vma = mm->mmap;
 	mm->mmap = mm->mmap_cache = NULL;
 	mm->mm_rb = RB_ROOT;
-	mm->rss = 0;
 	mm->total_vm = 0;
 	mm->locked_vm = 0;

Index: linux-2.6.9/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.9.orig/include/asm-generic/tlb.h	2004-10-18 14:53:05.000000000 -0700
+++ linux-2.6.9/include/asm-generic/tlb.h	2004-11-06 01:12:10.000000000 -0800
@@ -86,13 +86,6 @@
 static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	int freed = tlb->freed;
-	struct mm_struct *mm = tlb->mm;
-	int rss = mm->rss;
-
-	if (rss < freed)
-		freed = rss;
-	mm->rss = rss - freed;
 	tlb_flush_mmu(tlb, start, end);

 	/* keep the page table cache within bounds */
Index: linux-2.6.9/fs/exec.c
===================================================================
--- linux-2.6.9.orig/fs/exec.c	2004-11-03 13:36:34.000000000 -0800
+++ linux-2.6.9/fs/exec.c	2004-11-05 18:19:42.000000000 -0800
@@ -320,7 +320,6 @@
 		pte_unmap(pte);
 		goto out;
 	}
-	mm->rss++;
 	lru_cache_add_active(page);
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
Index: linux-2.6.9/fs/binfmt_flat.c
===================================================================
--- linux-2.6.9.orig/fs/binfmt_flat.c	2004-11-03 13:36:29.000000000 -0800
+++ linux-2.6.9/fs/binfmt_flat.c	2004-11-05 18:19:27.000000000 -0800
@@ -650,7 +650,6 @@
 		current->mm->start_brk = datapos + data_len + bss_len;
 		current->mm->brk = (current->mm->start_brk + 3) & ~3;
 		current->mm->context.end_brk = memp + ksize((void *) memp) - stack_len;
-		current->mm->rss = 0;
 	}

 	if (flags & FLAT_FLAG_KTRACE)
Index: linux-2.6.9/mm/memory.c
===================================================================
--- linux-2.6.9.orig/mm/memory.c	2004-11-03 13:36:36.000000000 -0800
+++ linux-2.6.9/mm/memory.c	2004-11-06 01:10:19.000000000 -0800
@@ -333,9 +333,6 @@
 					pte = pte_mkclean(pte);
 				pte = pte_mkold(pte);
 				get_page(page);
-				dst->rss++;
-				if (PageAnon(page))
-					dst->anon_rss++;
 				set_pte(dst_pte, pte);
 				page_dup_rmap(page);
 cont_copy_pte_range_noset:
@@ -426,8 +423,6 @@
 				set_pte(ptep, pgoff_to_pte(page->index));
 			if (pte_dirty(pte))
 				set_page_dirty(page);
-			if (PageAnon(page))
-				tlb->mm->anon_rss--;
 			else if (pte_young(pte))
 				mark_page_accessed(page);
 			tlb->freed++;
@@ -1113,11 +1108,7 @@
 	spin_lock(&mm->page_table_lock);
 	page_table = pte_offset_map(pmd, address);
 	if (likely(pte_same(*page_table, pte))) {
-		if (PageAnon(old_page))
-			mm->anon_rss--;
-		if (PageReserved(old_page))
-			++mm->rss;
-		else
+		if (!PageReserved(old_page))
 			page_remove_rmap(old_page);
 		break_cow(vma, new_page, address, page_table);
 		lru_cache_add_active(new_page);
@@ -1398,7 +1389,6 @@
 	if (vm_swap_full())
 		remove_exclusive_swap_page(page);

-	mm->rss++;
 	pte = mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -1463,7 +1453,6 @@
 			spin_unlock(&mm->page_table_lock);
 			goto out;
 		}
-		mm->rss++;
 		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
 							 vma->vm_page_prot)),
 				      vma);
@@ -1571,8 +1560,6 @@
 	 */
 	/* Only go through if we didn't race with anybody else... */
 	if (pte_none(*page_table)) {
-		if (!PageReserved(new_page))
-			++mm->rss;
 		flush_icache_page(vma, new_page);
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
@@ -1851,3 +1838,108 @@
 }

 #endif
+
+static void count_pte_range(pmd_t *pmd,
+	unsigned long address, unsigned long size,
+	struct vm_count *c)
+{
+        unsigned long offset;
+        pte_t *ptep;
+
+        if (pmd_none(*pmd))
+                return;
+        if (unlikely(pmd_bad(*pmd)))
+                return;
+        ptep = pte_offset_map(pmd, address);
+        offset = address & ~PMD_MASK;
+        if (offset + size > PMD_SIZE)
+                size = PMD_SIZE - offset;
+        size &= PAGE_MASK;
+        for (offset=0; offset < size; ptep++, offset += PAGE_SIZE) {
+                pte_t pte = *ptep;
+
+		if (pte_none(pte))
+                        continue;
+
+                if (pte_present(pte)) {
+                        struct page *page = NULL;
+                        unsigned long pfn = pte_pfn(pte);
+
+			c->present++;
+                        if (pfn_valid(pfn)) {
+                                page = pfn_to_page(pfn);
+                                if (PageReserved(page))
+                                        c->reserved++;
+				else
+				if (page_mapped(page) > 1)
+					c->shared++;
+				else
+				if (page_mapped(page) == 1)
+					c->resident++;
+
+				if (PageLocked(page))
+					c->locked++;
+                        }
+                        if (unlikely(!page))
+                                continue;
+                        if (pte_dirty(pte))
+                                c->dirty++;
+                        else if (pte_young(pte))
+                                c->young++;
+                } else {
+	                if (pte_file(pte))
+				c->file++;
+			else
+				c->swap++;
+		}
+        }
+}
+
+static void count_pmd_range(pgd_t *dir,
+	unsigned long address, unsigned long end, struct vm_count *c)
+{
+	pmd_t * pmd;
+
+        if (pgd_none(*dir))
+                return;
+        if (unlikely(pgd_bad(*dir)))
+                return;
+
+	pmd = pmd_offset(dir, address);
+
+	if (end > ((address + PGDIR_SIZE) & PGDIR_MASK))
+                end = ((address + PGDIR_SIZE) & PGDIR_MASK);
+        do {
+                count_pte_range(pmd, address, end - address, c);
+                address = (address + PMD_SIZE) & PMD_MASK;
+                pmd++;
+        } while (address && address < end);
+}
+
+static void count_vma(struct vm_area_struct *vma, struct vm_count *c)
+{
+	unsigned long address = vma->vm_start;
+	unsigned long end = vma->vm_end;
+	pgd_t * dir = pgd_offset(vma->vm_mm, address);
+
+	do {
+		count_pmd_range(dir, address, end, c);
+		address = (address + PGDIR_SIZE) & PGDIR_MASK;
+		dir++;
+	} while (address && address < end);
+}
+
+void count_vm(struct mm_struct *mm, struct vm_count *c)
+{
+	struct vm_area_struct *vma;
+
+	memset(c, 0,sizeof(struct vm_count));
+
+	for(vma = mm->mmap; vma; vma = vma->vm_next)
+		if (is_vm_hugetlb_page(vma)) {
+			printk(KERN_WARNING "hugetlb scans not supported.\n");
+		} else
+			count_vma(vma, c);
+}
+
+
Index: linux-2.6.9/fs/binfmt_som.c
===================================================================
--- linux-2.6.9.orig/fs/binfmt_som.c	2004-10-18 14:53:51.000000000 -0700
+++ linux-2.6.9/fs/binfmt_som.c	2004-11-05 18:19:54.000000000 -0800
@@ -259,7 +259,6 @@
 	create_som_tables(bprm);

 	current->mm->start_stack = bprm->p;
-	current->mm->rss = 0;

 #if 0
 	printk("(start_brk) %08lx\n" , (unsigned long) current->mm->start_brk);
Index: linux-2.6.9/mm/fremap.c
===================================================================
--- linux-2.6.9.orig/mm/fremap.c	2004-11-03 13:36:30.000000000 -0800
+++ linux-2.6.9/mm/fremap.c	2004-11-05 18:11:46.000000000 -0800
@@ -39,7 +39,6 @@
 					set_page_dirty(page);
 				page_remove_rmap(page);
 				page_cache_release(page);
-				mm->rss--;
 			}
 		}
 	} else {
@@ -87,7 +86,6 @@

 	zap_pte(mm, vma, addr, pte);

-	mm->rss++;
 	flush_icache_page(vma, page);
 	set_pte(pte, mk_pte(page, prot));
 	page_add_file_rmap(page);
Index: linux-2.6.9/mm/swapfile.c
===================================================================
--- linux-2.6.9.orig/mm/swapfile.c	2004-11-03 13:36:36.000000000 -0800
+++ linux-2.6.9/mm/swapfile.c	2004-11-05 18:13:56.000000000 -0800
@@ -431,7 +431,6 @@
 unuse_pte(struct vm_area_struct *vma, unsigned long address, pte_t *dir,
 	swp_entry_t entry, struct page *page)
 {
-	vma->vm_mm->rss++;
 	get_page(page);
 	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	page_add_anon_rmap(page, vma, address);
Index: linux-2.6.9/fs/binfmt_aout.c
===================================================================
--- linux-2.6.9.orig/fs/binfmt_aout.c	2004-11-03 13:36:29.000000000 -0800
+++ linux-2.6.9/fs/binfmt_aout.c	2004-11-05 18:19:16.000000000 -0800
@@ -309,7 +309,6 @@
 		(current->mm->start_brk = N_BSSADDR(ex));
 	current->mm->free_area_cache = current->mm->mmap_base;

-	current->mm->rss = 0;
 	current->mm->mmap = NULL;
 	compute_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
Index: linux-2.6.9/arch/ia64/mm/hugetlbpage.c
===================================================================
--- linux-2.6.9.orig/arch/ia64/mm/hugetlbpage.c	2004-10-18 14:54:27.000000000 -0700
+++ linux-2.6.9/arch/ia64/mm/hugetlbpage.c	2004-11-05 18:17:34.000000000 -0800
@@ -65,7 +65,6 @@
 {
 	pte_t entry;

-	mm->rss += (HPAGE_SIZE / PAGE_SIZE);
 	if (write_access) {
 		entry =
 		    pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
@@ -108,7 +107,6 @@
 		ptepage = pte_page(entry);
 		get_page(ptepage);
 		set_pte(dst_pte, entry);
-		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
 		addr += HPAGE_SIZE;
 	}
 	return 0;
@@ -249,7 +247,6 @@
 		put_page(page);
 		pte_clear(pte);
 	}
-	mm->rss -= (end - start) >> PAGE_SHIFT;
 	flush_tlb_range(vma, start, end);
 }

Index: linux-2.6.9/fs/proc/array.c
===================================================================
--- linux-2.6.9.orig/fs/proc/array.c	2004-11-03 13:36:29.000000000 -0800
+++ linux-2.6.9/fs/proc/array.c	2004-11-06 00:43:28.000000000 -0800
@@ -317,6 +317,7 @@
 	unsigned long rsslim = 0;
 	struct task_struct *t;
 	char tcomm[sizeof(task->comm)];
+	struct vm_count c;

 	state = *get_task_state(task);
 	vsize = eip = esp = 0;
@@ -394,6 +395,9 @@
 	/* convert nsec -> ticks */
 	start_time = nsec_to_clock_t(start_time);

+	if (mm)
+		count_vm(mm, &c);
+
 	res = sprintf(buffer,"%d (%s) %c %d %d %d %d %d %lu %lu \
 %lu %lu %lu %lu %lu %ld %ld %ld %ld %d %ld %llu %lu %ld %lu %lu %lu %lu %lu \
 %lu %lu %lu %lu %lu %lu %lu %lu %d %d %lu %lu\n",
@@ -420,7 +424,7 @@
 		jiffies_to_clock_t(task->it_real_value),
 		start_time,
 		vsize,
-		mm ? mm->rss : 0, /* you might want to shift this left 3 */
+		mm ? c.resident : 0, /* you might want to shift this left 3 */
 	        rsslim,
 		mm ? mm->start_code : 0,
 		mm ? mm->end_code : 0,
Index: linux-2.6.9/arch/i386/mm/hugetlbpage.c
===================================================================
--- linux-2.6.9.orig/arch/i386/mm/hugetlbpage.c	2004-11-03 13:36:31.000000000 -0800
+++ linux-2.6.9/arch/i386/mm/hugetlbpage.c	2004-11-05 18:18:05.000000000 -0800
@@ -42,7 +42,6 @@
 {
 	pte_t entry;

-	mm->rss += (HPAGE_SIZE / PAGE_SIZE);
 	if (write_access) {
 		entry =
 		    pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
@@ -82,7 +81,6 @@
 		ptepage = pte_page(entry);
 		get_page(ptepage);
 		set_pte(dst_pte, entry);
-		dst->rss += (HPAGE_SIZE / PAGE_SIZE);
 		addr += HPAGE_SIZE;
 	}
 	return 0;
@@ -218,7 +216,6 @@
 		page = pte_page(pte);
 		put_page(page);
 	}
-	mm->rss -= (end - start) >> PAGE_SHIFT;
 	flush_tlb_range(vma, start, end);
 }

Index: linux-2.6.9/fs/binfmt_elf.c
===================================================================
--- linux-2.6.9.orig/fs/binfmt_elf.c	2004-11-03 13:36:29.000000000 -0800
+++ linux-2.6.9/fs/binfmt_elf.c	2004-11-05 18:18:53.000000000 -0800
@@ -716,7 +716,6 @@

 	/* Do this so that we can load the interpreter, if need be.  We will
 	   change some of these later */
-	current->mm->rss = 0;
 	current->mm->free_area_cache = current->mm->mmap_base;
 	retval = setup_arg_pages(bprm, executable_stack);
 	if (retval < 0) {
Index: linux-2.6.9/include/asm-ia64/tlb.h
===================================================================
--- linux-2.6.9.orig/include/asm-ia64/tlb.h	2004-10-18 14:53:51.000000000 -0700
+++ linux-2.6.9/include/asm-ia64/tlb.h	2004-11-06 00:33:14.000000000 -0800
@@ -159,13 +159,6 @@
 static inline void
 tlb_finish_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	unsigned long freed = tlb->freed;
-	struct mm_struct *mm = tlb->mm;
-	unsigned long rss = mm->rss;
-
-	if (rss < freed)
-		freed = rss;
-	mm->rss = rss - freed;
 	/*
 	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
 	 * tlb->end_addr.
Index: linux-2.6.9/include/linux/mm.h
===================================================================
--- linux-2.6.9.orig/include/linux/mm.h	2004-11-03 13:36:35.000000000 -0800
+++ linux-2.6.9/include/linux/mm.h	2004-11-06 00:28:06.000000000 -0800
@@ -792,6 +792,22 @@
 							-vma_pages(vma));
 }

+/* Statistics on pages used in a vm */
+
+struct vm_count {
+	unsigned long shared;
+	unsigned long resident;
+	unsigned long swap;
+	unsigned long file;
+	unsigned long present;
+	unsigned long reserved;
+	unsigned long dirty;
+	unsigned long locked;
+	unsigned long young;
+};
+
+extern void count_vm(struct mm_struct *mm, struct vm_count *c);
+
 #ifndef CONFIG_DEBUG_PAGEALLOC
 static inline void
 kernel_map_pages(struct page *page, int numpages, int enable)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
