Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E3B556B0268
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:41 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so182220042pac.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:41 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rj3si30718105pbc.104.2015.09.28.12.18.23
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:23 -0700 (PDT)
Subject: [PATCH 14/25] mm: simplify get_user_pages() PTE bit handling
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:23 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191823.BFF753A4@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The current get_user_pages() code is a wee bit more complicated
than it needs to be for pte bit checking.  Currently, it establishes
a mask of required pte _PAGE_* bits and ensures that the pte it
goes after has all those bits.

We need to use the bits for our _PAGE_PRESENT check since
pte_present() is also true for _PAGE_PROTNONE, and we have no
accessor for _PAGE_USER, so need it there as well.

But we might as well just use pte_write() since we have it and
let the compiler work its magic on optimizing it.

This also consolidates the three identical copies of this code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/mm/gup.c |   34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff -puN arch/x86/mm/gup.c~pkeys-16-gup-swizzle arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c~pkeys-16-gup-swizzle	2015-09-28 11:39:47.203239951 -0700
+++ b/arch/x86/mm/gup.c	2015-09-28 11:39:47.206240088 -0700
@@ -63,6 +63,19 @@ retry:
 #endif
 }
 
+static inline int pte_allows_gup(pte_t pte, int write)
+{
+	/*
+	 * Note that pte_present() is true for !_PAGE_PRESENT
+	 * but _PAGE_PROTNONE, so we can not use it here.
+	 */
+	if (!(pte_flags(pte) & (_PAGE_PRESENT|_PAGE_USER)))
+		return 0;
+	if (write && !pte_write(pte))
+		return 0;
+	return 1;
+}
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -71,13 +84,8 @@ retry:
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
@@ -88,8 +96,8 @@ static noinline int gup_pte_range(pmd_t
 			pte_unmap(ptep);
 			return 0;
 		}
-
-		if ((pte_flags(pte) & (mask | _PAGE_SPECIAL)) != mask) {
+		if (!pte_allows_gup(pte, write) ||
+		    pte_special(pte)) {
 			pte_unmap(ptep);
 			return 0;
 		}
@@ -117,15 +125,11 @@ static inline void get_head_page_multipl
 static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
-	unsigned long mask;
 	pte_t pte = *(pte_t *)&pmd;
 	struct page *head, *page;
 	int refs;
 
-	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
-	if ((pte_flags(pte) & mask) != mask)
+	if (!pte_allows_gup(pte, write))
 		return 0;
 	/* hugepages are never "special" */
 	VM_BUG_ON(pte_flags(pte) & _PAGE_SPECIAL);
@@ -194,15 +198,11 @@ static int gup_pmd_range(pud_t pud, unsi
 static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
-	unsigned long mask;
 	pte_t pte = *(pte_t *)&pud;
 	struct page *head, *page;
 	int refs;
 
-	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
-	if ((pte_flags(pte) & mask) != mask)
+	if (!pte_allows_gup(pte, write))
 		return 0;
 	/* hugepages are never "special" */
 	VM_BUG_ON(pte_flags(pte) & _PAGE_SPECIAL);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
