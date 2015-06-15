Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 48E056B0073
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 03:51:18 -0400 (EDT)
Received: by lacny3 with SMTP id ny3so32329361lac.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:17 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id is4si9832814lac.103.2015.06.15.00.51.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 00:51:16 -0700 (PDT)
Received: by labko7 with SMTP id ko7so52304148lab.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 00:51:16 -0700 (PDT)
Subject: [PATCH RFC v0 6/6] mm/migrate: preserve lru order if possible
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 15 Jun 2015 10:51:11 +0300
Message-ID: <20150615075111.18112.88400.stgit@zurg>
In-Reply-To: <20150615073926.18112.59207.stgit@zurg>
References: <20150615073926.18112.59207.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

TODO
* link old and new pages and insert them as a batch later

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 mm/internal.h |    1 +
 mm/migrate.c  |    7 +++++--
 mm/swap.c     |   25 +++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 19081ba..6184fc2 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -99,6 +99,7 @@ extern unsigned long highest_memmap_pfn;
  */
 extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
+extern void insert_lru_page(struct page *page, struct page *pos);
 extern bool zone_reclaimable(struct zone *zone);
 
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index c060991..e171981 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -947,10 +947,13 @@ out:
 	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
 		ClearPageSwapBacked(newpage);
 		put_new_page(newpage, private);
-	} else if (unlikely(__is_movable_balloon_page(newpage))) {
+	} else if (rc != MIGRATEPAGE_SUCCESS ||
+		   unlikely(__is_movable_balloon_page(newpage))) {
 		/* drop our reference, page already in the balloon */
 		put_page(newpage);
-	} else
+	} else if (PageLRU(page))
+		insert_lru_page(newpage, page);
+	else
 		putback_lru_page(newpage);
 
 	if (result) {
diff --git a/mm/swap.c b/mm/swap.c
index 3ec0eb5..40559d6 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -518,6 +518,31 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 	}
 }
 
+void insert_lru_page(struct page *page, struct page *pos)
+{
+	struct zone *zone = page_zone(page);
+	int lru = page_lru_base_type(page);
+	struct lruvec *lruvec;
+	unsigned long flags;
+
+	if (page_evictable(page) && lru == page_lru(pos) &&
+#ifdef CONFIG_MEMCG
+	    page->mem_cgroup == pos->mem_cgroup &&
+#endif
+	    zone == page_zone(pos)) {
+		spin_lock_irqsave(&zone->lru_lock, flags);
+		lruvec = mem_cgroup_page_lruvec(page, zone);
+		SetPageLRU(page);
+		add_page_to_lru_list(page, lruvec, lru);
+		trace_mm_lru_insertion(page, lru);
+		if (PageLRU(pos) &&
+		    lruvec == mem_cgroup_page_lruvec(pos, zone))
+			list_move(&page->lru, &pos->lru);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	} else
+		putback_lru_page(page);
+}
+
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
