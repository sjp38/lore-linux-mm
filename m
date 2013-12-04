Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id C1F166B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 23:34:25 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so9800774yhn.4
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 20:34:25 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id l5si1699983yhl.124.2013.12.03.20.34.23
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 20:34:24 -0800 (PST)
Date: Wed, 4 Dec 2013 15:34:17 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
Message-ID: <20131204043417.GM10988@dastard>
References: <alpine.DEB.2.02.1311271336220.9222@chino.kir.corp.google.com>
 <20131127225340.GE3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271526080.22848@chino.kir.corp.google.com>
 <20131128102049.GF2761@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311291543400.22413@chino.kir.corp.google.com>
 <20131202132201.GC18838@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312021452510.13465@chino.kir.corp.google.com>
 <20131203222511.GU3556@cmpxchg.org>
 <alpine.DEB.2.02.1312031531510.5946@chino.kir.corp.google.com>
 <20131204030101.GV3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131204030101.GV3556@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 03, 2013 at 10:01:01PM -0500, Johannes Weiner wrote:
> On Tue, Dec 03, 2013 at 03:40:13PM -0800, David Rientjes wrote:
> > On Tue, 3 Dec 2013, Johannes Weiner wrote:
> > I believe the page allocator would be susceptible to the same deadlock if 
> > nothing else on the system can reclaim memory and that belief comes from 
> > code inspection that shows __GFP_NOFAIL is not guaranteed to ever succeed 
> > in the page allocator as their charges now are (with your patch) in memcg.  
> > I do not have an example of such an incident.
> 
> Me neither.

Is this the sort of thing that you expect to see when GFP_NOFS |
GFP_NOFAIL type allocations continualy fail?

http://oss.sgi.com/archives/xfs/2013-12/msg00095.html

XFS doesn't use GFP_NOFAIL, it does it's own loop with GFP_NOWARN in
kmem_alloc() so that if we get stuck for more than 100 attempts to
allocate it throws a warning. i.e. only when we really are stuck and
reclaim is not making any progress.

This specific case is due to memory fragmentation preventing a 64k
memory allocation (due to the filesystem being configured with a 64k
directory block size), but GFP_NOFS | GFP_NOFAIL allocations happen
*all the time* in filesystems.

> > > > So, my question again: why not bypass the per-zone min watermarks in the 
> > > > page allocator?
> > > 
> > > I don't even know what your argument is supposed to be.  The fact that
> > > we don't do it in the page allocator means that there can't be a bug
> > > in memcg?
> > > 
> > 
> > I'm asking if we should allow GFP_NOFS | __GFP_NOFAIL allocations in the 
> > page allocator to bypass per-zone min watermarks after reclaim has failed 
> > since the oom killer cannot be called in such a context so that the page 
> > allocator is not susceptible to the same deadlock without a complete 
> > depletion of memory reserves?
> 
> Yes, I think so.

There be dragons. If memcg's deadlock in low memory conditions in
the presence of GFP_NOFS | GFP_NOFAIL allocations, then we need to
make the memcg reclaim design more robust, not work around it by
allowing filesystems to drain critical memory reserves needed for
other situations....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
