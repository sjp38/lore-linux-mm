Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8FD62008B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 13:59:53 -0400 (EDT)
Date: Wed, 5 May 2010 10:57:18 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
In-Reply-To: <alpine.LFD.2.00.1005051007140.27218@i5.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1005051050590.27218@i5.linux-foundation.org>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
 <20100505155454.GT20979@csn.ul.ie> <alpine.LFD.2.00.1005051007140.27218@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>



On Wed, 5 May 2010, Linus Torvalds wrote:
> 
> From the vma, it's simply
> 	avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
> 	anon_vma = avc->anon_vma;
> 
> and once you take that lock, you know you've gotten the lock for all 
> chains related to that page. We _know_ that every single vma that is 
> associated with that anon_vma must have a chain that eventually ends in 
> that entry.

To clarify: here "is associated with that anon_vma" is basically about the 
whole forest of anon_vma/vma links. Different vma's can be associated with 
different anon_vma's, and pages can be associated with anon_vma's that can 
in turn reach other anon_vma's and many other vma's.

But regardless of _how_ you walk the chains between anon_vma's and vma's 
(including walking "back-pointers" that don't even exist except 
conceptually for the pointer going the other way), any relationship will 
have started at _some_ root vma.

IOW, the root anon_vma is directly 1:1 related to "do these vma/anon_vma's 
relate in _any_ way". If it's the same root anon_vma, then there is a 
historical relationship. And if the root anon_vma's are different, then 
there cannot be any relationship at all.

So locking the root anon_vma is both minimal _and_ sufficient. Any locking 
scheme (traversing the lists) would eventually end up hitting that root 
entry (minimal locking), and at the same time that root entry is also 
guaranteed to be the same for all related entities (ie it's sufficient to 
lock the root entry if everybody else also looks up their root and locks 
it).

I think. Tell me if I'm wrong.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
