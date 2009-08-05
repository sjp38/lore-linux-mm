Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DFBF36B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 03:53:23 -0400 (EDT)
Date: Wed, 5 Aug 2009 09:53:03 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090805075303.GG19322@elte.hu>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org> <20090804195717.GA5998@elte.hu> <20090804131818.ee5d4696.akpm@linux-foundation.org> <20090804203526.GA8699@elte.hu> <20090804135315.b2678e11.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090804135315.b2678e11.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, a.p.zijlstra@chello.nl, fweisbec@gmail.com, rostedt@goodmis.org, mel@csn.ul.ie, lwoodman@redhat.com, riel@redhat.com, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 4 Aug 2009 22:35:26 +0200
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > Did you never want to see whether firefox is leaking [any sort of] 
> > memory, and if yes, on what callsites? Try something like on an 
> > already running firefox context:
> > 
> >   perf stat -e kmem:mm_page_alloc \
> >             -e kmem:mm_pagevec_free \
> >             -e kmem:mm_page_free_direct \
> >      -p $(pidof firefox-bin) sleep 10
> > 
> > ... and "perf record" for the specific callsites.
> 
> OK, that would be useful.  What does the output look like?

I suspect Mel's output is an even better example.

> In what way is it superior to existing ways of finding leaks?

It's barely useful in this form - i just demoed the capability. perf 
stat is not a 'leak finding' special-purpose tool, but a generic 
tool that i used for this purpose as well, on an ad-hoc basis.

Tools that can be used in unexpected but still useful ways tend to 
be the best ones.

The kind of information these tracepoints expose, combined with the 
sampling and analysis features of perfcounters is the most 
high-quality information one can get about the page allocator IMO.

This is my general point: instead of wasting time and effort 
extending derived information, why not expose the core information? 
When the tracepoints are off there is essentially no overhead. 
(which is an added benefit - all the /proc/vmstat bits are collected 
unconditionally and then have to be summed up from all cpus when 
read out.)

> > this perf stuff is immensely flexible and a very unixish 
> > abstraction. The perf.data contains timestamped trace entries of 
> > page allocations and freeing done.
> > 
> > [...]
> > > It would be nice to at least partially remove the vmstat/meminfo 
> > > infrastructure but I don't think we can do that?
> > 
> > at least meminfo is an ABI for sure - vmstat too really.
> > 
> > But we can stop adding new fields into obsolete, inflexible and 
> > clearly deficient interfaces, and we can standardize new 
> > instrumentation to use modern instrumentation facilities - i.e. 
> > tracepoints and perfcounters.
> 
> That's bad.  Is there really no way in which we can consolidate 
> _any_ of that infrastructure?  We just pile in new stuff alongside 
> the old?
> 
> The worst part is needing two unrelated sets of userspace tools to 
> access basically-identical things.

We certainly should expose the full set of information to the new 
facility, so that it's self-sufficient and does not have to go 
digging in /proc for odd bits here and there (in various ad-hoc 
formats).

Above i'm arguing that since the old bits are an ABI, they should be 
kept but not extended.

btw., this is why i was resisting ad-hoc hacks like kpageflags. 
Those special-purpose instrumentation ABIs are hard to get rid of, 
and they come nowhere close to the utility of the real thing.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
