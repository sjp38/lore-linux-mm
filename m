From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200005031731.KAA80944@google.engr.sgi.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
Date: Wed, 3 May 2000 10:31:06 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.10005031003110.6049-100000@penguin.transmeta.com> from "Linus Torvalds" at May 03, 2000 10:16:03 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> 
> On Wed, 3 May 2000, Kanoj Sarcar wrote:
> > 
> > What we are coming down to is a case by case analysis. For example,
> > do_wp_page, which does pull a page out of the swap cache, has the
> > vmlist_lock.
> 
> _which_ vmlist? You can share swapcache entries on multiple VM's, and that
> is exactly what is_page_shared() is trying to protect against. 
> 
> Let's say that we have page X in the swap cache from process 1.
> 
> Process 2 also has that page, but it's in the page tables.
> 
> We do a vmscan on process 2, and will do a "swap_duplicate()" on the swap
> entry that we find in page X and free the page (leaving it _just_ in the
> swap cache), but at that exact moment another process 1 exits, for
> example, and calls free_page_and_swap_cache(). If is_page_shared() gets
> that wrong, we're now going to delete the page from the swap cache, yet we
> now have an entry to it in the page tables on process 2.
>

Okay, here's this example in a little more detail:

Page X: page ref count: 1 (from swapcache) + 1 (from P2)
	swap ref count: 1 (from swapcache) + 1 (from P1)

try_to_swap_out will do something like this:

after the swap_duplicate:

Page X: page ref count: 1 (from swapcache) + 1 (from P2)
	swap ref count: 1 (from swapcache) + 1 (from P1) + 1 (swap_duplicate) 

later on, after __free_page:

Page X: page ref count: 1 (from swapcache)
	swap ref count: 1 (from swapcache) + 1 (from P1) + 1 (swap_duplicate) 

At no point between the time try_to_swap_out() is running, will is_page_shared()
wrongly indicate the page is _not shared_, when it is really shared (as you
say, it is pessimistic). 

Process 2 doing a free_page_and_swap_cache will thruout see the page as
shared.

A similar race in transferring the pageref count to swapcount also exists
in do_swap_page(), there the pagelock is held ...

When I sent some of the swapcache locking code to you, I convinced myself
that the code was protected. Of course, I might have let some conditions 
slip by in my reasoning, the code hasn't changed that much since then ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
