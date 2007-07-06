Date: Fri, 6 Jul 2007 11:29:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX]{PATCH] flush icache on ia64 take2
Message-Id: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "tony.luck@intel.com" <tony.luck@intel.com>, nickpiggin@yahoo.com.au, mike@stroyan.net, Zoltan.Menyhart@bull.net, dmosberger@gmail.com, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is a patch for fixing icache flush race in ia64(Montecito) by implementing
flush_icache_page() at el.

Changelog:
 - updated against 2.6.22-rc7 (previous one was against 2.6.21)
 - removed hugetlbe's lazy_mmu_prot_update().
 - rewrote patch description.
 - removed patch against mprotect() if flushes cache.

Brief Description:
In current kernel, ia64 flushes executable page's icache by
lazy_mmu_prot_update() after set_pte(). But multi-threaded programs can access
text page if pte says "a page is present". Then, there is a race condition.
This patch guarantees cache is flushed before set_pte() call.

Basic Information:
Montecito, new ia64 processor, has separated L2 I-cache and L2 D-cache,
and I-cache and D-cache is not guaranteed to be consistent in automatic way.

L1 cache is also separated but L1 D-cache is write-through. 

Montecito has separated L2 cache and Mixed L3 cache. And...L2 D-cache is
*write back*. (See http://download.intel.com/design/Itanium2/manuals/
30806501.pdf section 2.3.3)

What we found and my understanding:

In our environment, I found SIGILL occurs when...
 * A multi threaded program is executed. (a program is a HPC program and uses
   automatic parallelizaiton.)
 * Above program is on NFS.
 * SIGILL happes only when a file is newly loaded into the page-cache.
 * Where failure occurs is not fixed. SIGILL comes at random instruction point.
 * This didn't happen before Montecito.

>From Itanium2 document, we can see....
 * Any invalidation of a cache-line will invalidate an I-cache.
 * I-cache and D-cache is not coherent.
 * L1D-cache to L2 cache is *write-through*.
 * L2D-cache to L3-mixed cache is *write-back*.

And we don't see this problem before Montecito. Big difference between old ones
and Montecito is 
 * old cpus has Mixed L2 cache.
 * Montecito has separated L2I-cache and L2D-cache.

Following is my understanding. I'd like to hear ia64 specialist's opinion.

Assume CPU(A) and CPU(B).

 1. CPU(A) causes a page fault in text and calls do_no_page().
 2. CPU(B) executes NFS's ops and fill page with received RPC result(from NFS).
    and do SetPageUptodate().
 3. CPU(A) continues a page fault operation and calls set_pte().
 4. CPU(B)'s another thread executes a text in the page which CPU(A) mapped.
 5-a. CPU(A) calls lazy_mmu_prot_update() and flush icache (this is slow).
 5-b. CPU(B) continues execution and cause SIGILL by an instruction which
      CPU(A) haven't flushed yet.

 In stage 2. , CPU(B) loads all text data into L2-Dcache and L3-mixed cache. 
 And write them.
 But data which can be accessed by CPU(B)'s L2-Icache is in L3-mixed cache.
 Then, If write back from L2-Dcache to L3-mixed cache is delayed, L2-Icache
 of CPU(B) will fetch wrong data.
 Note: CPU(A) will fetch fetch correct instruction in above case.

 Usual file systems uses DMA and it purges cache. But NFS uses copy-by-cpu.

 Anyway, there is SIGILL problem in NFS/ia64 and icache flush can fix
 SIGILL problem (in our HPC team test.)

 calling lazy_mmu_prot_update() before set_pte() can fix this. But
 it seems strange way. Then, flush_icache_page() is implemented.
 
 Note1: icache flush is called only when VM_EXEC flag is on and 
        PG_arch_1 is not set.
 Note2: description in Devid Mosberger's "ia64 linux kernel" pp204 says
       "linux taditionally maps the memory stack and memory allocated by
	the brk() with executable permission turned on...."
 	But this is changed now. anon/stack is not mapped as executable usually.
	It depens on READ_IMPLIES_EXEC personality. So checking VM_EXEC is enough.

What this patch does:
 1. remove all lazy_mmu_prot_update()...which is used by only ia64.
 2. implements flush_cache_page()/flush_icache_page() for ia64.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 arch/ia64/mm/init.c           |    7 +------
 include/asm-generic/pgtable.h |    4 ----
 include/asm-ia64/cacheflush.h |   24 ++++++++++++++++++++++--
 include/asm-ia64/pgtable.h    |    9 ---------
 mm/fremap.c                   |    1 -
 mm/hugetlb.c                  |    5 +++--
 mm/memory.c                   |   13 ++++++-------
 mm/migrate.c                  |    6 +++++-
 mm/mprotect.c                 |    1 -
 mm/rmap.c                     |    1 -
 10 files changed, 37 insertions(+), 34 deletions(-)

Index: devel-2.6.22-rc7/include/asm-ia64/cacheflush.h
===================================================================
--- devel-2.6.22-rc7.orig/include/asm-ia64/cacheflush.h
+++ devel-2.6.22-rc7/include/asm-ia64/cacheflush.h
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
 
Index: devel-2.6.22-rc7/arch/ia64/mm/init.c
===================================================================
--- devel-2.6.22-rc7.orig/arch/ia64/mm/init.c
+++ devel-2.6.22-rc7/arch/ia64/mm/init.c
@@ -54,16 +54,11 @@ struct page *zero_page_memmap_ptr;	/* ma
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
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
Index: devel-2.6.22-rc7/include/asm-ia64/pgtable.h
===================================================================
--- devel-2.6.22-rc7.orig/include/asm-ia64/pgtable.h
+++ devel-2.6.22-rc7/include/asm-ia64/pgtable.h
@@ -151,7 +151,6 @@
 
 #include <linux/sched.h>	/* for mm_struct */
 #include <asm/bitops.h>
-#include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
 
@@ -502,13 +501,6 @@ extern struct page *zero_page_memmap_ptr
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
@@ -596,7 +588,6 @@ extern void lazy_mmu_prot_update (pte_t 
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PGD_OFFSET_GATE
-#define __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
 
 #ifndef CONFIG_PGTABLE_4
 #include <asm-generic/pgtable-nopud.h>
Index: devel-2.6.22-rc7/include/asm-generic/pgtable.h
===================================================================
--- devel-2.6.22-rc7.orig/include/asm-generic/pgtable.h
+++ devel-2.6.22-rc7/include/asm-generic/pgtable.h
@@ -168,10 +168,6 @@ static inline void ptep_set_wrprotect(st
 #define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
 #endif
 
-#ifndef __HAVE_ARCH_LAZY_MMU_PROT_UPDATE
-#define lazy_mmu_prot_update(pte)	do { } while (0)
-#endif
-
 #ifndef __HAVE_ARCH_MOVE_PTE
 #define move_pte(pte, prot, old_addr, new_addr)	(pte)
 #endif
Index: devel-2.6.22-rc7/mm/memory.c
===================================================================
--- devel-2.6.22-rc7.orig/mm/memory.c
+++ devel-2.6.22-rc7/mm/memory.c
@@ -1693,7 +1693,6 @@ static int do_wp_page(struct mm_struct *
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (ptep_set_access_flags(vma, address, page_table, entry,1)) {
 			update_mmu_cache(vma, address, entry);
-			lazy_mmu_prot_update(entry);
 		}
 		ret |= VM_FAULT_WRITE;
 		goto unlock;
@@ -1735,7 +1734,6 @@ gotten:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		lazy_mmu_prot_update(entry);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2200,7 +2198,6 @@ static int do_swap_page(struct mm_struct
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
-	lazy_mmu_prot_update(pte);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 out:
@@ -2257,12 +2254,16 @@ static int do_anonymous_page(struct mm_s
 		inc_mm_counter(mm, file_rss);
 		page_add_file_rmap(page);
 	}
-
+	/*
+	 * new page is zero-filled, but we have to guarantee icache-dcache
+	 * synchronization before setting pte on some processor.
+	 */
+	if (write_access)
+		flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return VM_FAULT_MINOR;
@@ -2407,7 +2408,6 @@ retry:
 
 	/* no need to invalidate: a not-present page shouldn't be cached */
 	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
@@ -2563,7 +2563,6 @@ static inline int handle_pte_fault(struc
 	entry = pte_mkyoung(entry);
 	if (ptep_set_access_flags(vma, address, pte, entry, write_access)) {
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
Index: devel-2.6.22-rc7/mm/migrate.c
===================================================================
--- devel-2.6.22-rc7.orig/mm/migrate.c
+++ devel-2.6.22-rc7/mm/migrate.c
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
Index: devel-2.6.22-rc7/mm/mprotect.c
===================================================================
--- devel-2.6.22-rc7.orig/mm/mprotect.c
+++ devel-2.6.22-rc7/mm/mprotect.c
@@ -53,7 +53,6 @@ static void change_pte_range(struct mm_s
 			if (dirty_accountable && pte_dirty(ptent))
 				ptent = pte_mkwrite(ptent);
 			set_pte_at(mm, addr, pte, ptent);
-			lazy_mmu_prot_update(ptent);
 #ifdef CONFIG_MIGRATION
 		} else if (!pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
Index: devel-2.6.22-rc7/mm/rmap.c
===================================================================
--- devel-2.6.22-rc7.orig/mm/rmap.c
+++ devel-2.6.22-rc7/mm/rmap.c
@@ -436,7 +436,6 @@ static int page_mkclean_one(struct page 
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
-		lazy_mmu_prot_update(entry);
 		ret = 1;
 	}
 
Index: devel-2.6.22-rc7/mm/fremap.c
===================================================================
--- devel-2.6.22-rc7.orig/mm/fremap.c
+++ devel-2.6.22-rc7/mm/fremap.c
@@ -83,7 +83,6 @@ int install_page(struct mm_struct *mm, s
 	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
 	update_mmu_cache(vma, addr, pte_val);
-	lazy_mmu_prot_update(pte_val);
 	err = 0;
 unlock:
 	pte_unmap_unlock(pte, ptl);
Index: devel-2.6.22-rc7/mm/hugetlb.c
===================================================================
--- devel-2.6.22-rc7.orig/mm/hugetlb.c
+++ devel-2.6.22-rc7/mm/hugetlb.c
@@ -328,7 +328,6 @@ static void set_huge_ptep_writable(struc
 	entry = pte_mkwrite(pte_mkdirty(*ptep));
 	if (ptep_set_access_flags(vma, address, ptep, entry, 1)) {
 		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
 	}
 }
 
@@ -445,6 +444,7 @@ static int hugetlb_cow(struct mm_struct 
 	 * and just make the page writable */
 	avoidcopy = (page_count(old_page) == 1);
 	if (avoidcopy) {
+		/* cache flush is not necessary in this case */
 		set_huge_ptep_writable(vma, address, ptep);
 		return VM_FAULT_MINOR;
 	}
@@ -463,6 +463,8 @@ static int hugetlb_cow(struct mm_struct 
 
 	ptep = huge_pte_offset(mm, address & HPAGE_MASK);
 	if (likely(pte_same(*ptep, pte))) {
+		/* We have to confirm new_page's cache coherency if VM_EXEC */
+		flush_icache_page(vma,new_page);
 		/* Break COW */
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
@@ -681,7 +683,6 @@ void hugetlb_change_protection(struct vm
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(pte_modify(pte, newprot));
 			set_huge_pte_at(mm, address, ptep, pte);
-			lazy_mmu_prot_update(pte);
 		}
 	}
 	spin_unlock(&mm->page_table_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
