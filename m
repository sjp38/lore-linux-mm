Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0888E6B0006
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 11:31:52 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 33-v6so2738256wrb.12
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:31:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 74-v6si1420679wme.14.2018.06.20.08.31.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 08:31:50 -0700 (PDT)
Date: Wed, 20 Jun 2018 17:31:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memcg, oom: move out_of_memory back to the charge
 path
Message-ID: <20180620153148.GO13685@dhcp22.suse.cz>
References: <20180620103736.13880-1-mhocko@kernel.org>
 <20180620151812.GA2441@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180620151812.GA2441@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-06-18 11:18:12, Johannes Weiner wrote:
> On Wed, Jun 20, 2018 at 12:37:36PM +0200, Michal Hocko wrote:
[...]
> > -static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> > +enum oom_status {
> > +	OOM_SUCCESS,
> > +	OOM_FAILED,
> > +	OOM_ASYNC,
> > +	OOM_SKIPPED
> 
> Either SUCCESS & FAILURE, or SUCCEEDED & FAILED ;)

sure, I will go with later.

> We're not distinguishing ASYNC and SKIPPED anywhere below, but I
> cannot think of a good name to communicate them both without this
> function making assumptions about the charge function's behavior.
> So it's a bit weird, but probably the best way to go.

Yeah, that was what I was fighting with. My original proposal which
simply ENOMEM in the failure case was a simple bool but once we have
those different sates and failure behavior I think it is better to
comunicate that and let the caller do whatever it finds reasonable.

> 
> > +static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> >  {
> > -	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
> > -		return;
> > +	if (order > PAGE_ALLOC_COSTLY_ORDER)
> > +		return OOM_SKIPPED;
> >  	/*
> >  	 * We are in the middle of the charge context here, so we
> >  	 * don't want to block when potentially sitting on a callstack
> >  	 * that holds all kinds of filesystem and mm locks.
> >  	 *
> > -	 * Also, the caller may handle a failed allocation gracefully
> > -	 * (like optional page cache readahead) and so an OOM killer
> > -	 * invocation might not even be necessary.
> > +	 * cgroup1 allows disabling the OOM killer and waiting for outside
> > +	 * handling until the charge can succeed; remember the context and put
> > +	 * the task to sleep at the end of the page fault when all locks are
> > +	 * released.
> > +	 *
> > +	 * On the other hand, in-kernel OOM killer allows for an async victim
> > +	 * memory reclaim (oom_reaper) and that means that we are not solely
> > +	 * relying on the oom victim to make a forward progress and we can
> > +	 * invoke the oom killer here.
> >  	 *
> > -	 * That's why we don't do anything here except remember the
> > -	 * OOM context and then deal with it at the end of the page
> > -	 * fault when the stack is unwound, the locks are released,
> > -	 * and when we know whether the fault was overall successful.
> > +	 * Please note that mem_cgroup_oom_synchronize might fail to find a
> > +	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
> > +	 * we would fall back to the global oom killer in pagefault_out_of_memory
> >  	 */
> > +	if (!memcg->oom_kill_disable) {
> > +		if (mem_cgroup_out_of_memory(memcg, mask, order))
> > +			return OOM_SUCCESS;
> > +
> > +		WARN(!current->memcg_may_oom,
> > +				"Memory cgroup charge failed because of no reclaimable memory! "
> > +				"This looks like a misconfiguration or a kernel bug.");
> > +		return OOM_FAILED;
> > +	}
> > +
> > +	if (!current->memcg_may_oom)
> > +		return OOM_SKIPPED;
> 
> memcg_may_oom was introduced to distinguish between userspace faults
> that can OOM and contexts that return -ENOMEM. Now we're using it
> slightly differently and it's confusing.
> 
> 1) Why warn for kernel allocations, but not userspace ones? This
> should have a comment at least.

I am not sure I understand. We do warn for all allocations types of
mem_cgroup_out_of_memory fails as long as we are not in a legacy -
oom_disabled case.

> 2) We invoke the OOM killer when !memcg_may_oom. We want to OOM kill
> in either case, but only set up the mem_cgroup_oom_synchronize() for
> userspace faults. So the code makes sense, but a better name would be
> in order -- current->in_user_fault?

in_user_fault is definitely better than memcg_may_oom.

> >  	css_get(&memcg->css);
> >  	current->memcg_in_oom = memcg;
> >  	current->memcg_oom_gfp_mask = mask;
> >  	current->memcg_oom_order = order;
> > +
> > +	return OOM_ASYNC;
> 
> In terms of code flow, it would be much clearer to handle the
> memcg->oom_kill_disable case first, as a special case with early
> return, and make the OOM invocation the main code of this function,
> given its name.

This?
	if (order > PAGE_ALLOC_COSTLY_ORDER)
		return OOM_SKIPPED;

	/*
	 * We are in the middle of the charge context here, so we
	 * don't want to block when potentially sitting on a callstack
	 * that holds all kinds of filesystem and mm locks.
	 *
	 * cgroup1 allows disabling the OOM killer and waiting for outside
	 * handling until the charge can succeed; remember the context and put
	 * the task to sleep at the end of the page fault when all locks are
	 * released.
	 *
	 * On the other hand, in-kernel OOM killer allows for an async victim
	 * memory reclaim (oom_reaper) and that means that we are not solely
	 * relying on the oom victim to make a forward progress and we can
	 * invoke the oom killer here.
	 *
	 * Please note that mem_cgroup_oom_synchronize might fail to find a
	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
	 * we would fall back to the global oom killer in pagefault_out_of_memory
	 */
	if (memcg->oom_kill_disable) {
		if (!current->memcg_may_oom)
			return OOM_SKIPPED;
		css_get(&memcg->css);
		current->memcg_in_oom = memcg;
		current->memcg_oom_gfp_mask = mask;
		current->memcg_oom_order = order;

		return OOM_ASYNC;
	}

	if (mem_cgroup_out_of_memory(memcg, mask, order))
		return OOM_SUCCESS;

	WARN(!current->memcg_may_oom,
			"Memory cgroup charge failed because of no reclaimable memory! "
			"This looks like a misconfiguration or a kernel bug.");
	return OOM_FAILED;

Thanks!
-- 
Michal Hocko
SUSE Labs
