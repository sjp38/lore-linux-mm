Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E8CAE6B0200
	for <linux-mm@kvack.org>; Sun,  9 May 2010 15:22:09 -0400 (EDT)
Date: Sun, 9 May 2010 20:21:45 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
	rmap_walk by guaranteeing rmap_walk finds PTEs created within the
	temporary stack
Message-ID: <20100509192145.GI4859@csn.ul.ie>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie> <1273188053-26029-3-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org> <20100507105712.18fc90c4.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1005061905230.901@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005061905230.901@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 06, 2010 at 07:12:59PM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 7 May 2010, KAMEZAWA Hiroyuki wrote:
> > 
> > IIUC, move_page_tables() may call "page table allocation" and it cannot be
> > done under spinlock.
> 
> Bah. It only does a "alloc_new_pmd()", and we could easily move that out 
> of the loop and pre-allocate the pmd's.
> 
> If that's the only reason, then it's a really weak one, methinks.
> 

It turns out not to be easy to the preallocating of PUDs, PMDs and PTEs
move_page_tables() needs.  To avoid overallocating, it has to follow the same
logic as move_page_tables duplicating some code in the process. The ugliest
aspect of all is passing those pre-allocated pages back into move_page_tables
where they need to be passed down to such functions as __pte_alloc. It turns
extremely messy.

I stopped working on it about half way through as it was already too ugly
to live and would have similar cost to Kamezawa's much more straight-forward
approach of using move_vma().

While using move_vma is straight-forward and solves the problem, it's
not as cheap as Andrea's solution. Andrea allocates a temporary VMA and
puts it on a list and very little else. It didn't show up any problems
in microbenchmarks. Calling move_vma does a lot more work particularly in
copy_vma and this slows down exec.

With Kamezawa's patch, kernbench was fine on wall time but in System Time,
it slowed by up 1.48% in comparison to Andrea's slowing up by 0.64%[1].

aim9 was slowed as well. Kamezawa's slowed by 2.77% where Andrea's reported
faster by 2.58%. While AIM9 is flaky and these figures are barely outside
the noise, calling move_vma() is obviously more expensive.

While my solution at http://lkml.org/lkml/2010/4/30/198 is cheapest as it
does not touch exec() at all, is_vma_temporary_stack() could be broken in
the future if any of the assumptions it makes change.

So what you have is an inverse relationship between magic and
performance. Mine has the most magic and is fastest. Kamezawa's has the
least magic but slowest and Andrea has the goldilocks factor. Which do
you prefer?

[1] One caveat of the performance tests was that a lot of debugging such
    as lockdep was enabled. Disabling these would give different results
    but it should still be the case that calling move_vma is more expensive
    than calling kmem_cache_alloc.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
