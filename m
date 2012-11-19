Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 5D9AA6B0080
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:15:42 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so3182484eek.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:15:41 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 09/27] sched, mm, numa: Create generic NUMA fault infrastructure, with architectures overrides
Date: Mon, 19 Nov 2012 03:14:26 +0100
Message-Id: <1353291284-2998-10-git-send-email-mingo@kernel.org>
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

This patch is based on patches written by multiple people:

   Hugh Dickins <hughd@google.com>
   Johannes Weiner <hannes@cmpxchg.org>
   Peter Zijlstra <a.p.zijlstra@chello.nl>

Of the "mm/mpol: Create special PROT_NONE infrastructure" patch
and its variants.

I have reworked the code so significantly that I had to
drop the acks and signoffs.

In order to facilitate a lazy -- fault driven -- migration of pages,
create a special transient PROT_NONE variant, we can then use the
'spurious' protection faults to drive our migrations from.

Pages that already had an effective PROT_NONE mapping will not
be detected to generate these 'spuriuos' faults for the simple reason
that we cannot distinguish them on their protection bits, see
pte_numa().

This isn't a problem since PROT_NONE (and possible PROT_WRITE with
dirty tracking) aren't used or are rare enough for us to not care
about their placement.

Architectures can set the CONFIG_ARCH_WANTS_NUMA_GENERIC_PGPROT Kconfig
variable, in which case they get the PROT_NONE variant. Alternatively
they can provide the basic primitives themselves:

  bool pte_numa(struct vm_area_struct *vma, pte_t pte);
  pte_t pte_mknuma(struct vm_area_struct *vma, pte_t pte);
  bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd);
  pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
  unsigned long change_prot_numa(struct vm_area_struct *vma, unsigned long start, unsigned long end);

[ This non-generic angle is untested though. ]

Original-Idea-by: Rik van Riel <riel@redhat.com>
Also-From: Johannes Weiner <hannes@cmpxchg.org>
Also-From: Hugh Dickins <hughd@google.com>
Also-From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/asm-generic/pgtable.h |  55 ++++++++++++++
 include/linux/huge_mm.h       |  12 ++++
 include/linux/mempolicy.h     |   6 ++
 include/linux/migrate.h       |   5 ++
 include/linux/mm.h            |   5 ++
 include/linux/sched.h         |   2 +
 init/Kconfig                  |  22 ++++++
 mm/Makefile                   |   1 +
 mm/huge_memory.c              | 162 ++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h                 |   5 +-
 mm/memcontrol.c               |   7 +-
 mm/memory.c                   |  85 ++++++++++++++++++++--
 mm/migrate.c                  |   2 +-
 mm/mprotect.c                 |   7 --
 mm/numa.c                     |  73 +++++++++++++++++++
 15 files changed, 430 insertions(+), 19 deletions(-)
 create mode 100644 mm/numa.c

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 48fc1dc..d03d0a8 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -537,6 +537,61 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
 }
 
 /*
+ * Is this pte used for NUMA scanning?
+ */
+#ifdef CONFIG_ARCH_USES_NUMA_GENERIC_PGPROT
+extern bool pte_numa(struct vm_area_struct *vma, pte_t pte);
+#else
+# ifndef pte_numa
+static inline bool pte_numa(struct vm_area_struct *vma, pte_t pte)
+{
+	return false;
+}
+# endif
+#endif
+
+/*
+ * Turn a pte into a NUMA entry:
+ */
+#ifdef CONFIG_ARCH_USES_NUMA_GENERIC_PGPROT
+extern pte_t pte_mknuma(struct vm_area_struct *vma, pte_t pte);
+#else
+# ifndef pte_mknuma
+static inline pte_t pte_mknuma(struct vm_area_struct *vma, pte_t pte)
+{
+	return pte;
+}
+# endif
+#endif
+
+/*
+ * Is this pmd used for NUMA scanning?
+ */
+#ifdef CONFIG_ARCH_USES_NUMA_GENERIC_PGPROT_HUGEPAGE
+extern bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd);
+#else
+# ifndef pmd_numa
+static inline bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd)
+{
+	return false;
+}
+# endif
+#endif
+
+/*
+ * Some architectures (such as x86) may need to preserve certain pgprot
+ * bits, without complicating generic pgprot code.
+ *
+ * Most architectures don't care:
+ */
+#ifndef pgprot_modify
+static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
+{
+	return newprot;
+}
+#endif
+
+/*
  * This is a noop if Transparent Hugepage Support is not built into
  * the kernel. Otherwise it is equivalent to
  * pmd_none_or_trans_huge_or_clear_bad(), and shall only be called in
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index b31cb7d..7f5a552 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -197,4 +197,16 @@ static inline int pmd_trans_huge_lock(pmd_t *pmd,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+#ifdef CONFIG_NUMA_BALANCING_HUGEPAGE
+extern void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmd,
+				  unsigned int flags, pmd_t orig_pmd);
+#else
+static inline void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+					 unsigned long address, pmd_t *pmd,
+					 unsigned int flags, pmd_t orig_pmd)
+{
+}
+#endif
+
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index e5ccb9d..f329306 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -324,4 +324,10 @@ static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
 }
 
 #endif /* CONFIG_NUMA */
+
+static inline int mpol_misplaced(struct page *page, struct vm_area_struct *vma,
+				 unsigned long address)
+{
+	return -1; /* no node preference */
+}
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ce7e667..afd9af1 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -64,4 +64,9 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #define fail_migrate_page NULL
 
 #endif /* CONFIG_MIGRATION */
+static inline
+int migrate_misplaced_page(struct page *page, int node)
+{
+	return -EAGAIN; /* can't migrate now */
+}
 #endif /* _LINUX_MIGRATE_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5fc1d46..246375c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1559,6 +1559,11 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
 }
 #endif
 
+#ifdef CONFIG_ARCH_USES_NUMA_GENERIC_PGPROT
+extern unsigned long
+change_prot_numa(struct vm_area_struct *vma, unsigned long start, unsigned long end);
+#endif
+
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e1581a0..a0a2808 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1575,6 +1575,8 @@ struct task_struct {
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
+static inline void task_numa_fault(int node, int cpu, int pages) { }
+
 /*
  * Priority of a process goes from 0..MAX_PRIO-1, valid RT
  * priority is 0..MAX_RT_PRIO-1, and SCHED_NORMAL/SCHED_BATCH
diff --git a/init/Kconfig b/init/Kconfig
index 6fdd6e3..f36c83d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -696,6 +696,28 @@ config LOG_BUF_SHIFT
 config HAVE_UNSTABLE_SCHED_CLOCK
 	bool
 
+#
+# Helper Kconfig switches to express compound feature dependencies
+# and thus make the .h/.c code more readable:
+#
+config NUMA_BALANCING_HUGEPAGE
+	bool
+	default y
+	depends on NUMA_BALANCING
+	depends on TRANSPARENT_HUGEPAGE
+
+config ARCH_USES_NUMA_GENERIC_PGPROT
+	bool
+	default y
+	depends on ARCH_WANTS_NUMA_GENERIC_PGPROT
+	depends on NUMA_BALANCING
+
+config ARCH_USES_NUMA_GENERIC_PGPROT_HUGEPAGE
+	bool
+	default y
+	depends on ARCH_USES_NUMA_GENERIC_PGPROT
+	depends on TRANSPARENT_HUGEPAGE
+
 menuconfig CGROUPS
 	boolean "Control Group support"
 	depends on EVENTFD
diff --git a/mm/Makefile b/mm/Makefile
index 6b025f8..26f7574 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
+obj-$(CONFIG_ARCH_USES_NUMA_GENERIC_PGPROT) += numa.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 40f17c3..814e3ea 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -18,6 +18,7 @@
 #include <linux/freezer.h>
 #include <linux/mman.h>
 #include <linux/pagemap.h>
+#include <linux/migrate.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
 #include "internal.h"
@@ -725,6 +726,165 @@ out:
 	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+/*
+ * Handle a NUMA fault: check whether we should migrate and
+ * mark it accessible again.
+ */
+void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmd,
+			   unsigned int flags, pmd_t entry)
+{
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct mem_cgroup *memcg = NULL;
+	struct page *new_page;
+	struct page *page = NULL;
+	int last_cpu;
+	int node = -1;
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry)))
+		goto unlock;
+
+	if (unlikely(pmd_trans_splitting(entry))) {
+		spin_unlock(&mm->page_table_lock);
+		wait_split_huge_page(vma->anon_vma, pmd);
+		return;
+	}
+
+	page = pmd_page(entry);
+	if (page) {
+		int page_nid = page_to_nid(page);
+
+		VM_BUG_ON(!PageCompound(page) || !PageHead(page));
+		last_cpu = page_last_cpu(page);
+
+		get_page(page);
+		/*
+		 * Note that migrating pages shared by others is safe, since
+		 * get_user_pages() or GUP fast would have to fault this page
+		 * present before they could proceed, and we are holding the
+		 * pagetable lock here and are mindful of pmd races below.
+		 */
+		node = mpol_misplaced(page, vma, haddr);
+		if (node != -1 && node != page_nid)
+			goto migrate;
+	}
+
+fixup:
+	/* change back to regular protection */
+	entry = pmd_modify(entry, vma->vm_page_prot);
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, entry);
+
+unlock:
+	spin_unlock(&mm->page_table_lock);
+	if (page) {
+		task_numa_fault(page_to_nid(page), last_cpu, HPAGE_PMD_NR);
+		put_page(page);
+	}
+	return;
+
+migrate:
+	spin_unlock(&mm->page_table_lock);
+
+	lock_page(page);
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry))) {
+		spin_unlock(&mm->page_table_lock);
+		unlock_page(page);
+		put_page(page);
+		return;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	new_page = alloc_pages_node(node,
+	    (GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
+	if (!new_page)
+		goto alloc_fail;
+
+	if (isolate_lru_page(page)) {	/* Does an implicit get_page() */
+		put_page(new_page);
+		goto alloc_fail;
+	}
+
+	__set_page_locked(new_page);
+	SetPageSwapBacked(new_page);
+
+	/* anon mapping, we can simply copy page->mapping to the new page: */
+	new_page->mapping = page->mapping;
+	new_page->index = page->index;
+
+	migrate_page_copy(new_page, page);
+
+	WARN_ON(PageLRU(new_page));
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry))) {
+		spin_unlock(&mm->page_table_lock);
+
+		/* Reverse changes made by migrate_page_copy() */
+		if (TestClearPageActive(new_page))
+			SetPageActive(page);
+		if (TestClearPageUnevictable(new_page))
+			SetPageUnevictable(page);
+		mlock_migrate_page(page, new_page);
+
+		unlock_page(new_page);
+		put_page(new_page);		/* Free it */
+
+		unlock_page(page);
+		putback_lru_page(page);
+		put_page(page);			/* Drop the local reference */
+		return;
+	}
+	/*
+	 * Traditional migration needs to prepare the memcg charge
+	 * transaction early to prevent the old page from being
+	 * uncharged when installing migration entries.  Here we can
+	 * save the potential rollback and start the charge transfer
+	 * only when migration is already known to end successfully.
+	 */
+	mem_cgroup_prepare_migration(page, new_page, &memcg);
+
+	entry = mk_pmd(new_page, vma->vm_page_prot);
+	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+	entry = pmd_mkhuge(entry);
+
+	page_add_new_anon_rmap(new_page, vma, haddr);
+
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, entry);
+	page_remove_rmap(page);
+	/*
+	 * Finish the charge transaction under the page table lock to
+	 * prevent split_huge_page() from dividing up the charge
+	 * before it's fully transferred to the new page.
+	 */
+	mem_cgroup_end_migration(memcg, page, new_page, true);
+	spin_unlock(&mm->page_table_lock);
+
+	task_numa_fault(node, last_cpu, HPAGE_PMD_NR);
+
+	unlock_page(new_page);
+	unlock_page(page);
+	put_page(page);			/* Drop the rmap reference */
+	put_page(page);			/* Drop the LRU isolation reference */
+	put_page(page);			/* Drop the local reference */
+	return;
+
+alloc_fail:
+	unlock_page(page);
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry))) {
+		put_page(page);
+		page = NULL;
+		goto unlock;
+	}
+	goto fixup;
+}
+#endif
+
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 		  struct vm_area_struct *vma)
@@ -1363,6 +1523,8 @@ static int __split_huge_page_map(struct page *page,
 				BUG_ON(page_mapcount(page) != 1);
 			if (!pmd_young(*pmd))
 				entry = pte_mkold(entry);
+			if (pmd_numa(vma, *pmd))
+				entry = pte_mknuma(vma, entry);
 			pte = pte_offset_map(&_pmd, haddr);
 			BUG_ON(!pte_none(*pte));
 			set_pte_at(mm, haddr, pte, entry);
diff --git a/mm/internal.h b/mm/internal.h
index a4fa284..b84d571 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -212,11 +212,12 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 {
 	if (TestClearPageMlocked(page)) {
 		unsigned long flags;
+		int nr_pages = hpage_nr_pages(page);
 
 		local_irq_save(flags);
-		__dec_zone_page_state(page, NR_MLOCK);
+		__mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
 		SetPageMlocked(newpage);
-		__inc_zone_page_state(newpage, NR_MLOCK);
+		__mod_zone_page_state(page_zone(newpage), NR_MLOCK, nr_pages);
 		local_irq_restore(flags);
 	}
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7acf43b..011e510 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3255,15 +3255,18 @@ void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 				  struct mem_cgroup **memcgp)
 {
 	struct mem_cgroup *memcg = NULL;
+	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
 	enum charge_type ctype;
 
 	*memcgp = NULL;
 
-	VM_BUG_ON(PageTransHuge(page));
 	if (mem_cgroup_disabled())
 		return;
 
+	if (PageTransHuge(page))
+		nr_pages <<= compound_order(page);
+
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
@@ -3325,7 +3328,7 @@ void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 	 * charged to the res_counter since we plan on replacing the
 	 * old one and only one page is going to be left afterwards.
 	 */
-	__mem_cgroup_commit_charge(memcg, newpage, 1, ctype, false);
+	__mem_cgroup_commit_charge(memcg, newpage, nr_pages, ctype, false);
 }
 
 /* remove redundant charge if migration failed*/
diff --git a/mm/memory.c b/mm/memory.c
index 24d3a4a..b9bb15c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/migrate.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3437,6 +3438,69 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
+static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pte_t *ptep, pmd_t *pmd,
+			unsigned int flags, pte_t entry)
+{
+	struct page *page = NULL;
+	int node, page_nid = -1;
+	int last_cpu = -1;
+	spinlock_t *ptl;
+
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+	if (unlikely(!pte_same(*ptep, entry)))
+		goto out_unlock;
+
+	page = vm_normal_page(vma, address, entry);
+	if (page) {
+		get_page(page);
+		page_nid = page_to_nid(page);
+		last_cpu = page_last_cpu(page);
+		node = mpol_misplaced(page, vma, address);
+		if (node != -1 && node != page_nid)
+			goto migrate;
+	}
+
+out_pte_upgrade_unlock:
+	flush_cache_page(vma, address, pte_pfn(entry));
+
+	ptep_modify_prot_start(mm, address, ptep);
+	entry = pte_modify(entry, vma->vm_page_prot);
+	ptep_modify_prot_commit(mm, address, ptep, entry);
+
+	/* No TLB flush needed because we upgraded the PTE */
+
+	update_mmu_cache(vma, address, ptep);
+
+out_unlock:
+	pte_unmap_unlock(ptep, ptl);
+out:
+	if (page) {
+		task_numa_fault(page_nid, last_cpu, 1);
+		put_page(page);
+	}
+
+	return 0;
+
+migrate:
+	pte_unmap_unlock(ptep, ptl);
+
+	if (!migrate_misplaced_page(page, node)) {
+		page_nid = node;
+		goto out;
+	}
+
+	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_same(*ptep, entry)) {
+		put_page(page);
+		page = NULL;
+		goto out_unlock;
+	}
+
+	goto out_pte_upgrade_unlock;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3475,6 +3539,9 @@ int handle_pte_fault(struct mm_struct *mm,
 					pte, pmd, flags, entry);
 	}
 
+	if (pte_numa(vma, entry))
+		return do_numa_page(mm, vma, address, pte, pmd, flags, entry);
+
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*pte, entry)))
@@ -3539,13 +3606,16 @@ retry:
 							  pmd, flags);
 	} else {
 		pmd_t orig_pmd = *pmd;
-		int ret;
+		int ret = 0;
 
 		barrier();
-		if (pmd_trans_huge(orig_pmd)) {
-			if (flags & FAULT_FLAG_WRITE &&
-			    !pmd_write(orig_pmd) &&
-			    !pmd_trans_splitting(orig_pmd)) {
+		if (pmd_trans_huge(orig_pmd) && !pmd_trans_splitting(orig_pmd)) {
+			if (pmd_numa(vma, orig_pmd)) {
+				do_huge_pmd_numa_page(mm, vma, address, pmd,
+						      flags, orig_pmd);
+			}
+
+			if ((flags & FAULT_FLAG_WRITE) && !pmd_write(orig_pmd)) {
 				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
 							  orig_pmd);
 				/*
@@ -3555,12 +3625,13 @@ retry:
 				 */
 				if (unlikely(ret & VM_FAULT_OOM))
 					goto retry;
-				return ret;
 			}
-			return 0;
+
+			return ret;
 		}
 	}
 
+
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
 	 * run pte_offset_map on the pmd, if an huge pmd could
diff --git a/mm/migrate.c b/mm/migrate.c
index 77ed2d7..4ba45f4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -407,7 +407,7 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
  */
 void migrate_page_copy(struct page *newpage, struct page *page)
 {
-	if (PageHuge(page))
+	if (PageHuge(page) || PageTransHuge(page))
 		copy_huge_page(newpage, page);
 	else
 		copy_highpage(newpage, page);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 7c3628a..6ff2d5e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -28,13 +28,6 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-#ifndef pgprot_modify
-static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
-{
-	return newprot;
-}
-#endif
-
 static unsigned long change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
diff --git a/mm/numa.c b/mm/numa.c
new file mode 100644
index 0000000..8d18800
--- /dev/null
+++ b/mm/numa.c
@@ -0,0 +1,73 @@
+/*
+ * Generic NUMA page table entry support. This code reuses
+ * PROT_NONE: an architecture can choose to use its own
+ * implementation, by setting CONFIG_ARCH_SUPPORTS_NUMA_BALANCING
+ * and not setting CONFIG_ARCH_WANTS_NUMA_GENERIC_PGPROT.
+ */
+#include <linux/mm.h>
+
+static inline pgprot_t vma_prot_none(struct vm_area_struct *vma)
+{
+	/*
+	 * obtain PROT_NONE by removing READ|WRITE|EXEC privs
+	 */
+	vm_flags_t vmflags = vma->vm_flags & ~(VM_READ|VM_WRITE|VM_EXEC);
+
+	return pgprot_modify(vma->vm_page_prot, vm_get_page_prot(vmflags));
+}
+
+bool pte_numa(struct vm_area_struct *vma, pte_t pte)
+{
+	/*
+	 * For NUMA page faults, we use PROT_NONE ptes in VMAs with
+	 * "normal" vma->vm_page_prot protections.  Genuine PROT_NONE
+	 * VMAs should never get here, because the fault handling code
+	 * will notice that the VMA has no read or write permissions.
+	 *
+	 * This means we cannot get 'special' PROT_NONE faults from genuine
+	 * PROT_NONE maps, nor from PROT_WRITE file maps that do dirty
+	 * tracking.
+	 *
+	 * Neither case is really interesting for our current use though so we
+	 * don't care.
+	 */
+	if (pte_same(pte, pte_modify(pte, vma->vm_page_prot)))
+		return false;
+
+	return pte_same(pte, pte_modify(pte, vma_prot_none(vma)));
+}
+
+pte_t pte_mknuma(struct vm_area_struct *vma, pte_t pte)
+{
+	return pte_modify(pte, vma_prot_none(vma));
+}
+
+#ifdef CONFIG_ARCH_USES_NUMA_GENERIC_PGPROT_HUGEPAGE
+bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd)
+{
+	/*
+	 * See pte_numa() above
+	 */
+	if (pmd_same(pmd, pmd_modify(pmd, vma->vm_page_prot)))
+		return false;
+
+	return pmd_same(pmd, pmd_modify(pmd, vma_prot_none(vma)));
+}
+#endif
+
+/*
+ * The scheduler uses this function to mark a range of virtual
+ * memory inaccessible to user-space, for the purposes of probing
+ * the composition of the working set.
+ *
+ * The resulting page faults will be demultiplexed into:
+ *
+ *    mm/memory.c::do_numa_page()
+ *    mm/huge_memory.c::do_huge_pmd_numa_page()
+ *
+ * This generic version simply uses PROT_NONE.
+ */
+unsigned long change_prot_numa(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+{
+	return change_protection(vma, start, end, vma_prot_none(vma), 0);
+}
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
