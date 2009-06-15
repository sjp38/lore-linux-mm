From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 18/22] HWPOISON: use compound head page
Date: Mon, 15 Jun 2009 10:45:38 +0800
Message-ID: <20090615031254.862669832@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 021AD6B0085
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:36 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-compound-page-head.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

In most places we want to test/operate on the compound head page. 
The raw poisoned page is recorded in hwpoison_control.p for others.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -314,7 +314,8 @@ static const char *hwpoison_outcome_name
 
 struct hwpoison_control {
 	unsigned long pfn;
-	struct page *page;
+	struct page *p;		/* corrupted page */
+	struct page *page;	/* compound page head */
 	int outcome;
 };
 
@@ -732,13 +733,17 @@ void memory_failure(unsigned long pfn, i
 	}
 
 	p = pfn_to_page(pfn);
-	hpc.pfn = pfn;
-	hpc.page = p;
 	if (TestSetPageHWPoison(p)) {
-		action_result(&hpc, "already hardware poisoned", IGNORED);
+		printk(KERN_ERR
+		       "MCE %#lx: already hardware poisoned: Ignored\n",
+		       pfn);
 		return;
 	}
 
+	hpc.pfn  = pfn;
+	hpc.p    = p;
+	hpc.page = p = compound_head(p);
+
 	/*
 	 * We need/can do nothing about count=0 pages.
 	 * 1) it's a free page, and therefore in safe hand:
@@ -750,7 +755,7 @@ void memory_failure(unsigned long pfn, i
 	 * In fact it's dangerous to directly bump up page count from 0,
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
-	if (!get_page_unless_zero(compound_head(p))) {
+	if (!get_page_unless_zero(p)) {
 		action_result(&hpc, "free or high order kernel", IGNORED);
 		return;
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
