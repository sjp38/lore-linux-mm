Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 93B1F600044
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 10:04:38 -0400 (EDT)
Received: by wwf26 with SMTP id 26so1449412wwf.26
        for <linux-mm@kvack.org>; Fri, 30 Jul 2010 07:04:36 -0700 (PDT)
Date: Fri, 30 Jul 2010 16:04:42 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 1/6] vmscan: tracing: Roll up of patches currently in
	mmotm
Message-ID: <20100730140441.GB5269@nowhere>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie> <1280497020-22816-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1280497020-22816-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 02:36:55PM +0100, Mel Gorman wrote:
> This is a roll-up of patches currently in mmotm related to stack reduction and
> tracing reclaim. It is based on 2.6.35-rc6 and included for the convenience
> of testing.
> 
> No signed off required.
> ---
>  .../trace/postprocess/trace-vmscan-postprocess.pl  |  654 ++++++++++++++++++++



I have the feeling you've made an ad-hoc post processing script that seems
to rewrite all the format parsing, debugfs, stream handling, etc... we
have that in perf tools already.

May be you weren't aware of what we have in perf in terms of scripting support.

First, launch perf list and spot the events you're interested in, let's
say you're interested in irqs:

$ perf list
  [...]
  irq:irq_handler_entry                      [Tracepoint event]
  irq:irq_handler_exit                       [Tracepoint event]
  irq:softirq_entry                          [Tracepoint event]
  irq:softirq_exit                           [Tracepoint event]
  [...]

Now do a trace record:

# perf record -e irq:irq_handler_entry -e irq:irq_handler_exit -e irq:softirq_entry -e irq:softirq_exit cmd

or more simple:

# perf record -e irq:* cmd

You can use -a instead of cmd for wide tracing.

Now generate a perf parsing script on top of these traces:

# perf trace -g perl
generated Perl script: perf-trace.pl


Fill up the trace handlers inside perf-trace.pl and just run it:

# perf trace -s perf-trace.pl

Once ready, you can place your script in the script directory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
