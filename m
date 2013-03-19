Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id EDCD06B003D
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 06:27:04 -0400 (EDT)
Date: Tue, 19 Mar 2013 10:27:00 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/10] mm: vmscan: Decide whether to compact the pgdat
 based on reclaim progress
Message-ID: <20130319102700.GF2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-5-git-send-email-mgorman@suse.de>
 <CAJd=RBCZ7VZUB=Wc6tMtVsszFgnbfW3MbBW3wKyMqnLMV+UrWw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBCZ7VZUB=Wc6tMtVsszFgnbfW3MbBW3wKyMqnLMV+UrWw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Mi@jasper.es, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 18, 2013 at 07:35:04PM +0800, Hillf Danton wrote:
> On Sun, Mar 17, 2013 at 9:04 PM, Mel Gorman <mgorman@suse.de> wrote:
> > In the past, kswapd makes a decision on whether to compact memory after the
> > pgdat was considered balanced. This more or less worked but it is late to
> > make such a decision and does not fit well now that kswapd makes a decision
> > whether to exit the zone scanning loop depending on reclaim progress.
> >
> > This patch will compact a pgdat if at least  the requested number of pages
> > were reclaimed from unbalanced zones for a given priority. If any zone is
> > currently balanced, kswapd will not call compaction as it is expected the
> > necessary pages are already available.
> >
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/vmscan.c | 52 +++++++++++++++++++++-------------------------------
> >  1 file changed, 21 insertions(+), 31 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 279d0c2..7513bd1 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2694,8 +2694,11 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >
> >         do {
> >                 unsigned long lru_pages = 0;
> > +               unsigned long nr_to_reclaim = 0;
> >                 unsigned long nr_reclaimed = sc.nr_reclaimed;
> > +               unsigned long this_reclaimed;
> >                 bool raise_priority = true;
> > +               bool pgdat_needs_compaction = true;
> 
> To show that compaction is needed iff non order-o reclaim,
>                 bool do_compaction = !!order;
> 

An order check is already made where relevant. It could be part of how
pgdat_needs_compaction gets initialised but I did not think it helped
readability.

> >
> >                 /*
> >                  * Scan in the highmem->dma direction for the highest
> > @@ -2743,7 +2746,17 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >                 for (i = 0; i <= end_zone; i++) {
> >                         struct zone *zone = pgdat->node_zones + i;
> >
> > +                       if (!populated_zone(zone))
> > +                               continue;
> > +
> >                         lru_pages += zone_reclaimable_pages(zone);
> > +
> > +                       /* Check if the memory needs to be defragmented */
> Enrich the comment with, say,
> /*If any zone is
> currently balanced, kswapd will not call compaction as it is expected the
> necessary pages are already available.*/
> please since a big one is deleted below.
> 

Ok, done.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
