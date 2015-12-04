Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id AC06D82F64
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:01 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so556329pac.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:01 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q62si15484388pfq.5.2015.12.03.17.14.47
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:47 -0800 (PST)
Subject: [PATCH 16/34] x86, mm: simplify get_user_pages() PTE bit handling
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:46 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011446.DDC6435F@viggo.jf.intel.com>
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
---

 b/arch/x86/mm/gup.c |   45 ++++++++++++++++++++++++++++-----------------
 1 file changed, 28 insertions(+), 17 deletions(-)

diff -puN arch/x86/mm/gup.c~pkeys-16-gup-swizzle arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c~pkeys-16-gup-swizzle	2015-12-03 16:21:25.148649631 -0800
+++ b/arch/x86/mm/gup.c	2015-12-03 16:21:25.151649767 -0800
@@ -63,6 +63,30 @@ retry:
 #endif
 }
 
+static inline int pte_allows_gup(pte_t pte, int write)
+{
+	/*
+	 * 'pte' can reall be a pte, pmd or pud.  We only check
+	 * _PAGE_PRESENT, _PAGE_USER, and _PAGE_RW in here which
+	 * are the same value on all 3 types.
+	 */
+	if (!(pte_flags(pte) & (_PAGE_PRESENT|_PAGE_USER)))
+		return 0;
+	if (write && !(pte_write(pte)))
+		return 0;
+	return 1;
+}
+
+static inline int pmd_allows_gup(pmd_t pmd, int write)
+{
+	return pte_allows_gup(*(pte_t *)&pmd, write);
+}
+
+static inline int pud_allows_gup(pud_t pud, int write)
+{
+	return pte_allows_gup(*(pte_t *)&pud, write);
+}
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -71,13 +95,8 @@ retry:
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
@@ -88,8 +107,8 @@ static noinline int gup_pte_range(pmd_t
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
@@ -117,14 +136,10 @@ static inline void get_head_page_multipl
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
+	if (!pmd_allows_gup(pmd, write))
 		return 0;
 	/* hugepages are never "special" */
 	VM_BUG_ON(pmd_flags(pmd) & _PAGE_SPECIAL);
@@ -193,14 +208,10 @@ static int gup_pmd_range(pud_t pud, unsi
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
+	if (!pud_allows_gup(pud, write))
 		return 0;
 	/* hugepages are never "special" */
 	VM_BUG_ON(pud_flags(pud) & _PAGE_SPECIAL);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
