Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id E4E136B007B
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:28 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:25:23 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 7B896394004F
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:28:24 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345wJGG38535224
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:19 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wKBq026945
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:22 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 22/25] powerpc/THP: get_user_pages_fast changes
Date: Thu,  4 Apr 2013 11:28:00 +0530
Message-Id: <1365055083-31956-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

handle large pages for get_user_pages_fast. Also take care of large page splitting.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/gup.c |   84 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 82 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
index d7efdbf..835c1ae 100644
--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -55,6 +55,72 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 	return 1;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline int gup_huge_pmd(pmd_t *pmdp, unsigned long addr,
+			       unsigned long end, int write,
+			       struct page **pages, int *nr)
+{
+	int refs;
+	pmd_t pmd;
+	unsigned long mask;
+	struct page *head, *page, *tail;
+
+	pmd = *pmdp;
+	mask = PMD_HUGE_PRESENT | PMD_HUGE_USER;
+	if (write)
+		mask |= PMD_HUGE_RW;
+
+	if ((pmd_val(pmd) & mask) != mask)
+		return 0;
+
+	/* large pages are never "special" */
+	VM_BUG_ON(!pfn_valid(pmd_pfn(pmd)));
+
+	refs = 0;
+	head = pmd_page(pmd);
+	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	tail = page;
+	do {
+		VM_BUG_ON(compound_head(page) != head);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+
+	if (!page_cache_add_speculative(head, refs)) {
+		*nr -= refs;
+		return 0;
+	}
+
+	if (unlikely(pmd_val(pmd) != pmd_val(*pmdp))) {
+		*nr -= refs;
+		while (refs--)
+			put_page(head);
+		return 0;
+	}
+	/*
+	 * Any tail page need their mapcount reference taken before we
+	 * return.
+	 */
+	while (refs--) {
+		if (PageTail(tail))
+			get_huge_page_tail(tail);
+		tail++;
+	}
+
+	return 1;
+}
+#else
+
+static inline int gup_huge_pmd(pmd_t *pmdp, unsigned long addr,
+			       unsigned long end, int write,
+			       struct page **pages, int *nr)
+{
+	return 1;
+}
+#endif
+
 static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		int write, struct page **pages, int *nr)
 {
@@ -66,9 +132,23 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		pmd_t pmd = *pmdp;
 
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd))
+		/*
+		 * The pmd_trans_splitting() check below explains why
+		 * pmdp_splitting_flush has to flush the tlb, to stop
+		 * this gup-fast code from running while we set the
+		 * splitting bit in the pmd. Returning zero will take
+		 * the slow path that will call wait_split_huge_page()
+		 * if the pmd is still in splitting state. gup-fast
+		 * can't because it has irq disabled and
+		 * wait_split_huge_page() would never return as the
+		 * tlb flush IPI wouldn't run.
+		 */
+		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
 			return 0;
-		if (is_hugepd(pmdp)) {
+		if (unlikely(pmd_large(pmd))) {
+			if (!gup_huge_pmd(pmdp, addr, next, write, pages, nr))
+				return 0;
+		} else if (is_hugepd(pmdp)) {
 			if (!gup_hugepd((hugepd_t *)pmdp, PMD_SHIFT,
 					addr, next, write, pages, nr))
 				return 0;
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
