Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5636B0023
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:38 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 1so11158118uas.23
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:38 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k39si515808uae.128.2018.01.31.15.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:37 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 11/13] mm: use lru_batch locking in release_pages
Date: Wed, 31 Jan 2018 18:04:11 -0500
Message-Id: <20180131230413.27653-12-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

Introduce LRU batch locking in release_pages.  This is the code path
where I see lru_lock contention most often, so this is the one I used in
this prototype.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/swap.c | 45 +++++++++++++++++----------------------------
 1 file changed, 17 insertions(+), 28 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 2bb28fcb7cc0..fae766e035a4 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -745,31 +745,21 @@ void release_pages(struct page **pages, int nr)
 	int i;
 	LIST_HEAD(pages_to_free);
 	struct pglist_data *locked_pgdat = NULL;
+	spinlock_t *locked_lru_batch = NULL;
 	struct lruvec *lruvec;
 	unsigned long uninitialized_var(flags);
-	unsigned int uninitialized_var(lock_batch);
 
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
-		/*
-		 * Make sure the IRQ-safe lock-holding time does not get
-		 * excessive with a continuous string of pages from the
-		 * same pgdat. The lock is held only if pgdat != NULL.
-		 */
-		if (locked_pgdat && ++lock_batch == SWAP_CLUSTER_MAX) {
-			lru_unlock_all(locked_pgdat, &flags);
-			locked_pgdat = NULL;
-		}
-
 		if (is_huge_zero_page(page))
 			continue;
 
 		/* Device public page can not be huge page */
 		if (is_device_public_page(page)) {
-			if (locked_pgdat) {
-				lru_unlock_all(locked_pgdat, &flags);
-				locked_pgdat = NULL;
+			if (locked_lru_batch) {
+				lru_batch_unlock(NULL, &locked_lru_batch,
+						 &locked_pgdat, &flags);
 			}
 			put_zone_device_private_or_public_page(page);
 			continue;
@@ -780,26 +770,23 @@ void release_pages(struct page **pages, int nr)
 			continue;
 
 		if (PageCompound(page)) {
-			if (locked_pgdat) {
-				lru_unlock_all(locked_pgdat, &flags);
-				locked_pgdat = NULL;
+			if (locked_lru_batch) {
+				lru_batch_unlock(NULL, &locked_lru_batch,
+						 &locked_pgdat, &flags);
 			}
 			__put_compound_page(page);
 			continue;
 		}
 
 		if (PageLRU(page)) {
-			struct pglist_data *pgdat = page_pgdat(page);
-
-			if (pgdat != locked_pgdat) {
-				if (locked_pgdat)
-					lru_unlock_all(locked_pgdat, &flags);
-				lock_batch = 0;
-				locked_pgdat = pgdat;
-				lru_lock_all(locked_pgdat, &flags);
+			if (locked_lru_batch) {
+				lru_batch_unlock(page, &locked_lru_batch,
+						 &locked_pgdat, &flags);
 			}
+			lru_batch_lock(page, &locked_lru_batch, &locked_pgdat,
+				       &flags);
 
-			lruvec = mem_cgroup_page_lruvec(page, locked_pgdat);
+			lruvec = mem_cgroup_page_lruvec(page, page_pgdat(page));
 			VM_BUG_ON_PAGE(!PageLRU(page), page);
 			__ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
@@ -811,8 +798,10 @@ void release_pages(struct page **pages, int nr)
 
 		list_add(&page->lru, &pages_to_free);
 	}
-	if (locked_pgdat)
-		lru_unlock_all(locked_pgdat, &flags);
+	if (locked_lru_batch) {
+		lru_batch_unlock(NULL, &locked_lru_batch, &locked_pgdat,
+				 &flags);
+	}
 
 	mem_cgroup_uncharge_list(&pages_to_free);
 	free_unref_page_list(&pages_to_free);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
