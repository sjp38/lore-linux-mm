Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id B0F846B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 19:00:21 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so7152786yha.11
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 16:00:21 -0800 (PST)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id x27si37953868yhk.136.2013.11.29.16.00.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 16:00:15 -0800 (PST)
Received: by mail-yh0-f51.google.com with SMTP id c41so5573160yho.24
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 16:00:15 -0800 (PST)
Date: Fri, 29 Nov 2013 16:00:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [merged] mm-memcg-handle-non-error-oom-situations-more-gracefully.patch
 removed from -mm tree
In-Reply-To: <20131128035218.GM3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311291546370.22413@chino.kir.corp.google.com>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org> <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com> <20131127233353.GH3556@cmpxchg.org> <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com> <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com> <20131128031313.GK3556@cmpxchg.org> <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com> <20131128035218.GM3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Nov 2013, Johannes Weiner wrote:

> > None that I am currently aware of, I'll continue to try them out.  I'd 
> > suggest just dropping the stable@kernel.org from the whole series though 
> > unless there is another report of such a problem that people are running 
> > into.
> 
> The series has long been merged, how do we drop stable@kernel.org from
> it?
> 

You said you have informed stable to not merge these patches until further 
notice, I'd suggest simply avoid ever merging the whole series into a 
stable kernel since the problem isn't serious enough.  Marking changes 
that do "goto nomem" seem fine to mark for stable, though.

> > We've had this patch internally since we started using memcg, it has 
> > avoided some unnecessary oom killing.
> 
> Do you have quantified data that OOM kills are reduced over a longer
> sampling period?  How many kills are skipped?  How many of them are
> deferred temporarily but the VM ended up having to kill something
> anyway?

On the scale that we run memcg, we would see it daily in automated testing 
primarily because we panic the machine for memcg oom conditions where 
there are no killable processes.  It would typically manifest by two 
processes that are allocating memory in a memcg; one is oom killed, is 
allowed to allocate, handles its SIGKILL, exits and frees its memory and 
the second process which is oom disabled races with the uncharge and is 
oom disabled so the machine panics.

The upstream kernel of course doesn't panic in such a condition but if the 
same scenario were to have happened, the second process would be 
unnecessarily oom killed because it raced with the uncharge of the first 
victim and it had exited before the scan of processes in the memcg oom 
killer could detect it and defer.  So this patch definitely does prevent 
unnecessary oom killing when run at such a large scale that we do.

I'll send a formal patch.

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1836,6 +1836,13 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >  	if (!chosen)
> >  		return;
> >  	points = chosen_points * 1000 / totalpages;
> > +
> > +	/* One last chance to see if we really need to kill something */
> > +	if (mem_cgroup_margin(memcg) >= (1 << order)) {
> > +		put_task_struct(chosen);
> > +		return;
> > +	}
> > +
> >  	oom_kill_process(chosen, gfp_mask, order, points, totalpages, memcg,
> >  			 NULL, "Memory cgroup out of memory");
> >  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
