Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3047A6B0257
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:13:45 -0500 (EST)
Received: by obbnk6 with SMTP id nk6so34712490obb.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:13:45 -0800 (PST)
Received: from m50-134.163.com (m50-134.163.com. [123.125.50.134])
        by mx.google.com with ESMTP id l194si3678509oib.83.2015.12.02.07.13.43
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 07:13:44 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 2/2] mm/page_alloc.c: use list_for_each_entry in mark_free_pages()
Date: Wed,  2 Dec 2015 23:12:41 +0800
Message-Id: <7009a8fa2dba33da9bcfe60db4741139c07c8074.1449068845.git.geliangtang@163.com>
In-Reply-To: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
References: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
In-Reply-To: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
References: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Alexander Duyck <alexander.h.duyck@redhat.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use list_for_each_entry instead of list_for_each + list_entry to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/page_alloc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d38185..1c1ad58 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2027,7 +2027,7 @@ void mark_free_pages(struct zone *zone)
 	unsigned long pfn, max_zone_pfn;
 	unsigned long flags;
 	unsigned int order, t;
-	struct list_head *curr;
+	struct page *page;
 
 	if (zone_is_empty(zone))
 		return;
@@ -2037,17 +2037,17 @@ void mark_free_pages(struct zone *zone)
 	max_zone_pfn = zone_end_pfn(zone);
 	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 		if (pfn_valid(pfn)) {
-			struct page *page = pfn_to_page(pfn);
-
+			page = pfn_to_page(pfn);
 			if (!swsusp_page_is_forbidden(page))
 				swsusp_unset_page_free(page);
 		}
 
 	for_each_migratetype_order(order, t) {
-		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+		list_for_each_entry(page,
+				&zone->free_area[order].free_list[t], lru) {
 			unsigned long i;
 
-			pfn = page_to_pfn(list_entry(curr, struct page, lru));
+			pfn = page_to_pfn(page);
 			for (i = 0; i < (1UL << order); i++)
 				swsusp_set_page_free(pfn_to_page(pfn + i));
 		}
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
