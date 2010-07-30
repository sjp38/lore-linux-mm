Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 33DE56B02AB
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 10:12:57 -0400 (EDT)
Date: Fri, 30 Jul 2010 15:12:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/6] vmscan: tracing: Roll up of patches currently in
	mmotm
Message-ID: <20100730141217.GG3571@csn.ul.ie>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie> <1280497020-22816-2-git-send-email-mel@csn.ul.ie> <20100730140441.GB5269@nowhere>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100730140441.GB5269@nowhere>
Sender: owner-linux-mm@kvack.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 04:04:42PM +0200, Frederic Weisbecker wrote:
> On Fri, Jul 30, 2010 at 02:36:55PM +0100, Mel Gorman wrote:
> > This is a roll-up of patches currently in mmotm related to stack reduction and
> > tracing reclaim. It is based on 2.6.35-rc6 and included for the convenience
> > of testing.
> > 
> > No signed off required.
> > ---
> >  .../trace/postprocess/trace-vmscan-postprocess.pl  |  654 ++++++++++++++++++++
> 
> I have the feeling you've made an ad-hoc post processing script that seems
> to rewrite all the format parsing, debugfs, stream handling, etc... we
> have that in perf tools already.
> 

It's an hoc adaption of trace-pagealloc-postprocess.pl which was developed
before the perf scripting report. It's a bit klunky.

> May be you weren't aware of what we have in perf in terms of scripting support.
> 

I'm aware, I just haven't gotten around to adapting what the script does
to the perf scripting support. The existance of the script I have means
people can reproduce my results without having to wait for me to rewrite
the post-processing scripts for perf.

> First, launch perf list and spot the events you're interested in, let's
> say you're interested in irqs:
> 
> $ perf list
>   [...]
>   irq:irq_handler_entry                      [Tracepoint event]
>   irq:irq_handler_exit                       [Tracepoint event]
>   irq:softirq_entry                          [Tracepoint event]
>   irq:softirq_exit                           [Tracepoint event]
>   [...]
> 
> Now do a trace record:
> 
> # perf record -e irq:irq_handler_entry -e irq:irq_handler_exit -e irq:softirq_entry -e irq:softirq_exit cmd
> 
> or more simple:
> 
> # perf record -e irq:* cmd
> 
> You can use -a instead of cmd for wide tracing.
> 
> Now generate a perf parsing script on top of these traces:
> 
> # perf trace -g perl
> generated Perl script: perf-trace.pl
> 
> Fill up the trace handlers inside perf-trace.pl and just run it:
> 
> # perf trace -s perf-trace.pl
> 
> Once ready, you can place your script in the script directory.
> 

Ultimately, the post-processing scripts should be adapted to perf but it
could be a while before I get around to it.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
