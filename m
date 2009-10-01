Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CCB42600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 10:23:35 -0400 (EDT)
Date: Thu, 1 Oct 2009 16:03:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a kmem_cache_cpu
Message-ID: <20091001150346.GD21906@csn.ul.ie>
References: <84144f020909220638l79329905sf9a35286130e88d0@mail.gmail.com> <20090922135453.GF25965@csn.ul.ie> <84144f020909221154x820b287r2996480225692fad@mail.gmail.com> <20090922185608.GH25965@csn.ul.ie> <20090930144117.GA17906@csn.ul.ie> <alpine.DEB.1.10.0909301053550.9450@gentwo.org> <20090930220541.GA31530@csn.ul.ie> <alpine.DEB.1.10.0909301941570.11850@gentwo.org> <20091001104046.GA21906@csn.ul.ie> <alpine.DEB.1.10.0910011028380.3911@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0910011028380.3911@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 01, 2009 at 10:32:54AM -0400, Christoph Lameter wrote:
> On Thu, 1 Oct 2009, Mel Gorman wrote:
> 
> > > Frees are done directly to the target slab page if they are not to the
> > > current active slab page. No centralized locks. Concurrent frees from
> > > processors on the same node to multiple other nodes (or different pages
> > > on the same node) can occur.
> > >
> >
> > So as a total aside, SLQB has an advantage in that it always uses object
> > in LIFO order and is more likely to be cache hot. SLUB has an advantage
> > when one CPU allocates and another one frees because it potentially
> > avoids a cache line bounce. Might be something worth bearing in mind
> > when/if a comparison happens later.
> 
> SLQB may use cache hot objects regardless of their locality. SLUB
> always serves objects that have the same locality first (same page).
> SLAB returns objects via the alien caches to the remote node.
> So object allocations with SLUB will generate less TLB pressure since they
> are localized.

True, it might have been improved more if SLUB knew what local hugepage it
resided within as the kernel portion of the address space is backed by huge
TLB entries. Note that SLQB could have an advantage here early in boot as
the page allocator will tend to give it back pages within a single huge TLB
entry. It loses the advantage when the system has been running for a very long
time but it might be enough to skew benchmark results on cold-booted systems.

> SLUB objects are immediately returned to the remote node.
> SLAB/SLQB keeps them around for reallocation or queue processing.
> 
> > > Look at fallback_alloc() in slab. You can likely copy much of it. It
> > > considers memory policies and cpuset constraints.
> > >
> > True, it looks like some of the logic should be taken from there all right. Can
> > the treatment of memory policies be dealt with as a separate thread though? I'd
> > prefer to get memoryless nodes sorted out before considering the next two
> > problems (per-cpu instability on ppc64 and memory policy handling in SLQB).
> 
> Separate email thread? Ok.
> 

Yes, but I'll be honest. It'll be at least two weeks before I can tackle
memory policy related issues in SLQB. It's not high on my list of
priorities. I'm more concerned with breakage on ppc64 and a patch that
forces it to be disabled. Minimally, I want this resolved before getting
distracted by another thread.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
