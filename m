Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA966B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 12:34:51 -0500 (EST)
Received: by wggz12 with SMTP id z12so13167412wgg.2
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 09:34:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r15si2829726wju.47.2015.02.26.09.34.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Feb 2015 09:34:49 -0800 (PST)
Date: Thu, 26 Feb 2015 18:34:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2] mm, oom: do not fail __GFP_NOFAIL allocation if oom
 killer is disbaled
Message-ID: <20150226173445.GG14878@dhcp22.suse.cz>
References: <1424801964-1602-1-git-send-email-mhocko@suse.cz>
 <20150224191127.GA14718@phnom.home.cmpxchg.org>
 <alpine.DEB.2.10.1502241220500.3855@chino.kir.corp.google.com>
 <20150225140826.GD26680@dhcp22.suse.cz>
 <alpine.DEB.2.10.1502251240150.18097@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1502251240150.18097@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 25-02-15 12:41:07, David Rientjes wrote:
> On Wed, 25 Feb 2015, Michal Hocko wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 2d224bbdf8e8..c2ff40a30003 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2363,7 +2363,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  			goto out;
> >  	}
> >  	/* Exhausted what can be done so it's blamo time */
> > -	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false))
> > +	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
> > +			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> >  		*did_some_progress = 1;
> >  out:
> >  	oom_zonelist_unlock(ac->zonelist, gfp_mask);
> 
> Eek, not sure we actually need to play any games with did_some_progress, 
> it might be clearer just to do this

We would loose the warning which _might_ be helpful and I also find this
place better because it is close to the out_of_memory and this one has
only one failure mode. So I would prefer to stick with this unless there
are big objections.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2760,7 +2760,7 @@ retry:
>  							&did_some_progress);
>  			if (page)
>  				goto got_pg;
> -			if (!did_some_progress)
> +			if (!did_some_progress && !(gfp_mask & __GFP_NOFAIL))
>  				goto nopage;
>  		}
>  		/* Wait for some write requests to complete then retry */
> 
> Either way you decide, feel free to add my
> 
> Acked-by: David Rientjes <rientjes@gooogle.com>

Thanks!

Andrew, should I repost or you can pick it up from this thread? Assuming
you and others do not have objections of course.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
