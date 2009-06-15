From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 17/22] HWPOISON: introduce struct hwpoison_control
Date: Mon, 15 Jun 2009 10:45:37 +0800
Message-ID: <20090615031254.740121710@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BBDDC6B007E
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:41 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-control.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Code cleanups to allow passing around more parameters and states.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |   94 ++++++++++++++++++++++++------------------
 1 file changed, 54 insertions(+), 40 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -298,26 +298,32 @@ static void collect_procs(struct page *p
  * Error handlers for various types of pages.
  */
 
-enum outcome {
+enum hwpoison_outcome {
 	FAILED,		/* Error handling failed */
 	DELAYED,	/* Will be handled later */
 	IGNORED,	/* Error safely ignored */
 	RECOVERED,	/* Successfully recovered */
 };
 
-static const char *action_name[] = {
+static const char *hwpoison_outcome_name[] = {
 	[FAILED] = "Failed",
 	[DELAYED] = "Delayed",
 	[IGNORED] = "Ignored",
 	[RECOVERED] = "Recovered",
 };
 
+struct hwpoison_control {
+	unsigned long pfn;
+	struct page *page;
+	int outcome;
+};
+
 /*
  * Error hit kernel page.
  * Do nothing, try to be lucky and not touch this instead. For a few cases we
  * could be more sophisticated.
  */
-static int me_kernel(struct page *p, unsigned long pfn)
+static int me_kernel(struct hwpoison_control *hpc)
 {
 	return DELAYED;
 }
@@ -325,7 +331,7 @@ static int me_kernel(struct page *p, uns
 /*
  * Already poisoned page.
  */
-static int me_ignore(struct page *p, unsigned long pfn)
+static int me_ignore(struct hwpoison_control *hpc)
 {
 	return IGNORED;
 }
@@ -333,16 +339,16 @@ static int me_ignore(struct page *p, uns
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
  * Free memory
  */
-static int me_free(struct page *p, unsigned long pfn)
+static int me_free(struct hwpoison_control *hpc)
 {
 	return DELAYED;
 }
@@ -350,9 +356,10 @@ static int me_free(struct page *p, unsig
 /*
  * Clean (or cleaned) page cache page.
  */
-static int me_pagecache_clean(struct page *p, unsigned long pfn)
+static int me_pagecache_clean(struct hwpoison_control *hpc)
 {
 	struct address_space *mapping;
+	struct page *p = hpc->page;
 
 	if (!isolate_lru_page(p))
 		page_cache_release(p);
@@ -372,14 +379,14 @@ static int me_pagecache_clean(struct pag
 	    !invalidate_complete_page(mapping, p)) {
 		printk(KERN_ERR
 		       "MCE %#lx: failed to invalidate metadata page\n",
-			pfn);
+			hpc->pfn);
 		return FAILED;
 	}
 
 	truncate_inode_page(mapping, p);
 	if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO)) {
 		pr_debug(KERN_ERR "MCE %#lx: failed to release buffers\n",
-			 pfn);
+			 hpc->pfn);
 		return FAILED;
 	}
 	return RECOVERED;
@@ -390,11 +397,11 @@ static int me_pagecache_clean(struct pag
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
@@ -434,7 +441,7 @@ static int me_pagecache_dirty(struct pag
 		mapping_set_error(mapping, EIO);
 	}
 
-	return me_pagecache_clean(p, pfn);
+	return me_pagecache_clean(hpc);
 }
 
 /*
@@ -456,8 +463,10 @@ static int me_pagecache_dirty(struct pag
  * Clean swap cache pages can be directly isolated. A later page fault will
  * bring in the known good data from disk.
  */
-static int me_swapcache_dirty(struct page *p, unsigned long pfn)
+static int me_swapcache_dirty(struct hwpoison_control *hpc)
 {
+	struct page *p = hpc->page;
+
 	ClearPageDirty(p);
 	/* Trigger EIO in shmem: */
 	ClearPageUptodate(p);
@@ -468,8 +477,10 @@ static int me_swapcache_dirty(struct pag
 	return DELAYED;
 }
 
-static int me_swapcache_clean(struct page *p, unsigned long pfn)
+static int me_swapcache_clean(struct hwpoison_control *hpc)
 {
+	struct page *p = hpc->page;
+
 	if (!isolate_lru_page(p))
 		page_cache_release(p);
 
@@ -489,7 +500,7 @@ static int me_swapcache_clean(struct pag
  * Should handle free huge pages and dequeue them too, but this needs to
  * handle huge page accounting correctly.
  */
-static int me_huge_page(struct page *p, unsigned long pfn)
+static int me_huge_page(struct hwpoison_control *hpc)
 {
 	return FAILED;
 }
@@ -525,7 +536,7 @@ static struct page_state {
 	unsigned long mask;
 	unsigned long res;
 	char *msg;
-	int (*action)(struct page *p, unsigned long pfn);
+	int (*action)(struct hwpoison_control *hpc);
 } error_states[] = {
 	{ reserved,	reserved,	"reserved kernel",	me_ignore },
 	{ buddy,	buddy,		"free kernel",	me_free },
@@ -567,24 +578,22 @@ static struct page_state {
 	{ 0,		0,		"unknown page state",	me_unknown },
 };
 
-static void action_result(unsigned long pfn, char *msg, int result)
+static void action_result(struct hwpoison_control *hpc, char *msg, int result)
 {
+	hpc->outcome = result;
 	printk(KERN_ERR "MCE %#lx: %s%s page recovery: %s\n",
-		pfn, PageDirty(pfn_to_page(pfn)) ? "dirty " : "",
-		msg, action_name[result]);
+		hpc->pfn, PageDirty(hpc->page) ? "dirty " : "",
+		msg, hwpoison_outcome_name[result]);
 }
 
-static void page_action(struct page_state *ps, struct page *p,
-			unsigned long pfn)
+static void page_action(struct page_state *ps, struct hwpoison_control *hpc)
 {
-	int result;
+	action_result(hpc, ps->msg, ps->action(hpc));
 
-	result = ps->action(p, pfn);
-	action_result(pfn, ps->msg, result);
-	if (page_count(p) != 1)
+	if (page_count(hpc->page) != 1)
 		printk(KERN_ERR
 		       "MCE %#lx: %s page still referenced by %d users\n",
-		       pfn, ps->msg, page_count(p) - 1);
+		       hpc->pfn, ps->msg, page_count(hpc->page) - 1);
 
 	/* Could do more checks here if page looks ok */
 	atomic_long_add(1, &mce_bad_pages);
@@ -600,12 +609,12 @@ static void page_action(struct page_stat
  * Do all that is necessary to remove user space mappings. Unmap
  * the pages and send SIGBUS to the processes if the data was dirty.
  */
-static void hwpoison_user_mappings(struct page *p, unsigned long pfn,
-				  int trapno)
+static void hwpoison_user_mappings(struct hwpoison_control *hpc, int trapno)
 {
 	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	int kill = sysctl_memory_failure_early_kill;
 	struct address_space *mapping;
+	struct page *p = hpc->page;
 	LIST_HEAD(tokill);
 	int ret;
 	int i;
@@ -625,7 +634,8 @@ static void hwpoison_user_mappings(struc
 
 	if (PageSwapCache(p)) {
 		printk(KERN_ERR
-		       "MCE %#lx: keeping poisoned page in swap cache\n", pfn);
+		       "MCE %#lx: keeping poisoned page in swap cache\n",
+		       hpc->pfn);
 		ttu |= TTU_IGNORE_HWPOISON;
 	}
 
@@ -642,7 +652,7 @@ static void hwpoison_user_mappings(struc
 			ttu |= TTU_IGNORE_HWPOISON;
 			printk(KERN_INFO
 	"MCE %#lx: corrupted page was clean: dropped without side effects\n",
-				pfn);
+				hpc->pfn);
 		}
 	}
 
@@ -670,12 +680,13 @@ static void hwpoison_user_mappings(struc
 		ret = try_to_unmap(p, ttu);
 		if (ret == SWAP_SUCCESS)
 			break;
-		pr_debug("MCE %#lx: try_to_unmap retry needed %d\n", pfn,  ret);
+		pr_debug("MCE %#lx: try_to_unmap retry needed %d\n",
+			 hpc->pfn, ret);
 	}
 
 	if (ret != SWAP_SUCCESS)
 		printk(KERN_ERR "MCE %#lx: failed to unmap page (mapcount=%d)\n",
-				pfn, page_mapcount(p));
+				hpc->pfn, page_mapcount(p));
 
 	/*
 	 * Now that the dirty bit has been propagated to the
@@ -687,7 +698,7 @@ static void hwpoison_user_mappings(struc
 	 * any accesses to the poisoned memory.
 	 */
 	kill_procs_ao(&tokill, !!PageDirty(p), trapno,
-		      ret != SWAP_SUCCESS, pfn);
+		      ret != SWAP_SUCCESS, hpc->pfn);
 }
 
 /**
@@ -711,6 +722,7 @@ void memory_failure(unsigned long pfn, i
 {
 	struct page_state *ps;
 	struct page *p;
+	struct hwpoison_control hpc;
 
 	if (!pfn_valid(pfn)) {
 		printk(KERN_ERR
@@ -720,8 +732,10 @@ void memory_failure(unsigned long pfn, i
 	}
 
 	p = pfn_to_page(pfn);
+	hpc.pfn = pfn;
+	hpc.page = p;
 	if (TestSetPageHWPoison(p)) {
-		action_result(pfn, "already hardware poisoned", IGNORED);
+		action_result(&hpc, "already hardware poisoned", IGNORED);
 		return;
 	}
 
@@ -737,7 +751,7 @@ void memory_failure(unsigned long pfn, i
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
 	if (!get_page_unless_zero(compound_head(p))) {
-		action_result(pfn, "free or high order kernel", IGNORED);
+		action_result(&hpc, "free or high order kernel", IGNORED);
 		return;
 	}
 
@@ -752,19 +766,19 @@ void memory_failure(unsigned long pfn, i
 	/*
 	 * Now take care of user space mappings.
 	 */
-	hwpoison_user_mappings(p, pfn, trapno);
+	hwpoison_user_mappings(&hpc, trapno);
 
 	/*
 	 * Torn down by someone else?
 	 */
 	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
-		action_result(pfn, "already truncated LRU", IGNORED);
+		action_result(&hpc, "already truncated LRU", IGNORED);
 		goto out;
 	}
 
 	for (ps = error_states;; ps++) {
 		if ((p->flags & ps->mask) == ps->res) {
-			page_action(ps, p, pfn);
+			page_action(ps, &hpc);
 			break;
 		}
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
