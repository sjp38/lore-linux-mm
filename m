Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 337476B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 09:58:16 -0400 (EDT)
Date: Tue, 9 Jun 2009 15:38:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v4] zone_reclaim is always 0 by default
Message-ID: <20090609143826.GS18380@csn.ul.ie>
References: <20090604192236.9761.A69D9226@jp.fujitsu.com> <20090608115048.GA15070@csn.ul.ie> <20090609211721.DD9A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090609211721.DD9A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robin Holt <holt@sgi.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 10:48:34PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> sorry for late responce. my e-mail reading speed is very slow ;-)
> 
> First, Could you please read past thread?
> I think many topic of this mail are already discussed.
> 

I think I caught them all but the horrible fact of the matter is that
whether zone_reclaim_mode should be 1 or 0 on NUMA machines is "it depends".
There are arguements for both and no clear winner.

> 
> > On Thu, Jun 04, 2009 at 07:23:15PM +0900, KOSAKI Motohiro wrote:
> > > 
> > > Current linux policy is, zone_reclaim_mode is enabled by default if the machine
> > > has large remote node distance. it's because we could assume that large distance
> > > mean large server until recently.
> > > 
> > 
> > We don't make assumptions about the server being large, small or otherwise. The
> > affinity tables reporting a distance of 20 or more is saying "remote memory
> > has twice the latency of local memory". This is true irrespective of workload
> > and implies that going off-node has a real penalty regardless of workload.
> 
> No.
> Now, we talk about off-node allocation vs unnecessary file cache dropping.
> IOW, off-node allocation vs disk access.
> 

Even if we used GFP flags to identify the file pages, there is no guarantee
that we are taking the correct action to keep "relevant" pages in memory.

> Then, the worth doesn't only depend on off-node distance, but also depend on
> workload IO tendency and IO speed.
> 
> Fujitsu has 64 core ia64 HPC box, zone-reclaim sometimes made performance
> degression although its box. 
> 

I bet if it was 0, that the off-node accesses would somewtimes make
"performance degression" as well :(

> So, I don't think this problem is small vs large machine issue.
> nor i7 issue.
> high-speed P2P CPU integrated memory controller expose old issue.
> 
> 
> > > In general, workload depended configration shouldn't put into default settings.
> > > 
> > > However, current code is long standing about two year. Highest POWER and IA64 HPC machine
> > > (only) use this setting.
> > > 
> > > Thus, x86 and almost rest architecture change default setting, but Only power and ia64
> > > remain current configuration for backward-compatibility.
> > > 
> > 
> > What about if it's x86-64-based NUMA but it's not i7 based. There, the
> > NUMA distances might really mean something and that zone_reclaim behaviour
> > is desirable.
> 
> hmmm..
> I don't hope ignore AMD, I think it's common characterastic of P2P and
> integrated memory controller machine.
> 
> Also, I don't hope detect CPU family or similar, because we need update
> such code evey when Intel makes new cpu.
> 
> Can we detect P2P interconnect machine? I'm not sure.
> 

I've no idea. It's not just I7 because some of the AMD chips will have
integrated memory controllers as well. We were somewhat depending on the
affinity information providing the necessary information.

> > I think if we're going down the road of setting the default, it shouldn't be
> > per-architecture defaults as such. Other choices for addressing this might be;
> > 
> > 1. Make RECLAIM_DISTANCE a variable on x86. Set it to 20 by default, and 5
> >    (or some other sensible figure) on i7
> > 
> > 2. There should be a per-arch modifier callback for the affinity
> >    distances. If the x86 code detects the CPU is an i7, it can reduce the
> >    reported latencies to be more in line with expected reality.
> > 
> > 3. Do not use zone_reclaim() for file-backed data if more than 20% of memory
> >    overall is free. The difficulty is figuring out if the allocation is for
> >    file pages.
> > 
> > 4. Change zone_reclaim_mode default to mean "do your best to figure it
> >    out". Patch 1 would default large distances to 1 to see what happens.
> >    Then apply a heuristic when in figure-it-out mode and using reclaim_mode == 1
> > 
> > 	If we have locally reclaimed 2% of the nodes memory in file pages
> > 	within the last 5 seconds when >= 20% of total physical memory was
> > 	free, then set the reclaim_mode to 0 on the assumption the node is
> > 	mostly caching pages and shouldn't be reclaimed to avoid excessive IO
> > 
> > Option 1 would appear to be the most straight-forward but option 2
> > should be doable. Option 3 and 4 could turn into a rats nest and I would
> > consider those approaches a bit more drastic.
> 
> hmhm. 
> I think the key-point of option 1 and 2 are proper hardware detecting way.
> 
> option 3 and 4 are more prefere idea to me. I like workload adapted heuristic.
> but you already pointed out its hard, because page-allocator don't know
> allocation purpose ;)
> 

Option 3 may be undoable. Even if the allocations are tagged as "this is
a file-backed allocation", we have no way of detecting how important
that is to the overall workload. Option 4 would be the preference. It's
a heuristic that might let us down, but the administrator can override
it and fix the reclaim_mode in the event we get it wrong.

> 
> > > @@ -10,6 +10,12 @@ struct device_node;
> > >  
> > >  #include <asm/mmzone.h>
> > >  
> > > +/*
> > > + * Distance above which we begin to use zone reclaim
> > > + */
> > > +#define RECLAIM_DISTANCE 20
> > > +
> > > +
> > 
> > Where is the ia-64-specific modifier to RECAIM_DISTANCE?
> 
> 
> arch/ia64/include/asm/topology.h has
> 
> 	/*
> 	 * Distance above which we begin to use zone reclaim
> 	 */
> 	#define RECLAIM_DISTANCE 15
> 
> 
> I don't think distance==15 is machine independent proper definition.
> but there is long lived definition ;)
> 
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
