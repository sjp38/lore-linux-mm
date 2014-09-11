Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C01666B0072
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:54:55 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so8854274pab.4
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:54:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id jx1si241924pbd.192.2014.09.11.01.54.54
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 01:54:54 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v8 09/10] x86, mpx: cleanup unused bound tables
Date: Thu, 11 Sep 2014 16:46:49 +0800
Message-Id: <1410425210-24789-10-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qiaowei Ren <qiaowei.ren@intel.com>

Since the kernel allocated those tables on-demand without userspace
knowledge, it is also responsible for freeing them when the associated
mappings go away.

Here, the solution for this issue is to hook do_munmap() to check
whether one process is MPX enabled. If yes, those bounds tables covered
in the virtual address region which is being unmapped will be freed also.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/x86/include/asm/mmu_context.h |   16 +++
 arch/x86/include/asm/mpx.h         |    9 ++
 arch/x86/mm/mpx.c                  |  252 ++++++++++++++++++++++++++++++++++++
 include/asm-generic/mmu_context.h  |    6 +
 mm/mmap.c                          |    2 +
 5 files changed, 285 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 166af2a..d13e01c 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -10,6 +10,7 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
+#include <asm/mpx.h>
 #ifndef CONFIG_PARAVIRT
 #include <asm-generic/mm_hooks.h>
 
@@ -102,4 +103,19 @@ do {						\
 } while (0)
 #endif
 
+static inline void arch_unmap(struct mm_struct *mm,
+		struct vm_area_struct *vma,
+		unsigned long start, unsigned long end)
+{
+#ifdef CONFIG_X86_INTEL_MPX
+	/*
+	 * Check whether this vma comes from MPX-enabled application.
+	 * If so, release this vma related bound tables.
+	 */
+	if (mm->bd_addr && !(vma->vm_flags & VM_MPX))
+		mpx_unmap(mm, start, end);
+
+#endif
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
index 6cb0853..e848a74 100644
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -42,6 +42,13 @@
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
@@ -63,6 +70,8 @@ struct mpx_insn {
 #define MAX_MPX_INSN_SIZE	15
 
 unsigned long mpx_mmap(unsigned long len);
+void mpx_unmap(struct mm_struct *mm,
+		unsigned long start, unsigned long end);
 
 #ifdef CONFIG_X86_INTEL_MPX
 int do_mpx_bt_fault(struct xsave_struct *xsave_buf);
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index e1b28e6..feb1f01 100644
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
@@ -77,3 +86,246 @@ out:
 	up_write(&mm->mmap_sem);
 	return ret;
 }
+
+/*
+ * Get the base of bounds tables pointed by specific bounds
+ * directory entry.
+ */
+static int get_bt_addr(long __user *bd_entry, unsigned long *bt_addr)
+{
+	int valid;
+
+	if (!access_ok(VERIFY_READ, (bd_entry), sizeof(*(bd_entry))))
+		return -EFAULT;
+
+	pagefault_disable();
+	if (get_user(*bt_addr, bd_entry))
+		goto out;
+	pagefault_enable();
+
+	valid = *bt_addr & MPX_BD_ENTRY_VALID_FLAG;
+	*bt_addr &= MPX_BT_ADDR_MASK;
+
+	/*
+	 * If this bounds directory entry is nonzero, and meanwhile
+	 * the valid bit is zero, one SIGSEGV will be produced due to
+	 * this unexpected situation.
+	 */
+	if (!valid && *bt_addr)
+		return -EINVAL;
+	if (!valid)
+		return -ENOENT;
+
+	return 0;
+
+out:
+	pagefault_enable();
+	return -EFAULT;
+}
+
+/*
+ * Free the backing physical pages of bounds table 'bt_addr'.
+ * Assume start...end is within that bounds table.
+ */
+static int __must_check zap_bt_entries(struct mm_struct *mm,
+		unsigned long bt_addr,
+		unsigned long start, unsigned long end)
+{
+	struct vm_area_struct *vma;
+
+	/* Find the vma which overlaps this bounds table */
+	vma = find_vma(mm, bt_addr);
+	/*
+	 * The table entry comes from userspace and could be
+	 * pointing anywhere, so make sure it is at least
+	 * pointing to valid memory.
+	 */
+	if (!vma || !(vma->vm_flags & VM_MPX) ||
+			vma->vm_start > bt_addr ||
+			vma->vm_end < bt_addr+MPX_BT_SIZE_BYTES)
+		return -EINVAL;
+
+	zap_page_range(vma, start, end - start, NULL);
+	return 0;
+}
+
+static int __must_check unmap_single_bt(struct mm_struct *mm,
+		long __user *bd_entry, unsigned long bt_addr)
+{
+	int ret;
+
+	pagefault_disable();
+	ret = user_atomic_cmpxchg_inatomic(&bt_addr, bd_entry,
+			bt_addr | MPX_BD_ENTRY_VALID_FLAG, 0);
+	pagefault_enable();
+	if (ret)
+		return -EFAULT;
+
+	/*
+	 * to avoid recursion, do_munmap() will check whether it comes
+	 * from one bounds table through VM_MPX flag.
+	 */
+	return do_munmap(mm, bt_addr & MPX_BT_ADDR_MASK, MPX_BT_SIZE_BYTES);
+}
+
+/*
+ * If the bounds table pointed by bounds directory 'bd_entry' is
+ * not shared, unmap this whole bounds table. Otherwise, only free
+ * those backing physical pages of bounds table entries covered
+ * in this virtual address region start...end.
+ */
+static int __must_check unmap_shared_bt(struct mm_struct *mm,
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
+ *
+ * the VMAs covering the virtual address region start...end have already
+ * been split if necessary and removed from the VMA list.
+ */
+static int __must_check unmap_side_bts(struct mm_struct *mm,
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
+	 * VMAs. Because the VMAs covering the virtual address region
+	 * start...end have already been removed from the VMA list, if
+	 * next is not NULL it will satisfy start < end <= next->vm_start.
+	 * And if prev is not NULL, prev->vm_end <= start < end.
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
+static int __must_check mpx_try_unmap(struct mm_struct *mm,
+		unsigned long start, unsigned long end)
+{
+	int ret;
+	long __user *bd_entry, *bde_start, *bde_end;
+	unsigned long bt_addr;
+
+	/*
+	 * unmap bounds tables pointed out by start/end bounds directory
+	 * entries, or only free part of their backing physical memroy
+	 * if they are shared with adjacent VMAs.
+	 */
+	ret = unmap_side_bts(mm, start, end);
+	if (ret == -EFAULT)
+		return ret;
+
+	/*
+	 * unmap those bounds table which are entirely covered in this
+	 * virtual address region.
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
+ * necessary and remvoed from the VMA list.
+ */
+void mpx_unmap(struct mm_struct *mm,
+		unsigned long start, unsigned long end)
+{
+	int ret;
+
+	ret = mpx_try_unmap(mm, start, end);
+	if (ret == -EINVAL)
+		force_sig(SIGSEGV, current);
+}
diff --git a/include/asm-generic/mmu_context.h b/include/asm-generic/mmu_context.h
index a7eec91..ac558ca 100644
--- a/include/asm-generic/mmu_context.h
+++ b/include/asm-generic/mmu_context.h
@@ -42,4 +42,10 @@ static inline void activate_mm(struct mm_struct *prev_mm,
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
index c1f2ea4..abe533f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2583,6 +2583,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	/* Fix up all other VM information */
 	remove_vma_list(mm, vma);
 
+	arch_unmap(mm, vma, start, end);
+
 	return 0;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
