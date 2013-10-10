Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6832B9C0004
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:17 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so3106478pad.21
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:17 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 21/34] mips: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:46 +0300
Message-Id: <1381428359-14843-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ralf Baechle <ralf@linux-mips.org>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
---
 arch/mips/include/asm/pgalloc.h | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index 881d18b4e2..b336037e87 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -80,9 +80,12 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 	struct page *pte;
 
 	pte = alloc_pages(GFP_KERNEL | __GFP_REPEAT, PTE_ORDER);
-	if (pte) {
-		clear_highpage(pte);
-		pgtable_page_ctor(pte);
+	if (!pte)
+		return NULL;
+	clear_highpage(pte);
+	if (!pgtable_page_ctor(pte)) {
+		__free_page(pte);
+		return NULL;
 	}
 	return pte;
 }
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
