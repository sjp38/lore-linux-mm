Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C43526B038A
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 07:45:31 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 14so70689415itw.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:45:31 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0107.outbound.protection.outlook.com. [104.47.0.107])
        by mx.google.com with ESMTPS id o12si3584856plg.220.2017.03.14.04.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 Mar 2017 04:45:31 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCH] x86/hugetlb: Use 32/64 mmap bases according to syscall
Date: Tue, 14 Mar 2017 14:41:26 +0300
Message-ID: <20170314114126.9280-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, kernel test robot <xiaolong.ye@intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org

Commit:
  1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for 32-bit
mmap()")

introduced two mmap() bases for 32-bit syscalls and for 64-bit syscalls.
After that commit mm->mmap_base has address to base allocations for
64-bit syscalls, while mm->mmap_compat_base - for 32-bit syscalls.
mmap() code was changed accordingly, but hugetlb code was not changed,
which introduced bogus behavior: 32-bit application which mmaps
file on hugetlbfs uses mm->mmap_base and thou tries to allocate
space with 64-bit mmap() base.
Changed x86 hugetlbfs code to use two bases according to calling
syscall, which also will fix any problems with 32-bit syscalls
in 64-bit ELF and vice-versa.

Fixes: commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
32-bit mmap()").
Reported-by: kernel test robot <xiaolong.ye@intel.com>
Cc: 0x7f454c46@gmail.com
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
Note: I've tested it on a simple hand-written test, will reply when
got libhugetlbfs tests running in my environment.

 arch/x86/include/asm/elf.h   |  1 +
 arch/x86/kernel/sys_x86_64.c | 12 ------------
 arch/x86/mm/hugetlbpage.c    |  9 ++++++---
 arch/x86/mm/mmap.c           | 13 +++++++++++++
 4 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index ac5be5ba8527..d4d3ed456cb7 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -305,6 +305,7 @@ static inline int mmap_is_ia32(void)
 
 extern unsigned long tasksize_32bit(void);
 extern unsigned long tasksize_64bit(void);
+extern unsigned long get_mmap_base(int is_legacy);
 
 #ifdef CONFIG_X86_32
 
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 63e89dfc808a..207b8f2582c7 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -100,18 +100,6 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 	return error;
 }
 
-static unsigned long get_mmap_base(int is_legacy)
-{
-	struct mm_struct *mm = current->mm;
-
-#ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
-	if (in_compat_syscall())
-		return is_legacy ? mm->mmap_compat_legacy_base
-				 : mm->mmap_compat_base;
-#endif
-	return is_legacy ? mm->mmap_legacy_base : mm->mmap_base;
-}
-
 static void find_start_end(unsigned long flags, unsigned long *begin,
 			   unsigned long *end)
 {
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index c5066a260803..a50f4600a281 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -16,6 +16,8 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 #include <asm/pgalloc.h>
+#include <asm/elf.h>
+#include <asm/compat.h>
 
 #if 0	/* This is just for testing */
 struct page *
@@ -82,8 +84,9 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 
 	info.flags = 0;
 	info.length = len;
-	info.low_limit = current->mm->mmap_legacy_base;
-	info.high_limit = TASK_SIZE;
+	info.low_limit = get_mmap_base(1);
+	info.high_limit = in_compat_syscall() ?
+		tasksize_32bit() : tasksize_64bit();
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	return vm_unmapped_area(&info);
@@ -100,7 +103,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = current->mm->mmap_base;
+	info.high_limit = get_mmap_base(0);
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 	addr = vm_unmapped_area(&info);
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 529ab79800af..0fbb5a71b826 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -31,6 +31,7 @@
 #include <linux/sched/signal.h>
 #include <linux/sched/mm.h>
 #include <asm/elf.h>
+#include <asm/compat.h>
 
 struct va_alignment __read_mostly va_align = {
 	.flags = -1,
@@ -153,6 +154,18 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 #endif
 }
 
+unsigned long get_mmap_base(int is_legacy)
+{
+	struct mm_struct *mm = current->mm;
+
+#ifdef CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES
+	if (in_compat_syscall())
+		return is_legacy ? mm->mmap_compat_legacy_base
+				 : mm->mmap_compat_base;
+#endif
+	return is_legacy ? mm->mmap_legacy_base : mm->mmap_base;
+}
+
 const char *arch_vma_name(struct vm_area_struct *vma)
 {
 	if (vma->vm_flags & VM_MPX)
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
