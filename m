Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B19D6B0022
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 17:41:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d37so3208233wrd.21
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:41:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q138si3393676wmb.233.2018.03.21.14.41.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 14:41:06 -0700 (PDT)
Date: Wed, 21 Mar 2018 22:41:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, thp: do not invoke oom killer on thp charges
Message-ID: <20180321214104.GT23100@dhcp22.suse.cz>
References: <20180321205928.22240-1-mhocko@kernel.org>
 <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803211418170.107059@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 21-03-18 14:22:13, David Rientjes wrote:
> On Wed, 21 Mar 2018, Michal Hocko wrote:
> 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index d1a917b5b7b7..08accbcd1a18 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1493,7 +1493,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
> >  
> >  static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> >  {
> > -	if (!current->memcg_may_oom)
> > +	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
> >  		return;
> >  	/*
> >  	 * We are in the middle of the charge context here, so we
> 
> What bug reports have you received about order-4 and higher order non thp 
> charges that this fixes?

We do not have any costly _OOM killable_ allocations but THP AFAIR. Or
am I missing any?

> The patch title and the changelog specifically single out thp, which I've 
> fixed, since it has sane fallback behavior and everything else uses 
> __GFP_NORETRY.  I think this is misusing a page allocator heuristic that 
> hasn't been applied to the memcg charge path before to address a thp 
> regression but generalizing it for all charges.

Yes, which is the whole point! We do not want a THP specific workaround.
Just look at the bug your original patch was fixing. The regression was
caused by a change which generalizes gfp masks for THP because different
policies imply a different effort. As a side effect THP charges got OOM
killable. I would call it quite non intuitive and error prone.

> PAGE_ALLOC_COSTLY_ORDER is a heuristic used by the page allocator because 
> it cannot free high-order contiguous memory.  Memcg just needs to reclaim 
> a number of pages.  Two order-3 charges can cause a memcg oom kill but now 
> an order-4 charge cannot.  It's an unfair bias against high-order charges 
> that are not explicitly using __GFP_NORETRY.

PAGE_ALLOC_COSTLY_ORDER is documented and people know what to expect
from such a request. Diverging from that behavior just comes as a
surprise. There is no reason for that and as the above outlines it is
error prone.

-- 
Michal Hocko
SUSE Labs
