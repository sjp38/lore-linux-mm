Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 201B16B0036
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:26:52 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so2739866eek.8
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:26:51 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id r9si18142661eeo.128.2013.12.11.01.26.51
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 01:26:51 -0800 (PST)
Date: Wed, 11 Dec 2013 09:26:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, page_alloc: allow __GFP_NOFAIL to allocate below
 watermarks after reclaim
Message-ID: <20131211092648.GW11295@suse.de>
References: <alpine.DEB.2.02.1312091402580.11026@chino.kir.corp.google.com>
 <20131210075059.GA11295@suse.de>
 <alpine.DEB.2.02.1312101453020.22701@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312101453020.22701@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 10, 2013 at 03:03:39PM -0800, David Rientjes wrote:
> On Tue, 10 Dec 2013, Mel Gorman wrote:
> 
> > > If direct reclaim has failed to free memory, __GFP_NOFAIL allocations
> > > can potentially loop forever in the page allocator.  In this case, it's
> > > better to give them the ability to access below watermarks so that they
> > > may allocate similar to the same privilege given to GFP_ATOMIC
> > > allocations.
> > > 
> > > We're careful to ensure this is only done after direct reclaim has had
> > > the chance to free memory, however.
> > > 
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > The main problem with doing something like this is that it just smacks
> > into the adjusted watermark if there are a number of __GFP_NOFAIL. Who
> > was the user of __GFP_NOFAIL that was fixed by this patch?
> > 
> 
> Nobody, it comes out of a memcg discussion where __GFP_NOFAIL were 
> recently given the ability to bypass charges to the root memcg when the 
> memcg has hit its limit since we disallow the oom killer to kill a process 
> (for the same reason that the vast majority of __GFP_NOFAIL users, those 
> that do GFP_NOFS | __GFP_NOFAIL, disallow the oom killer in the page 
> allocator).
> 
> Without some other thread freeing memory, these allocations simply loop 
> forever.  We probably don't want to reconsider the choice that prevents 
> calling the oom killer in !__GFP_FS contexts since it will allow 
> unnecessary oom killing when memory can actually be freed by another 
> thread.
> 
> Since there are comments in both gfp.h and page_alloc.c that say no new 
> users will be added, it seems legitimate to ensure that the allocation 
> will at least have a chance of succeeding, but not the point of depleting 
> memory reserves entirely.
> 

Which __GFP_NOFAIL on its own does not guarantee if they just smack into
that barrier and cannot do anything. It changes the timing, not fixes
the problem.

> > There are enough bad users of __GFP_NOFAIL that I really question how
> > good an idea it is to allow emergency reserves to be used when they are
> > potentially leaked to other !__GFP_NOFAIL users via the slab allocator
> > shortly afterwards.
> > 
> 
> You could make the same argument for GFP_ATOMIC which can also allow 
> access to memory reserves.

The critical difference being that GFP_ATOMIC callers typically can handle
NULL being returned to them. GFP_ATOMIC storms may starve !GFP_ATOMIC
requests but it does not cause the same types of problems that
__GFP_NOFAIL using reserves would.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
