Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39AB66B04AB
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 19:00:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p15so157536946pgs.7
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 16:00:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d90si10055102pld.635.2017.07.16.16.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 16:00:05 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 6/8] x86/mm: Prepare to expose larger address space to userspace
Date: Mon, 17 Jul 2017 01:59:52 +0300
Message-Id: <20170716225954.74185-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
References: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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

A high hint address would only affect the allocation in question, but not
any future mmap()s.

Specifying high hint address on older kernel or on machine without 5-level
paging support is safe. The hint will be ignored and kernel will fall back
to allocation from 47-bit address space.

This approach helps to easily make application's memory allocator aware
about large address space without manually tracking allocated virtual
address space.

The patch puts all machinery in place, but not yet allows userspace to have
mappings above 47-bit -- TASK_SIZE_MAX has to be raised to get the effect.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/elf.h       |  2 +-
 arch/x86/include/asm/processor.h |  7 +++++--
 arch/x86/kernel/sys_x86_64.c     | 21 +++++++++++++++++----
 arch/x86/mm/hugetlbpage.c        | 21 +++++++++++++++++----
 arch/x86/mm/mmap.c               |  6 +++---
 5 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index c7090ef1388e..f87f4d73c700 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -305,7 +305,7 @@ static inline int mmap_is_ia32(void)
 }
 
 extern unsigned long task_size_32bit(void);
-extern unsigned long task_size_64bit(void);
+extern unsigned long task_size_64bit(int full_addr_space);
 extern unsigned long get_mmap_base(int is_legacy);
 
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 52b5a24dd56d..91362921eb05 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -802,6 +802,7 @@ static inline void spin_lock_prefetch(const void *x)
  */
 #define IA32_PAGE_OFFSET	PAGE_OFFSET
 #define TASK_SIZE		PAGE_OFFSET
+#define TASK_SIZE_LOW		TASK_SIZE
 #define TASK_SIZE_MAX		TASK_SIZE
 #define DEFAULT_MAP_WINDOW	TASK_SIZE
 #define STACK_TOP		TASK_SIZE
@@ -853,12 +854,14 @@ static inline void spin_lock_prefetch(const void *x)
 #define IA32_PAGE_OFFSET	((current->personality & ADDR_LIMIT_3GB) ? \
 					0xc0000000 : 0xFFFFe000)
 
+#define TASK_SIZE_LOW		(test_thread_flag(TIF_ADDR32) ? \
+					IA32_PAGE_OFFSET : DEFAULT_MAP_WINDOW)
 #define TASK_SIZE		(test_thread_flag(TIF_ADDR32) ? \
 					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
 #define TASK_SIZE_OF(child)	((test_tsk_thread_flag(child, TIF_ADDR32)) ? \
 					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
 
-#define STACK_TOP		TASK_SIZE
+#define STACK_TOP		TASK_SIZE_LOW
 #define STACK_TOP_MAX		TASK_SIZE_MAX
 
 #define INIT_THREAD  {						\
@@ -879,7 +882,7 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
  * space during mmap's.
  */
 #define __TASK_UNMAPPED_BASE(task_size)	(PAGE_ALIGN(task_size / 3))
-#define TASK_UNMAPPED_BASE		__TASK_UNMAPPED_BASE(TASK_SIZE)
+#define TASK_UNMAPPED_BASE		__TASK_UNMAPPED_BASE(TASK_SIZE_LOW)
 
 #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
 
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index f840e895d871..73e4d28112f8 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -101,8 +101,8 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 	return error;
 }
 
-static void find_start_end(unsigned long flags, unsigned long *begin,
-			   unsigned long *end)
+static void find_start_end(unsigned long addr, unsigned long flags,
+		unsigned long *begin, unsigned long *end)
 {
 	if (!in_compat_syscall() && (flags & MAP_32BIT)) {
 		/* This is usually used needed to map code in small
@@ -121,7 +121,10 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
 	}
 
 	*begin	= get_mmap_base(1);
-	*end	= in_compat_syscall() ? task_size_32bit() : task_size_64bit();
+	if (in_compat_syscall())
+		*end = task_size_32bit();
+	else
+		*end = task_size_64bit(addr > DEFAULT_MAP_WINDOW);
 }
 
 unsigned long
@@ -140,7 +143,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	if (flags & MAP_FIXED)
 		return addr;
 
-	find_start_end(flags, &begin, &end);
+	find_start_end(addr, flags, &begin, &end);
 
 	if (len > end)
 		return -ENOMEM;
@@ -204,6 +207,16 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
 	info.high_limit = get_mmap_base(0);
+
+	/*
+	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
+	 * in the full address space.
+	 *
+	 * !in_compat_syscall() check to avoid high addresses for x32.
+	 */
+	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
+		info.high_limit += TASK_SIZE_MAX - DEFAULT_MAP_WINDOW;
+
 	info.align_mask = 0;
 	info.align_offset = pgoff << PAGE_SHIFT;
 	if (filp) {
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 3cf89ad00f87..6d06cf33e3de 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -86,25 +86,38 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = get_mmap_base(1);
+
+	/*
+	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
+	 * in the full address space.
+	 */
 	info.high_limit = in_compat_syscall() ?
-		task_size_32bit() : task_size_64bit();
+		task_size_32bit() : task_size_64bit(addr > DEFAULT_MAP_WINDOW);
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
 	info.high_limit = get_mmap_base(0);
+
+	/*
+	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
+	 * in the full address space.
+	 */
+	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
+		info.high_limit += TASK_SIZE_MAX - DEFAULT_MAP_WINDOW;
+
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	addr = vm_unmapped_area(&info);
@@ -119,7 +132,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
-		info.high_limit = TASK_SIZE;
+		info.high_limit = TASK_SIZE_LOW;
 		addr = vm_unmapped_area(&info);
 	}
 
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index d2586913c8d0..c15a50a70b24 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -42,9 +42,9 @@ unsigned long task_size_32bit(void)
 	return IA32_PAGE_OFFSET;
 }
 
-unsigned long task_size_64bit(void)
+unsigned long task_size_64bit(int full_addr_space)
 {
-	return TASK_SIZE_MAX;
+	return full_addr_space ? TASK_SIZE_MAX : DEFAULT_MAP_WINDOW;
 }
 
 static unsigned long stack_maxrandom_size(unsigned long task_size)
@@ -142,7 +142,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
 
 	arch_pick_mmap_base(&mm->mmap_base, &mm->mmap_legacy_base,
-			arch_rnd(mmap64_rnd_bits), task_size_64bit());
+			arch_rnd(mmap64_rnd_bits), task_size_64bit(0));
 
 #ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
 	/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
