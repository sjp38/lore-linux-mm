Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 23DFB6B02A7
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:53:17 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so47351433pab.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:53:16 -0800 (PST)
Received: from m50-135.163.com (m50-135.163.com. [123.125.50.135])
        by mx.google.com with ESMTP id yj5si4657816pbc.32.2015.11.18.05.53.15
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 05:53:16 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm, thp: use list_first_entry_or_null()
Date: Wed, 18 Nov 2015 21:52:29 +0800
Message-Id: <007bfe4833c1e47bd313de6a1be65d61aa7e36e2.1447854574.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Mel Gorman <mgorman@suse.de>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Simplify the code with list_first_entry_or_null().

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/pgtable-generic.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 69261d4..c311a2e 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -164,13 +164,10 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 
 	/* FIFO */
 	pgtable = pmd_huge_pte(mm, pmdp);
-	if (list_empty(&pgtable->lru))
-		pmd_huge_pte(mm, pmdp) = NULL;
-	else {
-		pmd_huge_pte(mm, pmdp) = list_entry(pgtable->lru.next,
-					      struct page, lru);
+	pmd_huge_pte(mm, pmdp) = list_first_entry_or_null(&pgtable->lru,
+							  struct page, lru);
+	if (pmd_huge_pte(mm, pmdp))
 		list_del(&pgtable->lru);
-	}
 	return pgtable;
 }
 #endif
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
