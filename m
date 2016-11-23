Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4136B0287
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 10:35:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so7674320wme.4
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 07:35:49 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id 63si3063680wmo.42.2016.11.23.07.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 07:35:47 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id xy5so1306363wjc.1
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 07:35:47 -0800 (PST)
Date: Wed, 23 Nov 2016 16:35:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161123153544.GN2864@dhcp22.suse.cz>
References: <20161123064925.9716-1-mhocko@kernel.org>
 <20161123064925.9716-3-mhocko@kernel.org>
 <201611232335.JFC30797.VOOtOMFJFHLQSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201611232335.JFC30797.VOOtOMFJFHLQSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, mgorman@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 23-11-16 23:35:10, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __alloc_pages_may_oom makes sure to skip the OOM killer depending on
> > the allocation request. This includes lowmem requests, costly high
> > order requests and others. For a long time __GFP_NOFAIL acted as an
> > override for all those rules. This is not documented and it can be quite
> > surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
> > killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
> > the existing open coded loops around allocator to nofail request (and we
> > have done that in the past) then such a change would have a non trivial
> > side effect which is not obvious. Note that the primary motivation for
> > skipping the OOM killer is to prevent from pre-mature invocation.
> > 
> > The exception has been added by 82553a937f12 ("oom: invoke oom killer
> > for __GFP_NOFAIL"). The changelog points out that the oom killer has to
> > be invoked otherwise the request would be looping for ever. But this
> > argument is rather weak because the OOM killer doesn't really guarantee
> > any forward progress for those exceptional cases - e.g. it will hardly
> > help to form costly order - I believe we certainly do not want to kill
> > all processes and eventually panic the system just because there is a
> > nasty driver asking for order-9 page with GFP_NOFAIL not realizing all
> > the consequences - it is much better this request would loop for ever
> > than the massive system disruption, lowmem is also highly unlikely to be
> > freed during OOM killer and GFP_NOFS request could trigger while there
> > is still a lot of memory pinned by filesystems.
> > 
> > This patch simply removes the __GFP_NOFAIL special case in order to have
> > a more clear semantic without surprising side effects. Instead we do
> > allow nofail requests to access memory reserves to move forward in both
> > cases when the OOM killer is invoked and when it should be supressed.
> > __alloc_pages_nowmark helper has been introduced for that purpose.
> 
> __alloc_pages_nowmark() likely works if order is 0, but there is no
> guarantee that __alloc_pages_nowmark() can find order > 0 pages.

Yes and it is not meant to be a guarantee. We are just trying to help
them out.

> If __alloc_pages_nowmark() called by __GFP_NOFAIL could not find pages
> with requested order due to fragmentation, __GFP_NOFAIL should invoke
> the OOM killer. I believe that risking kill all processes and panic the
> system eventually is better than __GFP_NOFAIL livelock.

I violently disagree. Just imagine a driver which asks for an order-9
page and cannot really continue without it so it uses GFP_NOFAIL. There
is absolutely no reason to disrupt or even put the whole system down
just because of this particular request. It might take for ever to
continue but that is to be expected when asking for such a hard
requirement.

> I'm not happy that the caller cannot invoke the OOM killer unless __GFP_FS
> or __GFP_NOFAIL is specified. I think we should get rid of the concept of
> premature OOM killer invocation.

I am not happy about GFP_NOFS situation either but this is far from
trivial to solve and certainly outside of the scope of these patches.
But as the matter of fact GFP_NOFS context currently might lead to
pre-mature OOMs which are no-go for most users. Allowing __GFP_NOFAIL
to override this will just lead to hit those pre-mature OOMs too easily.

> That is, whenever requested pages cannot
> be allocated and the caller does not want to fail, invoking the OOM killer
> is no longer premature.

This is only true for the full reclaim contexts which GFP_NOFS is not.

> Unfortunately, there seems to be cases where the
> caller needs to use GFP_NOFS rather than GFP_KERNEL due to unclear dependency
> between memory allocation by system calls and memory reclaim by filesystems.

I do not understand your point here. Syscall is an entry point to the
kernel where we cannot recurse to the FS code so GFP_NOFS seems wrong
thing to ask.

> But memory reclaim by filesystems are not the fault of userspace processes
> which issued system calls. It is unfair to force legitimate processes to fail
> system calls with ENOMEM when GFP_NOFS is used inside system calls instead of
> killing memory hog processes using the OOM killer. The root cause is that we
> blindly treat all memory allocation requests evenly using the same watermark
> (with rough-grained exceptions such as __GFP_HIGH) and allow lower priority
> memory allocations (e.g. memory for buffered writes) to consume memory to the
> level where higher priority memory allocations (e.g. memory for disk I/O) has
> to retry looping without invoking the OOM killer, instead of using different
> watermarks based on purpose/importance/priority of individual memory
> allocation requests so that higher priority memory allocations can invoke
> the OOM killer.

The priority/importance of the allocation is really subjective. If you
ask every subsystem will claim theirs to be the most important. Gfp mask
has been used to give some constrains for allocations. If you need a
forward progress guarantee then you have to build on top - e.g. use
mempools.

Anyway I fail to see how the above is related to this patch. My main
point here is that GFP_NOFAIL should not override the OOM decisions.

> > @@ -3725,6 +3738,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		 */
> >  		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
> >  
> > +		/*
> > +		 * Help non-failing allocations by giving them access to memory
> > +		 * reserves
> > +		 */
> > +		page = __alloc_pages_nowmark(gfp_mask, order, ac);
> > +		if (page)
> > +			goto got_pg;
> > +
> 
> Should no_progress_loops be reset to 0 before retrying?

Hmm, we might but is it necessary? The OOM path handles that properly
and nothing else but the oom detection really cares about no_progress_loops.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
