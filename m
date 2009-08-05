Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C921E6B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:07:43 -0400 (EDT)
Date: Wed, 5 Aug 2009 10:07:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090805090742.GA21950@csn.ul.ie>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org> <4A787D84.2030207@redhat.com> <20090804121332.46df33a7.akpm@linux-foundation.org> <20090804204857.GA32092@csn.ul.ie> <20090805074103.GD19322@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090805074103.GD19322@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>, Fr?d?ric Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 09:41:03AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mel@csn.ul.ie> wrote:
> 
> [...]
> > > Is there a plan to add the rest later on?
> > 
> > Depending on how this goes, I will attempt to do a similar set of 
> > trace points for tracking kswapd and direct reclaim with the view 
> > to identifying when stalls occur due to reclaim, when lumpy 
> > reclaim is kicking in, how long it's taken and how often is 
> > succeeds/fails.
> > 
> > > Or are these nine more a proof-of-concept demonstration-code 
> > > thing?  If so, is it expected that developers will do an ad-hoc 
> > > copy-n-paste to solve a particular short-term problem and will 
> > > then toss the tracepoint away?  I guess that could be useful, 
> > > although you can do the same with vmstat.
> > 
> > Adding and deleting tracepoints, rebuilding and rebooting the 
> > kernel is obviously usable by developers but not a whole pile of 
> > use if recompiling the kernel is not an option or you're trying to 
> > debug a difficult-to-reproduce-but-is-happening-now type of 
> > problem.
> > 
> > Of the CC list, I believe Larry Woodman has the most experience 
> > with these sort of problems in the field so I'm hoping he'll make 
> > some sort of comment.
> 
> Yes. FYI, Larry's last set of patches (which Andrew essentially 
> NAK-ed) can be found attached below.
> 

I was made aware of that patch after V1 of this patchset and brought the
naming scheme more in line with Larry's. It's still up in the air what the
proper naming scheme should be. I went with mm_page* as the prefix which
I'm reasonably happy with but I've been hit on the nose with a rolled up
newspaper over naming before.

I also decided to just deal with the page allocator and not the MM as a whole
figuring that reviewing all MM tracepoints at the same time would be too much
to chew on and decide "are these the right tracepoints?". My expectation is
that there would need to be at least one set per headings;

page allocator
  subsys: kmem
  prefix: mm_page*
  example use: estimate zone lock contention

o slab allocator (already done)
  subsys: kmem
  prefix: kmem_* (although this wasn't consistent, e.g. kmalloc vs kmem_kmalloc)
  example use: measure allocation times for slab, slub, slqb

o high-level reclaim, kswapd wakeups, direct reclaim, lumpy triggers
  subsys: vmscan
  prefix: mm_vmscan*
  example use: estimate memory pressure

o low-level reclaim, list rotations, pages scanned, types of pages moving etc.
  subsys: vmscan
  prefix: mm_vmscan*
  (debugging VM tunables such as swappiness or why kswapd so active)

The following might also be useful for kernel developers but maybe less
useful in general so would be harder to justify.

o fault activity, anon, file, swap ins/outs 
o page cache activity
o readahead
o VM/FS, writeback, pdflush
o hugepage reservations, pool activity, faulting
o hotplug

> My general impression is that these things are very clearly useful, 
> but that it would also be nice to see a more structured plan about 
> what we want to instrument in the MM and what not so that a general 
> decision can be made instead of a creeping stream of ad-hoc 
> tracepoints with no end in sight.
> 
> I.e. have a full cycle set of tracepoints based on a high level 
> description - one (incomplete) sub-set i outlined here for example:
> 
>   http://lkml.org/lkml/2009/3/24/435
> 
> Adding a document about the page allocator and perhaps comment on 
> precisely what we want to trace would definitely be useful in 
> addressing Andrew's scepticism i think.
> 
> I.e. we'd have your patch in the end, but also with some feel-good 
> thoughts made about it on a higher level, so that we can be 
> reasonably sure that we have a meaningful set of tracepoints.
> 

Ok, I think I could put together such a description for the page allocator
tracepoints using the leader and your mail as starting points. I reckon the
best place for the end result would be Documentation/vm/tracepoints.txt

<Larry's patch snipped>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
