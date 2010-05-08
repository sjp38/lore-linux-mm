Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 542E16B027A
	for <linux-mm@kvack.org>; Sat,  8 May 2010 14:04:48 -0400 (EDT)
Date: Sat, 8 May 2010 20:04:12 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-ID: <20100508180412.GT5941@random.random>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie>
 <1273188053-26029-2-git-send-email-mel@csn.ul.ie>
 <20100508153922.GS5941@random.random>
 <alpine.LFD.2.00.1005081000490.3711@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005081000490.3711@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, May 08, 2010 at 10:02:50AM -0700, Linus Torvalds wrote:
> 
> 
> On Sat, 8 May 2010, Andrea Arcangeli wrote:
> > 
> > I'm simply not going to support the degradation to the root anon_vma
> > complexity in aa.git, except for strict merging requirements [ ..]
> 
> Goodie. That makes things easier for me - there's never going to be any 
> issue of whether I need to even _think_ about merging the piece of crap.
> 
> In other words - if people want anything like that merged, you had better 
> work on cleaning up the locking. Because I absolutely WILL NOT apply any 
> of the f*ckign broken locking patches that I've seen, when I've personally 
> told people how to fix the thing.

There is no broken (as in kernel crashing) locking in my THP
patches. It is more stable than mainline as far as migration is
concerned.

And the patch I think you're calling "broken" to fix the anon-vma
locking wasn't written by me (I only fixed the exec vs migrate race in
the way _I_ prefer and I still prefer, which is another bug not
related to the new anon-vma changes).

If the other patch you call broken:

   http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=patch;h=f42cfe59ed4ea474ea22aeec033aad408e1fb9d2

go figure how broken it is to do all this anon-vma changes, with all
complexity and risk involved with the only benefit of running the rmap
walks faster, and in the end the very function called rmap_walk() runs
even slower than 2.6.32. _That_ is broken in my view, and I'm not
saying I like the patch in the above link (I suggested a shared lock
from the start if you check) but it surely is less broken than what
you're discussing here about the root anon-vma.

> In other words, it's all _your_ problem.

And I already said in the very previous email I sent in this thread, I
will also maintain a for-mainline tree trying to support this
root-anon-vma thing in case you merge it by mistake, just to avoid
this new anon-vma locking changes to be involved in the merging
issues of THP.

How you mix the merging of THP with how to solve this migrate crash
that only affects mainline new anon-vma code without THP, I've no
idea, especially considering I mentioned I will support whatever
anon-vma locking that will go in mainline in a separate branch
(clearly it won't be the one I recommend to use for the very reasons
explained above but I'll provide it for merging).

Also note, if you refuse to merge THP it's not my problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
