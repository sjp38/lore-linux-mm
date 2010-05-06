Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFC06B02A9
	for <linux-mm@kvack.org>; Thu,  6 May 2010 10:25:54 -0400 (EDT)
Date: Thu, 6 May 2010 15:25:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100506142531.GB8704@csn.ul.ie>
References: <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org> <20100505175311.GU20979@csn.ul.ie> <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org> <20100506002255.GY20979@csn.ul.ie> <alpine.LFD.2.00.1005051737290.901@i5.linux-foundation.org> <20100506100208.GB20979@csn.ul.ie> <alpine.LFD.2.00.1005060707050.901@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005060707050.901@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 06, 2010 at 07:15:31AM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 6 May 2010, Mel Gorman wrote:
> > > 
> > > What makes this ok is the fact that it must be running under the RCU read 
> > > lock, and anon_vma's thus cannot be released.
> > 
> > This is very subtle in itself. RCU guarantees that the anon_vma exists
> > but does it guarantee that it's the same one we expect and that it
> > hasn't been freed and reused?
> 
> Nothing. And we shouldn't care.
> 
> If it's been freed and re-used, then all the anon_vma's (and vma's) 
> associated with the original anon_vma (and page) have been free'd.
> 
> And that, in turn, means that we don't really need to lock anything at 
> all. The fact that we end up locking an anon_vma that _used_ to be the 
> root anon_vma is immaterial - the lock won't _help_, but it shouldn't hurt 
> either, since it's still a valid spinlock.
> 

I can't see any problem with the logic.

> Now, the above is only true as far as the anon_vma itself is concerned. 
> It's entirely possible that any _other_ data structures would need to be 
> double-checked after getting the lock. For example, is the _page_ still 
> associated with that anon_vma? But that's an external issue as far as the 
> anon_vma locking is concerned - presumably the 'rmap_walk()' caller will 
> have made sure that the page itself is stable somehow.
> 

It does, by having the page locked as it performs the walk.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
