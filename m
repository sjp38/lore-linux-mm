Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B406F6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 01:51:11 -0400 (EDT)
Date: Wed, 31 Mar 2010 13:51:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100331055108.GA21963@localhost>
References: <20100330150453.8E9F.A69D9226@jp.fujitsu.com> <20100331045348.GA3396@sli10-desk.sh.intel.com> <20100331142708.039E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100331142708.039E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Li, Shaohua" <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KOSAKI-san,

On Wed, Mar 31, 2010 at 01:38:12PM +0800, KOSAKI Motohiro wrote:
> > On Tue, Mar 30, 2010 at 02:08:53PM +0800, KOSAKI Motohiro wrote:
> > > Hi
> > > 
> > > > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > > > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > > > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > > > value, but our calculation round it to zero. The commit makes vmscan
> > > > completely skip anon pages and cause oops.
> > > > An option is if percent[x] is zero in get_scan_ratio(), forces it
> > > > to 1. See below patch.
> > > > But the offending commit still changes behavior. Without the commit, we scan
> > > > all pages if priority is zero, below patch doesn't fix this. Don't know if
> > > > It's required to fix this too.
> > > 
> > > Can you please post your /proc/meminfo and reproduce program? I'll digg it.
> > > 
> > > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > > had similar logic, but 1% swap-out made lots bug reports. 
> > if 1% is still big, how about below patch?
> 
> This patch makes a lot of sense than previous. however I think <1% anon ratio
> shouldn't happen anyway because file lru doesn't have reclaimable pages.
> <1% seems no good reclaim rate.
> 
> perhaps I'll take your patch for stable tree. but we need to attack the root
> cause. iow, I guess we need to fix scan ratio equation itself.

I tend to regard this patch as a general improvement for both
.33-stable and .34. 

I do agree with you that it's desirable to do more test&analyze and
check further for possibly hidden problems.

Thanks,
Fengguang


> 
> 
> > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > value, but our calculation round it to zero. The commit makes vmscan
> > completely skip anon pages and cause oops.
> > To avoid underflow, we don't use percentage, instead we directly calculate
> > how many pages should be scaned.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 79c8098..80a7ed5 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1519,27 +1519,50 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
> >  }
> >  
> >  /*
> > + * Smallish @nr_to_scan's are deposited in @nr_saved_scan,
> > + * until we collected @swap_cluster_max pages to scan.
> > + */
> > +static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
> > +				       unsigned long *nr_saved_scan)
> > +{
> > +	unsigned long nr;
> > +
> > +	*nr_saved_scan += nr_to_scan;
> > +	nr = *nr_saved_scan;
> > +
> > +	if (nr >= SWAP_CLUSTER_MAX)
> > +		*nr_saved_scan = 0;
> > +	else
> > +		nr = 0;
> > +
> > +	return nr;
> > +}
> > +
> > +/*
> >   * Determine how aggressively the anon and file LRU lists should be
> >   * scanned.  The relative value of each set of LRU lists is determined
> >   * by looking at the fraction of the pages scanned we did rotate back
> >   * onto the active list instead of evict.
> >   *
> > - * percent[0] specifies how much pressure to put on ram/swap backed
> > - * memory, while percent[1] determines pressure on the file LRUs.
> > + * nr[x] specifies how many pages should be scaned
> >   */
> > -static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
> > -					unsigned long *percent)
> > +static void get_scan_count(struct zone *zone, struct scan_control *sc,
> > +				unsigned long *nr, int priority)
> >  {
> >  	unsigned long anon, file, free;
> >  	unsigned long anon_prio, file_prio;
> >  	unsigned long ap, fp;
> >  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> > +	unsigned long fraction[2], denominator[2];
> > +	enum lru_list l;
> >  
> >  	/* If we have no swap space, do not bother scanning anon pages. */
> >  	if (!sc->may_swap || (nr_swap_pages <= 0)) {
> > -		percent[0] = 0;
> > -		percent[1] = 100;
> > -		return;
> > +		fraction[0] = 0;
> > +		denominator[0] = 1;
> > +		fraction[1] = 1;
> > +		denominator[1] = 1;
> > +		goto out;
> >  	}
> >  
> >  	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
> > @@ -1552,9 +1575,11 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
> >  		/* If we have very few page cache pages,
> >  		   force-scan anon pages. */
> >  		if (unlikely(file + free <= high_wmark_pages(zone))) {
> > -			percent[0] = 100;
> > -			percent[1] = 0;
> > -			return;
> > +			fraction[0] = 1;
> > +			denominator[0] = 1;
> > +			fraction[1] = 0;
> > +			denominator[1] = 1;
> > +			goto out;
> >  		}
> >  	}
> >  
> > @@ -1601,29 +1626,29 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
> >  	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
> >  	fp /= reclaim_stat->recent_rotated[1] + 1;
> >  
> > -	/* Normalize to percentages */
> > -	percent[0] = 100 * ap / (ap + fp + 1);
> > -	percent[1] = 100 - percent[0];
> > -}
> > -
> > -/*
> > - * Smallish @nr_to_scan's are deposited in @nr_saved_scan,
> > - * until we collected @swap_cluster_max pages to scan.
> > - */
> > -static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
> > -				       unsigned long *nr_saved_scan)
> > -{
> > -	unsigned long nr;
> > +	fraction[0] = ap;
> > +	denominator[0] = ap + fp + 1;
> > +	fraction[1] = fp;
> > +	denominator[1] = ap + fp + 1;
> >  
> > -	*nr_saved_scan += nr_to_scan;
> > -	nr = *nr_saved_scan;
> > +out:
> > +	for_each_evictable_lru(l) {
> > +		int file = is_file_lru(l);
> > +		unsigned long scan;
> >  
> > -	if (nr >= SWAP_CLUSTER_MAX)
> > -		*nr_saved_scan = 0;
> > -	else
> > -		nr = 0;
> > +		if (fraction[file] == 0) {
> > +			nr[l] = 0;
> > +			continue;
> > +		}
> >  
> > -	return nr;
> > +		scan = zone_nr_lru_pages(zone, sc, l);
> > +		if (priority) {
> > +			scan >>= priority;
> > +			scan = (scan * fraction[file] / denominator[file]);
> > +		}
> > +		nr[l] = nr_scan_try_batch(scan,
> > +					  &reclaim_stat->nr_saved_scan[l]);
> > +	}
> >  }
> >  
> >  /*
> > @@ -1634,31 +1659,11 @@ static void shrink_zone(int priority, struct zone *zone,
> >  {
> >  	unsigned long nr[NR_LRU_LISTS];
> >  	unsigned long nr_to_scan;
> > -	unsigned long percent[2];	/* anon @ 0; file @ 1 */
> >  	enum lru_list l;
> >  	unsigned long nr_reclaimed = sc->nr_reclaimed;
> >  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> > -	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> > -
> > -	get_scan_ratio(zone, sc, percent);
> >  
> > -	for_each_evictable_lru(l) {
> > -		int file = is_file_lru(l);
> > -		unsigned long scan;
> > -
> > -		if (percent[file] == 0) {
> > -			nr[l] = 0;
> > -			continue;
> > -		}
> > -
> > -		scan = zone_nr_lru_pages(zone, sc, l);
> > -		if (priority) {
> > -			scan >>= priority;
> > -			scan = (scan * percent[file]) / 100;
> > -		}
> > -		nr[l] = nr_scan_try_batch(scan,
> > -					  &reclaim_stat->nr_saved_scan[l]);
> > -	}
> > +	get_scan_count(zone, sc, nr, priority);
> >  
> >  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> >  					nr[LRU_INACTIVE_FILE]) {
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
