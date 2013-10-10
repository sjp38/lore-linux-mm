Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id CA7239C0010
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:39 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so2873698pbc.8
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 30/34] unicore32: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:55 +0300
Message-Id: <1381428359-14843-31-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
---
 arch/unicore32/include/asm/pgalloc.h | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/arch/unicore32/include/asm/pgalloc.h b/arch/unicore32/include/asm/pgalloc.h
index 0213e373a8..2e02d1356f 100644
--- a/arch/unicore32/include/asm/pgalloc.h
+++ b/arch/unicore32/include/asm/pgalloc.h
@@ -51,12 +51,14 @@ pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 	struct page *pte;
 
 	pte = alloc_pages(PGALLOC_GFP, 0);
-	if (pte) {
-		if (!PageHighMem(pte)) {
-			void *page = page_address(pte);
-			clean_dcache_area(page, PTRS_PER_PTE * sizeof(pte_t));
-		}
-		pgtable_page_ctor(pte);
+	if (!pte)
+		return NULL;
+	if (!PageHighMem(pte)) {
+		void *page = page_address(pte);
+		clean_dcache_area(page, PTRS_PER_PTE * sizeof(pte_t));
+	}
+	if (!pgtable_page_ctor(pte)) {
+		__free_page(pte);
 	}
 
 	return pte;
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
