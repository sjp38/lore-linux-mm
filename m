Subject: Re: pressuring dirty pages (2.3.99-pre6)
References: <Pine.LNX.4.21.0004241922270.5572-100000@duckman.conectiva>
From: ebiederman@uswest.net (Eric W. Biederman)
Date: 25 Apr 2000 08:58:47 -0500
In-Reply-To: Rik van Riel's message of "Mon, 24 Apr 2000 19:42:12 -0300 (BRST)"
Message-ID: <m166t6ffjc.fsf@flinx.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On Mon, 24 Apr 2000, Stephen C. Tweedie wrote:
> > On Mon, Apr 24, 2000 at 04:54:38PM -0300, Rik van Riel wrote:
> > > 
> > > I've been trying to fix the VM balance for a week or so now,
> > > and things are mostly fixed except for one situation.
> > > 
> > > If there is a *heavy* write going on and the data is in the
> > > page cache only .. ie. no buffer heads available, then the
> > > page cache will grow almost without bounds and kswapd and
> > > the rest of the system will basically spin in shrink_mmap()...
> > 
> > shrink_mmap is the problem then -- it should be giving up sooner
> > and letting try_to_swap_out() deal with the pages.  mmap()ed
> > dirty pages can only be freed through swapper activity, not via
> > shrink_mmap().
> 
> That will not work. The problem isn't that kswapd eats cpu,
> but the problem is that the dirty pages completely dominate
> physical memory.
> 
> I've tried the "giving up earlier" option in shrink_mmap(),
> but that leads to memory filling up just as badly and giving
> us the same kind of trouble.
> 
> I guess what we want is the kind of callback that we do in
> the direction of the buffer cache, using something like the
> bdflush wakeup call done in try_to_free_buffers() ...
> 
> Maybe a "special" return value from shrink_mmap() telling
> do_try_to_free_pages() to run swap_out() unconditionally
> after this succesful shrink_mmap() call?  Maybe even with
> severity levels?
> 
> Eg. more calls to swap_out() if we encountered a lot of
> dirty pages in shrink_mmap() ???

I suspect the simplest thing we could do would be to actually implement
a RSS limit per struct mm.  Roughly in handle_pte_fault if the page isn't
present and we are at our rss limit call swap_out_mm, until we are
below the limit.  

This won't hurt much in the uncontended case, because the page
cache will still keep everything anyway, some dirty pages
will just get buffer_heads, and bdflush might clean those pages.

In the contended case, it removes some of the burden from swap_out,
and it should give shrink_mmap some pages to work with...

How we can approach the ideal of dynamically managed max RSS
sizes is another question...

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
