Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3983C6B0078
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 00:25:18 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/4] hugetlb, rmap: always use anon_vma root pointer
Date: Fri, 10 Sep 2010 13:23:03 +0900
Message-Id: <1284092586-1179-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch applies Andrea's fix given by the following patch into hugepage
rmapping code:

  commit 288468c334e98aacbb7e2fb8bde6bc1adcd55e05
  Author: Andrea Arcangeli <aarcange@redhat.com>
  Date:   Mon Aug 9 17:19:09 2010 -0700

This patch uses anon_vma->root and avoids unnecessary overwriting when
anon_vma is already set up.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/rmap.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git v2.6.36-rc3/mm/rmap.c v2.6.36-rc3/mm/rmap.c
index f6f0d2d..2854857 100644
--- v2.6.36-rc3/mm/rmap.c
+++ v2.6.36-rc3/mm/rmap.c
@@ -1564,13 +1564,14 @@ static void __hugepage_set_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address, int exclusive)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
+
 	BUG_ON(!anon_vma);
-	if (!exclusive) {
-		struct anon_vma_chain *avc;
-		avc = list_entry(vma->anon_vma_chain.prev,
-				 struct anon_vma_chain, same_vma);
-		anon_vma = avc->anon_vma;
-	}
+
+	if (PageAnon(page))
+		return;
+	if (!exclusive)
+		anon_vma = anon_vma->root;
+
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	page->mapping = (struct address_space *) anon_vma;
 	page->index = linear_page_index(vma, address);
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
