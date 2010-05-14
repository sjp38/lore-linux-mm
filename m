Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 532D36B01F0
	for <linux-mm@kvack.org>; Fri, 14 May 2010 14:32:53 -0400 (EDT)
Date: Fri, 14 May 2010 14:32:42 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: [RFC] Tracer Ring Buffer splice() vs page cache [was: Re: Perf and
	ftrace [was Re: PyTimechart]]
Message-ID: <20100514183242.GA11795@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra (peterz@infradead.org) wrote:
> On Thu, 2010-05-13 at 12:31 -0400, Mathieu Desnoyers wrote:
> > 
> > In addition, this would play well with mmap() too: we can simply add a
> > ring_buffer_get_mmap_offset() method to the backend (exported through another
> > ioctl) that would let user-space know the start of the mmap'd buffer range
> > currently owned by the reader. So we can inform user-space of the currently
> > owned page range without even changing the underlying memory map. 
> 
> I still think keeping refs to splice pages is tricky at best. Suppose
> they're spliced into the pagecache of a file, it could stay there for a
> long time under some conditions.
> 
> Also, the splice-client (say the pagecache) and the mmap will both want
> the pageframe to contain different information.

[CCing memory management specialists]

You bring a very interesting point. Let me describe what I want to achieve, and
see what others have to say about it:

I want the ring buffer to allocate pages only at ring buffer creation (never
while tracing). There are a few reasons why I want to do that, ranging from
improved performance to limited system disturbance.

Now let suppose we have the synchronization mechanism (detailed in the original
thread, but not relevant to this part of the discussion) that lets us give the
pages to the ring buffer "reader", which sends them to splice() so it can use
them as write buffers. Let also suppose that the ring buffer reader blocks until
the pages are written to the disk (synchronous write). In my scheme, the reader
still has pointers to these pages.

The point you bring here is that when the ring buffer "reader" is woken up,
these pages could still be in the page cache. So when the reader gives these
pages back to the ring buffer (so they can be used for writing again), the page
cache may still hold a reference to them, so the pages in the page cache and the
version on disk could be unsynchronized, and therefore this could possibly lead
to trace file corruption (in the worse case).

So I have three questions here:

1 - could we enforce removal of these pages from the page cache by calling
    "page_cache_release()" before giving these pages back to the ring buffer ?

2 - or maybe is there a page flag we could specify when we allocate them to
    ask for these pages to never be put in the page cache ? (but they should be
    still usable as write buffers)

3 - is there something more we need to do to grab a reference on the pages
    before passing them to splice(), so that when we call page_cache_release()
    they don't get reclaimed ?

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
