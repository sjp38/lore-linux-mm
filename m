Date: Wed, 4 Oct 2000 21:07:09 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Odd swap behavior
In-Reply-To: <39DBB745.7D652E4E@sgi.com>
Message-ID: <Pine.LNX.4.21.0010042101050.1054-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Oct 2000, Rajagopal Ananthanarayanan wrote:
> Rik van Riel wrote:
> 
> > > Does that mean stack pages of processes are not included?
> > > Non-aggressive swap can hurt performance.
> > 
> > I don't really see a clean way to do that in 2.4 ...
> 
> We can perhaps talk about this at the Storage Workshop ...

That would be a great idea. Maybe over dinner or lunch,
with some of the other people present as well? ;)

[I'll also bring guarana, to facilitate all-night hacking
sessions]

> > > Would it not be more efficient to bung clean (read) pages directly
> > > to inactive_clean on age = 0?
> > 
> > I don't know if this would make any difference...
> 
> I think it would. Consider steady state where pages
> are all "in use". Any new allocation has to start with
> pushing a page from active -> inactive, and then
> inactive -> inactive_clean, if necessary, and then reclaim.
> Now,  if we had pages which _are_ clean, then the path taken
> is simply active -> inactive_clean -> reclaim.

Indeed. Then again, we probably want to clear the unused
buffer heads off of active pages anyway, and in that case
these pages will be cleaned for us.

This is something I'm looking into at the moment...

[But it has lower priority than out of memory and the
high memory lockup problem ... if that still exists]

> > And in fact, I'm contemplating adding /all/ pages
> > that are deactivated to the inactive_dirty list,
> > since that way we'll reclaim all inactive pages
> > in FIFO order.
> > 
> > Currently we may "skip" some pages that were put
> > on the inactive_dirty list but were cleaned up
> > subsequently because we can find enough active
> > pages that can be moved to the inactive_clean
> > list immediately ...
> > 
> 
> This is an interesting idea, although it seems
> antithetical to what I said above. I think pure
> FIFO has its merits in accomodating longer locality of
> reference; it can help dbench.

I have no idea if it would help or not; only one
way to find out I guess...

> If you have a patch (to always deactivate to inactive_dirty),
> I can help you gauge it with the benchmarks ...

Quick and dirty patch below ;)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/



--- swap.c.orig	Tue Oct  3 10:20:41 2000
+++ swap.c	Wed Oct  4 21:06:06 2000
@@ -201,7 +201,7 @@
 		} else if (page->mapping && !PageDirty(page) &&
 							!PageLocked(page)) {
 			del_page_from_active_list(page);
-			add_page_to_inactive_clean_list(page);
+			add_page_to_inactive_dirty_list(page);
 		}
 		/*
 		 * OK, we cannot free the page. Leave it alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
