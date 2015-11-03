Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6761782F64
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 21:23:45 -0500 (EST)
Received: by padec8 with SMTP id ec8so3815385pad.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 18:23:45 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id yj5si36017030pbc.32.2015.11.02.18.23.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 18:23:44 -0800 (PST)
Date: Tue, 3 Nov 2015 11:23:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/8] MADV_FREE support
Message-ID: <20151103022343.GG17906@bbox>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <alpine.DEB.2.10.1510312142560.10406@chino.kir.corp.google.com>
 <5635B159.8030307@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5635B159.8030307@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>

On Sun, Nov 01, 2015 at 01:29:45AM -0500, Daniel Micay wrote:
> On 01/11/15 12:51 AM, David Rientjes wrote:
> > On Fri, 30 Oct 2015, Minchan Kim wrote:
> > 
> >> MADV_FREE is on linux-next so long time. The reason was two, I think.
> >>
> >> 1. MADV_FREE code on reclaim path was really mess.
> >>
> >> 2. Andrew really want to see voice of userland people who want to use
> >>    the syscall.
> >>
> >> A few month ago, Daniel Micay(jemalloc active contributor) requested me
> >> to make progress upstreaming but I was busy at that time so it took
> >> so long time for me to revist the code and finally, I clean it up the
> >> mess recently so it solves the #2 issue.
> >>
> >> As well, Daniel and Jason(jemalloc maintainer) requested it to Andrew
> >> again recently and they said it would be great to have even though
> >> it has swap dependency now so Andrew decided he will do that for v4.4.
> >>
> > 
> > First, thanks very much for refreshing the patchset and reposting after a 
> > series of changes have been periodically added to -mm, it makes it much 
> > easier.
> > 
> > For tcmalloc, we can do some things in the allocator itself to increase 
> > the amount of memory backed by thp.  Specifically, we can prefer to 
> > release Spans to pageblocks that are already not backed by thp so there is 
> > no additional split on each scavenge.  This is somewhat easy if all memory 
> > is organized into hugepage-aligned pageblocks in the allocator itself.  
> > Second, we can prefer to release Spans of longer length on each scavenge 
> > so we can delay scavenging for as long as possible in a hope we can find 
> > more pages to coalesce.  Third, we can discount refaulted released memory 
> > from the scavenging period.
> > 
> > That significantly improves the amount of memory backed by thp for 
> > tcmalloc.  The problem, however, is that tcmalloc uses MADV_DONTNEED to 
> > release memory to the system and MADV_FREE wouldn't help at all in a 
> > swapless environment.
> > 
> > To combat that, I've proposed a new MADV bit that simply caches the 
> > ranges freed by the allocator per vma and places them on both a per-vma 
> > and per-memcg list.  During reclaim, this list is iterated and ptes are 
> > freed after thp split period to the normal directed reclaim.  Without 
> > memory pressure, this backs 100% of the heap with thp with a relatively 
> > lightweight kernel change (the majority is vma manipulation on split) and 
> > a couple line change to tcmalloc.  When pulling memory from the returned 
> > freelists, the memory that we have MADV_DONTNEED'd, we need to use another 
> > MADV bit to remove it from this cache, so there is a second madvise(2) 
> > syscall involved but the freeing call is much less expensive since there 
> > is no pagetable walk without memory pressure or synchronous thp split.
> > 
> > I've been looking at MADV_FREE to see if there is common ground that could 
> > be shared, but perhaps it's just easier to ask what your proposed strategy 
> > is so that tcmalloc users, especially those in swapless environments, 
> > would benefit from any of your work?
> 
> The current implementation requires swap because the kernel already has
> robust infrastructure for swapping out anonymous memory when there's
> memory pressure. The MADV_FREE implementation just has to hook in there
> and cause pages to be dropped instead of swapped out. There's no reason
> it couldn't be extended to work in swapless environments, but it will
> take additional design and implementation work. As a stop-gap, I think

Yes, I have two ideas to support swapless system.

First one I sent a few month ago but didn't receive enough comment.
https://lkml.org/lkml/2015/2/24/71

Second one, we could add new LRU list which has just MADV_FREEed
hinted pages and VM can age them fairly with another LRU lists.
It might be better policy but it needs more amount of changes in MM
so I want to listen from userland people once they start to use
syscall.

> zram and friends will work fine as a form of swap for this.
> 
> It can definitely be improved to cooperate well with THP too. I've been
> following the progress, and most of the problems seem to have been with
> the THP and that's a very active area of development. Seems best to deal
> with that after a simple, working implementation lands.

I have already patch which splits THP page lazy where in reclaim path,
not syscall context. The patch itself is really simple but THP is
sometime very subtle and is changing heavily so I didn't want to make
noise this time. If anyone needs it really this time,
I am happy to send it.

> 
> The best aspect of MADV_FREE is that it completely avoids page faults
> when there's no memory pressure. Making use of the freed memory only
> triggers page faults if the pages had to be dropped because the system
> ran out of memory. It also avoids needing to zero the pages. The memory
> can also still be freed at any time if there's memory pressure again
> even if it's handed out as an allocation until it's actually touched.
> 
> The call to madvise still has significant overhead, but it's much
> cheaper than MADV_DONTNEED. Allocators will be able to lean on the
> kernel to make good decisions rather than implementing lazy freeing
> entirely on their own. It should improve performance *and* behavior
> under memory pressure since allocators can be more aggressive with it
> than MADV_DONTNEED.
> 
> A nice future improvement would be landing MADV_FREE_UNDO feature to
> allow an attempt to pin the pages in memory again. It would make this
> work very well for implementing caches that are dropped under memory
> pressure. Windows has this via MEM_RESET (essentially MADV_FREE) and
> MEM_RESET_UNDO. Android has it for ashmem too (pinning/unpinning). I
> think browser vendors would be very interested in it.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
