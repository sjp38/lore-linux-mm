Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AE0476B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 20:28:15 -0400 (EDT)
Date: Fri, 21 May 2010 02:27:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-ID: <20100521002740.GB5733@random.random>
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

If you're interested I can include your patchset after memory
compaction in aa.git, far from the ideal path for merging but ideal if
you want to test together with the full thing (memory compaction,
split_huge_page as you wondered just above etc..) and hopefully give
it more testing.

Note: I'm not sure if it's the right way to go, in fact I'm quite
skeptical, not because it won't work, but ironically the main reason
I'm interested is to close the XPMEM requirements the right way (not
with page pins and deferred async invalidates), as long as we've users
asking for rescheduling in mmu notifier methods this is the only way
to go. Initially I thought it had to be a build time option, but
seeing you doing it by default and for totally different reasons, I'm
slightly more optimistic it can be the default and surely XPMEM will
love it... the fact these locks are smarter helps a lot too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
