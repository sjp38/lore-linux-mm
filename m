Date: Wed, 4 Jul 2007 15:05:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Mike.stroya@hp.com, GOTO <y-goto@jp.fujitsu.com>, dmosberger@gmail.com, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

This is a experimental patch for fixing icache flush race of ia64(Montecito).

Problem Description:
Montecito, new ia64 processor, has separated L2 i-cache and d-cache,
and i-cache and d-cache is not consistent in automatic way.

L1 cache is also separated but L1 D-cache is write-through. Then, before
Montecito, any changes in L1-dcache is visible in L2-mixed-cache consistently.

Montecito has separated L2 cache and Mixed L3 cache. But...L2 D-cache is
*write back*. (See http://download.intel.com/design/Itanium2/manuals/
30806501.pdf section 2.3.3)

Assume : valid data is in L2 d-cache and old data in L3 mixed cache.
If write-back L2->L3 is delayed, at L2 i-cache miss cpu will fetch old data
in L3 mixed cache. 
By this, L2-icache-miss will read wrong instruction from L3-mixed cache.
(Just I think so, is this correct ?)

Anyway, there is SIGILL problem in NFS/ia64 and icache flush can fix
SIGILL problem (in our HPC team test.)

Following SIGILL issue occurs in current kernel.
(This was a discussion in this April)
- http://www.gelato.unsw.edu.au/archives/linux-ia64/0704/20323.html
Usual file systems uses DMA and it purges cache. But NFS uses copy-by-cpu.

This is HP-UX's errata comment:
- http://h50221.www5.hp.com/upassist/itrc_japan/assist2/patchdigest/PHKL_36120.html
(Sorry for Japanese page...but English comments also written. See PHKL_36120)

Now, I think icache should be flushed before set_pte().
This is a patch to try that.

1. remove all lazy_mmu_prot_update()...which is used by only ia64.
2. implements flush_cache_page()/flush_icache_page() for ia64.

Something unsure....
3. mprotect() flushes cache before removing pte. Is this sane ?
   I added flush_icache_range() before set_pte() here.

Any comments and advices ?
 
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 arch/ia64/mm/init.c           |    7 +------
 include/asm-generic/pgtable.h |    4 ----
 include/asm-ia64/cacheflush.h |   24 ++++++++++++++++++++++--
 include/asm-ia64/pgtable.h    |    9 ---------
 mm/fremap.c                   |    1 -
 mm/memory.c                   |   13 ++++++-------
 mm/migrate.c                  |    6 +++++-
 mm/mprotect.c                 |   10 +++++++++-
 mm/rmap.c                     |    1 -
 9 files changed, 43 insertions(+), 32 deletions(-)

Index: linux-2.6.22-rc7/include/asm-ia64/cacheflush.h
===================================================================
--- linux-2.6.22-rc7.orig/include/asm-ia64/cacheflush.h
+++ linux-2.6.22-rc7/include/asm-ia64/cacheflush.h
@@ -10,18 +10,38 @@
 
 #include <asm/bitops.h>
 #include <asm/page.h>
+#include <linux/mm.h>
 
 /*
  * Cache flushing routines.  This is the kind of stuff that can be very expensive, so try
  * to avoid them whenever possible.
  */
+extern void __flush_icache_page_ia64(struct page *page);
 
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_dup_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
-#define flush_icache_page(vma,page)		do { } while (0)
+
+static inline void
+flush_cache_page(struct vm_area_struct *vma, unsigned long vmaddr,
+		unsigned long pfn)
+{
+	if (vma->vm_flags & VM_EXEC) {
+		struct page *page;
+		if (!pfn_valid(pfn))
+			return;
+		page = pfn_to_page(pfn);
+		__flush_icache_page_ia64(page);
+	}
+}
+
+static inline void
+flush_icache_page(struct vm_area_struct *vma,struct page *page) {
+	if (vma->vm_flags & VM_EXEC)
+		__flush_icache_page_ia64(page);
+}
+
 #define flush_cache_vmap(start, end)		do { } while (0)
 #define flush_cache_vunmap(start, end)		do { } while (0)
 
Index: linux-2.6.22-rc7/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.22-rc7.orig/arch/ia64/mm/init.c
+++ linux-2.6.22-rc7/arch/ia64/mm/init.c
@@ -105,16 +105,11 @@ check_pgt_cache(void)
 }
 
 void
-lazy_mmu_prot_update (pte_t pte)
+__flush_icache_page_ia64 (struct page *page)
 {
 	unsigned long addr;
-	struct page *page;
 	unsigned long order;
 
-	if (!pte_exec(pte))
-		return;				/* not an executable page... */
-
-	page = pte_page(pte);
 	addr = (unsigned long) page_address(page);
 
 	if (test_bit(PG_arch_1, &page->flags))
Index: linux-2.6.22-rc7/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.22-rc7.orig/include/asm-ia64/pgtable.h
+++ linux-2.6.22-rc7/include/asm-ia64/pgtable.h
@@ -151,7 +151,6 @@
 
 #include <linux/sched.h>	/* for mm_struct */
 #include <asm/bitops.h>
-#include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
 
@@ -506,13 +505,6 @@ extern struct page *zero_page_memmap_ptr
 #define HUGETLB_PGDIR_MASK	(~(HUGETLB_PGDIR_SIZE-1))
 #endif
 
-/*
- * IA-64 doesn't have any external MMU info: the page tables contain all the necessary
- * information.  However, we use this routine to take care of any (delayed) i-cache
- * flushing that may be necessary.
- */
-extern void lazy_mmu_prot_update (pte_t pte);
-
 #define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
  * Update PTEP with ENTRY, which is guaranteed to be a less
@@ -593,7 +585,6 @@ do {											\
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PGD_OFFSET_GATE
-#define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
 
 #ifndef CONFIG_PGTABLE_4
 #include <asm-generic/pgtable-nopud.h>
Index: linux-2.6.22-rc7/include/asm-generic/pgtable.h
===================================================================
--- linux-2.6.22-rc7.orig/include/asm-generic/pgtable.h
+++ linux-2.6.22-rc7/include/asm-generic/pgtable.h
@@ -154,10 +154,6 @@ static inline void ptep_set_wrprotect(st
 #define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
 #endif
 
-#ifndef __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
-#define lazy_mmu_prot_update(pte)	do { } while (0)
-#endif
-
 #ifndef __HAVE_ARCH_MOVE_PTE
 #define move_pte(pte, prot, old_addr, new_addr)	(pte)
 #endif
Index: linux-2.6.22-rc7/mm/memory.c
===================================================================
--- linux-2.6.22-rc7.orig/mm/memory.c
+++ linux-2.6.22-rc7/mm/memory.c
@@ -1599,7 +1599,6 @@ static int do_wp_page(struct mm_struct *
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		ptep_set_access_flags(vma, address, page_table, entry, 1);
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 		ret |= VM_FAULT_WRITE;
 		goto unlock;
 	}
@@ -1640,7 +1639,6 @@ gotten:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		lazy_mmu_prot_update(entry);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2105,7 +2103,6 @@ static int do_swap_page(struct mm_struct
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
-	lazy_mmu_prot_update(pte);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 out:
@@ -2162,12 +2159,16 @@ static int do_anonymous_page(struct mm_s
 		inc_mm_counter(mm, file_rss);
 		page_add_file_rmap(page);
 	}
-
+	/*
+	 * new page is zero-filled, but we have to guarantee icache-dcache
+	 * synchronization before setting pte on some processor.
+	 */
+	if (write_access && (vma->vm_flags & VM_EXEC))
+		flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return VM_FAULT_MINOR;
@@ -2312,7 +2313,6 @@ retry:
 
 	/* no need to invalidate: a not-present page shouldn't be cached */
 	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
@@ -2470,7 +2470,6 @@ static inline int handle_pte_fault(struc
 	if (!pte_same(old_entry, entry)) {
 		ptep_set_access_flags(vma, address, pte, entry, write_access);
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
Index: linux-2.6.22-rc7/mm/migrate.c
===================================================================
--- linux-2.6.22-rc7.orig/mm/migrate.c
+++ linux-2.6.22-rc7/mm/migrate.c
@@ -172,6 +172,11 @@ static void remove_migration_pte(struct 
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
 	if (is_write_migration_entry(entry))
 		pte = pte_mkwrite(pte);
+	/*
+	 * If the processor doesn't guarantee icache-dicache synchronization.
+	 * We need to flush icache before set_pte.
+	 */
+	flush_icache_page(vma, new);
 	set_pte_at(mm, addr, ptep, pte);
 
 	if (PageAnon(new))
@@ -181,7 +186,6 @@ static void remove_migration_pte(struct 
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, pte);
-	lazy_mmu_prot_update(pte);
 
 out:
 	pte_unmap_unlock(ptep, ptl);
Index: linux-2.6.22-rc7/mm/mprotect.c
===================================================================
--- linux-2.6.22-rc7.orig/mm/mprotect.c
+++ linux-2.6.22-rc7/mm/mprotect.c
@@ -52,8 +52,16 @@ static void change_pte_range(struct mm_s
 			 */
 			if (dirty_accountable && pte_dirty(ptent))
 				ptent = pte_mkwrite(ptent);
+#ifdef CONFIG_SMP
+			/* we already flushed cache before reach here.
+			 * But that flush was done before removing pte.
+			 * we confirm i-cache consitency here again.
+			 * This is rare case.
+			 */
+			if (pte_exec(ptent))
+				flush_icache_range(addr, addr + PAGE_SIZE);
+#endif
 			set_pte_at(mm, addr, pte, ptent);
-			lazy_mmu_prot_update(ptent);
 #ifdef CONFIG_MIGRATION
 		} else if (!pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
Index: linux-2.6.22-rc7/mm/rmap.c
===================================================================
--- linux-2.6.22-rc7.orig/mm/rmap.c
+++ linux-2.6.22-rc7/mm/rmap.c
@@ -461,7 +461,6 @@ static int page_mkclean_one(struct page 
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
-		lazy_mmu_prot_update(entry);
 		ret = 1;
 	}
 
Index: linux-2.6.22-rc7/mm/fremap.c
===================================================================
--- linux-2.6.22-rc7.orig/mm/fremap.c
+++ linux-2.6.22-rc7/mm/fremap.c
@@ -83,7 +83,6 @@ int install_page(struct mm_struct *mm, s
 	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
 	update_mmu_cache(vma, addr, pte_val);
-	lazy_mmu_prot_update(pte_val);
 	err = 0;
 unlock:
 	pte_unmap_unlock(pte, ptl);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
