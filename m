Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5CA900001
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:12 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so3121932pab.15
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:11 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 13/34] avr32: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:38 +0300
Message-Id: <1381428359-14843-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
---
 arch/avr32/include/asm/pgalloc.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/avr32/include/asm/pgalloc.h b/arch/avr32/include/asm/pgalloc.h
index bc7e8ae479..1aba19d68c 100644
--- a/arch/avr32/include/asm/pgalloc.h
+++ b/arch/avr32/include/asm/pgalloc.h
@@ -68,7 +68,10 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 		return NULL;
 
 	page = virt_to_page(pg);
-	pgtable_page_ctor(page);
+	if (!pgtable_page_ctor(page)) {
+		quicklist_free(QUICK_PT, NULL, pg);
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
