Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id E8BE16B0253
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:49:23 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so70973558wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:49:23 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ct1si16069396wjb.60.2016.02.26.05.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 05:49:22 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id b205so9173743wmb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:49:22 -0800 (PST)
Date: Fri, 26 Feb 2016 14:49:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160226134920.GA18200@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602252219020.9793@eggly.anvils>
 <009a01d1706a$e666dc00$b3349400$@alibaba-inc.com>
 <20160226092406.GB8940@dhcp22.suse.cz>
 <00bd01d17080$445ceb00$cd16c100$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00bd01d17080$445ceb00$cd16c100$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@i-love.sakura.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Sergey Senozhatsky' <sergey.senozhatsky.work@gmail.com>

On Fri 26-02-16 18:27:16, Hillf Danton wrote:
> >> 
> > > --- a/mm/page_alloc.c	Thu Feb 25 15:43:18 2016
> > > +++ b/mm/page_alloc.c	Fri Feb 26 15:18:55 2016
> > > @@ -3113,6 +3113,8 @@ should_reclaim_retry(gfp_t gfp_mask, uns
> > >  	struct zone *zone;
> > >  	struct zoneref *z;
> > >
> > > +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> > > +		return true;
> > 
> > This is defeating the whole purpose of the rework - to behave
> > deterministically. You have just disabled the oom killer completely.
> > This is not the way to go
> > 
> Then in another direction, below is what I can do.
> 
> thanks
> Hillf
> --- a/mm/page_alloc.c	Thu Feb 25 15:43:18 2016
> +++ b/mm/page_alloc.c	Fri Feb 26 18:14:59 2016
> @@ -3366,8 +3366,11 @@ retry:
>  		no_progress_loops++;
>  
>  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
> -				 did_some_progress > 0, no_progress_loops))
> +				 did_some_progress > 0, no_progress_loops)) {
> +		/* Burn more cycles if any zone seems to satisfy our request */
> +		no_progress_loops /= 2;

No, I do not think this makes any sense. If we need more retry loops
then we can do it by increasing MAX_RECLAIM_RETRIES.

>  		goto retry;
> +	}
>  
>  	/* Reclaim has failed us, start killing things */
>  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
