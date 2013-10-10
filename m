Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB909C000F
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:40 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so2887413pbc.30
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 17/34] ia64: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:42 +0300
Message-Id: <1381428359-14843-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 arch/ia64/include/asm/pgalloc.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index 96a8d927db..5767cdfc08 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -91,7 +91,10 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 	if (!pg)
 		return NULL;
 	page = virt_to_page(pg);
-	pgtable_page_ctor(page);
+	if (!pgtable_page_ctor(page)) {
+		quicklist_free(0, NULL, pg);
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
