Date: Wed, 3 May 2000 01:11:28 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <200005030526.WAA59352@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10005030046480.981-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Kanoj Sarcar wrote:
> Moi wrote:
> > 
> > Wow.
> > 
> > That code definitely looks buggy.
> > 
> > Looking at the whole try_to_swap_out() in this light shows how it messes
> > with a _lot_ of page information without holding the page lock. I thought
> > we fixed this once already, but maybe not.
> > 
> > In try_to_swap_out(), earlier it does a
> > 
> > 	if (PageLocked(page))
> > 		goto out_failed;
> > 
> > and that really is wrong - it should do a
> > 
> > 	if (TryLockPage(page))
> > 		goto out_failed;
> 
> Umm, I am not saying this is not a good idea, but maybe code that 
> try_to_swap_out() invokes (like filemap_swapout etc) need to be 
> taught that the incoming page has already been locked. 

Oh, definitely. It's more than a one-liner change. Right now all the code
afterwards is written with the notion that the page is unlocked, and
having the page locked means that things have to be done differently (eg
use "__add_to_page_cache()" instead of "add_to_page_cache()" etc - all the
functions that get the page expecting the caller to have already locked
it).

> Nonetheless, unless you show me a possible scenario that will lead
> to the observed panic, I am skeptical that this is the real problem.

You may be right. The code certainly tries to be careful. However, I don't
trust "is_page_shared()" at all, _especially_ if there are people around
who play with the page state without locking the page. 

If "is_page_shared()" ends up ever getting the wrong value, I suspect we'd
be screwed. There may be other schenarios..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
