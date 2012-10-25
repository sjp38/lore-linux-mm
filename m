Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id E0D916B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 04:33:16 -0400 (EDT)
Date: Thu, 25 Oct 2012 17:38:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 1/2] vmevent: Implement pressure attribute
Message-ID: <20121025083843.GB15767@bbox>
References: <20121022111928.GA12396@lizard>
 <20121022112149.GA29325@lizard>
 <alpine.LFD.2.02.1210241159590.13035@tux.localdomain>
 <20121025022321.GA8892@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121025022321.GA8892@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, Oct 24, 2012 at 07:23:21PM -0700, Anton Vorontsov wrote:
> Hello Pekka,
> 
> Thanks for taking a look into this!
> 
> On Wed, Oct 24, 2012 at 12:03:10PM +0300, Pekka Enberg wrote:
> > On Mon, 22 Oct 2012, Anton Vorontsov wrote:
> > > This patch introduces VMEVENT_ATTR_PRESSURE, the attribute reports Linux
> > > virtual memory management pressure. There are three discrete levels:
> > > 
> > > VMEVENT_PRESSURE_LOW: Notifies that the system is reclaiming memory for
> > > new allocations. Monitoring reclaiming activity might be useful for
> > > maintaining overall system's cache level.
> > > 
> > > VMEVENT_PRESSURE_MED: The system is experiencing medium memory pressure,
> > > there is some mild swapping activity. Upon this event applications may
> > > decide to free any resources that can be easily reconstructed or re-read
> > > from a disk.
> > 
> > Nit:
> > 
> > s/VMEVENT_PRESSURE_MED/VMEVENT_PRESSUDE_MEDIUM/
> 
> Sure thing, will change.
> 
> > Other than that, I'm OK with this. Mel and others, what are your thoughts 
> > on this?
> > 
> > Anton, have you tested this with real world scenarios?
> 
> Yup, I was mostly testing it on a desktop. I.e. in a KVM instance I was
> running a full fedora17 desktop w/ a lot of apps opened. The pressure
> index was pretty good in the sense that it was indeed reflecting the
> sluggishness in the system during swap activity. It's not ideal, i.e. the
> index might drop slightly for some time, but we usually interested in
> "above some value" threshold, so it should be fine.
> 
> The _LOW level is defined very strictly, and cannot be tuned anyhow. So
> it's very solid, and that's what we mostly use for Android.
> 
> The _OOM level is also defined quite strict, so from the API point of
> view, it's also solid, and should not be a problem.

The one of the concern when I see the code is that whether we should consider
high order page allocation. Now OOM killer doesn't kill anyone when VM
suffer from higher order allocation because it doesn't help getting physical
contiguos memory in normal case. Same rule could be applied.

> 
> Although the problem with _OOM is delivering the event in time (i.e. we
> must be quick in predicting it, before OOMK triggers). Today the patch has

Absolutely. It was a biggest challenge.

> a shortcut for _OOM level: we send _OOM notification when reclaimer's
> priority is below empirically found value '3' (we might make it tunable
> via sysctl too, but that would expose another mm detail -- although sysctl
> sounds not that bad as exposing something in the C API; we have plenty of
> mm knobs in /proc/sys/vm/ already).

Hmm, I'm not sure depending on such magic value is good idea but I have no idea
so I will shut up :(

> 
> The real tunable is _MED level, and this should be tuned based on the
> desired system's behaviour that I described in more detail in this long
> post: http://lkml.org/lkml/2012/10/7/29.
> 
> Based on my observations, I wouldn't say that we have plenty of room to
> tune the value, though. Usual swapping activity causes index to rise to
> say to 30%, and when the system can't keep up, it raises to 50..90 (but we
> still have plenty of swap space, so the system is far away from OOM,
> although it is thrashing. Ideally I'd prefer to not have any sysctl, but I
> believe _MED level is really based on user's definition of "medium".
> 
> > How does it stack up against Android's low memory killer, for example?
> 
> The LMK driver is effectively using what we call _LOW pressure
> notifications here, so by definition it is enough to build a full
> replacement for the in-kernel LMK using just the _LOW level. But in the
> future, we might want to use _MED as well, e.g. kill unneeded services
> based not on the cache level, but based on the pressure.

Good idea.
Thanks for keeping trying this, Anton!

> 
> Thanks,
> Anton.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
