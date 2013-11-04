Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF426B0037
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 13:10:20 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id p10so6948241pdj.39
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 10:10:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.198])
        by mx.google.com with SMTP id cx4si11110269pbc.89.2013.11.04.10.10.18
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 10:10:19 -0800 (PST)
Received: by mail-wi0-f175.google.com with SMTP id hm4so952798wib.8
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 10:10:16 -0800 (PST)
Date: Mon, 4 Nov 2013 19:10:14 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131104181012.GK9299@localhost.localdomain>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <20131103101234.GB5330@gmail.com>
 <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
 <20131104070500.GE13030@gmail.com>
 <20131104142001.GE9299@localhost.localdomain>
 <20131104175245.GA19517@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131104175245.GA19517@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Jiri Olsa <jolsa@redhat.com>, Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, David Ahern <dsahern@gmail.com>

On Mon, Nov 04, 2013 at 06:52:45PM +0100, Ingo Molnar wrote:
> 
> * Frederic Weisbecker <fweisbec@gmail.com> wrote:
> 
> > On Mon, Nov 04, 2013 at 08:05:00AM +0100, Ingo Molnar wrote:
> > > 
> > > * Davidlohr Bueso <davidlohr@hp.com> wrote:
> > > 
> > > > Btw, do you suggest using a high level tool such as perf for getting 
> > > > this data or sprinkling get_cycles() in find_vma() -- I'd think that the 
> > > > first isn't fine grained enough, while the later will probably variate a 
> > > > lot from run to run but the ratio should be rather constant.
> > > 
> > > LOL - I guess I should have read your mail before replying to it ;-)
> > > 
> > > Yes, I think get_cycles() works better in this case - not due to 
> > > granularity (perf stat will report cycle granular just fine), but due 
> > > to the size of the critical path you'll be measuring. You really want 
> > > to extract the delta, because it's probably so much smaller than the 
> > > overhead of the workload itself.
> > > 
> > > [ We still don't have good 'measure overhead from instruction X to 
> > >   instruction Y' delta measurement infrastructure in perf yet, 
> > >   although Frederic is working on such a trigger/delta facility AFAIK. 
> > >   ]
> > 
> > Yep, in fact Jiri took it over and he's still working on it. But yeah, 
> > once that get merged, we should be able to measure instructions or 
> > cycles inside any user or kernel function through kprobes/uprobes or 
> > function graph tracer.
> 
> So, what would be nice is to actually make use of it: one very nice 
> usecase I'd love to see is to have the capability within the 'perf top' 
> TUI annotated assembly output to mark specific instructions as 'start' and 
> 'end' markers, and measure the overhead between them.

Yeah that would be a nice interface. Speaking about that, it would be nice to get your input
on the proposed interface for toggle events.

It's still in an RFC state, although it's getting quite elaborated, and I believe we haven't
yet found a real direction to take for the tooling interface IIRC. For example the perf record
cmdline used to state toggle events based contexts was one of the parts we were not that confident about.
And we really don't want to take a wrong direction for that as it's going to be complicated
to handle in any case.

See this thread:
https://lwn.net/Articles/568602/

thanks.

> 
> I.e. allow perf top / perf report to manage probes into interesting 
> functions - or create a similar TUI for 'perf probe' to allow easy live 
> marking/probing of various kernel functionality.
> 
> Thanks,
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
