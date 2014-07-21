Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2326E6B004D
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 01:42:48 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so9000432pad.8
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 22:42:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j3si1107912pdd.56.2014.07.20.22.42.46
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 22:42:47 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v7 09/10] x86, mpx: cleanup unused bound tables
Date: Mon, 21 Jul 2014 13:38:43 +0800
Message-Id: <1405921124-4230-10-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Qiaowei Ren <qiaowei.ren@intel.com>

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
 arch/x86/mm/mpx.c                  |  181 ++++++++++++++++++++++++++++++++++++
 include/asm-generic/mmu_context.h  |    6 +
 mm/mmap.c                          |    2 +
 5 files changed, 214 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index be12c53..af70d4f 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -6,6 +6,7 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
+#include <asm/mpx.h>
 #ifndef CONFIG_PARAVIRT
 #include <asm-generic/mm_hooks.h>
 
@@ -96,4 +97,19 @@ do {						\
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
index e1b28e6..d29ec9c 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -2,6 +2,7 @@
 #include <linux/syscalls.h>
 #include <asm/mpx.h>
 #include <asm/mman.h>
+#include <asm/mmu_context.h>
 #include <linux/sched/sysctl.h>
 
 static const char *mpx_mapping_name(struct vm_area_struct *vma)
@@ -77,3 +78,183 @@ out:
 	up_write(&mm->mmap_sem);
 	return ret;
 }
+
+/*
+ * Get the base of bounds tables pointed by specific bounds
+ * directory entry.
+ */
+static int get_bt_addr(long __user *bd_entry, unsigned long *bt_addr,
+		unsigned int *valid)
+{
+	if (get_user(*bt_addr, bd_entry))
+		return -EFAULT;
+
+	*valid = *bt_addr & MPX_BD_ENTRY_VALID_FLAG;
+	*bt_addr &= MPX_BT_ADDR_MASK;
+
+	/*
+	 * If this bounds directory entry is nonzero, and meanwhile
+	 * the valid bit is zero, one SIGSEGV will be produced due to
+	 * this unexpected situation.
+	 */
+	if (!(*valid) && *bt_addr)
+		force_sig(SIGSEGV, current);
+
+	return 0;
+}
+
+/*
+ * Free the backing physical pages of bounds table 'bt_addr'.
+ * Assume start...end is within that bounds table.
+ */
+static void zap_bt_entries(struct mm_struct *mm, unsigned long bt_addr,
+		unsigned long start, unsigned long end)
+{
+	struct vm_area_struct *vma;
+
+	/* Find the vma which overlaps this bounds table */
+	vma = find_vma(mm, bt_addr);
+	if (!vma || vma->vm_start > bt_addr ||
+			vma->vm_end < bt_addr+MPX_BT_SIZE_BYTES)
+		return;
+
+	zap_page_range(vma, start, end, NULL);
+}
+
+static void unmap_single_bt(struct mm_struct *mm, long __user *bd_entry,
+		unsigned long bt_addr)
+{
+	if (user_atomic_cmpxchg_inatomic(&bt_addr, bd_entry,
+			bt_addr | MPX_BD_ENTRY_VALID_FLAG, 0))
+		return;
+
+	/*
+	 * to avoid recursion, do_munmap() will check whether it comes
+	 * from one bounds table through VM_MPX flag.
+	 */
+	do_munmap(mm, bt_addr & MPX_BT_ADDR_MASK, MPX_BT_SIZE_BYTES);
+}
+
+/*
+ * If the bounds table pointed by bounds directory 'bd_entry' is
+ * not shared, unmap this whole bounds table. Otherwise, only free
+ * those backing physical pages of bounds table entries covered
+ * in this virtual address region start...end.
+ */
+static void unmap_shared_bt(struct mm_struct *mm, long __user *bd_entry,
+		unsigned long start, unsigned long end,
+		bool prev_shared, bool next_shared)
+{
+	unsigned long bt_addr;
+	unsigned int bde_valid = 0;
+
+	if (get_bt_addr(bd_entry, &bt_addr, &bde_valid) || !bde_valid)
+		return;
+
+	if (prev_shared && next_shared)
+		zap_bt_entries(mm, bt_addr,
+			bt_addr+MPX_GET_BT_ENTRY_OFFSET(start),
+			bt_addr+MPX_GET_BT_ENTRY_OFFSET(end-1));
+	else if (prev_shared)
+		zap_bt_entries(mm, bt_addr,
+			bt_addr+MPX_GET_BT_ENTRY_OFFSET(start),
+			bt_addr+MPX_BT_SIZE_BYTES);
+	else if (next_shared)
+		zap_bt_entries(mm, bt_addr, bt_addr,
+			bt_addr+MPX_GET_BT_ENTRY_OFFSET(end-1));
+	else
+		unmap_single_bt(mm, bd_entry, bt_addr);
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
+static void unmap_side_bts(struct mm_struct *mm, unsigned long start,
+		unsigned long end)
+{
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
+	if (prev && MPX_GET_BD_ENTRY_OFFSET(prev->vm_end-1) == (long)bde_start)
+		prev_shared = true;
+	if (next && MPX_GET_BD_ENTRY_OFFSET(next->vm_start) == (long)bde_end)
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
+		unmap_shared_bt(mm, bde_start, start, end,
+				prev_shared, next_shared);
+		return;
+	}
+
+	/*
+	 * If more than one bounds tables are covered in this virtual
+	 * address region being munmap()ed, we need to separately check
+	 * whether bde_start and bde_end are shared with adjacent VMAs.
+	 */
+	unmap_shared_bt(mm, bde_start, start, end, prev_shared, false);
+	unmap_shared_bt(mm, bde_end, start, end, false, next_shared);
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
+	long __user *bd_entry, *bde_start, *bde_end;
+	unsigned long bt_addr;
+	unsigned int bde_valid;
+
+	/*
+	 * unmap bounds tables pointed out by start/end bounds directory
+	 * entries, or only free part of their backing physical memroy
+	 * if they are shared with adjacent VMAs.
+	 */
+	unmap_side_bts(mm, start, end);
+
+	/*
+	 * unmap those bounds table which are entirely covered in this
+	 * virtual address region.
+	 */
+	bde_start = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(start);
+	bde_end = mm->bd_addr + MPX_GET_BD_ENTRY_OFFSET(end-1);
+	for (bd_entry = bde_start + 1; bd_entry < bde_end; bd_entry++) {
+		if (get_bt_addr(bd_entry, &bt_addr, &bde_valid))
+			return;
+		if (!bde_valid)
+			continue;
+		unmap_single_bt(mm, bd_entry, bt_addr);
+	}
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
index 129b847..8550d84 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2560,6 +2560,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
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
