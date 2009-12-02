From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 14/24] HWPOISON: return 0 if page is assured to be isolated
Date: Wed, 02 Dec 2009 11:12:45 +0800
Message-ID: <20091202043045.394560341@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 62CFF6007B7
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-isolated.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Introduce hpc.page_isolated to record if page is assured to be
isolated, ie. it won't be accessed in normal kernel code paths
and therefore won't trigger another MCE event.

__memory_failure() will now return 0 to indicate that page is
really isolated.  Note that the original used action result
RECOVERED is not a reliable criterion.

Note that we now don't bother to risk returning 0 for the
rare unpoison/truncated cases.

CC: Andi Kleen <andi@firstfloor.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

--- linux-mm.orig/mm/memory-failure.c	2009-11-30 20:35:49.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-11-30 20:40:56.000000000 +0800
@@ -332,6 +332,7 @@ struct hwpoison_control {
 	struct page *p;		/* raw corrupted page */
 	struct page *page;	/* compound page head */
 	int result;
+	unsigned page_isolated:1;
 };
 
 /*
@@ -529,9 +530,10 @@ static int me_swapcache_dirty(struct hwp
 	/* Trigger EIO in shmem: */
 	ClearPageUptodate(p);
 
-	if (!delete_from_lru_cache(p))
+	if (!delete_from_lru_cache(p)) {
+		hpc->page_isolated = 1;
 		return DELAYED;
-	else
+	} else
 		return FAILED;
 }
 
@@ -641,7 +643,7 @@ static void action_result(struct hwpoiso
 		msg, hwpoison_result_name[result]);
 }
 
-static int page_action(struct page_state *ps,
+static void page_action(struct page_state *ps,
 		       struct hwpoison_control *hpc)
 {
 	int result;
@@ -656,12 +658,15 @@ static int page_action(struct page_state
 		       "MCE %#lx: %s page still referenced by %d users\n",
 		       hpc->pfn, ps->msg, count);
 
+	if (result == RECOVERED)
+		hpc->page_isolated = 1;
+	if (count || page_mapcount(hpc->page))
+		hpc->page_isolated = 0;
+
 	/* Could do more checks here if page looks ok */
 	/*
 	 * Could adjust zone counters here to correct for the missing page.
 	 */
-
-	return result == RECOVERED ? 0 : -EBUSY;
 }
 
 #define N_UNMAP_TRIES 5
@@ -767,7 +772,6 @@ int __memory_failure(unsigned long pfn, 
 	struct page_state *ps;
 	struct page *p;
 	struct page *page;
-	int res;
 
 	if (!sysctl_memory_failure_recovery)
 		panic("Memory failure from trap %d on page %lx", trapno, pfn);
@@ -785,6 +789,7 @@ int __memory_failure(unsigned long pfn, 
 	hpc.pfn		= pfn;
 	hpc.p		= p;
 	hpc.page	= page;
+	hpc.page_isolated = 0;
 
 	if (TestSetPageHWPoison(p)) {
 		action_result(&hpc, "already hardware poisoned", IGNORED);
@@ -842,7 +847,6 @@ int __memory_failure(unsigned long pfn, 
 	 */
 	if (!PageHWPoison(p)) {
 		action_result(&hpc, "unpoisoned", IGNORED);
-		res = 0;
 		goto out;
 	}
 
@@ -852,30 +856,26 @@ int __memory_failure(unsigned long pfn, 
 	 * Now take care of user space mappings.
 	 * Abort on fail: __remove_from_page_cache() assumes unmapped page.
 	 */
-	if (hwpoison_user_mappings(&hpc, trapno) != SWAP_SUCCESS) {
-		res = -EBUSY;
+	if (hwpoison_user_mappings(&hpc, trapno) != SWAP_SUCCESS)
 		goto out;
-	}
 
 	/*
 	 * Torn down by someone else?
 	 */
 	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
 		action_result(&hpc, "already truncated LRU", IGNORED);
-		res = 0;
 		goto out;
 	}
 
-	res = -EBUSY;
 	for (ps = error_states;; ps++) {
 		if ((p->flags & ps->mask) == ps->res) {
-			res = page_action(ps, &hpc);
+			page_action(ps, &hpc);
 			break;
 		}
 	}
 out:
 	unlock_page(p);
-	return res;
+	return hpc.page_isolated ? 0 : -EBUSY;
 }
 EXPORT_SYMBOL_GPL(__memory_failure);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
