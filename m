Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2436B0075
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 18:40:17 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so10697793yha.21
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:40:17 -0800 (PST)
Received: from mail-yh0-x236.google.com (mail-yh0-x236.google.com [2607:f8b0:4002:c01::236])
        by mx.google.com with ESMTPS id i10si24400766yhg.175.2013.12.03.15.40.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 15:40:16 -0800 (PST)
Received: by mail-yh0-f54.google.com with SMTP id z12so10909822yhz.27
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:40:16 -0800 (PST)
Date: Tue, 3 Dec 2013 15:40:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
In-Reply-To: <20131203222511.GU3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1312031531510.5946@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311261658170.21003@chino.kir.corp.google.com> <alpine.DEB.2.02.1311261931210.5973@chino.kir.corp.google.com> <20131127163916.GB3556@cmpxchg.org> <alpine.DEB.2.02.1311271336220.9222@chino.kir.corp.google.com> <20131127225340.GE3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271526080.22848@chino.kir.corp.google.com> <20131128102049.GF2761@dhcp22.suse.cz> <alpine.DEB.2.02.1311291543400.22413@chino.kir.corp.google.com> <20131202132201.GC18838@dhcp22.suse.cz> <alpine.DEB.2.02.1312021452510.13465@chino.kir.corp.google.com>
 <20131203222511.GU3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 3 Dec 2013, Johannes Weiner wrote:

> > > Spin on which level? The whole point of this change was to not spin for
> > > ever because the caller might sit on top of other locks which might
> > > prevent somebody else to die although it has been killed.
> > 
> > See my question about the non-memcg page allocator behavior below.
> 
> No, please answer the question.
> 

The question would be answered below, by having consistency in allocation 
and charging paths between both the page allocator and memcg.

> > I'm not quite sure how significant of a point this is, though, because it 
> > depends on the caller doing the __GFP_NOFAIL allocations that allow the 
> > bypass.  If you're doing
> > 
> > 	for (i = 0; i < 1 << 20; i++)
> > 		page[i] = alloc_page(GFP_NOFS | __GFP_NOFAIL);
> 
> Hyperbole serves no one.
> 

Since this bypasses all charges to the root memcg in oom conditions as a 
result of your patch, how do you ensure the "leakage" is contained to a 
small amount of memory?  Are we currently just trusting the users of 
__GFP_NOFAIL that they aren't allocating a large amount of memory?

> > I'm referring to the generic non-memcg page allocator behavior.  Forget 
> > memcg for a moment.  What is the behavior in the _page_allocator_ for 
> > GFP_NOFS | __GFP_NOFAIL?  Do we spin forever if reclaim fails or do we 
> > bypas the per-zone min watermarks to allow it to allocate because "it 
> > needs to succeed, it may be holding filesystem locks"?
> > 
> > It's already been acknowledged in this thread that no bypassing is done 
> > in the page allocator and it just spins.  There's some handwaving saying 
> > that since the entire system is oom that there is a greater chance that 
> > memory will be freed by something else, but that's just handwaving and is 
> > certainly no guaranteed.
> 
> Do you have another explanation of why this deadlock is not triggering
> in the global case?  It's pretty obvious that there is a deadlock that
> can not be resolved unless some unrelated task intervenes, just read
> __alloc_pages_slowpath().
> 
> But we had a concrete bug report for memcg where there was no other
> task to intervene.  One was stuck in the OOM killer waiting for the
> victim to exit, the victim was stuck on locks that the killer held.
> 

I believe the page allocator would be susceptible to the same deadlock if 
nothing else on the system can reclaim memory and that belief comes from 
code inspection that shows __GFP_NOFAIL is not guaranteed to ever succeed 
in the page allocator as their charges now are (with your patch) in memcg.  
I do not have an example of such an incident.

> > So, my question again: why not bypass the per-zone min watermarks in the 
> > page allocator?
> 
> I don't even know what your argument is supposed to be.  The fact that
> we don't do it in the page allocator means that there can't be a bug
> in memcg?
> 

I'm asking if we should allow GFP_NOFS | __GFP_NOFAIL allocations in the 
page allocator to bypass per-zone min watermarks after reclaim has failed 
since the oom killer cannot be called in such a context so that the page 
allocator is not susceptible to the same deadlock without a complete 
depletion of memory reserves?

It's not an argument, it's a question.  Relax.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
