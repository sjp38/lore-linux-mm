Date: Wed, 4 Oct 2000 19:13:28 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Odd swap behavior
In-Reply-To: <39DBA9AA.AA4DEB1C@sgi.com>
Message-ID: <Pine.LNX.4.21.0010041909570.1054-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Oct 2000, Rajagopal Ananthanarayanan wrote:
> Rik van Riel wrote:
> 	[ ... ]
> > 
> > Please take a look at vmscan.c::refill_inactive()
> > 
> > Furthermore, we don't do background scanning on all
> > active pages, only on the unmapped ones.
> 
> Does that mean stack pages of processes are not included?
> Non-aggressive swap can hurt performance.	

I don't really see a clean way to do that in 2.4 ...

> > Agreed, but I don't see an "easy" solution for 2.4.
> 
> Ok, I have another suggestion. Suppose you had a situation
> where a page is read from disk. It has buffers. Initially
> the page is active, and then aged. Where does the page go at age = 0?
> In reading the current code it seems that it would go to
> inactive_dirty. See how deactivate_page() chooses the dirty list
> to add a page which has buffers. Of course, later page_launder()
> would do try_to_free_buffers() which discards (clean) buffer heads,
> and at that point the page is put on free_list/reclaimed.
> Would it not be more efficient to bung clean (read) pages directly
> to inactive_clean on age = 0?

I don't know if this would make any difference...

And in fact, I'm contemplating adding /all/ pages
that are deactivated to the inactive_dirty list,
since that way we'll reclaim all inactive pages
in FIFO order.

Currently we may "skip" some pages that were put
on the inactive_dirty list but were cleaned up
subsequently because we can find enough active
pages that can be moved to the inactive_clean
list immediately ...

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
