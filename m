Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 194CC6B0069
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 05:37:45 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id k14so4701256wgh.31
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 02:37:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yq2si16776762wjc.26.2014.10.06.02.37.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Oct 2014 02:37:44 -0700 (PDT)
Date: Mon, 6 Oct 2014 10:37:40 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Kswapd 100% CPU since 3.8 on Sandybridge
Message-ID: <20141006093740.GA19574@suse.de>
References: <CABe+QzA=0YVpQ8rN+3X-cbH6JP1nWTvp2spb93P9PqJhmjBROA@mail.gmail.com>
 <CABe+QzA-E40bFFXYJBc663Kx0KrE3xy2uZq5xOH2XL6mFPA6+w@mail.gmail.com>
 <CABe+QzCn_7xm1x62o5d2VoiQrf_7LorhnVOD905Zzd+uu_EuqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CABe+QzCn_7xm1x62o5d2VoiQrf_7LorhnVOD905Zzd+uu_EuqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sarah A Sharp <sarah@thesharps.us>
Cc: linux-mm@kvack.org, intel-gfx@lists.freedesktop.org

On Sat, Oct 04, 2014 at 10:05:20AM -0700, Sarah A Sharp wrote:
> Please excuse the non-wrapped email. My personal system is currently
> b0rked, so I'm sending this in frustration from my phone.
> 
> My laptop is currently completely hosed. Disk light on full solid
> Mouse movement sluggish to the point of moving a couple cms per second.
> Firefox window greyed out but not OOM killed yet. When this behavior
> occurred in the past, if I ran top, I would see kswapd taking up 100% of
> one of my two CPUs.
> 
> If I can catch the system in time before mouse movement becomes too
> sluggish, closing the browser window will cause kswapd usage to drop, and
> the system goes back to a normal state. If I don't catch it in time, I
> can't even ssh into the box to kill Firefox because the login times out.
> Occasionally Firefox gets OOM killed, but most of the time I have to use
> sysreq keys to reboot the system.
> 
> This can be reproduced by using either Chrome or Firefox. Chrome fails
> faster. I'm not sure whether it's related to loading tabs with a bunch of
> images, maybe flash, but it takes around 10-15 tabs being open before it
> starts to fail. I can try to characterize it further.
> 
> System: Lenovo x220 Intel Sandy Bridge graphics
> Ubuntu 14.04 with edgers PPA for Mesa
> 3.16.3 kernel
> 
> Since around the 3.8 kernel time frame, I've been able to reproduce this
> behavior. I'm pretty sure it was a kernel change.
> 
> I mentioned this to Mel Gorman at LinuxCon NA, and he wanted me to run a
> particular mm test. I still don't have time to triage this, but I'm now
> frustrated enough to make time.
> 
> Mel, what test do you want me to run?
> 

Minimally I wanted you to sample the stack traces for kswapd, narrow down
to the time of its failure and see if it was stuck in a shrinker loop. What
I suspected at the time was that it was hammering on the i915 shrinker and
possibly doing repeated shrinks of the GPU objects in there. At one point
at least, that was an extremely heavy operation if the objections were
not freeable and I wanted to see if that was still the case. I confess I
haven't looked at the code to see what has changed recently.

If that was confirmed then I to modify the mmtests Ftracereclaimcompact
reported to focus exclusively on slab and give a breakdown of which shrinker
it was spending time in. Right now, that reporter only says how much time
is spent in slab which is not enough in this case. I just wanted to first
know if it was worth the effort writing a monitor that gave a per-slab
breakdown. If it can be both identified as shrinker-related and narrowed
down to a specific shrinker then there is more to work with. mmtests can run
in a monitor-only mode so it *should* be possible to turn on this monitor,
wait for the problem to reproduce and focus on the end of the logs.

Unfortunately, none of this explains why the machine completely froze.
If it really was a shrinker problem then I expected the system to be
extremely sluggish but did not predict that it would be so unresponsive
that ssh was not an option. That has left me scratching my head.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
