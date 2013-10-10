Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 06A946B005C
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:17 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so2937686pdj.7
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:17 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 20/34] metag: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:45 +0300
Message-Id: <1381428359-14843-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, James Hogan <james.hogan@imgtec.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: James Hogan <james.hogan@imgtec.com>
---
 arch/metag/include/asm/pgalloc.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/metag/include/asm/pgalloc.h b/arch/metag/include/asm/pgalloc.h
index 275d928514..3104df0a48 100644
--- a/arch/metag/include/asm/pgalloc.h
+++ b/arch/metag/include/asm/pgalloc.h
@@ -52,8 +52,12 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 {
 	struct page *pte;
 	pte = alloc_pages(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0);
-	if (pte)
-		pgtable_page_ctor(pte);
+	if (!pte)
+		return NULL;
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
