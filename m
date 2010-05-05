Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 282BE6B0258
	for <linux-mm@kvack.org>; Wed,  5 May 2010 15:58:03 -0400 (EDT)
Date: Wed, 5 May 2010 21:57:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-ID: <20100505195732.GD5941@random.random>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie>
 <1273065281-13334-2-git-send-email-mel@csn.ul.ie>
 <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org>
 <20100505145620.GP20979@csn.ul.ie>
 <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
 <20100505155454.GT20979@csn.ul.ie>
 <20100505161319.GQ5835@random.random>
 <1273086685.1642.252.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273086685.1642.252.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 09:11:25PM +0200, Peter Zijlstra wrote:
> On Wed, 2010-05-05 at 18:13 +0200, Andrea Arcangeli wrote:
> > On Wed, May 05, 2010 at 04:54:54PM +0100, Mel Gorman wrote:
> > > I'm still thinking of the ordering but one possibility would be to use a mutex
> > 
> > I can't take mutex in split_huge_page... so I'd need to use an other solution.
> 
> So how's that going to work out for my make anon_vma->lock a mutex
> patches?

I'm not seeing much problem after all, even if you only switch the
anon_vma->lock (you switch both so it's quite different), unmap_vmas
may end up calling split_huge_page_pmd in zap_pmd_range only if the
vma is full anonymous (I don't allow hugepages in MAP_PRIVATE yet) so
there would be no i_mmap_lock held. But clearly if you switch _both_
it's even safer. In any case when we make that change, it'll require
to call split_huge_page_pmd and split_huge_page only in preemptive
points, and there is no such requirement today, and clearly when all
vm locking goes preemptive it'll be much natural and lower risk to
remove that requirement from split_huge_page too.

Also I think if we start taking mutex in anon_vma the i_mmap_lock
should switch too at the same time. I suspect it's an arbitrary choice
that we've to take always the i_mmap_lock before the anon_vma locks in
mmap.c so it makes sense they move in tandem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
