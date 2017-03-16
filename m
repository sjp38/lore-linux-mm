Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0927B6B03A0
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:01:54 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 187so19733574itk.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:01:54 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0135.hostedemail.com. [216.40.44.135])
        by mx.google.com with ESMTPS id v188si2029755itg.76.2017.03.15.19.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:01:53 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/15] mm: page_alloc: Avoid pointer comparisons to NULL
Date: Wed, 15 Mar 2017 19:00:09 -0700
Message-Id: <e1c88647d29937555519124a4fba2367af74939a.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Use direct test instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f9e6387c0ad4..b6605b077053 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -931,7 +931,7 @@ static void free_pages_check_bad(struct page *page)
 
 	if (unlikely(atomic_read(&page->_mapcount) != -1))
 		bad_reason = "nonzero mapcount";
-	if (unlikely(page->mapping != NULL))
+	if (unlikely(page->mapping))
 		bad_reason = "non-NULL mapping";
 	if (unlikely(page_ref_count(page) != 0))
 		bad_reason = "nonzero _refcount";
@@ -1668,7 +1668,7 @@ static void check_new_page_bad(struct page *page)
 
 	if (unlikely(atomic_read(&page->_mapcount) != -1))
 		bad_reason = "nonzero mapcount";
-	if (unlikely(page->mapping != NULL))
+	if (unlikely(page->mapping))
 		bad_reason = "non-NULL mapping";
 	if (unlikely(page_ref_count(page) != 0))
 		bad_reason = "nonzero _count";
@@ -2289,7 +2289,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 	for (i = 0; i < count; ++i) {
 		struct page *page = __rmqueue(zone, order, migratetype);
 
-		if (unlikely(page == NULL))
+		if (unlikely(!page))
 			break;
 
 		if (unlikely(check_pcp_refill(page)))
@@ -4951,7 +4951,7 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
 	struct zonelist *zonelist;
 
 	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
-	for (j = 0; zonelist->_zonerefs[j].zone != NULL; j++)
+	for (j = 0; zonelist->_zonerefs[j].zone; j++)
 		;
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j);
 	zonelist->_zonerefs[j].zone = NULL;
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
