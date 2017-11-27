Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35E7F6B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:38:49 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id s18so28200453pge.19
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 22:38:49 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 31si23069800ple.443.2017.11.26.22.38.47
        for <linux-mm@kvack.org>;
        Sun, 26 Nov 2017 22:38:48 -0800 (PST)
Date: Mon, 27 Nov 2017 15:38:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/vmscan: make do_shrink_slab more robust.
Message-ID: <20171127063846.GA27768@bbox>
References: <20171127051643.GA27449@bbox>
 <201711271427202879096@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711271427202879096@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.biao2@zte.com.cn
Cc: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Mon, Nov 27, 2017 at 02:27:20PM +0800, jiang.biao2@zte.com.cn wrote:
> > On Mon, Nov 27, 2017 at 12:46:27PM +0800, jiang.biao2@zte.com.cn wrote:> > On Mon, Nov 27, 2017 at 09:37:30AM +0800, Jiang Biao wrote:> >
> > > > > This patch make do_shrink_slab more robust when
> > > > > shrinker->count_objects return negative freeable.
> > > >
> > > > Shrinker.h says count_objects should return 0 if there are no
> > > > freeable objects, not -1.
> > > >
> > > > So if something returns -1, changing it with returning 0 would
> > > be more proper fix.
> > > >
> > > Hi,
> > > Indeed it's not a bug of vmscan, but there are many shrinkers
> > > out there, which may return negative value unwillingly(in some
> > > rare cases, such as decreasing cocurrently). It's unlikely and
> > > should be avioded, but not impossible, this patch may make it
> > > more robust and could not hurt :).
> > 
> > Yub, I'm not strong against of your claim. However, let's think
> > from different point of view.
> > 
> > API says it should return 0 unless shrinker cannot find freeable
> > object any more but with your change, implmentation handles
> > although a shrinker return minus value by mistake.
> > 
> > In future, MM guys might want to extend count_objects returning
> > -ERR_SOMETHING to propagate error, for example but we cannot.
> > Because some of shrinkers already rely on the implementation so
> > if we start to support minus value return, some of shrinker might
> > be broken.
> > 
> > Yes, it's the imaginary scenario but wanted why such changes
> > makes us trouble in future, API PoV.
> I agree with your concern.  How about we take another way by 
> adding some warning in such case? such as,
>         freeable = shrinker->count_objects(shrinker, shrinkctl);
> +       if (unlikely(freeable < 0)) {
> +               pr_err("shrink_slab: %pF negative objects returned. freeable=%ld\n",
> +                       shrinker->scan_objects, freeable);
> +               freeable = 0;  //maybe not needed?
> +       }
>         if (freeable == 0)
>                 return 0;
> In this way, we would not break the API, but could alert user exception 
> with message, and make it more robust in such case.

True but it would be a problem robust vs. effectivess tradeoff.
Think about that everyone want to make thier code robust.
It means they start to dump lots of defensive code so code start
to look like complicated as well as binary bloating.
So, whenever we add some more, we should think how effective
the code I am putting?

In this case, I'm skeptical, Sorry. But others might have different
opinions. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
