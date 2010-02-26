Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E79516B00A4
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:26 -0500 (EST)
Message-Id: <20100226200901.445609244@redhat.com>
Date: Fri, 26 Feb 2010 21:04:49 +0100
From: aarcange@redhat.com
Subject: [patch 16/35] bail out gup_fast on splitting pmd
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=gup_fast_bail_out
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Force gup_fast to take the slow path and block if the pmd is splitting, not
only if it's none.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 arch/x86/mm/gup.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -160,7 +160,18 @@ static int gup_pmd_range(pud_t pud, unsi
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
 		if (unlikely(pmd_large(pmd))) {
 			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
