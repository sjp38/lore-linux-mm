Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 3C6FD6B0093
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 07:59:34 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] asm-generic, mm: pgtable: consolidate zero page helpers
Date: Mon, 15 Oct 2012 14:59:59 +0300
Message-Id: <1350302399-8036-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org
Cc: linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We have two different implementation of is_zero_pfn() and
my_zero_pfn() helpers: for architectures with and without zero page
coloring.

Let's consolidate them in <asm-generic/pgtable.h>.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/mips/include/asm/pgtable.h |   11 +----------
 arch/s390/include/asm/pgtable.h |   11 +----------
 include/asm-generic/pgtable.h   |   26 ++++++++++++++++++++++++++
 include/linux/mm.h              |    8 --------
 mm/memory.c                     |    7 -------
 5 files changed, 28 insertions(+), 35 deletions(-)

diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index c02158b..14490e9 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -76,16 +76,7 @@ extern unsigned long zero_page_mask;
 
 #define ZERO_PAGE(vaddr) \
 	(virt_to_page((void *)(empty_zero_page + (((unsigned long)(vaddr)) & zero_page_mask))))
-
-#define is_zero_pfn is_zero_pfn
-static inline int is_zero_pfn(unsigned long pfn)
-{
-	extern unsigned long zero_pfn;
-	unsigned long offset_from_zero_pfn = pfn - zero_pfn;
-	return offset_from_zero_pfn <= (zero_page_mask >> PAGE_SHIFT);
-}
-
-#define my_zero_pfn(addr)	page_to_pfn(ZERO_PAGE(addr))
+#define __HAVE_COLOR_ZERO_PAGE
 
 extern void paging_init(void);
 
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index dd647c9..a76e53d 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -55,16 +55,7 @@ extern unsigned long zero_page_mask;
 #define ZERO_PAGE(vaddr) \
 	(virt_to_page((void *)(empty_zero_page + \
 	 (((unsigned long)(vaddr)) &zero_page_mask))))
-
-#define is_zero_pfn is_zero_pfn
-static inline int is_zero_pfn(unsigned long pfn)
-{
-	extern unsigned long zero_pfn;
-	unsigned long offset_from_zero_pfn = pfn - zero_pfn;
-	return offset_from_zero_pfn <= (zero_page_mask >> PAGE_SHIFT);
-}
-
-#define my_zero_pfn(addr)	page_to_pfn(ZERO_PAGE(addr))
+#define __HAVE_COLOR_ZERO_PAGE
 
 #endif /* !__ASSEMBLY__ */
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index b36ce40..284e808 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -449,6 +449,32 @@ extern void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 			unsigned long size);
 #endif
 
+#ifdef __HAVE_COLOR_ZERO_PAGE
+static inline int is_zero_pfn(unsigned long pfn)
+{
+	extern unsigned long zero_pfn;
+	unsigned long offset_from_zero_pfn = pfn - zero_pfn;
+	return offset_from_zero_pfn <= (zero_page_mask >> PAGE_SHIFT);
+}
+
+static inline unsigned long my_zero_pfn(unsigned long addr)
+{
+	return page_to_pfn(ZERO_PAGE(addr));
+}
+#else
+static inline int is_zero_pfn(unsigned long pfn)
+{
+	extern unsigned long zero_pfn;
+	return pfn == zero_pfn;
+}
+
+static inline unsigned long my_zero_pfn(unsigned long addr)
+{
+	extern unsigned long zero_pfn;
+	return zero_pfn;
+}
+#endif
+
 #ifdef CONFIG_MMU
 
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fe329da..fa06804 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -516,14 +516,6 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 }
 #endif
 
-#ifndef my_zero_pfn
-static inline unsigned long my_zero_pfn(unsigned long addr)
-{
-	extern unsigned long zero_pfn;
-	return zero_pfn;
-}
-#endif
-
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
diff --git a/mm/memory.c b/mm/memory.c
index 6017e23..d3f2120 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -717,13 +717,6 @@ static inline bool is_cow_mapping(vm_flags_t flags)
 	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 }
 
-#ifndef is_zero_pfn
-static inline int is_zero_pfn(unsigned long pfn)
-{
-	return pfn == zero_pfn;
-}
-#endif
-
 /*
  * vm_normal_page -- This function gets the "struct page" associated with a pte.
  *
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
