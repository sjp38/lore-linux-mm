Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 518E16B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 11:50:48 -0400 (EDT)
Date: Thu, 21 Mar 2013 16:50:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 04/10] mm: vmscan: Decide whether to compact the pgdat
 based on reclaim progress
Message-ID: <20130321155045.GS6094@dhcp22.suse.cz>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-5-git-send-email-mgorman@suse.de>
 <20130321153231.GP6094@dhcp22.suse.cz>
 <20130321154730.GK1878@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130321154730.GK1878@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 21-03-13 15:47:31, Mel Gorman wrote:
> On Thu, Mar 21, 2013 at 04:32:31PM +0100, Michal Hocko wrote:
> > On Sun 17-03-13 13:04:10, Mel Gorman wrote:
> > > In the past, kswapd makes a decision on whether to compact memory after the
> > > pgdat was considered balanced. This more or less worked but it is late to
> > > make such a decision and does not fit well now that kswapd makes a decision
> > > whether to exit the zone scanning loop depending on reclaim progress.
> > > 
> > > This patch will compact a pgdat if at least  the requested number of pages
> > > were reclaimed from unbalanced zones for a given priority. If any zone is
> > > currently balanced, kswapd will not call compaction as it is expected the
> > > necessary pages are already available.
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > ---
> > >  mm/vmscan.c | 52 +++++++++++++++++++++-------------------------------
> > >  1 file changed, 21 insertions(+), 31 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 279d0c2..7513bd1 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2694,8 +2694,11 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> > >  
> > >  	do {
> > >  		unsigned long lru_pages = 0;
> > > +		unsigned long nr_to_reclaim = 0;
> > >  		unsigned long nr_reclaimed = sc.nr_reclaimed;
> > > +		unsigned long this_reclaimed;
> > >  		bool raise_priority = true;
> > > +		bool pgdat_needs_compaction = true;
> > 
> > I am confused. We don't want to compact for order == 0, do we?
> > 
> 
> No, but an order check is made later which I felt it was clearer.  You are
> the second person to bring it up so I'll base the initialisation on order.

Dohh. Yes compact_pgdat is called only if order != 0. I was so focused
on pgdat_needs_compaction that I've missed it. Both checks use (order &&
pgdat_needs_compaction) so initialization based on order would be
probably better for readability.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
