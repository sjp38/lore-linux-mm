Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEB5900005
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:13 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so2960935pdj.11
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:12 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 15/34] frv: handle pgtable_page_ctor() fail
Date: Thu, 10 Oct 2013 21:05:40 +0300
Message-Id: <1381428359-14843-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Howells <dhowells@redhat.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Howells <dhowells@redhat.com>
---
 arch/frv/mm/pgalloc.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/arch/frv/mm/pgalloc.c b/arch/frv/mm/pgalloc.c
index f6084bc524..41907d25ed 100644
--- a/arch/frv/mm/pgalloc.c
+++ b/arch/frv/mm/pgalloc.c
@@ -37,11 +37,15 @@ pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 #else
 	page = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
 #endif
-	if (page) {
-		clear_highpage(page);
-		pgtable_page_ctor(page);
-		flush_dcache_page(page);
+	if (!page)
+		return NULL;
+
+	clear_highpage(page);
+	if (!pgtable_page_ctor(page)) {
+		__free_page(page);
+		return NULL;
 	}
+	flush_dcache_page(page);
 	return page;
 }
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
