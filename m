Date: Wed, 5 Mar 2008 16:22:11 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Notifier for Externally Mapped Memory (EMM) V1
Message-ID: <Pine.LNX.4.64.0803051600470.7481@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Izik Eidus <izike@qumranet.com>, Avi Kivity <avi@qumranet.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

This patch implements a simple callback for device drivers that establish
their own references to pages (KVM, GRU, XPmem, RDMA/Infiniband, DMA engines
etc). These references are unknown to the VM (therefore external).

With these callbacks it is possible for the device driver to release external
references when the VM requests it. This enables swapping, page migration and
allows support of remapping, permission changes etc etc for externally
mapped memory.

With this functionality it becomes also possible to avoid pinning or mlocking
pages (commonly done to stop the VM from unmapping device mapped pages).

A device driver must subscribe to a process using

	emm_register_notifier(struct emm_notifier *, struct mm_struct *)


The VM will then perform callbacks for operations that unmap or change
permissions of pages in that address space. When the process terminates
the callback function is called with emm_release.

Callbacks are performed before and after the unmapping action of the VM.

	emm_invalidate_start	before

	emm_invalidate_end	after

The device driver must hold off establishing new references to pages
in the range specified between a callback with emm_invalidate_start and
the subsequent call with emm_invalidate_end set. This allows the VM to
ensure that no concurrent driver actions are performed on an address
range while performing remapping or unmapping operations.

Callbacks are mostly performed in a non atomic context. However, in
various places spinlocks are held to traverse rmaps. So this patch here
is only useful for those devices that can remove mappings in an atomic
context (f.e. KVM/GRU).

If the rmap spinlocks are converted to semaphores then all callbacks will
be performed in a nonatomic context. No additional changes will be necessary
to this patchset.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm_types.h |    3 +
 include/linux/rmap.h     |   50 ++++++++++++++++++++++++++++++
 kernel/fork.c            |    3 +
 mm/Kconfig               |    5 +++
 mm/filemap_xip.c         |    4 ++
 mm/fremap.c              |    2 +
 mm/hugetlb.c             |    3 +
 mm/memory.c              |   42 ++++++++++++++++++++-----
 mm/mmap.c                |    3 +
 mm/mprotect.c            |    3 +
 mm/mremap.c              |    4 ++
 mm/rmap.c                |   78 +++++++++++++++++++++++++++++++++++++++++++++--
 12 files changed, 190 insertions(+), 10 deletions(-)

Index: linux-2.6.25-rc3-mm1/include/linux/mm_types.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/mm_types.h	2008-03-04 11:28:59.852322222 -0800
+++ linux-2.6.25-rc3-mm1/include/linux/mm_types.h	2008-03-05 15:59:26.872868541 -0800
@@ -236,6 +236,9 @@ struct mm_struct {
 	struct file *exe_file;
 	unsigned long num_exe_file_vmas;
 #endif
+#ifdef CONFIG_EMM_NOTIFIER
+	struct emm_notifier     *emm_notifier;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6.25-rc3-mm1/mm/Kconfig
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/Kconfig	2008-02-24 13:25:54.000000000 -0800
+++ linux-2.6.25-rc3-mm1/mm/Kconfig	2008-03-05 15:58:51.246302285 -0800
@@ -193,3 +193,8 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config EMM_NOTIFIER
+	def_bool n
+	bool "External Mapped Memory Notifier for drivers directly mapping memory"
+
Index: linux-2.6.25-rc3-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/rmap.h	2008-02-24 13:25:54.000000000 -0800
+++ linux-2.6.25-rc3-mm1/include/linux/rmap.h	2008-03-05 15:58:51.246302285 -0800
@@ -85,6 +85,56 @@ static inline void page_dup_rmap(struct 
 #endif
 
 /*
+ * Notifier for devices establishing their own references to Linux
+ * kernel pages in addition to the regular mapping via page
+ * table and rmap. The notifier allows the device to drop the mapping
+ * when the VM removes references to pages.
+ */
+enum emm_operation {
+	emm_release,		/* Process existing, */
+	emm_invalidate_start,	/* Before the VM unmaps pages */
+	emm_invalidate_end,	/* After the VM unmapped pages */
+	emm_referenced		/* Check if a range was referenced */
+};
+
+struct emm_notifier {
+	int (*callback)(struct emm_notifier *e, struct mm_struct *mm,
+		enum emm_operation op,
+		unsigned long start, unsigned long end);
+	struct emm_notifier *next;
+};
+
+extern int __emm_notify(struct mm_struct *mm, enum emm_operation op,
+		unsigned long start, unsigned long end);
+
+/*
+ * Callback to the device driver for an externally memory mapped section
+ * of memory.
+ *
+ * start	Address of first byte of the range
+ * end		Address of first byte after range.
+ */
+static inline int emm_notify(struct mm_struct *mm, enum emm_operation op,
+	unsigned long start, unsigned long end)
+{
+#ifdef CONFIG_EMM_NOTIFIER
+	if (unlikely(mm->emm_notifier))
+		return __emm_notify(mm, op, start, end);
+#endif
+	return 0;
+}
+
+/*
+ * Register a notifier with an mm struct. Release occurs when the process
+ * terminates by calling the notifier function with emm_release.
+ *
+ * Must hold the mmap_sem for write.
+ */
+extern void emm_notifier_register(struct emm_notifier *e,
+					struct mm_struct *mm);
+
+
+/*
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt);
Index: linux-2.6.25-rc3-mm1/mm/rmap.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/rmap.c	2008-03-04 11:29:00.608332241 -0800
+++ linux-2.6.25-rc3-mm1/mm/rmap.c	2008-03-05 16:19:49.863651354 -0800
@@ -275,6 +275,66 @@ pte_t *page_check_address(struct page *p
 	return NULL;
 }
 
+#ifdef CONFIG_EMM_NOTIFIER
+/*
+ * Notifier for devices establishing their own references to Linux
+ * kernel pages in addition to the regular mapping via page
+ * table and rmap. The notifier allows the device to drop the mapping
+ * when the VM removes references to pages.
+ */
+
+/*
+ * This function is only called when a single process remains that performs
+ * teardown when the last process is exiting.
+ */
+void emm_notifier_release(struct mm_struct *mm)
+{
+	struct emm_notifier *e;
+
+	while (mm->emm_notifier) {
+		e = mm->emm_notifier;
+		mm->emm_notifier = e->next;
+		e->callback(e, mm, emm_release, 0, 0);
+	}
+}
+
+/* Register a notifier */
+void emm_notifier_register(struct emm_notifier *e, struct mm_struct *mm)
+{
+	e->next = mm->emm_notifier;
+	/*
+	 * The update to emm_notifier must be visible
+	 * before the pointer becomes visible.
+	 */
+	smp_wmb();
+	mm->emm_notifier = e;
+}
+EXPORT_SYMBOL_GPL(emm_notifier_register);
+
+/* Perform a callback */
+int __emm_notify(struct mm_struct *mm, enum emm_operation op,
+		unsigned long start, unsigned long end)
+{
+	struct emm_notifier *e = mm->emm_notifier;
+	int x;
+
+	while (e) {
+		/*
+		 * emm_notifier contents must be fetched after
+		 * the retrival of the pointer to the notifier.
+		 */
+		smp_rmb();
+		if (e->callback) {
+			x = e->callback(e, mm, op, start, end);
+			if (x)
+				return x;
+		}
+		e = e->next;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__emm_notify);
+#endif
 /*
  * Subfunctions of page_referenced: page_referenced_one called
  * repeatedly from either page_referenced_anon or page_referenced_file.
@@ -310,6 +370,9 @@ static int page_referenced_one(struct pa
 
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
+
+	if (emm_notify(mm, emm_referenced, address, address + PAGE_SIZE))
+			referenced++;
 out:
 	return referenced;
 }
@@ -461,9 +524,10 @@ static int page_mkclean_one(struct page 
 	if (address == -EFAULT)
 		goto out;
 
+	emm_notify(mm, emm_invalidate_start, address, address + PAGE_SIZE);
 	pte = page_check_address(page, mm, address, &ptl);
 	if (!pte)
-		goto out;
+		goto out_notifier;
 
 	if (pte_dirty(*pte) || pte_write(*pte)) {
 		pte_t entry;
@@ -477,6 +541,9 @@ static int page_mkclean_one(struct page 
 	}
 
 	pte_unmap_unlock(pte, ptl);
+
+out_notifier:
+	emm_notify(mm, emm_invalidate_end, address, address + PAGE_SIZE);
 out:
 	return ret;
 }
@@ -716,9 +783,10 @@ static int try_to_unmap_one(struct page 
 	if (address == -EFAULT)
 		goto out;
 
+	emm_notify(mm, emm_invalidate_start, address, address + PAGE_SIZE);
 	pte = page_check_address(page, mm, address, &ptl);
 	if (!pte)
-		goto out;
+		goto out_notify;
 
 	/*
 	 * If the page is mlock()d, we cannot swap it out.
@@ -788,6 +856,8 @@ static int try_to_unmap_one(struct page 
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+out_notify:
+	emm_notify(mm, emm_invalidate_end, address, address + PAGE_SIZE);
 out:
 	return ret;
 }
@@ -826,6 +896,7 @@ static void try_to_unmap_cluster(unsigne
 	spinlock_t *ptl;
 	struct page *page;
 	unsigned long address;
+	unsigned long start;
 	unsigned long end;
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
@@ -847,6 +918,8 @@ static void try_to_unmap_cluster(unsigne
 	if (!pmd_present(*pmd))
 		return;
 
+	start = address;
+	emm_notify(mm, emm_invalidate_start, start, end);
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 
 	/* Update high watermark before we lower rss */
@@ -879,6 +952,7 @@ static void try_to_unmap_cluster(unsigne
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
+	emm_notify(mm, emm_invalidate_end, start, end);
 }
 
 static int try_to_unmap_anon(struct page *page, int migration)
Index: linux-2.6.25-rc3-mm1/kernel/fork.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/kernel/fork.c	2008-03-04 11:29:00.212326992 -0800
+++ linux-2.6.25-rc3-mm1/kernel/fork.c	2008-03-05 15:58:51.246302285 -0800
@@ -362,6 +362,9 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+#ifdef CONFIG_EMM_NOTIFIER
+		mm->emm_notifier = NULL;
+#endif
 		return mm;
 	}
 
Index: linux-2.6.25-rc3-mm1/mm/memory.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/memory.c	2008-03-04 11:29:00.600332133 -0800
+++ linux-2.6.25-rc3-mm1/mm/memory.c	2008-03-05 16:19:07.141370568 -0800
@@ -596,6 +596,7 @@ int copy_page_range(struct mm_struct *ds
 	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
+	int ret = 0;
 
 	/*
 	 * Don't copy ptes where a page fault will fill them correctly.
@@ -605,12 +606,15 @@ int copy_page_range(struct mm_struct *ds
 	 */
 	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
 		if (!vma->anon_vma)
-			return 0;
+			goto out;
 	}
 
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
+	if (is_cow_mapping(vma->vm_flags))
+		emm_notify(src_mm, emm_invalidate_start, addr, end);
+
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
 	do {
@@ -618,10 +622,16 @@ int copy_page_range(struct mm_struct *ds
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
 		if (copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-						vma, addr, next))
-			return -ENOMEM;
+						vma, addr, next)) {
+			ret = -ENOMEM;
+			break;
+		}
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
-	return 0;
+
+	if (is_cow_mapping(vma->vm_flags))
+		emm_notify(src_mm, emm_invalidate_end, addr, end);
+out:
+	return ret;
 }
 
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
@@ -894,12 +904,15 @@ unsigned long zap_page_range(struct vm_a
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
+	emm_notify(mm, emm_invalidate_start, address, end);
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
+	emm_notify(mm, emm_invalidate_end, address, end);
 	return end;
 }
 
@@ -1339,6 +1352,7 @@ int remap_pfn_range(struct vm_area_struc
 	pgd_t *pgd;
 	unsigned long next;
 	unsigned long end = addr + PAGE_ALIGN(size);
+	unsigned long start = addr;
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
@@ -1371,6 +1385,7 @@ int remap_pfn_range(struct vm_area_struc
 	BUG_ON(addr >= end);
 	pfn -= addr >> PAGE_SHIFT;
 	pgd = pgd_offset(mm, addr);
+	emm_notify(mm, emm_invalidate_start, start, end);
 	flush_cache_range(vma, addr, end);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1379,6 +1394,7 @@ int remap_pfn_range(struct vm_area_struc
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	emm_notify(mm, emm_invalidate_end, start, end);
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);
@@ -1462,10 +1478,12 @@ int apply_to_page_range(struct mm_struct
 {
 	pgd_t *pgd;
 	unsigned long next;
+	unsigned long start = addr;
 	unsigned long end = addr + size;
 	int err;
 
 	BUG_ON(addr >= end);
+	emm_notify(mm, emm_invalidate_start, start, end);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1473,6 +1491,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	emm_notify(mm, emm_invalidate_end, start, end);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
@@ -1613,8 +1632,10 @@ static int do_wp_page(struct mm_struct *
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
 			page_cache_release(old_page);
-			if (!pte_same(*page_table, orig_pte))
-				goto unlock;
+			if (!pte_same(*page_table, orig_pte)) {
+				pte_unmap_unlock(page_table, ptl);
+				goto check_dirty;
+			}
 
 			page_mkwrite = 1;
 		}
@@ -1630,7 +1651,8 @@ static int do_wp_page(struct mm_struct *
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
-		goto unlock;
+		pte_unmap_unlock(page_table, ptl);
+		goto check_dirty;
 	}
 
 	/*
@@ -1652,6 +1674,7 @@ gotten:
 	if (mem_cgroup_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
+	emm_notify(mm, emm_invalidate_start, address, address + PAGE_SIZE);
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
@@ -1690,8 +1713,11 @@ gotten:
 		page_cache_release(new_page);
 	if (old_page)
 		page_cache_release(old_page);
-unlock:
+
 	pte_unmap_unlock(page_table, ptl);
+	emm_notify(mm, emm_invalidate_end, address, address + PAGE_SIZE);
+
+check_dirty:
 	if (dirty_page) {
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
Index: linux-2.6.25-rc3-mm1/mm/mmap.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/mmap.c	2008-03-04 11:29:00.604332186 -0800
+++ linux-2.6.25-rc3-mm1/mm/mmap.c	2008-03-05 16:15:36.317854841 -0800
@@ -1751,6 +1751,7 @@ static void unmap_region(struct mm_struc
 	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
+	emm_notify(mm, emm_invalidate_start, start, end);
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
@@ -1759,6 +1760,7 @@ static void unmap_region(struct mm_struc
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	emm_notify(mm, emm_invalidate_end, start, end);
 }
 
 /*
@@ -2048,6 +2050,7 @@ void exit_mmap(struct mm_struct *mm)
 
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
+	emm_notify(mm, emm_release, 0, TASK_SIZE);
 
 	lru_add_drain();
 	flush_cache_mm(mm);
Index: linux-2.6.25-rc3-mm1/mm/mprotect.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/mprotect.c	2008-02-24 13:25:54.000000000 -0800
+++ linux-2.6.25-rc3-mm1/mm/mprotect.c	2008-03-05 16:15:53.033182172 -0800
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/rmap.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -198,10 +199,12 @@ success:
 		dirty_accountable = 1;
 	}
 
+	emm_notify(mm, emm_invalidate_start, start, end);
 	if (is_vm_hugetlb_page(vma))
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
 		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
+	emm_notify(mm, emm_invalidate_end, start, end);
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	return 0;
Index: linux-2.6.25-rc3-mm1/mm/mremap.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/mremap.c	2008-02-24 13:25:54.000000000 -0800
+++ linux-2.6.25-rc3-mm1/mm/mremap.c	2008-03-05 16:16:12.108414521 -0800
@@ -18,6 +18,7 @@
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/rmap.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -74,7 +75,9 @@ static void move_ptes(struct vm_area_str
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
+	unsigned long old_start = old_addr;
 
+	emm_notify(mm, emm_invalidate_start, old_start, old_end);
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
@@ -116,6 +119,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
+	emm_notify(mm, emm_invalidate_end, old_start, old_end);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
Index: linux-2.6.25-rc3-mm1/mm/filemap_xip.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/filemap_xip.c	2008-03-04 11:29:00.600332133 -0800
+++ linux-2.6.25-rc3-mm1/mm/filemap_xip.c	2008-03-05 16:10:01.431331796 -0800
@@ -190,6 +190,8 @@ __xip_unmap (struct address_space * mapp
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+		emm_notify(mm, emm_invalidate_start,
+					address, address + PAGE_SIZE);
 		pte = page_check_address(page, mm, address, &ptl);
 		if (pte) {
 			/* Nuke the page table entry. */
@@ -201,6 +203,8 @@ __xip_unmap (struct address_space * mapp
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);
 		}
+		emm_notify(mm, emm_invalidate_end,
+					address, address + PAGE_SIZE);
 	}
 	spin_unlock(&mapping->i_mmap_lock);
 }
Index: linux-2.6.25-rc3-mm1/mm/fremap.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/fremap.c	2008-02-24 13:25:54.000000000 -0800
+++ linux-2.6.25-rc3-mm1/mm/fremap.c	2008-03-05 16:10:13.706837775 -0800
@@ -214,7 +214,9 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	emm_notify(mm, emm_invalidate_start, start, end);
 	err = populate_range(mm, vma, start, size, pgoff);
+	emm_notify(mm, emm_invalidate_end, start, end);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
Index: linux-2.6.25-rc3-mm1/mm/hugetlb.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/hugetlb.c	2008-03-04 11:29:00.600332133 -0800
+++ linux-2.6.25-rc3-mm1/mm/hugetlb.c	2008-03-05 16:10:27.750272449 -0800
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/rmap.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -796,6 +797,7 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
+	emm_notify(mm, emm_invalidate_start, start, end);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -816,6 +818,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	emm_notify(mm, emm_invalidate_end, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
