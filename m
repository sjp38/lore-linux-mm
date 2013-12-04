Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id D736F6B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 00:25:53 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id d7so6470530bkh.3
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 21:25:53 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id zd1si2634113bkb.105.2013.12.03.21.25.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 21:25:52 -0800 (PST)
Date: Wed, 4 Dec 2013 00:25:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
Message-ID: <20131204052542.GY3556@cmpxchg.org>
References: <20131127225340.GE3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271526080.22848@chino.kir.corp.google.com>
 <20131128102049.GF2761@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311291543400.22413@chino.kir.corp.google.com>
 <20131202132201.GC18838@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312021452510.13465@chino.kir.corp.google.com>
 <20131203222511.GU3556@cmpxchg.org>
 <alpine.DEB.2.02.1312031531510.5946@chino.kir.corp.google.com>
 <20131204030101.GV3556@cmpxchg.org>
 <20131204043417.GM10988@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131204043417.GM10988@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 04, 2013 at 03:34:17PM +1100, Dave Chinner wrote:
> On Tue, Dec 03, 2013 at 10:01:01PM -0500, Johannes Weiner wrote:
> > On Tue, Dec 03, 2013 at 03:40:13PM -0800, David Rientjes wrote:
> > > On Tue, 3 Dec 2013, Johannes Weiner wrote:
> > > I believe the page allocator would be susceptible to the same deadlock if 
> > > nothing else on the system can reclaim memory and that belief comes from 
> > > code inspection that shows __GFP_NOFAIL is not guaranteed to ever succeed 
> > > in the page allocator as their charges now are (with your patch) in memcg.  
> > > I do not have an example of such an incident.
> > 
> > Me neither.
> 
> Is this the sort of thing that you expect to see when GFP_NOFS |
> GFP_NOFAIL type allocations continualy fail?
> 
> http://oss.sgi.com/archives/xfs/2013-12/msg00095.html
> 
> XFS doesn't use GFP_NOFAIL, it does it's own loop with GFP_NOWARN in
> kmem_alloc() so that if we get stuck for more than 100 attempts to
> allocate it throws a warning. i.e. only when we really are stuck and
> reclaim is not making any progress.
> 
> This specific case is due to memory fragmentation preventing a 64k
> memory allocation (due to the filesystem being configured with a 64k
> directory block size), but GFP_NOFS | GFP_NOFAIL allocations happen
> *all the time* in filesystems.

Yes, the question is whether this in itself is a practical problem,
regardless of whether you use __GFP_NOFAIL or a manual loop.

> > > > > So, my question again: why not bypass the per-zone min watermarks in the 
> > > > > page allocator?
> > > > 
> > > > I don't even know what your argument is supposed to be.  The fact that
> > > > we don't do it in the page allocator means that there can't be a bug
> > > > in memcg?
> > > > 
> > > 
> > > I'm asking if we should allow GFP_NOFS | __GFP_NOFAIL allocations in the 
> > > page allocator to bypass per-zone min watermarks after reclaim has failed 
> > > since the oom killer cannot be called in such a context so that the page 
> > > allocator is not susceptible to the same deadlock without a complete 
> > > depletion of memory reserves?
> > 
> > Yes, I think so.
> 
> There be dragons. If memcg's deadlock in low memory conditions in
> the presence of GFP_NOFS | GFP_NOFAIL allocations, then we need to
> make the memcg reclaim design more robust, not work around it by
> allowing filesystems to drain critical memory reserves needed for
> other situations....

The problems in the page allocator and memcg are entirely unrelated.
What we do in the memcg does not affect the page allocator and vice
versa.  However, they are problems of the same type, so we are trying
to find out whether both instances can have the same solution:

If GFP_NOFS | __GFP_NOFAIL allocations can not make forward progress
in direct reclaim, they are screwed: can't reclaim memory, can't OOM
kill, can't return NULL.  They are essentially stuck until a third
party intervenes.  This applies to both the page allocator and memcg.

In memcg, I fixed it by allowing the __GFP_NOFAIL task to bypass the
user-defined memory limit after reclaim fails.

David asks whether we should do the equivalent in the page allocator
and allow __GFP_NOFAIL allocations to dip into the emergency memory
reserves for the same reason.

I suggested that the situations are not entirely the same.  A memcg
might only have one or two tasks and so third party intervention to
reduce memory usage in the memcg can be unlikely to impossible,
whereas in the case of the page allocator, the likelihood of any task
in the system releasing or reclaiming memory is higher.

However, the GFP_NOFS | __GFP_NOFAIL task stuck in the page allocator
may hold filesystem locks that could prevent a third party from
freeing memory and/or exiting, so we can not guarantee that only the
__GFP_NOFAIL task is getting stuck, it might well trap other tasks.
The same applies to open-coded GFP_NOFS allocation loops of course
unless they cycle the filesystem locks while looping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
