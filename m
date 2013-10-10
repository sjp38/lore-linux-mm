Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF1A6B0039
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:10 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so2903616pbc.7
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:09 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/34] microblaze: add missing pgtable_page_ctor/dtor calls
Date: Thu, 10 Oct 2013 21:05:31 +0300
Message-Id: <1381428359-14843-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Simek <monstr@monstr.eu>

It will fix NR_PAGETABLE accounting. It's also required if the arch is
going ever support split ptl.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Simek <monstr@monstr.eu>
---
 arch/microblaze/include/asm/pgalloc.h | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/arch/microblaze/include/asm/pgalloc.h b/arch/microblaze/include/asm/pgalloc.h
index ebd3579248..7fdf7fabc7 100644
--- a/arch/microblaze/include/asm/pgalloc.h
+++ b/arch/microblaze/include/asm/pgalloc.h
@@ -122,8 +122,13 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 #endif
 
 	ptepage = alloc_pages(flags, 0);
-	if (ptepage)
-		clear_highpage(ptepage);
+	if (!ptepage)
+		return NULL;
+	clear_highpage(ptepage);
+	if (!pgtable_page_ctor(ptepage)) {
+		__free_page(ptepage);
+		return NULL;
+	}
 	return ptepage;
 }
 
@@ -158,8 +163,9 @@ extern inline void pte_free_slow(struct page *ptepage)
 	__free_page(ptepage);
 }
 
-extern inline void pte_free(struct mm_struct *mm, struct page *ptepage)
+static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
 {
+	pgtable_page_dtor(ptepage);
 	__free_page(ptepage);
 }
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
