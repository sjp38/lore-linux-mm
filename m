Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3486B041A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:50:46 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 190so206497312pgg.3
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:50:46 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 44si17218211pla.51.2017.03.12.22.50.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:50:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 26/26] x86/mm: allow to have userspace mappings above 47-bits
Date: Mon, 13 Mar 2017 08:50:20 +0300
Message-Id: <20170313055020.69655-27-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On x86, 5-level paging enables 56-bit userspace virtual address space.
Not all user space is ready to handle wide addresses. It's known that
at least some JIT compilers use higher bits in pointers to encode their
information. It collides with valid pointers with 5-level paging and
leads to crashes.

To mitigate this, we are not going to allocate virtual address space
above 47-bit by default.

But userspace can ask for allocation from full address space by
specifying hint address (with or without MAP_FIXED) above 47-bits.

If hint address set above 47-bit, but MAP_FIXED is not specified, we try
to look for unmapped area by specified address. If it's already
occupied, we look for unmapped area in *full* address space, rather than
from 47-bit window.

This approach helps to easily make application's memory allocator aware
about large address space without manually tracking allocated virtual
address space.

One important case we need to handle here is interaction with MPX.
MPX (without MAWA( extension cannot handle addresses above 47-bit, so we
need to make sure that MPX cannot be enabled we already have VMA above
the boundary and forbid creating such VMAs once MPX is enabled.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/elf.h       |  2 +-
 arch/x86/include/asm/mpx.h       |  9 +++++++++
 arch/x86/include/asm/processor.h |  9 ++++++---
 arch/x86/kernel/sys_x86_64.c     | 28 +++++++++++++++++++++++++++-
 arch/x86/mm/hugetlbpage.c        | 31 +++++++++++++++++++++++++++----
 arch/x86/mm/mmap.c               |  4 ++--
 arch/x86/mm/mpx.c                | 33 ++++++++++++++++++++++++++++++++-
 7 files changed, 104 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 9d49c18b5ea9..265625b0d6cb 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -250,7 +250,7 @@ extern int force_personality32;
    the loader.  We need to make sure that it is out of the way of the program
    that it will "exec", and that there is sufficient room for the brk.  */
 
-#define ELF_ET_DYN_BASE		(TASK_SIZE / 3 * 2)
+#define ELF_ET_DYN_BASE		(DEFAULT_MAP_WINDOW / 3 * 2)
 
 /* This yields a mask that user programs can use to figure out what
    instruction set this CPU supports.  This could be done in user space,
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
index f385eca5407a..da8ab4f2d0c7 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -799,6 +799,7 @@ static inline void spin_lock_prefetch(const void *x)
  */
 #define TASK_SIZE		PAGE_OFFSET
 #define TASK_SIZE_MAX		TASK_SIZE
+#define DEFAULT_MAP_WINDOW	TASK_SIZE
 #define STACK_TOP		TASK_SIZE
 #define STACK_TOP_MAX		STACK_TOP
 
@@ -838,7 +839,9 @@ static inline void spin_lock_prefetch(const void *x)
  * particular problem by preventing anything from being mapped
  * at the maximum canonical address.
  */
-#define TASK_SIZE_MAX	((1UL << 47) - PAGE_SIZE)
+#define TASK_SIZE_MAX	((1UL << __VIRTUAL_MASK_SHIFT) - PAGE_SIZE)
+
+#define DEFAULT_MAP_WINDOW	((1UL << 47) - PAGE_SIZE)
 
 /* This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
@@ -851,7 +854,7 @@ static inline void spin_lock_prefetch(const void *x)
 #define TASK_SIZE_OF(child)	((test_tsk_thread_flag(child, TIF_ADDR32)) ? \
 					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
 
-#define STACK_TOP		TASK_SIZE
+#define STACK_TOP		DEFAULT_MAP_WINDOW
 #define STACK_TOP_MAX		TASK_SIZE_MAX
 
 #define INIT_THREAD  {						\
@@ -873,7 +876,7 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
  * This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
+#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(DEFAULT_MAP_WINDOW / 3))
 
 #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
 
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 50215a4b9347..bae3706130a6 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -19,6 +19,7 @@
 
 #include <asm/ia32.h>
 #include <asm/syscalls.h>
+#include <asm/mpx.h>
 
 /*
  * Align a virtual address to avoid aliasing in the I$ on AMD F15h.
@@ -129,6 +130,10 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	struct vm_unmapped_area_info info;
 	unsigned long begin, end;
 
+	addr = mpx_unmapped_area_check(addr, len, flags);
+	if (IS_ERR_VALUE(addr))
+		return addr;
+
 	if (flags & MAP_FIXED)
 		return addr;
 
@@ -148,7 +153,16 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = begin;
-	info.high_limit = end;
+
+	/*
+	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
+	 * in the full address space.
+	 */
+	if (addr > DEFAULT_MAP_WINDOW)
+		info.high_limit = min(end, TASK_SIZE);
+	else
+		info.high_limit = min(end, DEFAULT_MAP_WINDOW);
+
 	info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	if (filp) {
@@ -168,6 +182,10 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 
+	addr = mpx_unmapped_area_check(addr, len, flags);
+	if (IS_ERR_VALUE(addr))
+		return addr;
+
 	/* requested length too big for entire address space */
 	if (len > TASK_SIZE)
 		return -ENOMEM;
@@ -192,6 +210,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
 	info.high_limit = mm->mmap_base;
+
+	/*
+	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
+	 * in the full address space.
+	 */
+	if (addr > DEFAULT_MAP_WINDOW)
+		info.high_limit += TASK_SIZE - DEFAULT_MAP_WINDOW;
+
 	info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	if (filp) {
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index c5066a260803..94f41a39d8fe 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -16,6 +16,7 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 #include <asm/pgalloc.h>
+#include <asm/mpx.h>
 
 #if 0	/* This is just for testing */
 struct page *
@@ -83,24 +84,41 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = current->mm->mmap_legacy_base;
-	info.high_limit = TASK_SIZE;
+	info.high_limit = DEFAULT_MAP_WINDOW;
+
+	/*
+	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
+	 * in the full address space.
+	 */
+	if (addr > DEFAULT_MAP_WINDOW)
+		info.high_limit = TASK_SIZE;
+	else
+		info.high_limit = DEFAULT_MAP_WINDOW;
+
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	return vm_unmapped_area(&info);
 }
 
 static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
-		unsigned long addr0, unsigned long len,
+		unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
 	struct hstate *h = hstate_file(file);
 	struct vm_unmapped_area_info info;
-	unsigned long addr;
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
 	info.high_limit = current->mm->mmap_base;
+
+	/*
+	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
+	 * in the full address space.
+	 */
+	if (addr > DEFAULT_MAP_WINDOW)
+		info.high_limit += TASK_SIZE - DEFAULT_MAP_WINDOW;
+
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	addr = vm_unmapped_area(&info);
@@ -115,7 +133,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
-		info.high_limit = TASK_SIZE;
+		info.high_limit = DEFAULT_MAP_WINDOW;
 		addr = vm_unmapped_area(&info);
 	}
 
@@ -132,6 +150,11 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 
 	if (len & ~huge_page_mask(h))
 		return -EINVAL;
+
+	addr = mpx_unmapped_area_check(addr, len, flags);
+	if (IS_ERR_VALUE(addr))
+		return addr;
+
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 7940166c799b..2fbfcabd098a 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -53,7 +53,7 @@ static unsigned long stack_maxrandom_size(void)
  * Leave an at least ~128 MB hole with possible stack randomization.
  */
 #define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
-#define MAX_GAP (TASK_SIZE/6*5)
+#define MAX_GAP (DEFAULT_MAP_WINDOW/6*5)
 
 static int mmap_is_legacy(void)
 {
@@ -91,7 +91,7 @@ static unsigned long mmap_base(unsigned long rnd)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(DEFAULT_MAP_WINDOW - gap - rnd);
 }
 
 /*
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 5126dfd52b18..cc318817ce7c 100644
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
@@ -1038,3 +1047,25 @@ void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
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
