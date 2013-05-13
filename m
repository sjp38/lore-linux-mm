Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 9FFA96B0036
	for <linux-mm@kvack.org>; Mon, 13 May 2013 06:21:30 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: Activate !PageLRU pages on mark_page_accessed if page is on local pagevec
Date: Mon, 13 May 2013 11:21:21 +0100
Message-Id: <1368440482-27909-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1368440482-27909-1-git-send-email-mgorman@suse.de>
References: <1368440482-27909-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>
Cc: Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

If a page is on a pagevec then it is !PageLRU and mark_page_accessed()
may fail to move a page to the active list as expected. Now that the LRU
is selected at LRU drain time, mark pages PageActive if they are on the
local pagevec so it gets moved to the correct list at LRU drain time.
Using a debugging patch it was found that for a simple git checkout based
workload that pages were never added to the active file list in practice
but with this patch applied they are.

				before   after
LRU Add Active File                  0      750583
LRU Add Active Anon            2640587     2702818
LRU Add Inactive File          8833662     8068353
LRU Add Inactive Anon              207         200

Note that only pages on the local pagevec are considered on purpose. A
!PageLRU page could be in the process of being released, reclaimed, migrated
or on a remote pagevec that is currently being drained. Marking it PageActive
is vunerable to races where PageLRU and Active bits are checked at the
wrong time. Page reclaim will trigger VM_BUG_ONs but depending on when the
race hits, it could also free a PageActive page to the page allocator and
trigger a bad_page warning. Similarly a potential race exists between a
per-cpu drain on a pagevec list and an activation on a remote CPU.

				lru_add_drain_cpu
				__pagevec_lru_add
				  lru = page_lru(page);
mark_page_accessed
  if (PageLRU(page))
    activate_page
  else
    SetPageActive
				  SetPageLRU(page);
				  add_page_to_lru_list(page, lruvec, lru);

In this case a PageActive page is added to the inactivate list and later the
inactive/active stats will get skewed. While the PageActive checks in vmscan
could be removed and potentially dealt with, a skew in the statistics would
be very difficult to detect. Hence this patch deals just with the common case
where a page being marked accessed has just been added to the local pagevec.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/swap.c | 34 ++++++++++++++++++++++++++++++++--
 1 file changed, 32 insertions(+), 2 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 0911579..7752407 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -431,6 +431,27 @@ void activate_page(struct page *page)
 }
 #endif
 
+static void __lru_cache_activate_page(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
+	int i;
+
+	/*
+	 * Search backwards on the optimistic assumption that the page being
+	 * activated has just been added to this pagevec
+	 */
+	for (i = pagevec_count(pvec) - 1; i >= 0; i--) {
+		struct page *pagevec_page = pvec->pages[i];
+
+		if (pagevec_page == page) {
+			SetPageActive(page);
+			break;
+		}
+	}
+
+	put_cpu_var(lru_add_pvec);
+}
+
 /*
  * Mark a page as having seen activity.
  *
@@ -441,8 +462,17 @@ void activate_page(struct page *page)
 void mark_page_accessed(struct page *page)
 {
 	if (!PageActive(page) && !PageUnevictable(page) &&
-			PageReferenced(page) && PageLRU(page)) {
-		activate_page(page);
+			PageReferenced(page)) {
+
+		/*
+		 * If the page is on the LRU, promote immediately. Otherwise,
+		 * assume the page is on a pagevec, mark it active and it'll
+		 * be moved to the active LRU on the next drain
+		 */
+		if (PageLRU(page))
+			activate_page(page);
+		else
+			__lru_cache_activate_page(page);
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
