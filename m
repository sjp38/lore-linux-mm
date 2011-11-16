Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E29026B006E
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 16:44:22 -0500 (EST)
Received: by yenm10 with SMTP id m10so284944yen.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 13:44:20 -0800 (PST)
Date: Wed, 16 Nov 2011 13:44:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <alpine.LFD.2.02.1111160908310.2446@tux.localdomain>
Message-ID: <alpine.DEB.2.00.1111161340010.16596@chino.kir.corp.google.com>
References: <20111114140421.GA27150@suse.de> <CAEwNFnALUoeh5cEW=XZqy7Aab4hxtE11-mAjWB1c5eddzGuQFA@mail.gmail.com> <20111115173656.GJ27150@suse.de> <20111116002235.GA10958@barrios-laptop.redhat.com> <CAMbhsRSePzsN-4JXEEwFoaa9EhBfHQ11gsjqJCDzV2nonJ0DqQ@mail.gmail.com>
 <20111116004516.GA13028@barrios-laptop.redhat.com> <alpine.LFD.2.02.1111160908310.2446@tux.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Colin Cross <ccross@android.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed, 16 Nov 2011, Pekka Enberg wrote:

> > diff --git a/kernel/power/suspend.c b/kernel/power/suspend.c
> > index fdd4263..01aa9b5 100644
> > --- a/kernel/power/suspend.c
> > +++ b/kernel/power/suspend.c
> > @@ -297,9 +297,11 @@ int enter_state(suspend_state_t state)
> >                goto Finish;
> > 
> >        pr_debug("PM: Entering %s sleep\n", pm_states[state]);
> > +       oom_killer_disable();
> >        pm_restrict_gfp_mask();
> >        error = suspend_devices_and_enter(state);
> >        pm_restore_gfp_mask();
> > +       oom_killer_enable();
> > 
> >  Finish:
> >        pr_debug("PM: Finishing wakeup.\n");
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6e8ecb6..d8c31b7 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2177,9 +2177,9 @@ rebalance:
> >         * running out of options and have to consider going OOM
> >         */
> >        if (!did_some_progress) {
> > -               if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> > -                       if (oom_killer_disabled)
> > +               if (oom_killer_disabled)
> >                                goto nopage;

You're allowing __GFP_NOFAIL allocations to fail.

> > +               if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> >                        page = __alloc_pages_may_oom(gfp_mask, order,
> >                                        zonelist, high_zoneidx,
> >                                        nodemask, preferred_zone,
> > 
> 
> I'd prefer something like this. The whole 'gfp_allowed_flags' thing was
> designed to make GFP_KERNEL work during boot time where it's obviously safe to
> do that. I really don't think that's going to work suspend cleanly.
> 

Adding Rafael to the cc.

This has been done since 2.6.34 and presumably has been working quite 
well.  I don't have a specific objection to gfp_allowed_flags to be used 
outside of boot since it seems plausible that there are system-level 
contexts that would need different behavior in the page allocator and this 
does it effectively without major surgery or a slower fastpath.  Suspend 
is using it just like boot does before irqs are enabled, so I don't have 
an objection to it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
