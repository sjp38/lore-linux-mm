Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 464B46B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:27:13 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v69so14507900wrb.3
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:27:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p91si786303edb.470.2017.11.27.00.27.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 00:27:11 -0800 (PST)
Date: Mon, 27 Nov 2017 09:27:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmscan: make do_shrink_slab more robust.
Message-ID: <20171127082709.2lrc4wbxosv6uuv3@dhcp22.suse.cz>
References: <20171127063846.GA27768@bbox>
 <201711271526547083632@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711271526547083632@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.biao2@zte.com.cn
Cc: minchan@kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Mon 27-11-17 15:26:54, jiang.biao2@zte.com.cn wrote:
> On Mon, Nov 27, 2017 at 02:27:20PM +0800, jiang.biao2@zte.com.cn wrote:> > I agree with your concern.  How about we take another way by
> > > adding some warning in such case? such as,
> > >         freeable = shrinker->count_objects(shrinker, shrinkctl);
> > > +       if (unlikely(freeable < 0)) {
> > > +               pr_err("shrink_slab: %pF negative objects returned. freeable=%ld\n",
> > > +                       shrinker->scan_objects, freeable);
> > > +               freeable = 0;  //maybe not needed?
> > > +       }
> > >         if (freeable == 0)
> > >                 return 0;
> > > In this way, we would not break the API, but could alert user exception
> > > with message, and make it more robust in such case.
> >
> > True but it would be a problem robust vs. effectivess tradeoff.
> > Think about that everyone want to make thier code robust.
> > It means they start to dump lots of defensive code so code start
> > to look like complicated as well as binary bloating.
> > So, whenever we add some more, we should think how effective
> > the code I am putting?
> > 
> > In this case, I'm skeptical, Sorry. But others might have different
> > opinions. :)
> 
> With all due respect. I still think the robustness is more important than 
> effectiveness in this case. :)

This is a slow path so I wouldn't worry about the performance much. On
the other hand I agree that the API is well documented so adding a
warning is too defensive. We simply assume that the kernel running in
the kernel is reasonable. So I would say, fix your code.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
