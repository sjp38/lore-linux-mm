Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B6B3E900007
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:13 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so3130841pab.10
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 10/34] arc: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:35 +0300
Message-Id: <1381428359-14843-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/pgalloc.h | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/arch/arc/include/asm/pgalloc.h b/arch/arc/include/asm/pgalloc.h
index 36a9f20c21..81208bfd9d 100644
--- a/arch/arc/include/asm/pgalloc.h
+++ b/arch/arc/include/asm/pgalloc.h
@@ -105,11 +105,16 @@ static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	pgtable_t pte_pg;
+	struct page *page;
 
 	pte_pg = __get_free_pages(GFP_KERNEL | __GFP_REPEAT, __get_order_pte());
-	if (pte_pg) {
-		memzero((void *)pte_pg, PTRS_PER_PTE * 4);
-		pgtable_page_ctor(virt_to_page(pte_pg));
+	if (!pte_pg)
+		return 0;
+	memzero((void *)pte_pg, PTRS_PER_PTE * 4);
+	page = virt_to_page(pte_pg);
+	if (!pgtable_page_ctor(page)) {
+		__free_page(page);
+		return 0;
 	}
 
 	return pte_pg;
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
