Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 96D02900004
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:11 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so3131319pab.29
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:11 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 12/34] arm64: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:37 +0300
Message-Id: <1381428359-14843-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
---
 arch/arm64/include/asm/pgalloc.h | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index f214069ec5..9bea6e74a0 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -63,9 +63,12 @@ pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 	struct page *pte;
 
 	pte = alloc_pages(PGALLOC_GFP, 0);
-	if (pte)
-		pgtable_page_ctor(pte);
-
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
