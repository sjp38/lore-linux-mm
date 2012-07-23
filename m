Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 498296B006C
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 20:47:53 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RESEND RFC 3/3] memory-hotplug: bug fix race between isolation and allocation
Date: Mon, 23 Jul 2012 09:48:02 +0900
Message-Id: <1343004482-6916-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1343004482-6916-1-git-send-email-minchan@kernel.org>
References: <1343004482-6916-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, lliubbo@gmail.com, Minchan Kim <minchan@kernel.org>

Like below, memory-hotplug makes race between page-isolation
and page-allocation so it can hit BUG_ON in __offline_isolated_pages.

	CPU A					CPU B

start_isolate_page_range
set_migratetype_isolate
spin_lock_irqsave(zone->lock)

				free_hot_cold_page(Page A)
				/* without zone->lock */
				migratetype = get_pageblock_migratetype(Page A);
				/*
				 * Page could be moved into MIGRATE_MOVABLE
				 * of per_cpu_pages
				 */
				list_add_tail(&page->lru, &pcp->lists[migratetype]);

set_pageblock_isolate
move_freepages_block
drain_all_pages

				/* Page A could be in MIGRATE_MOVABLE of free_list. */

check_pages_isolated
__test_page_isolated_in_pageblock
/*
 * We can't catch freed page which
 * is free_list[MIGRATE_MOVABLE]
 */
if (PageBuddy(page A))
	pfn += 1 << page_order(page A);

				/* So, Page A could be allocated */

__offline_isolated_pages
/*
 * BUG_ON hit or offline page
 * which is used by someone
 */
BUG_ON(!PageBuddy(page A));

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
I found this problem during code review so please confirm it.
Kame?

 mm/page_isolation.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index acf65a7..4699d1f 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -196,8 +196,11 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
 			continue;
 		}
 		page = pfn_to_page(pfn);
-		if (PageBuddy(page))
+		if (PageBuddy(page)) {
+			if (get_page_migratetype(page) != MIGRATE_ISOLATE)
+				break;
 			pfn += 1 << page_order(page);
+		}
 		else if (page_count(page) == 0 &&
 				get_page_migratetype(page) == MIGRATE_ISOLATE)
 			pfn += 1;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
