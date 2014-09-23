Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id AF28F6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 07:48:32 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id fb4so4415735wid.0
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 04:48:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ba7si14531879wjb.133.2014.09.23.04.48.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 04:48:31 -0700 (PDT)
Date: Tue, 23 Sep 2014 07:48:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: support transparent huge pages under
 pressure
Message-ID: <20140923114827.GB13593@cmpxchg.org>
References: <1411132840-16025-1-git-send-email-hannes@cmpxchg.org>
 <xr934mvykgiv.fsf@gthelen.mtv.corp.google.com>
 <20140923082927.GG18526@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140923082927.GG18526@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 23, 2014 at 12:29:27PM +0400, Vladimir Davydov wrote:
> [sorry for butting in, but I think I can answer your question]
> 
> On Mon, Sep 22, 2014 at 10:52:50PM -0700, Greg Thelen wrote:
> > 
> > On Fri, Sep 19 2014, Johannes Weiner wrote:
> > 
> > > In a memcg with even just moderate cache pressure, success rates for
> > > transparent huge page allocations drop to zero, wasting a lot of
> > > effort that the allocator puts into assembling these pages.
> > >
> > > The reason for this is that the memcg reclaim code was never designed
> > > for higher-order charges.  It reclaims in small batches until there is
> > > room for at least one page.  Huge pages charges only succeed when
> > > these batches add up over a series of huge faults, which is unlikely
> > > under any significant load involving order-0 allocations in the group.
> > >
> > > Remove that loop on the memcg side in favor of passing the actual
> > > reclaim goal to direct reclaim, which is already set up and optimized
> > > to meet higher-order goals efficiently.
> > >
> > > This brings memcg's THP policy in line with the system policy: if the
> > > allocator painstakingly assembles a hugepage, memcg will at least make
> > > an honest effort to charge it.  As a result, transparent hugepage
> > > allocation rates amid cache activity are drastically improved:
> > >
> > >                                       vanilla                 patched
> > > pgalloc                 4717530.80 (  +0.00%)   4451376.40 (  -5.64%)
> > > pgfault                  491370.60 (  +0.00%)    225477.40 ( -54.11%)
> > > pgmajfault                    2.00 (  +0.00%)         1.80 (  -6.67%)
> > > thp_fault_alloc               0.00 (  +0.00%)       531.60 (+100.00%)
> > > thp_fault_fallback          749.00 (  +0.00%)       217.40 ( -70.88%)
> > >
> > > [ Note: this may in turn increase memory consumption from internal
> > >   fragmentation, which is an inherent risk of transparent hugepages.
> > >   Some setups may have to adjust the memcg limits accordingly to
> > >   accomodate this - or, if the machine is already packed to capacity,
> > >   disable the transparent huge page feature. ]
> > 
> > We're using an earlier version of this patch, so I approve of the
> > general direction.  But I have some feedback.
> > 
> > The memsw aspect of this change seems somewhat separate.  Can it be
> > split into a different patch?
> > 
> > The memsw aspect of this patch seems to change behavior.  Is this
> > intended?  If so, a mention of it in the commit log would assuage the
> > reader.  I'll explain...  Assume a machine with swap enabled and
> > res.limit==memsw.limit, thus memsw_is_minimum is true.  My understanding
> > is that memsw.usage represents sum(ram_usage, swap_usage).  So when
> > memsw_is_minimum=true, then both swap_usage=0 and
> > memsw.usage==res.usage. 
> 
> Not necessarily, we can have memsw.usage > res.usage due to global
> pressure. The point is (memsw.limit-res.limit) is not the swap usage
> limit. This is really confusing. As Johannes pointed out, we should drop
> memsw.limit in favor of separate mem.limit and swap.limit.

Memsw can exceed memory, but not the other way round, so if the limits
are equal and we hit the memory limit, surely the memsw limit must be
hit as well?

> > In this condition, if res usage is at limit then there's no point in
> > swapping because memsw.usage is already maximal.  Prior to this patch
> > I think the kernel did the right thing, but not afterwards.
> > 
> > Before this patch:
> >   if res.usage == res.limit, try_charge() indirectly calls
> >   try_to_free_mem_cgroup_pages(noswap=true)
> 
> But this is wrong. If we fail to charge res, we should try to do swap
> out along with page cache reclaim. Swap out won't affect memsw.usage,
> but will diminish res.usage so that the allocation may succeed.

But we know that the memsw limit must be hit as well in that case, and
swapping only makes progress in the sense that we are then succeeding
the memory charge.  But we still fail to charge memsw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
