Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD4A6B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 12:37:06 -0500 (EST)
Date: Tue, 15 Nov 2011 17:36:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111115173656.GJ27150@suse.de>
References: <20111114140421.GA27150@suse.de>
 <CAEwNFnALUoeh5cEW=XZqy7Aab4hxtE11-mAjWB1c5eddzGuQFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEwNFnALUoeh5cEW=XZqy7Aab4hxtE11-mAjWB1c5eddzGuQFA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Nov 16, 2011 at 01:13:30AM +0900, Minchan Kim wrote:
> On Mon, Nov 14, 2011 at 11:04 PM, Mel Gorman <mgorman@suse.de> wrote:
> > This patch seems to have gotten lost in the cracks and the discussion
> > on alternatives that started here https://lkml.org/lkml/2011/10/25/24
> > petered out without any alternative patches being posted. Lacking
> > a viable alternative patch, I'm reposting this patch because AFAIK,
> > this bug still exists.
> >
> > Colin Cross reported;
> >
> >  Under the following conditions, __alloc_pages_slowpath can loop forever:
> >  gfp_mask & __GFP_WAIT is true
> >  gfp_mask & __GFP_FS is false
> >  reclaim and compaction make no progress
> >  order <= PAGE_ALLOC_COSTLY_ORDER
> >
> >  These conditions happen very often during suspend and resume,
> >  when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
> >  allocations into __GFP_WAIT.
> >
> >  The oom killer is not run because gfp_mask & __GFP_FS is false,
> >  but should_alloc_retry will always return true when order is less
> >  than PAGE_ALLOC_COSTLY_ORDER.
> >
> > In his fix, he avoided retrying the allocation if reclaim made no
> > progress and __GFP_FS was not set. The problem is that this would
> > result in GFP_NOIO allocations failing that previously succeeded
> > which would be very unfortunate.
> >
> > The big difference between GFP_NOIO and suspend converting GFP_KERNEL
> > to behave like GFP_NOIO is that normally flushers will be cleaning
> > pages and kswapd reclaims pages allowing GFP_NOIO to succeed after
> > a short delay. The same does not necessarily apply during suspend as
> > the storage device may be suspended.  Hence, this patch special cases
> > the suspend case to fail the page allocation if reclaim cannot make
> > progress. This might cause suspend to abort but that is better than
> > a livelock.
> >
> > [mgorman@suse.de: Rework fix to be suspend specific]
> > Reported-and-tested-by: Colin Cross <ccross@android.com>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/page_alloc.c |   22 ++++++++++++++++++++++
> >  1 files changed, 22 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9dd443d..5402897 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -127,6 +127,20 @@ void pm_restrict_gfp_mask(void)
> >        saved_gfp_mask = gfp_allowed_mask;
> >        gfp_allowed_mask &= ~GFP_IOFS;
> >  }
> > +
> > +static bool pm_suspending(void)
> > +{
> > +       if ((gfp_allowed_mask & GFP_IOFS) == GFP_IOFS)
> > +               return false;
> > +       return true;
> > +}
> > +
> > +#else
> > +
> > +static bool pm_suspending(void)
> > +{
> > +       return false;
> > +}
> >  #endif /* CONFIG_PM_SLEEP */
> >
> >  #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
> > @@ -2214,6 +2228,14 @@ rebalance:
> >
> >                        goto restart;
> >                }
> > +
> > +               /*
> > +                * Suspend converts GFP_KERNEL to __GFP_WAIT which can
> > +                * prevent reclaim making forward progress without
> > +                * invoking OOM. Bail if we are suspending
> > +                */
> > +               if (pm_suspending())
> > +                       goto nopage;
> >        }
> >
> >        /* Check if we should retry the allocation */
> >
> 
> I don't have much time to look into this problem so I miss some things.
> But the feeling I have a mind when I faced this problem is why we
> should make another special case handling function.
> Already we have such thing for hibernation - oom_killer_disabled in vm
> Could we use it instead of making new branch for very special case?

Fair question!

Suspend is a multi-stage process and the OOM killer is disabled at
a different time to the GFP flags being restricted. This is another
reason why renaming to pm_suspending to pm_suspended_storage is a
good idea (pm_suspending is misleading at best).

I am vague on all the steps hibernation takes but initially processes
are frozen and if they are successfully frozen then the OOM killer is
disabled. At this point, storage is still active so the GFP allowed
mask is the same. When preparing to write the image, kernel threads
are suspended so there is no new IO being initiated and then the GFP
mask is restricted to prevent any memory allocation trying to write
pages to storage. It then writes the image to disk.

So what we have now is

        if (!did_some_progress) {
                if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
                        if (oom_killer_disabled)
                                goto nopage;

Lets say we changed that to

        if (!did_some_progress) {
                if (oom_killer_disabled)
                        goto nopage;
                if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {

The impact would be that during the time between processes been frozen
and storage being suspended, GFP_NOIO allocations that used to call
wait_iff_congested and retry while kswapd does its thing will return
failure instead. These GFP_NOIO allocations that used to succeed will
now fail in rare cases during suspend and I don't think we want that.

Is this what you meant or had you something else in mind?

> Maybe It would be better to rename oom_killer_disabled with
> pm_is_going or something.
> 

I think renaming oom_killer_disabled to pm_oom_disabled would be
reasonable but it does not necessarily get us away from needing a
pm_suspended_storage() test.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
