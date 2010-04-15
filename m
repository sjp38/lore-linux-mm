Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 90B1A6B01F6
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 06:24:58 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3FAOwA0003094
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 19:24:59 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A390245DE4F
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:24:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 78E8E45DE4E
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:24:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EA541DB8038
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:24:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D8B941DB8061
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:24:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/4] mm: introduce free_pages_bulk
In-Reply-To: <20100415185310.D1A1.A69D9226@jp.fujitsu.com>
References: <20100415085420.GT2493@dastard> <20100415185310.D1A1.A69D9226@jp.fujitsu.com>
Message-Id: <20100415192412.D1AA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 19:24:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Now, vmscan is using __pagevec_free() for batch freeing. but
pagevec consume slightly lots stack (sizeof(long)*8), and x86_64
stack is very strictly limited.

Then, now we are planning to use page->lru list instead pagevec
for reducing stack. and introduce new helper function.

This is similar to __pagevec_free(), but receive list instead
pagevec. and this don't use pcp cache. it is good characteristics
for vmscan.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/gfp.h |    1 +
 mm/page_alloc.c     |   44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4c6d413..dbcac56 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -332,6 +332,7 @@ extern void free_hot_cold_page(struct page *page, int cold);
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr),0)
 
+void free_pages_bulk(struct zone *zone, struct list_head *list);
 void page_alloc_init(void);
 void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
 void drain_all_pages(void);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ba9aea7..1f68832 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2049,6 +2049,50 @@ void free_pages(unsigned long addr, unsigned int order)
 
 EXPORT_SYMBOL(free_pages);
 
+/*
+ * Frees a number of pages from the list
+ * Assumes all pages on list are in same zone and order==0.
+ *
+ * This is similar to __pagevec_free(), but receive list instead pagevec.
+ * and this don't use pcp cache. it is good characteristics for vmscan.
+ */
+void free_pages_bulk(struct zone *zone, struct list_head *list)
+{
+	unsigned long flags;
+	struct page *page;
+	struct page *page2;
+	int nr_pages = 0;
+
+	list_for_each_entry_safe(page, page2, list, lru) {
+		int wasMlocked = __TestClearPageMlocked(page);
+
+		if (free_pages_prepare(page, 0)) {
+			/* Make orphan the corrupted page. */
+			list_del(&page->lru);
+			continue;
+		}
+		if (unlikely(wasMlocked)) {
+			local_irq_save(flags);
+			free_page_mlock(page);
+			local_irq_restore(flags);
+		}
+		nr_pages++;
+	}
+
+	spin_lock_irqsave(&zone->lock, flags);
+	__count_vm_events(PGFREE, nr_pages);
+	zone->all_unreclaimable = 0;
+	zone->pages_scanned = 0;
+	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
+
+	list_for_each_entry_safe(page, page2, list, lru) {
+		/* have to delete it as __free_one_page list manipulates */
+		list_del(&page->lru);
+		__free_one_page(page, zone, 0, page_private(page));
+	}
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
 /**
  * alloc_pages_exact - allocate an exact number physically-contiguous pages.
  * @size: the number of bytes to allocate
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
