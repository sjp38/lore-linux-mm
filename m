Date: Wed, 16 Aug 2000 00:40:47 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: filemap.c SMP bug in 2.4.0-test*
In-Reply-To: <Pine.LNX.4.10.10008152018100.3600-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0008160031330.3400-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Aug 2000, Linus Torvalds wrote:
> On Tue, 15 Aug 2000, Rik van Riel wrote:
> > 
> > The backtrace I got points to some place deep inside
> > mm/filemap.c, in code I really didn't touch and I
> > wouldn't want to touch if this bug wasn't here ;)
> > 
> > >>EIP; c012e370 <lru_cache_add+5c/d4>   <=====
> > Trace; c021b33e <tvecs+1dde/19f60>
> > Trace; c021b579 <tvecs+2019/19f60>
> > Trace; c0127823 <add_to_page_cache_locked+cb/dc>
> > Trace; c0130a3c <add_to_swap_cache+84/8c>
> > Trace; c0130d00 <read_swap_cache_async+68/98>
> > Trace; c0125c8b <handle_mm_fault+143/1c0>
> > Trace; c0113d33 <do_page_fault+143/3f0>
> 
> Look at this back-trace again.
> 
> In particular, look at which page read_swap_cache_async() adds
> to the swap cache.

> *****   new_page_addr = __get_free_page(GFP_USER);		*******

> In short, read_swap_cache_async() allocates a new page that
> nobody else has access to. There's no way in hell that page is
> going to be on any LRU lists.

*nod*

> The bug pretty much has to be in the new page flag handling. No,
> I don't see anything wrong in your patch, but we're talking
> about a code-path that has it's own very private page that
> cannot be shared unless there are some pretty major bugs (if
> __get_free_page() returns a page that is still in use somewhere,
> we're _soo_ screwed).

I've seen the call trace with sys_write and sys_read
too, so I assume that it's indeed __alloc_pages() which
hands over a page with one of the flags still set.

Question is, how did that thing get on the free list
in the first place?  __free_pages_ok() checks for the
flags and reclaim_page() also checks for all of the
flags (inside the del_page_from_inactive_clean_list
macro)...

I've been looking at this code very closely over the
last week and fail to see any possibility for this
to happen, but where there's a bug there's a way ;)

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
