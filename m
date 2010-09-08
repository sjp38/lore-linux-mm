Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 138996B0047
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:45:40 -0400 (EDT)
Received: by gyf3 with SMTP id 3so117701gyf.14
        for <linux-mm@kvack.org>; Wed, 08 Sep 2010 08:45:38 -0700 (PDT)
Date: Thu, 9 Sep 2010 00:45:27 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: check all_unreclaimable in direct reclaim path
Message-ID: <20100908154527.GA5936@barrios-desktop>
References: <1283697637-3117-1-git-send-email-minchan.kim@gmail.com>
 <20100908054831.GB20955@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100908054831.GB20955@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 08, 2010 at 07:48:31AM +0200, Johannes Weiner wrote:
> On Sun, Sep 05, 2010 at 11:40:37PM +0900, Minchan Kim wrote:
> > M. Vefa Bicakci reported 2.6.35 kernel hang up when hibernation on his
> > 32bit 3GB mem machine. (https://bugzilla.kernel.org/show_bug.cgi?id=16771)
> > Also he was bisected first bad commit is below
> > 
> >   commit bb21c7ce18eff8e6e7877ca1d06c6db719376e3c
> >   Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >   Date:   Fri Jun 4 14:15:05 2010 -0700
> > 
> >      vmscan: fix do_try_to_free_pages() return value when priority==0 reclaim failure
> > 
> > At first impression, this seemed very strange because the above commit only
> > chenged function return value and hibernate_preallocate_memory() ignore
> > return value of shrink_all_memory(). But it's related.
> > 
> > Now, page allocation from hibernation code may enter infinite loop if
> > the system has highmem. The reasons are that vmscan don't care enough 
> > OOM case when oom_killer_disabled. 
> > 
> > The problem sequence is following as. 
> > 
> > 1. hibernation
> > 2. oom_disable
> > 3. alloc_pages
> > 4. do_try_to_free_pages
> >        if (scanning_global_lru(sc) && !all_unreclaimable)
> >                return 1;
> > 
> > If kswapd is not freezed, it would set zone->all_unreclaimable to 1 and then
> > shrink_zones maybe return true(ie, all_unreclaimable is true). 
> > so at last, alloc_pages could go to _nopage_. If it is, it should have no problem.
> > 
> > This patch adds all_unreclaimable check to protect in direct reclaim path, too.
> > It can care of hibernation OOM case and help bailout all_unreclaimable case slightly.
> > 
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> > Cc: M. Vefa Bicakci <bicave@superonline.com>
> > Cc: stable@kernel.org
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/vmscan.c |   33 +++++++++++++++++++++++++++------
> >  1 files changed, 27 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index f620ab3..53b23a7 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1893,12 +1893,11 @@ static void shrink_zone(int priority, struct zone *zone,
> >   * If a zone is deemed to be full of pinned pages then just give it a light
> >   * scan then give up on it.
> >   */
> > -static bool shrink_zones(int priority, struct zonelist *zonelist,
> > +static void shrink_zones(int priority, struct zonelist *zonelist,
> >  					struct scan_control *sc)
> >  {
> >  	struct zoneref *z;
> >  	struct zone *zone;
> > -	bool all_unreclaimable = true;
> >  
> >  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> >  					gfp_zone(sc->gfp_mask), sc->nodemask) {
> > @@ -1916,8 +1915,31 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
> >  		}
> >  
> >  		shrink_zone(priority, zone, sc);
> > -		all_unreclaimable = false;
> >  	}
> > +}
> > +
> > +static inline bool all_unreclaimable(struct zonelist *zonelist,
> > +		struct scan_control *sc)
> > +{
> > +	struct zoneref *z;
> > +	struct zone *zone;
> > +	bool all_unreclaimable = true;
> > +
> > +	if (!scanning_global_lru(sc))
> > +		return false;
> > +
> > +	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > +			gfp_zone(sc->gfp_mask), sc->nodemask) {
> > +		if (!populated_zone(zone))
> > +			continue;
> > +		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> > +			continue;
> > +		if (zone->pages_scanned < (zone_reclaimable_pages(zone) * 6)) {
> 
> Small nitpick: kswapd does the same check against the magic number,
> could you move it into a separate function?  zone_reclaimable()?

Nice cleanup. 
Thanks, Hannes. 

> 
> Otherwise,
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> 

== CUT HERE ==

Changelog 

v2
 * cleanup zone_reclaimable(suggested by Johannes)
 * rebase on mmotm-08-27
 
