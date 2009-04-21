Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2197C6B0055
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:49:15 -0400 (EDT)
Date: Tue, 21 Apr 2009 10:49:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 07/25] Check in advance if the zonelist needs
	additional filtering
Message-ID: <20090421094957.GM12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-8-git-send-email-mel@csn.ul.ie> <1240298472.771.29.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240298472.771.29.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 10:21:12AM +0300, Pekka Enberg wrote:
> Hi Mel,
> 
> On Mon, 2009-04-20 at 23:19 +0100, Mel Gorman wrote:
> > Zonelist are filtered based on nodemasks for memory policies normally.
> > It can be additionally filters on cpusets if they exist as well as
> > noting when zones are full. These simple checks are expensive enough to
> > be noticed in profiles. This patch checks in advance if zonelist
> > filtering will ever be needed. If not, then the bulk of the checks are
> > skipped.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > @@ -1401,6 +1405,7 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
> >  	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
> >  	int zlc_active = 0;		/* set if using zonelist_cache */
> >  	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
> > +	int zonelist_filter = 0;
> >  
> >  	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
> >  							&preferred_zone);
> > @@ -1411,6 +1416,10 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
> >  
> >  	VM_BUG_ON(order >= MAX_ORDER);
> >  
> > +	/* Determine in advance if the zonelist needs filtering */
> > +	if ((alloc_flags & ALLOC_CPUSET) && unlikely(number_of_cpusets > 1))
> > +		zonelist_filter = 1;
> > +
> >  zonelist_scan:
> >  	/*
> >  	 * Scan zonelist, looking for a zone with enough free.
> > @@ -1418,12 +1427,16 @@ zonelist_scan:
> >  	 */
> >  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> >  						high_zoneidx, nodemask) {
> > -		if (NUMA_BUILD && zlc_active &&
> > -			!zlc_zone_worth_trying(zonelist, z, allowednodes))
> > -				continue;
> > -		if ((alloc_flags & ALLOC_CPUSET) &&
> > -			!cpuset_zone_allowed_softwall(zone, gfp_mask))
> > -				goto try_next_zone;
> > +
> > +		/* Ignore the additional zonelist filter checks if possible */
> > +		if (zonelist_filter) {
> > +			if (NUMA_BUILD && zlc_active &&
> > +				!zlc_zone_worth_trying(zonelist, z, allowednodes))
> > +					continue;
> > +			if ((alloc_flags & ALLOC_CPUSET) &&
> 
> The above expression is always true here because of the earlier
> zonelists_filter check, no?
> 

Yeah, silly. I've dropped the patch altogether though because it was
avoiding zonelist filtering for the wrong reasons.

> > +				!cpuset_zone_allowed_softwall(zone, gfp_mask))
> > +					goto try_next_zone;
> > +		}
> >  
> >  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
> >  			unsigned long mark;
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
