Date: Wed, 3 May 2000 10:16:03 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <200005031635.JAA78671@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10005031003110.6049-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 3 May 2000, Kanoj Sarcar wrote:
> 
> What we are coming down to is a case by case analysis. For example,
> do_wp_page, which does pull a page out of the swap cache, has the
> vmlist_lock.

_which_ vmlist? You can share swapcache entries on multiple VM's, and that
is exactly what is_page_shared() is trying to protect against. 

Let's say that we have page X in the swap cache from process 1.

Process 2 also has that page, but it's in the page tables.

We do a vmscan on process 2, and will do a "swap_duplicate()" on the swap
entry that we find in page X and free the page (leaving it _just_ in the
swap cache), but at that exact moment another process 1 exits, for
example, and calls free_page_and_swap_cache(). If is_page_shared() gets
that wrong, we're now going to delete the page from the swap cache, yet we
now have an entry to it in the page tables on process 2.

And none of this seems to be synchronized - the vmlist lock is two
separate locks and doesn't protect this case. And as we've seen, vmscan
doesn't get the page lock.

Note that I don't actually believe in this schenario on x86, because with
processor ordering I suspect that is_page_shared() should still at worst
be too pessimistic, which is ok. I just think it's conceptually wrong.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
