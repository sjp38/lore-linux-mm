Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD1C6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 06:31:34 -0400 (EDT)
Date: Tue, 28 Apr 2009 11:31:59 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] Properly account for freed pages in free_pages_bulk() and
	when allocating high-order pages in buffered_rmqueue()
Message-ID: <20090428103159.GB23540@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240819119.2567.884.camel@ymzhang> <20090427143845.GC912@csn.ul.ie> <1240883957.2567.886.camel@ymzhang>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240883957.2567.886.camel@ymzhang>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

This patch fixes two problems with one patch in the page allocator
optimisation patchset.

free_pages_bulk() updates the number of free pages in the zone but it is
assuming that the pages being freed are order-0. While this is currently
always true, it's wrong to assume the order is 0. This patch fixes the
problem.

buffered_rmqueue() is not updating NR_FREE_PAGES when allocating pages with
__rmqueue(). As a result, a high-order allocation will leave an elevated
free page count value leading to the situation where the free page count
exceeds available RAM. This patch accounts for those allocated pages properly.

This is a fix for page-allocator-update-nr_free_pages-only-as-necessary.patch.

Reported-by: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dd2d59..59eb2e1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -545,7 +545,7 @@ static void free_pages_bulk(struct zone *zone, int count,
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
 
-	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
+	__mod_zone_page_state(zone, NR_FREE_PAGES, count << order);
 	while (count--) {
 		struct page *page;
 
@@ -1151,6 +1151,7 @@ again:
 	} else {
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
