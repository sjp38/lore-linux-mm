From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 13/24] HWPOISON: introduce struct hwpoison_control
Date: Wed, 02 Dec 2009 11:12:44 +0800
Message-ID: <20091202043045.258152715@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D641D6007BC
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-control.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

This allows passing around more parameters and states.
No behavior change.

CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |  108 +++++++++++++++++++++++++-----------------
 1 file changed, 65 insertions(+), 43 deletions(-)

--- linux-mm.orig/mm/memory-failure.c	2009-11-30 20:33:58.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-11-30 20:35:49.000000000 +0800
@@ -313,20 +313,27 @@ static void collect_procs(struct page *p
  * Error handlers for various types of pages.
  */
 
-enum outcome {
+enum hwpoison_result {
 	FAILED,		/* Error handling failed */
 	DELAYED,	/* Will be handled later */
 	IGNORED,	/* Error safely ignored */
 	RECOVERED,	/* Successfully recovered */
 };
 
-static const char *action_name[] = {
+static const char *hwpoison_result_name[] = {
 	[FAILED] = "Failed",
 	[DELAYED] = "Delayed",
 	[IGNORED] = "Ignored",
 	[RECOVERED] = "Recovered",
 };
 
+struct hwpoison_control {
+	unsigned long pfn;
+	struct page *p;		/* raw corrupted page */
+	struct page *page;	/* compound page head */
+	int result;
+};
+
 /*
  * XXX: It is possible that a page is isolated from LRU cache,
  * and then kept in swap cache or failed to remove from page cache.
@@ -356,7 +363,7 @@ static int delete_from_lru_cache(struct 
  * Do nothing, try to be lucky and not touch this instead. For a few cases we
  * could be more sophisticated.
  */
-static int me_kernel(struct page *p, unsigned long pfn)
+static int me_kernel(struct hwpoison_control *hpc)
 {
 	return DELAYED;
 }
@@ -364,28 +371,30 @@ static int me_kernel(struct page *p, uns
 /*
  * Already poisoned page.
  */
-static int me_ignore(struct page *p, unsigned long pfn)
+static int me_ignore(struct hwpoison_control *hpc)
 {
+	printk(KERN_ERR "MCE %#lx: Unknown page state\n", hpc->pfn);
 	return IGNORED;
 }
 
 /*
  * Page in unknown state. Do nothing.
  */
-static int me_unknown(struct page *p, unsigned long pfn)
+static int me_unknown(struct hwpoison_control *hpc)
 {
-	printk(KERN_ERR "MCE %#lx: Unknown page state\n", pfn);
+	printk(KERN_ERR "MCE %#lx: Unknown page state\n", hpc->pfn);
 	return FAILED;
 }
 
 /*
  * Clean (or cleaned) page cache page.
  */
-static int me_pagecache_clean(struct page *p, unsigned long pfn)
+static int me_pagecache_clean(struct hwpoison_control *hpc)
 {
 	int err;
 	int ret = FAILED;
 	struct address_space *mapping;
+	struct page *p = hpc->page;
 
 	delete_from_lru_cache(p);
 
@@ -420,10 +429,11 @@ static int me_pagecache_clean(struct pag
 		err = mapping->a_ops->error_remove_page(mapping, p);
 		if (err != 0) {
 			printk(KERN_INFO "MCE %#lx: Failed to punch page: %d\n",
-					pfn, err);
+					hpc->pfn, err);
 		} else if (page_has_private(p) &&
 				!try_to_release_page(p, GFP_NOIO)) {
-			pr_debug("MCE %#lx: failed to release buffers\n", pfn);
+			pr_debug("MCE %#lx: failed to release buffers\n",
+				 hpc->pfn);
 		} else {
 			ret = RECOVERED;
 		}
@@ -436,7 +446,7 @@ static int me_pagecache_clean(struct pag
 			ret = RECOVERED;
 		else
 			printk(KERN_INFO "MCE %#lx: Failed to invalidate\n",
-				pfn);
+				hpc->pfn);
 	}
 	return ret;
 }
@@ -446,11 +456,11 @@ static int me_pagecache_clean(struct pag
  * Issues: when the error hit a hole page the error is not properly
  * propagated.
  */
-static int me_pagecache_dirty(struct page *p, unsigned long pfn)
+static int me_pagecache_dirty(struct hwpoison_control *hpc)
 {
-	struct address_space *mapping = page_mapping(p);
+	struct address_space *mapping = page_mapping(hpc->page);
 
-	SetPageError(p);
+	SetPageError(hpc->page);
 	/* TBD: print more information about the file. */
 	if (mapping) {
 		/*
@@ -490,7 +500,7 @@ static int me_pagecache_dirty(struct pag
 		mapping_set_error(mapping, EIO);
 	}
 
-	return me_pagecache_clean(p, pfn);
+	return me_pagecache_clean(hpc);
 }
 
 /*
@@ -512,8 +522,9 @@ static int me_pagecache_dirty(struct pag
  * Clean swap cache pages can be directly isolated. A later page fault will
  * bring in the known good data from disk.
  */
-static int me_swapcache_dirty(struct page *p, unsigned long pfn)
+static int me_swapcache_dirty(struct hwpoison_control *hpc)
 {
+	struct page *p = hpc->page;
 	ClearPageDirty(p);
 	/* Trigger EIO in shmem: */
 	ClearPageUptodate(p);
@@ -524,8 +535,10 @@ static int me_swapcache_dirty(struct pag
 		return FAILED;
 }
 
-static int me_swapcache_clean(struct page *p, unsigned long pfn)
+static int me_swapcache_clean(struct hwpoison_control *hpc)
 {
+	struct page *p = hpc->page;
+
 	delete_from_swap_cache(p);
 
 	if (!delete_from_lru_cache(p))
@@ -545,7 +558,7 @@ static int me_swapcache_clean(struct pag
  * Should handle free huge pages and dequeue them too, but this needs to
  * handle huge page accounting correctly.
  */
-static int me_huge_page(struct page *p, unsigned long pfn)
+static int me_huge_page(struct hwpoison_control *hpc)
 {
 	return FAILED;
 }
@@ -581,7 +594,7 @@ static struct page_state {
 	unsigned long mask;
 	unsigned long res;
 	char *msg;
-	int (*action)(struct page *p, unsigned long pfn);
+	int (*action)(struct hwpoison_control *hpc);
 } error_states[] = {
 	{ reserved,	reserved,	"reserved kernel",	me_ignore },
 
@@ -619,30 +632,29 @@ static struct page_state {
 	{ 0,		0,		"unknown page state",	me_unknown },
 };
 
-static void action_result(unsigned long pfn, char *msg, int result)
+static void action_result(struct hwpoison_control *hpc, char *msg, int result)
 {
-	struct page *page = pfn_to_page(pfn);
-
+	hpc->result = result;
 	printk(KERN_ERR "MCE %#lx: %s%s page recovery: %s\n",
-		pfn,
-		PageDirty(page) ? "dirty " : "",
-		msg, action_name[result]);
+		hpc->pfn,
+		PageDirty(hpc->page) ? "dirty " : "",
+		msg, hwpoison_result_name[result]);
 }
 
-static int page_action(struct page_state *ps, struct page *p,
-			unsigned long pfn)
+static int page_action(struct page_state *ps,
+		       struct hwpoison_control *hpc)
 {
 	int result;
 	int count;
 
-	result = ps->action(p, pfn);
-	action_result(pfn, ps->msg, result);
+	result = ps->action(hpc);
+	action_result(hpc, ps->msg, result);
 
-	count = page_count(p) - 1;
+	count = page_count(hpc->page) - 1;
 	if (count != 0)
 		printk(KERN_ERR
 		       "MCE %#lx: %s page still referenced by %d users\n",
-		       pfn, ps->msg, count);
+		       hpc->pfn, ps->msg, count);
 
 	/* Could do more checks here if page looks ok */
 	/*
@@ -658,11 +670,12 @@ static int page_action(struct page_state
  * Do all that is necessary to remove user space mappings. Unmap
  * the pages and send SIGBUS to the processes if the data was dirty.
  */
-static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
-				  int trapno)
+static int hwpoison_user_mappings(struct hwpoison_control *hpc, int trapno)
 {
 	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	struct address_space *mapping;
+	struct page *p = hpc->page;
+	unsigned long pfn = hpc->pfn;
 	LIST_HEAD(tokill);
 	int ret;
 	int i;
@@ -725,7 +738,8 @@ static int hwpoison_user_mappings(struct
 		ret = try_to_unmap(p, ttu);
 		if (ret == SWAP_SUCCESS)
 			break;
-		pr_debug("MCE %#lx: try_to_unmap retry needed %d\n", pfn,  ret);
+		pr_debug("MCE %#lx: try_to_unmap retry needed %d\n",
+			 pfn, ret);
 	}
 
 	if (ret != SWAP_SUCCESS)
@@ -749,8 +763,10 @@ static int hwpoison_user_mappings(struct
 
 int __memory_failure(unsigned long pfn, int trapno, int ref)
 {
+	struct hwpoison_control hpc;
 	struct page_state *ps;
 	struct page *p;
+	struct page *page;
 	int res;
 
 	if (!sysctl_memory_failure_recovery)
@@ -763,9 +779,15 @@ int __memory_failure(unsigned long pfn, 
 		return -ENXIO;
 	}
 
-	p = pfn_to_page(pfn);
+	p		= pfn_to_page(pfn);
+	page		= compound_head(p);
+
+	hpc.pfn		= pfn;
+	hpc.p		= p;
+	hpc.page	= page;
+
 	if (TestSetPageHWPoison(p)) {
-		action_result(pfn, "already hardware poisoned", IGNORED);
+		action_result(&hpc, "already hardware poisoned", IGNORED);
 		return 0;
 	}
 
@@ -782,12 +804,12 @@ int __memory_failure(unsigned long pfn, 
 	 * In fact it's dangerous to directly bump up page count from 0,
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
-	if (!ref && !get_page_unless_zero(compound_head(p))) {
+	if (!ref && !get_page_unless_zero(page)) {
 		if (is_free_buddy_page(p)) {
-			action_result(pfn, "free buddy", DELAYED);
+			action_result(&hpc, "free buddy", DELAYED);
 			return 0;
 		} else {
-			action_result(pfn, "high order kernel", IGNORED);
+			action_result(&hpc, "high order kernel", IGNORED);
 			return -EBUSY;
 		}
 	}
@@ -803,7 +825,7 @@ int __memory_failure(unsigned long pfn, 
 	if (!PageLRU(p))
 		lru_add_drain_all();
 	if (!PageLRU(p)) {
-		action_result(pfn, "non LRU", IGNORED);
+		action_result(&hpc, "non LRU", IGNORED);
 		put_page(p);
 		return -EBUSY;
 	}
@@ -819,7 +841,7 @@ int __memory_failure(unsigned long pfn, 
 	 * unpoison always clear PG_hwpoison inside page lock
 	 */
 	if (!PageHWPoison(p)) {
-		action_result(pfn, "unpoisoned", IGNORED);
+		action_result(&hpc, "unpoisoned", IGNORED);
 		res = 0;
 		goto out;
 	}
@@ -830,7 +852,7 @@ int __memory_failure(unsigned long pfn, 
 	 * Now take care of user space mappings.
 	 * Abort on fail: __remove_from_page_cache() assumes unmapped page.
 	 */
-	if (hwpoison_user_mappings(p, pfn, trapno) != SWAP_SUCCESS) {
+	if (hwpoison_user_mappings(&hpc, trapno) != SWAP_SUCCESS) {
 		res = -EBUSY;
 		goto out;
 	}
@@ -839,7 +861,7 @@ int __memory_failure(unsigned long pfn, 
 	 * Torn down by someone else?
 	 */
 	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
-		action_result(pfn, "already truncated LRU", IGNORED);
+		action_result(&hpc, "already truncated LRU", IGNORED);
 		res = 0;
 		goto out;
 	}
@@ -847,7 +869,7 @@ int __memory_failure(unsigned long pfn, 
 	res = -EBUSY;
 	for (ps = error_states;; ps++) {
 		if ((p->flags & ps->mask) == ps->res) {
-			res = page_action(ps, p, pfn);
+			res = page_action(ps, &hpc);
 			break;
 		}
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
