From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 14:19:35 +1000 (EST)
Subject: [PATCH 10/15] PTI: Call iterators
In-Reply-To: <Pine.LNX.4.61.0505211409350.26645@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211417450.26645@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211400351.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211409350.26645@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 10 of 15.

page_table_dual_iterator is called to abstract
 	*copy_page_range in memory.c
 	*This is the only call to this specialised
 	 iterator.

page_table_build_iterator is called to abstract
 	*zeromap_page_table in memory.c
 	*remap_pfn_range in memory.c
 	*map_vm_area in vmalloc.c.
 	*These are all the calls to this iterator.

  mm/memory.c  |  268 
++++++++++-------------------------------------------------
  mm/vmalloc.c |   70 +++------------
  2 files changed, 62 insertions(+), 276 deletions(-)

Index: linux-2.6.12-rc4/mm/vmalloc.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/vmalloc.c	2005-05-19 17:01:14.000000000 
+1000
+++ linux-2.6.12-rc4/mm/vmalloc.c	2005-05-19 18:15:26.000000000 
+1000
@@ -15,6 +15,7 @@
  #include <linux/interrupt.h>

  #include <linux/vmalloc.h>
+#include <linux/page_table.h>

  #include <asm/uaccess.h>
  #include <asm/tlbflush.h>
@@ -83,76 +84,37 @@
  	flush_tlb_kernel_range((unsigned long) area->addr, end);
  }

-static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page 
***pages)
+struct map_vm_area_struct
  {
-	pte_t *pte;
-
-	pte = pte_alloc_kernel(&init_mm, pmd, addr);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		struct page *page = **pages;
-		WARN_ON(!pte_none(*pte));
-		if (!page)
-			return -ENOMEM;
-		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
-		(*pages)++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	return 0;
-}
+	struct page ***pages;
+	pgprot_t prot;
+};

-static inline int vmap_pmd_range(pud_t *pud, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page 
***pages)
+int map_vm_range(struct mm_struct *mm, pte_t *pte, unsigned long addr, 
void *data)
  {
-	pmd_t *pmd;
-	unsigned long next;
+	struct page *page = **(((struct map_vm_area_struct 
*)data)->pages);

-	pmd = pmd_alloc(&init_mm, pud, addr);
-	if (!pmd)
+	WARN_ON(!pte_none(*pte));
+	if (!page)
  		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page 
***pages)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_alloc(&init_mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
+	set_pte_at(&init_mm, addr, pte,
+		mk_pte(page, (((struct map_vm_area_struct 
*)data)->prot)));
+	(*(((struct map_vm_area_struct *)data)->pages))++;
  	return 0;
  }

  int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page 
***pages)
  {
-	pgd_t *pgd;
-	unsigned long next;
  	unsigned long addr = (unsigned long) area->addr;
  	unsigned long end = addr + area->size - PAGE_SIZE;
  	int err;
+	struct map_vm_area_struct data;

+	data.pages = pages;
+	data.prot = prot;
  	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
  	spin_lock(&init_mm.page_table_lock);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = vmap_pud_range(pgd, addr, next, prot, pages);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
+	err = page_table_build_iterator(&init_mm, addr, end, map_vm_range, 
&data);
  	spin_unlock(&init_mm.page_table_lock);
  	flush_cache_vmap((unsigned long) area->addr, end);
  	return err;
Index: linux-2.6.12-rc4/mm/memory.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/memory.c	2005-05-19 18:04:27.000000000 
+1000
+++ linux-2.6.12-rc4/mm/memory.c	2005-05-19 18:15:26.000000000 
+1000
@@ -90,14 +90,21 @@
   * but may be dropped within p[mg]d_alloc() and pte_alloc_map().
   */

-static inline void
-copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pte_t *dst_pte, pte_t *src_pte, unsigned long vm_flags,
-		unsigned long addr)
+struct copy_page_range_struct
+{
+	unsigned long vm_flags;
+};
+
+static inline int
+copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm, pte_t 
*dst_pte,
+	pte_t *src_pte, unsigned long addr, void *data)
  {
  	pte_t pte = *src_pte;
  	struct page *page;
  	unsigned long pfn;
+	unsigned long vm_flags;
+
+	vm_flags = ((struct copy_page_range_struct *)data)->vm_flags;

  	/* pte contains position in swap or file, so copy. */
  	if (unlikely(!pte_present(pte))) {
@@ -111,7 +118,7 @@
  			}
  		}
  		set_pte_at(dst_mm, addr, dst_pte, pte);
-		return;
+		return 0;
  	}

  	pfn = pte_pfn(pte);
@@ -126,7 +133,7 @@

  	if (!page || PageReserved(page)) {
  		set_pte_at(dst_mm, addr, dst_pte, pte);
-		return;
+		return 0;
  	}

  	/*
@@ -151,116 +158,21 @@
  		inc_mm_counter(dst_mm, anon_rss);
  	set_pte_at(dst_mm, addr, dst_pte, pte);
  	page_dup_rmap(page);
-}
-
-static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct 
*src_mm,
-		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct 
*vma,
-		unsigned long addr, unsigned long end)
-{
-	pte_t *src_pte, *dst_pte;
-	unsigned long vm_flags = vma->vm_flags;
-	int progress;
-
-again:
-	dst_pte = pte_alloc_map(dst_mm, dst_pmd, addr);
-	if (!dst_pte)
-		return -ENOMEM;
-	src_pte = pte_offset_map_nested(src_pmd, addr);
-
-	progress = 0;
-	spin_lock(&src_mm->page_table_lock);
-	do {
-		/*
-		 * We are holding two locks at this point - either of them
-		 * could generate latencies in another task on another 
CPU.
-		 */
-		if (progress >= 32 && (need_resched() ||
-		    need_lockbreak(&src_mm->page_table_lock) ||
-		    need_lockbreak(&dst_mm->page_table_lock)))
-			break;
-		if (pte_none(*src_pte)) {
-			progress++;
-			continue;
-		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vm_flags, 
addr);
-		progress += 8;
-	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
-	spin_unlock(&src_mm->page_table_lock);
-
-	pte_unmap_nested(src_pte - 1);
-	pte_unmap(dst_pte - 1);
-	cond_resched_lock(&dst_mm->page_table_lock);
-	if (addr != end)
-		goto again;
-	return 0;
-}
-
-static inline int copy_pmd_range(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
-		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct 
*vma,
-		unsigned long addr, unsigned long end)
-{
-	pmd_t *src_pmd, *dst_pmd;
-	unsigned long next;
-
-	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr);
-	if (!dst_pmd)
-		return -ENOMEM;
-	src_pmd = pmd_offset(src_pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(src_pmd))
-			continue;
-		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int copy_pud_range(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
-		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct 
*vma,
-		unsigned long addr, unsigned long end)
-{
-	pud_t *src_pud, *dst_pud;
-	unsigned long next;
-
-	dst_pud = pud_alloc(dst_mm, dst_pgd, addr);
-	if (!dst_pud)
-		return -ENOMEM;
-	src_pud = pud_offset(src_pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(src_pud))
-			continue;
-		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pud++, src_pud++, addr = next, addr != end);
  	return 0;
  }

  int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
  		struct vm_area_struct *vma)
  {
-	pgd_t *src_pgd, *dst_pgd;
-	unsigned long next;
  	unsigned long addr = vma->vm_start;
  	unsigned long end = vma->vm_end;
+	int err;
+	struct copy_page_range_struct data;

-	if (is_vm_hugetlb_page(vma))
-		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
+	data.vm_flags = vma->vm_flags;

-	dst_pgd = pgd_offset(dst_mm, addr);
-	src_pgd = pgd_offset(src_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(src_pgd))
-			continue;
-		if (copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
-	return 0;
+	err = page_table_dual_iterator(dst_mm, src_mm, addr, end, 
copy_one_pte, &data);
+	return err;
  }

  static void zap_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
@@ -718,76 +630,33 @@

  EXPORT_SYMBOL(get_user_pages);

-static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end, pgprot_t 
prot)
+struct zeromap_struct
  {
-	pte_t *pte;
+	pgprot_t prot;
+};

-	pte = pte_alloc_map(mm, pmd, addr);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		pte_t zero_pte = pte_wrprotect(mk_pte(ZERO_PAGE(addr), 
prot));
-		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, addr, pte, zero_pte);
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
-	return 0;
-}
-
-static inline int zeromap_pmd_range(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end, pgprot_t 
prot)
+int zero_range(struct mm_struct *mm, pte_t *pte, unsigned long addr, void 
*data)
  {
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (zeromap_pte_range(mm, pmd, addr, next, prot))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int zeromap_pud_range(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end, pgprot_t 
prot)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (zeromap_pmd_range(mm, pud, addr, next, prot))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
+	pte_t zero_pte = pte_wrprotect(mk_pte(ZERO_PAGE(addr),
+		((struct zeromap_struct *)data)->prot));
+	BUG_ON(!pte_none(*pte));
+	set_pte_at(mm, addr, pte, zero_pte);
  	return 0;
  }

  int zeromap_page_range(struct vm_area_struct *vma,
  			unsigned long addr, unsigned long size, pgprot_t 
prot)
  {
-	pgd_t *pgd;
-	unsigned long next;
  	unsigned long end = addr + size;
  	struct mm_struct *mm = vma->vm_mm;
  	int err;
+	struct zeromap_struct data;

+	data.prot = prot;
  	BUG_ON(addr >= end);
-	pgd = pgd_offset(mm, addr);
  	flush_cache_range(vma, addr, end);
  	spin_lock(&mm->page_table_lock);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = zeromap_pud_range(mm, pgd, addr, next, prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
+	err = page_table_build_iterator(mm, addr, end, zero_range, &data);
  	spin_unlock(&mm->page_table_lock);
  	return err;
  }
@@ -797,74 +666,32 @@
   * mappings are removed. any references to nonexistent pages results
   * in null mappings (currently treated as "copy-on-access")
   */
-static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
-{
-	pte_t *pte;

-	pte = pte_alloc_map(mm, pmd, addr);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		BUG_ON(!pte_none(*pte));
-		if (!pfn_valid(pfn) || PageReserved(pfn_to_page(pfn)))
-			set_pte_at(mm, addr, pte, pfn_pte(pfn, prot));
-		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
-	return 0;
-}
-
-static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+struct remap_pfn_struct
  {
-	pmd_t *pmd;
-	unsigned long next;
-
-	pfn -= addr >> PAGE_SHIFT;
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (remap_pte_range(mm, pmd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
+	unsigned long pfn;
+	pgprot_t prot;
+};

-static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+int remap_pfn_one(struct mm_struct *mm, pte_t *pte, unsigned long 
address, void *data)
  {
-	pud_t *pud;
-	unsigned long next;
+	unsigned long pfn = ((struct remap_pfn_struct *)data)->pfn;
+	pgprot_t prot = ((struct remap_pfn_struct *)data)->prot;

-	pfn -= addr >> PAGE_SHIFT;
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (remap_pmd_range(mm, pud, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
+	pfn += (address >> PAGE_SHIFT);
+	BUG_ON(!pte_none(*pte));
+	if (!pfn_valid(pfn) || PageReserved(pfn_to_page(pfn)))
+		set_pte_at(mm, address, pte, pfn_pte(pfn, prot));
  	return 0;
  }

-/*  Note: this is only safe if the mm semaphore is held when called. */
  int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
  		    unsigned long pfn, unsigned long size, pgprot_t prot)
  {
-	pgd_t *pgd;
-	unsigned long next;
  	unsigned long end = addr + size;
  	struct mm_struct *mm = vma->vm_mm;
  	int err;
+	struct remap_pfn_struct data;

  	/*
  	 * Physically remapped pages are special. Tell the
@@ -878,19 +705,16 @@

  	BUG_ON(addr >= end);
  	pfn -= addr >> PAGE_SHIFT;
-	pgd = pgd_offset(mm, addr);
+	data.pfn = pfn;
+	data.prot = prot;
+
  	flush_cache_range(vma, addr, end);
  	spin_lock(&mm->page_table_lock);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = remap_pud_range(mm, pgd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
+	err = page_table_build_iterator(mm, addr, end, remap_pfn_one, 
&data);
  	spin_unlock(&mm->page_table_lock);
  	return err;
  }
+
  EXPORT_SYMBOL(remap_pfn_range);

  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
