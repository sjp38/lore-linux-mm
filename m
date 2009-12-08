Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 32914600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:31 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [11/31] HWPOISON: introduce delete_from_lru_cache()
Message-Id: <20091208211627.60B2CB151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:27 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

Introduce delete_from_lru_cache() to
- clear PG_active, PG_unevictable to avoid complains at unpoison time
- move the isolate_lru_page() call back to the handlers instead of the
  entrance of __memory_failure(), this is more hwpoison filter friendly

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory-failure.c |   45 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 37 insertions(+), 8 deletions(-)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -350,6 +350,30 @@ static const char *action_name[] = {
 };
 
 /*
+ * XXX: It is possible that a page is isolated from LRU cache,
+ * and then kept in swap cache or failed to remove from page cache.
+ * The page count will stop it from being freed by unpoison.
+ * Stress tests should be aware of this memory leak problem.
+ */
+static int delete_from_lru_cache(struct page *p)
+{
+	if (!isolate_lru_page(p)) {
+		/*
+		 * Clear sensible page flags, so that the buddy system won't
+		 * complain when the page is unpoison-and-freed.
+		 */
+		ClearPageActive(p);
+		ClearPageUnevictable(p);
+		/*
+		 * drop the page count elevated by isolate_lru_page()
+		 */
+		page_cache_release(p);
+		return 0;
+	}
+	return -EIO;
+}
+
+/*
  * Error hit kernel page.
  * Do nothing, try to be lucky and not touch this instead. For a few cases we
  * could be more sophisticated.
@@ -393,6 +417,8 @@ static int me_pagecache_clean(struct pag
 	int ret = FAILED;
 	struct address_space *mapping;
 
+	delete_from_lru_cache(p);
+
 	/*
 	 * For anonymous pages we're done the only reference left
 	 * should be the one m_f() holds.
@@ -522,14 +548,20 @@ static int me_swapcache_dirty(struct pag
 	/* Trigger EIO in shmem: */
 	ClearPageUptodate(p);
 
-	return DELAYED;
+	if (!delete_from_lru_cache(p))
+		return DELAYED;
+	else
+		return FAILED;
 }
 
 static int me_swapcache_clean(struct page *p, unsigned long pfn)
 {
 	delete_from_swap_cache(p);
 
-	return RECOVERED;
+	if (!delete_from_lru_cache(p))
+		return RECOVERED;
+	else
+		return FAILED;
 }
 
 /*
@@ -748,7 +780,6 @@ static int hwpoison_user_mappings(struct
 
 int __memory_failure(unsigned long pfn, int trapno, int flags)
 {
-	unsigned long lru_flag;
 	struct page_state *ps;
 	struct page *p;
 	int res;
@@ -798,13 +829,11 @@ int __memory_failure(unsigned long pfn,
 	 */
 	if (!PageLRU(p))
 		lru_add_drain_all();
-	lru_flag = p->flags & lru;
-	if (isolate_lru_page(p)) {
+	if (!PageLRU(p)) {
 		action_result(pfn, "non LRU", IGNORED);
 		put_page(p);
 		return -EBUSY;
 	}
-	page_cache_release(p);
 
 	/*
 	 * Lock the page and wait for writeback to finish.
@@ -827,7 +856,7 @@ int __memory_failure(unsigned long pfn,
 	/*
 	 * Torn down by someone else?
 	 */
-	if ((lru_flag & lru) && !PageSwapCache(p) && p->mapping == NULL) {
+	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
 		action_result(pfn, "already truncated LRU", IGNORED);
 		res = 0;
 		goto out;
@@ -835,7 +864,7 @@ int __memory_failure(unsigned long pfn,
 
 	res = -EBUSY;
 	for (ps = error_states;; ps++) {
-		if (((p->flags | lru_flag)& ps->mask) == ps->res) {
+		if ((p->flags & ps->mask) == ps->res) {
 			res = page_action(ps, p, pfn);
 			break;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
