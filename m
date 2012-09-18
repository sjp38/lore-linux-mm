Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id D00286B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 18:06:06 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mm: thp: fix pmd_present for split_huge_page and PROT_NONE with THP
Date: Wed, 19 Sep 2012 00:05:59 +0200
Message-Id: <1348005959-4869-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

In many places !pmd_present has been converted to pmd_none. For pmds
that's equivalent and pmd_none is quicker so using pmd_none is
better.

However (unless we delete pmd_present) we should provide an accurate
pmd_present too. This will avoid the risk of code thinking the pmd is
non present because it's under __split_huge_page_map, see the
pmd_mknotpresent there and the comment above it.

If the page has been mprotected as PROT_NONE, it would also lead to a
pmd_present false negative in the same way as the race with
split_huge_page.

Because the PSE bit stays on at all times (both during split_huge_page
and when the _PAGE_PROTNONE bit get set), we could only check for the
PSE bit, but checking the PROTNONE bit too is still good to remember
pmd_present must always keep PROT_NONE into account.

This explains a not reproducible BUG_ON that was seldom reported on
the lists.

The same issue is in pmd_large, it would go wrong with both PROT_NONE
and if it races with split_huge_page.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/include/asm/pgtable.h |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 49afb3f..c3520d7 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -146,8 +146,7 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
 
 static inline int pmd_large(pmd_t pte)
 {
-	return (pmd_flags(pte) & (_PAGE_PSE | _PAGE_PRESENT)) ==
-		(_PAGE_PSE | _PAGE_PRESENT);
+	return pmd_flags(pte) & _PAGE_PSE;
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -415,7 +414,13 @@ static inline int pte_hidden(pte_t pte)
 
 static inline int pmd_present(pmd_t pmd)
 {
-	return pmd_flags(pmd) & _PAGE_PRESENT;
+	/*
+	 * Checking for _PAGE_PSE is needed too because
+	 * split_huge_page will temporarily clear the present bit (but
+	 * the _PAGE_PSE flag will remain set at all times while the
+	 * _PAGE_PRESENT bit is clear).
+	 */
+	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE);
 }
 
 static inline int pmd_none(pmd_t pmd)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
