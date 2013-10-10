Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC0B9C0007
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:19 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so2982631pdj.32
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 22/34] parisc: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:47 +0300
Message-Id: <1381428359-14843-23-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
---
 arch/parisc/include/asm/pgalloc.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index fc987a1c12..f213f5b4c4 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -121,8 +121,12 @@ static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *page = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-	if (page)
-		pgtable_page_ctor(page);
+	if (!page)
+		return NULL;
+	if (!pgtable_page_ctor(page)) {
+		__free_page(page);
+		return NULL;
+	}
 	return page;
 }
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
