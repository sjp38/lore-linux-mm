Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 937A5828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:23 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id ho8so45052333pac.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:23 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id s14si25613639pfa.120.2016.01.29.10.17.05
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:17:05 -0800 (PST)
Subject: [PATCH 16/31] x86, mm: simplify get_user_pages() PTE bit handling
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:17:05 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181705.9FF0BD10@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The current get_user_pages() code is a wee bit more complicated
than it needs to be for pte bit checking.  Currently, it establishes
a mask of required pte _PAGE_* bits and ensures that the pte it
goes after has all those bits.

This consolidates the three identical copies of this code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/mm/gup.c |   38 ++++++++++++++++++++++----------------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff -puN arch/x86/mm/gup.c~pkeys-12-gup-swizzle arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c~pkeys-12-gup-swizzle	2016-01-28 15:52:23.267537203 -0800
+++ b/arch/x86/mm/gup.c	2016-01-28 15:52:23.270537340 -0800
@@ -75,6 +75,24 @@ static void undo_dev_pagemap(int *nr, in
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
@@ -83,14 +101,9 @@ static noinline int gup_pte_range(pmd_t
 		unsigned long end, int write, struct page **pages, int *nr)
 {
 	struct dev_pagemap *pgmap = NULL;
-	unsigned long mask;
 	int nr_start = *nr;
 	pte_t *ptep;
 
-	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
-
 	ptep = pte_offset_map(&pmd, addr);
 	do {
 		pte_t pte = gup_get_pte(ptep);
@@ -110,7 +123,8 @@ static noinline int gup_pte_range(pmd_t
 				pte_unmap(ptep);
 				return 0;
 			}
-		} else if ((pte_flags(pte) & (mask | _PAGE_SPECIAL)) != mask) {
+		} else if (!pte_allows_gup(pte_val(pte), write) ||
+			   pte_special(pte)) {
 			pte_unmap(ptep);
 			return 0;
 		}
@@ -164,14 +178,10 @@ static int __gup_device_huge_pmd(pmd_t p
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
 
 	VM_BUG_ON(!pfn_valid(pmd_pfn(pmd)));
@@ -231,14 +241,10 @@ static int gup_pmd_range(pud_t pud, unsi
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
