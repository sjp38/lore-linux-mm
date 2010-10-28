Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 750E18D000B
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 06:04:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9SA4D27014721
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 Oct 2010 19:04:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1A46326A88
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 19:04:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1373345DE64
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 19:04:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DEA6F1DB8038
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 19:04:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 24765E38004
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 19:04:06 +0900 (JST)
Date: Thu, 28 Oct 2010 18:58:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
Message-Id: <20101028185839.4b951bdb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101028094903.GC4896@csn.ul.ie>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie>
	<1288169256-7174-2-git-send-email-mel@csn.ul.ie>
	<20101028100920.5d4ce413.kamezawa.hiroyu@jp.fujitsu.com>
	<20101028094903.GC4896@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Oct 2010 10:49:03 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Thu, Oct 28, 2010 at 10:09:20AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 27 Oct 2010 09:47:35 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > Commit [aa45484: calculate a better estimate of NR_FREE_PAGES when
> > > memory is low] noted that watermarks were based on the vmstat
> > > NR_FREE_PAGES. To avoid synchronization overhead, these counters are
> > > maintained on a per-cpu basis and drained both periodically and when a
> > > threshold is above a threshold. On large CPU systems, the difference
> > > between the estimate and real value of NR_FREE_PAGES can be very high.
> > > The system can get into a case where pages are allocated far below the
> > > min watermark potentially causing livelock issues. The commit solved the
> > > problem by taking a better reading of NR_FREE_PAGES when memory was low.
> > > 
> > > <SNIP>
> > > 
> > > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > > index 355a9e6..cafcc2d 100644
> > > --- a/mm/vmstat.c
> > > +++ b/mm/vmstat.c
> > > @@ -81,6 +81,12 @@ EXPORT_SYMBOL(vm_stat);
> > >  
> > >  #ifdef CONFIG_SMP
> > >  
> > > +static int calculate_pressure_threshold(struct zone *zone)
> > > +{
> > > +	return max(1, (int)((high_wmark_pages(zone) - low_wmark_pages(zone) /
> > > +				num_online_cpus())));
> > > +}
> > > +
> > 
> > Could you add background theory of this calculation as a comment to
> > show the difference with calculate_threshold() ?
> > 
> 
> Sure. When writing it, I realised that the calculations here differ from
> what percpu_drift_mark does. This is what I currently have
> 
> int calculate_pressure_threshold(struct zone *zone)
> {
>         int threshold;
>         int watermark_distance;
> 
>         /*
>          * As vmstats are not up to date, there is drift between the estimated
>          * and real values. For high thresholds and a high number of CPUs, it
>          * is possible for the min watermark to be breached while the estimated
>          * value looks fine. The pressure threshold is a reduced value such
>          * that even the maximum amount of drift will not accidentally breach
>          * the min watermark
>          */
>         watermark_distance = low_wmark_pages(zone) - min_wmark_pages(zone);
>         threshold = max(1, watermark_distance / num_online_cpus());
> 
>         /*
>          * Maximum threshold is 125
>          */
>         threshold = min(125, threshold);
> 
>         return threshold;
> }
> 
> Is this better?
> 

sounds nice.

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
