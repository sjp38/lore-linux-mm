Message-Id: <200405222203.i4MM3jr12340@mail.osdl.org>
Subject: [patch 07/57] rmap 7 object-based rmap
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:03:15 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

Dave McCracken's object-based reverse mapping scheme for file pages: why
build up and tear down chains of pte pointers for file pages, when
page->mapping has i_mmap and i_mmap_shared lists of all the vmas which
might contain that page, and it appears at one deterministic position
within the vma (unless vma is nonlinear - see next patch)?

Has some drawbacks: more work to locate the ptes from page_referenced and
try_to_unmap, especially if the i_mmap lists contain a lot of vmas covering
different ranges; has to down_trylock the i_shared_sem, and hope that
doesn't fail too often.  But attractive in that it uses less lowmem, and
shifts the rmap burden away from the hot paths, to swapout.

Hybrid scheme for the moment: carry on with pte_chains for anonymous pages,
that's unchanged; but file pages keep mapcount in the pte union of struct
page, where anonymous pages keep chain pointer or direct pte address: so
page_mapped(page) works on both.

Hugh massaged it a little: distinct page_add_file_rmap entry point; list
searches check rss so as not to waste time on mms fully swapped out; check
mapcount to terminate once all ptes have been found; and a WARN_ON if
page_referenced should have but couldn't find all the ptes.


---

 25-akpm/include/asm-ia64/pgtable.h |    2 
 25-akpm/include/linux/mm.h         |    1 
 25-akpm/include/linux/rmap.h       |    1 
 25-akpm/mm/fremap.c                |   20 +-
 25-akpm/mm/memory.c                |   17 +
 25-akpm/mm/mremap.c                |    6 
 25-akpm/mm/rmap.c                  |  320 +++++++++++++++++++++++++++++++++----
 mm/filemap.c                       |    0 
 8 files changed, 322 insertions(+), 45 deletions(-)

diff -puN include/linux/mm.h~rmap-7-object-based-rmap include/linux/mm.h
--- 25/include/linux/mm.h~rmap-7-object-based-rmap	2004-05-22 14:56:22.158722888 -0700
+++ 25-akpm/include/linux/mm.h	2004-05-22 14:59:43.285147024 -0700
@@ -185,6 +185,7 @@ struct page {
 		struct pte_chain *chain;/* Reverse pte mapping pointer.
 					 * protected by PG_chainlock */
 		pte_addr_t direct;
+		unsigned int mapcount;	/* Count ptes mapped into mms */
 	} pte;
 	unsigned long private;		/* Mapping-private opaque data:
 					 * usually used for buffer_heads
diff -puN include/linux/rmap.h~rmap-7-object-based-rmap include/linux/rmap.h
--- 25/include/linux/rmap.h~rmap-7-object-based-rmap	2004-05-22 14:56:22.159722736 -0700
+++ 25-akpm/include/linux/rmap.h	2004-05-22 14:59:43.286146872 -0700
@@ -27,6 +27,7 @@ static inline void pte_chain_free(struct
 
 struct pte_chain * fastcall
 	page_add_rmap(struct page *, pte_t *, struct pte_chain *);
+void fastcall page_add_file_rmap(struct page *);
 void fastcall page_remove_rmap(struct page *, pte_t *);
 
 /*
diff -puN mm/fremap.c~rmap-7-object-based-rmap mm/fremap.c
--- 25/mm/fremap.c~rmap-7-object-based-rmap	2004-05-22 14:56:22.160722584 -0700
+++ 25-akpm/mm/fremap.c	2004-05-22 14:59:43.750076344 -0700
@@ -49,7 +49,7 @@ static inline void zap_pte(struct mm_str
 }
 
 /*
- * Install a page to a given virtual memory address, release any
+ * Install a file page to a given virtual memory address, release any
  * previously existing mapping.
  */
 int install_page(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -60,11 +60,13 @@ int install_page(struct mm_struct *mm, s
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t pte_val;
-	struct pte_chain *pte_chain;
 
-	pte_chain = pte_chain_alloc(GFP_KERNEL);
-	if (!pte_chain)
-		goto err;
+	/*
+	 * We use page_add_file_rmap below: if install_page is
+	 * ever extended to anonymous pages, this will warn us.
+	 */
+	BUG_ON(!page_mapping(page));
+
 	pgd = pgd_offset(mm, addr);
 	spin_lock(&mm->page_table_lock);
 
@@ -81,18 +83,14 @@ int install_page(struct mm_struct *mm, s
 	mm->rss++;
 	flush_icache_page(vma, page);
 	set_pte(pte, mk_pte(page, prot));
-	pte_chain = page_add_rmap(page, pte, pte_chain);
+	page_add_file_rmap(page);
 	pte_val = *pte;
 	pte_unmap(pte);
 	update_mmu_cache(vma, addr, pte_val);
-	spin_unlock(&mm->page_table_lock);
-	pte_chain_free(pte_chain);
-	return 0;
 
+	err = 0;
 err_unlock:
 	spin_unlock(&mm->page_table_lock);
-	pte_chain_free(pte_chain);
-err:
 	return err;
 }
 EXPORT_SYMBOL(install_page);
diff -puN mm/memory.c~rmap-7-object-based-rmap mm/memory.c
--- 25/mm/memory.c~rmap-7-object-based-rmap	2004-05-22 14:56:22.162722280 -0700
+++ 25-akpm/mm/memory.c	2004-05-22 14:59:43.290146264 -0700
@@ -331,8 +331,11 @@ skip_copy_pte_range:
 				dst->rss++;
 
 				set_pte(dst_pte, pte);
-				pte_chain = page_add_rmap(page, dst_pte,
-							pte_chain);
+				if (PageAnon(page))
+					pte_chain = page_add_rmap(page,
+						dst_pte, pte_chain);
+				else
+					page_add_file_rmap(page);
 				if (pte_chain)
 					goto cont_copy_pte_range_noset;
 				pte_chain = pte_chain_alloc(GFP_ATOMIC | __GFP_NOWARN);
@@ -1489,6 +1492,7 @@ do_no_page(struct mm_struct *mm, struct 
 	struct pte_chain *pte_chain;
 	int sequence = 0;
 	int ret = VM_FAULT_MINOR;
+	int anon = 0;
 
 	if (!vma->vm_ops || !vma->vm_ops->nopage)
 		return do_anonymous_page(mm, vma, page_table,
@@ -1523,8 +1527,8 @@ retry:
 			goto oom;
 		copy_user_highpage(page, new_page, address);
 		page_cache_release(new_page);
-		lru_cache_add_active(page);
 		new_page = page;
+		anon = 1;
 	}
 
 	spin_lock(&mm->page_table_lock);
@@ -1562,7 +1566,12 @@ retry:
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte(page_table, entry);
-		pte_chain = page_add_rmap(new_page, page_table, pte_chain);
+		if (anon) {
+			lru_cache_add_active(new_page);
+			pte_chain = page_add_rmap(new_page,
+						page_table, pte_chain);
+		} else
+			page_add_file_rmap(new_page);
 		pte_unmap(page_table);
 	} else {
 		/* One of our sibling threads was faster, back out. */
diff -puN mm/mremap.c~rmap-7-object-based-rmap mm/mremap.c
--- 25/mm/mremap.c~rmap-7-object-based-rmap	2004-05-22 14:56:22.163722128 -0700
+++ 25-akpm/mm/mremap.c	2004-05-22 14:59:43.291146112 -0700
@@ -90,8 +90,10 @@ copy_one_pte(struct vm_area_struct *vma,
 		unsigned long pfn = pte_pfn(pte);
 		if (pfn_valid(pfn)) {
 			struct page *page = pfn_to_page(pfn);
-			page_remove_rmap(page, src);
-			*pte_chainp = page_add_rmap(page, dst, *pte_chainp);
+			if (PageAnon(page)) {
+				page_remove_rmap(page, src);
+				*pte_chainp = page_add_rmap(page, dst, *pte_chainp);
+			}
 		}
 	}
 }
diff -puN mm/rmap.c~rmap-7-object-based-rmap mm/rmap.c
--- 25/mm/rmap.c~rmap-7-object-based-rmap	2004-05-22 14:56:22.165721824 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:43.753075888 -0700
@@ -113,6 +113,135 @@ pte_chain_encode(struct pte_chain *pte_c
  ** VM stuff below this comment
  **/
 
+/*
+ * At what user virtual address is pgoff expected in file-backed vma?
+ */
+static inline
+unsigned long vma_address(struct vm_area_struct *vma, pgoff_t pgoff)
+{
+	unsigned long address;
+
+	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+	return (address >= vma->vm_start && address < vma->vm_end)?
+		address: -EFAULT;
+}
+
+static int page_referenced_one(struct page *page,
+	struct mm_struct *mm, unsigned long address,
+	unsigned int *mapcount, int *failed)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	int referenced = 0;
+
+	if (!spin_trylock(&mm->page_table_lock)) {
+		/*
+		 * For debug we're currently warning if not all found,
+		 * but in this case that's expected: suppress warning.
+		 */
+		(*failed)++;
+		return 0;
+	}
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out_unlock;
+
+	pmd = pmd_offset(pgd, address);
+	if (!pmd_present(*pmd))
+		goto out_unlock;
+
+	pte = pte_offset_map(pmd, address);
+	if (!pte_present(*pte))
+		goto out_unmap;
+
+	if (page_to_pfn(page) != pte_pfn(*pte))
+		goto out_unmap;
+
+	if (ptep_test_and_clear_young(pte))
+		referenced++;
+
+	(*mapcount)--;
+
+out_unmap:
+	pte_unmap(pte);
+
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+	return referenced;
+}
+
+/**
+ * page_referenced_file - referenced check for object-based rmap
+ * @page: the page we're checking references on.
+ *
+ * For an object-based mapped page, find all the places it is mapped and
+ * check/clear the referenced flag.  This is done by following the page->mapping
+ * pointer, then walking the chain of vmas it holds.  It returns the number
+ * of references it found.
+ *
+ * This function is only called from page_referenced for object-based pages.
+ *
+ * The semaphore address_space->i_shared_sem is tried.  If it can't be gotten,
+ * assume a reference count of 0, so try_to_unmap will then have a go.
+ */
+static inline int page_referenced_file(struct page *page)
+{
+	unsigned int mapcount = page->pte.mapcount;
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	unsigned long address;
+	int referenced = 0;
+	int failed = 0;
+
+	if (down_trylock(&mapping->i_shared_sem))
+		return 0;
+
+	list_for_each_entry(vma, &mapping->i_mmap, shared) {
+		address = vma_address(vma, pgoff);
+		if (address == -EFAULT)
+			continue;
+		if ((vma->vm_flags & (VM_LOCKED|VM_MAYSHARE))
+				  == (VM_LOCKED|VM_MAYSHARE)) {
+			referenced++;
+			goto out;
+		}
+		if (vma->vm_mm->rss) {
+			referenced += page_referenced_one(page,
+				vma->vm_mm, address, &mapcount, &failed);
+			if (!mapcount)
+				goto out;
+		}
+	}
+
+	list_for_each_entry(vma, &mapping->i_mmap_shared, shared) {
+		if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
+			failed++;
+			continue;
+		}
+		address = vma_address(vma, pgoff);
+		if (address == -EFAULT)
+			continue;
+		if (vma->vm_flags & (VM_LOCKED|VM_RESERVED)) {
+			referenced++;
+			goto out;
+		}
+		if (vma->vm_mm->rss) {
+			referenced += page_referenced_one(page,
+				vma->vm_mm, address, &mapcount, &failed);
+			if (!mapcount)
+				goto out;
+		}
+	}
+
+	WARN_ON(!failed);
+out:
+	up(&mapping->i_shared_sem);
+	return referenced;
+}
+
 /**
  * page_referenced - test if the page was referenced
  * @page: the page to test
@@ -135,7 +264,10 @@ int fastcall page_referenced(struct page
 	if (TestClearPageReferenced(page))
 		referenced++;
 
-	if (PageDirect(page)) {
+	if (!PageAnon(page)) {
+		if (page_mapped(page) && page->mapping)
+			referenced += page_referenced_file(page);
+	} else if (PageDirect(page)) {
 		pte_t *pte = rmap_ptep_map(page->pte.direct);
 		if (ptep_test_and_clear_young(pte))
 			referenced++;
@@ -170,7 +302,7 @@ int fastcall page_referenced(struct page
 }
 
 /**
- * page_add_rmap - add reverse mapping entry to a page
+ * page_add_rmap - add reverse mapping entry to an anonymous page
  * @page: the page to add the mapping to
  * @ptep: the page table entry mapping this page
  *
@@ -191,10 +323,8 @@ page_add_rmap(struct page *page, pte_t *
 	if (page->pte.direct == 0) {
 		page->pte.direct = pte_paddr;
 		SetPageDirect(page);
-		if (!page->mapping) {
-			SetPageAnon(page);
-			page->mapping = ANON_MAPPING_DEBUG;
-		}
+		SetPageAnon(page);
+		page->mapping = ANON_MAPPING_DEBUG;
 		inc_page_state(nr_mapped);
 		goto out;
 	}
@@ -228,6 +358,25 @@ out:
 }
 
 /**
+ * page_add_file_rmap - add pte mapping to a file page
+ * @page: the page to add the mapping to
+ *
+ * The caller needs to hold the mm->page_table_lock.
+ */
+void fastcall page_add_file_rmap(struct page *page)
+{
+	BUG_ON(PageAnon(page));
+	if (!pfn_valid(page_to_pfn(page)) || PageReserved(page))
+		return;
+
+	page_map_lock(page);
+	if (!page_mapped(page))
+		inc_page_state(nr_mapped);
+	page->pte.mapcount++;
+	page_map_unlock(page);
+}
+
+/**
  * page_remove_rmap - take down reverse mapping to a page
  * @page: page to remove mapping from
  * @ptep: page table entry to remove
@@ -250,7 +399,9 @@ void fastcall page_remove_rmap(struct pa
 	if (!page_mapped(page))
 		goto out_unlock;	/* remap_page_range() from a driver? */
 
-	if (PageDirect(page)) {
+	if (!PageAnon(page)) {
+		page->pte.mapcount--;
+	} else if (PageDirect(page)) {
 		if (page->pte.direct == pte_paddr) {
 			page->pte.direct = 0;
 			ClearPageDirect(page);
@@ -298,7 +449,7 @@ out_unlock:
 }
 
 /**
- * try_to_unmap_one - worker function for try_to_unmap
+ * try_to_unmap_anon_one - worker function for try_to_unmap
  * @page: page to unmap
  * @ptep: page table entry to unmap from page
  *
@@ -310,7 +461,7 @@ out_unlock:
  *		rmap lock		shrink_list()
  *		    mm->page_table_lock	try_to_unmap_one(), trylock
  */
-static int fastcall try_to_unmap_one(struct page * page, pte_addr_t paddr)
+static int fastcall try_to_unmap_anon_one(struct page * page, pte_addr_t paddr)
 {
 	pte_t *ptep = rmap_ptep_map(paddr);
 	unsigned long address = ptep_to_address(ptep);
@@ -348,7 +499,7 @@ static int fastcall try_to_unmap_one(str
 	flush_cache_page(vma, address);
 	pte = ptep_clear_flush(vma, address, ptep);
 
-	if (PageAnon(page)) {
+	{
 		swp_entry_t entry = { .val = page->private };
 		/*
 		 * Store the swap location in the pte.
@@ -358,16 +509,6 @@ static int fastcall try_to_unmap_one(str
 		swap_duplicate(entry);
 		set_pte(ptep, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*ptep));
-	} else {
-		/*
-		 * If a nonlinear mapping then store the file page offset
-		 * in the pte.
-		 */
-		BUG_ON(!page->mapping);
-		if (page->index != linear_page_index(vma, address)) {
-			set_pte(ptep, pgoff_to_pte(page->index));
-			BUG_ON(!pte_file(*ptep));
-		}
 	}
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
@@ -384,6 +525,128 @@ out_unlock:
 	return ret;
 }
 
+static int try_to_unmap_one(struct page *page,
+	struct mm_struct *mm, unsigned long address,
+	unsigned int *mapcount, struct vm_area_struct *vma)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	pte_t pteval;
+	int ret = SWAP_AGAIN;
+
+	/*
+	 * We need the page_table_lock to protect us from page faults,
+	 * munmap, fork, etc...
+	 */
+	if (!spin_trylock(&mm->page_table_lock))
+		goto out;
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out_unlock;
+
+	pmd = pmd_offset(pgd, address);
+	if (!pmd_present(*pmd))
+		goto out_unlock;
+
+	pte = pte_offset_map(pmd, address);
+	if (!pte_present(*pte))
+		goto out_unmap;
+
+	if (page_to_pfn(page) != pte_pfn(*pte))
+		goto out_unmap;
+
+	(*mapcount)--;
+
+	/*
+	 * If the page is mlock()d, we cannot swap it out.
+	 * If it's recently referenced (perhaps page_referenced
+	 * skipped over this mm) then we should reactivate it.
+	 */
+	if ((vma->vm_flags & (VM_LOCKED|VM_RESERVED)) ||
+			ptep_test_and_clear_young(pte)) {
+		ret = SWAP_FAIL;
+		goto out_unmap;
+	}
+
+	/* Nuke the page table entry. */
+	flush_cache_page(vma, address);
+	pteval = ptep_clear_flush(vma, address, pte);
+
+	/* Move the dirty bit to the physical page now the pte is gone. */
+	if (pte_dirty(pteval))
+		set_page_dirty(page);
+
+	mm->rss--;
+	BUG_ON(!page->pte.mapcount);
+	page->pte.mapcount--;
+	page_cache_release(page);
+
+out_unmap:
+	pte_unmap(pte);
+
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+
+out:
+	return ret;
+}
+
+/**
+ * try_to_unmap_file - unmap file page using the object-based rmap method
+ * @page: the page to unmap
+ *
+ * Find all the mappings of a page using the mapping pointer and the vma chains
+ * contained in the address_space struct it points to.
+ *
+ * This function is only called from try_to_unmap for object-based pages.
+ *
+ * The semaphore address_space->i_shared_sem is tried.  If it can't be gotten,
+ * return a temporary error.
+ */
+static inline int try_to_unmap_file(struct page *page)
+{
+	unsigned int mapcount = page->pte.mapcount;
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	unsigned long address;
+	int ret = SWAP_AGAIN;
+
+	if (down_trylock(&mapping->i_shared_sem))
+		return ret;
+
+	list_for_each_entry(vma, &mapping->i_mmap, shared) {
+		if (vma->vm_mm->rss) {
+			address = vma_address(vma, pgoff);
+			if (address == -EFAULT)
+				continue;
+			ret = try_to_unmap_one(page,
+				vma->vm_mm, address, &mapcount, vma);
+			if (ret == SWAP_FAIL || !mapcount)
+				goto out;
+		}
+	}
+
+	list_for_each_entry(vma, &mapping->i_mmap_shared, shared) {
+		if (unlikely(vma->vm_flags & VM_NONLINEAR))
+			continue;
+		if (vma->vm_mm->rss) {
+			address = vma_address(vma, pgoff);
+			if (address == -EFAULT)
+				continue;
+			ret = try_to_unmap_one(page,
+				vma->vm_mm, address, &mapcount, vma);
+			if (ret == SWAP_FAIL || !mapcount)
+				goto out;
+		}
+	}
+out:
+	up(&mapping->i_shared_sem);
+	return ret;
+}
+
 /**
  * try_to_unmap - try to remove all page table mappings to a page
  * @page: the page to get unmapped
@@ -402,14 +665,17 @@ int fastcall try_to_unmap(struct page * 
 	int ret = SWAP_SUCCESS;
 	int victim_i;
 
-	/* This page should not be on the pageout lists. */
-	if (PageReserved(page))
-		BUG();
-	if (!PageLocked(page))
-		BUG();
+	BUG_ON(PageReserved(page));
+	BUG_ON(!PageLocked(page));
+	BUG_ON(!page_mapped(page));
+
+	if (!PageAnon(page)) {
+		ret = try_to_unmap_file(page);
+		goto out;
+	}
 
 	if (PageDirect(page)) {
-		ret = try_to_unmap_one(page, page->pte.direct);
+		ret = try_to_unmap_anon_one(page, page->pte.direct);
 		if (ret == SWAP_SUCCESS) {
 			page->pte.direct = 0;
 			ClearPageDirect(page);
@@ -428,7 +694,7 @@ int fastcall try_to_unmap(struct page * 
 		for (i = pte_chain_idx(pc); i < NRPTE; i++) {
 			pte_addr_t pte_paddr = pc->ptes[i];
 
-			switch (try_to_unmap_one(page, pte_paddr)) {
+			switch (try_to_unmap_anon_one(page, pte_paddr)) {
 			case SWAP_SUCCESS:
 				/*
 				 * Release a slot.  If we're releasing the
diff -puN mm/filemap.c~rmap-7-object-based-rmap mm/filemap.c
diff -puN include/asm-ia64/pgtable.h~rmap-7-object-based-rmap include/asm-ia64/pgtable.h
--- 25/include/asm-ia64/pgtable.h~rmap-7-object-based-rmap	2004-05-22 14:56:22.168721368 -0700
+++ 25-akpm/include/asm-ia64/pgtable.h	2004-05-22 14:59:42.540260264 -0700
@@ -102,7 +102,7 @@
  * can map.
  */
 #define PMD_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-3))
-#define PMD_SIZE	(__IA64_UL(1) << PMD_SHIFT)
+#define PMD_SIZE	(1UL << PMD_SHIFT)
 #define PMD_MASK	(~(PMD_SIZE-1))
 #define PTRS_PER_PMD	(__IA64_UL(1) << (PAGE_SHIFT-3))
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
