Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8FF8E0002
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 02:40:22 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 2-v6so542458plc.11
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 23:40:22 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id i21-v6si17741515pgg.513.2018.09.17.23.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Sep 2018 23:40:20 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH 15/19] mm/balloon_compaction: list interfaces
Date: Mon, 17 Sep 2018 23:38:49 -0700
Message-ID: <20180918063853.198332-16-namit@vmware.com>
In-Reply-To: <20180918063853.198332-1-namit@vmware.com>
References: <20180918063853.198332-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Nadav Amit <namit@vmware.com>, "Michael S.
 Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

Introduce interfaces for ballooning enqueueing and dequeueing of a list
of pages. These interfaces reduce the overhead of storing and restoring
IRQs by batching the operations. In addition they do not panic if the
list of pages is empty.

Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: linux-mm@kvack.org
Cc: virtualization@lists.linux-foundation.org
Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 include/linux/balloon_compaction.h |   4 +
 mm/balloon_compaction.c            | 139 +++++++++++++++++++++--------
 2 files changed, 105 insertions(+), 38 deletions(-)

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 53051f3d8f25..2c5a8e09e413 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -72,6 +72,10 @@ extern struct page *balloon_page_alloc(void);
 extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
 				 struct page *page);
 extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
+extern void balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
+				      struct list_head *pages);
+extern int balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
+				     struct list_head *pages, int n_req_pages);
 
 static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
 {
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index a6c0efb3544f..b920c2a10d6f 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -10,6 +10,100 @@
 #include <linux/export.h>
 #include <linux/balloon_compaction.h>
 
+static int balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
+				     struct page *page)
+{
+	/*
+	 * Block others from accessing the 'page' when we get around to
+	 * establishing additional references. We should be the only one
+	 * holding a reference to the 'page' at this point.
+	 */
+	if (!trylock_page(page)) {
+		WARN_ONCE(1, "balloon inflation failed to enqueue page\n");
+		return -EFAULT;
+	}
+	list_del(&page->lru);
+	balloon_page_insert(b_dev_info, page);
+	unlock_page(page);
+	__count_vm_event(BALLOON_INFLATE);
+	return 0;
+}
+
+/**
+ * balloon_page_list_enqueue() - inserts a list of pages into the balloon page
+ *				 list.
+ * @b_dev_info: balloon device descriptor where we will insert a new page to
+ * @pages: pages to enqueue - allocated using balloon_page_alloc.
+ *
+ * Driver must call it to properly enqueue a balloon pages before definitively
+ * removing it from the guest system.
+ */
+void balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
+			       struct list_head *pages)
+{
+	struct page *page, *tmp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	list_for_each_entry_safe(page, tmp, pages, lru)
+		balloon_page_enqueue_one(b_dev_info, page);
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+}
+EXPORT_SYMBOL_GPL(balloon_page_list_enqueue);
+
+/**
+ * balloon_page_list_dequeue() - removes pages from balloon's page list and
+ *				 returns a list of the pages.
+ * @b_dev_info: balloon device decriptor where we will grab a page from.
+ * @pages: pointer to the list of pages that would be returned to the caller.
+ * @n_req_pages: number of requested pages.
+ *
+ * Driver must call it to properly de-allocate a previous enlisted balloon pages
+ * before definetively releasing it back to the guest system. This function
+ * tries to remove @n_req_pages from the ballooned pages and return it to the
+ * caller in the @pages list.
+ *
+ * Note that this function may fail to dequeue some pages temporarily empty due
+ * to compaction isolated pages.
+ *
+ * Return: number of pages that were added to the @pages list.
+ */
+int balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
+			       struct list_head *pages, int n_req_pages)
+{
+	struct page *page, *tmp;
+	unsigned long flags;
+	int n_pages = 0;
+
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
+		/*
+		 * Block others from accessing the 'page' while we get around
+		 * establishing additional references and preparing the 'page'
+		 * to be released by the balloon driver.
+		 */
+		if (!trylock_page(page))
+			continue;
+
+		if (IS_ENABLED(CONFIG_BALLOON_COMPACTION) &&
+		    PageIsolated(page)) {
+			/* raced with isolation */
+			unlock_page(page);
+			continue;
+		}
+		balloon_page_delete(page);
+		__count_vm_event(BALLOON_DEFLATE);
+		unlock_page(page);
+		list_add(&page->lru, pages);
+		if (++n_pages >= n_req_pages)
+			break;
+	}
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+
+	return n_pages;
+}
+EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
+
 /*
  * balloon_page_alloc - allocates a new page for insertion into the balloon
  *			  page list.
@@ -44,17 +138,9 @@ void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
 {
 	unsigned long flags;
 
-	/*
-	 * Block others from accessing the 'page' when we get around to
-	 * establishing additional references. We should be the only one
-	 * holding a reference to the 'page' at this point.
-	 */
-	BUG_ON(!trylock_page(page));
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
-	balloon_page_insert(b_dev_info, page);
-	__count_vm_event(BALLOON_INFLATE);
+	balloon_page_enqueue_one(b_dev_info, page);
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
-	unlock_page(page);
 }
 EXPORT_SYMBOL_GPL(balloon_page_enqueue);
 
@@ -71,36 +157,13 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
  */
 struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 {
-	struct page *page, *tmp;
 	unsigned long flags;
-	bool dequeued_page;
+	LIST_HEAD(pages);
+	int n_pages;
 
-	dequeued_page = false;
-	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
-	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
-		/*
-		 * Block others from accessing the 'page' while we get around
-		 * establishing additional references and preparing the 'page'
-		 * to be released by the balloon driver.
-		 */
-		if (trylock_page(page)) {
-#ifdef CONFIG_BALLOON_COMPACTION
-			if (PageIsolated(page)) {
-				/* raced with isolation */
-				unlock_page(page);
-				continue;
-			}
-#endif
-			balloon_page_delete(page);
-			__count_vm_event(BALLOON_DEFLATE);
-			unlock_page(page);
-			dequeued_page = true;
-			break;
-		}
-	}
-	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+	n_pages = balloon_page_list_dequeue(b_dev_info, &pages, 1);
 
-	if (!dequeued_page) {
+	if (n_pages != 1) {
 		/*
 		 * If we are unable to dequeue a balloon page because the page
 		 * list is empty and there is no isolated pages, then something
@@ -113,9 +176,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 			     !b_dev_info->isolated_pages))
 			BUG();
 		spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
-		page = NULL;
+		return NULL;
 	}
-	return page;
+	return list_first_entry(&pages, struct page, lru);
 }
 EXPORT_SYMBOL_GPL(balloon_page_dequeue);
 
-- 
2.17.1
