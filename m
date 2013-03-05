Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 3EC626B0007
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 01:58:31 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MJ6001FEE1HS6O0@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Mar 2013 15:58:29 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [RFC/PATCH 1/5] mm: introduce migrate_replace_page() for migrating
 page to the given target
Date: Tue, 05 Mar 2013 07:57:55 +0100
Message-id: <1362466679-17111-2-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Introduce migrate_replace_page() function for migrating single page to the
given target page.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/migrate.h |    5 ++++
 mm/migrate.c            |   59 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a405d3dc..3a8a6c1 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -35,6 +35,8 @@ enum migrate_reason {
 
 #ifdef CONFIG_MIGRATION
 
+extern int migrate_replace_page(struct page *oldpage, struct page *newpage);
+
 extern void putback_lru_pages(struct list_head *l);
 extern void putback_movable_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
@@ -57,6 +59,9 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
 #else
 
+static inline int migrate_replace_page(struct page *oldpage,
+		struct page *newpage) { return -ENOSYS; }
+
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
diff --git a/mm/migrate.c b/mm/migrate.c
index 3bbaf5d..a2a6950 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1067,6 +1067,65 @@ out:
 	return rc;
 }
 
+/*
+ * migrate_replace_page
+ *
+ * The function takes one single page and a target page (newpage) and
+ * tries to migrate data to the target page. The caller must ensure that
+ * the source page is locked with one additional get_page() call, which
+ * will be freed during the migration. The caller also must release newpage
+ * if migration fails, otherwise the ownership of the newpage is taken.
+ * Source page is released if migration succeeds.
+ *
+ * Return: error code or 0 on success.
+ */
+int migrate_replace_page(struct page *page, struct page *newpage)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long flags;
+	int ret = -EAGAIN;
+	int pass;
+
+	migrate_prep();
+
+	spin_lock_irqsave(&zone->lru_lock, flags);
+
+	if (PageLRU(page) &&
+	    __isolate_lru_page(page, ISOLATE_UNEVICTABLE) == 0) {
+		struct lruvec *lruvec = mem_cgroup_page_lruvec(page, zone);
+		del_page_from_lru_list(page, lruvec, page_lru(page));
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	} else {
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		return -EAGAIN;
+	}
+
+	/* page is now isolated, so release additional reference */
+	put_page(page);
+
+	for (pass = 0; pass < 10 && ret != 0; pass++) {
+		cond_resched();
+
+		if (page_count(page) == 1) {
+			/* page was freed from under us, so we are done */
+			ret = 0;
+			break;
+		}
+		ret = __unmap_and_move(page, newpage, 1, MIGRATE_SYNC);
+	}
+
+	if (ret == 0) {
+		/* take ownership of newpage and add it to lru */
+		putback_lru_page(newpage);
+	} else {
+		/* restore additional reference to the oldpage */
+		get_page(page);
+	}
+
+	putback_lru_page(page);
+	return ret;
+}
+
 #ifdef CONFIG_NUMA
 /*
  * Move a list of individual pages
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
