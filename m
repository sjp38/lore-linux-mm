Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 8BC9F6B002B
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 14:34:22 -0500 (EST)
Date: Thu, 13 Dec 2012 14:33:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/8] mm: vmscan: save work scanning (almost) empty LRU
 lists
Message-ID: <20121213193332.GB6317@cmpxchg.org>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-4-git-send-email-hannes@cmpxchg.org>
 <20121213104104.GX1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121213104104.GX1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 13, 2012 at 10:41:04AM +0000, Mel Gorman wrote:
> On Wed, Dec 12, 2012 at 04:43:35PM -0500, Johannes Weiner wrote:
> > In certain cases (kswapd reclaim, memcg target reclaim), a fixed
> > minimum amount of pages is scanned from the LRU lists on each
> > iteration, to make progress.
> > 
> > Do not make this minimum bigger than the respective LRU list size,
> > however, and save some busy work trying to isolate and reclaim pages
> > that are not there.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> This looks like a corner case where the LRU size would have to be smaller
> than SWAP_CLUSTER_MAX. Is that common enough to care? It looks correct,
> I'm just curious.

We have one lruvec per memcg per zone, so consider memory cgroups in a
NUMA environment: NR_MEMCG * (NR_NODES - 1) * NR_LRU_LISTS permanently
empty lruvecs, assuming the memory of one cgroup is bound to one node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
