Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 51C426B003D
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:11 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so2978705pdj.35
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 11/34] arm: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:36 +0300
Message-Id: <1381428359-14843-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King <linux@arm.linux.org.uk>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Russell King <linux@arm.linux.org.uk>
---
 arch/arm/include/asm/pgalloc.h | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index 943504f53f..78a7793616 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -102,12 +102,14 @@ pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 #else
 	pte = alloc_pages(PGALLOC_GFP, 0);
 #endif
-	if (pte) {
-		if (!PageHighMem(pte))
-			clean_pte_table(page_address(pte));
-		pgtable_page_ctor(pte);
+	if (!pte)
+		return NULL;
+	if (!PageHighMem(pte))
+		clean_pte_table(page_address(pte));
+	if (!pgtable_page_ctor(pte)) {
+		__free_page(pte);
+		return NULL;
 	}
-
 	return pte;
 }
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
