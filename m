Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2B46B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 08:27:13 -0500 (EST)
Received: by lffu14 with SMTP id u14so98043160lff.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 05:27:12 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id rp2si18684924lbb.168.2015.11.26.05.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 05:27:11 -0800 (PST)
Date: Thu, 26 Nov 2015 16:26:56 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] vmscan: fix slab vs lru balance
Message-ID: <20151126132656.GL29014@esperanza>
References: <1448369241-26593-1-git-send-email-vdavydov@virtuozzo.com>
 <20151124150227.78c9e39b789f593c5216471e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151124150227.78c9e39b789f593c5216471e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 24, 2015 at 03:02:27PM -0800, Andrew Morton wrote:
> On Tue, 24 Nov 2015 15:47:21 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> 
> > The comment to shrink_slab states that the portion of kmem objects
> > scanned by it equals the portion of lru pages scanned by shrink_zone
> > over shrinker->seeks.
> > 
> > shrinker->seeks is supposed to be equal to the number of disk seeks
> > required to recreated an object. It is usually set to DEFAULT_SEEKS (2),
> > which is quite logical, because most kmem objects (e.g. dentry or inode)
> > require random IO to reread (seek to read and seek back).
> > 
> > That said, one would expect that dcache is scanned two times less
> > intensively than page cache, which sounds sane as dentries are generally
> > more costly to recreate.
> > 
> > However, the formula for distributing memory pressure between slab and
> > lru actually looks as follows (see do_shrink_slab):
> > 
> >                               lru_scanned
> > objs_to_scan = objs_total * --------------- * 4 / shrinker->seeks
> >                             lru_reclaimable
> > 
> > That is dcache, as well as most of other slab caches, is scanned two
> > times more aggressively than page cache.
> > 
> > Fix this by dropping '4' from the equation above.
> > 
> 
> oh geeze.  Who wrote that crap?
> 
> 
> commit c3f4656118a78c1c294e0b4d338ac946265a822b
> Author: Andrew Morton <akpm@osdl.org>
> Date:   Mon Dec 29 23:48:44 2003 -0800
> 
>     [PATCH] shrink_slab acounts for seeks incorrectly
>     
>     wli points out that shrink_slab inverts the sense of shrinker->seeks: those
>     caches which require more seeks to reestablish an object are shrunk harder.
>     That's wrong - they should be shrunk less.
>     
>     So fix that up, but scaling the result so that the patch is actually a no-op
>     at this time, because all caches use DEFAULT_SEEKS (2).
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b859482..f2da3c9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -154,7 +154,7 @@ static int shrink_slab(long scanned, unsigned int gfp_mask)
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
>  		unsigned long long delta;
>  
> -		delta = scanned * shrinker->seeks;
> +		delta = 4 * (scanned / shrinker->seeks);
>  		delta *= (*shrinker->shrinker)(0, gfp_mask);
>  		do_div(delta, pages + 1);
>  		shrinker->nr += delta;
> 
> 
> What a pathetic changelog.
> 
> The current code may be good, it may be bad, but I'm reluctant to
> change it without a solid demonstration that the result is overall
> superior.
> 

Yep, that's understandable - we've been living with this (mis)behavior
for more than 10 years already and nobody seems to complain.

I don't have a solid proof at hand right now that the patch makes things
substantially better in most cases - it just comes from the speculation
that dropping dcache is really expensive, because (a) rereading it
requires random IO and (b) dropping an inode automatically results in
dropping page cache attached to it, so it shouldn't be scanned more
aggressively than unmapped page cache.

Anyway, I'll try to run various workloads with and w/o this patch and
report back if I find those which benefit from it.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
