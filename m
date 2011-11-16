Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3DD9C6B0072
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 19:45:25 -0500 (EST)
Received: by vws14 with SMTP id 14so429211vws.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 16:45:22 -0800 (PST)
Date: Wed, 16 Nov 2011 09:45:16 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111116004516.GA13028@barrios-laptop.redhat.com>
References: <20111114140421.GA27150@suse.de>
 <CAEwNFnALUoeh5cEW=XZqy7Aab4hxtE11-mAjWB1c5eddzGuQFA@mail.gmail.com>
 <20111115173656.GJ27150@suse.de>
 <20111116002235.GA10958@barrios-laptop.redhat.com>
 <CAMbhsRSePzsN-4JXEEwFoaa9EhBfHQ11gsjqJCDzV2nonJ0DqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMbhsRSePzsN-4JXEEwFoaa9EhBfHQ11gsjqJCDzV2nonJ0DqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Nov 15, 2011 at 04:28:36PM -0800, Colin Cross wrote:
> On Tue, Nov 15, 2011 at 4:22 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > On Tue, Nov 15, 2011 at 05:36:56PM +0000, Mel Gorman wrote:
> >> On Wed, Nov 16, 2011 at 01:13:30AM +0900, Minchan Kim wrote:
> >> The impact would be that during the time between processes been frozen
> >> and storage being suspended, GFP_NOIO allocations that used to call
> >> wait_iff_congested and retry while kswapd does its thing will return
> >> failure instead. These GFP_NOIO allocations that used to succeed will
> >> now fail in rare cases during suspend and I don't think we want that.
> >>
> >> Is this what you meant or had you something else in mind?
> >>
> >
> > You read my mind exactly!
> >
> > I thought hibernation process is as follows,
> >
> > freeze user processes
> > oom_disable
> > hibernate_preallocate_memory
> > freeze kernel processes(include kswapd)
> > pm_restrict_gfp_mask
> > swsusp_save
> >
> > My guessing is hibernate_prealocate_memory should reserve all memory needed
> > for hibernation for reclaimaing pages of kswapd because kswapd just would be
> > stopped so during swsusp_save, page reclaim should not be occured.
> >
> > But being see description of patch, my guess seems wrong.
> > Now the problem happens and it means page reclaim happens during swsusp_save.
> > Colin or someone could confirm this?
> 
> The problem I see is during suspend, not hibernation.  The particular
> allocation that usually causes the problem is the pgd_alloc for page
> tables when re-enabling the 2nd cpu during resume, which is odd as
> those same page tables were freed during suspend.  I guess an
> unfreezable kernel thread allocated that memory between the free and
> re-allocation.

Then, How about this?

[barrios@barrios-laptop linux-2.6]$ git diff
diff --git a/kernel/power/suspend.c b/kernel/power/suspend.c
index fdd4263..01aa9b5 100644
--- a/kernel/power/suspend.c
+++ b/kernel/power/suspend.c
@@ -297,9 +297,11 @@ int enter_state(suspend_state_t state)
                goto Finish;
 
        pr_debug("PM: Entering %s sleep\n", pm_states[state]);
+       oom_killer_disable();
        pm_restrict_gfp_mask();
        error = suspend_devices_and_enter(state);
        pm_restore_gfp_mask();
+       oom_killer_enable();
 
  Finish:
        pr_debug("PM: Finishing wakeup.\n");
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..d8c31b7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2177,9 +2177,9 @@ rebalance:
         * running out of options and have to consider going OOM
         */
        if (!did_some_progress) {
-               if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
-                       if (oom_killer_disabled)
+               if (oom_killer_disabled)
                                goto nopage;
+               if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
                        page = __alloc_pages_may_oom(gfp_mask, order,
                                        zonelist, high_zoneidx,
                                        nodemask, preferred_zone,

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
