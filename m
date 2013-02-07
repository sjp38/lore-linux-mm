Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id E44036B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 11:14:02 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] HWPOISON: fix misjudgement of page_action() for errors on mlocked pages
Date: Thu,  7 Feb 2013 11:13:40 -0500
Message-Id: <1360253620-10223-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>
Cc: gong.chen@linux.intel.com, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

memory_failure() can't handle memory errors on mlocked pages correctly,
because page_action() judges such errors as ones on "unknown pages"
instead of ones on "unevictable LRU page" or "mlocked LRU page".
In order to determine page_state page_action() checks page flags at the
timing of the judgement, but such page flags are not the same with those
just after memory_failure() is called, because memory_failure() does
unmapping of the error pages before doing page_action(). This unmapping
changes the page state, especially page_remove_rmap() (called from
try_to_unmap_one()) clears PG_mlocked, so page_action() can't catch mlocked
pages after that.

With this patch, we store the page flag of the error page before doing
unmap, and (only) if the first check with page flags at the time decided
the error page is unknown, we do the second check with the stored page flag.
This implementation doesn't change error handling for the page types
for which the first check can determine the page state correctly.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 27 ++++++++++++++++++++++-----
 1 file changed, 22 insertions(+), 5 deletions(-)

diff --git v3.8-rc5.orig/mm/memory-failure.c v3.8-rc5/mm/memory-failure.c
index c60d86c..e6d6022 100644
--- v3.8-rc5.orig/mm/memory-failure.c
+++ v3.8-rc5/mm/memory-failure.c
@@ -1093,6 +1093,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	struct page *hpage;
 	int res;
 	unsigned int nr_pages;
+	unsigned long page_flags;
 
 	if (!sysctl_memory_failure_recovery)
 		panic("Memory failure from trap %d on page %lx", trapno, pfn);
@@ -1201,6 +1202,15 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	lock_page(hpage);
 
 	/*
+	 * We use page flags to determine what action should be taken,
+	 * but it can be modified by the error containment action.
+	 * One example is mlocked page, where PG_mlocked is cleared by
+	 * page_remove_rmap() in try_to_unmap_one(). So to determine page
+	 * status correctly, we store the page flags at this timing.
+	 */
+	page_flags = p->flags;
+
+	/*
 	 * unpoison always clear PG_hwpoison inside page lock
 	 */
 	if (!PageHWPoison(p)) {
@@ -1258,12 +1268,19 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	}
 
 	res = -EBUSY;
-	for (ps = error_states;; ps++) {
-		if ((p->flags & ps->mask) == ps->res) {
-			res = page_action(ps, p, pfn);
+	/*
+	 * The first check uses the current page flag which might not have any
+	 * relevant information. The second check with stored page flags are
+	 * carried out only if the first check can't determine the page status.
+	 */
+	for (ps = error_states;; ps++)
+		if ((p->flags & ps->mask) == ps->res)
 			break;
-		}
-	}
+	if (!ps->mask)
+		for (ps = error_states;; ps++)
+			if ((page_flags & ps->mask) == ps->res)
+				break;
+	res = page_action(ps, p, pfn);
 out:
 	unlock_page(hpage);
 	return res;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
