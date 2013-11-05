Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id EB4316B0037
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 03:24:57 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so7957687pdj.34
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 00:24:57 -0800 (PST)
Received: from psmtp.com ([74.125.245.137])
        by mx.google.com with SMTP id w7si1478135pbg.292.2013.11.05.00.24.55
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 00:24:56 -0800 (PST)
Received: by mail-ee0-f42.google.com with SMTP id c1so1238490eek.1
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 00:24:54 -0800 (PST)
Date: Tue, 5 Nov 2013 09:24:51 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131105082450.GA10127@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <20131103101234.GB5330@gmail.com>
 <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
 <20131104070500.GE13030@gmail.com>
 <20131104142001.GE9299@localhost.localdomain>
 <20131104175245.GA19517@gmail.com>
 <20131104181012.GK9299@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131104181012.GK9299@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>, Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, David Ahern <dsahern@gmail.com>


* Frederic Weisbecker <fweisbec@gmail.com> wrote:

> On Mon, Nov 04, 2013 at 06:52:45PM +0100, Ingo Molnar wrote:
> > 
> > * Frederic Weisbecker <fweisbec@gmail.com> wrote:
> > 
> > > On Mon, Nov 04, 2013 at 08:05:00AM +0100, Ingo Molnar wrote:
> > > > 
> > > > * Davidlohr Bueso <davidlohr@hp.com> wrote:
> > > > 
> > > > > Btw, do you suggest using a high level tool such as perf for getting 
> > > > > this data or sprinkling get_cycles() in find_vma() -- I'd think that the 
> > > > > first isn't fine grained enough, while the later will probably variate a 
> > > > > lot from run to run but the ratio should be rather constant.
> > > > 
> > > > LOL - I guess I should have read your mail before replying to it ;-)
> > > > 
> > > > Yes, I think get_cycles() works better in this case - not due to 
> > > > granularity (perf stat will report cycle granular just fine), but due 
> > > > to the size of the critical path you'll be measuring. You really want 
> > > > to extract the delta, because it's probably so much smaller than the 
> > > > overhead of the workload itself.
> > > > 
> > > > [ We still don't have good 'measure overhead from instruction X to 
> > > >   instruction Y' delta measurement infrastructure in perf yet, 
> > > >   although Frederic is working on such a trigger/delta facility AFAIK. 
> > > >   ]
> > > 
> > > Yep, in fact Jiri took it over and he's still working on it. But yeah, 
> > > once that get merged, we should be able to measure instructions or 
> > > cycles inside any user or kernel function through kprobes/uprobes or 
> > > function graph tracer.
> > 
> > So, what would be nice is to actually make use of it: one very nice 
> > usecase I'd love to see is to have the capability within the 'perf top' 
> > TUI annotated assembly output to mark specific instructions as 'start' and 
> > 'end' markers, and measure the overhead between them.
> 
> Yeah that would be a nice interface. Speaking about that, it would be nice to get your input
> on the proposed interface for toggle events.
> 
> It's still in an RFC state, although it's getting quite elaborated, and I believe we haven't
> yet found a real direction to take for the tooling interface IIRC. For example the perf record
> cmdline used to state toggle events based contexts was one of the parts we were not that confident about.
> And we really don't want to take a wrong direction for that as it's going to be complicated
> to handle in any case.
> 
> See this thread:
> https://lwn.net/Articles/568602/

At the risk of hijacking this discussion, here's my take on triggers:

I think the primary interface should be to allow the disabling/enabling of 
a specific event from other events.

>From user-space it would be fd driven: add a perf attribute to allow a 
specific event to set the state of another event if it triggers. The 
'other event' would be an fd, similar to how group events are specified.

An 'off' trigger sets the state to 0 (disabled).
An 'on' trigger sets the state to 1 (enabled).

Using such a facility the measurement of deltas would need 3 events:

 - fd1: a cycles event that is created disabled

 - fd2: a kprobes event at the 'start' RIP, set to counting only,
        connected to fd1, setting state to '1'

 - fd3: a kprobes event at the 'stop' RIP, set to counting only,
        connected to fd1, setting state to '0'.

This way every time the (fd2) start-RIP kprobes event executes, the 
trigger code sees that it's supposed to enable the (fd1) cycles event. 
Every time the (fd3) stop-RIP kprobes event executes, the trigger code 
sees that it's set to disable the (fd1) cycles event.

Instead of 'cycles event', it could count instructions, or pagefaults, or 
cachemisses.

( If the (fd1) cycles event is a sampling event then this would allow nice 
  things like the profiling of individual functions within the context of 
  a specific system call, driven by triggers. )

In theory we could allow self-referential triggers as well: the first 
execution of the trigger would disable itself. If the trigger state is not 
on/off but a counter then this would allow 'take 100 samples then shut 
off' type of functionality as well.

But success primarily depends on how useful the tooling UI turns out to 
be: create a nice Slang or GTK UI for kprobes and triggers, and/or turn it 
into a really intuitive command line UI, and people will use it.

I think annotated assembly/source output is a really nice match for 
triggers and kprobes, so I'd suggest the Slang TUI route ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
