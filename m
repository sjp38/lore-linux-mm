Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF1228024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 11:02:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so20264254wmg.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:02:50 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id v187si3689765wma.50.2016.09.23.08.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 08:02:37 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 133so3238866wmq.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:02:36 -0700 (PDT)
Date: Fri, 23 Sep 2016 17:02:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
Message-ID: <20160923150234.GV4478@dhcp22.suse.cz>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <201609232336.FIH57364.FOVHtMFQLFSJOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609232336.FIH57364.FOVHtMFQLFSJOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, linux-kernel@vger.kernel.org

On Fri 23-09-16 23:36:22, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > @@ -3659,6 +3661,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	else
> >  		no_progress_loops++;
> >  
> > +	/* Make sure we know about allocations which stall for too long */
> > +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> 
> Should we check !__GFP_NOWARN ? I think __GFP_NOWARN is likely used with
> __GFP_NORETRY, and __GFP_NORETRY is already checked by now.
> 
> I think printing warning regardless of __GFP_NOWARN is better because
> this check is similar to hungtask warning.

Well, if the user said to not warn we should really obey that. Why would
that matter?
 
> > +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> > +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
> > +				order, gfp_mask, &gfp_mask);
> > +		stall_timeout += 10 * HZ;
> > +		dump_stack();
> 
> Can we move this pr_warn() + dump_stack() to a separate function like
> 
> static void __warn_memalloc_stall(unsigned int order, gfp_t gfp_mask, unsigned long alloc_start)
> {
> 	pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> 		current->comm, jiffies_to_msecs(jiffies-alloc_start),
> 		order, gfp_mask, &gfp_mask);
> 	dump_stack();
> }
> 
> in order to allow SystemTap scripts to perform additional actions by name (e.g.
> 
> # stap -g -e 'probe kernel.function("__warn_memalloc_stall").return { panic(); }

I find this reasoning and the use case really _absurd_, seriously! Pulling
the warning into a separate function might be reasonable regardless,
though. It matches warn_alloc_failed. Also if we find out we need some
rate limitting or more checks it might just turn out being easier to
follow rather than in the middle of an already complicated allocation
slow path. I just do not like that the stall_timeout would have to stay
in the original place or have it an in/out parameter.

> ) rather than by line number, and surround __warn_memalloc_stall() call with
> mutex in order to serialize warning messages because it is possible that
> multiple allocation requests are stalling?

we do not use any lock in warn_alloc_failed so why this should be any
different?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
