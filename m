Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA08925
	for <linux-mm@kvack.org>; Fri, 27 Dec 2002 16:03:17 -0800 (PST)
Message-ID: <3E0CEA3F.35B3044@digeo.com>
Date: Fri, 27 Dec 2002 16:03:11 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: handling pte_chain_alloc() failures
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've been gnawing this bone for six months, finally did a patch.

The way I handled it was to require that the caller provide a fresh
pte_chain to page_add_rmap().   I'm hardly ecstatic with this, but
the overhead is low - maybe 20 additional instructions in the pagefault
path.

I tried schemes which were based on page reservation, and a scheme
based on guaranteed reservations via the slab head arrays.  None of
them worked, for various reasons.  copy_page_range() wants to allocate
up to 128 kbytes atomically, else it oopses.  That's a lot of per-cpu
reserved memory.  And pte_alloc_map() and friends can sleep, so I
cannot hold a reservation across that which screwed everything up.

Anyway.  This passes heavy testing without shpte, light testing with.

Because this stuff just stomps all over the shpte patch what I
have done is to make the following changes to 2.5.53-mm1:

+ copy_page_range-cleanup.patch

  Small stuff, partly to make shpte patching easier.

+ pte_chain_alloc-fix.patch

  This is the "mechanism"

+ page_add_rmap-rework.patch

  This converts all the 2.5.x page_add_rmap() callers to use the
  new scheme.  (apart from swapoff.  It will still oops if pte_chain_alloc()
  fails)

shpte-ng.patch

  This has been _modified_ to use the new scheme.   Note that mm_chain_alloc()
  needs similar treatment.  Later.

The above change presentation makes the changes hard to review, so the below
patch is a diff from 2.5.53-mm1 to 2.5.53-mm1 with all the above changes.
I'll do an mm2 later today after a bit more testng.

Dave, could I ask you to check the locking changes carefully?  Some
of them are fairly nasty.  Thanks.



--- 2553-mm1/fs/exec.c	Fri Dec 27 13:39:48 2002
+++ 25/fs/exec.c	Fri Dec 27 14:12:57 2002
@@ -45,6 +45,7 @@
 #include <linux/ptrace.h>
 #include <linux/mount.h>
 #include <linux/security.h>
+#include <linux/rmap-locking.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
@@ -294,12 +295,13 @@
 	pgd_t * pgd;
 	pmd_t * pmd;
 	pte_t * pte;
+	struct pte_chain *pte_chain;
 
 	if (page_count(page) != 1)
 		printk(KERN_ERR "mem_map disagrees with %p at %08lx\n", page, address);
 
 	pgd = pgd_offset(tsk->mm, address);
-
+	pte_chain = pte_chain_alloc(GFP_KERNEL);
 	spin_lock(&tsk->mm->page_table_lock);
 	pmd = pmd_alloc(tsk->mm, pgd, address);
 	if (!pmd)
@@ -315,17 +317,19 @@
 	flush_dcache_page(page);
 	flush_page_to_ram(page);
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(page, PAGE_COPY))));
-	page_add_rmap(page, pte);
-	increment_rss(kmap_atomic_to_page(pte));
+	pte_chain = page_add_rmap(page, pte, pte_chain);
 	pte_unmap(pte);
+	increment_rss(kmap_atomic_to_page(pte));
 	spin_unlock(&tsk->mm->page_table_lock);
 
 	/* no need for flush_tlb */
+	pte_chain_free(pte_chain);
 	return;
 out:
 	spin_unlock(&tsk->mm->page_table_lock);
 	__free_page(page);
 	force_sig(SIGKILL, tsk);
+	pte_chain_free(pte_chain);
 	return;
 }
 
--- 2553-mm1/include/linux/rmap-locking.h	Fri Dec 27 13:39:48 2002
+++ 25/include/linux/rmap-locking.h	Fri Dec 27 14:12:57 2002
@@ -5,6 +5,11 @@
  * pte chain.
  */
 
+#include <linux/slab.h>
+
+struct pte_chain;
+extern kmem_cache_t *pte_chain_cache;
+
 static inline void pte_chain_lock(struct page *page)
 {
 	/*
@@ -43,3 +48,12 @@
 #endif
 	preempt_enable();
 }
+
+struct pte_chain *pte_chain_alloc(int gfp_flags);
+void __pte_chain_free(struct pte_chain *pte_chain);
+
+static inline void pte_chain_free(struct pte_chain *pte_chain)
+{
+	if (pte_chain)
+		__pte_chain_free(pte_chain);
+}
--- 2553-mm1/mm/fremap.c	Fri Dec 27 13:39:48 2002
+++ 25/mm/fremap.c	Fri Dec 27 14:12:57 2002
@@ -13,12 +13,12 @@
 #include <linux/swapops.h>
 #include <linux/rmap-locking.h>
 #include <linux/ptshare.h>
-
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static inline void zap_pte(struct mm_struct *mm, struct page *ptepage, pte_t *ptep)
+static inline void
+zap_pte(struct mm_struct *mm, struct page *ptepage, pte_t *ptep)
 {
 	pte_t pte = *ptep;
 
@@ -57,6 +57,7 @@
 	pte_t *pte, entry;
 	pgd_t *pgd;
 	pmd_t *pmd;
+	struct pte_chain *pte_chain = NULL;
 
 	spin_lock(&mm->page_table_lock);
 	pgd = pgd_offset(mm, addr);
@@ -65,14 +66,13 @@
 	if (!pmd)
 		goto err_unlock;
 
+	pte_chain = pte_chain_alloc(GFP_KERNEL);
 	pte = pte_alloc_unshare(mm, pmd, addr);
 	if (!pte)
 		goto err_unlock;
 
 	ptepage = pmd_page(*pmd);
-
 	zap_pte(mm, ptepage, pte);
-
 	increment_rss(ptepage);
 	flush_page_to_ram(page);
 	flush_icache_page(vma, page);
@@ -80,17 +80,18 @@
 	if (prot & PROT_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 	set_pte(pte, entry);
-	page_add_rmap(page, pte);
+	pte_chain = page_add_rmap(page, pte, pte_chain);
 	pte_unmap(pte);
 	flush_tlb_page(vma, addr);
 
 	pte_page_unlock(ptepage);
 	spin_unlock(&mm->page_table_lock);
-
+	pte_chain_free(pte_chain);
 	return 0;
 
 err_unlock:
 	spin_unlock(&mm->page_table_lock);
+	pte_chain_free(pte_chain);
 	return err;
 }
 
--- 2553-mm1/mm/memory.c	Fri Dec 27 13:39:48 2002
+++ 25/mm/memory.c	Fri Dec 27 14:12:57 2002
@@ -236,6 +236,7 @@
 	unsigned long address = vma->vm_start;
 	unsigned long end = vma->vm_end;
 	unsigned long cow;
+	struct pte_chain *pte_chain = NULL;
 
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst, src, vma);
@@ -285,6 +286,14 @@
 				goto cont_copy_pmd_range;
 			}
 
+			if (pte_chain == NULL) {
+				spin_unlock(&dst->page_table_lock);
+				pte_chain = pte_chain_alloc(GFP_KERNEL);
+				if (!pte_chain)
+					goto nomem;
+				spin_lock(&dst->page_table_lock);
+			}
+	
 			dst_pte = pte_alloc_map(dst, dst_pmd, address);
 			if (!dst_pte)
 				goto nomem;
@@ -292,7 +301,7 @@
 			ptepage = pmd_page(*src_pmd);
 			pte_page_lock(ptepage);
 			src_pte = pte_offset_map_nested(src_pmd, address);
-			do {
+			for ( ; ; ) {
 				pte_t pte = *src_pte;
 				struct page *page;
 				unsigned long pfn;
@@ -335,7 +344,8 @@
 
 cont_copy_pte_range:
 				set_pte(dst_pte, pte);
-				page_add_rmap(page, dst_pte);
+				pte_chain = page_add_rmap(page, dst_pte,
+							pte_chain);
 cont_copy_pte_range_noset:
 				address += PAGE_SIZE;
 				if (address >= end) {
@@ -346,7 +356,33 @@
 				}
 				src_pte++;
 				dst_pte++;
-			} while ((unsigned long)src_pte & PTE_TABLE_MASK);
+				if (!((unsigned long)src_pte & PTE_TABLE_MASK))
+					break;
+				if (!pte_chain) {
+					pte_chain = pte_chain_alloc(GFP_ATOMIC);
+					if (pte_chain)
+						continue;
+				}
+
+				/*
+				 * pte_chain allocation failed, and we need to
+				 * run page reclaim.
+				 */
+				pte_page_unlock(ptepage);
+				pte_unmap_nested(src_pte);
+				pte_unmap(dst_pte);
+				spin_unlock(&src->page_table_lock);	
+				spin_unlock(&dst->page_table_lock);	
+				pte_chain = pte_chain_alloc(GFP_KERNEL);
+				if (!pte_chain)
+					goto nomem;
+				spin_lock(&dst->page_table_lock);	
+				spin_lock(&src->page_table_lock);	
+				pte_page_lock(ptepage);
+				dst_pte = pte_offset_map(dst_pmd, address);
+				src_pte = pte_offset_map_nested(src_pmd,
+								address);
+			}
 			pte_page_unlock(ptepage);
 			pte_unmap_nested(src_pte-1);
 			pte_unmap(dst_pte-1);
@@ -360,13 +396,16 @@
 out_unlock:
 	spin_unlock(&src->page_table_lock);
 out:
+	pte_chain_free(pte_chain);
 	return 0;
 nomem:
+	pte_chain_free(pte_chain);
 	return -ENOMEM;
 }
 #endif
 
-static void zap_pte_range(mmu_gather_t *tlb, pmd_t * pmd, unsigned long address, unsigned long size)
+static void
+zap_pte_range(mmu_gather_t *tlb, pmd_t * pmd, unsigned long address, unsigned long size)
 {
 	unsigned long offset;
 	struct page *ptepage = pmd_page(*pmd);
@@ -982,6 +1021,7 @@
 	struct page *old_page, *new_page;
 	struct page *ptepage = pmd_page(*pmd);
 	unsigned long pfn = pte_pfn(pte);
+	struct pte_chain *pte_chain = NULL;
 
 	if (!pfn_valid(pfn))
 		goto bad_wp_page;
@@ -1010,6 +1050,7 @@
 	if (!new_page)
 		goto no_mem;
 	copy_cow_page(old_page,new_page,address);
+	pte_chain = pte_chain_alloc(GFP_KERNEL);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -1022,7 +1063,7 @@
 			increment_rss(ptepage);
 		page_remove_rmap(old_page, page_table);
 		break_cow(vma, new_page, address, page_table);
-		page_add_rmap(new_page, page_table);
+		pte_chain = page_add_rmap(new_page, page_table, pte_chain);
 		lru_cache_add_active(new_page);
 
 		/* Free the old page.. */
@@ -1032,6 +1073,7 @@
 	pte_page_unlock(ptepage);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
+	pte_chain_free(pte_chain);
 	return VM_FAULT_MINOR;
 
 bad_wp_page:
@@ -1170,6 +1212,7 @@
 	swp_entry_t entry = pte_to_swp_entry(orig_pte);
 	pte_t pte;
 	int ret = VM_FAULT_MINOR;
+	struct pte_chain *pte_chain = NULL;
 
 	pte_unmap(page_table);
 	pte_page_unlock(ptepage);
@@ -1200,6 +1243,11 @@
 	}
 
 	mark_page_accessed(page);
+	pte_chain = pte_chain_alloc(GFP_KERNEL);
+	if (!pte_chain) {
+		ret = -ENOMEM;
+		goto out;
+	}
 	lock_page(page);
 
 	/*
@@ -1233,13 +1281,14 @@
 	flush_page_to_ram(page);
 	flush_icache_page(vma, page);
 	set_pte(page_table, pte);
-	page_add_rmap(page, page_table);
+	pte_chain = page_add_rmap(page, page_table, pte_chain);
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
 	pte_unmap(page_table);
 	pte_page_unlock(ptepage);
 out:
+	pte_chain_free(pte_chain);
 	return ret;
 }
 
@@ -1248,12 +1297,28 @@
  * spinlock held to protect against concurrent faults in
  * multithreaded programs. 
  */
-static int do_anonymous_page(struct mm_struct * mm, struct vm_area_struct * vma, pte_t *page_table, pmd_t *pmd, int write_access, unsigned long addr)
+static int
+do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		pte_t *page_table, pmd_t *pmd, int write_access,
+		unsigned long addr)
 {
 	pte_t entry;
 	struct page * page = ZERO_PAGE(addr);
 	struct page *ptepage = pmd_page(*pmd);
+	struct pte_chain *pte_chain;
+	int ret;
 
+	pte_chain = pte_chain_alloc(GFP_ATOMIC);
+	if (!pte_chain) {
+		pte_unmap(page_table);
+		pte_page_unlock(ptepage);
+		pte_chain = pte_chain_alloc(GFP_KERNEL);
+		if (!pte_chain)
+			goto no_mem;
+		pte_page_lock(ptepage);
+		page_table = pte_offset_map(pmd, addr);
+	}
+		
 	/* Read-only mapping of ZERO_PAGE. */
 	entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
 
@@ -1276,7 +1341,8 @@
 			pte_unmap(page_table);
 			page_cache_release(page);
 			pte_page_unlock(ptepage);
-			return VM_FAULT_MINOR;
+			ret = VM_FAULT_MINOR;
+			goto out;
 		}
 		increment_rss(ptepage);
 		flush_page_to_ram(page);
@@ -1286,16 +1352,21 @@
 	}
 
 	set_pte(page_table, entry);
-	page_add_rmap(page, page_table); /* ignores ZERO_PAGE */
+	/* ignores ZERO_PAGE */
+	pte_chain = page_add_rmap(page, page_table, pte_chain);
 	pte_unmap(page_table);
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, entry);
 	pte_page_unlock(ptepage);
-	return VM_FAULT_MINOR;
+	ret = VM_FAULT_MINOR;
+	goto out;
 
 no_mem:
-	return VM_FAULT_OOM;
+	ret = VM_FAULT_OOM;
+out:
+	pte_chain_free(pte_chain);
+	return ret;
 }
 
 /*
@@ -1310,15 +1381,18 @@
  * This is called with the MM semaphore held and the page table
  * spinlock held. Exit with the spinlock released.
  */
-static int do_no_page(struct mm_struct * mm, struct vm_area_struct * vma,
+static int
+do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long address, int write_access, pte_t *page_table, pmd_t *pmd)
 {
 	struct page * new_page;
 	struct page *ptepage = pmd_page(*pmd);
 	pte_t entry;
+	struct pte_chain *pte_chain;
 
 	if (!vma->vm_ops || !vma->vm_ops->nopage)
-		return do_anonymous_page(mm, vma, page_table, pmd, write_access, address);
+		return do_anonymous_page(mm, vma, page_table,
+					pmd, write_access, address);
 	pte_unmap(page_table);
 	pte_page_unlock(ptepage);
 
@@ -1345,6 +1419,7 @@
 		new_page = page;
 	}
 
+	pte_chain = pte_chain_alloc(GFP_KERNEL);
 	ptepage = pmd_page(*pmd);
 	pte_page_lock(ptepage);
 	page_table = pte_offset_map(pmd, address);
@@ -1368,19 +1443,21 @@
 		if (write_access)
 			entry = pte_mkwrite(pte_mkdirty(entry));
 		set_pte(page_table, entry);
-		page_add_rmap(new_page, page_table);
+		pte_chain = page_add_rmap(new_page, page_table, pte_chain);
 		pte_unmap(page_table);
 	} else {
 		/* One of our sibling threads was faster, back out. */
 		pte_unmap(page_table);
 		page_cache_release(new_page);
 		pte_page_unlock(ptepage);
+		pte_chain_free(pte_chain);
 		return VM_FAULT_MINOR;
 	}
 
 	/* no need to invalidate: a not-present page shouldn't be cached */
 	update_mmu_cache(vma, address, entry);
 	pte_page_unlock(ptepage);
+	pte_chain_free(pte_chain);
 	return VM_FAULT_MAJOR;
 }
 
--- 2553-mm1/mm/mremap.c	Fri Dec 27 13:39:48 2002
+++ 25/mm/mremap.c	Fri Dec 27 14:12:57 2002
@@ -23,7 +23,9 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static int move_one_page(struct vm_area_struct *vma, unsigned long old_addr, unsigned long new_addr)
+static int
+move_one_page(struct vm_area_struct *vma, unsigned long old_addr,
+		unsigned long new_addr, struct pte_chain **pte_chainp)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int error = 0;
@@ -70,7 +72,7 @@
 		if (pte_present(pte)) {
 			struct page *page = pte_page(pte);
 			page_remove_rmap(page, src_pte);
-			page_add_rmap(page, dst_pte);
+			*pte_chainp = page_add_rmap(page, dst_pte, *pte_chainp);
 		}
 	}
 	pte_unmap_nested(src_pte);
@@ -89,6 +91,7 @@
 	unsigned long new_addr, unsigned long old_addr, unsigned long len)
 {
 	unsigned long offset = len;
+	struct pte_chain *pte_chain = NULL;
 
 	flush_cache_range(vma, old_addr, old_addr + len);
 
@@ -98,10 +101,20 @@
 	 * only a few pages.. This also makes error recovery easier.
 	 */
 	while (offset) {
+		if (!pte_chain) {
+			pte_chain = pte_chain_alloc(GFP_ATOMIC);
+			if (!pte_chain) {
+				spin_unlock(&vma->vm_mm->page_table_lock);
+				pte_chain = pte_chain_alloc(GFP_KERNEL);
+				spin_lock(&vma->vm_mm->page_table_lock);
+			}
+		}
 		offset -= PAGE_SIZE;
-		if (move_one_page(vma, old_addr + offset, new_addr + offset))
+		if (move_one_page(vma, old_addr + offset,
+				new_addr + offset, &pte_chain))
 			goto oops_we_failed;
 	}
+	pte_chain_free(pte_chain);
 	return 0;
 
 	/*
@@ -113,8 +126,16 @@
 	 */
 oops_we_failed:
 	flush_cache_range(vma, new_addr, new_addr + len);
-	while ((offset += PAGE_SIZE) < len)
-		move_one_page(vma, new_addr + offset, old_addr + offset);
+	while ((offset += PAGE_SIZE) < len) {
+		if (!pte_chain) {
+			spin_unlock(&vma->vm_mm->page_table_lock);
+			pte_chain = pte_chain_alloc(GFP_KERNEL);
+			spin_lock(&vma->vm_mm->page_table_lock);
+		}
+		move_one_page(vma, new_addr + offset,
+				old_addr + offset, &pte_chain);
+	}
+	pte_chain_free(pte_chain);
 	zap_page_range(vma, new_addr, len);
 	return -1;
 }
--- 2553-mm1/mm/rmap.c	Fri Dec 27 13:39:48 2002
+++ 25/mm/rmap.c	Fri Dec 27 14:12:57 2002
@@ -28,6 +28,7 @@
 #include <linux/rmap-locking.h>
 #include <linux/ptshare.h>
 #include <linux/cache.h>
+#include <linux/percpu.h>
 
 #include <asm/pgalloc.h>
 #include <asm/rmap.h>
@@ -57,8 +58,8 @@
 	pte_addr_t ptes[NRPTE];
 } ____cacheline_aligned;
 
-static kmem_cache_t	*mm_chain_cache;
-static kmem_cache_t	*pte_chain_cache;
+kmem_cache_t	*mm_chain_cache;
+kmem_cache_t	*pte_chain_cache;
 
 /*
  * pte_chain list management policy:
@@ -78,37 +79,8 @@
  */
 
 /**
- * pte_chain_alloc - allocate a pte_chain struct
- *
- * Returns a pointer to a fresh pte_chain structure. Allocates new
- * pte_chain structures as required.
- * Caller needs to hold the page's pte_chain_lock.
- */
-static inline struct pte_chain *pte_chain_alloc(void)
-{
-	struct pte_chain *ret;
-
-	ret = kmem_cache_alloc(pte_chain_cache, GFP_ATOMIC);
-#ifdef DEBUG_RMAP
-	{
-		int i;
-		for (i = 0; i < NRPTE; i++)
-			BUG_ON(ret->ptes[i]);
-		BUG_ON(ret->next);
-	}
-#endif
-	return ret;
-}
-
-/**
- * pte_chain_free - free pte_chain structure
- * @pte_chain: pte_chain struct to free
- */
-static inline void pte_chain_free(struct pte_chain *pte_chain)
-{
-	pte_chain->next = NULL;
-	kmem_cache_free(pte_chain_cache, pte_chain);
-}
+ ** VM stuff below this comment
+ **/
 
 static inline struct mm_chain *mm_chain_alloc(void)
 {
@@ -130,10 +102,6 @@
 }
 
 /**
- ** VM stuff below this comment
- **/
-
-/**
  * page_referenced - test if the page was referenced
  * @page: the page to test
  *
@@ -182,7 +150,7 @@
 			page->pte.direct = pc->ptes[NRPTE-1];
 			SetPageDirect(page);
 			pc->ptes[NRPTE-1] = 0;
-			pte_chain_free(pc);
+			__pte_chain_free(pc);
 		}
 	}
 	return referenced;
@@ -323,10 +291,11 @@
  * Add a new pte reverse mapping to a page.
  * The caller needs to hold the pte_page_lock.
  */
-void page_add_rmap(struct page * page, pte_t * ptep)
+struct pte_chain *
+page_add_rmap(struct page *page, pte_t *ptep, struct pte_chain *pte_chain)
 {
 	pte_addr_t pte_paddr = ptep_to_paddr(ptep);
-	struct pte_chain *pte_chain;
+	struct pte_chain *cur_pte_chain;
 	int i;
 
 #ifdef DEBUG_RMAP
@@ -338,7 +307,7 @@
 #endif
 
 	if (!pfn_valid(page_to_pfn(page)) || PageReserved(page))
-		return;
+		return pte_chain;
 
 	pte_chain_lock(page);
 
@@ -377,30 +346,28 @@
 	if (PageDirect(page)) {
 		/* Convert a direct pointer into a pte_chain */
 		ClearPageDirect(page);
-		pte_chain = pte_chain_alloc();
 		pte_chain->ptes[NRPTE-1] = page->pte.direct;
 		pte_chain->ptes[NRPTE-2] = pte_paddr;
 		page->pte.direct = 0;
 		page->pte.chain = pte_chain;
+		pte_chain = NULL;	/* We consumed it */
 		goto out;
 	}
 
-	pte_chain = page->pte.chain;
-	if (pte_chain->ptes[0]) {	/* It's full */
-		struct pte_chain *new;
-
-		new = pte_chain_alloc();
-		new->next = pte_chain;
-		page->pte.chain = new;
-		new->ptes[NRPTE-1] = pte_paddr;
+	cur_pte_chain = page->pte.chain;
+	if (cur_pte_chain->ptes[0]) {	/* It's full */
+		pte_chain->next = cur_pte_chain;
+		page->pte.chain = pte_chain;
+		pte_chain->ptes[NRPTE-1] = pte_paddr;
+		pte_chain = NULL;	/* We consumed it */
 		goto out;
 	}
 
-	BUG_ON(!pte_chain->ptes[NRPTE-1]);
+	BUG_ON(!cur_pte_chain->ptes[NRPTE-1]);
 
 	for (i = NRPTE-2; i >= 0; i--) {
-		if (!pte_chain->ptes[i]) {
-			pte_chain->ptes[i] = pte_paddr;
+		if (!cur_pte_chain->ptes[i]) {
+			cur_pte_chain->ptes[i] = pte_paddr;
 			goto out;
 		}
 	}
@@ -408,7 +375,7 @@
 out:
 	pte_chain_unlock(page);
 	inc_page_state(nr_reverse_maps);
-	return;
+	return pte_chain;
 }
 
 /**
@@ -470,7 +437,7 @@
 				if (victim_i == NRPTE-1) {
 					/* Emptied a pte_chain */
 					page->pte.chain = start->next;
-					pte_chain_free(start);
+					__pte_chain_free(start);
 				} else {
 					/* Do singleton->PageDirect here */
 				}
@@ -759,7 +726,7 @@
 				victim_i++;
 				if (victim_i == NRPTE) {
 					page->pte.chain = start->next;
-					pte_chain_free(start);
+					__pte_chain_free(start);
 					start = page->pte.chain;
 					victim_i = 0;
 				}
@@ -795,6 +762,53 @@
 	memset(pc, 0, sizeof(*pc));
 }
 
+DEFINE_PER_CPU(struct pte_chain *, local_pte_chain) = 0;
+
+/**
+ * __pte_chain_free - free pte_chain structure
+ * @pte_chain: pte_chain struct to free
+ */
+void __pte_chain_free(struct pte_chain *pte_chain)
+{
+	int cpu = get_cpu();
+	struct pte_chain **pte_chainp;
+
+	if (pte_chain->next)
+		pte_chain->next = NULL;
+	pte_chainp = &per_cpu(local_pte_chain, cpu);
+	if (*pte_chainp == NULL)
+		*pte_chainp = pte_chain;
+	else
+		kmem_cache_free(pte_chain_cache, pte_chain);
+	put_cpu();
+}
+
+/*
+ * pte_chain_alloc(): allocate a pte_chain structure for use by page_add_rmap().
+ *
+ * The caller of page_add_rmap() must perform the allocation because
+ * page_add_rmap() is invariably called under spinlock.  Often, page_add_rmap()
+ * will not actually use the pte_chain, because there is space available in one
+ * of the existing pte_chains which are attached to the page.  So the case of
+ * allocating and then freeing a single pte_chain is specially optimised here,
+ * with a one-deep per-cpu cache.
+ */
+struct pte_chain *pte_chain_alloc(int gfp_flags)
+{
+	int cpu = get_cpu();
+	struct pte_chain *ret;
+	struct pte_chain **pte_chainp = &per_cpu(local_pte_chain, cpu);
+
+	if (*pte_chainp) {
+		ret = *pte_chainp;
+		*pte_chainp = NULL;
+	} else {
+		ret = kmem_cache_alloc(pte_chain_cache, gfp_flags);
+	}
+	put_cpu();
+	return ret;
+}
+
 void __init pte_chain_init(void)
 {
 
--- 2553-mm1/mm/swapfile.c	Fri Dec 27 13:39:48 2002
+++ 25/mm/swapfile.c	Fri Dec 27 14:12:57 2002
@@ -18,10 +18,10 @@
 #include <linux/buffer_head.h>
 #include <linux/writeback.h>
 #include <linux/proc_fs.h>
-#include <linux/rmap-locking.h>
-#include <linux/ptshare.h>
 #include <linux/seq_file.h>
 #include <linux/init.h>
+#include <linux/rmap-locking.h>
+#include <linux/ptshare.h>
 
 #include <asm/pgtable.h>
 #include <asm/rmap.h>
@@ -380,8 +380,10 @@
  * what to do if a write is requested later.
  */
 /* mmlist_lock and vma->vm_mm->page_table_lock are held */
-static inline void unuse_pte(struct vm_area_struct * vma, unsigned long address,
-	pte_t *dir, swp_entry_t entry, struct page* page, pmd_t *pmd)
+static void
+unuse_pte(struct vm_area_struct *vma, unsigned long address, pte_t *dir,
+	swp_entry_t entry, struct page *page, pmd_t *pmd,
+	struct pte_chain **pte_chainp)
 {
 	pte_t pte = *dir;
 
@@ -391,7 +393,7 @@
 		return;
 	get_page(page);
 	set_pte(dir, pte_mkold(mk_pte(page, vma->vm_page_prot)));
-	page_add_rmap(page, dir);
+	*pte_chainp = page_add_rmap(page, dir, *pte_chainp);
 	swap_free(entry);
 	increment_rss(pmd_page(*pmd));
 }
@@ -404,7 +406,9 @@
 	struct page *ptepage;
 	pte_t * pte;
 	unsigned long end;
+	struct pte_chain *pte_chain;
 
+	pte_chain = pte_chain_alloc(GFP_ATOMIC);
 	if (pmd_none(*dir))
 		return;
 	if (pmd_bad(*dir)) {
@@ -421,12 +425,16 @@
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
 	do {
-		unuse_pte(vma, offset+address-vma->vm_start, pte, entry, page, dir);
+		unuse_pte(vma, offset+address-vma->vm_start,
+				pte, entry, page, dir, &pte_chain);
 		address += PAGE_SIZE;
 		pte++;
+		if (pte_chain == NULL)
+			pte_chain = pte_chain_alloc(GFP_ATOMIC);
 	} while (address && (address < end));
 	pte_page_unlock(ptepage);
 	pte_unmap(pte - 1);
+	pte_chain_free(pte_chain);
 }
 
 /* mmlist_lock and vma->vm_mm->page_table_lock are held */
--- 2553-mm1/mm/ptshare.c	Fri Dec 27 13:39:48 2002
+++ 25/mm/ptshare.c	Fri Dec 27 14:12:57 2002
@@ -124,6 +124,7 @@
 	pte_t	*src_ptb, *dst_ptb;
 	struct page *oldpage, *newpage;
 	struct vm_area_struct *vma;
+	struct pte_chain *pte_chain = NULL;
 	int	base, addr;
 	int	end, page_end;
 	int	src_unshare;
@@ -141,9 +142,15 @@
 	pte_page_unlock(oldpage);
 	spin_unlock(&mm->page_table_lock);
 	newpage = pte_alloc_one(mm, address);
+	if (newpage)
+		pte_chain = pte_chain_alloc(GFP_KERNEL);
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!newpage))
 		return NULL;
+	if (!pte_chain) {
+		put_page(newpage);
+		return NULL;
+	}
 
 	/*
 	 * Fetch the ptepage pointer again in case it changed while
@@ -216,7 +223,26 @@
 				get_page(page);
 			}
 			set_pte(dst_pte, pte);
-			page_add_rmap(page, dst_pte);
+			pte_chain = page_add_rmap(page, dst_pte, pte_chain);
+			if (!pte_chain)
+				pte_chain = pte_chain_alloc(GFP_ATOMIC);
+			if (!pte_chain) {
+				pte_unmap_nested(src_ptb);
+				pte_unmap(dst_ptb);
+				pte_page_unlock(newpage);
+				pte_page_unlock(oldpage);
+				spin_unlock(&mm->page_table_lock);
+				pte_chain = pte_chain_alloc(GFP_KERNEL);
+				if (!pte_chain) {
+					spin_lock(&mm->page_table_lock);
+					return NULL;
+				}
+				spin_lock(&mm->page_table_lock);
+				pte_page_lock(oldpage);
+				pte_page_lock(newpage);
+				dst_ptb = pte_page_map(newpage, addr);
+				src_ptb = pte_page_map_nested(oldpage, addr);
+			}
 unshare_skip_set:
 			src_pte++;
 			dst_pte++;
@@ -257,10 +283,11 @@
 	put_page(oldpage);
 
 	pte_page_unlock(oldpage);
-
+	pte_chain_free(pte_chain);
 	return dst_ptb + __pte_offset(address);
 
 out_map:
+	pte_chain_free(pte_chain);
 	return pte_offset_map(pmd, address);
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
