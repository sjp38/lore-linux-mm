Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 41F6B6B03C8
	for <linux-mm@kvack.org>; Wed, 10 May 2017 02:13:18 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g67so5396245wrd.0
        for <linux-mm@kvack.org>; Tue, 09 May 2017 23:13:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si2232819wrd.163.2017.05.09.23.13.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 23:13:15 -0700 (PDT)
Date: Wed, 10 May 2017 08:13:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: scan pages until it founds eligible pages
Message-ID: <20170510061312.GB26158@dhcp22.suse.cz>
References: <1493700038-27091-1-git-send-email-minchan@kernel.org>
 <20170502051452.GA27264@bbox>
 <20170502075432.GC14593@dhcp22.suse.cz>
 <20170502145150.GA19011@bgram>
 <20170502151436.GN14593@dhcp22.suse.cz>
 <20170503044809.GA21619@bgram>
 <20170503060044.GA1236@dhcp22.suse.cz>
 <20170510014654.GA23584@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510014654.GA23584@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 10-05-17 10:46:54, Minchan Kim wrote:
> On Wed, May 03, 2017 at 08:00:44AM +0200, Michal Hocko wrote:
[...]
> > @@ -1486,6 +1486,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  			continue;
> >  		}
> >  
> > +		/*
> > +		 * Do not count skipped pages because we do want to isolate
> > +		 * some pages even when the LRU mostly contains ineligible
> > +		 * pages
> > +		 */
> 
> How about adding comment about "why"?
> 
> /*
>  * Do not count skipped pages because it makes the function to return with
>  * none isolated pages if the LRU mostly contains inelgible pages so that
>  * VM cannot reclaim any pages and trigger premature OOM.
>  */

I am not sure this is necessarily any better. Mentioning a pre-mature
OOM would require a much better explanation because a first immediate
question would be "why don't we scan those pages at priority 0". Also
decision about the OOM is at a different layer and it might change in
future when this doesn't apply any more. But it is not like I would
insist...

> > +		scan++;
> >  		switch (__isolate_lru_page(page, mode)) {
> >  		case 0:
> >  			nr_pages = hpage_nr_pages(page);
> 
> Confirmed.

Hmm. I can clearly see how we could skip over too many pages and hit
small reclaim priorities too quickly but I am still scratching my head
about how we could hit the OOM killer as a result. The amount of pages
on the active anonymous list suggests that we are not able to rotate
pages quickly enough. I have to keep thinking about that.

> It works as expected but it changed scan counter's behavior.  How
> about this?

OK, it looks good to me. I believe the main motivation of the original
patch from Johannes was to drop the magical total_skipped.
 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2314aca47d12..846922d7942e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1469,7 +1469,7 @@ static __always_inline void update_lru_sizes(struct lruvec *lruvec,
>   *
>   * Appropriate locks must be held before calling this function.
>   *
> - * @nr_to_scan:	The number of pages to look through on the list.
> + * @nr_to_scan:	The number of eligible pages to look through on the list.
>   * @lruvec:	The LRU vector to pull pages from.
>   * @dst:	The temp list to put pages on to.
>   * @nr_scanned:	The number of pages that were scanned.
> @@ -1489,11 +1489,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
>  	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
>  	unsigned long skipped = 0;
> -	unsigned long scan, nr_pages;
> +	unsigned long scan, total_scan, nr_pages;
>  	LIST_HEAD(pages_skipped);
>  
> -	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
> -					!list_empty(src); scan++) {
> +	for (total_scan = scan = 0; scan < nr_to_scan &&
> +					nr_taken < nr_to_scan &&
> +					!list_empty(src);
> +					total_scan++) {
>  		struct page *page;
>  
>  		page = lru_to_page(src);
> @@ -1507,6 +1509,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  			continue;
>  		}
>  
> +		/*
> +		 * Do not count skipped pages because it makes the function to
> +		 * return with none isolated pages if the LRU mostly contains
> +		 * inelgible pages so that VM cannot reclaim any pages and
> +		 * trigger premature OOM.
> +		 */
> +		scan++;
>  		switch (__isolate_lru_page(page, mode)) {
>  		case 0:
>  			nr_pages = hpage_nr_pages(page);
> @@ -1544,9 +1553,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  			skipped += nr_skipped[zid];
>  		}
>  	}
> -	*nr_scanned = scan;
> +	*nr_scanned = total_scan;
>  	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
> -				    scan, skipped, nr_taken, mode, lru);
> +				    total_scan, skipped, nr_taken, mode, lru);
>  	update_lru_sizes(lruvec, lru, nr_zone_taken);
>  	return nr_taken;
>  }

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
