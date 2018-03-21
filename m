Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 951CF6B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 04:22:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z14so2158789wrh.1
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 01:22:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4si2375575wmh.9.2018.03.21.01.22.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 01:22:30 -0700 (PDT)
Date: Wed, 21 Mar 2018 09:22:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: do not cause memcg oom for thp
Message-ID: <20180321082228.GC23100@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1803191409420.124411@chino.kir.corp.google.com>
 <20180320071624.GB23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803201321430.167205@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803201321430.167205@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 20-03-18 13:25:23, David Rientjes wrote:
> On Tue, 20 Mar 2018, Michal Hocko wrote:
> 
> > > Commit 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and
> > > madvised allocations") changed the page allocator to no longer detect thp
> > > allocations based on __GFP_NORETRY.
> > > 
> > > It did not, however, modify the mem cgroup try_charge() path to avoid oom
> > > kill for either khugepaged collapsing or thp faulting.  It is never
> > > expected to oom kill a process to allocate a hugepage for thp; reclaim is
> > > governed by the thp defrag mode and MADV_HUGEPAGE, but allocations (and
> > > charging) should fallback instead of oom killing processes.
> > 
> > For some reason I thought that the charging path simply bails out for
> > costly orders - effectively the same thing as for the global OOM killer.
> > But we do not. Is there any reason to not do that though? Why don't we
> > simply do
> > 
> 
> I'm not sure of the expectation of high-order memcg charging without 
> __GFP_NORETRY,

It should be semantically compatible with the allocation path.

> I only know that khugepaged can now cause memcg oom kills 
> when trying to collapse memory, and then subsequently found that the same 
> situation exists for faulting instead of falling back to small pages.

And that is clearly a bug because page allocator doesn't oom kill while
the memcg charge does for the same gfp flag. That should be fixed.

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
> That may make sense as an additional patch, but for thp allocations we 
> don't want to retry reclaim nr_retries times anyway; we want the old 
> behavior of __GFP_NORETRY before commit 2516035499b9.

Why? Allocation and the charge path should use the same gfp mask unless
there is a strong reason for it. If you have one then please mention it
in the changelog.

> So the above would be a follow-up patch that wouldn't replace mine.

Unless there is a strong reason to use different gfp mask for the
allocation and the charge then your fix is actually wrong.
-- 
Michal Hocko
SUSE Labs
