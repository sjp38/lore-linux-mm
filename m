Message-ID: <3A670E0E.5394FFFD@augan.com>
Date: Thu, 18 Jan 2001 16:38:54 +0100
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: swapout selection change in pre1
References: <Pine.LNX.4.31.0101181032150.31432-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Ed Tomlinson <tomlins@cam.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Rik van Riel wrote:

> > Reverse mapping is basically not simple at all. For each page table entry,
> > you need a
> >
> >       struct reverse_map {
> >               /* actual pte pointer is implied by location,
> >                  if you implement this cleverly, but still
> >                  needed, of course */
> >               struct reverse_map *prev, *next;
> >               struct vm_struct *vma;
> >       };
> 
> Actually, you need only 2 pointers per page.
> 
> struct reverse_map {
>         pte_t * pte;
>         struct reverse_map * next;
> };

To keep memory usage low and to still be reasonably fast, we could
restrict the size of a vma to two mmu levels and cache a pointer to the
pmd table in the vma, so you have less to lookup in the page table. It
would also speed up normal mapping/unmapping of entries for
architectures with more than 2 mmu levels. Generic mm code had mostly
only to deal with two mmu levels and e.g could call "pmd =
pmd_alloc_vma(vma, address);" instead of "pgd = pgd_offset(mm, address);
pmd = pmd_alloc(pgd, address);". No idea if this is fast enough for
balancing, but it would simplify other parts. :-)

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
