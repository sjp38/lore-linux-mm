Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 413DB6B0005
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:53:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so2958838pgt.6
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:53:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f21si3291735pgn.693.2018.03.21.13.53.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 13:53:11 -0700 (PDT)
Date: Wed, 21 Mar 2018 21:53:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: do not cause memcg oom for thp
Message-ID: <20180321204921.GP23100@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1803191409420.124411@chino.kir.corp.google.com>
 <20180320071624.GB23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803201321430.167205@chino.kir.corp.google.com>
 <20180321082228.GC23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803211212490.92011@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803211212490.92011@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 21-03-18 12:37:10, David Rientjes wrote:
> On Wed, 21 Mar 2018, Michal Hocko wrote:
> 
> > > I'm not sure of the expectation of high-order memcg charging without 
> > > __GFP_NORETRY,
> > 
> > It should be semantically compatible with the allocation path.
> > 
> 
> That doesn't make sense, the allocation path needs to allocate contiguous 
> memory for the high order, the charging path just needs to charge a number 
> of pages.  Why would the allocation and charging path be compatible when 
> one needs to reclaim contiguous memory or compact memory and the the other 
> just needs to reclaim any memory?

Because you do not want to see surprises. E.g. seeing unexpected OOMs
for large allocatations. Just think about it. Do you really want to have
a different reclaim policy for the allocation and charging for all
allocating paths? THP is by no means special. We do have different gfp
masks for THP to express how hard to try. Why should the charge path
behave any different?

You are right that the allocation path involves compaction and that is
different from the charging path. But that is an implementation detail
of the current implementation. Semantically, it is the gfp mask to tell
how hard to try and treating just because of how the current code works
is simply wrong.

> > > I only know that khugepaged can now cause memcg oom kills 
> > > when trying to collapse memory, and then subsequently found that the same 
> > > situation exists for faulting instead of falling back to small pages.
> > 
> > And that is clearly a bug because page allocator doesn't oom kill while
> > the memcg charge does for the same gfp flag. That should be fixed.
> > 
> 
> It's fixed with my patch, yes.

Your patch only fixes up the current situation. Anytime a new THP
allocation emerges that code path has to be careful to add
__GFP_NORETRY to not regress again. That is just too error prone.

> The page allocator doesn't oom kill for 
> orders over PAGE_ALLOC_COSTLY_ORDER only because it is unlikely to free 
> order-4 and higher contiguous memory as a result; it's in the name, it's a 
> costly order for the page allocator.  Using it as a heuristic in the memcg 
> charging path seems strange.

It is not strange at all. We have the concept that large allocations are
OK to fail rather than cause disruptive actions. And the same applies
for charges as well. There is no reason to over reclaim or even OOM kill
for a large charge if we have a fallback.

Seriously. Making different polices to the allocation and the memcg
charge will lead to both unexpected behavior and a maintenance mess.
And there is no good reason for that.
-- 
Michal Hocko
SUSE Labs
