Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 1771D6B0068
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 22:03:29 -0500 (EST)
Date: Thu, 20 Dec 2012 22:02:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/7] mm: vmscan: save work scanning (almost) empty LRU
 lists
Message-ID: <20121221030236.GF7147@cmpxchg.org>
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
 <1355767957-4913-3-git-send-email-hannes@cmpxchg.org>
 <20121219155901.c488bac2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121219155901.c488bac2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 19, 2012 at 03:59:01PM -0800, Andrew Morton wrote:
> On Mon, 17 Dec 2012 13:12:32 -0500
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > In certain cases (kswapd reclaim, memcg target reclaim), a fixed
> > minimum amount of pages is scanned from the LRU lists on each
> > iteration, to make progress.
> > 
> > Do not make this minimum bigger than the respective LRU list size,
> > however, and save some busy work trying to isolate and reclaim pages
> > that are not there.
> > 
> > Empty LRU lists are quite common with memory cgroups in NUMA
> > environments because there exists a set of LRU lists for each zone for
> > each memory cgroup, while the memory of a single cgroup is expected to
> > stay on just one node.  The number of expected empty LRU lists is thus
> > 
> >   memcgs * (nodes - 1) * lru types
> > 
> > Each attempt to reclaim from an empty LRU list does expensive size
> > comparisons between lists, acquires the zone's lru lock etc.  Avoid
> > that.
> > 
> > ...
> >
> > -#define SWAP_CLUSTER_MAX 32
> > +#define SWAP_CLUSTER_MAX 32UL
> 
> You made me review the effects of this change.  It looks OK.  A few
> cleanups are possible, please review.
> 
> I wonder what happens in __setup_per_zone_wmarks() if we set
> SWAP_CLUSTER_MAX greater than 128.

In the current clamp() implementation max overrides min, so...

BUILD_BUG_ON()?  Probably unnecessary, it seems like a rather
arbitrary range to begin with.

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/page_alloc.c:__setup_per_zone_wmarks: make min_pages unsigned long
> 
> `int' is an inappropriate type for a number-of-pages counter.
> 
> While we're there, use the clamp() macro.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Satoru Moriya <satoru.moriya@hds.com>
> Cc: Simon Jeons <simon.jeons@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/vmscan.c:shrink_lruvec(): switch to min()
> 
> "mm: vmscan: save work scanning (almost) empty LRU lists" made
> SWAP_CLUSTER_MAX an unsigned long.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Satoru Moriya <satoru.moriya@hds.com>
> Cc: Simon Jeons <simon.jeons@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/vmscan.c:__zone_reclaim(): replace max_t() with max()
> 
> "mm: vmscan: save work scanning (almost) empty LRU lists" made
> SWAP_CLUSTER_MAX an unsigned long.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Satoru Moriya <satoru.moriya@hds.com>
> Cc: Simon Jeons <simon.jeons@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
