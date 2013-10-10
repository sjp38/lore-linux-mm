Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id E04CF6B0036
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:08 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so2940276pbc.22
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 04/34] xtensa: fix potential NULL-pointer dereference
Date: Thu, 10 Oct 2013 21:05:29 +0300
Message-Id: <1381428359-14843-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>

Add missing check for memory allocation fail.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Chris Zankel <chris@zankel.net>
Cc: Max Filippov <jcmvbkbc@gmail.com>
---
 arch/xtensa/include/asm/pgalloc.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/xtensa/include/asm/pgalloc.h b/arch/xtensa/include/asm/pgalloc.h
index cf914c8c24..037671a655 100644
--- a/arch/xtensa/include/asm/pgalloc.h
+++ b/arch/xtensa/include/asm/pgalloc.h
@@ -51,9 +51,13 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 					unsigned long addr)
 {
+	pte_t *pte;
 	struct page *page;
 
-	page = virt_to_page(pte_alloc_one_kernel(mm, addr));
+	pte = pte_alloc_one_kernel(mm, addr);
+	if (!pte)
+		return NULL;
+	page = virt_to_page(pte);
 	pgtable_page_ctor(page);
 	return page;
 }
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
