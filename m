Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id C81496B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 07:11:53 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id k14so551314iea.5
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 04:11:53 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 23 Aug 2013 19:11:53 +0800
Message-ID: <CAL1ERfOdg4QNA3g2-yu7j1xM69tr=tC3K+TNRF86d=t+A7Jfgw@mail.gmail.com>
Subject: [PATCH 3/4] zswap bugfix: memory leaks when invalidate and reclaim
 occur simultaneously
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, sjenning@linux.vnet.ibm.com
Cc: weijie.yang@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Consider the following scenario:
thread 1: zswap reclaim entry x (get the refcount, but not call
zswap_get_swap_cache_page yet)
thread 0: zswap_frontswap_invalidate_page entry x (finished, entry x
and its zbud is not freed as its refcount != 0)
now, the swap_map[x] = 0
thread 1: zswap_get_swap_cache_page called, swapcache_prepare return
-ENOENT because entry x is not used any more
zswap_get_swap_cache_page return ZSWAP_SWAPCACHE_NOMEM
zswap_writeback_entry do nothing except put refcount
now, the memory of zswap_entry x and its zpage leak

---
 mm/zswap.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 5f97f4f..9d34c3c 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -387,7 +387,7 @@ static void zswap_free_entry(struct zswap_tree
*tree, struct zswap_entry *entry)
 enum zswap_get_swap_ret {
 	ZSWAP_SWAPCACHE_NEW,
 	ZSWAP_SWAPCACHE_EXIST,
-	ZSWAP_SWAPCACHE_NOMEM
+	ZSWAP_SWAPCACHE_FAIL
 };

 /*
@@ -401,9 +401,9 @@ enum zswap_get_swap_ret {
  * added to the swap cache, and returned in retpage.
  *
  * If success, the swap cache page is returned in retpage
- * Returns 0 if page was already in the swap cache, page is not locked
- * Returns 1 if the new page needs to be populated, page is locked
- * Returns <0 on error
+ * Returns ZSWAP_SWAPCACHE_EXIST if page was already in the swap cache
+ * Returns ZSWAP_SWAPCACHE_NEW if the new page needs to be populated,
page is locked
+ * Returns ZSWAP_SWAPCACHE_FAIL on error
  */
 static int zswap_get_swap_cache_page(swp_entry_t entry,
 				struct page **retpage)
@@ -475,7 +475,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 	if (new_page)
 		page_cache_release(new_page);
 	if (!found_page)
-		return ZSWAP_SWAPCACHE_NOMEM;
+		return ZSWAP_SWAPCACHE_FAIL;
 	*retpage = found_page;
 	return ZSWAP_SWAPCACHE_EXIST;
 }
@@ -529,11 +529,11 @@ static int zswap_writeback_entry(struct
zbud_pool *pool, unsigned long handle)

 	/* try to allocate swap cache page */
 	switch (zswap_get_swap_cache_page(swpentry, &page)) {
-	case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
+	case ZSWAP_SWAPCACHE_FAIL: /* no memory or invalidate happened */
 		ret = -ENOMEM;
 		goto fail;

-	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
+	case ZSWAP_SWAPCACHE_EXIST:
 		/* page is already in the swap cache, ignore for now */
 		page_cache_release(page);
 		ret = -EEXIST;
@@ -591,7 +591,12 @@ static int zswap_writeback_entry(struct zbud_pool
*pool, unsigned long handle)

 fail:
 	spin_lock(&tree->lock);
-	zswap_entry_put(entry);
+	refcount = zswap_entry_put(entry);
+	if (refcount <= 0) {
+		/* invalidate happened,  consider writeback as success */
+		zswap_free_entry(tree, entry);
+		ret = 0;
+	}
 	spin_unlock(&tree->lock);
 	return ret;
 }
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
