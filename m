Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1696B013D
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 15:41:24 -0400 (EDT)
Date: Fri, 29 Oct 2010 12:40:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
Message-Id: <20101029124002.356bd592.akpm@linux-foundation.org>
In-Reply-To: <20101029101210.GG4896@csn.ul.ie>
References: <1288278816-32667-1-git-send-email-mel@csn.ul.ie>
	<1288278816-32667-2-git-send-email-mel@csn.ul.ie>
	<20101028150433.fe4f2d77.akpm@linux-foundation.org>
	<20101029101210.GG4896@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 11:12:11 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Thu, Oct 28, 2010 at 03:04:33PM -0700, Andrew Morton wrote:
> > On Thu, 28 Oct 2010 16:13:35 +0100
> 
> > 
> > I have a feeling this problem will bite us again perhaps due to those
> > other callsites, but we haven't found the workload yet.
> > 
> > I don't undestand why restore/reduce_pgdat_percpu_threshold() were
> > called around that particular sleep in kswapd and nowhere else.
> > 
> > > vanilla                      11.6615%
> > > disable-threshold            0.2584%
> > 
> > Wow.  That's 12% of all CPUs?  How many CPUs and what workload?
> > 
> 
> 112 threads CPUs 14 sockets. Workload initialisation creates NR_CPU sparse
> files that are 10*TOTAL_MEMORY/NR_CPU in size. Workload itself is NR_CPU
> processes just reading their own file.
> 
> The critical thing is the number of sockets. For single-socket-8-thread
> for example, vanilla was just 0.66% of time (although the patches did
> bring it down to 0.11%).

I'm surprised.  I thought the inefficiency here was caused by CPUs
tromping through percpu data, adding things up.  But the above info
would indicate that the problem was caused by lots of cross-socket
traffic?  If so, where did that come from?

> ...
>
> Follow-on patch?

Sometime, please.

> > >
> > > ...
> > >
> > >  				if (!sleeping_prematurely(pgdat, order, remaining)) {
> > >  					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > > +					restore_pgdat_percpu_threshold(pgdat);
> > >  					schedule();
> > > +					reduce_pgdat_percpu_threshold(pgdat);
> > 
> > We could do with some code comments here explaining what's going on.
> > 
> 
> Follow-on patch?
> 
> > >  				} else {
> > >  					if (remaining)
> > >  						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> > >
> > > ...
> > >
> > > +static int calculate_pressure_threshold(struct zone *zone)
> > > +{
> > > +	int threshold;
> > > +	int watermark_distance;
> > > +
> > > +	/*
> > > +	 * As vmstats are not up to date, there is drift between the estimated
> > > +	 * and real values. For high thresholds and a high number of CPUs, it
> > > +	 * is possible for the min watermark to be breached while the estimated
> > > +	 * value looks fine. The pressure threshold is a reduced value such
> > > +	 * that even the maximum amount of drift will not accidentally breach
> > > +	 * the min watermark
> > > +	 */
> > > +	watermark_distance = low_wmark_pages(zone) - min_wmark_pages(zone);
> > > +	threshold = max(1, (int)(watermark_distance / num_online_cpus()));
> > > +
> > > +	/*
> > > +	 * Maximum threshold is 125
> > 
> > Reasoning?
> > 
> 
> To match the existing maximum which I assume is due to the deltas being
> stored in a s8.

hm, OK.  So (CHAR_MAX-2) would be a tad clearer, only there's no
CHAR_MAX and "2" remains mysterious ;)

I do go on about code comments a lot lately.  Eric D's kernel just
crashed because we didn't adequately comment first_zones_zonelist()
so I'm feeling all vindicated!

>
> > Given that ->stat_threshold is the same for each CPU, why store it for
> > each CPU at all?  Why not put it in the zone and eliminate the inner
> > loop?
> > 
> 
> I asked why we couldn't move the threshold to struct zone and Christoph
> responded;
> 
> "If you move it then the cache footprint of the vm stat functions (which
> need to access the threshold for each access!) will increase and the
> performance sink dramatically. I tried to avoid placing the threshold
> there when I developed that approach but it always caused a dramatic
> regression under heavy load."

I don't really buy that.  The cache footprint will be increased by a
max of one cacheline (for zone->stat_threshold) and the cache footprint
will be actually reduced in the much larger percpu area (depending on
alignment and padding and stuff).

I'm suspecting something went wrong here, perhaps zone->stat_threshold
shared a cacheline with something unfortunate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
