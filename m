Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D93E26B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 13:17:45 -0500 (EST)
Date: Fri, 13 Nov 2009 18:17:40 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] vmscan: Have kswapd sleep for a short interval and
	double check it should be asleep
Message-ID: <20091113181740.GN29804@csn.ul.ie>
References: <20091113142558.33B6.A69D9226@jp.fujitsu.com> <20091113141303.GI29804@csn.ul.ie> <20091114023901.3DA8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091114023901.3DA8.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Nov 14, 2009 at 03:00:57AM +0900, KOSAKI Motohiro wrote:
> > On Fri, Nov 13, 2009 at 07:43:09PM +0900, KOSAKI Motohiro wrote:
> > > > After kswapd balances all zones in a pgdat, it goes to sleep. In the event
> > > > of no IO congestion, kswapd can go to sleep very shortly after the high
> > > > watermark was reached. If there are a constant stream of allocations from
> > > > parallel processes, it can mean that kswapd went to sleep too quickly and
> > > > the high watermark is not being maintained for sufficient length time.
> > > > 
> > > > This patch makes kswapd go to sleep as a two-stage process. It first
> > > > tries to sleep for HZ/10. If it is woken up by another process or the
> > > > high watermark is no longer met, it's considered a premature sleep and
> > > > kswapd continues work. Otherwise it goes fully to sleep.
> > > > 
> > > > This adds more counters to distinguish between fast and slow breaches of
> > > > watermarks. A "fast" premature sleep is one where the low watermark was
> > > > hit in a very short time after kswapd going to sleep. A "slow" premature
> > > > sleep indicates that the high watermark was breached after a very short
> > > > interval.
> > > > 
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > 
> > > Why do you submit this patch to mainline? this is debugging patch
> > > no more and no less.
> > > 
> > 
> > Do you mean the stats part? The stats are included until such time as the page
> > allocator failure reports stop or are significantly reduced. In the event a
> > report is received, the value of the counters help determine if kswapd was
> > struggling or not. They should be removed once this mess is ironed out.
> > 
> > If there is a preference, I can split out the stats part and send it to
> > people with page allocator failure reports for retesting.
> 
> I'm sorry my last mail didn't have enough explanation.
> This stats help to solve this issue. I agreed. but after solving this issue,
> I don't imagine administrator how to use this stats. if KSWAPD_PREMATURE_FAST or
> KSWAPD_PREMATURE_SLOW significantly increased, what should admin do?

One possible workaround would be to raise min_free_kbytes while a fix is
being worked on.

> Or, Can LKML folk make any advise to admin?
> 

Work with them to fix the bug :/

> if kernel doesn't have any bug, kswapd wakeup rate is not so worth information imho.
> following your additional code itself looks good to me. but...
> 
> 
> > ==== CUT HERE ====
> > vmscan: Have kswapd sleep for a short interval and double check it should be asleep fix 1
> > 
> > This patch is a fix and a claritifacation to the patch "vmscan: Have
> > kswapd sleep for a short interval and double check it should be asleep".
> > The fix is for kswapd to only check zones in the node it is responsible
> > for. The clarification is to rename two counters to better explain what is
> > being counted.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > --- 
> >  include/linux/vmstat.h |    2 +-
> >  mm/vmscan.c            |   20 +++++++++++++-------
> >  mm/vmstat.c            |    4 ++--
> >  3 files changed, 16 insertions(+), 10 deletions(-)
> > 
> > diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> > index 7d66695..0591a48 100644
> > --- a/include/linux/vmstat.h
> > +++ b/include/linux/vmstat.h
> > @@ -40,7 +40,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> >  		PGSCAN_ZONE_RECLAIM_FAILED,
> >  #endif
> >  		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
> > -		KSWAPD_PREMATURE_FAST, KSWAPD_PREMATURE_SLOW,
> > +		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
> >  		KSWAPD_NO_CONGESTION_WAIT,
> >  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> >  #ifdef CONFIG_HUGETLB_PAGE
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 70967e1..5557555 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1905,19 +1905,25 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> >  #endif
> >  
> >  /* is kswapd sleeping prematurely? */
> > -static int sleeping_prematurely(int order, long remaining)
> > +static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> >  {
> > -	struct zone *zone;
> > +	int i;
> >  
> >  	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
> >  	if (remaining)
> >  		return 1;
> >  
> >  	/* If after HZ/10, a zone is below the high mark, it's premature */
> > -	for_each_populated_zone(zone)
> > +	for (i = 0; i < pgdat->nr_zones; i++) {
> > +		struct zone *zone = pgdat->node_zones + i;
> > +
> > +		if (!populated_zone(zone))
> > +			continue;
> > +
> >  		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
> >  								0, 0))
> >  			return 1;
> > +	}
> >  
> >  	return 0;
> >  }
> > @@ -2221,7 +2227,7 @@ static int kswapd(void *p)
> >  				long remaining = 0;
> >  
> >  				/* Try to sleep for a short interval */
> > -				if (!sleeping_prematurely(order, remaining)) {
> > +				if (!sleeping_prematurely(pgdat, order, remaining)) {
> >  					remaining = schedule_timeout(HZ/10);
> >  					finish_wait(&pgdat->kswapd_wait, &wait);
> >  					prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > @@ -2232,13 +2238,13 @@ static int kswapd(void *p)
> >  				 * premature sleep. If not, then go fully
> >  				 * to sleep until explicitly woken up
> >  				 */
> > -				if (!sleeping_prematurely(order, remaining))
> > +				if (!sleeping_prematurely(pgdat, order, remaining))
> >  					schedule();
> >  				else {
> >  					if (remaining)
> > -						count_vm_event(KSWAPD_PREMATURE_FAST);
> > +						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> >  					else
> > -						count_vm_event(KSWAPD_PREMATURE_SLOW);
> > +						count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> >  				}
> >  			}
> >  
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index bc09547..6cc8dc6 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -683,8 +683,8 @@ static const char * const vmstat_text[] = {
> >  	"slabs_scanned",
> >  	"kswapd_steal",
> >  	"kswapd_inodesteal",
> > -	"kswapd_slept_prematurely_fast",
> > -	"kswapd_slept_prematurely_slow",
> > +	"kswapd_low_wmark_hit_quickly",
> > +	"kswapd_high_wmark_hit_quickly",
> >  	"kswapd_no_congestion_wait",
> >  	"pageoutrun",
> >  	"allocstall",
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
