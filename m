Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFA09000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:26:56 -0400 (EDT)
Date: Tue, 26 Apr 2011 15:26:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 13/13] mm: Account for the number of times direct
 reclaimers get throttled
Message-ID: <20110426142650.GI4658@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
 <1303803414-5937-14-git-send-email-mgorman@suse.de>
 <20110426223510.4c6ab3cc@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110426223510.4c6ab3cc@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Apr 26, 2011 at 10:35:10PM +1000, NeilBrown wrote:
> On Tue, 26 Apr 2011 08:36:54 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Under significant pressure when writing back to network-backed storage,
> > direct reclaimers may get throttled. This is expected to be a
> > short-lived event and the processes get woken up again but processes do
> > get stalled. This patch counts how many times such stalling occurs. It's
> > up to the administrator whether to reduce these stalls by increasing
> > min_free_kbytes.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  include/linux/vm_event_item.h |    1 +
> >  mm/vmscan.c                   |    1 +
> >  mm/vmstat.c                   |    1 +
> >  3 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> > index 03b90cdc..652e5f3 100644
> > --- a/include/linux/vm_event_item.h
> > +++ b/include/linux/vm_event_item.h
> > @@ -29,6 +29,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> >  		FOR_ALL_ZONES(PGSTEAL),
> >  		FOR_ALL_ZONES(PGSCAN_KSWAPD),
> >  		FOR_ALL_ZONES(PGSCAN_DIRECT),
> > +		PGSCAN_DIRECT_THROTTLE,
> >  #ifdef CONFIG_NUMA
> >  		PGSCAN_ZONE_RECLAIM_FAILED,
> >  #endif
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 8b6da2b..e88138b 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2154,6 +2154,7 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> >  		goto out;
> >  
> >  	/* Throttle */
> > +	count_vm_event(PGSCAN_DIRECT_THROTTLE);
> >  	do {
> >  		schedule();
> >  		finish_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait);
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index a2b7344..5725387 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -911,6 +911,7 @@ const char * const vmstat_text[] = {
> >  	TEXTS_FOR_ZONES("pgsteal")
> >  	TEXTS_FOR_ZONES("pgscan_kswapd")
> >  	TEXTS_FOR_ZONES("pgscan_direct")
> > +	"pgscan_direct_throttle",
> >  
> >  #ifdef CONFIG_NUMA
> >  	"zone_reclaim_failed",
> 
> I like this approach.  Make the information available, but don't make a fuss
> about it.
> 
> Actually, I like the whole series - I'm really having to dig deep to find
> anything to complain about :-)
> 
> Feel free to put
>    Reviewed-by: NeilBrown <neilb@suse.de>
> against anything that I haven't commented on.
> 

Thanks very much!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
