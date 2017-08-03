Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D10D86B06A3
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 08:22:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z36so1740527wrb.13
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 05:22:27 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id 33si1685317edp.326.2017.08.03.05.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 05:22:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id D6F6A1C18F8
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 13:22:25 +0100 (IST)
Date: Thu, 3 Aug 2017 13:22:25 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 1/2] mm, oom: do not rely on TIF_MEMDIE for memory
 reserves access
Message-ID: <20170803122225.3ycluy5ixl5edlfn@techsingularity.net>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170727090357.3205-2-mhocko@kernel.org>
 <20170802082914.GF2524@dhcp22.suse.cz>
 <20170803093701.icju4mxmto3ls3ch@techsingularity.net>
 <20170803110030.GJ12521@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170803110030.GJ12521@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 03, 2017 at 01:00:30PM +0200, Michal Hocko wrote:
> > Ok, no collision with the wmark indexes so that should be fine. While I
> > didn't check, I suspect that !MMU users also have relatively few CPUs to
> > allow major contention.
> 
> Well, I didn't try to improve the !MMU case because a) I do not know
> whether there is a real problem with oom depletion there and b) I have
> no way to test this. So I only focused on keeping the status quo for
> nommu.
> 

I've no problem with that.

> > > @@ -3603,21 +3612,46 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> > >  	return alloc_flags;
> > >  }
> > >  
> > > -bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > > +static bool oom_reserves_allowed(struct task_struct *tsk)
> > >  {
> > > -	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
> > > +	if (!tsk_is_oom_victim(tsk))
> > > +		return false;
> > > +
> > > +	/*
> > > +	 * !MMU doesn't have oom reaper so give access to memory reserves
> > > +	 * only to the thread with TIF_MEMDIE set
> > > +	 */
> > > +	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
> > >  		return false;
> > >  
> > > +	return true;
> > > +}
> > > +
> > 
> > Ok, there is a chance that a task selected as an OOM kill victim may be
> > in the middle of a __GFP_NOMEMALLOC allocation but I can't actually see a
> > problem wiith that. __GFP_NOMEMALLOC users are not going to be in the exit
> > path (which we care about for an OOM killed task) and the caller should
> > always be able to handle a failure.
> 
> Not sure I understand. If the oom victim is doing __GFP_NOMEMALLOC then
> we haven't been doing ALLOC_NO_WATERMARKS even before. So I preserve the
> behavior here. Even though I am not sure this is a deliberate behavior
> or something more of result of an evolution of the code.
> 

The behaviour is fine as far as I can tell.

> > > +bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > > +{
> > > +	return __gfp_pfmemalloc_flags(gfp_mask) > 0;
> > >  }
> > 
> > Very subtle sign casing error here. If the flags ever use the high bit,
> > this wraps and fails. It "shouldn't be possible" but you could just remove
> > the "> 0" there to be on the safe side or have __gfp_pfmemalloc_flags
> > return unsigned.
> 
> what about
> 	return !!__gfp_pfmemalloc_flags(gfp_mask);
>  

You could but it's overkill. Any value cast to bool should be safe as it's
meant to be immune from truncation concerns.

> > >  /*
> > > @@ -3770,6 +3804,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > >  	unsigned long alloc_start = jiffies;
> > >  	unsigned int stall_timeout = 10 * HZ;
> > >  	unsigned int cpuset_mems_cookie;
> > > +	int reserves;
> > >  
> > 
> > This should be explicitly named to indicate it's about flags and not the
> > number of reserve pages or something else wacky.
> 
> s@reserves@reserve_flags@?
> 

That's do.

> > >  	/*
> > >  	 * In the slowpath, we sanity check order to avoid ever trying to
> > > @@ -3875,15 +3910,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > >  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
> > >  		wake_all_kswapds(order, ac);
> > >  
> > > -	if (gfp_pfmemalloc_allowed(gfp_mask))
> > > -		alloc_flags = ALLOC_NO_WATERMARKS;
> > > +	reserves = __gfp_pfmemalloc_flags(gfp_mask);
> > > +	if (reserves)
> > > +		alloc_flags = reserves;
> > >  
> > 
> > And if it's reserve_flags you can save a branch with
> > 
> > reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
> > alloc_pags |= reserve_flags;
> > 
> > It won't make much difference considering how branch-intensive the allocator
> > is anyway.
> 
> I was actually considering that but rather didn't want to do it because
> I wanted to reset alloc_flags rather than create strange ALLOC_$FOO
> combinations which would be harder to evaluate.
>  

Ok, it does implicitely clear flags like ALLOC_CPUSET which is fine in
this context but it must be remembered in the future if an alloc flag is
ever introduced that has meaning even for oom kill.

> > Mostly I only found nit-picks so whether you address them or not
> > 
> > Acked-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Thanks a lot for your review. Here is an incremental diff on top

Looks fine. I am not a major fan of the !! because I think it's
unnecessary but it's not worth making a big deal out of. It's a
well-recognised idiom.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
