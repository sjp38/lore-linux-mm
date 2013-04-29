Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 451D96B009F
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 17:53:34 -0400 (EDT)
Date: Mon, 29 Apr 2013 22:53:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: Ensure that mark_page_accessed moves pages to
 the active list
Message-ID: <20130429215327.GA11497@suse.de>
References: <1367253119-6461-1-git-send-email-mgorman@suse.de>
 <1367253119-6461-3-git-send-email-mgorman@suse.de>
 <517EA9E3.6050407@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <517EA9E3.6050407@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Mon, Apr 29, 2013 at 01:12:03PM -0400, Rik van Riel wrote:
> On 04/29/2013 12:31 PM, Mel Gorman wrote:
> 
> >A PageActive page is now added to the inactivate list.
> >
> >While this looks strange, I think it is sufficiently harmless that additional
> >barriers to address the case is not justified.  Unfortunately, while I never
> >witnessed it myself, these parallel updates potentially trigger defensive
> >DEBUG_VM checks on PageActive and hence they are removed by this patch.
> 
> Could this not cause issues with __page_cache_release, called from
> munmap, exit, truncate, etc.?
> 

Possibly if the page was activated before it was freed to the page allocator.

> Could the eventual skewing of active vs inactive numbers break page
> reclaim heuristics?
> 

Yes, good point and it would be very difficult to detect that it happened.

> I wonder if we would need to move to a scheme where the PG_active bit
> is always the authoritive one, and we never pass an overriding "lru"
> parameter to __pagevec_lru_add.
> 

I don't think that necessarily gets away from the various differnet races.

> Would memory ordering between SetPageLRU and testing for PageLRU be
> enough to then prevent the statistics from going off?
> 

I do not think all the holes in every cases can be closed. There are a
lot of races and bugs would creep in eventually. As the common case of
interest is when a page has recently been added to the local CPUs pagevec
the following should be sufficient.

---8<---
mm: Activate !PageLRU pages on mark_page_accessed if page is on local pagevec

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
index 80fbc37..96565eb 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -427,6 +427,27 @@ void activate_page(struct page *page)
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
@@ -437,8 +458,17 @@ void activate_page(struct page *page)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
