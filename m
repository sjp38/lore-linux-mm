Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59183828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 20:14:51 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j185so251111871ith.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 17:14:51 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 126si2505371itr.33.2016.07.05.17.14.50
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 17:14:50 -0700 (PDT)
Date: Wed, 6 Jul 2016 09:15:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 01/31] mm, vmstat: add infrastructure for per-node vmstats
Message-ID: <20160706001540.GB12570@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-2-git-send-email-mgorman@techsingularity.net>
 <20160704235018.GA26749@bbox>
 <20160705081405.GE11498@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <20160705081405.GE11498@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 05, 2016 at 09:14:05AM +0100, Mel Gorman wrote:
> On Tue, Jul 05, 2016 at 08:50:18AM +0900, Minchan Kim wrote:
> > > @@ -172,13 +174,17 @@ void refresh_zone_stat_thresholds(void)
> > >  	int threshold;
> > >  
> > >  	for_each_populated_zone(zone) {
> > > +		struct pglist_data *pgdat = zone->zone_pgdat;
> > >  		unsigned long max_drift, tolerate_drift;
> > >  
> > >  		threshold = calculate_normal_threshold(zone);
> > >  
> > > -		for_each_online_cpu(cpu)
> > > +		for_each_online_cpu(cpu) {
> > >  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> > >  							= threshold;
> > > +			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
> > > +							= threshold;
> > > +		}
> > 
> > I didn't see other patches yet so it might fix it then.
> > 
> > per_cpu_nodestats is per node not zone but it use per-zone threshold
> > and even overwritten by next zones. I don't think it's not intended.
> 
> It was intended that the threshold from one zone would be used but now
> that you point it out, it would use the threshold for the smallest zone
> in the node which is sub-optimal. I applied the patch below on top to
> use the threshold from the largest zone. I considered using the sum of
> all thresholds but feared it might allow too much per-cpu drift. It can
> be switched to the sum if we find a case where vmstat updates are too
> high.

Fair enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
