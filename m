Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 133D68D000B
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 05:49:20 -0400 (EDT)
Date: Thu, 28 Oct 2010 10:49:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
	threshold when memory is low
Message-ID: <20101028094903.GC4896@csn.ul.ie>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie> <1288169256-7174-2-git-send-email-mel@csn.ul.ie> <20101028100920.5d4ce413.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101028100920.5d4ce413.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2010 at 10:09:20AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 27 Oct 2010 09:47:35 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Commit [aa45484: calculate a better estimate of NR_FREE_PAGES when
> > memory is low] noted that watermarks were based on the vmstat
> > NR_FREE_PAGES. To avoid synchronization overhead, these counters are
> > maintained on a per-cpu basis and drained both periodically and when a
> > threshold is above a threshold. On large CPU systems, the difference
> > between the estimate and real value of NR_FREE_PAGES can be very high.
> > The system can get into a case where pages are allocated far below the
> > min watermark potentially causing livelock issues. The commit solved the
> > problem by taking a better reading of NR_FREE_PAGES when memory was low.
> > 
> > <SNIP>
> > 
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 355a9e6..cafcc2d 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -81,6 +81,12 @@ EXPORT_SYMBOL(vm_stat);
> >  
> >  #ifdef CONFIG_SMP
> >  
> > +static int calculate_pressure_threshold(struct zone *zone)
> > +{
> > +	return max(1, (int)((high_wmark_pages(zone) - low_wmark_pages(zone) /
> > +				num_online_cpus())));
> > +}
> > +
> 
> Could you add background theory of this calculation as a comment to
> show the difference with calculate_threshold() ?
> 

Sure. When writing it, I realised that the calculations here differ from
what percpu_drift_mark does. This is what I currently have

int calculate_pressure_threshold(struct zone *zone)
{
        int threshold;
        int watermark_distance;

        /*
         * As vmstats are not up to date, there is drift between the estimated
         * and real values. For high thresholds and a high number of CPUs, it
         * is possible for the min watermark to be breached while the estimated
         * value looks fine. The pressure threshold is a reduced value such
         * that even the maximum amount of drift will not accidentally breach
         * the min watermark
         */
        watermark_distance = low_wmark_pages(zone) - min_wmark_pages(zone);
        threshold = max(1, watermark_distance / num_online_cpus());

        /*
         * Maximum threshold is 125
         */
        threshold = min(125, threshold);

        return threshold;
}

Is this better?

> And don't we need to have "max=125" thresh here ?
> 

Yes.

> 
> >  static int calculate_threshold(struct zone *zone)
> >  {
> >  	int threshold;
> > @@ -159,6 +165,44 @@ static void refresh_zone_stat_thresholds(void)
> >  	}
> >  }
> >  
> > +void reduce_pgdat_percpu_threshold(pg_data_t *pgdat)
> > +{
> > +	struct zone *zone;
> > +	int cpu;
> > +	int threshold;
> > +	int i;
> > +
> 
> get_online_cpus();
> 

Also correct.

Thanks very much. I'm revising the series.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
