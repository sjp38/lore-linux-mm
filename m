Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id F31F76B03BB
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 09:52:36 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so7917717pab.36
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 06:52:36 -0700 (PDT)
Received: from psmtp.com ([74.125.245.193])
        by mx.google.com with SMTP id gv2si11774303pbb.11.2013.10.22.06.52.35
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 06:52:36 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86, mm: get ASLR work for hugetlb mappings
Date: Tue, 22 Oct 2013 16:52:20 +0300
Message-Id: <1382449940-24357-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>

Matthew noticed that hugetlb doesn't participate in ASLR on x86-64.
The reason is genereic hugetlb_get_unmapped_area() which is used on
x86-64. It doesn't support randomization and use bottom-up unmapped area
lookup, instead of usual top-down on x86-64.

x86 has arch-specific hugetlb_get_unmapped_area(), but it's used only on
x86-32.

Let's use arch-specific hugetlb_get_unmapped_area() on x86-64 too.
It fixes the issue and make hugetlb use top-down unmapped area lookup.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
---
 arch/x86/include/asm/page.h    | 1 +
 arch/x86/include/asm/page_32.h | 4 ----
 arch/x86/mm/hugetlbpage.c      | 9 +++------
 3 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index c87892442e..775873d3be 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -71,6 +71,7 @@ extern bool __virt_addr_valid(unsigned long kaddr);
 #include <asm-generic/getorder.h>
 
 #define __HAVE_ARCH_GATE_AREA 1
+#define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
 
 #endif	/* __KERNEL__ */
 #endif /* _ASM_X86_PAGE_H */
diff --git a/arch/x86/include/asm/page_32.h b/arch/x86/include/asm/page_32.h
index 4d550d04b6..904f528cc8 100644
--- a/arch/x86/include/asm/page_32.h
+++ b/arch/x86/include/asm/page_32.h
@@ -5,10 +5,6 @@
 
 #ifndef __ASSEMBLY__
 
-#ifdef CONFIG_HUGETLB_PAGE
-#define HAVE_ARCH_HUGETLB_UNMAPPED_AREA
-#endif
-
 #define __phys_addr_nodebug(x)	((x) - PAGE_OFFSET)
 #ifdef CONFIG_DEBUG_VIRTUAL
 extern unsigned long __phys_addr(unsigned long);
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 9d980d88b7..8c9f647ff9 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -87,9 +87,7 @@ int pmd_huge_support(void)
 }
 #endif
 
-/* x86_64 also uses this file */
-
-#ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
+#ifdef CONFIG_HUGETLB_PAGE
 static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 		unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
@@ -99,7 +97,7 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 
 	info.flags = 0;
 	info.length = len;
-	info.low_limit = TASK_UNMAPPED_BASE;
+	info.low_limit = current->mm->mmap_legacy_base;
 	info.high_limit = TASK_SIZE;
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
@@ -172,8 +170,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 		return hugetlb_get_unmapped_area_topdown(file, addr, len,
 				pgoff, flags);
 }
-
-#endif /*HAVE_ARCH_HUGETLB_UNMAPPED_AREA*/
+#endif /* CONFIG_HUGETLB_PAGE */
 
 #ifdef CONFIG_X86_64
 static __init int setup_hugepagesz(char *opt)
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
