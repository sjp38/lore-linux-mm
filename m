Date: Tue, 20 May 2008 11:21:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Yet another mm notifier: Notify when pages are unmapped.
Message-ID: <Pine.LNX.4.64.0805201114340.6592@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvads@linux-foundation.org
Cc: holt@sgi.com, steiner@sgi.com, npiggin@suse.de, andrea@qumranet.com, akpm@linux-foundation.org, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

Robin suggested that the last post as a reply in the anon_vma thread made 
this patch vanish. So here it is again (guess we are all tired of 
notifiers...)



This patch implements a callbacks for device drivers that establish external
references to pages aside from the Linux rmaps. Those either:

1. Do not take a refcount on pages that are mapped from devices. They
have a TLB cache like handling and must be able to flush external references
from atomic contexts. These devices do not need to provide the _sync methods.

2. Do take a refcount on pages mapped externally. These are handled by
marking pages as to be invalidated in atomic contexts. Invalidation
may be started by the driver. A _sync variant for the individual or
range unmap is called when we are back in a nonatomic context. At that
point the device must complete the removal of external references
and drop its refcount.

With the mm notifier it is possible for the device driver to release external
references after the page references are removed from a process that made
them available.

With the notifier it becomes possible to get pages unpinned on request and thus
avoid issues that come with having a large amount of pinned pages.

A device driver must subscribe to a process using

        mm_register_notifier(struct mm_struct *, struct mm_notifier *)

The VM will then perform callbacks for operations that unmap or change
permissions of pages in that address space.

When the process terminates then the ->release method is called first to
remove all pages still mapped to the proces.

Before the mm_struct is freed the ->destroy() method is called which
should dispose of the mm_notifier structure.

The following callbacks exist:

invalidate_range(notifier, mm_struct *, from , to)

	Invalidate a range of addresses. The invalidation is
	not required to complete immediately.

invalidate_range_sync(notifier, mm_struct *, from, to)

	This is called after some invalidate_range callouts.
	The driver may only return when the invalidation of the references
	is completed. Callback is only called from non atomic contexts.
	There is no need to provide this callback if the driver can remove
	references in an atomic context.

invalidate_page(notifier, mm_struct *, struct page *page, unsigned long address)

	Invalidate references to a particular page. The driver may
	defer the invalidation.

invalidate_page_sync(notifier, mm_struct *,struct *)

	Called after one or more invalidate_page() callbacks. The callback
	must only return when the external references have been removed.
	The callback does not need to be provided if the driver can remove
	references in atomic contexts.

[NOTE] The invalidate_page_sync() callback is weird because it is called for
	every notifier that supports the invalidate_page_sync() callback
	if a page has PageNotifier() set. The driver must determine in an efficient
	way that the page is not of interest. This is because we do not have the
	mm context after we have dropped the rmap list lock.
	Drivers incrementing the refcount must set and clear PageNotifier
	appropriately when establishing and/or dropping a refcount!
	[These conditions are similar to the rmap notifier that was introduced
	in my V7 of the mmu_notifier].

There is no support for an aging callback. A device driver may simply set the
reference bit on the linux pte when the external mapping is referenced if such
support is desired.

The patch is provisional. All functions are inlined for now. They should be wrapped like
in Andrea's series. Its probably good to have Andrea review this if we actually
decide to go this route since he is pretty good as detecting issues with complex
lock interactions in the vm. mmu notifiers V7 was rejected by Andrew because of the
strange asymmetry in invalidate_page_sync() (at that time called rmap notifier) and
we are reintroducing that now in a light weight order to be able to defer freeing
until after the rmap spinlocks have been dropped.

Jack tested this with the GRU.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/hugetlbfs/inode.c       |    2 
 include/linux/mm_types.h   |    3 
 include/linux/page-flags.h |    3 
 include/linux/rmap.h       |  161 +++++++++++++++++++++++++++++++++++++++++++++
 kernel/fork.c              |    4 +
 mm/Kconfig                 |    4 +
 mm/filemap_xip.c           |    2 
 mm/fremap.c                |    2 
 mm/hugetlb.c               |    3 
 mm/memory.c                |   38 ++++++++--
 mm/mmap.c                  |    3 
 mm/mprotect.c              |    3 
 mm/mremap.c                |    5 +
 mm/rmap.c                  |   11 ++-
 14 files changed, 234 insertions(+), 10 deletions(-)

Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2008-05-16 11:28:50.000000000 -0700
+++ linux-2.6/kernel/fork.c	2008-05-16 16:06:26.000000000 -0700
@@ -386,6 +386,9 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+#ifdef CONFIG_MM_NOTIFIER
+		mm->mm_notifier = NULL;
+#endif
 		return mm;
 	}
 
@@ -418,6 +421,7 @@ void __mmdrop(struct mm_struct *mm)
 	BUG_ON(mm == &init_mm);
 	mm_free_pgd(mm);
 	destroy_context(mm);
+	mm_notifier_destroy(mm);
 	free_mm(mm);
 }
 EXPORT_SYMBOL_GPL(__mmdrop);
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c	2008-05-16 11:28:49.000000000 -0700
+++ linux-2.6/mm/filemap_xip.c	2008-05-16 16:06:26.000000000 -0700
@@ -189,6 +189,7 @@ __xip_unmap (struct address_space * mapp
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
+			mm_notifier_invalidate_page(mm, page, address);
 			page_remove_rmap(page, vma);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
@@ -197,6 +198,7 @@ __xip_unmap (struct address_space * mapp
 		}
 	}
 	spin_unlock(&mapping->i_mmap_lock);
+	mm_notifier_invalidate_page_sync(page);
 }
 
 /*
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2008-05-16 11:28:49.000000000 -0700
+++ linux-2.6/mm/fremap.c	2008-05-16 16:06:26.000000000 -0700
@@ -214,7 +214,9 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	mm_notifier_invalidate_range(mm, start, start + size);
 	err = populate_range(mm, vma, start, size, pgoff);
+	mm_notifier_invalidate_range_sync(mm, start, start + size);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-05-16 11:28:50.000000000 -0700
+++ linux-2.6/mm/hugetlb.c	2008-05-16 17:50:31.000000000 -0700
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/rmap.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -843,6 +844,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	mm_notifier_invalidate_range(mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
@@ -864,6 +866,7 @@ void unmap_hugepage_range(struct vm_area
 		spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
 		__unmap_hugepage_range(vma, start, end);
 		spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
+		mm_notifier_invalidate_range_sync(vma->vm_mm, start, end);
 	}
 }
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-05-16 11:28:49.000000000 -0700
+++ linux-2.6/mm/memory.c	2008-05-16 16:06:26.000000000 -0700
@@ -527,6 +527,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	 */
 	if (is_cow_mapping(vm_flags)) {
 		ptep_set_wrprotect(src_mm, addr, src_pte);
+		mm_notifier_invalidate_range(src_mm, addr, addr + PAGE_SIZE);
 		pte = pte_wrprotect(pte);
 	}
 
@@ -649,6 +650,7 @@ int copy_page_range(struct mm_struct *ds
 	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
+	int ret;
 
 	/*
 	 * Don't copy ptes where a page fault will fill them correctly.
@@ -664,17 +666,30 @@ int copy_page_range(struct mm_struct *ds
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
+	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
-		if (copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-						vma, addr, next))
-			return -ENOMEM;
+		if (unlikely(copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
+					    vma, addr, next))) {
+			ret = -ENOMEM;
+			break;
+		}
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
-	return 0;
+
+	/*
+	 * We need to invalidate the secondary MMU mappings only when
+	 * there could be a permission downgrade on the ptes of the
+	 * parent mm. And a permission downgrade will only happen if
+	 * is_cow_mapping() returns true.
+	 */
+	if (is_cow_mapping(vma->vm_flags))
+		mm_notifier_invalidate_range_sync(src_mm, vma->vm_start, end);
+
+	return ret;
 }
 
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
@@ -913,6 +928,7 @@ unsigned long unmap_vmas(struct mmu_gath
 			}
 
 			tlb_finish_mmu(*tlbp, tlb_start, start);
+			mm_notifier_invalidate_range(vma->vm_mm, tlb_start, start);
 
 			if (need_resched() ||
 				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
@@ -951,8 +967,10 @@ unsigned long zap_page_range(struct vm_a
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
+	if (tlb) {
 		tlb_finish_mmu(tlb, address, end);
+		mm_notifier_invalidate_range(mm, address, end);
+	}
 	return end;
 }
 
@@ -1711,7 +1729,6 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			page_cache_release(old_page);
 			if (!pte_same(*page_table, orig_pte))
 				goto unlock;
 
@@ -1729,6 +1746,7 @@ static int do_wp_page(struct mm_struct *
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
+		old_page = NULL;
 		goto unlock;
 	}
 
@@ -1774,6 +1792,7 @@ gotten:
 		 * thread doing COW.
 		 */
 		ptep_clear_flush(vma, address, page_table);
+		mm_notifier_invalidate_page(mm, old_page, address);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
@@ -1787,10 +1806,13 @@ gotten:
 
 	if (new_page)
 		page_cache_release(new_page);
-	if (old_page)
-		page_cache_release(old_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
+	if (old_page) {
+		mm_notifier_invalidate_page_sync(old_page);
+		page_cache_release(old_page);
+	}
+
 	if (dirty_page) {
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-05-16 11:28:50.000000000 -0700
+++ linux-2.6/mm/mmap.c	2008-05-16 16:06:26.000000000 -0700
@@ -1759,6 +1759,8 @@ static void unmap_region(struct mm_struc
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	mm_notifier_invalidate_range(mm, start, end);
+	mm_notifier_invalidate_range_sync(mm, start, end);
 }
 
 /*
@@ -2048,6 +2050,7 @@ void exit_mmap(struct mm_struct *mm)
 
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
+	mm_notifier_release(mm);
 
 	lru_add_drain();
 	flush_cache_mm(mm);
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c	2008-05-16 11:28:50.000000000 -0700
+++ linux-2.6/mm/mprotect.c	2008-05-16 16:06:26.000000000 -0700
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/rmap.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -132,6 +133,7 @@ static void change_protection(struct vm_
 		change_pud_range(mm, pgd, addr, next, newprot, dirty_accountable);
 	} while (pgd++, addr = next, addr != end);
 	flush_tlb_range(vma, start, end);
+	mm_notifier_invalidate_range(vma->vm_mm, start, end);
 }
 
 int
@@ -211,6 +213,7 @@ success:
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
 		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
+	mm_notifier_invalidate_range_sync(mm, start, end);
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	return 0;
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c	2008-05-16 11:28:49.000000000 -0700
+++ linux-2.6/mm/mremap.c	2008-05-16 16:06:26.000000000 -0700
@@ -18,6 +18,7 @@
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/rmap.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -74,6 +75,7 @@ static void move_ptes(struct vm_area_str
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
+	unsigned long old_start = old_addr;
 
 	if (vma->vm_file) {
 		/*
@@ -100,6 +102,7 @@ static void move_ptes(struct vm_area_str
 		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
 	arch_enter_lazy_mmu_mode();
 
+	mm_notifier_invalidate_range(mm, old_addr, old_end);
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
 				   new_pte++, new_addr += PAGE_SIZE) {
 		if (pte_none(*old_pte))
@@ -116,6 +119,8 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
+
+	mm_notifier_invalidate_range_sync(vma->vm_mm, old_start, old_end);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2008-05-16 11:28:50.000000000 -0700
+++ linux-2.6/mm/rmap.c	2008-05-16 16:06:26.000000000 -0700
@@ -52,6 +52,9 @@
 
 #include <asm/tlbflush.h>
 
+struct mm_notifier *mm_notifier_page_sync;
+DECLARE_RWSEM(mm_notifier_page_sync_sem);
+
 struct kmem_cache *anon_vma_cachep;
 
 /* This must be called under the mmap_sem. */
@@ -458,6 +461,7 @@ static int page_mkclean_one(struct page 
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
 		entry = ptep_clear_flush(vma, address, pte);
+		mm_notifier_invalidate_page(mm, page, address);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -502,8 +506,8 @@ int page_mkclean(struct page *page)
 				ret = 1;
 			}
 		}
+		mm_notifier_invalidate_page_sync(page);
 	}
-
 	return ret;
 }
 EXPORT_SYMBOL_GPL(page_mkclean);
@@ -725,6 +729,7 @@ static int try_to_unmap_one(struct page 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
 	pteval = ptep_clear_flush(vma, address, pte);
+	mm_notifier_invalidate_page(mm, page, address);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
@@ -855,6 +860,7 @@ static void try_to_unmap_cluster(unsigne
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
 		pteval = ptep_clear_flush(vma, address, pte);
+		mm_notifier_invalidate_page(mm, page, address);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
@@ -1013,8 +1019,9 @@ int try_to_unmap(struct page *page, int 
 	else
 		ret = try_to_unmap_file(page, migration);
 
+	mm_notifier_invalidate_page_sync(page);
+
 	if (!page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
 }
-
Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h	2008-05-16 11:28:49.000000000 -0700
+++ linux-2.6/include/linux/rmap.h	2008-05-16 18:32:52.000000000 -0700
@@ -133,4 +133,165 @@ static inline int page_mkclean(struct pa
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 
+#ifdef CONFIG_MM_NOTIFIER
+
+struct mm_notifier_ops {
+	void (*invalidate_range)(struct mm_notifier *mn, struct mm_struct *mm,
+					unsigned long start, unsigned long end);
+	void (*invalidate_range_sync)(struct mm_notifier *mn, struct mm_struct *mm,
+					unsigned long start, unsigned long end);
+	void (*invalidate_page)(struct mm_notifier *mn, struct mm_struct *mm,
+					struct page *page, unsigned long addr);
+	void (*invalidate_page_sync)(struct mm_notifier *mn, struct mm_struct *mm,
+								struct page *page);
+	void (*release)(struct mm_notifier *mn, struct mm_struct *mm);
+	void (*destroy)(struct mm_notifier *mn, struct mm_struct *mm);
+};
+
+struct mm_notifier {
+	struct mm_notifier_ops *ops;
+	struct mm_struct *mm;
+	struct mm_notifier *next;
+	struct mm_notifier *next_page_sync;
+};
+
+extern struct mm_notifier *mm_notifier_page_sync;
+extern struct rw_semaphore mm_notifier_page_sync_sem;
+
+/*
+ * Must hold mmap_sem when calling mm_notifier_register.
+ */
+static inline void mm_notifier_register(struct mm_notifier *mn,
+						struct mm_struct *mm)
+{
+	mn->mm = mm;
+	mn->next = mm->mm_notifier;
+	rcu_assign_pointer(mm->mm_notifier, mn);
+	if (mn->ops->invalidate_page_sync) {
+		down_write(&mm_notifier_page_sync_sem);
+		mn->next_page_sync = mm_notifier_page_sync;
+		mm_notifier_page_sync = mn;
+		up_write(&mm_notifier_page_sync_sem);
+	}
+}
+
+/*
+ * Invalidate remote references in a particular address range
+ */
+static inline void mm_notifier_invalidate_range(struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+	struct mm_notifier *mn;
+
+	for (mn = rcu_dereference(mm->mm_notifier); mn;
+					mn = rcu_dereference(mn->next))
+		mn->ops->invalidate_range(mn, mm, start, end);
+}
+
+/*
+ * Invalidate remote references in a particular address range.
+ * Can sleep. Only return if all remote references have been removed.
+ */
+static inline void mm_notifier_invalidate_range_sync(struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+	struct mm_notifier *mn;
+
+	for (mn = rcu_dereference(mm->mm_notifier); mn;
+					mn = rcu_dereference(mn->next))
+		if (mn->ops->invalidate_range_sync)
+			mn->ops->invalidate_range_sync(mn, mm, start, end);
+}
+
+/*
+ * Invalidate remote references to a page
+ */
+static inline void mm_notifier_invalidate_page(struct mm_struct *mm,
+					struct page *page, unsigned long addr)
+{
+	struct mm_notifier *mn;
+
+	for (mn = rcu_dereference(mm->mm_notifier); mn;
+					mn = rcu_dereference(mn->next))
+		mn->ops->invalidate_page(mn, mm, page, addr);
+}
+
+/*
+ * Invalidate remote references to a partioular page. Only return
+ * if all references have been removed.
+ *
+ * Note: This is an expensive function since it is not clear at the time
+ * of call to which mm_struct() the page belongs.. It walks through the
+ * mmlist  and calls the mmu notifier ops for each address space in the
+ * system. At some point this needs to be optimized.
+ */
+static inline void mm_notifier_invalidate_page_sync(struct page *page)
+{
+	struct mm_notifier *mn;
+
+	if (!PageNotifier(page))
+		return;
+
+	down_read(&mm_notifier_page_sync_sem);
+
+	for (mn = mm_notifier_page_sync; mn; mn = mn->next_page_sync)
+		if (mn->ops->invalidate_page_sync)
+				mn->ops->invalidate_page_sync(mn, mn->mm, page);
+
+	up_read(&mm_notifier_page_sync_sem);
+}
+
+/*
+ * Invalidate all remote references before shutdown
+ */
+static inline void mm_notifier_release(struct mm_struct *mm)
+{
+	struct mm_notifier *mn;
+
+	for (mn = rcu_dereference(mm->mm_notifier); mn;
+					mn = rcu_dereference(mn->next))
+		mn->ops->release(mn, mm);
+}
+
+/*
+ * Release resources before freeing mm_struct.
+ */
+static inline void mm_notifier_destroy(struct mm_struct *mm)
+{
+	struct mm_notifier *mn;
+
+	while (mm->mm_notifier) {
+		mn = mm->mm_notifier;
+		mm->mm_notifier = mn->next;
+		if (mn->ops->invalidate_page_sync) {
+			struct mm_notifier *m;
+
+			down_write(&mm_notifier_page_sync_sem);
+
+			if (mm_notifier_page_sync != mn) {
+				for (m = mm_notifier_page_sync; m; m = m->next_page_sync)
+					if (m->next_page_sync == mn)
+						break;
+
+				m->next_page_sync = mn->next_page_sync;
+			} else
+				mm_notifier_page_sync = mn->next_page_sync;
+
+			up_write(&mm_notifier_page_sync_sem);
+		}
+		mn->ops->destroy(mn, mm);
+	}
+}
+#else
+static inline void mm_notifier_invalidate_range(struct mm_struct *mm,
+			unsigned long start, unsigned long end) {}
+static inline void mm_notifier_invalidate_range_sync(struct mm_struct *mm,
+			unsigned long start, unsigned long end) {}
+static inline void mm_notifier_invalidate_page(struct mm_struct *mm,
+			struct page *page, unsigned long address) {}
+static inline void mm_notifier_invalidate_page_sync(struct page *page) {}
+static inline void mm_notifier_release(struct mm_struct *mm) {}
+static inline void mm_notifier_destroy(struct mm_struct *mm) {}
+#endif
+
 #endif	/* _LINUX_RMAP_H */
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2008-05-16 11:28:50.000000000 -0700
+++ linux-2.6/mm/Kconfig	2008-05-16 16:06:26.000000000 -0700
@@ -205,3 +205,7 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config MM_NOTIFIER
+	def_bool y
+
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2008-05-16 11:28:49.000000000 -0700
+++ linux-2.6/include/linux/mm_types.h	2008-05-16 16:06:26.000000000 -0700
@@ -244,6 +244,9 @@ struct mm_struct {
 	struct file *exe_file;
 	unsigned long num_exe_file_vmas;
 #endif
+#ifdef CONFIG_MM_NOTIFIER
+	struct mm_notifier *mm_notifier;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-05-16 11:28:49.000000000 -0700
+++ linux-2.6/include/linux/page-flags.h	2008-05-16 16:06:26.000000000 -0700
@@ -93,6 +93,7 @@ enum pageflags {
 	PG_mappedtodisk,	/* Has blocks allocated on-disk */
 	PG_reclaim,		/* To be reclaimed asap */
 	PG_buddy,		/* Page is free, on buddy lists */
+	PG_notifier,		/* Call notifier when page is changed/unmapped */
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
 #endif
@@ -173,6 +174,8 @@ PAGEFLAG(MappedToDisk, mappedtodisk)
 PAGEFLAG(Reclaim, reclaim) TESTCLEARFLAG(Reclaim, reclaim)
 PAGEFLAG(Readahead, reclaim)		/* Reminder to do async read-ahead */
 
+PAGEFLAG(Notifier, notifier);
+
 #ifdef CONFIG_HIGHMEM
 /*
  * Must use a macro here due to header dependency issues. page_zone() is not
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2008-05-16 11:28:49.000000000 -0700
+++ linux-2.6/fs/hugetlbfs/inode.c	2008-05-16 16:06:55.000000000 -0700
@@ -442,6 +442,8 @@ hugetlb_vmtruncate_list(struct prio_tree
 
 		__unmap_hugepage_range(vma,
 				vma->vm_start + v_offset, vma->vm_end);
+		mm_notifier_invalidate_range_sync(vma->vm_mm,
+				vma->vm_start + v_offset, vma->vm_end);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
