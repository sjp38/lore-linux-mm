Message-ID: <4196F16E.4060107@yahoo.com.au>
Date: Sun, 14 Nov 2004 16:47:26 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Possible alternate 4 level pagetables?
References: <4196F12D.20005@yahoo.com.au> <4196F151.50805@yahoo.com.au>
In-Reply-To: <4196F151.50805@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------050301020608040104000001"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050301020608040104000001
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

3/4 - core patch

--------------050301020608040104000001
Content-Type: text/x-patch;
 name="4level-core-patch.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-core-patch.patch"



Extend the Linux MM to 4level page tables. 

This is the core patch for mm/*, fs/*, include/linux/*  

It breaks all architectures, which will be fixed in separate patches.

The conversion is quite straight forward.  All the functions walking the page
table hierarchy have been changed to deal with another level at the top.  The
additional level is called pml4.  

mm/memory.c has changed a lot because it did most of the heavy lifting here. 
Most of the changes here are extensions of the previous code.  

One exception is copy_page_range() which I rewrote into the standard multiple
inlines style.  The previous single function goto heaven was not really
scalable to 4level.

pgd_offset() and pgd_offset_k() have been renamed to make sure all unconverted
code causes an compile error.  They are replaced with
pml4_offset()/pml4_offset_k() and pml4_pgd_offset()/pml4_pgd_offset_k() Please
note than when you use pml4_offset_k() you also have to use
pml4_pgd_offset_k() because IA64 requires a special case here.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/fs/exec.c                 |    6 
 25-akpm/include/linux/init_task.h |    2 
 25-akpm/include/linux/sched.h     |    2 
 25-akpm/kernel/fork.c             |    6 
 25-akpm/mm/fremap.c               |   11 



---

 linux-2.6-npiggin/fs/exec.c                 |    6 
 linux-2.6-npiggin/include/linux/init_task.h |    2 
 linux-2.6-npiggin/include/linux/mm.h        |   22 
 linux-2.6-npiggin/mm/fremap.c               |   18 
 linux-2.6-npiggin/mm/memory.c               |  687 ++++++++++++++++++----------
 linux-2.6-npiggin/mm/mempolicy.c            |   22 
 linux-2.6-npiggin/mm/mmap.c                 |   25 -
 linux-2.6-npiggin/mm/mprotect.c             |   65 +-
 linux-2.6-npiggin/mm/mremap.c               |   29 -
 linux-2.6-npiggin/mm/msync.c                |   55 +-
 linux-2.6-npiggin/mm/rmap.c                 |   21 
 linux-2.6-npiggin/mm/swapfile.c             |   81 ++-
 linux-2.6-npiggin/mm/vmalloc.c              |  113 +++-
 13 files changed, 794 insertions(+), 352 deletions(-)

diff -puN fs/exec.c~4level-core-patch fs/exec.c
--- linux-2.6/fs/exec.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/fs/exec.c	2004-11-14 12:33:54.000000000 +1100
@@ -300,6 +300,7 @@ void install_arg_page(struct vm_area_str
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t * pgd;
+	pud_t * pud;
 	pmd_t * pmd;
 	pte_t * pte;
 
@@ -310,7 +311,10 @@ void install_arg_page(struct vm_area_str
 	pgd = pgd_offset(mm, address);
 
 	spin_lock(&mm->page_table_lock);
-	pmd = pmd_alloc(mm, pgd, address);
+	pud = pud_alloc(mm, pgd, address);
+	if (!pud)
+		goto out;
+	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		goto out;
 	pte = pte_alloc_map(mm, pmd, address);
diff -puN include/linux/init_task.h~4level-core-patch include/linux/init_task.h
--- linux-2.6/include/linux/init_task.h~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/include/linux/init_task.h	2004-11-14 12:33:54.000000000 +1100
@@ -34,7 +34,7 @@
 #define INIT_MM(name) \
 {			 					\
 	.mm_rb		= RB_ROOT,				\
-	.pgd		= swapper_pg_dir, 			\
+	.pgd		= swapper_pg_dir,			\
 	.mm_users	= ATOMIC_INIT(2), 			\
 	.mm_count	= ATOMIC_INIT(1), 			\
 	.mmap_sem	= __RWSEM_INITIALIZER(name.mmap_sem),	\
diff -puN include/linux/mm.h~4level-core-patch include/linux/mm.h
--- linux-2.6/include/linux/mm.h~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/include/linux/mm.h	2004-11-14 15:04:02.000000000 +1100
@@ -566,7 +566,7 @@ int unmap_vmas(struct mmu_gather **tlbp,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
-void clear_page_tables(struct mmu_gather *tlb, unsigned long first, int nr);
+void clear_page_range(struct mmu_gather *tlb, unsigned long addr, unsigned long end);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 int zeromap_page_range(struct vm_area_struct *vma, unsigned long from,
@@ -581,7 +581,8 @@ static inline void unmap_shared_mapping_
 }
 
 extern int vmtruncate(struct inode * inode, loff_t offset);
-extern pmd_t *FASTCALL(__pmd_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address));
+extern pud_t *FASTCALL(__pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address));
+extern pmd_t *FASTCALL(__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address));
 extern pte_t *FASTCALL(pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
 extern pte_t *FASTCALL(pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
 extern int install_page(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, struct page *page, pgprot_t prot);
@@ -626,15 +627,22 @@ extern struct shrinker *set_shrinker(int
 extern void remove_shrinker(struct shrinker *shrinker);
 
 /*
- * On a two-level page table, this ends up being trivial. Thus the
- * inlining and the symmetry break with pte_alloc_map() that does all
+ * On a two-level or three-level page table, this ends up being trivial. Thus
+ * the inlining and the symmetry break with pte_alloc_map() that does all
  * of this out-of-line.
  */
-static inline pmd_t *pmd_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 {
 	if (pgd_none(*pgd))
-		return __pmd_alloc(mm, pgd, address);
-	return pmd_offset(pgd, address);
+		return __pud_alloc(mm, pgd, address);
+	return pud_offset(pgd, address);
+}
+
+static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+{
+	if (pud_none(*pud))
+		return __pmd_alloc(mm, pud, address);
+	return pmd_offset(pud, address);
 }
 
 extern void free_area_init(unsigned long * zones_size);
diff -puN include/linux/sched.h~4level-core-patch include/linux/sched.h
diff -puN kernel/fork.c~4level-core-patch kernel/fork.c
diff -puN mm/fremap.c~4level-core-patch mm/fremap.c
--- linux-2.6/mm/fremap.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/fremap.c	2004-11-14 12:33:54.000000000 +1100
@@ -60,14 +60,19 @@ int install_page(struct mm_struct *mm, s
 	pgoff_t size;
 	int err = -ENOMEM;
 	pte_t *pte;
-	pgd_t *pgd;
 	pmd_t *pmd;
+	pud_t *pud;
+	pgd_t *pgd;
 	pte_t pte_val;
 
 	pgd = pgd_offset(mm, addr);
 	spin_lock(&mm->page_table_lock);
+	
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+	    goto err_unlock;
 
-	pmd = pmd_alloc(mm, pgd, addr);
+	pmd = pmd_alloc(mm, pud, addr);
 	if (!pmd)
 		goto err_unlock;
 
@@ -112,14 +117,19 @@ int install_file_pte(struct mm_struct *m
 {
 	int err = -ENOMEM;
 	pte_t *pte;
-	pgd_t *pgd;
 	pmd_t *pmd;
+	pud_t *pud;
+	pgd_t *pgd;
 	pte_t pte_val;
 
 	pgd = pgd_offset(mm, addr);
 	spin_lock(&mm->page_table_lock);
+	
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		goto err_unlock;
 
-	pmd = pmd_alloc(mm, pgd, addr);
+	pmd = pmd_alloc(mm, pud, addr);
 	if (!pmd)
 		goto err_unlock;
 
diff -puN mm/memory.c~4level-core-patch mm/memory.c
--- linux-2.6/mm/memory.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/memory.c	2004-11-14 16:32:50.000000000 +1100
@@ -34,6 +34,8 @@
  *
  * 16.07.99  -  Support of BIGMEM added by Gerhard Wichert, Siemens AG
  *		(Gerhard.Wichert@pdb.siemens.de)
+ *
+ * Aug/Sep 2004 Changed to four level page tables (Andi Kleen)
  */
 
 #include <linux/kernel_stat.h>
@@ -118,10 +120,30 @@ static inline void free_one_pmd(struct m
 	pte_free_tlb(tlb, page);
 }
 
+static inline void free_one_pud(struct mmu_gather *tlb, pud_t * dir)
+{
+	int j;
+	pmd_t *pmd;
+
+	if (pud_none(*dir))
+		return;
+	if (unlikely(pud_bad(*dir))) {
+		pud_ERROR(*dir);
+		pud_clear(dir);
+		return;
+	}
+	pmd = pmd_offset(dir, 0);
+	pud_clear(dir);
+	for (j = 0; j < PTRS_PER_PMD ; j++)
+		free_one_pmd(tlb, pmd+j);
+	pmd_free_tlb(tlb, pmd);
+}
+
+
 static inline void free_one_pgd(struct mmu_gather *tlb, pgd_t * dir)
 {
 	int j;
-	pmd_t * pmd;
+	pud_t * pud;
 
 	if (pgd_none(*dir))
 		return;
@@ -130,28 +152,31 @@ static inline void free_one_pgd(struct m
 		pgd_clear(dir);
 		return;
 	}
-	pmd = pmd_offset(dir, 0);
+	pud = pud_offset(dir, 0);
 	pgd_clear(dir);
-	for (j = 0; j < PTRS_PER_PMD ; j++)
-		free_one_pmd(tlb, pmd+j);
-	pmd_free_tlb(tlb, pmd);
+	for (j = 0; j < PTRS_PER_PUD ; j++)
+		free_one_pud(tlb, pud+j);
+	pud_free_tlb(tlb, pud);
 }
 
 /*
- * This function clears all user-level page tables of a process - this
- * is needed by execve(), so that old pages aren't in the way.
+ * This function clears user-level page tables of a process.
  *
  * Must be called with pagetable lock held.
+ *
+ * This function is not exact and may clear less than the range if
+ * addr and end are not suitably aligned.
  */
-void clear_page_tables(struct mmu_gather *tlb, unsigned long first, int nr)
+void clear_page_range(struct mmu_gather *tlb, unsigned long addr, unsigned long end)
 {
 	pgd_t * page_dir = tlb->mm->pgd;
 
-	page_dir += first;
+	page_dir += addr;
 	do {
 		free_one_pgd(tlb, page_dir);
 		page_dir++;
-	} while (--nr);
+		addr = (addr + PGDIR_SIZE) & PGDIR_MASK;
+	} while (addr && (addr < end));
 }
 
 pte_t fastcall * pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
@@ -204,165 +229,210 @@ pte_t fastcall * pte_alloc_kernel(struct
 out:
 	return pte_offset_kernel(pmd, address);
 }
-#define PTE_TABLE_MASK	((PTRS_PER_PTE-1) * sizeof(pte_t))
-#define PMD_TABLE_MASK	((PTRS_PER_PMD-1) * sizeof(pmd_t))
 
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
  * covered by this vma.
  *
- * 08Jan98 Merged into one routine from several inline routines to reduce
- *         variable count and make things faster. -jj
- *
  * dst->page_table_lock is held on entry and exit,
- * but may be dropped within pmd_alloc() and pte_alloc_map().
+ * but may be dropped within p[mg]d_alloc() and pte_alloc_map().
  */
-int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
-			struct vm_area_struct *vma)
+
+static inline void
+copy_swap_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm, pte_t pte)
 {
-	pgd_t * src_pgd, * dst_pgd;
-	unsigned long address = vma->vm_start;
-	unsigned long end = vma->vm_end;
-	unsigned long cow;
+	if (pte_file(pte))
+		return;
+	swap_duplicate(pte_to_swp_entry(pte));
+	if (list_empty(&dst_mm->mmlist)) {
+		spin_lock(&mmlist_lock);
+		list_add(&dst_mm->mmlist, &src_mm->mmlist);
+		spin_unlock(&mmlist_lock);
+	}
+}
 
-	if (is_vm_hugetlb_page(vma))
-		return copy_hugetlb_page_range(dst, src, vma);
+static inline void
+copy_one_pte(struct mm_struct *dst_mm,  struct mm_struct *src_mm,
+		pte_t *dst_pte, pte_t *src_pte, unsigned long vm_flags,
+		unsigned long addr)
+{
+	pte_t pte = *src_pte;
+	struct page *page;
+	unsigned long pfn;
 
-	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
-	src_pgd = pgd_offset(src, address)-1;
-	dst_pgd = pgd_offset(dst, address)-1;
+	/* pte contains position in swap, so copy. */
+	if (!pte_present(pte)) {
+		copy_swap_pte(dst_mm, src_mm, pte);
+		set_pte(dst_pte, pte);
+		return;
+	}
+	pfn = pte_pfn(pte);
+	/* the pte points outside of valid memory, the
+	 * mapping is assumed to be good, meaningful
+	 * and not mapped via rmap - duplicate the
+	 * mapping as is.
+	 */
+	page = NULL;
+	if (pfn_valid(pfn))
+		page = pfn_to_page(pfn);
 
-	for (;;) {
-		pmd_t * src_pmd, * dst_pmd;
+	if (!page || PageReserved(page)) {
+		set_pte(dst_pte, pte);
+		return;
+	}
 
-		src_pgd++; dst_pgd++;
-		
-		/* copy_pmd_range */
-		
-		if (pgd_none(*src_pgd))
-			goto skip_copy_pmd_range;
-		if (unlikely(pgd_bad(*src_pgd))) {
-			pgd_ERROR(*src_pgd);
-			pgd_clear(src_pgd);
-skip_copy_pmd_range:	address = (address + PGDIR_SIZE) & PGDIR_MASK;
-			if (!address || (address >= end))
-				goto out;
+	/*
+	 * If it's a COW mapping, write protect it both
+	 * in the parent and the child
+	 */
+	if ((vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE) {
+		ptep_set_wrprotect(src_pte);
+		pte = *src_pte;
+	}
+
+	/*
+	 * If it's a shared mapping, mark it clean in
+	 * the child
+	 */
+	if (vm_flags & VM_SHARED)
+		pte = pte_mkclean(pte);
+	pte = pte_mkold(pte);
+	get_page(page);
+	dst_mm->rss++;
+	if (PageAnon(page))
+		dst_mm->anon_rss++;
+	set_pte(dst_pte, pte);
+	page_dup_rmap(page);
+}
+
+static int copy_pte_range(struct mm_struct *dst_mm,  struct mm_struct *src_mm,
+		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	pte_t *src_pte, *dst_pte;
+	pte_t *s, *d;
+	unsigned long vm_flags = vma->vm_flags;
+
+	d = dst_pte = pte_alloc_map(dst_mm, dst_pmd, addr);
+	if (!dst_pte)
+		return -ENOMEM;
+
+	spin_lock(&src_mm->page_table_lock);
+	s = src_pte = pte_offset_map_nested(src_pmd, addr);
+	for (; addr < end; addr += PAGE_SIZE, s++, d++) {
+		if (pte_none(*s))
 			continue;
-		}
+		copy_one_pte(dst_mm, src_mm, d, s, vm_flags, addr);
+	}
+	pte_unmap_nested(src_pte);
+	pte_unmap(dst_pte);
+	spin_unlock(&src_mm->page_table_lock);
+	cond_resched_lock(&dst_mm->page_table_lock);
+	return 0;
+}
 
-		src_pmd = pmd_offset(src_pgd, address);
-		dst_pmd = pmd_alloc(dst, dst_pgd, address);
-		if (!dst_pmd)
-			goto nomem;
+static int copy_pmd_range(struct mm_struct *dst_mm,  struct mm_struct *src_mm,
+		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	pmd_t *src_pmd, *dst_pmd;
+	int err = 0;
+	unsigned long next;
+
+	src_pmd = pmd_offset(src_pud, addr);
+	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr);
+	if (!dst_pmd)
+		return -ENOMEM;
+
+	for (; addr < end; addr = next, src_pmd++, dst_pmd++) {
+		next = (addr + PMD_SIZE) & PMD_MASK;
+		if (next > end)
+			next = end;
+		if (pmd_none(*src_pmd))
+			continue;
+		if (pmd_bad(*src_pmd)) {
+			pmd_ERROR(*src_pmd);
+			pmd_clear(src_pmd);
+			continue;
+		}
+		err = copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
+							vma, addr, next);
+		if (err)
+			break;
+	}
+	return err;
+}
 
-		do {
-			pte_t * src_pte, * dst_pte;
-		
-			/* copy_pte_range */
-		
-			if (pmd_none(*src_pmd))
-				goto skip_copy_pte_range;
-			if (unlikely(pmd_bad(*src_pmd))) {
-				pmd_ERROR(*src_pmd);
-				pmd_clear(src_pmd);
-skip_copy_pte_range:
-				address = (address + PMD_SIZE) & PMD_MASK;
-				if (address >= end)
-					goto out;
-				goto cont_copy_pmd_range;
-			}
+static int copy_pud_range(struct mm_struct *dst_mm,  struct mm_struct *src_mm,
+		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end)
+{
+	pud_t *src_pud, *dst_pud;
+	int err = 0;
+	unsigned long next;
+
+	src_pud = pud_offset(src_pgd, addr);
+	dst_pud = pud_alloc(dst_mm, dst_pgd, addr);
+	if (!dst_pud)
+		return -ENOMEM;
+
+	for (; addr < end; addr = next, src_pud++, dst_pud++) {
+		next = (addr + PUD_SIZE) & PUD_MASK;
+		if (next > end)
+			next = end;
+		if (pud_none(*src_pud))
+			continue;
+		if (pud_bad(*src_pud)) {
+			pud_ERROR(*src_pud);
+			pud_clear(src_pud);
+			continue;
+		}
+		err = copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
+							vma, addr, next);
+		if (err)
+			break;
+	}
+	return err;
+}
 
-			dst_pte = pte_alloc_map(dst, dst_pmd, address);
-			if (!dst_pte)
-				goto nomem;
-			spin_lock(&src->page_table_lock);	
-			src_pte = pte_offset_map_nested(src_pmd, address);
-			do {
-				pte_t pte = *src_pte;
-				struct page *page;
-				unsigned long pfn;
-
-				/* copy_one_pte */
-
-				if (pte_none(pte))
-					goto cont_copy_pte_range_noset;
-				/* pte contains position in swap, so copy. */
-				if (!pte_present(pte)) {
-					if (!pte_file(pte)) {
-						swap_duplicate(pte_to_swp_entry(pte));
-						if (list_empty(&dst->mmlist)) {
-							spin_lock(&mmlist_lock);
-							list_add(&dst->mmlist,
-								 &src->mmlist);
-							spin_unlock(&mmlist_lock);
-						}
-					}
-					set_pte(dst_pte, pte);
-					goto cont_copy_pte_range_noset;
-				}
-				pfn = pte_pfn(pte);
-				/* the pte points outside of valid memory, the
-				 * mapping is assumed to be good, meaningful
-				 * and not mapped via rmap - duplicate the
-				 * mapping as is.
-				 */
-				page = NULL;
-				if (pfn_valid(pfn)) 
-					page = pfn_to_page(pfn); 
-
-				if (!page || PageReserved(page)) {
-					set_pte(dst_pte, pte);
-					goto cont_copy_pte_range_noset;
-				}
+int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
+		struct vm_area_struct *vma)
+{
+	pgd_t *src_pgd, *dst_pgd;
+	unsigned long addr, start, end, next;
+	int err = 0;
+	int i;
 
-				/*
-				 * If it's a COW mapping, write protect it both
-				 * in the parent and the child
-				 */
-				if (cow) {
-					ptep_set_wrprotect(src_pte);
-					pte = *src_pte;
-				}
+	if (is_vm_hugetlb_page(vma))
+		return copy_hugetlb_page_range(dst, src, vma);
 
-				/*
-				 * If it's a shared mapping, mark it clean in
-				 * the child
-				 */
-				if (vma->vm_flags & VM_SHARED)
-					pte = pte_mkclean(pte);
-				pte = pte_mkold(pte);
-				get_page(page);
-				dst->rss++;
-				if (PageAnon(page))
-					dst->anon_rss++;
-				set_pte(dst_pte, pte);
-				page_dup_rmap(page);
-cont_copy_pte_range_noset:
-				address += PAGE_SIZE;
-				if (address >= end) {
-					pte_unmap_nested(src_pte);
-					pte_unmap(dst_pte);
-					goto out_unlock;
-				}
-				src_pte++;
-				dst_pte++;
-			} while ((unsigned long)src_pte & PTE_TABLE_MASK);
-			pte_unmap_nested(src_pte-1);
-			pte_unmap(dst_pte-1);
-			spin_unlock(&src->page_table_lock);
-			cond_resched_lock(&dst->page_table_lock);
-cont_copy_pmd_range:
-			src_pmd++;
-			dst_pmd++;
-		} while ((unsigned long)src_pmd & PMD_TABLE_MASK);
+	start = vma->vm_start;
+	src_pgd = pgd_offset(src, start);
+	dst_pgd = pgd_offset(dst, start);
+
+	end = vma->vm_end;
+	addr = start;
+	for (i = pgd_index(addr);
+	     i <= pgd_index(end-1);
+	     i++, addr = next, src_pgd++, dst_pgd++) {
+		next = (addr + PGDIR_SIZE) & PGDIR_MASK;
+		if (next > end || next <= addr)
+			next = end;
+		if (pgd_none(*src_pgd))
+			continue;
+		if (pgd_bad(*src_pgd)) {
+			pgd_ERROR(*src_pgd);
+			pgd_clear(src_pgd);
+			continue;
+		}
+		err = copy_pud_range(dst, src, dst_pgd, src_pgd,
+							vma, addr, next);
+		if (err)
+			break;
 	}
-out_unlock:
-	spin_unlock(&src->page_table_lock);
-out:
-	return 0;
-nomem:
-	return -ENOMEM;
+
+	return err;
 }
 
 static void zap_pte_range(struct mmu_gather *tlb,
@@ -449,23 +519,23 @@ static void zap_pte_range(struct mmu_gat
 }
 
 static void zap_pmd_range(struct mmu_gather *tlb,
-		pgd_t * dir, unsigned long address,
+		pud_t *pud, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
 	pmd_t * pmd;
 	unsigned long end;
 
-	if (pgd_none(*dir))
+	if (pud_none(*pud))
 		return;
-	if (unlikely(pgd_bad(*dir))) {
-		pgd_ERROR(*dir);
-		pgd_clear(dir);
+	if (unlikely(pud_bad(*pud))) {
+		pud_ERROR(*pud);
+		pud_clear(pud);
 		return;
 	}
-	pmd = pmd_offset(dir, address);
+	pmd = pmd_offset(pud, address);
 	end = address + size;
-	if (end > ((address + PGDIR_SIZE) & PGDIR_MASK))
-		end = ((address + PGDIR_SIZE) & PGDIR_MASK);
+	if (end > ((address + PUD_SIZE) & PUD_MASK))
+		end = ((address + PUD_SIZE) & PUD_MASK);
 	do {
 		zap_pte_range(tlb, pmd, address, end - address, details);
 		address = (address + PMD_SIZE) & PMD_MASK; 
@@ -473,20 +543,46 @@ static void zap_pmd_range(struct mmu_gat
 	} while (address && (address < end));
 }
 
+static void zap_pud_range(struct mmu_gather *tlb,
+		pgd_t * pgd, unsigned long address,
+		unsigned long end, struct zap_details *details)
+{
+	pud_t * pud;
+
+	if (pgd_none(*pgd))
+		return;
+	if (unlikely(pgd_bad(*pgd))) {
+		pgd_ERROR(*pgd);
+		pgd_clear(pgd);
+		return;
+	}
+	pud = pud_offset(pgd, address);
+	do {
+		zap_pmd_range(tlb, pud, address, end - address, details);
+		address = (address + PUD_SIZE) & PUD_MASK; 
+		pud++;
+	} while (address && (address < end));
+}
+
 static void unmap_page_range(struct mmu_gather *tlb,
 		struct vm_area_struct *vma, unsigned long address,
 		unsigned long end, struct zap_details *details)
 {
-	pgd_t * dir;
+	unsigned long next;
+	pgd_t *pgd;
+	int i;
 
 	BUG_ON(address >= end);
-	dir = pgd_offset(vma->vm_mm, address);
+	pgd = pgd_offset(vma->vm_mm, address);
 	tlb_start_vma(tlb, vma);
-	do {
-		zap_pmd_range(tlb, dir, address, end - address, details);
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
+	for (i = pgd_index(address); i <= pgd_index(end-1); i++) {
+		next = (address + PGDIR_SIZE) & PGDIR_MASK;
+		if (next <= address || next > end)
+			next = end;
+		zap_pud_range(tlb, pgd, address, next, details);
+		address = next;
+		pgd++;
+	}
 	tlb_end_vma(tlb, vma);
 }
 
@@ -628,6 +724,7 @@ struct page *
 follow_page(struct mm_struct *mm, unsigned long address, int write) 
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *ptep, pte;
 	unsigned long pfn;
@@ -641,13 +738,15 @@ follow_page(struct mm_struct *mm, unsign
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
 		goto out;
 
-	pmd = pmd_offset(pgd, address);
-	if (pmd_none(*pmd))
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
+		goto out;
+	
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
 	if (pmd_huge(*pmd))
 		return follow_huge_pmd(mm, address, pmd, write);
-	if (unlikely(pmd_bad(*pmd)))
-		goto out;
 
 	ptep = pte_offset_map(pmd, address);
 	if (!ptep)
@@ -691,6 +790,7 @@ untouched_anonymous_page(struct mm_struc
 			 unsigned long address)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 
 	/* Check if the vma is for an anonymous mapping. */
@@ -702,8 +802,12 @@ untouched_anonymous_page(struct mm_struc
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
 		return 1;
 
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
+		return 1;
+
 	/* Check if page middle directory entry exists. */
-	pmd = pmd_offset(pgd, address);
+	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		return 1;
 
@@ -735,19 +839,21 @@ int get_user_pages(struct task_struct *t
 			unsigned long pg = start & PAGE_MASK;
 			struct vm_area_struct *gate_vma = get_gate_vma(tsk);
 			pgd_t *pgd;
+			pud_t *pud;
 			pmd_t *pmd;
 			pte_t *pte;
 			if (write) /* user gate pages are read-only */
 				return i ? : -EFAULT;
 			pgd = pgd_offset_gate(mm, pg);
-			if (!pgd)
+			if (pgd_none(*pgd))
 				return i ? : -EFAULT;
-			pmd = pmd_offset(pgd, pg);
-			if (!pmd)
+			pud = pud_offset(pgd, pg);
+			if (pud_none(*pud))
 				return i ? : -EFAULT;
-			pte = pte_offset_map(pmd, pg);
-			if (!pte)
+			pmd = pmd_offset(pud, pg);
+			if (pmd_none(*pmd))
 				return i ? : -EFAULT;
+			pte = pte_offset_map(pmd, pg);
 			if (!pte_present(*pte)) {
 				pte_unmap(pte);
 				return i ? : -EFAULT;
@@ -861,16 +967,16 @@ static void zeromap_pte_range(pte_t * pt
 	} while (address && (address < end));
 }
 
-static inline int zeromap_pmd_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address,
-                                    unsigned long size, pgprot_t prot)
+static inline int zeromap_pmd_range(struct mm_struct *mm, pmd_t * pmd,
+		unsigned long address, unsigned long size, pgprot_t prot)
 {
 	unsigned long base, end;
 
-	base = address & PGDIR_MASK;
-	address &= ~PGDIR_MASK;
+	base = address & PUD_MASK;
+	address &= ~PUD_MASK;
 	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
+	if (end > PUD_SIZE)
+		end = PUD_SIZE;
 	do {
 		pte_t * pte = pte_alloc_map(mm, pmd, base + address);
 		if (!pte)
@@ -883,31 +989,64 @@ static inline int zeromap_pmd_range(stru
 	return 0;
 }
 
-int zeromap_page_range(struct vm_area_struct *vma, unsigned long address, unsigned long size, pgprot_t prot)
+static inline int zeromap_pud_range(struct mm_struct *mm, pud_t * pud,
+				    unsigned long address,
+                                    unsigned long size, pgprot_t prot)
 {
+	unsigned long base, end;
 	int error = 0;
-	pgd_t * dir;
+
+	base = address & PGDIR_MASK;
+	address &= ~PGDIR_MASK;
+	end = address + size;
+	if (end > PGDIR_SIZE)
+		end = PGDIR_SIZE;
+	do {
+		pmd_t * pmd = pmd_alloc(mm, pud, base + address);
+		error = -ENOMEM;
+		if (!pmd)
+			break;
+		error = zeromap_pmd_range(mm, pmd, address, end - address, prot);
+		if (error)
+			break;
+		address = (address + PUD_SIZE) & PUD_MASK;
+		pud++;
+	} while (address && (address < end));
+	return 0;
+}
+
+int zeromap_page_range(struct vm_area_struct *vma, unsigned long address,
+					unsigned long size, pgprot_t prot)
+{
+	int i;
+	int error = 0;
+	pgd_t * pgd;
 	unsigned long beg = address;
 	unsigned long end = address + size;
+	unsigned long next;
 	struct mm_struct *mm = vma->vm_mm;
 
-	dir = pgd_offset(mm, address);
+	pgd = pgd_offset(mm, address);
 	flush_cache_range(vma, beg, end);
-	if (address >= end)
-		BUG();
+	BUG_ON(address >= end);
+	BUG_ON(end > vma->vm_end);
 
 	spin_lock(&mm->page_table_lock);
-	do {
-		pmd_t *pmd = pmd_alloc(mm, dir, address);
+	for (i = pgd_index(address); i <= pgd_index(end-1); i++) {
+		pud_t *pud = pud_alloc(mm, pgd, address);
 		error = -ENOMEM;
-		if (!pmd)
+		if (!pud)
 			break;
-		error = zeromap_pmd_range(mm, pmd, address, end - address, prot);
+		next = (address + PGDIR_SIZE) & PGDIR_MASK;
+		if (next <= beg || next > end)
+			next = end;
+		error = zeromap_pud_range(mm, pud, address,
+						next - address, prot);
 		if (error)
 			break;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
+		address = next;
+		pgd++;
+	}
 	/*
 	 * Why flush? zeromap_pte_range has a BUG_ON for !pte_none()
 	 */
@@ -921,8 +1060,9 @@ int zeromap_page_range(struct vm_area_st
  * mappings are removed. any references to nonexistent pages results
  * in null mappings (currently treated as "copy-on-access")
  */
-static inline void remap_pte_range(pte_t * pte, unsigned long address, unsigned long size,
-	unsigned long pfn, pgprot_t prot)
+static inline void
+remap_pte_range(pte_t * pte, unsigned long address, unsigned long size,
+		unsigned long pfn, pgprot_t prot)
 {
 	unsigned long end;
 
@@ -940,22 +1080,24 @@ static inline void remap_pte_range(pte_t
 	} while (address && (address < end));
 }
 
-static inline int remap_pmd_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address, unsigned long size,
-	unsigned long pfn, pgprot_t prot)
+static inline int
+remap_pmd_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address,
+		unsigned long size, unsigned long pfn, pgprot_t prot)
 {
 	unsigned long base, end;
 
-	base = address & PGDIR_MASK;
-	address &= ~PGDIR_MASK;
+	base = address & PUD_MASK;
+	address &= ~PUD_MASK;
 	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-	pfn -= address >> PAGE_SHIFT;
+	if (end > PUD_SIZE)
+		end = PUD_SIZE;
+	pfn -= (address >> PAGE_SHIFT);
 	do {
 		pte_t * pte = pte_alloc_map(mm, pmd, base + address);
 		if (!pte)
 			return -ENOMEM;
-		remap_pte_range(pte, base + address, end - address, pfn + (address >> PAGE_SHIFT), prot);
+		remap_pte_range(pte, base + address, end - address,
+				(address >> PAGE_SHIFT) + pfn, prot);
 		pte_unmap(pte);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
@@ -963,20 +1105,46 @@ static inline int remap_pmd_range(struct
 	return 0;
 }
 
+static inline int remap_pud_range(struct mm_struct *mm, pud_t * pud,
+				  unsigned long address, unsigned long size,
+				  unsigned long pfn, pgprot_t prot)
+{
+	unsigned long base, end;
+
+	base = address & PGDIR_MASK;
+	address &= ~PGDIR_MASK;
+	end = address + size;
+	if (end > PGDIR_SIZE)
+		end = PGDIR_SIZE;
+	pfn -= address >> PAGE_SHIFT;
+	do {
+		pmd_t *pmd = pmd_alloc(mm, pud, base+address);
+		if (!pmd)
+			return -ENOMEM;
+		remap_pmd_range(mm, pmd, base + address, end - address,
+				(address >> PAGE_SHIFT) + pfn, prot);
+		address = (address + PUD_SIZE) & PUD_MASK;
+		pud++;
+	} while (address && (address < end));
+	return 0;
+}
+
 /*  Note: this is only safe if the mm semaphore is held when called. */
-int remap_pfn_range(struct vm_area_struct *vma, unsigned long from, unsigned long pfn, unsigned long size, pgprot_t prot)
+int remap_pfn_range(struct vm_area_struct *vma, unsigned long from,
+		    unsigned long pfn, unsigned long size, pgprot_t prot)
 {
 	int error = 0;
-	pgd_t * dir;
+	pgd_t *pgd;
 	unsigned long beg = from;
 	unsigned long end = from + size;
+	unsigned long next;
 	struct mm_struct *mm = vma->vm_mm;
+	int i;
 
 	pfn -= from >> PAGE_SHIFT;
-	dir = pgd_offset(mm, from);
+	pgd = pgd_offset(mm, from);
 	flush_cache_range(vma, beg, end);
-	if (from >= end)
-		BUG();
+	BUG_ON(from >= end);
 
 	/*
 	 * Physically remapped pages are special. Tell the
@@ -987,25 +1155,32 @@ int remap_pfn_range(struct vm_area_struc
 	 *	this region.
 	 */
 	vma->vm_flags |= VM_IO | VM_RESERVED;
+
 	spin_lock(&mm->page_table_lock);
-	do {
-		pmd_t *pmd = pmd_alloc(mm, dir, from);
+	for (i = pgd_index(beg); i <= pgd_index(end-1); i++) {
+		pud_t *pud = pud_alloc(mm, pgd, from);
 		error = -ENOMEM;
-		if (!pmd)
+		if (!pgd)
 			break;
-		error = remap_pmd_range(mm, pmd, from, end - from, pfn + (from >> PAGE_SHIFT), prot);
+		next = (from + PGDIR_SIZE) & PGDIR_MASK;
+		if (next > end || next <= from)
+			next = end;
+		error = remap_pud_range(mm, pud, from, end - from,
+					pfn + (from >> PAGE_SHIFT), prot);
 		if (error)
 			break;
-		from = (from + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (from && (from < end));
+		from = next;
+		pgd++;
+	}
 	/*
 	 * Why flush? remap_pte_range has a BUG_ON for !pte_none()
 	 */
 	flush_tlb_range(vma, beg, end);
 	spin_unlock(&mm->page_table_lock);
+
 	return error;
 }
+
 EXPORT_SYMBOL(remap_pfn_range);
 
 /*
@@ -1697,13 +1872,14 @@ static inline int handle_pte_fault(struc
  * By the time we get here, we already hold the mm semaphore
  */
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct * vma,
-	unsigned long address, int write_access)
+		unsigned long address, int write_access)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
+	pte_t *pte;
 
 	__set_current_state(TASK_RUNNING);
-	pgd = pgd_offset(mm, address);
 
 	inc_page_state(pgfault);
 
@@ -1714,19 +1890,62 @@ int handle_mm_fault(struct mm_struct *mm
 	 * We need the page table lock to synchronize with kswapd
 	 * and the SMP-safe atomic PTE updates.
 	 */
+	pgd = pgd_offset(mm, address);
 	spin_lock(&mm->page_table_lock);
-	pmd = pmd_alloc(mm, pgd, address);
 
-	if (pmd) {
-		pte_t * pte = pte_alloc_map(mm, pmd, address);
-		if (pte)
-			return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
-	}
+	pud = pud_alloc(mm, pgd, address);
+	if (!pud)
+		goto oom;
+
+	pmd = pmd_alloc(mm, pud, address);
+	if (!pmd)
+		goto oom;
+
+	pte = pte_alloc_map(mm, pmd, address);
+	if (!pte)
+		goto oom;
+	
+	return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
+
+ oom:
 	spin_unlock(&mm->page_table_lock);
 	return VM_FAULT_OOM;
 }
 
 /*
+ * Allocate page upper directory.
+ *
+ * We've already handled the fast-path in-line, and we own the
+ * page table lock.
+ *
+ * On a two-level or three-level page table, this ends up actually being
+ * entirely optimized away.
+ */
+pud_t fastcall *__pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+{
+	pud_t *new;
+
+	spin_unlock(&mm->page_table_lock);
+	new = pud_alloc_one(mm, address);
+	spin_lock(&mm->page_table_lock);
+	if (!new)
+		return NULL;
+
+	/*
+	 * Because we dropped the lock, we should re-check the
+	 * entry, as somebody else could have populated it..
+	 */
+	if (pgd_present(*pgd)) {
+		pud_free(new);
+		goto out;
+	}
+	pgd_populate(mm, pgd, new);
+out:
+	return pud_offset(pgd, address);
+}
+
+
+/*
  * Allocate page middle directory.
  *
  * We've already handled the fast-path in-line, and we own the
@@ -1735,7 +1954,7 @@ int handle_mm_fault(struct mm_struct *mm
  * On a two-level page table, this ends up actually being entirely
  * optimized away.
  */
-pmd_t fastcall *__pmd_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+pmd_t fastcall *__pmd_alloc(struct mm_struct *mm, pud_t *pgd, unsigned long address)
 {
 	pmd_t *new;
 
@@ -1749,11 +1968,11 @@ pmd_t fastcall *__pmd_alloc(struct mm_st
 	 * Because we dropped the lock, we should re-check the
 	 * entry, as somebody else could have populated it..
 	 */
-	if (pgd_present(*pgd)) {
+	if (pud_present(*pud)) {
 		pmd_free(new);
 		goto out;
 	}
-	pgd_populate(mm, pgd, new);
+	pud_populate(mm, pud, new);
 out:
 	return pmd_offset(pgd, address);
 }
@@ -1787,17 +2006,21 @@ struct page * vmalloc_to_page(void * vma
 	unsigned long addr = (unsigned long) vmalloc_addr;
 	struct page *page = NULL;
 	pgd_t *pgd = pgd_offset_k(addr);
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *ptep, pte;
   
 	if (!pgd_none(*pgd)) {
-		pmd = pmd_offset(pgd, addr);
-		if (!pmd_none(*pmd)) {
-			ptep = pte_offset_map(pmd, addr);
-			pte = *ptep;
-			if (pte_present(pte))
-				page = pte_page(pte);
-			pte_unmap(ptep);
+		pud = pud_offset_k(pgd, addr);
+		if (!pud_none(*pud)) {
+			pmd = pmd_offset(pud, addr);
+			if (!pmd_none(*pmd)) {
+				ptep = pte_offset_map(pmd, addr);
+				pte = *ptep;
+				if (pte_present(pte))
+					page = pte_page(pte);
+				pte_unmap(ptep);
+			}
 		}
 	}
 	return page;
diff -puN mm/mempolicy.c~4level-core-patch mm/mempolicy.c
--- linux-2.6/mm/mempolicy.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/mempolicy.c	2004-11-14 12:33:54.000000000 +1100
@@ -233,18 +233,29 @@ static struct mempolicy *mpol_new(int mo
 
 /* Ensure all existing pages follow the policy. */
 static int
-verify_pages(unsigned long addr, unsigned long end, unsigned long *nodes)
+verify_pages(struct mm_struct *mm,
+	     unsigned long addr, unsigned long end, unsigned long *nodes)
 {
 	while (addr < end) {
 		struct page *p;
 		pte_t *pte;
 		pmd_t *pmd;
-		pgd_t *pgd = pgd_offset_k(addr);
+		pud_t *pud;
+		pgd_t *pgd;
+		pgd = pgd_offset(mm, addr);
 		if (pgd_none(*pgd)) {
-			addr = (addr + PGDIR_SIZE) & PGDIR_MASK;
+			unsigned long next = (addr + PGDIR_SIZE) & PGDIR_MASK;
+			if (next > addr)
+				break;
+			addr = next;
+			continue;
+		}
+		pud = pud_offset(pgd, addr);
+		if (pud_none(*pud)) {
+			addr = (addr + PUD_SIZE) & PUD_MASK;
 			continue;
 		}
-		pmd = pmd_offset(pgd, addr);
+		pmd = pmd_offset(pud, addr);
 		if (pmd_none(*pmd)) {
 			addr = (addr + PMD_SIZE) & PMD_MASK;
 			continue;
@@ -282,7 +293,8 @@ check_range(struct mm_struct *mm, unsign
 		if (prev && prev->vm_end < vma->vm_start)
 			return ERR_PTR(-EFAULT);
 		if ((flags & MPOL_MF_STRICT) && !is_vm_hugetlb_page(vma)) {
-			err = verify_pages(vma->vm_start, vma->vm_end, nodes);
+			err = verify_pages(vma->vm_mm,
+					   vma->vm_start, vma->vm_end, nodes);
 			if (err) {
 				first = ERR_PTR(err);
 				break;
diff -puN mm/mmap.c~4level-core-patch mm/mmap.c
--- linux-2.6/mm/mmap.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/mmap.c	2004-11-14 13:01:07.000000000 +1100
@@ -1474,7 +1474,7 @@ static void free_pgtables(struct mmu_gat
 {
 	unsigned long first = start & PGDIR_MASK;
 	unsigned long last = end + PGDIR_SIZE - 1;
-	unsigned long start_index, end_index;
+	unsigned long start_index;
 	struct mm_struct *mm = tlb->mm;
 
 	if (!prev) {
@@ -1498,23 +1498,23 @@ static void free_pgtables(struct mmu_gat
 			if (last > next->vm_start)
 				last = next->vm_start;
 		}
-		if (prev->vm_end > first)
+		if (prev->vm_end > first) {
 			first = prev->vm_end + PGDIR_SIZE - 1;
+			if (first < prev->vm_end)
+				first = TASK_SIZE;
+		}
 		break;
 	}
 no_mmaps:
-	if (last < first)	/* for arches with discontiguous pgd indices */
+	if (last < first)	/* for arches with discontiguous indices */
 		return;
-	/*
-	 * If the PGD bits are not consecutive in the virtual address, the
-	 * old method of shifting the VA >> by PGDIR_SHIFT doesn't work.
-	 */
 	start_index = pgd_index(first);
-	if (start_index < FIRST_USER_PGD_NR)
+	if (start_index < FIRST_USER_PGD_NR) {
 		start_index = FIRST_USER_PGD_NR;
-	end_index = pgd_index(last);
-	if (end_index > start_index) {
-		clear_page_tables(tlb, start_index, end_index - start_index);
+		first = start_index * PGDIR_SIZE;
+	}
+	if (last > first) {
+		clear_page_range(tlb, first, last);
 		flush_tlb_pgtables(mm, first & PGDIR_MASK, last & PGDIR_MASK);
 	}
 }
@@ -1844,7 +1844,8 @@ void exit_mmap(struct mm_struct *mm)
 					~0UL, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	BUG_ON(mm->map_count);	/* This is just debugging */
-	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
+	clear_page_range(tlb, FIRST_USER_PGD_NR * PGDIR_SIZE,
+			 (TASK_SIZE + PGDIR_SIZE - 1) & ~(PGDIR_SIZE - 1));
 	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
 
 	vma = mm->mmap;
diff -puN mm/mprotect.c~4level-core-patch mm/mprotect.c
--- linux-2.6/mm/mprotect.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/mprotect.c	2004-11-14 12:33:54.000000000 +1100
@@ -62,12 +62,38 @@ change_pte_range(pmd_t *pmd, unsigned lo
 }
 
 static inline void
-change_pmd_range(pgd_t *pgd, unsigned long address,
+change_pmd_range(pud_t *pud, unsigned long address,
 		unsigned long size, pgprot_t newprot)
 {
 	pmd_t * pmd;
 	unsigned long end;
 
+	if (pud_none(*pud))
+		return;
+	if (pud_bad(*pud)) {
+		pud_ERROR(*pud);
+		pud_clear(pud);
+		return;
+	}
+	pmd = pmd_offset(pud, address);
+	address &= ~PUD_MASK;
+	end = address + size;
+	if (end > PUD_SIZE)
+		end = PUD_SIZE;
+	do {
+		change_pte_range(pmd, address, end - address, newprot);
+		address = (address + PMD_SIZE) & PMD_MASK;
+		pmd++;
+	} while (address && (address < end));
+}
+
+static inline void
+change_pud_range(pgd_t *pgd, unsigned long address,
+		unsigned long size, pgprot_t newprot)
+{
+	pud_t * pud;
+	unsigned long end;
+
 	if (pgd_none(*pgd))
 		return;
 	if (pgd_bad(*pgd)) {
@@ -75,15 +101,15 @@ change_pmd_range(pgd_t *pgd, unsigned lo
 		pgd_clear(pgd);
 		return;
 	}
-	pmd = pmd_offset(pgd, address);
+	pud = pud_offset(pgd, address);
 	address &= ~PGDIR_MASK;
 	end = address + size;
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
 	do {
-		change_pte_range(pmd, address, end - address, newprot);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
+		change_pmd_range(pud, address, end - address, newprot);
+		address = (address + PUD_SIZE) & PUD_MASK;
+		pud++;
 	} while (address && (address < end));
 }
 
@@ -91,22 +117,25 @@ static void
 change_protection(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, pgprot_t newprot)
 {
-	pgd_t *dir;
-	unsigned long beg = start;
+	struct mm_struct *mm = current->mm;
+	pgd_t *pgd;
+	unsigned long beg = start, next;
+	int i;
 
-	dir = pgd_offset(current->mm, start);
+	pgd = pgd_offset(mm, start);
 	flush_cache_range(vma, beg, end);
-	if (start >= end)
-		BUG();
-	spin_lock(&current->mm->page_table_lock);
-	do {
-		change_pmd_range(dir, start, end - start, newprot);
-		start = (start + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (start && (start < end));
+	BUG_ON(start >= end);
+	spin_lock(&mm->page_table_lock);
+	for (i = pgd_index(start); i <= pgd_index(end-1); i++) {
+		next = (start + PGDIR_SIZE) & PGDIR_MASK;
+		if (next <= start || next > end)
+			next = end;
+		change_pud_range(pgd, start, next - start, newprot);
+		start = next;
+		pgd++;
+	}
 	flush_tlb_range(vma, beg, end);
-	spin_unlock(&current->mm->page_table_lock);
-	return;
+	spin_unlock(&mm->page_table_lock);
 }
 
 static int
diff -puN mm/mremap.c~4level-core-patch mm/mremap.c
--- linux-2.6/mm/mremap.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/mremap.c	2004-11-14 12:33:54.000000000 +1100
@@ -25,19 +25,24 @@
 static pte_t *get_one_pte_map_nested(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
 	if (pgd_none(*pgd))
 		goto end;
-	if (pgd_bad(*pgd)) {
-		pgd_ERROR(*pgd);
-		pgd_clear(pgd);
+
+	pud = pud_offset(pgd, addr);
+	if (pud_none(*pud))
+		goto end;
+	if (pud_bad(*pud)) {
+		pud_ERROR(*pud);
+		pud_clear(pud);
 		goto end;
 	}
 
-	pmd = pmd_offset(pgd, addr);
+	pmd = pmd_offset(pud, addr);
 	if (pmd_none(*pmd))
 		goto end;
 	if (pmd_bad(*pmd)) {
@@ -58,12 +63,17 @@ end:
 static pte_t *get_one_pte_map(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 
 	pgd = pgd_offset(mm, addr);
 	if (pgd_none(*pgd))
 		return NULL;
-	pmd = pmd_offset(pgd, addr);
+
+	pud = pud_offset(pgd, addr);
+	if (pud_none(*pud))
+		return NULL;
+	pmd = pmd_offset(pud, addr);
 	if (!pmd_present(*pmd))
 		return NULL;
 	return pte_offset_map(pmd, addr);
@@ -71,10 +81,17 @@ static pte_t *get_one_pte_map(struct mm_
 
 static inline pte_t *alloc_one_pte_map(struct mm_struct *mm, unsigned long addr)
 {
+	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte = NULL;
 
-	pmd = pmd_alloc(mm, pgd_offset(mm, addr), addr);
+	pgd = pgd_offset(mm, addr);
+
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return NULL;
+	pmd = pmd_alloc(mm, pud, addr);
 	if (pmd)
 		pte = pte_alloc_map(mm, pmd, addr);
 	return pte;
diff -puN mm/msync.c~4level-core-patch mm/msync.c
--- linux-2.6/mm/msync.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/msync.c	2004-11-14 16:31:51.000000000 +1100
@@ -67,13 +67,39 @@ static int filemap_sync_pte_range(pmd_t 
 	return error;
 }
 
-static inline int filemap_sync_pmd_range(pgd_t * pgd,
+static inline int filemap_sync_pmd_range(pud_t * pud,
 	unsigned long address, unsigned long end, 
 	struct vm_area_struct *vma, unsigned int flags)
 {
 	pmd_t * pmd;
 	int error;
 
+	if (pud_none(*pud))
+		return 0;
+	if (pud_bad(*pud)) {
+		pud_ERROR(*pud);
+		pud_clear(pud);
+		return 0;
+	}
+	pmd = pmd_offset(pud, address);
+	if ((address & PUD_MASK) != (end & PUD_MASK))
+		end = (address & PUD_MASK) + PUD_SIZE;
+	error = 0;
+	do {
+		error |= filemap_sync_pte_range(pmd, address, end, vma, flags);
+		address = (address + PMD_SIZE) & PMD_MASK;
+		pmd++;
+	} while (address && (address < end));
+	return error;
+}
+
+static inline int filemap_sync_pud_range(pgd_t *pgd,
+	unsigned long address, unsigned long end,
+	struct vm_area_struct *vma, unsigned int flags)
+{
+	pud_t *pud;
+	int error;
+
 	if (pgd_none(*pgd))
 		return 0;
 	if (pgd_bad(*pgd)) {
@@ -81,14 +107,14 @@ static inline int filemap_sync_pmd_range
 		pgd_clear(pgd);
 		return 0;
 	}
-	pmd = pmd_offset(pgd, address);
+	pud = pud_offset(pgd, address);
 	if ((address & PGDIR_MASK) != (end & PGDIR_MASK))
 		end = (address & PGDIR_MASK) + PGDIR_SIZE;
 	error = 0;
 	do {
-		error |= filemap_sync_pte_range(pmd, address, end, vma, flags);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
+		error |= filemap_sync_pmd_range(pud, address, end, vma, flags);
+		address = (address + PUD_SIZE) & PUD_MASK;
+		pud++;
 	} while (address && (address < end));
 	return error;
 }
@@ -96,8 +122,10 @@ static inline int filemap_sync_pmd_range
 static int filemap_sync(struct vm_area_struct * vma, unsigned long address,
 	size_t size, unsigned int flags)
 {
-	pgd_t * dir;
+	pgd_t *pgd;
 	unsigned long end = address + size;
+	unsigned long next;
+	int i;
 	int error = 0;
 
 	/* Aquire the lock early; it may be possible to avoid dropping
@@ -105,7 +133,7 @@ static int filemap_sync(struct vm_area_s
 	 */
 	spin_lock(&vma->vm_mm->page_table_lock);
 
-	dir = pgd_offset(vma->vm_mm, address);
+	pgd = pgd_offset(vma->vm_mm, address);
 	flush_cache_range(vma, address, end);
 
 	/* For hugepages we can't go walking the page table normally,
@@ -116,11 +144,14 @@ static int filemap_sync(struct vm_area_s
 
 	if (address >= end)
 		BUG();
-	do {
-		error |= filemap_sync_pmd_range(dir, address, end, vma, flags);
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
+	for (i = pgd_index(address); i <= pgd_index(end-1); i++) {
+		next = (address + PGDIR_SIZE) & PGDIR_MASK;
+		if (next <= address || next > end)
+			next = end;
+		error |= filemap_sync_pud_range(pgd, address, next, vma, flags);
+		address = next;
+		pgd++;
+	}
 	/*
 	 * Why flush ? filemap_sync_pte already flushed the tlbs with the
 	 * dirty bits.
diff -puN mm/rmap.c~4level-core-patch mm/rmap.c
--- linux-2.6/mm/rmap.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/rmap.c	2004-11-14 12:33:54.000000000 +1100
@@ -259,6 +259,7 @@ static int page_referenced_one(struct pa
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	int referenced = 0;
@@ -275,7 +276,11 @@ static int page_referenced_one(struct pa
 	if (!pgd_present(*pgd))
 		goto out_unlock;
 
-	pmd = pmd_offset(pgd, address);
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out_unlock;
+
+	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		goto out_unlock;
 
@@ -499,6 +504,7 @@ static int try_to_unmap_one(struct page 
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	pte_t pteval;
@@ -520,7 +526,11 @@ static int try_to_unmap_one(struct page 
 	if (!pgd_present(*pgd))
 		goto out_unlock;
 
-	pmd = pmd_offset(pgd, address);
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out_unlock;
+
+	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		goto out_unlock;
 
@@ -628,6 +638,7 @@ static void try_to_unmap_cluster(unsigne
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	pte_t pteval;
@@ -653,7 +664,11 @@ static void try_to_unmap_cluster(unsigne
 	if (!pgd_present(*pgd))
 		goto out_unlock;
 
-	pmd = pmd_offset(pgd, address);
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out_unlock;
+
+	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		goto out_unlock;
 
diff -puN mm/swapfile.c~4level-core-patch mm/swapfile.c
--- linux-2.6/mm/swapfile.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/swapfile.c	2004-11-14 16:31:51.000000000 +1100
@@ -486,27 +486,27 @@ static unsigned long unuse_pmd(struct vm
 }
 
 /* vma->vm_mm->page_table_lock is held */
-static unsigned long unuse_pgd(struct vm_area_struct * vma, pgd_t *dir,
-	unsigned long address, unsigned long size,
+static unsigned long unuse_pud(struct vm_area_struct * vma, pud_t *pud,
+        unsigned long address, unsigned long size, unsigned long offset,
 	swp_entry_t entry, struct page *page)
 {
 	pmd_t * pmd;
-	unsigned long offset, end;
+	unsigned long end;
 	unsigned long foundaddr;
 
-	if (pgd_none(*dir))
+	if (pud_none(*pud))
 		return 0;
-	if (pgd_bad(*dir)) {
-		pgd_ERROR(*dir);
-		pgd_clear(dir);
+	if (pud_bad(*pud)) {
+		pud_ERROR(*pud);
+		pud_clear(pud);
 		return 0;
 	}
-	pmd = pmd_offset(dir, address);
-	offset = address & PGDIR_MASK;
-	address &= ~PGDIR_MASK;
+	pmd = pmd_offset(pud, address);
+	offset += address & PUD_MASK;
+	address &= ~PUD_MASK;
 	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
+	if (end > PUD_SIZE)
+		end = PUD_SIZE;
 	if (address >= end)
 		BUG();
 	do {
@@ -521,12 +521,48 @@ static unsigned long unuse_pgd(struct vm
 }
 
 /* vma->vm_mm->page_table_lock is held */
+static unsigned long unuse_pgd(struct vm_area_struct * vma, pgd_t *pgd,
+	unsigned long address, unsigned long size,
+	swp_entry_t entry, struct page *page)
+{
+	pud_t * pud;
+	unsigned long offset;
+	unsigned long foundaddr;
+	unsigned long end;
+
+	if (pgd_none(*pgd))
+		return 0;
+	if (pgd_bad(*pgd)) {
+		pgd_ERROR(*pgd);
+		pgd_clear(pgd);
+		return 0;
+	}
+	pud = pud_offset(pgd, address);
+	offset = address & PGDIR_MASK;
+	address &= ~PGDIR_MASK;
+	end = address + size;
+	if (end > PGDIR_SIZE)
+		end = PGDIR_SIZE;
+	BUG_ON (address >= end);
+	do {
+		foundaddr = unuse_pud(vma, pud, address, end - address,
+					        offset, entry, page);
+		if (foundaddr)
+			return foundaddr;
+		address = (address + PUD_SIZE) & PUD_MASK;
+		pud++;
+	} while (address && (address < end));
+	return 0;
+}
+
+/* vma->vm_mm->page_table_lock is held */
 static unsigned long unuse_vma(struct vm_area_struct * vma,
 	swp_entry_t entry, struct page *page)
 {
-	pgd_t *pgdir;
-	unsigned long start, end;
+	pgd_t *pgd;
+	unsigned long start, end, next;
 	unsigned long foundaddr;
+	int i;
 
 	if (page->mapping) {
 		start = page_address_in_vma(page, vma);
@@ -538,15 +574,18 @@ static unsigned long unuse_vma(struct vm
 		start = vma->vm_start;
 		end = vma->vm_end;
 	}
-	pgdir = pgd_offset(vma->vm_mm, start);
-	do {
-		foundaddr = unuse_pgd(vma, pgdir, start, end - start,
-						entry, page);
+	pgd = pgd_offset(vma->vm_mm, start);
+	for (i = pgd_index(start); i <= pgd_index(end-1); i++) {
+		next = (start + PGDIR_SIZE) & PGDIR_MASK;
+		if (next > end || next <= start)
+			next = end;
+		foundaddr = unuse_pgd(vma, pgd, start, next - start, entry, page);
 		if (foundaddr)
 			return foundaddr;
-		start = (start + PGDIR_SIZE) & PGDIR_MASK;
-		pgdir++;
-	} while (start && (start < end));
+		start = next;
+		i++;
+		pgd++;
+	}
 	return 0;
 }
 
diff -puN mm/vmalloc.c~4level-core-patch mm/vmalloc.c
--- linux-2.6/mm/vmalloc.c~4level-core-patch	2004-11-14 12:33:54.000000000 +1100
+++ linux-2.6-npiggin/mm/vmalloc.c	2004-11-14 16:31:51.000000000 +1100
@@ -56,25 +56,25 @@ static void unmap_area_pte(pmd_t *pmd, u
 	} while (address < end);
 }
 
-static void unmap_area_pmd(pgd_t *dir, unsigned long address,
+static void unmap_area_pmd(pud_t *pud, unsigned long address,
 				  unsigned long size)
 {
 	unsigned long end;
 	pmd_t *pmd;
 
-	if (pgd_none(*dir))
+	if (pud_none(*pud))
 		return;
-	if (pgd_bad(*dir)) {
-		pgd_ERROR(*dir);
-		pgd_clear(dir);
+	if (pud_bad(*pud)) {
+		pud_ERROR(*pud);
+		pud_clear(pud);
 		return;
 	}
 
-	pmd = pmd_offset(dir, address);
-	address &= ~PGDIR_MASK;
+	pmd = pmd_offset(pud, address);
+	address &= ~PUD_MASK;
 	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
+	if (end > PUD_SIZE)
+		end = PUD_SIZE;
 
 	do {
 		unmap_area_pte(pmd, address, end - address);
@@ -83,6 +83,33 @@ static void unmap_area_pmd(pgd_t *dir, u
 	} while (address < end);
 }
 
+static void unmap_area_pud(pgd_t *pgd, unsigned long address,
+			   unsigned long size)
+{
+	pud_t *pud;
+	unsigned long end;
+
+	if (pgd_none(*pgd))
+		return;
+	if (pgd_bad(*pgd)) {
+		pgd_ERROR(*pgd);
+		pgd_clear(pgd);
+		return;
+	}
+
+	pud = pud_offset_k(pgd, address);
+	address &= ~PGDIR_MASK;
+	end = address + size;
+	if (end > PGDIR_SIZE)
+		end = PGDIR_SIZE;
+
+	do {
+		unmap_area_pmd(pud, address, end - address);
+		address = (address + PUD_SIZE) & PUD_MASK;
+		pud++;
+	} while (address && (address < end));
+}
+
 static int map_area_pte(pte_t *pte, unsigned long address,
 			       unsigned long size, pgprot_t prot,
 			       struct page ***pages)
@@ -96,7 +123,6 @@ static int map_area_pte(pte_t *pte, unsi
 
 	do {
 		struct page *page = **pages;
-
 		WARN_ON(!pte_none(*pte));
 		if (!page)
 			return -ENOMEM;
@@ -115,11 +141,11 @@ static int map_area_pmd(pmd_t *pmd, unsi
 {
 	unsigned long base, end;
 
-	base = address & PGDIR_MASK;
-	address &= ~PGDIR_MASK;
+	base = address & PUD_MASK;
+	address &= ~PUD_MASK;
 	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
+	if (end > PUD_SIZE)
+		end = PUD_SIZE;
 
 	do {
 		pte_t * pte = pte_alloc_kernel(&init_mm, pmd, base + address);
@@ -134,19 +160,41 @@ static int map_area_pmd(pmd_t *pmd, unsi
 	return 0;
 }
 
+static int map_area_pud(pud_t *pud, unsigned long address,
+			       unsigned long end, pgprot_t prot,
+			       struct page ***pages)
+{
+	do {
+		pmd_t *pmd = pmd_alloc(&init_mm, pud, address);
+		if (!pmd)
+			return -ENOMEM;
+		if (map_area_pmd(pmd, address, end - address, prot, pages))
+			return -ENOMEM;
+		address = (address + PUD_SIZE) & PUD_MASK;
+		pud++;
+	} while (address && address < end);
+
+	return 0;
+}
+
 void unmap_vm_area(struct vm_struct *area)
 {
 	unsigned long address = (unsigned long) area->addr;
 	unsigned long end = (address + area->size);
-	pgd_t *dir;
+	unsigned long next;
+	pgd_t *pgd;
+	int i;
 
-	dir = pgd_offset_k(address);
+	pgd = pgd_offset_k(address);
 	flush_cache_vunmap(address, end);
-	do {
-		unmap_area_pmd(dir, address, end - address);
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
+	for (i = pgd_index(address); i <= pgd_index(end-1); i++) {
+		next = (address + PGDIR_SIZE) & PGDIR_MASK;
+		if (next <= address || next > end)
+			next = end;
+		unmap_area_pud(pgd, address, next - address);
+		address = next;
+	        pgd++;
+	}
 	flush_tlb_kernel_range((unsigned long) area->addr, end);
 }
 
@@ -154,25 +202,30 @@ int map_vm_area(struct vm_struct *area, 
 {
 	unsigned long address = (unsigned long) area->addr;
 	unsigned long end = address + (area->size-PAGE_SIZE);
-	pgd_t *dir;
+	unsigned long next;
+	pgd_t *pgd;
 	int err = 0;
+	int i;
 
-	dir = pgd_offset_k(address);
+	pgd = pgd_offset_k(address);
 	spin_lock(&init_mm.page_table_lock);
-	do {
-		pmd_t *pmd = pmd_alloc(&init_mm, dir, address);
-		if (!pmd) {
+	for (i = pgd_index(address); i <= pgd_index(end-1); i++) {
+		pud_t *pud = pud_alloc(&init_mm, pgd, address);
+		if (!pud) {
 			err = -ENOMEM;
 			break;
 		}
-		if (map_area_pmd(pmd, address, end - address, prot, pages)) {
+		next = (address + PGDIR_SIZE) & PGDIR_MASK;
+		if (next < address || next > end)
+			next = end;
+		if (map_area_pud(pud, address, next, prot, pages)) {
 			err = -ENOMEM;
 			break;
 		}
 
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
+		address = next;
+		pgd++;
+	}
 
 	spin_unlock(&init_mm.page_table_lock);
 	flush_cache_vmap((unsigned long) area->addr, end);

_

--------------050301020608040104000001--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
