Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DA7B36B004F
	for <linux-mm@kvack.org>; Tue, 26 May 2009 21:47:54 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: release swap slots for actively used pages
Date: Wed, 27 May 2009 03:47:39 +0200
Message-Id: <1243388859-9760-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

For anonymous pages activated by the reclaim scan or faulted from an
evicted page table entry we should always try to free up swap space.

Both events indicate that the page is in active use and a possible
change in the working set.  Thus removing the slot association from
the page increases the chance of the page being placed near its new
LRU buddies on the next eviction and helps keeping the amount of stale
swap cache entries low.

try_to_free_swap() inherently only succeeds when the last user of the
swap slot vanishes so it is safe to use from places where that single
mapping just brought the page back to life.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
 mm/memory.c |    3 +--
 mm/vmscan.c |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8b4e40e..407ebf7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2671,8 +2671,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	mem_cgroup_commit_charge_swapin(page, ptr);
 
 	swap_free(entry);
-	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
-		try_to_free_swap(page);
+	try_to_free_swap(page);
 	unlock_page(page);
 
 	if (write_access) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 621708f..2f0549d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -788,7 +788,7 @@ cull_mlocked:
 
 activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
-		if (PageSwapCache(page) && vm_swap_full())
+		if (PageSwapCache(page))
 			try_to_free_swap(page);
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
