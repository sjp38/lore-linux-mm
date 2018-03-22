Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92D696B0009
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 04:26:16 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p128so3786004pga.19
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 01:26:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y17sor1804414pfl.12.2018.03.22.01.26.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Mar 2018 01:26:15 -0700 (PDT)
Date: Thu, 22 Mar 2018 01:26:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg, thp: do not invoke oom killer on thp charges
In-Reply-To: <20180321214104.GT23100@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1803220106010.175961@chino.kir.corp.google.com>
References: <20180321205928.22240-1-mhocko@kernel.org> <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com> <20180321214104.GT23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 21 Mar 2018, Michal Hocko wrote:

> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index d1a917b5b7b7..08accbcd1a18 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1493,7 +1493,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
> > >  
> > >  static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> > >  {
> > > -	if (!current->memcg_may_oom)
> > > +	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
> > >  		return;
> > >  	/*
> > >  	 * We are in the middle of the charge context here, so we
> > 
> > What bug reports have you received about order-4 and higher order non thp 
> > charges that this fixes?
> 
> We do not have any costly _OOM killable_ allocations but THP AFAIR. Or
> am I missing any?
> 

So now you're making a generalized policy change to the memcg charge path 
to fix what is obviously only thp and caused by removing the __GFP_NORETRY 
from thp allocations in commit 2516035499b9?  I don't know what orders 
people enforce for slub_min_order.  I assume that people who don't want to 
cause a memcg oom kill are using __GFP_NORETRY because that's how it has 
always worked.  The fact that the page allocator got more sophisticated 
logic for the various thp fault and defrag policies doesn't change that.

You're implementing the exact same behavior that commit 2516035499b9 was 
trying to avoid; it's trying to avoid special-casing thp in general logic. 
order > PAGE_ALLOC_COSTLY_ORDER is a terrible heuristic to identify thp 
allocations.

> > PAGE_ALLOC_COSTLY_ORDER is a heuristic used by the page allocator because 
> > it cannot free high-order contiguous memory.  Memcg just needs to reclaim 
> > a number of pages.  Two order-3 charges can cause a memcg oom kill but now 
> > an order-4 charge cannot.  It's an unfair bias against high-order charges 
> > that are not explicitly using __GFP_NORETRY.
> 
> PAGE_ALLOC_COSTLY_ORDER is documented and people know what to expect
> from such a request. Diverging from that behavior just comes as a
> surprise. There is no reason for that and as the above outlines it is
> error prone.
> 

You're diverging from it because the memcg charge path has never had this 
heuristic.  I'm somewhat stunned this has to be repeated: 
PAGE_ALLOC_COSTLY_ORDER is about the ability to allocate _contiguous_ 
memory, it's not about the _amount_ of memory.  Changing the memcg charge 
path to factor order into oom kill decisions is new, and should be 
proposed as a follow-up patch to my bug fix to describe what else is being 
impacted by your patch and what is fixed by it.

Yours is a heuristic change, mine is a bug fix.

Look, commit 2516035499b9 pulled off __GFP_NORETRY for GFP_TRANSHUGE and 
forgot to fix it up for memcg charging.  I'm setting the bit again to 
prevent the oom kill.  It's what should be merged for rc7.  I can't make a 
stable case for it because the stable rules want it to impact more than 
one user and I haven't seen other bug reports.  It can be backported if 
others are affected to meet the rules.

Your change is broken and I wouldn't push it to Linus for rc7 if my life 
depended on it.  What is the response when someone complains that they 
start getting a ton of MEMCG_OOM notifications for every thp fallback?
They will, because yours is a broken implementation.

I'm trying to fix the problem introduced by commit 2516035499b9 wrt how 
memcg charges treat high order non-__GFP_NORETRY allocations, and fix it 
directly with something that is obviously right.  I'm specifically not 
trying to change heuristics as a bug fix.  Please feel free to send a 
follow-up patch for 4.17 that lays out why memcg doesn't want to oom kill 
for order-4 and above (why does memcg fail for 64KB charges when the 
caller specifically left off __GFP_NORETRY again?) as a policy change and 
why that is helpful.

Respectfully, allow the bugfix to fix what was obviously left off from 
commit 2516035499b9.  I don't have time to write 100 emails on it, but 
Andrew can be assured if he chooses to send it for rc7 that my code (1) is 
actually tested, (2) has users that depend on it, and (3) won't cause 
undesired side-effects like yours wrt oom notifications.
