Date: Thu, 18 Jan 2001 10:40:32 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: swapout selection change in pre1
In-Reply-To: <Pine.LNX.4.10.10101151047540.6247-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.31.0101181032150.31432-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Ed Tomlinson <tomlins@cam.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jan 2001, Linus Torvalds wrote:
> On Mon, 15 Jan 2001, Jamie Lokier wrote:
> >
> > Btw, reverse page mapping resolves this and makes it very simple: no
> > vmscanning (*), so no hand waving heuristic.
>
> Ehh.. Try to actually _implement_ reverse mapping, and THEN say that.
>
> Reverse mapping is basically not simple at all. For each page table entry,
> you need a
>
> 	struct reverse_map {
> 		/* actual pte pointer is implied by location,
> 		   if you implement this cleverly, but still
> 		   needed, of course */
> 		struct reverse_map *prev, *next;
> 		struct vm_struct *vma;
> 	};

Actually, you need only 2 pointers per page.

struct reverse_map {
	pte_t * pte;
	struct reverse_map * next;
};

To find the vma and mm, we will want to use the ->mapping
and ->index in the page_struct of the page table page to
indicate which mm_struct this page table is part of and which
offset this page table has in the mm_struct.

The only thing where this structure will be weak is when
you have many processes mapping the same page and blowing
away this single mapping (eg. on exec after fork, not vfork).

For large (many processes) systems it may be worth it to have
the *prev pointer as well. For small systems we can do without
it and reduce overhead.

Whether this extra memory use is offset by the fact that we can
get page replacement balancing right and page scanning CPU use
more predictable I don't know ... but I want to find out for 2.5 ;)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
