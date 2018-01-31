Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19ABE6B0012
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:36 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id l33so15504873ywh.5
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:36 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f5si1481766qtd.167.2018.01.31.15.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:35 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 08/13] mm: temporarily convert lru_lock callsites to lock-all API
Date: Wed, 31 Jan 2018 18:04:08 -0500
Message-Id: <20180131230413.27653-9-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

These will use the lru_batch_locks in a later series.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/swap.c   | 18 ++++++++----------
 mm/vmscan.c |  4 ++--
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index c4ca7e1c7c03..cf6a59f2cad6 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -62,12 +62,12 @@ static void __page_cache_release(struct page *page)
 		struct lruvec *lruvec;
 		unsigned long flags;
 
-		spin_lock_irqsave(zone_lru_lock(zone), flags);
+		lru_lock_all(zone->zone_pgdat, &flags);
 		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
-		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
+		lru_unlock_all(zone->zone_pgdat, &flags);
 	}
 	__ClearPageWaiters(page);
 	mem_cgroup_uncharge(page);
@@ -758,7 +758,7 @@ void release_pages(struct page **pages, int nr)
 		 * same pgdat. The lock is held only if pgdat != NULL.
 		 */
 		if (locked_pgdat && ++lock_batch == SWAP_CLUSTER_MAX) {
-			spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
+			lru_unlock_all(locked_pgdat, &flags);
 			locked_pgdat = NULL;
 		}
 
@@ -768,8 +768,7 @@ void release_pages(struct page **pages, int nr)
 		/* Device public page can not be huge page */
 		if (is_device_public_page(page)) {
 			if (locked_pgdat) {
-				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
-						       flags);
+				lru_unlock_all(locked_pgdat, &flags);
 				locked_pgdat = NULL;
 			}
 			put_zone_device_private_or_public_page(page);
@@ -782,7 +781,7 @@ void release_pages(struct page **pages, int nr)
 
 		if (PageCompound(page)) {
 			if (locked_pgdat) {
-				spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
+				lru_unlock_all(locked_pgdat, &flags);
 				locked_pgdat = NULL;
 			}
 			__put_compound_page(page);
@@ -794,11 +793,10 @@ void release_pages(struct page **pages, int nr)
 
 			if (pgdat != locked_pgdat) {
 				if (locked_pgdat)
-					spin_unlock_irqrestore(&locked_pgdat->lru_lock,
-									flags);
+					lru_unlock_all(locked_pgdat, &flags);
 				lock_batch = 0;
 				locked_pgdat = pgdat;
-				spin_lock_irqsave(&locked_pgdat->lru_lock, flags);
+				lru_lock_all(locked_pgdat, &flags);
 			}
 
 			lruvec = mem_cgroup_page_lruvec(page, locked_pgdat);
@@ -814,7 +812,7 @@ void release_pages(struct page **pages, int nr)
 		list_add(&page->lru, &pages_to_free);
 	}
 	if (locked_pgdat)
-		spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
+		lru_unlock_all(locked_pgdat, &flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_unref_page_list(&pages_to_free);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b893200a397d..7f5ff0bb133f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1623,7 +1623,7 @@ int isolate_lru_page(struct page *page)
 		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
 
-		spin_lock_irq(zone_lru_lock(zone));
+		lru_lock_all(zone->zone_pgdat, NULL);
 		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
@@ -1632,7 +1632,7 @@ int isolate_lru_page(struct page *page)
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}
-		spin_unlock_irq(zone_lru_lock(zone));
+		lru_unlock_all(zone->zone_pgdat, NULL);
 	}
 	return ret;
 }
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
