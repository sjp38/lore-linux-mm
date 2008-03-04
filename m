Date: Mon, 3 Mar 2008 23:31:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Notifier for Externally Mapped Memory (EMM)
In-Reply-To: <47CC9B57.5050402@qumranet.com>
Message-ID: <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
References: <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de>
 <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random>
 <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random>
 <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random>
 <20080302155457.GK8091@v2.random> <20080303213707.GA8091@v2.random>
 <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Stripped things down and did what Andrea and I talked about last Friday.
No invalidate_page callbacks. No ops anymore. Simple linked list for 
notifier. No RCU. Added the code to rmap.h and rmap.c (after all it is 
concerned with handling mappings).



This patch implements a simple callback for device drivers that establish
their own references to pages (KVM, GRU, XPmem, RDMA/Infiniband, DMA engines
etc). These references are unknown to the VM (therefore external).

With these callbacks it is possible for the device driver to release external
references when the VM requests it. This enables swapping, page migration and
allows support of remapping, permission changes etc etc for externally
mapped memory.

With this functionality it becomes possible to avoid pinning or mlocking
pages (commonly done to stop the VM from unmapping pages).

A device driver must subscribe to a process using

	emm_register_notifier

The VM will then perform callbacks for operations that unmap or change
permissions of pages in that address space. When the process terminates
the callback function is called with emm_release.

Callbacks are performed before and after the unmapping action of the VM.

	emm_invalidate_start	before
	emm_invalidate_end	after

Callbacks are mostly performed in a non atomic context. However, in
various places spinlocks are held to traverse rmaps. So this patch here
is only useful for those devices that can remove mappings in an atomic
context (f.e. KVM/GRU).

If the rmap traversal spinlocks are converted to semaphores then all 
callbacks willbe performed in a nonatomic context. Callouts can stay 
where they are.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm_types.h |    3 +
 include/linux/rmap.h     |   51 +++++++++++++++++++++++++++++++++
 kernel/fork.c            |    3 +
 mm/Kconfig               |    5 +++
 mm/filemap_xip.c         |    5 +++
 mm/fremap.c              |    2 +
 mm/hugetlb.c             |    4 ++
 mm/memory.c              |   32 ++++++++++++++++++--
 mm/mmap.c                |    3 +
 mm/mprotect.c            |    3 +
 mm/mremap.c              |    5 +++
 mm/rmap.c                |   72 ++++++++++++++++++++++++++++++++++++++++++++++-
 12 files changed, 183 insertions(+), 5 deletions(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2008-03-03 22:54:11.961264684 -0800
+++ linux-2.6/include/linux/mm_types.h	2008-03-03 22:55:13.333569600 -0800
@@ -225,6 +225,9 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
+#ifdef CONFIG_EMM_NOTIFIER
+	struct emm_notifier	*emm_notifier;
+#endif
 #ifdef CONFIG_CGROUP_MEM_CONT
 	struct mem_cgroup *mem_cgroup;
 #endif
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2008-03-03 22:54:11.993264520 -0800
+++ linux-2.6/mm/Kconfig	2008-03-03 22:55:13.337569625 -0800
@@ -193,3 +193,8 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config EMM_NOTIFIER
+	def_bool n
+	bool "External Mapped Memory Notifier for drivers directly mapping memory"
+
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-03-03 22:54:12.053265354 -0800
+++ linux-2.6/mm/mmap.c	2008-03-03 22:59:25.522848812 -0800
@@ -1747,11 +1747,13 @@ static void unmap_region(struct mm_struc
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+	emm_notify(mm, emm_invalidate_start, start, end);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	emm_notify(mm, emm_invalidate_end, start, end);
 }
 
 /*
@@ -2038,6 +2040,7 @@ void exit_mmap(struct mm_struct *mm)
 
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
+	emm_notify(mm, emm_release, 0, TASK_SIZE);
 
 	lru_add_drain();
 	flush_cache_mm(mm);
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c	2008-03-03 22:54:12.069264942 -0800
+++ linux-2.6/mm/mprotect.c	2008-03-03 22:55:13.337569625 -0800
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
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c	2008-03-03 22:54:12.077265005 -0800
+++ linux-2.6/mm/mremap.c	2008-03-03 22:59:25.530848880 -0800
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
@@ -98,6 +101,7 @@ static void move_ptes(struct vm_area_str
 	new_ptl = pte_lockptr(mm, new_pmd);
 	if (new_ptl != old_ptl)
 		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+
 	arch_enter_lazy_mmu_mode();
 
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
@@ -116,6 +120,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
+	emm_notify(mm, emm_invalidate_end, old_start, old_end);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2008-03-03 22:54:12.089265604 -0800
+++ linux-2.6/mm/rmap.c	2008-03-03 22:59:25.542848702 -0800
@@ -298,6 +298,10 @@ static int page_referenced_one(struct pa
 
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
+	if (!referenced)
+		/* rmap lock held */
+		referenced = emm_notify(mm, emm_referenced,
+					address, address + PAGE_SIZE);
 out:
 	return referenced;
 }
@@ -446,6 +450,8 @@ static int page_mkclean_one(struct page 
 	if (address == -EFAULT)
 		goto out;
 
+	/* rmap lock held */
+	emm_notify(mm, emm_invalidate_start, address, address + PAGE_SIZE);
 	pte = page_check_address(page, mm, address, &ptl);
 	if (!pte)
 		goto out;
@@ -462,6 +468,7 @@ static int page_mkclean_one(struct page 
 	}
 
 	pte_unmap_unlock(pte, ptl);
+	emm_notify(mm, emm_invalidate_end, address, address + PAGE_SIZE);
 out:
 	return ret;
 }
@@ -702,9 +709,11 @@ static int try_to_unmap_one(struct page 
 	if (address == -EFAULT)
 		goto out;
 
+	/* rmap lock held */
+	emm_notify(mm, emm_invalidate_start, address, address + PAGE_SIZE);
 	pte = page_check_address(page, mm, address, &ptl);
 	if (!pte)
-		goto out;
+		goto out_notify;
 
 	/*
 	 * If the page is mlock()d, we cannot swap it out.
@@ -774,6 +783,8 @@ static int try_to_unmap_one(struct page 
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+out_notify:
+	emm_notify(mm, emm_invalidate_end, address, address + PAGE_SIZE);
 out:
 	return ret;
 }
@@ -812,6 +823,7 @@ static void try_to_unmap_cluster(unsigne
 	spinlock_t *ptl;
 	struct page *page;
 	unsigned long address;
+	unsigned long start;
 	unsigned long end;
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
@@ -833,6 +845,8 @@ static void try_to_unmap_cluster(unsigne
 	if (!pmd_present(*pmd))
 		return;
 
+	start = address;
+	emm_notify(mm, emm_invalidate_start, start, end);
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 
 	/* Update high watermark before we lower rss */
@@ -865,6 +879,7 @@ static void try_to_unmap_cluster(unsigne
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
+	emm_notify(mm, emm_invalidate_end, start, end);
 }
 
 static int try_to_unmap_anon(struct page *page, int migration)
@@ -1011,3 +1026,58 @@ int try_to_unmap(struct page *page, int 
 	return ret;
 }
 
+/*
+ * Notifier for devices establishing their own references to Linux
+ * kernel pages in addition to the regular mapping via page
+ * table and rmap. The notifier allows the device to drop the mapping
+ * when the VM removes references to pages.
+ *
+ *  Copyright (C) 2008  SGI
+ *             Christoph Lameter <clameter@sgi.com>
+ */
+
+#ifdef CONFIG_EMM_NOTIFIER
+/*
+ * No synchronization. This function can only be called when only a single
+ * process remains that performs teardown.
+ */
+void emm_notifier_release(struct mm_struct *mm)
+{
+	struct emm_notifier *e;
+
+	while (mm->emm_notifier) {
+		e = mm->emm_notifier;
+		mm->emm_notifier = e->next;
+		e->func(e, mm, emm_release, 0, 0);
+	}
+}
+EXPORT_SYMBOL_GPL(emm_notifier_release);
+
+/* Register a notifier */
+void emm_notifier_register(struct emm_notifier *e, struct mm_struct *mm)
+{
+	e->next = mm->emm_notifier;
+	mm->emm_notifier = e;
+}
+EXPORT_SYMBOL_GPL(emm_notifier_register);
+
+/* Perform a callback */
+int __emm_notify(struct mm_struct *mm, enum emm_operations op,
+		unsigned long start, unsigned long end)
+{
+	struct emm_notifier *e = mm->emm_notifier;
+	int x;
+
+	while (e) {
+		if (e->func) {
+			x = e->func(e, mm, op, start, end);
+			if (x)
+				return x;
+		}
+		e = e->next;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__emm_notify);
+#endif
+
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-03-03 22:54:12.041265025 -0800
+++ linux-2.6/mm/memory.c	2008-03-03 22:59:25.502849006 -0800
@@ -611,6 +611,9 @@ int copy_page_range(struct mm_struct *ds
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
+	if (is_cow_mapping(vma->vm_flags))
+		emm_notify(src_mm, emm_invalidate_start, addr, end);
+
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
 	do {
@@ -621,6 +624,10 @@ int copy_page_range(struct mm_struct *ds
 						vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+
+	if (is_cow_mapping(vma->vm_flags))
+		emm_notify(src_mm, emm_invalidate_end, addr, end);
+
 	return 0;
 }
 
@@ -897,7 +904,11 @@ unsigned long zap_page_range(struct vm_a
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+
+	/* i_mmap_lock may be held */
+	emm_notify(mm, emm_invalidate_start, address, end);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	emm_notify(mm, emm_invalidate_end, address, end);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
@@ -1340,6 +1351,7 @@ int remap_pfn_range(struct vm_area_struc
 	pgd_t *pgd;
 	unsigned long next;
 	unsigned long end = addr + PAGE_ALIGN(size);
+	unsigned long start = addr;
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
@@ -1372,6 +1384,7 @@ int remap_pfn_range(struct vm_area_struc
 	BUG_ON(addr >= end);
 	pfn -= addr >> PAGE_SHIFT;
 	pgd = pgd_offset(mm, addr);
+	emm_notify(mm, emm_invalidate_start, start, end);
 	flush_cache_range(vma, addr, end);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1380,6 +1393,7 @@ int remap_pfn_range(struct vm_area_struc
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	emm_notify(mm, emm_invalidate_end, start, end);
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);
@@ -1463,10 +1477,12 @@ int apply_to_page_range(struct mm_struct
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
@@ -1474,6 +1490,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	emm_notify(mm, emm_invalidate_end, start, end);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
@@ -1614,8 +1631,10 @@ static int do_wp_page(struct mm_struct *
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
@@ -1631,7 +1650,8 @@ static int do_wp_page(struct mm_struct *
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
-		goto unlock;
+		pte_unmap_unlock(page_table, ptl);
+		goto check_dirty;
 	}
 
 	/*
@@ -1653,6 +1673,7 @@ gotten:
 	if (mem_cgroup_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
+	emm_notify(mm, emm_invalidate_start, address, address + PAGE_SIZE);
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
@@ -1691,8 +1712,11 @@ gotten:
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
Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h	2008-02-14 15:20:13.185930864 -0800
+++ linux-2.6/include/linux/rmap.h	2008-03-03 22:55:13.341569687 -0800
@@ -133,4 +133,55 @@ static inline int page_mkclean(struct pa
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 
+/*
+ * Notifier for devices establishing their own references to Linux
+ * kernel pages in addition to the regular mapping via page
+ * table and rmap. The notifier allows the device to drop the mapping
+ * when the VM removes references to pages.
+ */
+enum emm_operations {
+	emm_release,		/* Process existing, */
+	emm_invalidate_start,	/* Before the VM unmaps pages */
+	emm_invalidate_end,	/* After the VM unmapped pages */
+	emm_referenced		/* Check if a range was referenced */
+};
+
+struct emm_notifier {
+	int (*func)(struct emm_notifier *e, struct mm_struct *mm,
+		enum emm_operations op,
+		unsigned long start, unsigned long end);
+	struct emm_notifier *next;
+};
+
+extern int __emm_notify(struct mm_struct *mm, enum emm_operations op,
+		unsigned long start, unsigned long end);
+
+static inline int mm_has_emm_notifier(struct mm_struct *mm)
+{
+#ifdef CONFIG_EMM_NOTIFIER
+	return unlikely(mm->emm_notifier);
+#else
+	return 0;
+#endif
+}
+
+static inline int emm_notify(struct mm_struct *mm, enum emm_operations op,
+	unsigned long start, unsigned long end)
+{
+#ifdef CONFIG_EMM_NOTIFIER
+	if (mm_has_emm_notifier(mm))
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
 #endif	/* _LINUX_RMAP_H */
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2008-03-03 22:54:11.985264714 -0800
+++ linux-2.6/kernel/fork.c	2008-03-03 22:59:27.230858013 -0800
@@ -362,6 +362,9 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+#ifdef CONFIG_EMM_NOTIFIER
+		mm->emm_notifier = NULL;
+#endif
 		return mm;
 	}
 
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c	2008-03-03 22:54:12.013264644 -0800
+++ linux-2.6/mm/filemap_xip.c	2008-03-03 22:59:25.474848348 -0800
@@ -190,6 +190,9 @@ __xip_unmap (struct address_space * mapp
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+		/* i_mmap_lock held */
+		emm_notify(mm, emm_invalidate_start,
+					address, address + PAGE_SIZE);
 		pte = page_check_address(page, mm, address, &ptl);
 		if (pte) {
 			/* Nuke the page table entry. */
@@ -201,6 +204,8 @@ __xip_unmap (struct address_space * mapp
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);
 		}
+		emm_notify(mm, emm_invalidate_end,
+					address, address + PAGE_SIZE);
 	}
 	spin_unlock(&mapping->i_mmap_lock);
 }
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2008-03-03 22:54:12.021264688 -0800
+++ linux-2.6/mm/fremap.c	2008-03-03 22:59:25.482848555 -0800
@@ -214,7 +214,9 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	emm_notify(mm, emm_invalidate_start, start, end);
 	err = populate_range(mm, vma, start, size, pgoff);
+	emm_notify(mm, emm_invalidate_end, start, end);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-03-03 22:54:12.033264769 -0800
+++ linux-2.6/mm/hugetlb.c	2008-03-03 22:59:27.230858013 -0800
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/rmap.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -755,6 +756,8 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
+	/* i_mmap_lock held */
+	emm_notify(mm, emm_invalidate_start, start, end);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -775,6 +778,7 @@ void __unmap_hugepage_range(struct vm_ar
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
