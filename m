Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D4DB06B0102
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 01:08:49 -0400 (EDT)
Received: by pzk4 with SMTP id 4so1698859pzk.14
        for <linux-mm@kvack.org>; Sat, 04 Jun 2011 22:08:48 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] Fix page isolated count mismatch
Date: Sun,  5 Jun 2011 14:08:36 +0900
Message-Id: <1307250516-10756-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>

If migration is failed, normally we call putback_lru_pages which
decreases NR_ISOLATE_[ANON|FILE].
It means we should increase NR_ISOLATE_[ANON|FILE] before calling
putback_lru_pages. But soft_offline_page dosn't it.

It can make NR_ISOLATE_[ANON|FILE] with negative value and in UP build
, zone_page_state will say huge isolated pages so too_many_isolated
functions be deceived completely. At last, some process stuck in D state
as it expect while loop ending with congestion_wait.
But it's never ending story.

If it is right, it would be -stable stuff.

Cc: Andi Kleen <andi@firstfloor.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memory-failure.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 5c8f7e0..eac0ba5 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -52,6 +52,7 @@
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
 #include <linux/memory_hotplug.h>
+#include <linux/mm_inline.h>
 #include "internal.h"
 
 int sysctl_memory_failure_early_kill __read_mostly = 0;
@@ -1468,7 +1469,8 @@ int soft_offline_page(struct page *page, int flags)
 	put_page(page);
 	if (!ret) {
 		LIST_HEAD(pagelist);
-
+		inc_zone_page_state(page, NR_ISOLATED_ANON +
+					    page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
 								0, true);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
