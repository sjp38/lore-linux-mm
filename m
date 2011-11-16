Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6DB6B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 17:48:20 -0500 (EST)
Received: by ywp17 with SMTP id 17so363191ywp.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 14:48:18 -0800 (PST)
Date: Wed, 16 Nov 2011 14:48:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <CABin3AGpQbt6i56a5+rh=qJC+vC-x4VkhJwsfJczMyGsSH31TA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1111161438160.16596@chino.kir.corp.google.com>
References: <20111114140421.GA27150@suse.de> <CAEwNFnALUoeh5cEW=XZqy7Aab4hxtE11-mAjWB1c5eddzGuQFA@mail.gmail.com> <20111115173656.GJ27150@suse.de> <20111116002235.GA10958@barrios-laptop.redhat.com> <CAMbhsRSePzsN-4JXEEwFoaa9EhBfHQ11gsjqJCDzV2nonJ0DqQ@mail.gmail.com>
 <20111116004516.GA13028@barrios-laptop.redhat.com> <alpine.LFD.2.02.1111160908310.2446@tux.localdomain> <alpine.DEB.2.00.1111161340010.16596@chino.kir.corp.google.com> <CABin3AGpQbt6i56a5+rh=qJC+vC-x4VkhJwsfJczMyGsSH31TA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-90931042-1321483390=:16596"
Content-ID: <alpine.DEB.2.00.1111161443210.16596@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <barrioskmc@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Colin Cross <ccross@android.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-90931042-1321483390=:16596
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1111161443211.16596@chino.kir.corp.google.com>

On Thu, 17 Nov 2011, Minchan Kim wrote:

> >> > diff --git a/kernel/power/suspend.c b/kernel/power/suspend.c
> >> > index fdd4263..01aa9b5 100644
> >> > --- a/kernel/power/suspend.c
> >> > +++ b/kernel/power/suspend.c
> >> > @@ -297,9 +297,11 @@ int enter_state(suspend_state_t state)
> >> > A  A  A  A  A  A  A  A goto Finish;
> >> >
> >> > A  A  A  A pr_debug("PM: Entering %s sleep\n", pm_states[state]);
> >> > + A  A  A  oom_killer_disable();
> >> > A  A  A  A pm_restrict_gfp_mask();
> >> > A  A  A  A error = suspend_devices_and_enter(state);
> >> > A  A  A  A pm_restore_gfp_mask();
> >> > + A  A  A  oom_killer_enable();
> >> >
> >> > A Finish:
> >> > A  A  A  A pr_debug("PM: Finishing wakeup.\n");
> >> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> > index 6e8ecb6..d8c31b7 100644
> >> > --- a/mm/page_alloc.c
> >> > +++ b/mm/page_alloc.c
> >> > @@ -2177,9 +2177,9 @@ rebalance:
> >> > A  A  A  A  * running out of options and have to consider going OOM
> >> > A  A  A  A  */
> >> > A  A  A  A if (!did_some_progress) {
> >> > - A  A  A  A  A  A  A  if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> >> > - A  A  A  A  A  A  A  A  A  A  A  if (oom_killer_disabled)
> >> > + A  A  A  A  A  A  A  if (oom_killer_disabled)
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A goto nopage;
> >
> > You're allowing __GFP_NOFAIL allocations to fail.
> >
> >> > + A  A  A  A  A  A  A  if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> >> > A  A  A  A  A  A  A  A  A  A  A  A page = __alloc_pages_may_oom(gfp_mask, order,
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A zonelist, high_zoneidx,
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A nodemask, preferred_zone,
> >> >
> >>
> >> I'd prefer something like this. The whole 'gfp_allowed_flags' thing was
> >> designed to make GFP_KERNEL work during boot time where it's obviously safe to
> >> do that. I really don't think that's going to work suspend cleanly.
> >>
> >
> > Adding Rafael to the cc.
> >
> > This has been done since 2.6.34 and presumably has been working quite
> > well. A I don't have a specific objection to gfp_allowed_flags to be used
> > outside of boot since it seems plausible that there are system-level
> > contexts that would need different behavior in the page allocator and this
> > does it effectively without major surgery or a slower fastpath. A Suspend
> > is using it just like boot does before irqs are enabled, so I don't have
> > an objection to it.
> >
> 
> My point isn't using gfp_allowed_flags(maybe it's Pekka's concern) but
> why adding new special case handling code like pm_suspended_storage.
> I think we can handle the issue with oom_killer_disabled(but the naming is bad)
> 

Ignore the name of the function that Mel is introducing, it's only related 
to suspend because that's the only thing that (currently) alters 
gfp_allowed_mask after boot.  If something else were to clear __GFP_FS and 
__GFP_IO in the future, we'd simply need to rename the function.  I was 
going to ask for a comment specifically about that, but I think it's 
proximity to the function that allows gfp_allowed_mask to be altered is 
sufficient.

We'd really like to avoid the loop if __GFP_FS and __GFP_IO are not set.  
If oom_killer_disabled is set anytime that gfp_allowed_mask does not allow 
them for _all_ page allocations, then we could certainly replace the new 
pm_suspended_storage() check in should_alloc_retry() with a check on 
oom_killer_disabled.

I'll let you and Rafael work out whether that can be done or not, I just 
see pm_restrict_gfp_mask() being called in kernel/power/hibernate.c and 
kernel/power/suspend.c whereas oom_killer_disable() is only called in 
kernel/power/process.c.  oom_killer_disable() would be unnecessary if 
__GFP_FS were already cleared, so it would require some changes in the 
suspend code.

I like Mel's patch because it's easily maintainable and only depends on 
the state of reclaim and the gfp flags being passed in, which is the 
direct cause of the infinite loop.
--397155492-90931042-1321483390=:16596--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
