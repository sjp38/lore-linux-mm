Date: Thu, 18 Jan 2001 23:17:35 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] 2-pointer PTE chaining idea
In-Reply-To: <14951.58719.533776.944814@pizda.ninka.net>
Message-ID: <Pine.LNX.4.10.10101182307340.9418-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>


On Thu, 18 Jan 2001, David S. Miller wrote:

> 
> Rik van Riel writes:
>  > In order to find the vma and the mm_struct each pte belongs to,
>  > we can use the ->mapping and ->index fields in the page_struct
>  > of the page table, with the ->mapping pointing to the mm_struct
>  > and the ->index containing the offset within the mm_struct
> 
> Anonymous pages have no page->mapping, how can this work?

Note the "in the page struct of the page table".
                                    ^^^^^^^^^^

What Rik is saying is that if your page tables themselves are full pages
(which is not true everywhere, but hey, close enough), you can use the
"struct page *" of the _page_table_ page to save off the "struct
mm_struct" pointer, along with the base in the mm_struct. You can then lok
up the vma the normal way (get the mm->page_table_lock, and search for it,
you know where the page table entry is in the page table, and you know
where the page table itself is virtually).

It doesn't help us, though. 2 or 3 pointers doesn't make any difference on
x86, at least: the 3-pointer-scheme had a "next, prev, mm" pointer triple,
and there is an _implied_ pointer pointing to the page table entry itself,
that Rik probably forgot about.

The only sane way I can think of to do the "implied pointer" is to do an
order-2 allocation when you allocate a page directory: you get 16kB of
memory, and you use the low 4kB for the hardware page table stuff, with
the upper 3kB for the pointers associated with the page table entries. You
do this for two reasons: 
 - still only one allocation
 - this way you can get from the pointers to the page table entry (and
   the other way around) by arithmetic rather than having to have a
   pointer to the page table entry.

But this also means that If you need 2 pointers, you might as well use 3
extra words anyway, because otherwise you'd just have an unused 32-bit
word for every page table entry anyway.

Whatever. Maybe it can be done other ways. The fact that the way I thought
to implement it was with an order-2 allocation to do this efficiently is
what really killed it for me. Maybe Rik has other ideas. I don't think
order-2 allocations are acceptable.

		Linus


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
