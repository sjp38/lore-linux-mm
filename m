Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A74DF6B0044
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:16 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so3101988pad.33
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:16 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 07/34] mn10300: add missing pgtable_page_ctor/dtor calls
Date: Thu, 10 Oct 2013 21:05:32 +0300
Message-Id: <1381428359-14843-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>

It will fix NR_PAGETABLE accounting. It's also required if the arch is
going ever support split ptl.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
---
 arch/mn10300/include/asm/pgalloc.h | 1 +
 arch/mn10300/mm/pgtable.c          | 9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/mn10300/include/asm/pgalloc.h b/arch/mn10300/include/asm/pgalloc.h
index 146bacf193..0f25d5fa86 100644
--- a/arch/mn10300/include/asm/pgalloc.h
+++ b/arch/mn10300/include/asm/pgalloc.h
@@ -46,6 +46,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
+	pgtable_page_dtor(pte);
 	__free_page(pte);
 }
 
diff --git a/arch/mn10300/mm/pgtable.c b/arch/mn10300/mm/pgtable.c
index bd9ada693f..e77a7c7280 100644
--- a/arch/mn10300/mm/pgtable.c
+++ b/arch/mn10300/mm/pgtable.c
@@ -78,8 +78,13 @@ struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 #else
 	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
 #endif
-	if (pte)
-		clear_highpage(pte);
+	if (!pte)
+		return NULL;
+	clear_highpage(pte);
+	if (!pgtable_page_ctor(pte)) {
+		__free_page(pte);
+		return NULL;
+	}
 	return pte;
 }
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
