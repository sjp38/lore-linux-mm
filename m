Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3759C000A
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:30 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so2978150pdj.4
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 18/34] m32r: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:43 +0300
Message-Id: <1381428359-14843-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hirokazu Takata <takata@linux-m32r.org>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hirokazu Takata <takata@linux-m32r.org>
---
 arch/m32r/include/asm/pgalloc.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/m32r/include/asm/pgalloc.h b/arch/m32r/include/asm/pgalloc.h
index ac4208bcc5..2d55a064cc 100644
--- a/arch/m32r/include/asm/pgalloc.h
+++ b/arch/m32r/include/asm/pgalloc.h
@@ -45,7 +45,10 @@ static __inline__ pgtable_t pte_alloc_one(struct mm_struct *mm,
 
 	if (!pte)
 		return NULL;
-	pgtable_page_ctor(pte);
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
