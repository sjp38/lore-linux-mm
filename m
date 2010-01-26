Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EE10A6B00A6
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 11:42:45 -0500 (EST)
Date: Tue, 26 Jan 2010 16:42:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126164230.GC16468@csn.ul.ie>
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random> <alpine.DEB.2.00.1001251529070.5379@router.home> <4B5E3CC0.2060006@redhat.com> <alpine.DEB.2.00.1001260947580.23549@router.home> <20100126161625.GO30452@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100126161625.GO30452@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 05:16:25PM +0100, Andrea Arcangeli wrote:
> On Tue, Jan 26, 2010 at 09:54:59AM -0600, Christoph Lameter wrote:
> > Huge pages are already in use through hugetlbs for such workloads. That
> > works without swap. So why is this suddenly such a must have requirement?
> 
> hugetlbfs is unusable when you're not doing a static alloc for 1 DBMS
> in 1 machine with alloc size set in a config file that will then match
> grub command line.
> 

That may have been the case once upon a time but is far from accurate
now. I routinely run benchmarks against a database using huge pages that
isn't even hugepage-aware without going through insane steps. The huge
pages are often allocated when the system has already been running
several days (and in one case a few weeks) and I didn't have to be
overly specific on how many huge pages I needed either as additional
ones were allocated as required.

hugetlbfs may be not be ideal, but it's not quite as catastrophic as
commonly believed either.

> > Why not swap 2M huge pages as a whole?
> 
> That is nice thing to speedup swap bandwidth and reduce fragmentation,
> just I couldn't make so many changes in one go. Later we can make this
> change and remove a few split_huge_page from the rmap paths.
> 
> > What in your workload forces hugetlb swap use? Just leaving a certain
> > percentage of memory for 4k pages addresses the issue right now.
> 
> hypervisor must be able to swap, furthermore when a VM exists we want
> to be able to use that ram as pagecache (not to remain reserved in
> some hugetlbfs). And we must be able to fallback to 4k allocations
> always without userland being able to notice when unable to defrag,
> all things hugetlbfs can't do. All designs that can't 100% fallback to
> 4k allocations are useless in my view as far as you want to keep the
> word "transparent" in the description of the patch...
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
