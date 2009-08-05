Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0569D6B009C
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 06:28:33 -0400 (EDT)
Date: Wed, 5 Aug 2009 12:27:50 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing script for page-allocator-related ftrace events
Message-ID: <20090805102750.GA2488@cmpxchg.org>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org> <4A787D84.2030207@redhat.com> <20090804121332.46df33a7.akpm@linux-foundation.org> <20090804204857.GA32092@csn.ul.ie> <20090805074103.GD19322@elte.hu> <20090805090742.GA21950@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805090742.GA21950@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>, Fr?d?ric Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 10:07:43AM +0100, Mel Gorman wrote:

> I also decided to just deal with the page allocator and not the MM as a whole
> figuring that reviewing all MM tracepoints at the same time would be too much
> to chew on and decide "are these the right tracepoints?". My expectation is
> that there would need to be at least one set per headings;
> 
> page allocator
>   subsys: kmem
>   prefix: mm_page*
>   example use: estimate zone lock contention
> 
> o slab allocator (already done)
>   subsys: kmem
>   prefix: kmem_* (although this wasn't consistent, e.g. kmalloc vs kmem_kmalloc)
>   example use: measure allocation times for slab, slub, slqb
> 
> o high-level reclaim, kswapd wakeups, direct reclaim, lumpy triggers
>   subsys: vmscan
>   prefix: mm_vmscan*
>   example use: estimate memory pressure
> 
> o low-level reclaim, list rotations, pages scanned, types of pages moving etc.
>   subsys: vmscan
>   prefix: mm_vmscan*
>   (debugging VM tunables such as swappiness or why kswapd so active)
> 
> The following might also be useful for kernel developers but maybe less
> useful in general so would be harder to justify.
> 
> o fault activity, anon, file, swap ins/outs 
> o page cache activity
> o readahead
> o VM/FS, writeback, pdflush
> o hugepage reservations, pool activity, faulting
> o hotplug

Maybe if more people would tell how they currently use tracepoints in
the MM we can find some common ground on what can be useful to more
than one person and why?

FWIW, I recently started using tracepoints at the following places for
looking at swap code behaviour:

	o swap slot alloc/free	[type, offset]
	o swap slot read/write	[type, offset]
	o swapcache add/delete	[type, offset]
	o swap fault/evict	[page->mapping, page->index, type, offset]

This gives detail beyond vmstat's possibilities at the cost of 8 lines
of trace_swap_foo() distributed over 5 files.

I have not aggregated the output so far, just looked at the raw data
and enjoyed reading how the swap slot allocator behaves in reality
(you can probably integrate the traces into snapshots of the whole
swap space layout), what load behaviour triggers insane swap IO
patterns, in what context is readahead reading the wrong pages etc.,
stuff you wouldn't see when starting out with statistical
aggregations.

Now, these data are pretty specialized and probably only few people
will make use of them, but OTOH, the cost they impose on the traced
code is so miniscule that it would be a much greater pain to 1) know
about and find third party patches and 2) apply, possibly forward-port
third party patches.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
