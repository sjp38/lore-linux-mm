Date: Fri, 16 Apr 2004 16:59:36 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: msync() needed before munmap() when writing to shared mapping?
Message-Id: <20040416165936.7fd9f5e1.akpm@osdl.org>
In-Reply-To: <20040416231009.GA27775@mail.shareable.org>
References: <20040416220223.GA27084@mail.shareable.org>
	<20040416154652.7ab27e79.akpm@osdl.org>
	<20040416231009.GA27775@mail.shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jamie Lokier <jamie@shareable.org> wrote:
>
> ...
> A related question.  The comment for MADV_DONTNEED says:
> 
>  * NB: This interface discards data rather than pushes it out to swap,
>  * as some implementations do.  This has performance implications for
>  * applications like large transactional databases which want to discard
>  * pages in anonymous maps after committing to backing store the data
>  * that was kept in them.  There is no reason to write this data out to
>  * the swap area if the application is discarding it.
>  *
>  * An interface that causes the system to free clean pages and flush
>  * dirty pages is already available as msync(MS_INVALIDATE).
> 
> MADV_DONTNEED calls zap_page_range().
> That propagates dirtiness into the pagecache.
> 
> So it *doesn't* "discard data rather than push it out to swap", if the
> same dirty data is mapped elsewhere e.g. as a shared anonymous
> mapping, does it?

Sure.  If some other process is using the same pages we don't go toss them
away.

> The comment also mentions MS_INVALIDATE, but MS_INVALIDATE doesn't do
> what the comment says and doesn't implement anything like POSIX
> either.  (Linux's MS_INVALIDATE is practically equivalent to MS_ASYNC).

Seems that way - MS_INVALIDATE will simply propagate pte dirtiness into
page dirtiness.  For non-file-backed mappings it is a no-op.

> Is there a call which does what the command about MS_INVALIDATE says,
> i.e. free clean pages and flush dirty ones?

Not really.  What is a clean anonymous page?  If it's ever been written to,
it's conceptually dirty, whether or not it is physically dirty.  ie: if you
invalidate it, you've lost your data.

I guess you could get a similar result by munmap() and then mmapping it
again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
