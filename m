Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f77.google.com (mail-oa0-f77.google.com [209.85.219.77])
	by kanga.kvack.org (Postfix) with ESMTP id B3B856B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 13:23:44 -0500 (EST)
Received: by mail-oa0-f77.google.com with SMTP id o6so2056oag.0
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 10:23:44 -0800 (PST)
Received: from psmtp.com ([74.125.245.105])
        by mx.google.com with SMTP id hk1si14566694pbb.221.2013.11.20.08.07.20
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 08:07:21 -0800 (PST)
Date: Wed, 20 Nov 2013 11:07:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, vmscan: abort futile reclaim if we've been oom killed
Message-ID: <20131120160712.GF3556@cmpxchg.org>
References: <alpine.DEB.2.02.1311121801200.18803@chino.kir.corp.google.com>
 <20131113152412.GH707@cmpxchg.org>
 <alpine.DEB.2.02.1311131400300.23211@chino.kir.corp.google.com>
 <20131114000043.GK707@cmpxchg.org>
 <alpine.DEB.2.02.1311131639010.6735@chino.kir.corp.google.com>
 <20131118164107.GC3556@cmpxchg.org>
 <alpine.DEB.2.02.1311181712080.4292@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311181712080.4292@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 18, 2013 at 05:17:31PM -0800, David Rientjes wrote:
> On Mon, 18 Nov 2013, Johannes Weiner wrote:
> 
> > > Um, no, those processes are going through a repeated loop of direct 
> > > reclaim, calling the oom killer, iterating the tasklist, finding an 
> > > existing oom killed process that has yet to exit, and looping.  They 
> > > wouldn't loop for too long if we can reduce the amount of time that it 
> > > takes for that oom killed process to exit.
> > 
> > I'm not talking about the big loop in the page allocator.  The victim
> > is going through the same loop.  This patch is about the victim being
> > in a pointless direct reclaim cycle when it could be exiting, all I'm
> > saying is that the other tasks doing direct reclaim at that moment
> > should also be quitting and retrying the allocation.
> > 
> 
> "All other tasks" would be defined as though sharing the same mempolicy 
> context as the oom kill victim or the same set of cpuset mems, I'm not 
> sure what type of method for determining reclaim eligiblity you're 
> proposing to avoid pointlessly spinning without making progress.  Until an 
> alternative exists, my patch avoids the needless spinning and expedites 
> the exit, so I'll ask that it be merged.

I laid this out in the second half of my email, which you apparently
did not read:

"If we have multi-second stalls in direct reclaim then it should be
 fixed for all direct reclaimers.  The problem is not only OOM kill
 victims getting stuck, it's every direct reclaimer being stuck trying
 to do way too much work before retrying the allocation.

 Kswapd checks the system state after every priority cycle.  Direct
 reclaim should probably do the same and retry the allocation after
 every priority cycle or every X pages scanned, where X is something
 reasonable and not "up to every LRU page in the system"."

NAK to this incomplete drive-by fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
