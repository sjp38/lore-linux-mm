Date: Wed, 16 Aug 2000 01:09:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: filemap.c SMP bug in 2.4.0-test*
In-Reply-To: <Pine.LNX.4.21.0008160031330.3400-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0008160046270.3400-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Aug 2000, Rik van Riel wrote:
> On Tue, 15 Aug 2000, Linus Torvalds wrote:

> > In particular, look at which page read_swap_cache_async() adds
> > to the swap cache.
> 
> > *****   new_page_addr = __get_free_page(GFP_USER);		*******
> 
> > In short, read_swap_cache_async() allocates a new page that
> > nobody else has access to. There's no way in hell that page is
> > going to be on any LRU lists.

> Question is, how did that thing get on the free list
> in the first place?  __free_pages_ok() checks for the
> flags and reclaim_page() also checks for all of the
> flags

OK, I have a vague and highly improbable idea about
this (but no clue about some of the subsystems I'm
going to assume things about).

What if the page we barf on was part of a multi-page
contiguous allocation?

Suppose some subsystem (like nfs) allocates an 8kB
contiguous area, which gets filled with data and mmap()ed
by a user process.

At that moment, _both_ pages are put into the lru list and
flagged as such. Now if the "lower" of the two pages gets
released and the upper is still in the list, a hypothetical
buggy driver (maybe even nfs) would do a __free_pages_ok()
on the DOUBLE page, even though the "higher" page is still
in use (and has the bit set).

That way a page with one of the page list flags set could
slip by the check in __free_pages_ok. I know this is an
improbable theory, but it's the only way I can see which
would bypass the checks in __free_pages_ok (and the one
in reclaim_page)...

[yes, I know I must get some sleep and look at this
stuff when I'm awake ;)]

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
