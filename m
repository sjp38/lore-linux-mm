Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 133516B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 04:27:28 -0400 (EDT)
Received: by wigg3 with SMTP id g3so69142026wig.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 01:27:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fr3si17047262wic.113.2015.06.15.01.27.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 01:27:26 -0700 (PDT)
Date: Mon, 15 Jun 2015 09:27:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/25] mm, vmscan: Make kswapd think of reclaim in terms
 of nodes
Message-ID: <20150615082720.GM26425@suse.de>
References: <00ea01d0a4de$19f165d0$4dd43170$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <00ea01d0a4de$19f165d0$4dd43170$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Fri, Jun 12, 2015 at 03:05:00PM +0800, Hillf Danton wrote:
> > -	/* Reclaim above the high watermark. */
> > -	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
> > +	/* Aim to reclaim above all the zone high watermarks */
> > +	for (z = 0; z <= end_zone; z++) {
> > +		zone = pgdat->node_zones + end_zone;
> s/end_zone/z/ ?

Ouch, thanks!

With this bug, kswapd would reclaim based on a multiple of the highest
zone. Whether that was under or over reclaim would depend on the size of
that zone relative to lower zones.

> > +		nr_to_reclaim += high_wmark_pages(zone);
> > 
> [...]
> > @@ -3280,13 +3177,26 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >  			compact_pgdat(pgdat, order);
> > 
> >  		/*
> > +		 * Stop reclaiming if any eligible zone is balanced and clear
> > +		 * node writeback or congested.
> > +		 */
> > +		for (i = 0; i <= *classzone_idx; i++) {
> > +			zone = pgdat->node_zones + i;
> > +
> > +			if (zone_balanced(zone, sc.order, 0, *classzone_idx)) {
> > +				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> > +				clear_bit(PGDAT_DIRTY, &pgdat->flags);
> > +				break;
> s/break/goto out/ ?

Yes. It'd actually be ok because it'll detect the same condition and
exit in the next outer loop but goto out is better.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
