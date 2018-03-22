Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6FD6B025E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 16:29:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q6so4681299pgv.12
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 13:29:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m10sor205744pge.108.2018.03.22.13.29.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Mar 2018 13:29:39 -0700 (PDT)
Date: Thu, 22 Mar 2018 13:29:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg, thp: do not invoke oom killer on thp charges
In-Reply-To: <20180322085611.GY23100@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1803221304160.3268@chino.kir.corp.google.com>
References: <20180321205928.22240-1-mhocko@kernel.org> <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com> <20180321214104.GT23100@dhcp22.suse.cz> <alpine.DEB.2.20.1803220106010.175961@chino.kir.corp.google.com>
 <20180322085611.GY23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 22 Mar 2018, Michal Hocko wrote:

> > So now you're making a generalized policy change to the memcg charge path 
> > to fix what is obviously only thp and caused by removing the __GFP_NORETRY 
> > from thp allocations in commit 2516035499b9?
> 
> Yes, because relying on __GFP_NORETRY for the oom handling has proven to
> be subtle and error prone. And as I've repeated few times already there
> is _no_ reason why the oom policy for the memcg charge should be any
> different from the allocator's one.
> 

The PAGE_ALLOC_COSTLY_ORDER oom heuristic in the page allocator is about 
the unlikelihood of freeing contiguous memory.  It was added around the 
same time I added the oom heuristic to prevent killing processes for 
lowmem because of the unlikelihood of freeing lowmem.

If lowmem is accounted to a memcg, would you avoid oom kill in that 
scenario too, just for the sake of matching the page allocator?  Of course 
not.

The argument is absurd, I'm sorry.  Charging 32KB of memory allows the 
memcg oom killer but magically 64KB of memory automatically fails and the 
charging path has no ability to override that because you've made it part 
of the charge path.  There is no __GFP_RETRY.  Making blanket claims that 
high-order charges should never oom kill and that you know better than the 
caller, and that you don't think the caller knows what they are doing wrt 
__GFP_NORETRY, is more dangerous imo than the potential benefit from what 
you are proposing.

> They simply cannot because kmalloc performs the change under the cover.
> So you would have to use kmalloc(gfp|__GFP_NORETRY) to be absolutely
> sure to not trigger _any_ oom killer. This is just wrong thing to do.
> 

Examples of where this isn't already done?  It certainly wasn't a problem 
before __GFP_NORETRY was dropped in commit 2516035499b9 but you suspect 
it's a problem now.

> > You're diverging from it because the memcg charge path has never had this 
> > heuristic.
> 
> Which is arguably a bug which just didn't matter because we do not
> have costly order oom eligible charges in general and THP was subtly
> different and turned out to be error prone.
> 

It was inadvertently dropped from commit 2516035499b9.  There were no 
high-order charge oom kill problems before this commit.  People know how 
to use __GFP_NORETRY or leave it off, which you don't trust them to do 
because you're hardcoding a heuristic in the charge path.  You also acked 
the commit that introduced this "error prone" problem.  Before you start 
to advertise that you know better than what previously worked just fine, 
let's fix the issue that was introduced by that commit and then you can 
propose a follow-up patch that changes the charge heuristic and it can 
stand on its own merits.

> > I'm somewhat stunned this has to be repeated: 
> > PAGE_ALLOC_COSTLY_ORDER is about the ability to allocate _contiguous_ 
> > memory, it's not about the _amount_ of memory.  Changing the memcg charge 
> > path to factor order into oom kill decisions is new, and should be 
> > proposed as a follow-up patch to my bug fix to describe what else is being 
> > impacted by your patch and what is fixed by it.
> > 
> > Yours is a heuristic change, mine is a bug fix.
> 
> Nobody is really arguing about this. I have just pointed out my
> reservation that your bug fix is adding more special casing and a more
> generic solution is due.

Dude, it's setting a bit that the problem commit dropped.  That's it.  I'm 
setting a bit.

> If you absolutely believe that your bugfix is
> so important to make it to rc7 I will not object. It is however strange
> that we haven't seen a _single_ bug report in last two years about this
> being a problem. So I am not really sure the urgency is due.
> 

You're not really sure about the urgency but you were "tempted to mark 
this for stable" for your heuristic "fix"?

> > Your change is broken and I wouldn't push it to Linus for rc7 if my life 
> > depended on it.  What is the response when someone complains that they 
> > start getting a ton of MEMCG_OOM notifications for every thp fallback?
> > They will, because yours is a broken implementation.
> 
> I fail to see what is broken. Could you be more specific?
>  

I said MEMCG_OOM notifications on thp fallback.  You modified 
mem_cgroup_oom().  What is called before mem_cgroup_oom()?  
mem_cgroup_event(mem_over_limit, MEMCG_OOM).  That increments the 
MEMCG_OOM event and anybody waiting on the events file gets notified it 
changed.  They read a MEMCG_OOM event.  It's thp fallback, it's not memcg 
oom.

Really, I can't continue to write 100 emails in this thread.  I'm sorry, 
but there are only so many hours in a day.  I can't read 20 emails about 
why Tetsuo shouldn't emit a stack trace when the oom reaper fails, which 
happens 0.04% of the time on production workloads with data I provided.  I 
can't continue to reiterate why we added the PAGE_ALLOC_COSTLY_ORDER 
heuristic to the allocator.  I'm done.

> > Respectfully, allow the bugfix to fix what was obviously left off from 
> > commit 2516035499b9.
> 
> I haven't nacked the patch AFAIR so nothing really prevents it from
> being merged.
> 

It should be merged for rc7.  Please send any follow-up policy change wrt 
to high-order charges as a separate patch for 4.17.
