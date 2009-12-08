Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 90BA8600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:27 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [6/31] HWPOISON: avoid grabbing the page count multiple times during madvise injection
Message-Id: <20091208211622.54209B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:22 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

If page is double referenced in madvise_hwpoison() and __memory_failure(),
remove_mapping() will fail because it expects page_count=2. Fix it by
not grabbing extra page count in __memory_failure().

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/madvise.c        |    1 -
 mm/memory-failure.c |    8 ++++----
 2 files changed, 4 insertions(+), 5 deletions(-)

Index: linux/mm/madvise.c
===================================================================
--- linux.orig/mm/madvise.c
+++ linux/mm/madvise.c
@@ -238,7 +238,6 @@ static int madvise_hwpoison(unsigned lon
 		       page_to_pfn(p), start);
 		/* Ignore return value for now */
 		__memory_failure(page_to_pfn(p), 0, 1);
-		put_page(p);
 	}
 	return ret;
 }
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -629,7 +629,7 @@ static void action_result(unsigned long
 }
 
 static int page_action(struct page_state *ps, struct page *p,
-			unsigned long pfn, int ref)
+			unsigned long pfn)
 {
 	int result;
 	int count;
@@ -637,7 +637,7 @@ static int page_action(struct page_state
 	result = ps->action(p, pfn);
 	action_result(pfn, ps->msg, result);
 
-	count = page_count(p) - 1 - ref;
+	count = page_count(p) - 1;
 	if (count != 0)
 		printk(KERN_ERR
 		       "MCE %#lx: %s page still referenced by %d users\n",
@@ -775,7 +775,7 @@ int __memory_failure(unsigned long pfn,
 	 * In fact it's dangerous to directly bump up page count from 0,
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
-	if (!get_page_unless_zero(compound_head(p))) {
+	if (!ref && !get_page_unless_zero(compound_head(p))) {
 		action_result(pfn, "free or high order kernel", IGNORED);
 		return PageBuddy(compound_head(p)) ? 0 : -EBUSY;
 	}
@@ -823,7 +823,7 @@ int __memory_failure(unsigned long pfn,
 	res = -EBUSY;
 	for (ps = error_states;; ps++) {
 		if (((p->flags | lru_flag)& ps->mask) == ps->res) {
-			res = page_action(ps, p, pfn, ref);
+			res = page_action(ps, p, pfn);
 			break;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
