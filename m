Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2207D6B0044
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:16 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so2941138pdj.21
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 24/34] s390: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:49 +0300
Message-Id: <1381428359-14843-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/mm/pgtable.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index c463e5cd3b..b109edb90b 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -754,7 +754,11 @@ static inline unsigned long *page_table_alloc_pgste(struct mm_struct *mm,
 		__free_page(page);
 		return NULL;
 	}
-	pgtable_page_ctor(page);
+	if (!pgtable_page_ctor(page)) {
+		kfree(mp);
+		__free_page(page);
+		return NULL;
+	}
 	mp->vmaddr = vmaddr & PMD_MASK;
 	INIT_LIST_HEAD(&mp->mapper);
 	page->index = (unsigned long) mp;
@@ -884,7 +888,10 @@ unsigned long *page_table_alloc(struct mm_struct *mm, unsigned long vmaddr)
 		page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
 		if (!page)
 			return NULL;
-		pgtable_page_ctor(page);
+		if (!pgtable_page_ctor(page)) {
+			__free_page(page);
+			return NULL;
+		}
 		atomic_set(&page->_mapcount, 1);
 		table = (unsigned long *) page_to_phys(page);
 		clear_table(table, _PAGE_INVALID, PAGE_SIZE);
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
