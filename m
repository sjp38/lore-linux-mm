Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8CAFA62008B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 12:13:50 -0400 (EDT)
Date: Wed, 5 May 2010 18:13:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-ID: <20100505161319.GQ5835@random.random>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie>
 <1273065281-13334-2-git-send-email-mel@csn.ul.ie>
 <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org>
 <20100505145620.GP20979@csn.ul.ie>
 <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
 <20100505155454.GT20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100505155454.GT20979@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 04:54:54PM +0100, Mel Gorman wrote:
> I'm still thinking of the ordering but one possibility would be to use a mutex

I can't take mutex in split_huge_page... so I'd need to use an other solution.

> Not yet.

Rik's patch that takes the locks in the faster path is preferable to
me, it's just simpler, you know the really "strong" long is the
page->mapping/anon_vma->lock and nothing else. You've a page, you take
that lock, you're done for that very page.

Sure that means updating vm_start/vm_pgoff then requires locking all
anon_vmas that the vma registered into, but that's conceptually
simpler and it doesn't alter the page_lock_anon_vma semantics. Now I
wonder if you said the same_anon_vma is in order, but the same_vma is
not, if it's safe to lock the same_vma in list order in anon_vma_lock,
I didn't experience problems on the anon_vma_chain branch but
anon_vma_lock disables all lockdep lock inversion checking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
