Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 04F0B6B00DB
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 12:15:26 -0400 (EDT)
Date: Tue, 19 Oct 2010 00:15:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
Message-ID: <20101018161504.GB29500@localhost>
References: <20100915091118.3dbdc961@notabene>
 <4C90139A.1080809@redhat.com>
 <20100915122334.3fa7b35f@notabene>
 <20100915082843.GA17252@localhost>
 <20100915184434.18e2d933@notabene>
 <20101018151459.2b443221@notabene>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101018151459.2b443221@notabene>
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 18, 2010 at 12:14:59PM +0800, Neil Brown wrote:
> On Wed, 15 Sep 2010 18:44:34 +1000
> Neil Brown <neilb@suse.de> wrote:
> 
> > On Wed, 15 Sep 2010 16:28:43 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > Neil,
> > > 
> > > Sorry for the rushed and imaginary ideas this morning..
> > > 
> > > > @@ -1101,6 +1101,12 @@ static unsigned long shrink_inactive_lis
> > > >  	int lumpy_reclaim = 0;
> > > >  
> > > >  	while (unlikely(too_many_isolated(zone, file, sc))) {
> > > > +		if ((sc->gfp_mask & GFP_IOFS) != GFP_IOFS)
> > > > +			/* Not allowed to do IO, so mustn't wait
> > > > +			 * on processes that might try to
> > > > +			 */
> > > > +			return SWAP_CLUSTER_MAX;
> > > > +
> > > 
> > > The above patch should behavior like this: it returns SWAP_CLUSTER_MAX
> > > to cheat all the way up to believe "enough pages have been reclaimed".
> > > So __alloc_pages_direct_reclaim() see non-zero *did_some_progress and
> > > go on to call get_page_from_freelist(). That normally fails because
> > > the task didn't really scanned the LRU lists. However it does have the
> > > possibility to succeed -- when so many processes are doing concurrent
> > > direct reclaims, it may luckily get one free page reclaimed by other
> > > tasks. What's more, if it does fail to get a free page, the upper
> > > layer __alloc_pages_slowpath() will be repeat recalling
> > > __alloc_pages_direct_reclaim(). So, sooner or later it will succeed in
> > > "stealing" a free page reclaimed by other tasks.
> > > 
> > > In summary, the patch behavior for !__GFP_IO/FS is
> > > - won't do any page reclaim
> > > - won't fail the page allocation (unexpected)
> > > - will wait and steal one free page from others (unreasonable)
> > > 
> > > So it will address the problem you encountered, however it sounds
> > > pretty unexpected and illogical behavior, right?
> > > 
> > > I believe this patch will address the problem equally well.
> > > What do you think?
> > 
> > Thank you for the detailed explanation.  Is agree with your reasoning and
> > now understand why your patch is sufficient.
> > 
> > I will get it tested and let you know how that goes.
> 
> (sorry this has taken a month to follow up).
> 
> Testing shows that this patch seems to work.
> The test load (essentially kernbench) doesn't deadlock any more, though it

Good news, thanks for the test!

> does get bogged down thrashing in swap so it doesn't make a lot more
> progress :-)  I guess that is to be expected.
 
The patch does allow more isolated pages, which may lead to more
pressure on the LRU lists and hence swapping (or vmscan file writes?).

> One observation is that the kernbench generated 10%-20% more context switches
> with the patch than without.  Is that to be expected?

It's total number of context switches? It may be due to the increased
swapping as well.

> Do you have plans for sending this patch upstream?

Would you help try the modified patch? It tries to reduce the number
of isolated pages. Hope it helps reduce the thrashing. I also noticed
that the original patch only covers the GFP_NOIO case and missed GFP_NOFS.

Thanks,
Fengguang
---
Subject: mm: Avoid possible deadlock caused by too_many_isolated()
From: Wu Fengguang <fengguang.wu@intel.com>
Date: Wed Sep 15 15:36:19 CST 2010

Neil find that if too_many_isolated() returns true while performing
direct reclaim we can end up waiting for other threads to complete their
direct reclaim.  If those threads are allowed to enter the FS or IO to
free memory, but this thread is not, then it is possible that those
threads will be waiting on this thread and so we get a circular
deadlock.

some task enters direct reclaim with GFP_KERNEL
  => too_many_isolated() false
    => vmscan and run into dirty pages
      => pageout()
        => take some FS lock
	  => fs/block code does GFP_NOIO allocation
	    => enter direct reclaim again
	      => too_many_isolated() true
		=> waiting for others to progress, however the other
		   tasks may be circular waiting for the FS lock..

The fix is to let !__GFP_IO and !__GFP_FS direct reclaims enjoy higher
priority than normal ones, by honouring them higher throttle threshold.

Now !GFP_IOFS reclaims won't be waiting for GFP_IOFS reclaims to
progress. They will be blocked only when there are too many concurrent
!GFP_IOFS reclaims, however that's very unlikely because the IO-less
direct reclaims is able to progress much more faster, and they won't
deadlock each other. The threshold is raised high enough for them, so
that there can be sufficient parallel progress of !GFP_IOFS reclaims.

Reported-by: NeilBrown <neilb@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- linux-next.orig/mm/vmscan.c	2010-10-13 12:35:14.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-10-19 00:13:04.000000000 +0800
@@ -1163,6 +1163,13 @@ static int too_many_isolated(struct zone
 		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
 	}
 
+	/*
+	 * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so that
+	 * they won't get blocked by normal ones and form circular deadlock.
+	 */
+	if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
+		inactive >>= 3;
+
 	return isolated > inactive;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
