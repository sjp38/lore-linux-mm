Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B56076B01D1
	for <linux-mm@kvack.org>; Tue, 18 May 2010 11:43:41 -0400 (EDT)
Date: Tue, 18 May 2010 11:43:27 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [RFC] Tracer Ring Buffer splice() vs page cache [was: Re: Perf
	and ftrace [was Re: PyTimechart]]
Message-ID: <20100518154327.GC7748@Krystal>
References: <20100514183242.GA11795@Krystal> <1273862945.1674.14.camel@laptop> <20100517224243.GA10603@Krystal> <1274185160.5605.7787.camel@twins> <20100518151626.GA7748@Krystal> <1274196233.5605.8169.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1274196233.5605.8169.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra (peterz@infradead.org) wrote:
> On Tue, 2010-05-18 at 11:16 -0400, Mathieu Desnoyers wrote:
> > > Also, suppose it was still in the page-cache and still dirty, a steal()
> > > would then punch a hole in the file.
> > 
> > page_cache_pipe_buf_steal starts by doing a wait_on_page_writeback(page); and
> > then does a try_to_release_page(page, GFP_KERNEL). Only if that succeeds is the
> > action of stealing succeeding. 
> 
> If you're going to wait for writeback I don't really see the advantage
> of stealing over simply allocating a new page.

That would allow the ring buffer to use a bounded amount of memory and not
pollute the page cache uselessly. When allocating pages as you propose, the
tracer will quickly fill and pollute the page cache with trace file pages, which
will have a large impact on I/O behavior. But in 99.9999% of use-cases, we don't
ever need to access them after they have been saved to disk.

By re-stealing its own pages after waiting for the writeback to complete, the
ring buffer would use a bounded amount of pages. If larger buffers are needed,
the user just has to specify a larger buffer size.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
