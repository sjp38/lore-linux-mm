Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 73C476B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 21:12:15 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/2][BUGFIX] mm: do not use page_count without a page pin
Date: Thu, 14 Jun 2012 10:12:13 +0900
Message-Id: <1339636334-9238-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wanpeng Li <liwp.linux@gmail.com>

d179e84ba fixed the problem[1] in vmscan.c but same problem is here.
Let's fix it.

[1] http://comments.gmane.org/gmane.linux.kernel.mm/65844

I copy and paste d179e84ba's contents for description.

"It is unsafe to run page_count during the physical pfn scan because
compound_head could trip on a dangling pointer when reading
page->first_page if the compound page is being freed by another CPU."

* changelog from v1
  - Add comment about skip tail page of THP - Andrea
  - fix typo - Wanpeng Li
  - based on next-20120613

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Wanpeng Li <liwp.linux@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 266f267..543cc2d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5496,11 +5496,18 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
 			continue;
 
 		page = pfn_to_page(check);
-		if (!page_count(page)) {
+		/*
+		 * We can't use page_count without pin a page
+		 * because another CPU can free compound page.
+		 * This check already skips compound tails of THP
+		 * because their page->_count is zero at all time.
+		 */
+		if (!atomic_read(&page->_count)) {
 			if (PageBuddy(page))
 				iter += (1 << page_order(page)) - 1;
 			continue;
 		}
+
 		if (!PageLRU(page))
 			found++;
 		/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
