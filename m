Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 651FC6B0062
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 13:01:24 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH] staging: ramster: fix build warnings
Date: Thu,  6 Sep 2012 10:01:14 -0700
Message-Id: <1346950874-32502-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-janitors@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, konrad.wilk@oracle.com, dan.carpenter@oracle.com, dan.magenheimer@oracle.com

Fix build warnings resulting from in-progress work that was
not entirely ifdef'd out.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 24b3d4a..eb0639f 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -449,16 +449,18 @@ static struct page *zcache_alloc_page(void)
 	return page;
 }
 
+#ifdef FRONTSWAP_HAS_UNUSE
 static void zcache_unacct_page(void)
 {
 	zcache_pageframes_freed =
 		atomic_inc_return(&zcache_pageframes_freed_atomic);
 }
+#endif
 
 static void zcache_free_page(struct page *page)
 {
 	long curr_pageframes;
-	static long max_pageframes, min_pageframes, total_freed;
+	static long max_pageframes, min_pageframes;
 
 	if (page == NULL)
 		BUG();
@@ -965,9 +967,10 @@ out:
 	return page;
 }
 
+#ifdef FRONTSWAP_HAS_UNUSE
 static void unswiz(struct tmem_oid oid, u32 index,
 				unsigned *type, pgoff_t *offset);
-#ifdef FRONTSWAP_HAS_UNUSE
+
 /*
  *  Choose an LRU persistent pageframe and attempt to "unuse" it by
  *  calling frontswap_unuse on both zpages.
@@ -1060,7 +1063,9 @@ static int shrink_zcache_memory(struct shrinker *shrink,
 	int nr_evict = 0;
 	int nr_unuse = 0;
 	struct page *page;
+#ifdef FRONTSWAP_HAS_UNUSE
 	int unuse_ret;
+#endif
 
 	if (nr <= 0)
 		goto skip_evict;
@@ -1517,6 +1522,7 @@ static inline struct tmem_oid oswiz(unsigned type, u32 ind)
 	return oid;
 }
 
+#ifdef FRONTSWAP_HAS_UNUSE
 static void unswiz(struct tmem_oid oid, u32 index,
 				unsigned *type, pgoff_t *offset)
 {
@@ -1524,6 +1530,7 @@ static void unswiz(struct tmem_oid oid, u32 index,
 	*offset = (pgoff_t)((index << SWIZ_BITS) |
 			(oid.oid[0] & SWIZ_MASK));
 }
+#endif
 
 static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
 					struct page *page)
@@ -1533,7 +1540,6 @@ static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
 	struct tmem_oid oid = oswiz(type, ind);
 	int ret = -1;
 	unsigned long flags;
-	int unuse_ret;
 
 	BUG_ON(!PageLocked(page));
 	if (!disable_frontswap_ignore_nonactive && !PageWasActive(page)) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
