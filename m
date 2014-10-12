Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4F157900017
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 00:51:58 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so3749032pde.8
        for <linux-mm@kvack.org>; Sat, 11 Oct 2014 21:51:57 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ov9si7510017pdb.7.2014.10.11.21.51.54
        for <linux-mm@kvack.org>;
        Sat, 11 Oct 2014 21:51:55 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
Date: Sun, 12 Oct 2014 12:41:54 +0800
Message-Id: <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, Qiaowei Ren <qiaowei.ren@intel.com>

There are two mappings in play: 1. The mapping with the actual data,
which userspace is munmap()ing or brk()ing away, etc... 2. The mapping
for the bounds table *backing* the data (is tagged with mpx_vma_ops,
see the patch "add MPX specific mmap interface").

If userspace use the prctl() indroduced earlier in this patchset to
enable the management of bounds tables in kernel, when it unmaps the
first kind of mapping with the actual data, kernel needs to free the
mapping for the bounds table backing the data. This patch calls
arch_unmap() at the very end of do_unmap() to do so. This will walk
the directory to look at the entries covered in the data vma and unmaps
the bounds table which is referenced from the directory and then clears
the directory entry.

Unmapping of bounds tables is called under vm_munmap() of the data VMA.
So we have to check ->vm_ops to prevent recursion. This recursion represents
having bounds tables for bounds tables, which should not occur normally.
Being strict about it here helps ensure that we do not have an exploitable
stack overflow.

Once we unmap the bounds table, we would have a bounds directory entry
pointing at empty address space. That address space could now be allocated
for some other (random) use, and the MPX hardware is now going to go
trying to walk it as if it were a bounds table. That would be bad. So
any unmapping of a bounds table has to be accompanied by a corresponding
write to the bounds directory entry to have it invalid. That write to
the bounds directory can fault.

Since we are doing the freeing from munmap() (and other paths like it),
we hold mmap_sem for write. If we fault, the page fault handler will
attempt to acquire mmap_sem for read and we will deadlock. For now, to
avoid deadlock, we disable page faults while touching the bounds directory
entry. This keeps us from being able to free the tables in this case.
This deficiency will be addressed in later patches.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/x86/include/asm/mmu_context.h |   16 ++
 arch/x86/include/asm/mpx.h         |    9 +
 arch/x86/mm/mpx.c                  |  317 ++++++++++++++++++++++++++++++++++++
 include/asm-generic/mmu_context.h  |    6 +
 mm/mmap.c                          |    2 +
 5 files changed, 350 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index e33ddb7..2b52d1b 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -111,4 +111,20 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
 #endif
 }
 
+static inline void arch_unmap(struct mm_struct *mm,
+		struct vm_area_struct *vma,
+		unsigned long start, unsigned long end)
+{
+#ifdef CONFIG_X86_INTEL_MPX
+	/*
+	 * Userspace never asked us to manage the bounds tables,
+	 * so refuse to help.
+	 */
+	if (!kernel_managing_mpx_tables(current->mm))
+		return;
+
+	mpx_notify_unmap(mm, vma, start, end);
+#endif
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
index 32f13f5..a1a0155 100644
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -48,6 +48,13 @@
 #define MPX_BD_SIZE_BYTES (1UL<<(MPX_BD_ENTRY_OFFSET+MPX_BD_ENTRY_SHIFT))
 #define MPX_BT_SIZE_BYTES (1UL<<(MPX_BT_ENTRY_OFFSET+MPX_BT_ENTRY_SHIFT))
 
+#define MPX_BD_ENTRY_MASK	((1<<MPX_BD_ENTRY_OFFSET)-1)
+#define MPX_BT_ENTRY_MASK	((1<<MPX_BT_ENTRY_OFFSET)-1)
+#define MPX_GET_BD_ENTRY_OFFSET(addr)	((((addr)>>(MPX_BT_ENTRY_OFFSET+ \
+		MPX_IGN_BITS)) & MPX_BD_ENTRY_MASK) << MPX_BD_ENTRY_SHIFT)
+#define MPX_GET_BT_ENTRY_OFFSET(addr)	((((addr)>>MPX_IGN_BITS) & \
+		MPX_BT_ENTRY_MASK) << MPX_BT_ENTRY_SHIFT)
+
 #define MPX_BNDSTA_ERROR_CODE	0x3
 #define MPX_BNDCFG_ENABLE_FLAG	0x1
 #define MPX_BD_ENTRY_VALID_FLAG	0x1
@@ -73,6 +80,8 @@ static inline int kernel_managing_mpx_tables(struct mm_struct *mm)
 	return (mm->bd_addr != MPX_INVALID_BOUNDS_DIR);
 }
 unsigned long mpx_mmap(unsigned long len);
+void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long start, unsigned long end);
 
 #ifdef CONFIG_X86_INTEL_MPX
 int do_mpx_bt_fault(struct xsave_struct *xsave_buf);
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 376f2ee..dcc6621 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -1,7 +1,16 @@
+/*
+ * mpx.c - Memory Protection eXtensions
+ *
+ * Copyright (c) 2014, Intel Corporation.
+ * Qiaowei Ren <qiaowei.ren@intel.com>
+ * Dave Hansen <dave.hansen@intel.com>
+ */
+
 #include <linux/kernel.h>
 #include <linux/syscalls.h>
 #include <asm/mpx.h>
 #include <asm/mman.h>
+#include <asm/mmu_context.h>
 #include <linux/sched/sysctl.h>
 
 static const char *mpx_mapping_name(struct vm_area_struct *vma)
@@ -13,6 +22,11 @@ static struct vm_operations_struct mpx_vma_ops = {
 	.name = mpx_mapping_name,
 };
 
+int is_mpx_vma(struct vm_area_struct *vma)
+{
+	return (vma->vm_ops == &mpx_vma_ops);
+}
+
 /*
  * this is really a simplified "vm_mmap". it only handles mpx
  * related maps, including bounds table and bounds directory.
@@ -66,3 +80,306 @@ unsigned long mpx_mmap(unsigned long len)
 
 	return ret;
 }
+
+/*
+ * Get the base of bounds tables pointed by specific bounds
+ * directory entry.
+ */
+static int get_bt_addr(long __user *bd_entry, unsigned long *bt_addr)
+{
+	int ret;
+	int valid;
+
+	if (!access_ok(VERIFY_READ, (bd_entry), sizeof(*bd_entry)))
+		return -EFAULT;
+
+	pagefault_disable();
+	ret = get_user(*bt_addr, bd_entry);
+	pagefault_enable();
+	if (ret)
+		return ret;
+
+	valid = *bt_addr & MPX_BD_ENTRY_VALID_FLAG;
+	*bt_addr &= MPX_BT_ADDR_MASK;
+
+	/*
+	 * When the kernel is managing bounds tables, a bounds directory
+	 * entry will either have a valid address (plus the valid bit)
+	 * *OR* be completely empty. If we see a !valid entry *and* some
+	 * data in the address field, we know something is wrong. This
+	 * -EINVAL return will cause a SIGSEGV.
+	 */
+	if (!valid && *bt_addr)
+		return -EINVAL;
+	/*
+	 * Not present is OK.  It just means there was no bounds table
+	 * for this memory, which is completely OK.  Make sure to distinguish
+	 * this from -EINVAL, which will cause a SEGV.
+	 */
+	if (!valid)
+		return -ENOENT;
+
+	return 0;
+}
+
+/*
+ * Free the backing physical pages of bounds table 'bt_addr'.
+ * Assume start...end is within that bounds table.
+ */
+static int zap_bt_entries(struct mm_struct *mm,
+		unsigned long bt_addr,
+		unsigned long start, unsigned long end)
+{
+	struct vm_area_struct *vma;
+	unsigned long addr, len;
+
+	/*
+	 * Find the first overlapping vma. If vma->vm_start > start, there
+	 * will be a hole in the bounds table. This -EINVAL return will
+	 * cause a SIGSEGV.
+	 */
+	vma = find_vma(mm, start);
+	if (!vma || vma->vm_start > start)
+		return -EINVAL;
+
+	/*
+	 * A NUMA policy on a VM_MPX VMA could cause this bouds table to
+	 * be split. So we need to look across the entire 'start -> end'
+	 * range of this bounds table, find all of the VM_MPX VMAs, and
+	 * zap only those.
+	 */
+	addr = start;
+	while (vma && vma->vm_start < end) {
+		/*
+		 * If one VMA which is not for MPX is found in the middle
+		 * of this bounds table, this -EINVAL return will cause a
+		 * SIGSEGV.
+		 */
+		if (!(vma->vm_flags & VM_MPX))
+			return -EINVAL;
+
+		len = min(vma->vm_end, end) - addr;
+		zap_page_range(vma, addr, len, NULL);
+
+		vma = vma->vm_next;
+		addr = vma->vm_start;
+	}
+
+	return 0;
+}
+
+static int unmap_single_bt(struct mm_struct *mm,
+		long __user *bd_entry, unsigned long bt_addr)
+{
+	unsigned long expected_old_val = bt_addr | MPX_BD_ENTRY_VALID_FLAG;
+	unsigned long actual_old_val = 0;
+	int ret;
+
+	/*
+	 * The whole bounds tables freeing code will be called under
+	 * mm->mmap_sem write-lock. So the value of bd_entry could not
+	 * be changed during this period, and 'actual_old_val' will be
+	 * equal to 'expected_old_val'.
+	 */
+	pagefault_disable();
+	ret = user_atomic_cmpxchg_inatomic(&actual_old_val, bd_entry,
+			expected_old_val, 0);
+	pagefault_enable();
+	if (ret)
+		return ret;
+
+	/*
+	 * Note, we are likely being called under do_munmap() already. To
+	 * avoid recursion, do_munmap() will check whether it comes
+	 * from one bounds table through VM_MPX flag.
+	 */
+	return do_munmap(mm, bt_addr, MPX_BT_SIZE_BYTES);
+}
+
+/*
+ * If the bounds table pointed by bounds directory 'bd_entry' is
+ * not shared, unmap this whole bounds table. Otherwise, only free
+ * those backing physical pages of bounds table entries covered
+ * in this virtual address region start...end.
+ */
+static int unmap_shared_bt(struct mm_struct *mm,
+		long __user *bd_entry, unsigned long start,
+		unsigned long end, bool prev_shared, bool next_shared)
+{
+	unsigned long bt_addr;
+	int ret;
+
+	ret = get_bt_addr(bd_entry, &bt_addr);
+	if (ret)
+		return ret;
+
+	if (prev_shared && next_shared)
+		ret = zap_bt_entries(mm, bt_addr,
+				bt_addr+MPX_GET_BT_ENTRY_OFFSET(start),
+				bt_addr+MPX_GET_BT_ENTRY_OFFSET(end));
+	else if (prev_shared)
+		ret = zap_bt_entries(mm, bt_addr,
+				bt_addr+MPX_GET_BT_ENTRY_OFFSET(start),
+				bt_addr+MPX_BT_SIZE_BYTES);
+	else if (next_shared)
+		ret = zap_bt_entries(mm, bt_addr, bt_addr,
+				bt_addr+MPX_GET_BT_ENTRY_OFFSET(end));
+	else
+		ret = unmap_single_bt(mm, bd_entry, bt_addr);
+
+	return ret;
+}
+
+/*
+ * A virtual address region being munmap()ed might share bounds table
+ * with adjacent VMAs. We only need to free the backing physical
+ * memory of these shared bounds tables entries covered in this virtual
+ * address region.
+ */
+static int unmap_edge_bts(struct mm_struct *mm,
+		unsigned long start, unsigned long end)
+{
+	int ret;
+	long __user *bde_start, *bde_end;
+	struct vm_area_struct *prev, *next;
+	bool prev_shared = false, next_shared = false;
+
+	bde_start = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(start);
+	bde_end = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(end-1);
+
+	/*
+	 * Check whether bde_start and bde_end are shared with adjacent
+	 * VMAs.
+	 *
+	 * We already unliked the VMAs from the mm's rbtree so 'start'
+	 * is guaranteed to be in a hole. This gets us the first VMA
+	 * before the hole in to 'prev' and the next VMA after the hole
+	 * in to 'next'.
+	 */
+	next = find_vma_prev(mm, start, &prev);
+	if (prev && (mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(prev->vm_end-1))
+			== bde_start)
+		prev_shared = true;
+	if (next && (mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(next->vm_start))
+			== bde_end)
+		next_shared = true;
+
+	/*
+	 * This virtual address region being munmap()ed is only
+	 * covered by one bounds table.
+	 *
+	 * In this case, if this table is also shared with adjacent
+	 * VMAs, only part of the backing physical memory of the bounds
+	 * table need be freeed. Otherwise the whole bounds table need
+	 * be unmapped.
+	 */
+	if (bde_start == bde_end) {
+		return unmap_shared_bt(mm, bde_start, start, end,
+				prev_shared, next_shared);
+	}
+
+	/*
+	 * If more than one bounds tables are covered in this virtual
+	 * address region being munmap()ed, we need to separately check
+	 * whether bde_start and bde_end are shared with adjacent VMAs.
+	 */
+	ret = unmap_shared_bt(mm, bde_start, start, end, prev_shared, false);
+	if (ret)
+		return ret;
+
+	ret = unmap_shared_bt(mm, bde_end, start, end, false, next_shared);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
+static int mpx_unmap_tables_for(struct mm_struct *mm,
+		unsigned long start, unsigned long end)
+{
+	int ret;
+	long __user *bd_entry, *bde_start, *bde_end;
+	unsigned long bt_addr;
+
+	/*
+	 * "Edge" bounds tables are those which are being used by the region
+	 * (start -> end), but that may be shared with adjacent areas.  If they
+	 * turn out to be completely unshared, they will be freed.  If they are
+	 * shared, we will free the backing store (like an MADV_DONTNEED) for
+	 * areas used by this region.
+	 */
+	ret = unmap_edge_bts(mm, start, end);
+	if (ret == -EFAULT)
+		return ret;
+
+	/*
+	 * Only unmap the bounds table that are
+	 *   1. fully covered
+	 *   2. not at the edges of the mapping, even if full aligned
+	 */
+	bde_start = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(start);
+	bde_end = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(end-1);
+	for (bd_entry = bde_start + 1; bd_entry < bde_end; bd_entry++) {
+		ret = get_bt_addr(bd_entry, &bt_addr);
+		/*
+		 * A fault means we have to drop mmap_sem,
+		 * perform the fault, and retry this somehow.
+		 */
+		if (ret == -EFAULT)
+			return ret;
+		/*
+		 * Any other issue (like a bad bounds-directory)
+		 * we can try the next one.
+		 */
+		if (ret)
+			continue;
+
+		ret = unmap_single_bt(mm, bd_entry, bt_addr);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+/*
+ * Free unused bounds tables covered in a virtual address region being
+ * munmap()ed. Assume end > start.
+ *
+ * This function will be called by do_munmap(), and the VMAs covering
+ * the virtual address region start...end have already been split if
+ * necessary, and the 'vma' is the first vma in this range (start -> end).
+ */
+void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long start, unsigned long end)
+{
+	int ret;
+
+	/*
+	 * This will look across the entire 'start -> end' range,
+	 * and find all of the non-VM_MPX VMAs.
+	 *
+	 * To avoid recursion, if a VM_MPX vma is found in the range
+	 * (start->end), we will not continue follow-up work. This
+	 * recursion represents having bounds tables for bounds tables,
+	 * which should not occur normally. Being strict about it here
+	 * helps ensure that we do not have an exploitable stack overflow.
+	 */
+	do {
+		if (vma->vm_flags & VM_MPX)
+			return;
+		vma = vma->vm_next;
+	} while (vma && vma->vm_start < end);
+
+	ret = mpx_unmap_tables_for(mm, start, end);
+	if (ret == -EFAULT) {
+		/*
+		 * FIXME: If access to the bounds directory fault, we
+		 * need handle that outside of the mmap sem held region.
+		 */
+		return;
+	}
+
+	if (ret == -EINVAL)
+		force_sig(SIGSEGV, current);
+}
diff --git a/include/asm-generic/mmu_context.h b/include/asm-generic/mmu_context.h
index 1f2a8f9..aa2d8ba 100644
--- a/include/asm-generic/mmu_context.h
+++ b/include/asm-generic/mmu_context.h
@@ -47,4 +47,10 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
 {
 }
 
+static inline void arch_unmap(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+}
+
 #endif /* __ASM_GENERIC_MMU_CONTEXT_H */
diff --git a/mm/mmap.c b/mm/mmap.c
index c0a3637..6246437 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2580,6 +2580,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
 	unmap_region(mm, vma, prev, start, end);
 
+	arch_unmap(mm, vma, start, end);
+
 	/* Fix up all other VM information */
 	remove_vma_list(mm, vma);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
