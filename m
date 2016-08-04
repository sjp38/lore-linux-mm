Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B484C6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 07:29:53 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id le9so29475628pab.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:29:53 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id d5si14320037pfb.98.2016.08.04.04.29.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 04:29:53 -0700 (PDT)
Message-ID: <57A3260F.4050709@huawei.com>
Date: Thu, 4 Aug 2016 19:25:03 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mm: fix set pageblock migratetype in deferred struct
 page init
References: <57A325CA.9050707@huawei.com>
In-Reply-To: <57A325CA.9050707@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

MAX_ORDER_NR_PAGES is usually 4M, and a pageblock is usually 2M, so we only
set one pageblock's migratetype in deferred_free_range() if pfn is aligned
to MAX_ORDER_NR_PAGES.

Also we missed to free the last block in deferred_init_memmap().

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b258ec..e0ec3b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1399,15 +1399,18 @@ static void __init deferred_free_range(struct page *page,
 		return;
 
 	/* Free a large naturally-aligned chunk if possible */
-	if (nr_pages == MAX_ORDER_NR_PAGES &&
-	    (pfn & (MAX_ORDER_NR_PAGES-1)) == 0) {
+	if (nr_pages == pageblock_nr_pages &&
+	    (pfn & (pageblock_nr_pages - 1)) == 0) {
 		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-		__free_pages_boot_core(page, MAX_ORDER-1);
+		__free_pages_boot_core(page, pageblock_order);
 		return;
 	}
 
-	for (i = 0; i < nr_pages; i++, page++)
+	for (i = 0; i < nr_pages; i++, page++, pfn++) {
+		if ((pfn & (pageblock_nr_pages - 1)) == 0)
+			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 		__free_pages_boot_core(page, 0);
+	}
 }
 
 /* Completion tracking for deferred_init_memmap() threads */
@@ -1475,9 +1478,9 @@ static int __init deferred_init_memmap(void *data)
 
 			/*
 			 * Ensure pfn_valid is checked every
-			 * MAX_ORDER_NR_PAGES for memory holes
+			 * pageblock_nr_pages for memory holes
 			 */
-			if ((pfn & (MAX_ORDER_NR_PAGES - 1)) == 0) {
+			if ((pfn & (pageblock_nr_pages - 1)) == 0) {
 				if (!pfn_valid(pfn)) {
 					page = NULL;
 					goto free_range;
@@ -1490,7 +1493,7 @@ static int __init deferred_init_memmap(void *data)
 			}
 
 			/* Minimise pfn page lookups and scheduler checks */
-			if (page && (pfn & (MAX_ORDER_NR_PAGES - 1)) != 0) {
+			if (page && (pfn & (pageblock_nr_pages - 1)) != 0) {
 				page++;
 			} else {
 				nr_pages += nr_to_free;
@@ -1526,6 +1529,9 @@ free_range:
 			free_base_page = NULL;
 			free_base_pfn = nr_to_free = 0;
 		}
+		/* Free the last block of pages to allocator */
+		nr_pages += nr_to_free;
+		deferred_free_range(free_base_page, free_base_pfn, nr_to_free);
 
 		first_init_pfn = max(end_pfn, first_init_pfn);
 	}
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
