Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id D9ADF6B008C
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:44:03 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC/PATCH 1/3] swap: allow adding of pages to tail of anonymous inactive queue
Date: Wed,  3 Oct 2012 15:43:52 -0700
Message-Id: <1349304234-19273-2-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1349304234-19273-1-git-send-email-dan.magenheimer@oracle.com>
References: <1349304234-19273-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, hughd@google.com, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, dan.magenheimer@oracle.com, aarcange@redhat.com, mgorman@suse.de, gregkh@linuxfoundation.org

When moving a page of anonymous data out of zcache and back
into swap cache, such pages are VERY inactive, and we want
them to be swapped to disk ASAP.  So we need to add them
at the tail of the proper queue.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 include/linux/swap.h |   10 ++++++++++
 mm/swap.c            |   16 ++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 388e706..d3c7281 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -225,6 +225,7 @@ extern unsigned int nr_free_pagecache_pages(void);
 
 /* linux/mm/swap.c */
 extern void __lru_cache_add(struct page *, enum lru_list lru);
+extern void __lru_cache_add_tail(struct page *, enum lru_list lru);
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
 extern void lru_add_page_tail(struct page *page, struct page *page_tail,
 			      struct lruvec *lruvec);
@@ -247,6 +248,15 @@ static inline void lru_cache_add_anon(struct page *page)
 {
 	__lru_cache_add(page, LRU_INACTIVE_ANON);
 }
+ 
+/**
+ * lru_cache_add_tail: add a page to the tail of the page lists
+ * @page: the page to add
+ */
+static inline void lru_cache_add_anon_tail(struct page *page)
+{
+	__lru_cache_add_tail(page, LRU_INACTIVE_ANON);
+}
 
 static inline void lru_cache_add_file(struct page *page)
 {
diff --git a/mm/swap.c b/mm/swap.c
index 7782588..67216d8 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -456,6 +456,22 @@ void __lru_cache_add(struct page *page, enum lru_list lru)
 	put_cpu_var(lru_add_pvecs);
 }
 EXPORT_SYMBOL(__lru_cache_add);
+ 
+void __lru_cache_add_tail(struct page *page, enum lru_list lru)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
+	unsigned long flags;
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page)) {
+		__pagevec_lru_add(pvec, lru);
+		local_irq_save(flags);
+		pagevec_move_tail(pvec);
+		local_irq_restore(flags);
+	}
+	put_cpu_var(lru_add_pvecs);
+}
+EXPORT_SYMBOL(__lru_cache_add_tail);
 
 /**
  * lru_cache_add_lru - add a page to a page list
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
