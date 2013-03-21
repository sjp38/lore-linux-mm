Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id CECC66B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 08:59:41 -0400 (EDT)
Date: Thu, 21 Mar 2013 13:59:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd
 reclaims at each priority
Message-ID: <20130321125939.GK6094@dhcp22.suse.cz>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-2-git-send-email-mgorman@suse.de>
 <20130320161847.GD27375@dhcp22.suse.cz>
 <20130321094713.GD1878@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130321094713.GD1878@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 21-03-13 09:47:13, Mel Gorman wrote:
> On Wed, Mar 20, 2013 at 05:18:47PM +0100, Michal Hocko wrote:
> > On Sun 17-03-13 13:04:07, Mel Gorman wrote:
> > [...]
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 88c5fed..4835a7a 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2593,6 +2593,32 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
> > >  }
> > >  
> > >  /*
> > > + * kswapd shrinks the zone by the number of pages required to reach
> > > + * the high watermark.
> > > + */
> > > +static void kswapd_shrink_zone(struct zone *zone,
> > > +			       struct scan_control *sc,
> > > +			       unsigned long lru_pages)
> > > +{
> > > +	unsigned long nr_slab;
> > > +	struct reclaim_state *reclaim_state = current->reclaim_state;
> > > +	struct shrink_control shrink = {
> > > +		.gfp_mask = sc->gfp_mask,
> > > +	};
> > > +
> > > +	/* Reclaim above the high watermark. */
> > > +	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
> > 
> > OK, so the cap is at high watermark which sounds OK to me, although I
> > would expect balance_gap being considered here. Is it not used
> > intentionally or you just wanted to have a reasonable upper bound?
> > 
> 
> It's intentional. The balance_gap is taken into account before the
> decision to shrink but not afterwards. As the watermark check after
> shrinking is based on just the high watermark, I decided to have
> shrink_zone reclaim on that basis.

OK, it makes sense. Thanks both you and Rik for clarification.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
