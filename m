Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id ECB4F6B0266
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 04:58:37 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so70089987pac.2
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 01:58:37 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rb8si7436512pbb.243.2015.10.01.01.58.37
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 01:58:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: avoid false-positive PageTail() during meminit
Date: Thu,  1 Oct 2015 11:58:00 +0300
Message-Id: <1443689880-147129-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Since compound_head() rework we encode PageTail() into bit 0 of
page->lru.next (aka page->compound_head). We need to make sure that
page->lru is initialized before first use of compound_head() or
PageTail().

My page-flags patchset makes sure that we don't use PG_reserved on
compound pages. That means we have PageTail() check as eary as in
SetPageReserved() in reserve_bootmem_region()

Let's initialize page->lru before that to avoid false positive from
PageTail().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---

Andrew, this can be folded into "mm: make compound_head() robust"

---
 mm/page_alloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 778eb3a0f103..95fbc43a93dd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -926,8 +926,6 @@ static void init_reserved_page(unsigned long pfn)
 #else
 static inline void init_reserved_page(unsigned long pfn)
 {
-	/* Avoid false-positive PageTail() */
-	INIT_LIST_HEAD(&pfn_to_page(pfn)->lru);
 }
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
@@ -947,6 +945,10 @@ void __meminit reserve_bootmem_region(unsigned long start, unsigned long end)
 			struct page *page = pfn_to_page(start_pfn);
 
 			init_reserved_page(start_pfn);
+
+			/* Avoid false-positive PageTail() */
+			INIT_LIST_HEAD(&page->lru);
+
 			SetPageReserved(page);
 		}
 	}
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
