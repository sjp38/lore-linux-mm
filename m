Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25A7A6B0078
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 09:02:12 -0400 (EDT)
Date: Tue, 21 Sep 2010 05:58:14 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 0/3] Reduce watermark-related problems with
 the per-cpu	allocator V4
Message-ID: <20100921125814.GF1205@kroah.com>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie>
 <20100903160551.05db4a92.akpm@linux-foundation.org>
 <20100921111741.GB11439@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100921111741.GB11439@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, stable@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 21, 2010 at 12:17:41PM +0100, Mel Gorman wrote:
> On Fri, Sep 03, 2010 at 04:05:51PM -0700, Andrew Morton wrote:
> > On Fri,  3 Sep 2010 10:08:43 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > The noteworthy change is to patch 2 which now uses the generic
> > > zone_page_state_snapshot() in zone_nr_free_pages(). Similar logic still
> > > applies for *when* zone_page_state_snapshot() to avoid ovedhead.
> > > 
> > > Changelog since V3
> > >   o Use generic helper for NR_FREE_PAGES estimate when necessary
> > > 
> > > Changelog since V2
> > >   o Minor clarifications
> > >   o Rebase to 2.6.36-rc3
> > > 
> > > Changelog since V1
> > >   o Fix for !CONFIG_SMP
> > >   o Correct spelling mistakes
> > >   o Clarify a ChangeLog
> > >   o Only check for counter drift on machines large enough for the counter
> > >     drift to breach the min watermark when NR_FREE_PAGES report the low
> > >     watermark is fine
> > > 
> > > Internal IBM test teams beta testing distribution kernels have reported
> > > problems on machines with a large number of CPUs whereby page allocator
> > > failure messages show huge differences between the nr_free_pages vmstat
> > > counter and what is available on the buddy lists. In an extreme example,
> > > nr_free_pages was above the min watermark but zero pages were on the buddy
> > > lists allowing the system to potentially livelock unable to make forward
> > > progress unless an allocation succeeds. There is no reason why the problems
> > > would not affect mainline so the following series mitigates the problems
> > > in the page allocator related to to per-cpu counter drift and lists.
> > > 
> > > The first patch ensures that counters are updated after pages are added to
> > > free lists.
> > > 
> > > The second patch notes that the counter drift between nr_free_pages and what
> > > is on the per-cpu lists can be very high. When memory is low and kswapd
> > > is awake, the per-cpu counters are checked as well as reading the value
> > > of NR_FREE_PAGES. This will slow the page allocator when memory is low and
> > > kswapd is awake but it will be much harder to breach the min watermark and
> > > potentially livelock the system.
> > > 
> > > The third patch notes that after direct-reclaim an allocation can
> > > fail because the necessary pages are on the per-cpu lists. After a
> > > direct-reclaim-and-allocation-failure, the per-cpu lists are drained and
> > > a second attempt is made.
> > > 
> > > Performance tests against 2.6.36-rc3 did not show up anything interesting. A
> > > version of this series that continually called vmstat_update() when
> > > memory was low was tested internally and found to help the counter drift
> > > problem. I described this during LSF/MM Summit and the potential for IPI
> > > storms was frowned upon. An alternative fix is in patch two which uses
> > > for_each_online_cpu() to read the vmstat deltas while memory is low and
> > > kswapd is awake. This should be functionally similar.
> > > 
> > > This patch should be merged after the patch "vmstat : update
> > > zone stat threshold at onlining a cpu" which is in mmotm as
> > > vmstat-update-zone-stat-threshold-when-onlining-a-cpu.patch .
> > > 
> > > If we can agree on it, this series is a stable candidate.
> > 
> > (cc stable@kernel.org)
> > 
> > >  include/linux/mmzone.h |   13 +++++++++++++
> > >  include/linux/vmstat.h |   22 ++++++++++++++++++++++
> > >  mm/mmzone.c            |   21 +++++++++++++++++++++
> > >  mm/page_alloc.c        |   29 +++++++++++++++++++++--------
> > >  mm/vmstat.c            |   15 ++++++++++++++-
> > >  5 files changed, 91 insertions(+), 9 deletions(-)
> > 
> > For the entire patch series I get
> > 
> >  include/linux/mmzone.h |   13 +++++++++++++
> >  include/linux/vmstat.h |   22 ++++++++++++++++++++++
> >  mm/mmzone.c            |   21 +++++++++++++++++++++
> >  mm/page_alloc.c        |   33 +++++++++++++++++++++++----------
> >  mm/vmstat.c            |   16 +++++++++++++++-
> >  5 files changed, 94 insertions(+), 11 deletions(-)
> > 
> > The patches do apply OK to 2.6.35.
> > 
> > Give the extent and the coreness of it all, it's a bit more than I'd
> > usually push at the -stable guys.  But I guess that if the patches fix
> > all the issues you've noted, as well as David's "minute-long livelocks
> > in memory reclaim" then yup, it's worth backporting it all.
> > 
> 
> These patches have made it to mainline as the following commits.
> 
> 9ee493c mm: page allocator: drain per-cpu lists after direct reclaim allocation fails
> aa45484 mm: page allocator: calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
> 72853e2 mm: page allocator: update free page counters after pages are placed on the free list
> 
> I have not heard from the -stable guys, is there a reasonable
> expectation that they'll be picked up?

If you ask me, then I'll know to give a response :)

None of these were tagged as going to the stable tree, should I include
them?  If so, for which -stable tree?  .27, .32, and .35 are all
currently active.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
