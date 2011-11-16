Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 49D346B0074
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 16:55:56 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Date: Wed, 16 Nov 2011 22:58:39 +0100
References: <20111114140421.GA27150@suse.de> <alpine.LFD.2.02.1111160908310.2446@tux.localdomain> <alpine.DEB.2.00.1111161340010.16596@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1111161340010.16596@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201111162258.39346.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Colin Cross <ccross@android.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wednesday, November 16, 2011, David Rientjes wrote:
> On Wed, 16 Nov 2011, Pekka Enberg wrote:
> 
> > > diff --git a/kernel/power/suspend.c b/kernel/power/suspend.c
> > > index fdd4263..01aa9b5 100644
> > > --- a/kernel/power/suspend.c
> > > +++ b/kernel/power/suspend.c
> > > @@ -297,9 +297,11 @@ int enter_state(suspend_state_t state)
> > >                goto Finish;
> > > 
> > >        pr_debug("PM: Entering %s sleep\n", pm_states[state]);
> > > +       oom_killer_disable();
> > >        pm_restrict_gfp_mask();
> > >        error = suspend_devices_and_enter(state);
> > >        pm_restore_gfp_mask();
> > > +       oom_killer_enable();
> > > 
> > >  Finish:
> > >        pr_debug("PM: Finishing wakeup.\n");
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 6e8ecb6..d8c31b7 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2177,9 +2177,9 @@ rebalance:
> > >         * running out of options and have to consider going OOM
> > >         */
> > >        if (!did_some_progress) {
> > > -               if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> > > -                       if (oom_killer_disabled)
> > > +               if (oom_killer_disabled)
> > >                                goto nopage;
> 
> You're allowing __GFP_NOFAIL allocations to fail.
> 
> > > +               if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> > >                        page = __alloc_pages_may_oom(gfp_mask, order,
> > >                                        zonelist, high_zoneidx,
> > >                                        nodemask, preferred_zone,
> > > 
> > 
> > I'd prefer something like this. The whole 'gfp_allowed_flags' thing was
> > designed to make GFP_KERNEL work during boot time where it's obviously safe to
> > do that. I really don't think that's going to work suspend cleanly.
> > 
> 
> Adding Rafael to the cc.
> 
> This has been done since 2.6.34 and presumably has been working quite 
> well.

Yes, it has.

> I don't have a specific objection to gfp_allowed_flags to be used 
> outside of boot since it seems plausible that there are system-level 
> contexts that would need different behavior in the page allocator and this 
> does it effectively without major surgery or a slower fastpath.  Suspend 
> is using it just like boot does before irqs are enabled, so I don't have 
> an objection to it.

Good. :-)

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
