Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BEE756B0006
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 04:56:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 31so3964150wrr.2
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 01:56:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y13si4378946wrh.82.2018.03.22.01.56.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 01:56:14 -0700 (PDT)
Date: Thu, 22 Mar 2018 09:56:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, thp: do not invoke oom killer on thp charges
Message-ID: <20180322085611.GY23100@dhcp22.suse.cz>
References: <20180321205928.22240-1-mhocko@kernel.org>
 <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com>
 <20180321214104.GT23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803220106010.175961@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803220106010.175961@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 22-03-18 01:26:13, David Rientjes wrote:
> On Wed, 21 Mar 2018, Michal Hocko wrote:
> 
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index d1a917b5b7b7..08accbcd1a18 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -1493,7 +1493,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
> > > >  
> > > >  static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> > > >  {
> > > > -	if (!current->memcg_may_oom)
> > > > +	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
> > > >  		return;
> > > >  	/*
> > > >  	 * We are in the middle of the charge context here, so we
> > > 
> > > What bug reports have you received about order-4 and higher order non thp 
> > > charges that this fixes?
> > 
> > We do not have any costly _OOM killable_ allocations but THP AFAIR. Or
> > am I missing any?
> > 
> 
> So now you're making a generalized policy change to the memcg charge path 
> to fix what is obviously only thp and caused by removing the __GFP_NORETRY 
> from thp allocations in commit 2516035499b9?

Yes, because relying on __GFP_NORETRY for the oom handling has proven to
be subtle and error prone. And as I've repeated few times already there
is _no_ reason why the oom policy for the memcg charge should be any
different from the allocator's one.

> I don't know what orders 
> people enforce for slub_min_order.  I assume that people who don't want to 
> cause a memcg oom kill are using __GFP_NORETRY because that's how it has 
> always worked.  The fact that the page allocator got more sophisticated 
> logic for the various thp fault and defrag policies doesn't change that.

They simply cannot because kmalloc performs the change under the cover.
So you would have to use kmalloc(gfp|__GFP_NORETRY) to be absolutely
sure to not trigger _any_ oom killer. This is just wrong thing to do.

> You're implementing the exact same behavior that commit 2516035499b9 was 
> trying to avoid; it's trying to avoid special-casing thp in general logic. 

It is not trying to special case THP. It special cases _all_ costly
charges.

> order > PAGE_ALLOC_COSTLY_ORDER is a terrible heuristic to identify thp 
> allocations.
> 
> > > PAGE_ALLOC_COSTLY_ORDER is a heuristic used by the page allocator because 
> > > it cannot free high-order contiguous memory.  Memcg just needs to reclaim 
> > > a number of pages.  Two order-3 charges can cause a memcg oom kill but now 
> > > an order-4 charge cannot.  It's an unfair bias against high-order charges 
> > > that are not explicitly using __GFP_NORETRY.
> > 
> > PAGE_ALLOC_COSTLY_ORDER is documented and people know what to expect
> > from such a request. Diverging from that behavior just comes as a
> > surprise. There is no reason for that and as the above outlines it is
> > error prone.
> > 
> 
> You're diverging from it because the memcg charge path has never had this 
> heuristic.

Which is arguably a bug which just didn't matter because we do not
have costly order oom eligible charges in general and THP was subtly
different and turned out to be error prone.

> I'm somewhat stunned this has to be repeated: 
> PAGE_ALLOC_COSTLY_ORDER is about the ability to allocate _contiguous_ 
> memory, it's not about the _amount_ of memory.  Changing the memcg charge 
> path to factor order into oom kill decisions is new, and should be 
> proposed as a follow-up patch to my bug fix to describe what else is being 
> impacted by your patch and what is fixed by it.
> 
> Yours is a heuristic change, mine is a bug fix.

Nobody is really arguing about this. I have just pointed out my
reservation that your bug fix is adding more special casing and a more
generic solution is due. If you absolutely believe that your bugfix is
so important to make it to rc7 I will not object. It is however strange
that we haven't seen a _single_ bug report in last two years about this
being a problem. So I am not really sure the urgency is due.

> Look, commit 2516035499b9 pulled off __GFP_NORETRY for GFP_TRANSHUGE and 
> forgot to fix it up for memcg charging.  I'm setting the bit again to 
> prevent the oom kill.  It's what should be merged for rc7.  I can't make a 
> stable case for it because the stable rules want it to impact more than 
> one user and I haven't seen other bug reports.  It can be backported if 
> others are affected to meet the rules.

Exactly, so why the urgency and having half fix that will preserve the
subtle behavior?
 
> Your change is broken and I wouldn't push it to Linus for rc7 if my life 
> depended on it.  What is the response when someone complains that they 
> start getting a ton of MEMCG_OOM notifications for every thp fallback?
> They will, because yours is a broken implementation.

I fail to see what is broken. Could you be more specific?
 
> I'm trying to fix the problem introduced by commit 2516035499b9 wrt how 
> memcg charges treat high order non-__GFP_NORETRY allocations, and fix it 
> directly with something that is obviously right.  I'm specifically not 
> trying to change heuristics as a bug fix.  Please feel free to send a 
> follow-up patch for 4.17 that lays out why memcg doesn't want to oom kill 
> for order-4 and above (why does memcg fail for 64KB charges when the 
> caller specifically left off __GFP_NORETRY again?) as a policy change and 
> why that is helpful.
> 
> Respectfully, allow the bugfix to fix what was obviously left off from 
> commit 2516035499b9.

I haven't nacked the patch AFAIR so nothing really prevents it from
being merged.

-- 
Michal Hocko
SUSE Labs
