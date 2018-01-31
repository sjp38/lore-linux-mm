Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC8116B0026
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:40 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id l6so15260552qtj.0
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:40 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id x22si2749728qka.31.2018.01.31.15.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:39 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 12/13] mm: split up release_pages into non-sentinel and sentinel passes
Date: Wed, 31 Jan 2018 18:04:12 -0500
Message-Id: <20180131230413.27653-13-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

A common case in release_pages is for the 'pages' list to be in roughly
the same order as they are in their LRU.  With LRU batch locking, when a
sentinel page is removed, an adjacent non-sentinel page must be promoted
to a sentinel page to follow the locking scheme.  So we can get behavior
where nearly every page in the 'pages' array is treated as a sentinel
page, hurting the scalability of this approach.

To address this, split up release_pages into non-sentinel and sentinel
passes so that the non-sentinel pages can be locked with an LRU batch
lock before the sentinel pages are removed.

For the prototype, just use a bitmap and a temporary outer loop to
implement this.

Performance numbers from a single microbenchmark at this point in the
series are included in the next patch.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/swap.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index fae766e035a4..a302224293ad 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -731,6 +731,7 @@ void lru_add_drain_all(void)
 	put_online_cpus();
 }
 
+#define LRU_BITMAP_SIZE	512
 /**
  * release_pages - batched put_page()
  * @pages: array of pages to release
@@ -742,16 +743,32 @@ void lru_add_drain_all(void)
  */
 void release_pages(struct page **pages, int nr)
 {
-	int i;
+	int h, i;
 	LIST_HEAD(pages_to_free);
 	struct pglist_data *locked_pgdat = NULL;
 	spinlock_t *locked_lru_batch = NULL;
 	struct lruvec *lruvec;
 	unsigned long uninitialized_var(flags);
+	DECLARE_BITMAP(lru_bitmap, LRU_BITMAP_SIZE);
+
+	VM_BUG_ON(nr > LRU_BITMAP_SIZE);
 
+	bitmap_zero(lru_bitmap, nr);
+
+	for (h = 0; h < 2; h++) {
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
+		if (h == 0) {
+			if (PageLRU(page) && page->lru_sentinel) {
+				bitmap_set(lru_bitmap, i, 1);
+				continue;
+			}
+		} else {
+			if (!test_bit(i, lru_bitmap))
+				continue;
+		}
+
 		if (is_huge_zero_page(page))
 			continue;
 
@@ -798,6 +815,7 @@ void release_pages(struct page **pages, int nr)
 
 		list_add(&page->lru, &pages_to_free);
 	}
+	}
 	if (locked_lru_batch) {
 		lru_batch_unlock(NULL, &locked_lru_batch, &locked_pgdat,
 				 &flags);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
