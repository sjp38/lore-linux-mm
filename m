Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 89ADA6B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 11:07:58 -0400 (EDT)
Date: Thu, 21 Mar 2013 16:07:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning
 requirements for kswapd
Message-ID: <20130321150755.GN6094@dhcp22.suse.cz>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-3-git-send-email-mgorman@suse.de>
 <20130321140154.GL6094@dhcp22.suse.cz>
 <20130321143114.GM2055@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130321143114.GM2055@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 21-03-13 14:31:15, Mel Gorman wrote:
> On Thu, Mar 21, 2013 at 03:01:54PM +0100, Michal Hocko wrote:
> > On Sun 17-03-13 13:04:08, Mel Gorman wrote:
> > > Simplistically, the anon and file LRU lists are scanned proportionally
> > > depending on the value of vm.swappiness although there are other factors
> > > taken into account by get_scan_count().  The patch "mm: vmscan: Limit
> > > the number of pages kswapd reclaims" limits the number of pages kswapd
> > > reclaims but it breaks this proportional scanning and may evenly shrink
> > > anon/file LRUs regardless of vm.swappiness.
> > > 
> > > This patch preserves the proportional scanning and reclaim. It does mean
> > > that kswapd will reclaim more than requested but the number of pages will
> > > be related to the high watermark.
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > ---
> > >  mm/vmscan.c | 52 +++++++++++++++++++++++++++++++++++++++++-----------
> > >  1 file changed, 41 insertions(+), 11 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 4835a7a..182ff15 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -1815,6 +1815,45 @@ out:
> > >  	}
> > >  }
> > >  
> > > +static void recalculate_scan_count(unsigned long nr_reclaimed,
> > > +		unsigned long nr_to_reclaim,
> > > +		unsigned long nr[NR_LRU_LISTS])
> > > +{
> > > +	enum lru_list l;
> > > +
> > > +	/*
> > > +	 * For direct reclaim, reclaim the number of pages requested. Less
> > > +	 * care is taken to ensure that scanning for each LRU is properly
> > > +	 * proportional. This is unfortunate and is improper aging but
> > > +	 * minimises the amount of time a process is stalled.
> > > +	 */
> > > +	if (!current_is_kswapd()) {
> > > +		if (nr_reclaimed >= nr_to_reclaim) {
> > > +			for_each_evictable_lru(l)
> > > +				nr[l] = 0;
> > > +		}
> > > +		return;
> > 
> > Heh, this is nicely cryptically said what could be done in shrink_lruvec
> > as
> > 	if (!current_is_kswapd()) {
> > 		if (nr_reclaimed >= nr_to_reclaim)
> > 			break;
> > 	}
> > 
> 
> Pretty much. At one point during development, this function was more
> complex and it evolved into this without me rechecking if splitting it
> out still made sense.
> 
> > Besides that this is not memcg aware which I think it would break
> > targeted reclaim which is kind of direct reclaim but it still would be
> > good to stay proportional because it starts with DEF_PRIORITY.
> > 
> 
> This does break memcg because it's a special sort of direct reclaim.
> 
> > I would suggest moving this back to shrink_lruvec and update the test as
> > follows:
> 
> I also noticed that we check whether the scan counts need to be
> normalised more than once

I didn't mind this because it "disqualified" at least one LRU every
round which sounds reasonable to me because all LRUs would be scanned
proportionally. E.g. if swappiness is 0 then nr[anon] would be 0 and
then the active/inactive aging would break? Or am I missing something?

> and this reshuffling checks nr_reclaimed twice. How about this?
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 182ff15..320a2f4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1815,45 +1815,6 @@ out:
>  	}
>  }
>  
> -static void recalculate_scan_count(unsigned long nr_reclaimed,
> -		unsigned long nr_to_reclaim,
> -		unsigned long nr[NR_LRU_LISTS])
> -{
> -	enum lru_list l;
> -
> -	/*
> -	 * For direct reclaim, reclaim the number of pages requested. Less
> -	 * care is taken to ensure that scanning for each LRU is properly
> -	 * proportional. This is unfortunate and is improper aging but
> -	 * minimises the amount of time a process is stalled.
> -	 */
> -	if (!current_is_kswapd()) {
> -		if (nr_reclaimed >= nr_to_reclaim) {
> -			for_each_evictable_lru(l)
> -				nr[l] = 0;
> -		}
> -		return;
> -	}
> -
> -	/*
> -	 * For kswapd, reclaim at least the number of pages requested.
> -	 * However, ensure that LRUs shrink by the proportion requested
> -	 * by get_scan_count() so vm.swappiness is obeyed.
> -	 */
> -	if (nr_reclaimed >= nr_to_reclaim) {
> -		unsigned long min = ULONG_MAX;
> -
> -		/* Find the LRU with the fewest pages to reclaim */
> -		for_each_evictable_lru(l)
> -			if (nr[l] < min)
> -				min = nr[l];
> -
> -		/* Normalise the scan counts so kswapd scans proportionally */
> -		for_each_evictable_lru(l)
> -			nr[l] -= min;
> -	}
> -}
> -
>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>   */
> @@ -1864,7 +1825,9 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  	enum lru_list lru;
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> +	unsigned long min;
>  	struct blk_plug plug;
> +	bool scan_adjusted = false;
>  
>  	get_scan_count(lruvec, sc, nr);
>  
> @@ -1881,7 +1844,33 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  			}
>  		}
>  
> -		recalculate_scan_count(nr_reclaimed, nr_to_reclaim, nr);
> +		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> +			continue;
> +
> +		/*
> +		 * For global direct reclaim, reclaim only the number of pages
> +		 * requested. Less care is taken to scan proportionally as it
> +		 * is more important to minimise direct reclaim stall latency
> +		 * than it is to properly age the LRU lists.
> +		 */
> +		if (global_reclaim(sc) && !current_is_kswapd())
> +			break;
> +
> +		/*
> +		 * For kswapd and memcg, reclaim at least the number of pages
> +		 * requested. However, ensure that LRUs shrink by the
> +		 * proportion requested by get_scan_count() so vm.swappiness
> +		 * is obeyed. Find the smallest LRU list and normalise the
> +		 * scan counts so the fewest number of pages are reclaimed
> +		 * while still maintaining proportionality.
> +		 */
> +		min = ULONG_MAX;
> +		for_each_evictable_lru(lru)
> +			if (nr[lru] < min)
> +				min = nr[lru];
> +		for_each_evictable_lru(lru)
> +			nr[lru] -= min;
> +		scan_adjusted = true;
>  	}
>  	blk_finish_plug(&plug);
>  	sc->nr_reclaimed += nr_reclaimed;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
