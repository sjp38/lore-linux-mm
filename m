Date: Fri, 19 Jan 2001 18:55:59 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] 2-pointer PTE chaining idea
In-Reply-To: <Pine.LNX.4.10.10101182307340.9418-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.31.0101191849050.3368-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jan 2001, Linus Torvalds wrote:
> On Thu, 18 Jan 2001, David S. Miller wrote:
> > Rik van Riel writes:
> >  > In order to find the vma and the mm_struct each pte belongs to,
> >  > we can use the ->mapping and ->index fields in the page_struct
> >  > of the page table, with the ->mapping pointing to the mm_struct
> >  > and the ->index containing the offset within the mm_struct
> >
> > Anonymous pages have no page->mapping, how can this work?
>
> Note the "in the page struct of the page table".
>                                     ^^^^^^^^^^
>
> What Rik is saying is that if your page tables themselves are full pages
> (which is not true everywhere, but hey, close enough), you can use the
> "struct page *" of the _page_table_ page to save off the "struct
> mm_struct" pointer, along with the base in the mm_struct.

> It doesn't help us, though. 2 or 3 pointers doesn't make any difference on
> x86, at least: the 3-pointer-scheme had a "next, prev, mm" pointer triple,
> and there is an _implied_ pointer pointing to the page table entry itself,
> that Rik probably forgot about.

Actually, the pointer is to the page table entry ... on systems
where the page table is a multiple of the full page we know that
the page table itself has address:

page_table = pte_t & ~(PAGE_TABLE_SIZE - 1);

And from there we can easily get the struct page *.

> The only sane way I can think of to do the "implied pointer" is to do an
> order-2 allocation when you allocate a page directory: you get 16kB of

How about doing an order-1 allocation and having a singly linked
list ?

The structure would then look like this (on x86)

struct bidir_page_table {
	struct pte_t pte[1024];
	void * next[1024];
};

With next[400]:
- indicating that pte[400] is in the pte chain we're currently
  searching
- pointing to the next pointer in the pte chain, much like used
  block listed in the FAT filesystem

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
