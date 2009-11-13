Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F07286B006A
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 08:54:50 -0500 (EST)
Date: Fri, 13 Nov 2009 13:54:43 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/5] vmscan: Take order into consideration when
	deciding if kswapd is in trouble
Message-ID: <20091113135443.GF29804@csn.ul.ie>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie> <1258054235-3208-6-git-send-email-mel@csn.ul.ie> <20091113142608.33B9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091113142608.33B9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 06:54:29PM +0900, KOSAKI Motohiro wrote:
> > If reclaim fails to make sufficient progress, the priority is raised.
> > Once the priority is higher, kswapd starts waiting on congestion.
> > However, on systems with large numbers of high-order atomics due to
> > crappy network cards, it's important that kswapd keep working in
> > parallel to save their sorry ass.
> > 
> > This patch takes into account the order kswapd is reclaiming at before
> > waiting on congestion. The higher the order, the longer it is before
> > kswapd considers itself to be in trouble. The impact is that kswapd
> > works harder in parallel rather than depending on direct reclaimers or
> > atomic allocations to fail.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/vmscan.c |   14 ++++++++++++--
> >  1 files changed, 12 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ffa1766..5e200f1 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1946,7 +1946,7 @@ static int sleeping_prematurely(int order, long remaining)
> >  static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
> >  {
> >  	int all_zones_ok;
> > -	int priority;
> > +	int priority, congestion_priority;
> >  	int i;
> >  	unsigned long total_scanned;
> >  	struct reclaim_state *reclaim_state = current->reclaim_state;
> > @@ -1967,6 +1967,16 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
> >  	 */
> >  	int temp_priority[MAX_NR_ZONES];
> >  
> > +	/*
> > +	 * When priority reaches congestion_priority, kswapd will sleep
> > +	 * for a short time while congestion clears. The higher the
> > +	 * order being reclaimed, the less likely kswapd will go to
> > +	 * sleep as high-order allocations are harder to reclaim and
> > +	 * stall direct reclaimers longer
> > +	 */
> > +	congestion_priority = DEF_PRIORITY - 2;
> > +	congestion_priority -= min(congestion_priority, sc.order);
> 
> This calculation mean
> 
> 	sc.order	congestion_priority	scan-pages
> 	---------------------------------------------------------
> 	0		10			1/1024 * zone-mem
> 	1		9			1/512  * zone-mem
> 	2		8			1/256  * zone-mem
> 	3		7			1/128  * zone-mem
> 	4		6			1/64   * zone-mem
> 	5		5			1/32   * zone-mem
> 	6		4			1/16   * zone-mem
> 	7		3			1/8    * zone-mem
> 	8		2			1/4    * zone-mem
> 	9		1			1/2    * zone-mem
> 	10		0			1      * zone-mem
> 	11+		0			1      * zone-mem
> 
> I feel this is too agressive. The intention of this congestion_wait()
> is to prevent kswapd use 100% cpu time.

Ok, I thought the intention might be to avoid dumping too many pages on
the queue but it was already waiting on congestion elsewhere.

> but the above promotion seems
> break it.
> 
> example,
> ia64 have 256MB hugepage (i.e. order=14). it mean kswapd never sleep.
> 
> example2,
> order-3 (i.e. PAGE_ALLOC_COSTLY_ORDER) makes one of most inefficent
> reclaim, because it doesn't use lumpy recliam.
> I've seen 128GB size zone, it mean 1/128 = 1GB. oh well, kswapd definitely
> waste cpu time 100%.
> 
> 
> > +
> >  loop_again:
> >  	total_scanned = 0;
> >  	sc.nr_reclaimed = 0;
> > @@ -2092,7 +2102,7 @@ loop_again:
> >  		 * OK, kswapd is getting into trouble.  Take a nap, then take
> >  		 * another pass across the zones.
> >  		 */
> > -		if (total_scanned && priority < DEF_PRIORITY - 2)
> > +		if (total_scanned && priority < congestion_priority)
> >  			congestion_wait(BLK_RW_ASYNC, HZ/10);
> 
> Instead, How about this?
> 

This makes a lot of sense. Tests look good and I added stats to make sure
the logic was triggering. On X86, kswapd avoided a congestion_wait 11723
times and X86-64 avoided it 5084 times. I think we should hold onto the
stats temporarily until all these bugs are ironed out.

Would you like to sign off the following?

If you are ok to sign off, this patch should replace my patch 5 in
the series.

==== CUT HERE ====

vmscan: Stop kswapd waiting on congestion when the min watermark is not being met

If reclaim fails to make sufficient progress, the priority is raised.
Once the priority is higher, kswapd starts waiting on congestion.  However,
if the zone is below the min watermark then kswapd needs to continue working
without delay as there is a danger of an increased rate of GFP_ATOMIC
allocation failure.

This patch changes the conditions under which kswapd waits on
congestion by only going to sleep if the min watermarks are being met.

[mel@csn.ul.ie: Add stats to track how relevant the logic is]
Needs-signed-off-by-original-author

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 9716003..7d66695 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -41,6 +41,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
 		KSWAPD_PREMATURE_FAST, KSWAPD_PREMATURE_SLOW,
+		KSWAPD_NO_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ffa1766..70967e1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1966,6 +1966,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 	 * free_pages == high_wmark_pages(zone).
 	 */
 	int temp_priority[MAX_NR_ZONES];
+	int has_under_min_watermark_zone = 0;
 
 loop_again:
 	total_scanned = 0;
@@ -2085,6 +2086,15 @@ loop_again:
 			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
+
+			/*
+			 * We are still under min water mark. it mean we have
+			 * GFP_ATOMIC allocation failure risk. Hurry up!
+			 */
+			if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
+					      end_zone, 0))
+				has_under_min_watermark_zone = 1;
+
 		}
 		if (all_zones_ok)
 			break;		/* kswapd: all done */
@@ -2092,8 +2102,13 @@ loop_again:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
-		if (total_scanned && priority < DEF_PRIORITY - 2)
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+		if (total_scanned && (priority < DEF_PRIORITY - 2)) {
+
+			if (!has_under_min_watermark_zone)
+				count_vm_event(KSWAPD_NO_CONGESTION_WAIT);
+			else
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+		}
 
 		/*
 		 * We do this so kswapd doesn't build up large priorities for
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 90b11e4..bc09547 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -685,6 +685,7 @@ static const char * const vmstat_text[] = {
 	"kswapd_inodesteal",
 	"kswapd_slept_prematurely_fast",
 	"kswapd_slept_prematurely_slow",
+	"kswapd_no_congestion_wait",
 	"pageoutrun",
 	"allocstall",
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
