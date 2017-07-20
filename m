Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB5396B02F3
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 09:40:41 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k71so13060399wrc.15
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 06:40:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p124si1699862wmd.269.2017.07.20.06.40.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 06:40:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/4] mm, page_owner: make init_pages_in_zone() faster
Date: Thu, 20 Jul 2017 15:40:26 +0200
Message-Id: <20170720134029.25268-2-vbabka@suse.cz>
In-Reply-To: <20170720134029.25268-1-vbabka@suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>, Vlastimil Babka <vbabka@suse.cz>

In init_pages_in_zone() we currently use the generic set_page_owner() function
to initialize page_owner info for early allocated pages. This means we
needlessly do lookup_page_ext() twice for each page, and more importantly
save_stack(), which has to unwind the stack and find the corresponding stack
depot handle. Because the stack is always the same for the initialization,
unwind it once in init_pages_in_zone() and reuse the handle. Also avoid the
repeated lookup_page_ext().

This can significantly reduce boot times with page_owner=on on large machines,
especially for kernels built without frame pointer, where the stack unwinding
is noticeably slower.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_owner.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 401feb070335..5aa21ca237d9 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -183,6 +183,20 @@ noinline void __set_page_owner(struct page *page, unsigned int order,
 	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
 }
 
+static void __set_page_owner_init(struct page_ext *page_ext,
+					depot_stack_handle_t handle)
+{
+	struct page_owner *page_owner;
+
+	page_owner = get_page_owner(page_ext);
+	page_owner->handle = handle;
+	page_owner->order = 0;
+	page_owner->gfp_mask = 0;
+	page_owner->last_migrate_reason = -1;
+
+	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
+}
+
 void __set_page_owner_migrate_reason(struct page *page, int reason)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
@@ -520,10 +534,13 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
 	unsigned long end_pfn = pfn + zone->spanned_pages;
 	unsigned long count = 0;
+	depot_stack_handle_t init_handle;
 
 	/* Scan block by block. First and last block may be incomplete */
 	pfn = zone->zone_start_pfn;
 
+	init_handle = save_stack(0);
+
 	/*
 	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
 	 * a zone boundary, it will be double counted between zones. This does
@@ -570,7 +587,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 				continue;
 
 			/* Found early allocated page */
-			set_page_owner(page, 0, 0);
+			__set_page_owner_init(page_ext, init_handle);
 			count++;
 		}
 	}
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
