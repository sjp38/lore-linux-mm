Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 89C976B0009
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 04:11:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e130so441222wme.0
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 01:11:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x204si4075648wme.204.2018.03.22.01.11.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 01:11:51 -0700 (PDT)
Date: Thu, 22 Mar 2018 09:11:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: do not cause memcg oom for thp
Message-ID: <20180322081150.GX23100@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1803191409420.124411@chino.kir.corp.google.com>
 <20180320071624.GB23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803201321430.167205@chino.kir.corp.google.com>
 <20180321082228.GC23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803211212490.92011@chino.kir.corp.google.com>
 <20180321204921.GP23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803211422510.107059@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803211422510.107059@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 21-03-18 14:27:10, David Rientjes wrote:
> On Wed, 21 Mar 2018, Michal Hocko wrote:
> 
> > > That doesn't make sense, the allocation path needs to allocate contiguous 
> > > memory for the high order, the charging path just needs to charge a number 
> > > of pages.  Why would the allocation and charging path be compatible when 
> > > one needs to reclaim contiguous memory or compact memory and the the other 
> > > just needs to reclaim any memory?
> > 
> > Because you do not want to see surprises. E.g. seeing unexpected OOMs
> > for large allocatations. Just think about it. Do you really want to have
> > a different reclaim policy for the allocation and charging for all
> > allocating paths?
> 
> It depends on the use of __GFP_NORETRY.  If the high-order charge is 
> __GFP_NORETRY, it does not oom kill.  It is left to the caller.

How does the caller say it when the charge path is hidden inside the
allocator - e.g. inside kmalloc?

> Just 
> because thp allocations have been special cased in the page allocator to 
> be able to remove __GFP_NORETRY without fixing the memcg charge path does 
> not mean memcg needs a special heuristic for high-order memory when it 
> does not require contiguous memory.  You say you don't want any surprises, 
> but now you are changing behavior needlessly for all charges with
> order > PAGE_ALLOC_COSTLY_ORDER that do not use __GFP_NORETRY.

Not really. Only the #PF path is allowed to trigger the oom killer now
so high order allocations (mostly coming from kmalloc) do not trigger
OOM killer anyway. But this is the thing that might change in future and
therefore I think it is essential to have a different oom behavior than
the allocator.

> > You are right that the allocation path involves compaction and that is
> > different from the charging path. But that is an implementation detail
> > of the current implementation.
> > 
> 
> Lol, the fact that the page allocator requires contiguous memory is not an 
> implementation detail of the current implementation.

The underlying mechanism might be different in future. So your lol is
not really appropriate.

> > Your patch only fixes up the current situation. Anytime a new THP
> > allocation emerges that code path has to be careful to add
> > __GFP_NORETRY to not regress again. That is just too error prone.
> > 
> 
> We could certainly handle it by adding helpers similar to 
> alloc_hugepage_direct_gfpmask() and alloc_hugepage_khugepaged_gfpmask() 
> which are employed for the same purpose for the page allocator gfp mask.

This doesn't solve the problem in general (e.g. kmalloc).

-- 
Michal Hocko
SUSE Labs
