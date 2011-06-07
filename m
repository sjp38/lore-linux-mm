Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F3E636B00E7
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:39:26 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id 4so3156114pzk.14
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 07:39:25 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 08/10] migration: make in-order-putback aware
Date: Tue,  7 Jun 2011 23:38:21 +0900
Message-Id: <2eeaeeb6f2b9354212b37e28144f46a47209b5c5.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

This patch introduces new API makes migrate_ilru_pages which is aware of in-order putback.
So newpage is located at old page's LRU position.

[migrate_pages vs migrate_ilru_pages]

1) we need handle singly linked list.
The page->lru isn't doubly linked list any more when we handle migration list.
So migrate_ilru_pages have to handle singly linked list instead of doubly lined list.

2) We need defer old page's putback.
At present, during migration, old page would be freed through unmap_and_move's
putback_lru_page. It has a problem in inorder-putback's logic.
The same_lru in migrate_ilru_pages checks old pages's PageLRU and something
for determining whether the page can be located at old page's position or not.
If old page is freed before handling inorder-lru list, it ends up having !PageLRU
and same_lru returns 'false' so that inorder putback would become no-op.

3) we need adjust prev_page of inorder_lru page list when we putback newpage and free old page.
For example,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4 - P3 - P2 - P1 - T
inorder_lru : 0

We isolate P2,P3,P4 so inorder_lru has following list

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P1 - T
inorder_lru : (P4,P5) - (P3,P4) - (P2,P3)

After 1st putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P1 - T
inorder_lru : (P3,P4) - (P2,P3)
P4' is newpage and P4(ie, old page) would freed

In 2nd putback, P3 would find P4 in same_lru but P4 is in buddy
so it returns 'false' then inorder_lru doesn't work any more.
The bad effect continues until P2. That's too bad.
For fixing, this patch defines adjust_ilru_prev_page.
It works following as.

After 1st putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P1 - T
inorder_lru : (P3,P4') - (P2,P3)

It replaces old page's pointer with new one's so

In 2nd putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P3' - P1 -  T
inorder_lru : (P2,P3')

In 3rd putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P3' - P2' - P1 - T
inorder_lru : 0

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/migrate.h |    5 ++
 mm/migrate.c            |  152 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 157 insertions(+), 0 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 5914282..3858618 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -50,6 +50,11 @@ extern int migrate_page(struct address_space *,
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			bool sync);
+
+extern int migrate_ilru_pages(struct inorder_lru *l, new_page_t x,
+			unsigned long private, bool offlining,
+			bool sync);
+
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			bool sync);
diff --git a/mm/migrate.c b/mm/migrate.c
index 3aec310..a57f60b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -855,6 +855,108 @@ out:
         return rc;
 }
 
+static inline void adjust_ilru_prev_page(struct inorder_lru *head,
+		struct page *prev_page, struct page *new_page)
+{
+	struct page *page;
+	list_for_each_migrate_entry(page, head, ilru)
+		if (page->ilru.prev_page == prev_page)
+			page->ilru.prev_page = new_page;
+}
+
+void __put_ilru_pages(struct page *page, struct page *newpage,
+		struct inorder_lru **prev_lru, struct inorder_lru *head)
+{
+	struct zone *zone;
+	bool del = false;
+	struct page *prev_page = page->ilru.prev_page;
+	if (page != NULL) {
+		/*
+		 * A page that has been migrated has all references
+		 * removed and will be freed. A page that has not been
+		 * migrated will have kepts its references and be
+		 * restored.
+		 */
+		migratelist_del(page, *prev_lru);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				page_is_file_cache(page));
+		/*
+		 * Unlike unmap_and_move, we defer putback_lru_page
+		 * after inorder-lru list handling. If we call it,
+		 * the page would be freed then and it doesn't have PG_lru.
+		 * So same_lru doesn't work correctly.
+		 */
+		del = true;
+	}
+	else
+		*prev_lru = &page->ilru;
+	/*
+	 * Move the new page to the LRU. If migration was not successful
+	 * then this will free the page.
+	 */
+	zone = page_zone(newpage);
+	spin_lock_irq(&zone->lru_lock);
+	if (page && same_lru(page, prev_page)) {
+		putback_page_to_lru(newpage, prev_page);
+		spin_unlock_irq(&zone->lru_lock);
+		/*
+		 * The newpage will replace LRU position of old page and
+		 * old one would be freed. So let's adjust prev_page of pages
+		 * remained in migratelist for same_lru wokring.
+		 */
+		adjust_ilru_prev_page(head, page, newpage);
+		put_page(newpage); /* drop ref from isolate */
+	}
+	else {
+		spin_unlock_irq(&zone->lru_lock);
+		putback_lru_page(newpage);
+	}
+
+	if (del)
+		putback_lru_page(page);
+}
+
+/*
+ * Counterpart of unmap_and_move() for compaction.
+ * The logic is almost same with unmap_and_move. The difference is
+ * this function handles prev_lru. For inorder-lru compaction, we use
+ * singly linked list so we need prev pointer handling to delete entry.
+ */
+static int unmap_and_move_ilru(new_page_t get_new_page, unsigned long private,
+		struct page *page, int force, bool offlining, bool sync,
+		struct inorder_lru **prev_lru, struct inorder_lru *head)
+{
+	int rc = 0;
+	int *result = NULL;
+	struct page *newpage = get_new_page(page, private, &result);
+
+	if (!newpage)
+		return -ENOMEM;
+
+	if (page_count(page) == 1) {
+		/* page was freed from under us. So we are done. */
+		goto out;
+	}
+
+	if (unlikely(PageTransHuge(page)))
+		if (unlikely(split_huge_page(page)))
+			goto out;
+
+	rc = __unmap_and_move(page, newpage, force, offlining, sync);
+	if (rc == -EAGAIN)
+		page = NULL;
+out:
+	__put_ilru_pages(page, newpage, prev_lru, head);
+	if (result) {
+		if (rc)
+			*result = rc;
+		else
+			*result = page_to_nid(newpage);
+	}
+	return rc;
+
+}
+
 /*
  * Counterpart of unmap_and_move_page() for hugepage migration.
  *
@@ -996,6 +1098,56 @@ out:
 	return nr_failed + retry;
 }
 
+int migrate_ilru_pages(struct inorder_lru *head, new_page_t get_new_page,
+		unsigned long private, bool offlining, bool sync)
+{
+	int retry = 1;
+	int nr_failed = 0;
+	int pass = 0;
+	struct page *page, *page2;
+	struct inorder_lru *prev;
+	int swapwrite = current->flags & PF_SWAPWRITE;
+	int rc;
+
+	if (!swapwrite)
+		current->flags |= PF_SWAPWRITE;
+
+	for(pass = 0; pass < 10 && retry; pass++) {
+		retry = 0;
+		list_for_each_migrate_entry_safe(page, page2, head, ilru) {
+			cond_resched();
+
+			prev = head;
+			rc = unmap_and_move_ilru(get_new_page, private,
+					page, pass > 2, offlining,
+					sync, &prev, head);
+
+			switch(rc) {
+				case -ENOMEM:
+					goto out;
+				case -EAGAIN:
+					retry++;
+					break;
+				case 0:
+					break;
+				default:
+					/* Permanent failure */
+					nr_failed++;
+					break;
+			}
+		}
+	}
+	rc = 0;
+out:
+	if (!swapwrite)
+		current->flags &= ~PF_SWAPWRITE;
+
+	if (rc)
+		return rc;
+
+	return nr_failed + retry;
+}
+
 int migrate_huge_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
 		bool sync)
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
