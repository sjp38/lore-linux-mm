Date: Tue, 15 Aug 2000 19:10:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: filemap.c SMP bug in 2.4.0-test*
Message-ID: <Pine.LNX.4.21.0008151845550.2466-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

it appears that a debugging check in my VM patch has uncovered
a bug in filemap.c (which could explain the "innd failing"
thread on linux-kernel).

The debugging check (in mm/swap.c::lru_cache_add(), line 232)
checks if the page which is to be added to the page lists is
already on one of the lists. In case it is, a nice backtrace
follows...

from mm/swap.c:
    227 void lru_cache_add(struct page * page)
    228 {
    229         spin_lock(&pagemap_lru_lock);
    230         if (!PageLocked(page))
    231                 BUG();
    232         DEBUG_ADD_PAGE
    233         add_page_to_active_list(page);

from include/mm/swap.h:
    199 #define DEBUG_ADD_PAGE \
    200         if (PageActive(page) || PageInactiveDirty(page) || \
    201                              PageInactiveClean(page)) BUG();

The backtrace I got points to some place deep inside
mm/filemap.c, in code I really didn't touch and I
wouldn't want to touch if this bug wasn't here ;)

>>EIP; c012e370 <lru_cache_add+5c/d4>   <=====
Trace; c021b33e <tvecs+1dde/19f60>
Trace; c021b579 <tvecs+2019/19f60>
Trace; c0127823 <add_to_page_cache_locked+cb/dc>
Trace; c0130a3c <add_to_swap_cache+84/8c>
Trace; c0130d00 <read_swap_cache_async+68/98>
Trace; c0125c8b <handle_mm_fault+143/1c0>
Trace; c0113d33 <do_page_fault+143/3f0>

I've had a few variants of this, but always the
add_to_page_cache* functions were involved...

BTW, in the normal source tree, this situation
could lead to corruption of the lru list. Maybe
this explains the innd problems, maybe not, but
I think we should at least add the debugging
code to vanilla 2.4 as well in order to catch
this bug.

On a related note, the new VM patch seems to be
well-behaved, solid and nicely performant now. ;)

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
