Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3346B0501
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 19:00:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q87so150580470pfk.15
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 16:00:07 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d3si1193371pln.570.2017.07.16.16.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 16:00:06 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/8] x86/mpx: Do not allow MPX if we have mappings above 47-bit
Date: Mon, 17 Jul 2017 01:59:51 +0300
Message-Id: <20170716225954.74185-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
References: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

MPX (without MAWA extension) cannot handle addresses above 47-bit, so we
need to make sure that MPX cannot be enabled if we already have VMA above
the boundary and forbid creating such VMAs once MPX is enabled.

The patch implements mpx_unmapped_area_check() which is called from all
variants of get_unmapped_area() to check if the requested address fits
mpx.

On enabling MPX, we check if we already have any vma above 47-bit
boundary and forbit the enabling if we do.

As long as DEFAULT_MAP_WINDOW is equal to TASK_SIZE_MAX, the change is
nop. It will change when we allow userspace to have mappings above
47-bits.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mpx.h       |  9 +++++++++
 arch/x86/include/asm/processor.h |  3 +++
 arch/x86/kernel/sys_x86_64.c     |  9 +++++++++
 arch/x86/mm/hugetlbpage.c        |  6 ++++++
 arch/x86/mm/mpx.c                | 33 ++++++++++++++++++++++++++++++++-
 5 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
index a0d662be4c5b..7d7404756bb4 100644
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -73,6 +73,9 @@ static inline void mpx_mm_init(struct mm_struct *mm)
 }
 void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 		      unsigned long start, unsigned long end);
+
+unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len,
+		unsigned long flags);
 #else
 static inline siginfo_t *mpx_generate_siginfo(struct pt_regs *regs)
 {
@@ -94,6 +97,12 @@ static inline void mpx_notify_unmap(struct mm_struct *mm,
 				    unsigned long start, unsigned long end)
 {
 }
+
+static inline unsigned long mpx_unmapped_area_check(unsigned long addr,
+		unsigned long len, unsigned long flags)
+{
+	return addr;
+}
 #endif /* CONFIG_X86_INTEL_MPX */
 
 #endif /* _ASM_X86_MPX_H */
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 6a79547e8ee0..52b5a24dd56d 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -803,6 +803,7 @@ static inline void spin_lock_prefetch(const void *x)
 #define IA32_PAGE_OFFSET	PAGE_OFFSET
 #define TASK_SIZE		PAGE_OFFSET
 #define TASK_SIZE_MAX		TASK_SIZE
+#define DEFAULT_MAP_WINDOW	TASK_SIZE
 #define STACK_TOP		TASK_SIZE
 #define STACK_TOP_MAX		STACK_TOP
 
@@ -844,6 +845,8 @@ static inline void spin_lock_prefetch(const void *x)
  */
 #define TASK_SIZE_MAX	((1UL << 47) - PAGE_SIZE)
 
+#define DEFAULT_MAP_WINDOW	TASK_SIZE_MAX
+
 /* This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 89bd0d6460e1..f840e895d871 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -21,6 +21,7 @@
 #include <asm/compat.h>
 #include <asm/ia32.h>
 #include <asm/syscalls.h>
+#include <asm/mpx.h>
 
 /*
  * Align a virtual address to avoid aliasing in the I$ on AMD F15h.
@@ -132,6 +133,10 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	struct vm_unmapped_area_info info;
 	unsigned long begin, end;
 
+	addr = mpx_unmapped_area_check(addr, len, flags);
+	if (IS_ERR_VALUE(addr))
+		return addr;
+
 	if (flags & MAP_FIXED)
 		return addr;
 
@@ -171,6 +176,10 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 
+	addr = mpx_unmapped_area_check(addr, len, flags);
+	if (IS_ERR_VALUE(addr))
+		return addr;
+
 	/* requested length too big for entire address space */
 	if (len > TASK_SIZE)
 		return -ENOMEM;
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 868f02cf58ce..3cf89ad00f87 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -18,6 +18,7 @@
 #include <asm/tlbflush.h>
 #include <asm/pgalloc.h>
 #include <asm/elf.h>
+#include <asm/mpx.h>
 
 #if 0	/* This is just for testing */
 struct page *
@@ -135,6 +136,11 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 
 	if (len & ~huge_page_mask(h))
 		return -EINVAL;
+
+	addr = mpx_unmapped_area_check(addr, len, flags);
+	if (IS_ERR_VALUE(addr))
+		return addr;
+
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 1c34b767c84c..8c8da27e8549 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -355,10 +355,19 @@ int mpx_enable_management(void)
 	 */
 	bd_base = mpx_get_bounds_dir();
 	down_write(&mm->mmap_sem);
+
+	/* MPX doesn't support addresses above 47-bits yet. */
+	if (find_vma(mm, DEFAULT_MAP_WINDOW)) {
+		pr_warn_once("%s (%d): MPX cannot handle addresses "
+				"above 47-bits. Disabling.",
+				current->comm, current->pid);
+		ret = -ENXIO;
+		goto out;
+	}
 	mm->context.bd_addr = bd_base;
 	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
 		ret = -ENXIO;
-
+out:
 	up_write(&mm->mmap_sem);
 	return ret;
 }
@@ -1030,3 +1039,25 @@ void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (ret)
 		force_sig(SIGSEGV, current);
 }
+
+/* MPX cannot handle addresses above 47-bits yet. */
+unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len,
+		unsigned long flags)
+{
+	if (!kernel_managing_mpx_tables(current->mm))
+		return addr;
+	if (addr + len <= DEFAULT_MAP_WINDOW)
+		return addr;
+	if (flags & MAP_FIXED)
+		return -ENOMEM;
+
+	/*
+	 * Requested len is larger than whole area we're allowed to map in.
+	 * Resetting hinting address wouldn't do much good -- fail early.
+	 */
+	if (len > DEFAULT_MAP_WINDOW)
+		return -ENOMEM;
+
+	/* Look for unmap area within DEFAULT_MAP_WINDOW */
+	return 0;
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
