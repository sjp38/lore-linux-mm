Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 434886B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 07:51:29 -0400 (EDT)
Received: by pactp5 with SMTP id tp5so17586440pac.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 04:51:28 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id eu8si19153152pdb.133.2015.03.31.04.51.27
        for <linux-mm@kvack.org>;
        Tue, 31 Mar 2015 04:51:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: use PageAnon() and PageKsm() helpers in page_anon_vma()
Date: Tue, 31 Mar 2015 14:50:47 +0300
Message-Id: <1427802647-16764-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

page_anon_vma() directly checks PAGE_MAPPING_ANON and PAGE_MAPPING_KSM
bits on page->mapping to find out if page->mapping is anon_vma;

Let's use PageAnon() and PageKsm() helpers instead. It helps readability
and makes page_anon_vma() work correctly on tail pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 9c5ff69fa0cd..21f10e53bb9e 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -108,8 +108,7 @@ static inline void put_anon_vma(struct anon_vma *anon_vma)
 
 static inline struct anon_vma *page_anon_vma(struct page *page)
 {
-	if (((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) !=
-					    PAGE_MAPPING_ANON)
+	if (!PageAnon(page) || PageKsm(page))
 		return NULL;
 	return page_rmapping(page);
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
