Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AE8086B01E8
	for <linux-mm@kvack.org>; Mon, 17 May 2010 18:42:48 -0400 (EDT)
Date: Mon, 17 May 2010 18:42:43 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [RFC] Tracer Ring Buffer splice() vs page cache [was: Re: Perf
	and ftrace [was Re: PyTimechart]]
Message-ID: <20100517224243.GA10603@Krystal>
References: <20100514183242.GA11795@Krystal> <1273862945.1674.14.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273862945.1674.14.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra (peterz@infradead.org) wrote:
> On Fri, 2010-05-14 at 14:32 -0400, Mathieu Desnoyers wrote:
> 
> > [CCing memory management specialists]
> 
> And jet you forgot Jens who wrote it ;-)

oops ! thanks for adding him.

> 
> > So I have three questions here:
> > 
> > 1 - could we enforce removal of these pages from the page cache by calling
> >     "page_cache_release()" before giving these pages back to the ring buffer ?
> > 
> > 2 - or maybe is there a page flag we could specify when we allocate them to
> >     ask for these pages to never be put in the page cache ? (but they should be
> >     still usable as write buffers)
> > 
> > 3 - is there something more we need to do to grab a reference on the pages
> >     before passing them to splice(), so that when we call page_cache_release()
> >     they don't get reclaimed ? 
> 
> There is no guarantee it is the pagecache they end up in, it could be a
> network packet queue, a pipe, or anything that implements .splice_write.
> 
> >From what I understand of splice() is that it assumes it passes
> ownership of the page, you're not supposed to touch them again, non of
> the above three are feasible.

Yup, I've looked more deeply at the splice() code, and I now see why things
don't fall apart in LTTng currently. My implementation seems to be causing
splice() to perform a copy. My ring buffer splice implementation is derived from
kernel/relay.c. I override

pipe_buf_operations release op with:

static void ltt_relay_pipe_buf_release(struct pipe_inode_info *pipe,
                                       struct pipe_buffer *pbuf)
{
}

and

splice_pipe_desc spd_release file op with:

static void ltt_relay_page_release(struct splice_pipe_desc *spd, unsigned int i)
{
}

My understanding is that by keeping 2 references on the pages (the ring buffer +
the pipe), splice safely refuses to move the pages and performs a copy instead.

I'll continue to look into this. One of the things I noticed that that we could
possibly use the "steal()" operation to steal the pages back from the page cache
to repopulate the ring buffer rather than continuously allocating new pages. If
steal() fails for some reasons, then we can fall back on page allocation. I'm
not sure it is safe to assume anything about pages being in the page cache
though. Maybe the safest route is to just allocate new pages for now.

Thoughts ?

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
