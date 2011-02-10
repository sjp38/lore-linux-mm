Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C58C78D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 05:21:40 -0500 (EST)
Date: Thu, 10 Feb 2011 10:21:10 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] vmscan: fix zone shrinking exit when scan work is done
Message-ID: <20110210102109.GB17873@csn.ul.ie>
References: <20110209154606.GJ27110@cmpxchg.org> <20110209164656.GA1063@csn.ul.ie> <20110209182846.GN3347@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110209182846.GN3347@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 09, 2011 at 07:28:46PM +0100, Andrea Arcangeli wrote:
> On Wed, Feb 09, 2011 at 04:46:56PM +0000, Mel Gorman wrote:
> > On Wed, Feb 09, 2011 at 04:46:06PM +0100, Johannes Weiner wrote:
> > > Hi,
> > > 
> > > I think this should fix the problem of processes getting stuck in
> > > reclaim that has been reported several times.
> > 
> > I don't think it's the only source but I'm basing this on seeing
> > constant looping in balance_pgdat() and calling congestion_wait() a few
> > weeks ago that I haven't rechecked since. However, this looks like a
> > real fix for a real problem.
> 
> Agreed. Just yesterday I spent some time on the lumpy compaction
> changes after wondering about Michal's khugepaged 100% report, and I
> expected some fix was needed in this area (as I couldn't find any bug
> in khugepaged yet, so the lumpy compaction looked the next candidate
> for bugs).
> 

Michal did report that disabling defrag did not help but the stack trace
also showed that it was stuck in shrink_zone() which is what Johannes'
patch targets. It's not unreasonable to test if Johannes' patch solves
Michal's problem. Michal, I know that your workload is a bit random and
may not be reproducible but do you think it'd be possible to determine
if Johannes' patch helps?

> I've also been wondering about the !nr_scanned check in
> should_continue_reclaim too but I didn't look too much into the caller
> (I was tempted to remove it all together). I don't see how checking
> nr_scanned can be safe even after we fix the caller to avoid passing
> non-zero values if "goto restart".
> 
> nr_scanned is incremented even for !page_evictable... so it's not
> really useful to insist, just because we scanned something, in my
> view. It looks bogus... So my proposal would be below.
> 

We should not be ending up in a situation with the LRU list of only
page_evictable pages and that situation persisting causing excessive (or
infinite) looping. As unevictable pages are encountered on the LRU list,
they should be moved to the unevictable lists by putback_lru_page().  Are you
aware of a situation where this becomes broken?

I recognise that SWAP_CLUSTER_MAX pages could all be unevictable and they
are all get moved. In this case, nr_scanned is positive and we continue
to scan but this is expected and desirable: Reclaim/compaction needs more
pages to be freed before it starts compaction. If it stops scanning early,
then it would just fail the allocation later. This is what the "NOTE" is about.

I prefer Johannes' fix for the observed problem.

> ====
> Subject: mm: stop checking nr_scanned in should_continue_reclaim
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> nr_scanned is incremented even for !page_evictable... so it's not
> really useful to insist, just because we scanned something.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 148c6e6..9741884 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1831,7 +1831,6 @@ out:
>   */
>  static inline bool should_continue_reclaim(struct zone *zone,
>  					unsigned long nr_reclaimed,
> -					unsigned long nr_scanned,
>  					struct scan_control *sc)
>  {
>  	unsigned long pages_for_compaction;
> @@ -1841,15 +1840,8 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  	if (!(sc->reclaim_mode & RECLAIM_MODE_COMPACTION))
>  		return false;
>  
> -	/*
> -	 * If we failed to reclaim and have scanned the full list, stop.
> -	 * NOTE: Checking just nr_reclaimed would exit reclaim/compaction far
> -	 *       faster but obviously would be less likely to succeed
> -	 *       allocation. If this is desirable, use GFP_REPEAT to decide
> -	 *       if both reclaimed and scanned should be checked or just
> -	 *       reclaimed
> -	 */
> -	if (!nr_reclaimed && !nr_scanned)
> +	/* If we failed to reclaim stop. */
> +	if (!nr_reclaimed)
>  		return false;
>  
>  	/*
> @@ -1884,7 +1876,6 @@ static void shrink_zone(int priority, struct zone *zone,
>  	enum lru_list l;
>  	unsigned long nr_reclaimed;
>  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> -	unsigned long nr_scanned = sc->nr_scanned;
>  
>  restart:
>  	nr_reclaimed = 0;
> @@ -1923,8 +1914,7 @@ restart:
>  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
>  
>  	/* reclaim/compaction might need reclaim to continue */
> -	if (should_continue_reclaim(zone, nr_reclaimed,
> -					sc->nr_scanned - nr_scanned, sc))
> +	if (should_continue_reclaim(zone, nr_reclaimed, sc))
>  		goto restart;
>  
>  	throttle_vm_writeout(sc->gfp_mask);
> 
> 

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
