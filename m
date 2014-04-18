Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A81176B003A
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:39:40 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so1569866pab.18
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 08:39:40 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id qf5si16532505pac.457.2014.04.18.08.39.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 08:39:39 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so1574383pad.17
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 08:39:39 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: Re: [PATCH] mm/swap: cleanup *lru_cache_add* functions
Date: Fri, 18 Apr 2014 23:39:25 +0800
Message-Id: <1397835565-6411-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, hannes@cmpxchg.org, shli@kernel.org, bob.liu@oracle.com, sjenning@linux.vnet.ibm.com, nasa4836@gmail.com, iamjoonsoo.kim@lge.com, aquini@redhat.com, mgorman@suse.de, riel@redhat.com, aarcange@redhat.com, khalid.aziz@oracle.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi, Christoph Hellwig,

>There are no modular users of lru_cache_add, so please don't needlessly
>export it.

yep, I re-checked and found there is no module user of neither 
lru_cache_add() nor lru_cache_add_anon(), so don't export it.

Here is the renewed patch:
---

In mm/swap.c, __lru_cache_add() is exported, but actually there are
no users outside this file. However, lru_cache_add() is supposed to
be used by vfs, or whatever others, but it is not exported.

This patch unexports __lru_cache_add(), and makes it static.
It also exports lru_cache_add_file(), as it is use by cifs, which
be loaded as module.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 include/linux/swap.h | 19 ++-----------------
 mm/swap.c            | 31 +++++++++++++++++++++++--------
 2 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3507115..5a14b92 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -308,8 +308,9 @@ extern unsigned long nr_free_pagecache_pages(void);
 
 
 /* linux/mm/swap.c */
-extern void __lru_cache_add(struct page *);
 extern void lru_cache_add(struct page *);
+extern void lru_cache_add_anon(struct page *page);
+extern void lru_cache_add_file(struct page *page);
 extern void lru_add_page_tail(struct page *page, struct page *page_tail,
 			 struct lruvec *lruvec, struct list_head *head);
 extern void activate_page(struct page *);
@@ -323,22 +324,6 @@ extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
 
-/**
- * lru_cache_add: add a page to the page lists
- * @page: the page to add
- */
-static inline void lru_cache_add_anon(struct page *page)
-{
-	ClearPageActive(page);
-	__lru_cache_add(page);
-}
-
-static inline void lru_cache_add_file(struct page *page)
-{
-	ClearPageActive(page);
-	__lru_cache_add(page);
-}
-
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
diff --git a/mm/swap.c b/mm/swap.c
index ab3f508..c0cd7d0 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -582,13 +582,7 @@ void mark_page_accessed(struct page *page)
 }
 EXPORT_SYMBOL(mark_page_accessed);
 
-/*
- * Queue the page for addition to the LRU via pagevec. The decision on whether
- * to add the page to the [in]active [file|anon] list is deferred until the
- * pagevec is drained. This gives a chance for the caller of __lru_cache_add()
- * have the page added to the active list using mark_page_accessed().
- */
-void __lru_cache_add(struct page *page)
+static void __lru_cache_add(struct page *page)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
 
@@ -598,11 +592,32 @@ void __lru_cache_add(struct page *page)
 	pagevec_add(pvec, page);
 	put_cpu_var(lru_add_pvec);
 }
-EXPORT_SYMBOL(__lru_cache_add);
+
+/**
+ * lru_cache_add: add a page to the page lists
+ * @page: the page to add
+ */
+void lru_cache_add_anon(struct page *page)
+{
+	ClearPageActive(page);
+	__lru_cache_add(page);
+}
+
+void lru_cache_add_file(struct page *page)
+{
+	ClearPageActive(page);
+	__lru_cache_add(page);
+}
+EXPORT_SYMBOL(lru_cache_add_file);
 
 /**
  * lru_cache_add - add a page to a page list
  * @page: the page to be added to the LRU.
+ *
+ * Queue the page for addition to the LRU via pagevec. The decision on whether
+ * to add the page to the [in]active [file|anon] list is deferred until the
+ * pagevec is drained. This gives a chance for the caller of lru_cache_add()
+ * have the page added to the active list using mark_page_accessed().
  */
 void lru_cache_add(struct page *page)
 {
-- 
1.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
