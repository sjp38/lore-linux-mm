Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 84171828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:06:49 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id yy13so150769226pab.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:06:49 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id sk6si51335152pab.138.2016.01.06.16.01.28
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:28 -0800 (PST)
Subject: [PATCH 16/31] x86, mm: simplify get_user_pages() PTE bit handling
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:27 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000127.E7532AF1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The current get_user_pages() code is a wee bit more complicated
than it needs to be for pte bit checking.  Currently, it establishes
a mask of required pte _PAGE_* bits and ensures that the pte it
goes after has all those bits.

This consolidates the three identical copies of this code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/mm/gup.c |   39 ++++++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 17 deletions(-)

diff -puN arch/x86/mm/gup.c~pkeys-12-gup-swizzle arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c~pkeys-12-gup-swizzle	2016-01-06 15:50:09.552333717 -0800
+++ b/arch/x86/mm/gup.c	2016-01-06 15:50:09.555333852 -0800
@@ -64,6 +64,24 @@ retry:
 }
 
 /*
+ * 'pteval' can come from a pte, pmd or pud.  We only check
+ * _PAGE_PRESENT, _PAGE_USER, and _PAGE_RW in here which are the
+ * same value on all 3 types.
+ */
+static inline int pte_allows_gup(unsigned long pteval, int write)
+{
+	unsigned long need_pte_bits = _PAGE_PRESENT|_PAGE_USER;
+
+	if (write)
+		need_pte_bits |= _PAGE_RW;
+
+	if ((pteval & need_pte_bits) != need_pte_bits)
+		return 0;
+
+	return 1;
+}
+
+/*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
  * register pressure.
@@ -71,13 +89,8 @@ retry:
 static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
-	unsigned long mask;
 	pte_t *ptep;
 
-	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
-
 	ptep = pte_offset_map(&pmd, addr);
 	do {
 		pte_t pte = gup_get_pte(ptep);
@@ -88,8 +101,8 @@ static noinline int gup_pte_range(pmd_t
 			pte_unmap(ptep);
 			return 0;
 		}
-
-		if ((pte_flags(pte) & (mask | _PAGE_SPECIAL)) != mask) {
+		if (!pte_allows_gup(pte_val(pte), write) ||
+		    pte_special(pte)) {
 			pte_unmap(ptep);
 			return 0;
 		}
@@ -117,14 +130,10 @@ static inline void get_head_page_multipl
 static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
-	unsigned long mask;
 	struct page *head, *page;
 	int refs;
 
-	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
-	if ((pmd_flags(pmd) & mask) != mask)
+	if (!pte_allows_gup(pmd_val(pmd), write))
 		return 0;
 	/* hugepages are never "special" */
 	VM_BUG_ON(pmd_flags(pmd) & _PAGE_SPECIAL);
@@ -193,14 +202,10 @@ static int gup_pmd_range(pud_t pud, unsi
 static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
-	unsigned long mask;
 	struct page *head, *page;
 	int refs;
 
-	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
-	if ((pud_flags(pud) & mask) != mask)
+	if (!pte_allows_gup(pud_val(pud), write))
 		return 0;
 	/* hugepages are never "special" */
 	VM_BUG_ON(pud_flags(pud) & _PAGE_SPECIAL);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
