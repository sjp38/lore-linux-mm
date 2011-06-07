Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4BE6B007D
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 11:07:13 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: memory-failure: Fix isolated page count during memory failure
Date: Tue,  7 Jun 2011 16:07:04 +0100
Message-Id: <1307459225-4481-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1307459225-4481-1-git-send-email-mgorman@suse.de>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

From: Minchan Kim <minchan.kim@gmail.com>

From: Minchan Kim <minchan.kim@gmail.com>

Pages isolated for migration are accounted with the vmstat counters
NR_ISOLATE_[ANON|FILE]. Callers of migrate_pages() are expected to
increment these counters when pages are isolated from the LRU. Once
the pages have been migrated, they are put back on the LRU or freed
and the isolated count is decremented.

Memory failure is not properly accounting for pages it isolates
causing the NR_ISOLATED counters to be negative. On SMP builds,
this goes unnoticed as negative counters are treated as 0 due to
expected per-cpu drift. On UP builds, the counter is treated by
too_many_isolated() as a large value causing processes to enter D
state during page reclaim or compaction. This patch accounts for
pages isolated by memory failure correctly.

[mgorman@suse.de: Updated changelog]
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
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
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
