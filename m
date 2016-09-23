Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE3D6B027F
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:32:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l132so10021527wmf.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:32:27 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id f189si2253817wmf.4.2016.09.23.01.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 01:32:26 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w84so1551669wmg.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:32:26 -0700 (PDT)
Date: Fri, 23 Sep 2016 10:32:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
Message-ID: <20160923083224.GF4478@dhcp22.suse.cz>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <007901d21574$9ef82d60$dce88820$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <007901d21574$9ef82d60$dce88820$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>

On Fri 23-09-16 16:29:36, Hillf Danton wrote:
[...]
> > @@ -3659,6 +3661,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	else
> >  		no_progress_loops++;
> > 
> > +	/* Make sure we know about allocations which stall for too long */
> > +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> > +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> > +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
> 
> Better if pid is also printed.

I've tried to be consistent with warn_alloc_failed and that doesn't
print pid either. Maybe both of them should. Dunno

> > +				order, gfp_mask, &gfp_mask);
> > +		stall_timeout += 10 * HZ;
> 
> Alternatively	 alloc_start = jiffies;

Then we would lose the cumulative time in the output which is imho
helpful because you cannot tell whether the new warning is a new request
or the old one still looping.

> > +		dump_stack();
> > +	}
> > +
> >  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
> >  				 did_some_progress > 0, no_progress_loops))
> >  		goto retry;
> > --
> > 2.9.3
> > 
> thanks
> Hillf
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
