Date: Fri, 26 May 2000 12:16:32 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] page aging and deferred swapping for 2.4.0-test1
In-Reply-To: <392E916F.E102551D@norran.net>
Message-ID: <Pine.LNX.4.21.0005261213370.26570-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 May 2000, Roger Larsson wrote:

> Shouldn't lru_cache_add in swap.h initialize age?

It doesn't particularly matter where that is done, but I guess
lru_cache_add is a good place for it when you take readability
into account.

> > --- linux-2.4.0-test1/mm/page_alloc.c.orig      Thu May 25 12:27:47 2000
> > +++ linux-2.4.0-test1/mm/page_alloc.c   Thu May 25 18:37:44 2000
> > @@ -94,6 +94,8 @@
> >         if (PageDecrAfter(page))
> >                 BUG();
> > 
> > +       page->age = 2;
> > +
> 
> hmm...
> If this is a page that has beed used much, isn't it penalized to
> much, and don't we loose information...??? (all fread pages are the
> same)

You may want to read the code to see what __free_pages_ok
is actually used for.

> and in try_to_swap_out (mm/vmscan.c) we could change to
> 	/* Don't look at this pte if it's been accessed recently. */
> 	if (pte_young(pte)) {
> 		/*
> 		 * Transfer the "accessed" bit from the page
> 		 * tables to the global page map.
> 		 */
> 		set_pte(page_table, pte_mkold(pte));
>                 page->age += 3;
> 		goto out_failed;
> 	}

This is dead wrong. Suppose the page isn't in the lru queue ...
its age would get upped to infinite values.

Also, if a page is shared between multiple ptes, we don't want
to mess with its age at scanning all ptes. We are using the
PG_referenced bit exactly to avoid this bug.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
