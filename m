Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC1516B0005
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:37:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h11so3164688pfn.0
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:37:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b70sor1438428pfd.148.2018.03.21.12.37.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 12:37:12 -0700 (PDT)
Date: Wed, 21 Mar 2018 12:37:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: do not cause memcg oom for thp
In-Reply-To: <20180321082228.GC23100@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1803211212490.92011@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803191409420.124411@chino.kir.corp.google.com> <20180320071624.GB23100@dhcp22.suse.cz> <alpine.DEB.2.20.1803201321430.167205@chino.kir.corp.google.com> <20180321082228.GC23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Mar 2018, Michal Hocko wrote:

> > I'm not sure of the expectation of high-order memcg charging without 
> > __GFP_NORETRY,
> 
> It should be semantically compatible with the allocation path.
> 

That doesn't make sense, the allocation path needs to allocate contiguous 
memory for the high order, the charging path just needs to charge a number 
of pages.  Why would the allocation and charging path be compatible when 
one needs to reclaim contiguous memory or compact memory and the the other 
just needs to reclaim any memory?

> > I only know that khugepaged can now cause memcg oom kills 
> > when trying to collapse memory, and then subsequently found that the same 
> > situation exists for faulting instead of falling back to small pages.
> 
> And that is clearly a bug because page allocator doesn't oom kill while
> the memcg charge does for the same gfp flag. That should be fixed.
> 

It's fixed with my patch, yes.  The page allocator doesn't oom kill for 
orders over PAGE_ALLOC_COSTLY_ORDER only because it is unlikely to free 
order-4 and higher contiguous memory as a result; it's in the name, it's a 
costly order for the page allocator.  Using it as a heuristic in the memcg 
charging path seems strange.

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
> > That may make sense as an additional patch, but for thp allocations we 
> > don't want to retry reclaim nr_retries times anyway; we want the old 
> > behavior of __GFP_NORETRY before commit 2516035499b9.
> 
> Why? Allocation and the charge path should use the same gfp mask unless
> there is a strong reason for it. If you have one then please mention it
> in the changelog.
> 

It shouldn't use the same gfp mask for thp allocations because the page 
allocator needs to allocate contiguous memory and mem cgroup just needs to 
charge a number of pages.  Khugepaged will fail the allocation without 
reclaim or compaction if its defrag setting does not allow it.  If defrag 
is allowed, the page allocator policy is that oom kill is unlikely to free 
order-4 and above contiguous memory without killing multiple victims.  
That's not the case with the memcg charging path: oom killing a process 
will always uncharge memory, it need not be contiguous.  When we lost 
__GFP_NORETRY because of a page allocator change to better distinguish thp 
allocations, it left the door open to oom killing for thp through the 
charge path when fallback is possible.

Specifying __GFP_NORETRY for the page allocator for thp allocations would 
prematurely cause them to fail depending on the defrag settings.  The page 
allocator implementation always prevents oom kill for these allocations 
with or without the bit.  Specifying it for the charging path allows it to 
fail without oom kill and relies specifically on the bit.  Trying to 
introduce a page allocator-like heuristic to the charge path, which 
doesn't require contiguous memory, based on order so it wouldn't need 
__GFP_NORETRY would be a separate change.
