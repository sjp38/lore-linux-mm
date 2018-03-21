Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D71866B0008
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 17:27:12 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s6so3011361pgn.3
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:27:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 67sor1506841pfr.32.2018.03.21.14.27.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 14:27:11 -0700 (PDT)
Date: Wed, 21 Mar 2018 14:27:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: do not cause memcg oom for thp
In-Reply-To: <20180321204921.GP23100@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1803211422510.107059@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803191409420.124411@chino.kir.corp.google.com> <20180320071624.GB23100@dhcp22.suse.cz> <alpine.DEB.2.20.1803201321430.167205@chino.kir.corp.google.com> <20180321082228.GC23100@dhcp22.suse.cz> <alpine.DEB.2.20.1803211212490.92011@chino.kir.corp.google.com>
 <20180321204921.GP23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Mar 2018, Michal Hocko wrote:

> > That doesn't make sense, the allocation path needs to allocate contiguous 
> > memory for the high order, the charging path just needs to charge a number 
> > of pages.  Why would the allocation and charging path be compatible when 
> > one needs to reclaim contiguous memory or compact memory and the the other 
> > just needs to reclaim any memory?
> 
> Because you do not want to see surprises. E.g. seeing unexpected OOMs
> for large allocatations. Just think about it. Do you really want to have
> a different reclaim policy for the allocation and charging for all
> allocating paths?

It depends on the use of __GFP_NORETRY.  If the high-order charge is 
__GFP_NORETRY, it does not oom kill.  It is left to the caller.  Just 
because thp allocations have been special cased in the page allocator to 
be able to remove __GFP_NORETRY without fixing the memcg charge path does 
not mean memcg needs a special heuristic for high-order memory when it 
does not require contiguous memory.  You say you don't want any surprises, 
but now you are changing behavior needlessly for all charges with
order > PAGE_ALLOC_COSTLY_ORDER that do not use __GFP_NORETRY.

> You are right that the allocation path involves compaction and that is
> different from the charging path. But that is an implementation detail
> of the current implementation.
> 

Lol, the fact that the page allocator requires contiguous memory is not an 
implementation detail of the current implementation.

> Your patch only fixes up the current situation. Anytime a new THP
> allocation emerges that code path has to be careful to add
> __GFP_NORETRY to not regress again. That is just too error prone.
> 

We could certainly handle it by adding helpers similar to 
alloc_hugepage_direct_gfpmask() and alloc_hugepage_khugepaged_gfpmask() 
which are employed for the same purpose for the page allocator gfp mask.
