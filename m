Date: Tue, 28 Jan 2003 14:41:04 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.59-mm6] Speed up task exit
Message-ID: <64880000.1043786464@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1869179384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========1869179384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Andrew, this builds on my first patch eliminating the page_table_lock
during page table cleanup on exit.  I took a good hard look at
clear_page_tables, and realized that it's using up a lot of time to run.
It walks through a lot of empty slots looking for pte pages to free.

I came to the realization that if we could just keep a count of mapped
pages and swap entries, we'd know right away if a pte page is freeable.
This patch tracks the count for pte pages and removes them as soon as
they're unused, eliminating the need for clear_page_tables entirely.

Doing this gained another 5% in my fork/exit timing tests, so the combined
patch gives me a 10% improvement in fork/exit.

Tracking the reference counts was the last straw in overloading struct page
with pte page info, so I created a 'struct ptpage' to use when the struct
page describes a page table page.  It's a bit of a hack, but I think in the
long run will make it more understandable.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1869179384==========
Content-Type: text/plain; charset=iso-8859-1; name="exit-2.5.59-mm6-2.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="exit-2.5.59-mm6-2.diff"; size=26209

--- 2.5.59-mm6/./include/asm-generic/tlb.h	2003-01-16 20:21:33.000000000 =
-0600
+++ 2.5.59-mm6-test/./include/asm-generic/tlb.h	2003-01-27 =
11:10:49.000000000 -0600
@@ -84,13 +84,6 @@
 static inline void
 tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long =
end)
 {
-	int freed =3D tlb->freed;
-	struct mm_struct *mm =3D tlb->mm;
-	int rss =3D mm->rss;
-
-	if (rss < freed)
-		freed =3D rss;
-	mm->rss =3D rss - freed;
 	tlb_flush_mmu(tlb, start, end);
=20
 	/* keep the page table cache within bounds */
--- 2.5.59-mm6/./include/asm-generic/rmap.h	2003-01-16 20:22:19.000000000 =
-0600
+++ 2.5.59-mm6-test/./include/asm-generic/rmap.h	2003-01-27 =
11:10:49.000000000 -0600
@@ -26,7 +26,8 @@
  */
 #include <linux/mm.h>
=20
-static inline void pgtable_add_rmap(struct page * page, struct mm_struct * =
mm, unsigned long address)
+static inline void
+pgtable_add_rmap(struct ptpage * page, struct mm_struct * mm, unsigned =
long address)
 {
 #ifdef BROKEN_PPC_PTE_ALLOC_ONE
 	/* OK, so PPC calls pte_alloc() before mem_map[] is setup ... ;( */
@@ -35,30 +36,31 @@
 	if (!mem_init_done)
 		return;
 #endif
-	page->mapping =3D (void *)mm;
-	page->index =3D address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
+	page->mm =3D mm;
+	page->virtual =3D address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
 	inc_page_state(nr_page_table_pages);
 }
=20
-static inline void pgtable_remove_rmap(struct page * page)
+static inline void
+pgtable_remove_rmap(struct ptpage * page)
 {
-	page->mapping =3D NULL;
-	page->index =3D 0;
+	page->mm =3D NULL;
+	page->virtual =3D 0;
 	dec_page_state(nr_page_table_pages);
 }
=20
 static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
 {
-	struct page * page =3D kmap_atomic_to_page(ptep);
-	return (struct mm_struct *) page->mapping;
+	struct ptpage * page =3D (struct ptpage *)kmap_atomic_to_page(ptep);
+	return page->mm;
 }
=20
 static inline unsigned long ptep_to_address(pte_t * ptep)
 {
-	struct page * page =3D kmap_atomic_to_page(ptep);
+	struct ptpage * page =3D (struct ptpage *)kmap_atomic_to_page(ptep);
 	unsigned long low_bits;
 	low_bits =3D ((unsigned long)ptep & ~PAGE_MASK) * PTRS_PER_PTE;
-	return page->index + low_bits;
+	return page->virtual + low_bits;
 }
=20
 #if CONFIG_HIGHPTE
--- 2.5.59-mm6/./include/linux/mm.h	2003-01-27 11:01:12.000000000 -0600
+++ 2.5.59-mm6-test/./include/linux/mm.h	2003-01-28 10:35:07.000000000 =
-0600
@@ -196,6 +196,16 @@
  */
 #include <linux/page-flags.h>
=20
+struct ptpage {
+	unsigned long flags;		/* atomic flags, some possibly
+					   updated asynchronously */
+	atomic_t count;			/* Usage count, see below. */
+	struct mm_struct *mm;		/* mm_struct this page belongs to */
+	unsigned long virtual;		/* virtual address this page maps */
+	unsigned long mapcount;		/* Number of pages mapped to this page */
+	unsigned long swapcount; 	/* Number of swap pages in this page */
+};
+
 /*
  * Methods to modify the page usage count.
  *
@@ -365,6 +375,11 @@
 void shmem_lock(struct file * file, int lock);
 int shmem_zero_setup(struct vm_area_struct *);
=20
+void increment_rss(struct ptpage *ptpage);
+void decrement_rss(struct ptpage *ptpage);
+void increment_swapcount(struct ptpage *ptpage);
+void decrement_swapcount(struct ptpage *ptpage);
+
 void zap_page_range(struct vm_area_struct *vma, unsigned long address,
 			unsigned long size);
 int unmap_vmas(struct mmu_gather **tlbp, struct mm_struct *mm,
@@ -372,7 +387,6 @@
 		unsigned long end_addr, unsigned long *nr_accounted);
 void unmap_page_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			unsigned long address, unsigned long size);
-void clear_page_tables(struct mmu_gather *tlb, unsigned long first, int =
nr);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 int remap_page_range(struct vm_area_struct *vma, unsigned long from,
--- 2.5.59-mm6/./include/asm-i386/pgalloc.h	2003-01-27 11:01:11.000000000 =
-0600
+++ 2.5.59-mm6-test/./include/asm-i386/pgalloc.h	2003-01-27 =
11:10:49.000000000 -0600
@@ -10,10 +10,10 @@
 #define pmd_populate_kernel(mm, pmd, pte) \
 		set_pmd(pmd, __pmd(_PAGE_TABLE + __pa(pte)))
=20
-static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct =
page *pte)
+static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct =
ptpage *pte)
 {
 	set_pmd(pmd, __pmd(_PAGE_TABLE +
-		((unsigned long long)page_to_pfn(pte) <<
+		((unsigned long long)page_to_pfn((struct page *)pte) <<
 			(unsigned long long) PAGE_SHIFT)));
 }
 /*
@@ -24,20 +24,20 @@
 void pgd_free(pgd_t *pgd);
=20
 pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
-struct page *pte_alloc_one(struct mm_struct *, unsigned long);
+struct ptpage *pte_alloc_one(struct mm_struct *, unsigned long);
=20
 static inline void pte_free_kernel(pte_t *pte)
 {
 	free_page((unsigned long)pte);
 }
=20
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct ptpage *pte)
 {
-	__free_page(pte);
+	__free_page((struct page *)pte);
 }
=20
=20
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),((struct page =
*)pte))
=20
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
--- 2.5.59-mm6/./include/asm-i386/pgtable.h	2003-01-27 11:01:11.000000000 =
-0600
+++ 2.5.59-mm6-test/./include/asm-i386/pgtable.h	2003-01-27 =
11:10:49.000000000 -0600
@@ -229,6 +229,8 @@
 #define pmd_page(pmd) (pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 #endif /* !CONFIG_DISCONTIGMEM */
=20
+#define	pmd_ptpage(pmd) ((struct ptpage *)pmd_page(pmd))
+
 #define pmd_large(pmd) \
 	((pmd_val(pmd) & (_PAGE_PSE|_PAGE_PRESENT)) =3D=3D =
(_PAGE_PSE|_PAGE_PRESENT))
=20
--- 2.5.59-mm6/./arch/i386/mm/pgtable.c	2003-01-27 11:01:08.000000000 -0600
+++ 2.5.59-mm6-test/./arch/i386/mm/pgtable.c	2003-01-27 11:10:49.000000000 =
-0600
@@ -145,24 +145,26 @@
 	return pte;
 }
=20
-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
+struct ptpage *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	int count =3D 0;
-	struct page *pte;
+	struct ptpage *pte;
   =20
    	do {
 #if CONFIG_HIGHPTE
-		pte =3D alloc_pages(GFP_KERNEL | __GFP_HIGHMEM, 0);
+		pte =3D (struct ptpage *)alloc_pages(GFP_KERNEL | __GFP_HIGHMEM, 0);
 #else
-		pte =3D alloc_pages(GFP_KERNEL, 0);
+		pte =3D (struct ptpage *)alloc_pages(GFP_KERNEL, 0);
 #endif
-		if (pte)
-			clear_highpage(pte);
-		else {
+		if (pte) {
+			clear_highpage((struct page *)pte);
+			pte->mapcount =3D pte->swapcount=3D 0;
+			break;
+		} else {
 			current->state =3D TASK_UNINTERRUPTIBLE;
 			schedule_timeout(HZ);
 		}
-	} while (!pte && (count++ < 10));
+	} while (count++ < 10);
 	return pte;
 }
=20
--- 2.5.59-mm6/./fs/exec.c	2003-01-27 11:01:10.000000000 -0600
+++ 2.5.59-mm6-test/./fs/exec.c	2003-01-28 10:44:04.000000000 -0600
@@ -317,7 +317,7 @@
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(page, PAGE_COPY))));
 	pte_chain =3D page_add_rmap(page, pte, pte_chain);
 	pte_unmap(pte);
-	tsk->mm->rss++;
+	increment_rss(pmd_ptpage(*pmd));
 	spin_unlock(&tsk->mm->page_table_lock);
=20
 	/* no need for flush_tlb */
--- 2.5.59-mm6/./mm/fremap.c	2003-01-16 20:21:34.000000000 -0600
+++ 2.5.59-mm6-test/./mm/fremap.c	2003-01-28 10:54:01.000000000 -0600
@@ -19,9 +19,11 @@
 static inline void zap_pte(struct mm_struct *mm, pte_t *ptep)
 {
 	pte_t pte =3D *ptep;
+	struct ptpage *ptpage;
=20
 	if (pte_none(pte))
 		return;
+	ptpage =3D (struct ptpage *)kmap_atomic_to_page((void *)ptep);
 	if (pte_present(pte)) {
 		unsigned long pfn =3D pte_pfn(pte);
=20
@@ -33,12 +35,13 @@
 					set_page_dirty(page);
 				page_remove_rmap(page, ptep);
 				page_cache_release(page);
-				mm->rss--;
+				decrement_rss(ptpage);
 			}
 		}
 	} else {
 		free_swap_and_cache(pte_to_swp_entry(pte));
 		pte_clear(ptep);
+		decrement_swapcount(ptpage);
 	}
 }
=20
@@ -69,7 +72,6 @@
=20
 	zap_pte(mm, pte);
=20
-	mm->rss++;
 	flush_page_to_ram(page);
 	flush_icache_page(vma, page);
 	entry =3D mk_pte(page, protection_map[prot]);
@@ -78,6 +80,7 @@
 	set_pte(pte, entry);
 	pte_chain =3D page_add_rmap(page, pte, pte_chain);
 	pte_unmap(pte);
+	increment_rss(pmd_ptpage(*pmd));
 	flush_tlb_page(vma, addr);
=20
 	spin_unlock(&mm->page_table_lock);
--- 2.5.59-mm6/./mm/swapfile.c	2003-01-16 20:21:44.000000000 -0600
+++ 2.5.59-mm6-test/./mm/swapfile.c	2003-01-28 11:14:00.000000000 -0600
@@ -379,20 +379,23 @@
  */
 /* mmlist_lock and vma->vm_mm->page_table_lock are held */
 static void
-unuse_pte(struct vm_area_struct *vma, unsigned long address, pte_t *dir,
+unuse_pte(struct vm_area_struct *vma, pmd_t *pmd, pte_t *dir,
 	swp_entry_t entry, struct page *page, struct pte_chain **pte_chainp)
 {
 	pte_t pte =3D *dir;
+	struct ptpage *ptpage;
=20
 	if (likely(pte_to_swp_entry(pte).val !=3D entry.val))
 		return;
 	if (unlikely(pte_none(pte) || pte_present(pte)))
 		return;
+	ptpage =3D pmd_ptpage(*pmd);
 	get_page(page);
 	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	*pte_chainp =3D page_add_rmap(page, dir, *pte_chainp);
+	increment_rss(ptpage);
+	decrement_swapcount(ptpage);
 	swap_free(entry);
-	++vma->vm_mm->rss;
 }
=20
 /* mmlist_lock and vma->vm_mm->page_table_lock are held */
@@ -423,8 +426,7 @@
 		 */
 		if (pte_chain =3D=3D NULL)
 			pte_chain =3D pte_chain_alloc(GFP_ATOMIC);
-		unuse_pte(vma, offset+address-vma->vm_start,
-				pte, entry, page, &pte_chain);
+		unuse_pte(vma, dir, pte, entry, page, &pte_chain);
 		address +=3D PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
--- 2.5.59-mm6/./mm/memory.c	2003-01-16 20:22:06.000000000 -0600
+++ 2.5.59-mm6-test/./mm/memory.c	2003-01-28 11:02:33.000000000 -0600
@@ -64,81 +64,46 @@
 void * high_memory;
 struct page *highmem_start_page;
=20
-/*
- * We special-case the C-O-W ZERO_PAGE, because it's such
- * a common occurrence (no need to read the page to know
- * that it's zero - better for the cache and memory subsystem).
- */
-static inline void copy_cow_page(struct page * from, struct page * to, =
unsigned long address)
+void increment_rss(struct ptpage *ptpage)
 {
-	if (from =3D=3D ZERO_PAGE(address)) {
-		clear_user_highpage(to, address);
-		return;
-	}
-	copy_user_highpage(to, from, address);
+	ptpage->mapcount++;
+	ptpage->mm->rss++;
 }
=20
-/*
- * Note: this doesn't free the actual pages themselves. That
- * has been handled earlier when unmapping all the memory regions.
- */
-static inline void free_one_pmd(struct mmu_gather *tlb, pmd_t * dir)
+void decrement_rss(struct ptpage *ptpage)
 {
-	struct page *page;
-
-	if (pmd_none(*dir))
-		return;
-	if (pmd_bad(*dir)) {
-		pmd_ERROR(*dir);
-		pmd_clear(dir);
-		return;
-	}
-	page =3D pmd_page(*dir);
-	pmd_clear(dir);
-	pgtable_remove_rmap(page);
-	pte_free_tlb(tlb, page);
+	ptpage->mapcount--;
+	ptpage->mm->rss--;
 }
=20
-static inline void free_one_pgd(struct mmu_gather *tlb, pgd_t * dir)
+void increment_swapcount(struct ptpage *ptpage)
 {
-	int j;
-	pmd_t * pmd;
+	ptpage->swapcount++;
+}
=20
-	if (pgd_none(*dir))
-		return;
-	if (pgd_bad(*dir)) {
-		pgd_ERROR(*dir);
-		pgd_clear(dir);
-		return;
-	}
-	pmd =3D pmd_offset(dir, 0);
-	pgd_clear(dir);
-	for (j =3D 0; j < PTRS_PER_PMD ; j++)
-		free_one_pmd(tlb, pmd+j);
-	pmd_free_tlb(tlb, pmd);
+void decrement_swapcount(struct ptpage *ptpage)
+{
+	ptpage->swapcount--;
 }
=20
 /*
- * This function clears all user-level page tables of a process - this
- * is needed by execve(), so that old pages aren't in the way.
- *
- * Must be called with pagetable lock held.
+ * We special-case the C-O-W ZERO_PAGE, because it's such
+ * a common occurrence (no need to read the page to know
+ * that it's zero - better for the cache and memory subsystem).
  */
-void clear_page_tables(struct mmu_gather *tlb, unsigned long first, int =
nr)
+static inline void copy_cow_page(struct page * from, struct page * to, =
unsigned long address)
 {
-	pgd_t * page_dir =3D tlb->mm->pgd;
-
-	page_dir +=3D first;
-	do {
-		free_one_pgd(tlb, page_dir);
-		page_dir++;
-	} while (--nr);
+	if (from =3D=3D ZERO_PAGE(address)) {
+		clear_user_highpage(to, address);
+		return;
+	}
+	copy_user_highpage(to, from, address);
 }
=20
 pte_t * pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long =
address)
 {
 	if (!pmd_present(*pmd)) {
-		struct page *new;
+		struct ptpage *new;
=20
 		spin_unlock(&mm->page_table_lock);
 		new =3D pte_alloc_one(mm, address);
@@ -182,7 +147,6 @@
 			pte_free_kernel(new);
 			goto out;
 		}
-		pgtable_add_rmap(virt_to_page(new), mm, address);
 		pmd_populate_kernel(mm, pmd, new);
 	}
 out:
@@ -252,6 +216,7 @@
=20
 		do {
 			pte_t * src_pte, * dst_pte;
+			struct page *ptpage;
 		
 			/* copy_pte_range */
 		
@@ -272,6 +237,7 @@
 				goto nomem;
 			spin_lock(&src->page_table_lock);	
 			src_pte =3D pte_offset_map_nested(src_pmd, address);
+			ptpage =3D pmd_ptpage(*dst_pmd);
 			do {
 				pte_t pte =3D *src_pte;
 				struct page *page;
@@ -285,6 +251,7 @@
 				if (!pte_present(pte)) {
 					swap_duplicate(pte_to_swp_entry(pte));
 					set_pte(dst_pte, pte);
+					increment_swapcount(ptpage);
 					goto cont_copy_pte_range_noset;
 				}
 				pfn =3D pte_pfn(pte);
@@ -311,7 +278,7 @@
 					pte =3D pte_mkclean(pte);
 				pte =3D pte_mkold(pte);
 				get_page(page);
-				dst->rss++;
+				increment_rss(ptpage);
=20
 cont_copy_pte_range:
 				set_pte(dst_pte, pte);
@@ -374,6 +341,7 @@
 {
 	unsigned long offset;
 	pte_t *ptep;
+	struct ptpage *ptpage;
=20
 	if (pmd_none(*pmd))
 		return;
@@ -382,6 +350,7 @@
 		pmd_clear(pmd);
 		return;
 	}
+	ptpage =3D pmd_ptpage(*pmd);
 	ptep =3D pte_offset_map(pmd, address);
 	offset =3D address & ~PMD_MASK;
 	if (offset + size > PMD_SIZE)
@@ -406,13 +375,21 @@
 						mark_page_accessed(page);
 					tlb->freed++;
 					page_remove_rmap(page, ptep);
+					decrement_rss(ptpage);
 					tlb_remove_page(tlb, page);
 				}
 			}
 		} else {
 			free_swap_and_cache(pte_to_swp_entry(pte));
+			decrement_swapcount(ptpage);
 			pte_clear(ptep);
 		}
+		if (!ptpage->mapcount && !ptpage->swapcount) {
+			pmd_clear(pmd);
+			pgtable_remove_rmap(ptpage);
+			pte_free_tlb(tlb, ptpage);
+			break;
+		}
 	}
 	pte_unmap(ptep-1);
 }
@@ -596,6 +573,170 @@
 	spin_unlock(&mm->page_table_lock);
 }
=20
+/**
+ * unmap_all_pages - unmap all the pages for an mm_struct
+ * @mm: the mm_struct to unmap
+ *
+ * This function is only called when an mm_struct is about to be
+ * released.  It walks through all vmas and removes their pages
+ * from the page table.  It understands shared pte pages and will
+ * decrement the count appropriately.
+ */
+void unmap_all_pages(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	struct ptpage *ptpage;
+	struct page *pagevec[16];
+	int npages =3D 0;
+	unsigned long address;
+	unsigned long vm_end, pmd_end, pte_end;
+
+	lru_add_drain();
+
+	vma =3D mm->mmap;
+
+	/* On the off chance that the first vma is hugetlb... */
+	if (is_vm_hugetlb_page(vma)) {
+		unmap_hugepage_range(vma, vma->vm_start, vma->vm_end);
+		vma =3D vma->vm_next;
+		mm->map_count--;
+	}
+
+	for (;;) {
+		if (!vma)
+			goto out;
+
+		address =3D vma->vm_start;
+next_vma:
+		vm_end =3D vma->vm_end;
+		mm->map_count--;
+		/*
+		 * Advance the vma pointer to the next vma.
+		 * To facilitate coalescing adjacent vmas, the
+		 * pointer always points to the next one
+		 * beyond the range we're currently working
+		 * on, which means vma will be null on the
+		 * last iteration.
+		 */
+		vma =3D vma->vm_next;
+		if (vma) {
+			/*
+			 * Go ahead and include hugetlb vmas
+			 * in the range we process.  The pmd
+			 * entry will be cleared by close, so
+			 * we'll just skip over them.  This is
+			 * easier than trying to avoid them.
+			 */
+			if (is_vm_hugetlb_page(vma))
+				unmap_hugepage_range(vma, vma->vm_start, vma->vm_end);
+
+			/*
+			 * Coalesce adjacent vmas and process
+			 * them all in one iteration.
+			 */
+			if (vma->vm_start =3D=3D vm_end) {
+				goto next_vma;
+			}
+		}
+		pgd =3D pgd_offset(mm, address);
+		do {
+			if (pgd_none(*pgd))
+				goto skip_pgd;
+
+			if (pgd_bad(*pgd)) {
+				pgd_ERROR(*pgd);
+				pgd_clear(pgd);
+skip_pgd:
+				address =3D (address + PGDIR_SIZE) & PGDIR_MASK;
+				if (address > vm_end)
+					address =3D vm_end;
+				goto next_pgd;
+			}
+			pmd =3D pmd_offset(pgd, address);
+			if (vm_end > ((address + PGDIR_SIZE) & PGDIR_MASK))
+				pmd_end =3D (address + PGDIR_SIZE) & PGDIR_MASK;
+			else
+				pmd_end =3D vm_end;
+
+			do {
+				if (pmd_none(*pmd))
+					goto skip_pmd;
+				if (pmd_bad(*pmd)) {
+					pmd_ERROR(*pmd);
+					pmd_clear(pmd);
+skip_pmd:
+					address =3D  (address + PMD_SIZE) & PMD_MASK;
+					if (address > pmd_end)
+						address =3D pmd_end;
+					goto next_pmd;
+				}
+				ptpage =3D pmd_ptpage(*pmd);
+				pte =3D pte_offset_map(pmd, address);
+				if (pmd_end > ((address + PMD_SIZE) & PMD_MASK))
+					pte_end =3D (address + PMD_SIZE) & PMD_MASK;
+				else
+					pte_end =3D pmd_end;
+				do {
+					pte_t pteval =3D *pte;
+
+					if (pte_none(pteval))
+						goto next_pte;
+					if (pte_present(pteval)) {
+						unsigned long pfn =3D pte_pfn(pteval);
+						if (pfn_valid(pfn)) {
+							struct page *page =3D pfn_to_page(pfn);
+							if (!PageReserved(page)) {
+								if (pte_dirty(pteval))
+									set_page_dirty(page);
+								if (page->mapping &&
+								    pte_young(pteval) &&
+								    !PageSwapCache(page))
+									mark_page_accessed(page);
+								page_remove_rmap(page, pte);
+								decrement_rss(ptpage);
+								pagevec[npages++] =3D page;
+								if (npages =3D=3D 16) {
+									free_pages_and_swap_cache(pagevec, npages);
+									npages =3D 0;
+								}
+								
+							}
+						}
+					} else {
+						free_swap_and_cache(pte_to_swp_entry(pteval));
+						decrement_swapcount(ptpage);
+					}
+					pte_clear(pte);
+					if (!ptpage->mapcount && !ptpage->swapcount) {
+						pmd_clear(pmd);
+						pgtable_remove_rmap(ptpage);
+						pte_free(ptpage);
+						address =3D pte_end;
+						break;
+					}
+next_pte:
+					address +=3D PAGE_SIZE;
+					pte++;
+				} while (address < pte_end);
+				pte_unmap(pte-1);
+next_pmd:
+				pmd++;
+			} while (address < pmd_end);
+next_pgd:
+			pgd++;
+		} while (address < vm_end);
+	}
+
+out:
+	if (npages)
+		free_pages_and_swap_cache(pagevec, npages);
+
+	flush_tlb_mm(mm);
+}
+
 /*
  * Do a quick page-table lookup for a single page.
  * mm->page_table_lock must be held.
@@ -962,8 +1103,6 @@
 	spin_lock(&mm->page_table_lock);
 	page_table =3D pte_offset_map(pmd, address);
 	if (pte_same(*page_table, pte)) {
-		if (PageReserved(old_page))
-			++mm->rss;
 		page_remove_rmap(old_page, page_table);
 		break_cow(vma, new_page, address, page_table);
 		pte_chain =3D page_add_rmap(new_page, page_table, pte_chain);
@@ -1114,6 +1253,7 @@
 	swp_entry_t entry =3D pte_to_swp_entry(orig_pte);
 	pte_t pte;
 	int ret =3D VM_FAULT_MINOR;
+	struct ptpage *ptpage;
 	struct pte_chain *pte_chain =3D NULL;
=20
 	pte_unmap(page_table);
@@ -1172,7 +1312,6 @@
 	if (vm_swap_full())
 		remove_exclusive_swap_page(page);
=20
-	mm->rss++;
 	pte =3D mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page))
 		pte =3D pte_mkdirty(pte_mkwrite(pte));
@@ -1182,6 +1321,9 @@
 	flush_icache_page(vma, page);
 	set_pte(page_table, pte);
 	pte_chain =3D page_add_rmap(page, page_table, pte_chain);
+	ptpage =3D pmd_ptpage(*pmd);
+	increment_rss(ptpage);
+	decrement_swapcount(ptpage);
=20
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
@@ -1242,7 +1384,6 @@
 			ret =3D VM_FAULT_MINOR;
 			goto out;
 		}
-		mm->rss++;
 		flush_page_to_ram(page);
 		entry =3D pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 		lru_cache_add_active(page);
@@ -1253,6 +1394,7 @@
 	/* ignores ZERO_PAGE */
 	pte_chain =3D page_add_rmap(page, page_table, pte_chain);
 	pte_unmap(page_table);
+	increment_rss(pmd_ptpage(*pmd));
=20
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, entry);
@@ -1332,7 +1474,6 @@
 	 */
 	/* Only go through if we didn't race with anybody else... */
 	if (pte_none(*page_table)) {
-		++mm->rss;
 		flush_page_to_ram(new_page);
 		flush_icache_page(vma, new_page);
 		entry =3D mk_pte(new_page, vma->vm_page_prot);
@@ -1341,6 +1482,7 @@
 		set_pte(page_table, entry);
 		pte_chain =3D page_add_rmap(new_page, page_table, pte_chain);
 		pte_unmap(page_table);
+		increment_rss(pmd_ptpage(*pmd));
 	} else {
 		/* One of our sibling threads was faster, back out. */
 		pte_unmap(page_table);
--- 2.5.59-mm6/./mm/mremap.c	2003-01-16 20:22:15.000000000 -0600
+++ 2.5.59-mm6-test/./mm/mremap.c	2003-01-28 11:05:22.000000000 -0600
@@ -94,8 +94,10 @@
 		page =3D pte_page(*src);
=20
 	if (!pte_none(*src)) {
-		if (page)
+		if (page) {
 			page_remove_rmap(page, src);
+			decrement_rss((struct ptpage *)kmap_atomic_to_page((void *)src));
+		}
 		pte =3D ptep_get_and_clear(src);
 		if (!dst) {
 			/* No dest?  We must put it back. */
@@ -103,8 +105,10 @@
 			error++;
 		}
 		set_pte(dst, pte);
-		if (page)
+		if (page) {
 			*pte_chainp =3D page_add_rmap(page, dst, *pte_chainp);
+			increment_rss((struct ptpage *)kmap_atomic_to_page((void *)dst));
+		}
 	}
 	return error;
 }
--- 2.5.59-mm6/./mm/mmap.c	2003-01-27 11:01:12.000000000 -0600
+++ 2.5.59-mm6-test/./mm/mmap.c	2003-01-27 11:12:51.000000000 -0600
@@ -23,6 +23,8 @@
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
=20
+extern void unmap_all_pages(struct mm_struct *mm);
+
 /*
  * WARNING: the debugging will use recursive algorithms so never enable =
this
  * unless you know what you are doing.
@@ -1006,69 +1008,6 @@
 }
 #endif
=20
-/*
- * Try to free as many page directory entries as we can,
- * without having to work very hard at actually scanning
- * the page tables themselves.
- *
- * Right now we try to free page tables if we have a nice
- * PGDIR-aligned area that got free'd up. We could be more
- * granular if we want to, but this is fast and simple,
- * and covers the bad cases.
- *
- * "prev", if it exists, points to a vma before the one
- * we just free'd - but there's no telling how much before.
- */
-static void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct =
*prev,
-	unsigned long start, unsigned long end)
-{
-	unsigned long first =3D start & PGDIR_MASK;
-	unsigned long last =3D end + PGDIR_SIZE - 1;
-	unsigned long start_index, end_index;
-	struct mm_struct *mm =3D tlb->mm;
-
-	if (!prev) {
-		prev =3D mm->mmap;
-		if (!prev)
-			goto no_mmaps;
-		if (prev->vm_end > start) {
-			if (last > prev->vm_start)
-				last =3D prev->vm_start;
-			goto no_mmaps;
-		}
-	}
-	for (;;) {
-		struct vm_area_struct *next =3D prev->vm_next;
-
-		if (next) {
-			if (next->vm_start < start) {
-				prev =3D next;
-				continue;
-			}
-			if (last > next->vm_start)
-				last =3D next->vm_start;
-		}
-		if (prev->vm_end > first)
-			first =3D prev->vm_end + PGDIR_SIZE - 1;
-		break;
-	}
-no_mmaps:
-	if (last < first)	/* for arches with discontiguous pgd indices */
-		return;
-	/*
-	 * If the PGD bits are not consecutive in the virtual address, the
-	 * old method of shifting the VA >> by PGDIR_SHIFT doesn't work.
-	 */
-	start_index =3D pgd_index(first);
-	if (start_index < FIRST_USER_PGD_NR)
-		start_index =3D FIRST_USER_PGD_NR;
-	end_index =3D pgd_index(last);
-	if (end_index > start_index) {
-		clear_page_tables(tlb, start_index, end_index - start_index);
-		flush_tlb_pgtables(mm, first & PGDIR_MASK, last & PGDIR_MASK);
-	}
-}
-
 /* Normal function to fix up a mapping
  * This function is the default for when an area has no specific
  * function.  This may be used as part of a more specific routine.
@@ -1134,7 +1073,6 @@
 	tlb =3D tlb_gather_mmu(mm, 0);
 	unmap_vmas(&tlb, mm, vma, start, end, &nr_accounted);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(tlb, prev, start, end);
 	tlb_finish_mmu(tlb, start, end);
 }
=20
@@ -1382,25 +1320,16 @@
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
-	struct mmu_gather *tlb;
 	struct vm_area_struct *vma;
-	unsigned long nr_accounted =3D 0;
=20
 	profile_exit_mmap(mm);
 =20
 	lru_add_drain();
=20
-	spin_lock(&mm->page_table_lock);
-
-	tlb =3D tlb_gather_mmu(mm, 1);
 	flush_cache_mm(mm);
-	/* Use ~0UL here to ensure all VMAs in the mm are unmapped */
-	mm->map_count -=3D unmap_vmas(&tlb, mm, mm->mmap, 0,
-					~0UL, &nr_accounted);
-	vm_unacct_memory(nr_accounted);
-	BUG_ON(mm->map_count);	/* This is just debugging */
-	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
-	tlb_finish_mmu(tlb, 0, TASK_SIZE);
+	unmap_all_pages(mm);
+
+  	BUG_ON(mm->map_count);	/* This is just debugging */
=20
 	vma =3D mm->mmap;
 	mm->mmap =3D mm->mmap_cache =3D NULL;
@@ -1409,14 +1338,20 @@
 	mm->total_vm =3D 0;
 	mm->locked_vm =3D 0;
=20
-	spin_unlock(&mm->page_table_lock);
-
 	/*
 	 * Walk the list again, actually closing and freeing it
 	 * without holding any MM locks.
 	 */
 	while (vma) {
 		struct vm_area_struct *next =3D vma->vm_next;
+
+		/*
+		 * If the VMA has been charged for, account for its
+		 * removal
+		 */
+		if (vma->vm_flags & VM_ACCOUNT)
+			vm_unacct_memory((vma->vm_end - vma->vm_start) >> PAGE_SHIFT);
+
 		remove_shared_vm_struct(vma);
 		if (vma->vm_ops) {
 			if (vma->vm_ops->close)
--- 2.5.59-mm6/./mm/rmap.c	2003-01-16 20:22:43.000000000 -0600
+++ 2.5.59-mm6-test/./mm/rmap.c	2003-01-28 10:54:31.000000000 -0600
@@ -328,6 +328,7 @@
 static int try_to_unmap_one(struct page * page, pte_addr_t paddr)
 {
 	pte_t *ptep =3D rmap_ptep_map(paddr);
+	struct ptpage *ptpage =3D (struct ptpage *)kmap_atomic_to_page((void =
*)ptep);
 	unsigned long address =3D ptep_to_address(ptep);
 	struct mm_struct * mm =3D ptep_to_mm(ptep);
 	struct vm_area_struct * vma;
@@ -338,6 +339,15 @@
 		BUG();
=20
 	/*
+	 * If this mm is in the process of exiting, skip this page
+	 * for now to let the exit finish.
+	 */
+	if (atomic_read(&mm->mm_users) =3D=3D 0) {
+		rmap_ptep_unmap(ptep);
+		return SWAP_AGAIN;
+	}
+
+	/*
 	 * We need the page_table_lock to protect us from page faults,
 	 * munmap, fork, etc...
 	 */
@@ -364,19 +374,20 @@
 	flush_cache_page(vma, address);
 	pte =3D ptep_get_and_clear(ptep);
 	flush_tlb_page(vma, address);
+	decrement_rss(ptpage);
=20
 	/* Store the swap location in the pte. See handle_pte_fault() ... */
 	if (PageSwapCache(page)) {
 		swp_entry_t entry =3D { .val =3D page->index };
 		swap_duplicate(entry);
 		set_pte(ptep, swp_entry_to_pte(entry));
+		increment_swapcount(ptpage);
 	}
=20
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pte))
 		set_page_dirty(page);
=20
-	mm->rss--;
 	page_cache_release(page);
 	ret =3D SWAP_SUCCESS;
=20

--==========1869179384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
