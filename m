Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CC3F36B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 12:52:51 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so7175318pab.26
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 09:52:51 -0800 (PST)
Received: from psmtp.com ([74.125.245.175])
        by mx.google.com with SMTP id bc2si11395446pad.71.2013.11.04.09.52.50
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 09:52:50 -0800 (PST)
Received: by mail-ea0-f176.google.com with SMTP id m14so418388eaj.7
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 09:52:48 -0800 (PST)
Date: Mon, 4 Nov 2013 18:52:45 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131104175245.GA19517@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <20131103101234.GB5330@gmail.com>
 <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
 <20131104070500.GE13030@gmail.com>
 <20131104142001.GE9299@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131104142001.GE9299@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>, Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, David Ahern <dsahern@gmail.com>


* Frederic Weisbecker <fweisbec@gmail.com> wrote:

> On Mon, Nov 04, 2013 at 08:05:00AM +0100, Ingo Molnar wrote:
> > 
> > * Davidlohr Bueso <davidlohr@hp.com> wrote:
> > 
> > > Btw, do you suggest using a high level tool such as perf for getting 
> > > this data or sprinkling get_cycles() in find_vma() -- I'd think that the 
> > > first isn't fine grained enough, while the later will probably variate a 
> > > lot from run to run but the ratio should be rather constant.
> > 
> > LOL - I guess I should have read your mail before replying to it ;-)
> > 
> > Yes, I think get_cycles() works better in this case - not due to 
> > granularity (perf stat will report cycle granular just fine), but due 
> > to the size of the critical path you'll be measuring. You really want 
> > to extract the delta, because it's probably so much smaller than the 
> > overhead of the workload itself.
> > 
> > [ We still don't have good 'measure overhead from instruction X to 
> >   instruction Y' delta measurement infrastructure in perf yet, 
> >   although Frederic is working on such a trigger/delta facility AFAIK. 
> >   ]
> 
> Yep, in fact Jiri took it over and he's still working on it. But yeah, 
> once that get merged, we should be able to measure instructions or 
> cycles inside any user or kernel function through kprobes/uprobes or 
> function graph tracer.

So, what would be nice is to actually make use of it: one very nice 
usecase I'd love to see is to have the capability within the 'perf top' 
TUI annotated assembly output to mark specific instructions as 'start' and 
'end' markers, and measure the overhead between them.

I.e. allow perf top / perf report to manage probes into interesting 
functions - or create a similar TUI for 'perf probe' to allow easy live 
marking/probing of various kernel functionality.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
