Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 25D206B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 02:10:47 -0500 (EST)
Received: by bke17 with SMTP id 17so238522bke.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 23:10:45 -0800 (PST)
Date: Wed, 16 Nov 2011 09:10:32 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <20111116004516.GA13028@barrios-laptop.redhat.com>
Message-ID: <alpine.LFD.2.02.1111160908310.2446@tux.localdomain>
References: <20111114140421.GA27150@suse.de> <CAEwNFnALUoeh5cEW=XZqy7Aab4hxtE11-mAjWB1c5eddzGuQFA@mail.gmail.com> <20111115173656.GJ27150@suse.de> <20111116002235.GA10958@barrios-laptop.redhat.com> <CAMbhsRSePzsN-4JXEEwFoaa9EhBfHQ11gsjqJCDzV2nonJ0DqQ@mail.gmail.com>
 <20111116004516.GA13028@barrios-laptop.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Colin Cross <ccross@android.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, 16 Nov 2011, Minchan Kim wrote:
> Then, How about this?
>
> [barrios@barrios-laptop linux-2.6]$ git diff
> diff --git a/kernel/power/suspend.c b/kernel/power/suspend.c
> index fdd4263..01aa9b5 100644
> --- a/kernel/power/suspend.c
> +++ b/kernel/power/suspend.c
> @@ -297,9 +297,11 @@ int enter_state(suspend_state_t state)
>                goto Finish;
>
>        pr_debug("PM: Entering %s sleep\n", pm_states[state]);
> +       oom_killer_disable();
>        pm_restrict_gfp_mask();
>        error = suspend_devices_and_enter(state);
>        pm_restore_gfp_mask();
> +       oom_killer_enable();
>
>  Finish:
>        pr_debug("PM: Finishing wakeup.\n");
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6e8ecb6..d8c31b7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2177,9 +2177,9 @@ rebalance:
>         * running out of options and have to consider going OOM
>         */
>        if (!did_some_progress) {
> -               if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> -                       if (oom_killer_disabled)
> +               if (oom_killer_disabled)
>                                goto nopage;
> +               if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
>                        page = __alloc_pages_may_oom(gfp_mask, order,
>                                        zonelist, high_zoneidx,
>                                        nodemask, preferred_zone,
>

I'd prefer something like this. The whole 'gfp_allowed_flags' thing was 
designed to make GFP_KERNEL work during boot time where it's obviously 
safe to do that. I really don't think that's going to work suspend 
cleanly.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
