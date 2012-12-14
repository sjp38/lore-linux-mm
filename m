Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 596776B006C
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 03:46:42 -0500 (EST)
Date: Fri, 14 Dec 2012 09:46:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/8] mm: vmscan: save work scanning (almost) empty LRU
 lists
Message-ID: <20121214084637.GB6898@dhcp22.suse.cz>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-4-git-send-email-hannes@cmpxchg.org>
 <20121213154346.GF21644@dhcp22.suse.cz>
 <20121213193820.GC6317@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121213193820.GC6317@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 13-12-12 14:38:20, Johannes Weiner wrote:
> On Thu, Dec 13, 2012 at 04:43:46PM +0100, Michal Hocko wrote:
> > On Wed 12-12-12 16:43:35, Johannes Weiner wrote:
> > > In certain cases (kswapd reclaim, memcg target reclaim), a fixed
> > > minimum amount of pages is scanned from the LRU lists on each
> > > iteration, to make progress.
> > > 
> > > Do not make this minimum bigger than the respective LRU list size,
> > > however, and save some busy work trying to isolate and reclaim pages
> > > that are not there.
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > Hmm, shrink_lruvec would do:
> > 	nr_to_scan = min_t(unsigned long,
> > 			   nr[lru], SWAP_CLUSTER_MAX);
> > 	nr[lru] -= nr_to_scan;
> > and isolate_lru_pages does
> > 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++)
> > so it shouldn't matter and we shouldn't do any additional loops, right?
> > 
> > Anyway it would be beter if get_scan_count wouldn't ask for more than is
> > available.
> 
> Consider the inactive_list_is_low() check (especially expensive for
> memcg anon), lru_add_drain(), lru lock acquisition...

Ohh, I totally missed that. Thanks for pointing out (maybe s/some busy
wok/$WITH_ALL_THIS/)?

Thanks for clarification!

> And as I wrote to Mel in the other email, this can happen a lot when
> you have memory cgroups in a multi-node environment.
> 
> > Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 
> Thanks!
> 
> > > @@ -1748,15 +1748,17 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
> > >  out:
> > >  	for_each_evictable_lru(lru) {
> > >  		int file = is_file_lru(lru);
> > > +		unsigned long size;
> > >  		unsigned long scan;
> > >  
> > > -		scan = get_lru_size(lruvec, lru);
> > > +		size = get_lru_size(lruvec, lru);
> > +		size = scan = get_lru_size(lruvec, lru);
> > 
> > >  		if (sc->priority || noswap) {
> > > -			scan >>= sc->priority;
> > > +			scan = size >> sc->priority;
> > >  			if (!scan && force_scan)
> > > -				scan = SWAP_CLUSTER_MAX;
> > > +				scan = min(size, SWAP_CLUSTER_MAX);
> > >  			scan = div64_u64(scan * fraction[file], denominator);
> > > -		}
> > > +		} else
> > > +			scan = size;
> > 
> > And this is not necessary then but this is totally nit.
> 
> Do you actually find this more readable?  Setting size = scan and then
> later scan = size >> sc->priority? :-)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
