Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 646986B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 05:11:37 -0400 (EDT)
Date: Tue, 9 Jun 2009 10:42:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when
	zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Message-ID: <20090609094231.GM18380@csn.ul.ie>
References: <20090609143211.DD64.A69D9226@jp.fujitsu.com> <20090609081821.GE18380@csn.ul.ie> <20090609173011.DD7F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090609173011.DD7F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 05:45:02PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > > > @@ -1192,6 +1192,15 @@ static struct ctl_table vm_table[] = {
> > > >  		.extra1		= &zero,
> > > >  	},
> > > >  	{
> > > > +		.ctl_name       = CTL_UNNUMBERED,
> > > > +		.procname       = "zone_reclaim_interval",
> > > > +		.data           = &zone_reclaim_interval,
> > > > +		.maxlen         = sizeof(zone_reclaim_interval),
> > > > +		.mode           = 0644,
> > > > +		.proc_handler   = &proc_dointvec_jiffies,
> > > > +		.strategy       = &sysctl_jiffies,
> > > > +	},
> > > 
> > > hmmm, I think nobody can know proper interval settings on his own systems.
> > > I agree with Wu. It can be hidden.
> > > 
> > 
> > For the few users that case, I expect the majority of those will choose
> > either 0 or the default value of 30. They might want to alter this while
> > setting zone_reclaim_mode if they don't understand the different values
> > it can have for example.
> > 
> > My preference would be that this not exist at all but the
> > scan-avoidance-heuristic has to be perfect to allow that.
> 
> Ah, I didn't concern interval==0. thanks.
> I can ack this now, but please add documentation about interval==0 meaning?
> 

I will.

> 
> 
> 
> > > > @@ -2414,6 +2426,16 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > > >  	ret = __zone_reclaim(zone, gfp_mask, order);
> > > >  	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
> > > >  
> > > > +	if (!ret) {
> > > > +		/*
> > > > +		 * We were unable to reclaim enough pages to stay on node and
> > > > +		 * unable to detect in advance that the scan would fail. Allow
> > > > +		 * off node accesses for zone_reclaim_inteval jiffies before
> > > > +		 * trying zone_reclaim() again
> > > > +		 */
> > > > +		zone->zone_reclaim_failure = jiffies;
> > > 
> > > Oops, this simple assignment don't care jiffies round-trip.
> > > 
> > 
> > Here it is just recording the jiffies value. The real smarts with the counter
> > use time_before() which I assumed could handle jiffie wrap-arounds. Even
> > if it doesn't, the consequence is that one scan will occur that could have
> > been avoided around the time of the jiffie wraparound. The value will then
> > be reset and it will be fine.
> 
> time_before() assume two argument are enough nearly time.
> if we use 32bit cpu and HZ=1000, about jiffies wraparound about one month.
> 
> Then, 
> 
> 1. zone reclaim failure occur
> 2. system works fine for one month
> 3. jiffies wrap and time_before() makes mis-calculation.
> 

And the scan occurs uselessly and zone_reclaim_failure gets set again.
I believe the one useless scan is not significant enough to warrent dealing
with jiffie wraparound.

> I think.
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
