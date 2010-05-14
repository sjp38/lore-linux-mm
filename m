Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DC8BF6B01E3
	for <linux-mm@kvack.org>; Fri, 14 May 2010 14:49:54 -0400 (EDT)
Received: from f199130.upc-f.chello.nl ([80.56.199.130] helo=dyad.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1OCzxH-0001YF-Mt
	for linux-mm@kvack.org; Fri, 14 May 2010 18:49:51 +0000
Subject: Re: [RFC] Tracer Ring Buffer splice() vs page cache [was: Re: Perf
 and ftrace [was Re: PyTimechart]]
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100514183242.GA11795@Krystal>
References: <20100514183242.GA11795@Krystal>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 14 May 2010 20:49:05 +0200
Message-ID: <1273862945.1674.14.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-05-14 at 14:32 -0400, Mathieu Desnoyers wrote:

> [CCing memory management specialists]

And jet you forgot Jens who wrote it ;-)

> So I have three questions here:
> 
> 1 - could we enforce removal of these pages from the page cache by calling
>     "page_cache_release()" before giving these pages back to the ring buffer ?
> 
> 2 - or maybe is there a page flag we could specify when we allocate them to
>     ask for these pages to never be put in the page cache ? (but they should be
>     still usable as write buffers)
> 
> 3 - is there something more we need to do to grab a reference on the pages
>     before passing them to splice(), so that when we call page_cache_release()
>     they don't get reclaimed ? 

There is no guarantee it is the pagecache they end up in, it could be a
network packet queue, a pipe, or anything that implements .splice_write.

>From what I understand of splice() is that it assumes it passes
ownership of the page, you're not supposed to touch them again, non of
the above three are feasible.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
