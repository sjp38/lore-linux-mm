Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A8A20620096
	for <linux-mm@kvack.org>; Thu,  6 May 2010 10:17:52 -0400 (EDT)
Date: Thu, 6 May 2010 07:15:31 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
In-Reply-To: <20100506100208.GB20979@csn.ul.ie>
Message-ID: <alpine.LFD.2.00.1005060707050.901@i5.linux-foundation.org>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
 <20100505175311.GU20979@csn.ul.ie> <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org> <20100506002255.GY20979@csn.ul.ie> <alpine.LFD.2.00.1005051737290.901@i5.linux-foundation.org> <20100506100208.GB20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>



On Thu, 6 May 2010, Mel Gorman wrote:
> > 
> > What makes this ok is the fact that it must be running under the RCU read 
> > lock, and anon_vma's thus cannot be released.
> 
> This is very subtle in itself. RCU guarantees that the anon_vma exists
> but does it guarantee that it's the same one we expect and that it
> hasn't been freed and reused?

Nothing. And we shouldn't care.

If it's been freed and re-used, then all the anon_vma's (and vma's) 
associated with the original anon_vma (and page) have been free'd.

And that, in turn, means that we don't really need to lock anything at 
all. The fact that we end up locking an anon_vma that _used_ to be the 
root anon_vma is immaterial - the lock won't _help_, but it shouldn't hurt 
either, since it's still a valid spinlock.

Now, the above is only true as far as the anon_vma itself is concerned. 
It's entirely possible that any _other_ data structures would need to be 
double-checked after getting the lock. For example, is the _page_ still 
associated with that anon_vma? But that's an external issue as far as the 
anon_vma locking is concerned - presumably the 'rmap_walk()' caller will 
have made sure that the page itself is stable somehow.

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
