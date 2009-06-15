From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 20/22] HWPOISON: collect infos that reflect the impact of the memory corruption
Date: Mon, 15 Jun 2009 10:45:40 +0800
Message-ID: <20090615031255.151495090@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5DCD26B0082
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:28 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-safety-bits.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

When a page corrupted, users may care about
- does it hit some important areas?
- can its data be recovered?
- can it be isolated to avoid a deadly future reference?
so that they can take proper actions like emergency sync/shutdown or
schedule reboot at some convenient time.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |   78 +++++++++++++++++++++++++++++++++++-------
 1 file changed, 66 insertions(+), 12 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -312,11 +312,32 @@ static const char *hwpoison_outcome_name
 	[RECOVERED] = "Recovered",
 };
 
+enum hwpoison_page_type {
+	PAGE_IS_KERNEL,
+	PAGE_IS_FS_METADATA,
+	PAGE_IS_FILE_DATA,
+	PAGE_IS_ANON_DATA,
+	PAGE_IS_SWAP_CACHE,
+	PAGE_IS_FREE,
+};
+
+static const char *hwpoison_page_type_name[] = {
+	[ PAGE_IS_KERNEL ]	= "kernel",
+	[ PAGE_IS_FS_METADATA ]	= "fs_metadata",
+	[ PAGE_IS_FILE_DATA ]	= "file_data",
+	[ PAGE_IS_ANON_DATA ]	= "anon_data",
+	[ PAGE_IS_SWAP_CACHE ]	= "swap_cache",
+	[ PAGE_IS_FREE ]	= "free",
+};
+
 struct hwpoison_control {
 	unsigned long pfn;
 	struct page *p;		/* corrupted page */
 	struct page *page;	/* compound page head */
 	int outcome;
+	int page_type;
+	unsigned data_recoverable:1;
+	unsigned page_isolated:1;
 };
 
 /*
@@ -358,8 +379,14 @@ static int me_pagecache_clean(struct hwp
 		page_cache_release(p);
 
 	mapping = page_mapping(p);
-	if (mapping == NULL)
+	if (mapping == NULL) {
+		hpc->page_isolated = 1;
 		return RECOVERED;
+	}
+
+	/* clean file backed page is recoverable */
+	if (!PageDirty(p) && !PageSwapBacked(p))
+		hpc->data_recoverable = 1;
 
 	/*
 	 * Now truncate the page in the page cache. This is really
@@ -368,12 +395,14 @@ static int me_pagecache_clean(struct hwp
 	 * has a reference, because it could be file system metadata
 	 * and that's not safe to truncate.
 	 */
-	if (!S_ISREG(mapping->host->i_mode) &&
-	    !invalidate_complete_page(mapping, p)) {
-		printk(KERN_ERR
-		       "MCE %#lx: failed to invalidate metadata page\n",
-			hpc->pfn);
-		return FAILED;
+	if (!S_ISREG(mapping->host->i_mode)) {
+		hpc->page_type = PAGE_IS_FS_METADATA;
+		if (!invalidate_complete_page(mapping, p)) {
+			printk(KERN_ERR
+			       "MCE %#lx: failed to invalidate metadata page\n",
+			       hpc->pfn);
+			return FAILED;
+		}
 	}
 
 	truncate_inode_page(mapping, p);
@@ -382,6 +411,8 @@ static int me_pagecache_clean(struct hwp
 			 hpc->pfn);
 		return FAILED;
 	}
+
+	hpc->page_isolated = 1;
 	return RECOVERED;
 }
 
@@ -467,6 +498,7 @@ static int me_swapcache_dirty(struct hwp
 	if (!isolate_lru_page(p))
 		page_cache_release(p);
 
+	hpc->page_isolated = 1;
 	return DELAYED;
 }
 
@@ -478,6 +510,8 @@ static int me_swapcache_clean(struct hwp
 		page_cache_release(p);
 
 	delete_from_swap_cache(p);
+	hpc->data_recoverable = 1;
+	hpc->page_isolated = 1;
 
 	return RECOVERED;
 }
@@ -587,6 +621,10 @@ static void page_action(struct page_stat
 		       "MCE %#lx: %s page still referenced by %d users\n",
 		       hpc->pfn, ps->msg, page_count(hpc->page) - 1);
 
+	if (page_count(hpc->page) > 1 ||
+	    page_mapcount(hpc->page) > 0)
+		hpc->page_isolated = 0;
+
 	/* Could do more checks here if page looks ok */
 	atomic_long_add(1, &mce_bad_pages);
 
@@ -735,6 +773,10 @@ void memory_failure(unsigned long pfn, i
 	hpc.p    = p;
 	hpc.page = p = compound_head(p);
 
+	hpc.page_type = PAGE_IS_KERNEL;
+	hpc.data_recoverable = 0;
+	hpc.page_isolated = 0;
+
 	/*
 	 * We need/can do nothing about count=0 pages.
 	 * 1) it's a free page, and therefore in safe hand:
@@ -747,9 +789,12 @@ void memory_failure(unsigned long pfn, i
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
 	if (!get_page_unless_zero(p)) {
-		if (is_free_buddy_page(p))
+		if (is_free_buddy_page(p)) {
+			hpc.page_type = PAGE_IS_FREE;
+			hpc.data_recoverable = 1;
+			hpc.page_isolated = 1;
 			action_result(&hpc, "free buddy", DELAYED);
-		else
+		} else
 			action_result(&hpc, "high order kernel", IGNORED);
 		return;
 	}
@@ -770,9 +815,18 @@ void memory_failure(unsigned long pfn, i
 	/*
 	 * Torn down by someone else?
 	 */
-	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
-		action_result(&hpc, "already truncated LRU", IGNORED);
-		goto out;
+	if (PageLRU(p)) {
+		if (PageSwapCache(p))
+			hpc.page_type = PAGE_IS_SWAP_CACHE;
+		else if (PageAnon(p))
+			hpc.page_type = PAGE_IS_ANON_DATA;
+		else
+			hpc.page_type = PAGE_IS_FILE_DATA;
+		if (!PageSwapCache(p) && p->mapping == NULL) {
+			action_result(&hpc, "already truncated LRU", IGNORED);
+			hpc.page_type = PAGE_IS_FREE;
+			goto out;
+		}
 	}
 
 	for (ps = error_states;; ps++) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
