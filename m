Received: by qb-out-0506.google.com with SMTP id e12so2290933qba.0
        for <linux-mm@kvack.org>; Fri, 03 Oct 2008 00:03:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Date: Fri,  3 Oct 2008 10:04:29 +0300
Message-Id: <1223017469-5158-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>Thomas Gleixner <tglx@linutronix.de>Ingo Molnar <mingo@redhat.com>"H. Peter Anvin" <hpa@zytor.com>Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

---
 arch/x86/kernel/sys_x86_64.c |   15 +++++++++++----
 include/asm-x86/elf.h        |    4 +++-
 include/asm-x86/processor.h  |    6 ++++--
 3 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 3b360ef..d6ac928 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -48,7 +48,9 @@ out:
 static void find_start_end(unsigned long flags, unsigned long *begin,
 			   unsigned long *end)
 {
-	if (!test_thread_flag(TIF_IA32) && (flags & MAP_32BIT)) {
+	if (!test_thread_flag(TIF_IA32) &&
+	    ((flags & MAP_32BIT) ||
+	     (current->personality & ADDR_LIMIT_32BIT))) {
 		unsigned long new_begin;
 		/* This is usually used needed to map code in small
 		   model, so it needs to be in the first 31bit. Limit
@@ -94,7 +96,8 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	if (((flags & MAP_32BIT) || test_thread_flag(TIF_IA32))
+	if (((flags & MAP_32BIT) || test_thread_flag(TIF_IA32) ||
+	     (current->personality & ADDR_LIMIT_32BIT))
 	    && len <= mm->cached_hole_size) {
 	        mm->cached_hole_size = 0;
 		mm->free_area_cache = begin;
@@ -150,8 +153,12 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (flags & MAP_FIXED)
 		return addr;
 
-	/* for MAP_32BIT mappings we force the legact mmap base */
-	if (!test_thread_flag(TIF_IA32) && (flags & MAP_32BIT))
+	/* for MAP_32BIT mappings and ADDR_LIMIT_32BIT personality we force the
+	 * legact mmap base
+	 */
+	if (!test_thread_flag(TIF_IA32) &&
+	    ((flags & MAP_32BIT) ||
+	     (current->personality & ADDR_LIMIT_32BIT)))
 		goto bottomup;
 
 	/* requesting a specific address */
diff --git a/include/asm-x86/elf.h b/include/asm-x86/elf.h
index 7be4733..fa39e10 100644
--- a/include/asm-x86/elf.h
+++ b/include/asm-x86/elf.h
@@ -298,7 +298,9 @@ do {									\
 #define VDSO_HIGH_BASE		0xffffe000U /* CONFIG_COMPAT_VDSO address */
 
 /* 1GB for 64bit, 8MB for 32bit */
-#define STACK_RND_MASK (test_thread_flag(TIF_IA32) ? 0x7ff : 0x3fffff)
+#define STACK_RND_MASK ((test_thread_flag(TIF_IA32) || \
+			 current->personality & ADDR_LIMIT_32BIT ) ? \
+			0x7ff : 0x3fffff)
 
 #define ARCH_DLINFO							\
 do {									\
diff --git a/include/asm-x86/processor.h b/include/asm-x86/processor.h
index 4df3e2f..6d7f2f9 100644
--- a/include/asm-x86/processor.h
+++ b/include/asm-x86/processor.h
@@ -904,7 +904,8 @@ extern unsigned long thread_saved_pc(struct task_struct *tsk);
 #define TASK_SIZE_OF(child)	((test_tsk_thread_flag(child, TIF_IA32)) ? \
 					IA32_PAGE_OFFSET : TASK_SIZE64)
 
-#define STACK_TOP		TASK_SIZE
+#define STACK_TOP		(current->personality & ADDR_LIMIT_32BIT ? \
+					 0x80000000 : TASK_SIZE)
 #define STACK_TOP_MAX		TASK_SIZE64
 
 #define INIT_THREAD  { \
@@ -932,7 +933,8 @@ extern void start_thread(struct pt_regs *regs, unsigned long new_ip,
  * This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
+#define TASK_UNMAPPED_BASE	(current->personality & ADDR_LIMIT_32BIT ? \
+					0x40000000 : PAGE_ALIGN(TASK_SIZE / 3))
 
 #define KSTK_EIP(task)		(task_pt_regs(task)->ip)
 
-- 
1.5.6.5.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
