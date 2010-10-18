Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 194E96B00B3
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 00:15:15 -0400 (EDT)
Date: Mon, 18 Oct 2010 15:14:59 +1100
From: Neil Brown <neilb@suse.de>
Subject: Re: Deadlock possibly caused by too_many_isolated.
Message-ID: <20101018151459.2b443221@notabene>
In-Reply-To: <20100915184434.18e2d933@notabene>
References: <20100915091118.3dbdc961@notabene>
	<4C90139A.1080809@redhat.com>
	<20100915122334.3fa7b35f@notabene>
	<20100915082843.GA17252@localhost>
	<20100915184434.18e2d933@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010 18:44:34 +1000
Neil Brown <neilb@suse.de> wrote:

> On Wed, 15 Sep 2010 16:28:43 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Neil,
> > 
> > Sorry for the rushed and imaginary ideas this morning..
> > 
> > > @@ -1101,6 +1101,12 @@ static unsigned long shrink_inactive_lis
> > >  	int lumpy_reclaim = 0;
> > >  
> > >  	while (unlikely(too_many_isolated(zone, file, sc))) {
> > > +		if ((sc->gfp_mask & GFP_IOFS) != GFP_IOFS)
> > > +			/* Not allowed to do IO, so mustn't wait
> > > +			 * on processes that might try to
> > > +			 */
> > > +			return SWAP_CLUSTER_MAX;
> > > +
> > 
> > The above patch should behavior like this: it returns SWAP_CLUSTER_MAX
> > to cheat all the way up to believe "enough pages have been reclaimed".
> > So __alloc_pages_direct_reclaim() see non-zero *did_some_progress and
> > go on to call get_page_from_freelist(). That normally fails because
> > the task didn't really scanned the LRU lists. However it does have the
> > possibility to succeed -- when so many processes are doing concurrent
> > direct reclaims, it may luckily get one free page reclaimed by other
> > tasks. What's more, if it does fail to get a free page, the upper
> > layer __alloc_pages_slowpath() will be repeat recalling
> > __alloc_pages_direct_reclaim(). So, sooner or later it will succeed in
> > "stealing" a free page reclaimed by other tasks.
> > 
> > In summary, the patch behavior for !__GFP_IO/FS is
> > - won't do any page reclaim
> > - won't fail the page allocation (unexpected)
> > - will wait and steal one free page from others (unreasonable)
> > 
> > So it will address the problem you encountered, however it sounds
> > pretty unexpected and illogical behavior, right?
> > 
> > I believe this patch will address the problem equally well.
> > What do you think?
> 
> Thank you for the detailed explanation.  Is agree with your reasoning and
> now understand why your patch is sufficient.
> 
> I will get it tested and let you know how that goes.

(sorry this has taken a month to follow up).

Testing shows that this patch seems to work.
The test load (essentially kernbench) doesn't deadlock any more, though it
does get bogged down thrashing in swap so it doesn't make a lot more
progress :-)  I guess that is to be expected.

One observation is that the kernbench generated 10%-20% more context switches
with the patch than without.  Is that to be expected?

Do you have plans for sending this patch upstream?

Thanks,
NeilBrown


> 
> Thanks,
> NeilBrown
> 
> 
> > 
> > Thanks,
> > Fengguang
> > ---
> > 
> > mm: Avoid possible deadlock caused by too_many_isolated()
> > 
> > Neil finds that if too_many_isolated() returns true while performing
> > direct reclaim we can end up waiting for other threads to complete their
> > direct reclaim.  If those threads are allowed to enter the FS or IO to
> > free memory, but this thread is not, then it is possible that those
> > threads will be waiting on this thread and so we get a circular
> > deadlock.
> > 
> > some task enters direct reclaim with GFP_KERNEL
> >   => too_many_isolated() false
> >     => vmscan and run into dirty pages
> >       => pageout()
> >         => take some FS lock
> > 	  => fs/block code does GFP_NOIO allocation
> > 	    => enter direct reclaim again
> > 	      => too_many_isolated() true
> > 		=> waiting for others to progress, however the other
> > 		   tasks may be circular waiting for the FS lock..
> > 
> > The fix is to let !__GFP_IO and !__GFP_FS direct reclaims enjoy higher
> > priority than normal ones, by honouring them higher throttle threshold.
> > 
> > Now !__GFP_IO/FS reclaims won't be waiting for __GFP_IO/FS reclaims to
> > progress. They will be blocked only when there are too many concurrent
> > !__GFP_IO/FS reclaims, however that's very unlikely because the IO-less
> > direct reclaims is able to progress much more faster, and they won't
> > deadlock each other. The threshold is raised high enough for them, so
> > that there can be sufficient parallel progress of !__GFP_IO/FS reclaims.
> > 
> > Reported-by: NeilBrown <neilb@suse.de>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  mm/vmscan.c |    5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > --- linux-next.orig/mm/vmscan.c	2010-09-15 11:58:58.000000000 +0800
> > +++ linux-next/mm/vmscan.c	2010-09-15 15:36:14.000000000 +0800
> > @@ -1141,36 +1141,39 @@ int isolate_lru_page(struct page *page)
> >  	return ret;
> >  }
> >  
> >  /*
> >   * Are there way too many processes in the direct reclaim path already?
> >   */
> >  static int too_many_isolated(struct zone *zone, int file,
> >  		struct scan_control *sc)
> >  {
> >  	unsigned long inactive, isolated;
> > +	int ratio;
> >  
> >  	if (current_is_kswapd())
> >  		return 0;
> >  
> >  	if (!scanning_global_lru(sc))
> >  		return 0;
> >  
> >  	if (file) {
> >  		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> >  		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
> >  	} else {
> >  		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
> >  		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
> >  	}
> >  
> > -	return isolated > inactive;
> > +	ratio = sc->gfp_mask & (__GFP_IO | __GFP_FS) ? 1 : 8;
> > +
> > +	return isolated > inactive * ratio;
> >  }
> >  
> >  /*
> >   * TODO: Try merging with migrations version of putback_lru_pages
> >   */
> >  static noinline_for_stack void
> >  putback_lru_pages(struct zone *zone, struct scan_control *sc,
> >  				unsigned long nr_anon, unsigned long nr_file,
> >  				struct list_head *page_list)
> >  {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
