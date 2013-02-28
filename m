Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 5691F6B000C
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:16 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 16:27:14 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 131BE38C8025
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:11 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLR9Rc25034982
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:10 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLR9XJ023274
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:09 -0500
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 19/24] page_alloc: transplant pages that are being flushed from the per-cpu lists
Date: Thu, 28 Feb 2013 13:26:16 -0800
Message-Id: <1362086781-16725-10-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

In free_pcppages_bulk(), check if a page needs to be moved to a new
node/zone & then perform the transplant (in a slightly defered manner).

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5579eda..11947c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -650,13 +650,14 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	int migratetype = 0;
 	int batch_free = 0;
 	int to_free = count;
+	struct page *pos, *page;
+	LIST_HEAD(need_move);
 
 	spin_lock(&zone->lock);
 	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 
 	while (to_free) {
-		struct page *page;
 		struct list_head *list;
 
 		/*
@@ -679,11 +680,23 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 
 		do {
 			int mt;	/* migratetype of the to-be-freed page */
+			int dest_nid;
 
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
 			mt = get_freepage_migratetype(page);
+
+			dest_nid = dnuma_page_needs_move(page);
+			if (dest_nid != NUMA_NO_NODE) {
+				dnuma_prior_free_to_new_zone(page, 0,
+						nid_zone(dest_nid,
+							page_zonenum(page)),
+						dest_nid);
+				list_add(&page->lru, &need_move);
+				continue;
+			}
+
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
@@ -695,6 +708,27 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
 	spin_unlock(&zone->lock);
+
+	list_for_each_entry_safe(page, pos, &need_move, lru) {
+		struct zone *dest_zone = page_zone(page);
+		int mt;
+
+		spin_lock(&dest_zone->lock);
+
+		VM_BUG_ON(dest_zone != page_zone(page));
+		pr_devel("freeing pcp page %pK with changed node\n", page);
+		list_del(&page->lru);
+		mt = get_freepage_migratetype(page);
+		__free_one_page(page, dest_zone, 0, mt);
+		trace_mm_page_pcpu_drain(page, 0, mt);
+
+		/* XXX: fold into "post_free_to_new_zone()" ? */
+		if (is_migrate_cma(mt))
+			__mod_zone_page_state(dest_zone, NR_FREE_CMA_PAGES, 1);
+		dnuma_post_free_to_new_zone(page, 0);
+
+		spin_unlock(&dest_zone->lock);
+	}
 }
 
 static void free_one_page(struct zone *zone, struct page *page, int order,
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
