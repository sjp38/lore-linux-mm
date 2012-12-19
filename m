Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A0BCD6B0070
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 18:59:02 -0500 (EST)
Date: Wed, 19 Dec 2012 15:59:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/7] mm: vmscan: save work scanning (almost) empty LRU
 lists
Message-Id: <20121219155901.c488bac2.akpm@linux-foundation.org>
In-Reply-To: <1355767957-4913-3-git-send-email-hannes@cmpxchg.org>
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
	<1355767957-4913-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 17 Dec 2012 13:12:32 -0500
Johannes Weiner <hannes@cmpxchg.org> wrote:

> In certain cases (kswapd reclaim, memcg target reclaim), a fixed
> minimum amount of pages is scanned from the LRU lists on each
> iteration, to make progress.
> 
> Do not make this minimum bigger than the respective LRU list size,
> however, and save some busy work trying to isolate and reclaim pages
> that are not there.
> 
> Empty LRU lists are quite common with memory cgroups in NUMA
> environments because there exists a set of LRU lists for each zone for
> each memory cgroup, while the memory of a single cgroup is expected to
> stay on just one node.  The number of expected empty LRU lists is thus
> 
>   memcgs * (nodes - 1) * lru types
> 
> Each attempt to reclaim from an empty LRU list does expensive size
> comparisons between lists, acquires the zone's lru lock etc.  Avoid
> that.
> 
> ...
>
> -#define SWAP_CLUSTER_MAX 32
> +#define SWAP_CLUSTER_MAX 32UL

You made me review the effects of this change.  It looks OK.  A few
cleanups are possible, please review.

I wonder what happens in __setup_per_zone_wmarks() if we set
SWAP_CLUSTER_MAX greater than 128.



From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/page_alloc.c:__setup_per_zone_wmarks: make min_pages unsigned long

`int' is an inappropriate type for a number-of-pages counter.

While we're there, use the clamp() macro.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>
Cc: Simon Jeons <simon.jeons@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff -puN mm/page_alloc.c~a mm/page_alloc.c
--- a/mm/page_alloc.c~a
+++ a/mm/page_alloc.c
@@ -5258,13 +5258,10 @@ static void __setup_per_zone_wmarks(void
 			 * deltas controls asynch page reclaim, and so should
 			 * not be capped for highmem.
 			 */
-			int min_pages;
+			unsigned long min_pages;
 
 			min_pages = zone->present_pages / 1024;
-			if (min_pages < SWAP_CLUSTER_MAX)
-				min_pages = SWAP_CLUSTER_MAX;
-			if (min_pages > 128)
-				min_pages = 128;
+			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
 			zone->watermark[WMARK_MIN] = min_pages;
 		} else {
 			/*
_


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/vmscan.c:shrink_lruvec(): switch to min()

"mm: vmscan: save work scanning (almost) empty LRU lists" made
SWAP_CLUSTER_MAX an unsigned long.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>
Cc: Simon Jeons <simon.jeons@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN mm/vmscan.c~a mm/vmscan.c
--- a/mm/vmscan.c~a
+++ a/mm/vmscan.c
@@ -1873,8 +1873,7 @@ restart:
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(lru) {
 			if (nr[lru]) {
-				nr_to_scan = min_t(unsigned long,
-						   nr[lru], SWAP_CLUSTER_MAX);
+				nr_to_scan = min(nr[lru], SWAP_CLUSTER_MAX);
 				nr[lru] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
_


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/vmscan.c:__zone_reclaim(): replace max_t() with max()

"mm: vmscan: save work scanning (almost) empty LRU lists" made
SWAP_CLUSTER_MAX an unsigned long.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>
Cc: Simon Jeons <simon.jeons@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN mm/vmscan.c~mm-vmscanc-__zone_reclaim-replace-max_t-with-max mm/vmscan.c
--- a/mm/vmscan.c~mm-vmscanc-__zone_reclaim-replace-max_t-with-max
+++ a/mm/vmscan.c
@@ -3347,8 +3347,7 @@ static int __zone_reclaim(struct zone *z
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,
-		.nr_to_reclaim = max_t(unsigned long, nr_pages,
-				       SWAP_CLUSTER_MAX),
+		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
 		.order = order,
 		.priority = ZONE_RECLAIM_PRIORITY,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
