Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A90C56B025F
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:10:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b192so16734555pga.14
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 05:10:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o128si1549427pfg.292.2017.10.31.05.10.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 05:10:35 -0700 (PDT)
Date: Tue, 31 Oct 2017 13:10:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after
 selecting an OOM victim.
Message-ID: <20171031121032.lm3wxx3l5tkpo2ni@dhcp22.suse.cz>
References: <1509178029-10156-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171030141815.lk76bfetmspf7f4x@dhcp22.suse.cz>
 <201710311940.FDJ52199.OHMtSFVFOJLOQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710311940.FDJ52199.OHMtSFVFOJLOQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

On Tue 31-10-17 19:40:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > +struct page *alloc_pages_before_oomkill(struct oom_control *oc)
> > > +{
> > > +	/*
> > > +	 * Make sure that this allocation attempt shall not depend on
> > > +	 * __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation, for the caller is
> > > +	 * already holding oom_lock.
> > > +	 */
> > > +	const gfp_t gfp_mask = oc->gfp_mask & ~__GFP_DIRECT_RECLAIM;
> > > +	struct alloc_context *ac = oc->ac;
> > > +	unsigned int alloc_flags = gfp_to_alloc_flags(gfp_mask);
> > > +	const int reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
> > > +
> > > +	/* Need to update zonelist if selected as OOM victim. */
> > > +	if (reserve_flags) {
> > > +		alloc_flags = reserve_flags;
> > > +		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> > > +		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> > > +					ac->high_zoneidx, ac->nodemask);
> > > +	}
> > 
> > Why do we need this zone list rebuilding?
> 
> Why we do _not_ need this zone list rebuilding?
> 
> The reason I used __alloc_pages_slowpath() in alloc_pages_before_oomkill() is
> to avoid duplicating code (such as checking for ALLOC_OOM and rebuilding zone
> list) which needs to be maintained in sync with __alloc_pages_slowpath().
>
> If you don't like calling __alloc_pages_slowpath() from
> alloc_pages_before_oomkill(), I'm OK with calling __alloc_pages_nodemask()
> (with __GFP_DIRECT_RECLAIM/__GFP_NOFAIL cleared and __GFP_NOWARN set), for
> direct reclaim functions can call __alloc_pages_nodemask() (with PF_MEMALLOC
> set in order to avoid recursion of direct reclaim).
> 
> We are rebuilding zone list if selected as an OOM victim, for
> __gfp_pfmemalloc_flags() returns ALLOC_OOM if oom_reserves_allowed(current)
> is true.

So your answer is copy&paste without a deeper understanding, righ?

[...]

> The reason I'm proposing this "mm,oom: Try last second allocation before and
> after selecting an OOM victim." is that since oom_reserves_allowed(current) can
> become true when current is between post __gfp_pfmemalloc_flags(gfp_mask) and
> pre mutex_trylock(&oom_lock), an OOM victim can fail to try ALLOC_OOM attempt
> before selecting next OOM victim when MMF_OOM_SKIP was set quickly.

ENOPARSE. I am not even going to finish this email sorry. This is way
beyond my time budget.

Can you actually come with something that doesn't make ones head explode
and yet describe what the actual problem is and how you deal with it?

E.g something like this
"
OOM killer is invoked after all the reclaim attempts have failed and
there doesn't seem to be a viable chance for the situation to change.
__alloc_pages_may_oom tries to reduce chances of a race during OOM
handling by taking oom lock so only one caller is allowed to really
invoke the oom killer.

__alloc_pages_may_oom also tries last time ALLOC_WMARK_HIGH allocation
request before really invoking out_of_memory handler. This has two
motivations. The first one is explained by the comment and it aims to
catch potential parallel OOM killing and the second one was explained by
Andrea Arcangeli as follows:
: Elaborating the comment: the reason for the high wmark is to reduce
: the likelihood of livelocks and be sure to invoke the OOM killer, if
: we're still under pressure and reclaim just failed. The high wmark is
: used to be sure the failure of reclaim isn't going to be ignored. If
: using the min wmark like you propose there's risk of livelock or
: anyway of delayed OOM killer invocation.

While both have some merit, the first reason is mostly historical
because we have the explicit locking now and it is really unlikely that
the memory would be available right after we have given up trying.
Last attempt allocation makes some sense of course but considering that
the oom victim selection is quite an expensive operation which can take
a considerable amount of time it makes much more sense to retry the
allocation after the most expensive part rather than before. Therefore
move the last attempt right before we are trying to kill an oom victim
to rule potential races when somebody could have freed a lot of memory
in the meantime. This will reduce the time window for potentially
pre-mature OOM killing considerably.
"
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
