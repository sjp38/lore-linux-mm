Subject: Re: Question on swapping
From: Amol Kumar Lad <amolk@ishoni.com>
In-Reply-To: <3DF071C3.C3E1EC39@scs.ch>
References: <3DF071C3.C3E1EC39@scs.ch>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 06 Dec 2002 20:29:50 -0500
Message-Id: <1039224592.4551.57.camel@amol.in.ishoni.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: Joseph A Knapka <jknapka@earthlink.net>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Fri, 2002-12-06 at 04:45, Martin Maletinsky wrote:
> Hello Joe,
> 
> Thank you for your reply. I have an additional question.
> 
> Joseph A Knapka wrote:
> 
> > Martin Maletinsky wrote:
> > > Hello,
> > >
> > > I am looking at the swapping mechanism in Linux. I have read the
> relevant chapter 16 in 'Understanding the Linux Kernel' from
> Bovet&Cesati, and looked at the 2.2.18 kernel
> > > source code. I still have the follwing question:
> > >
> > > Function try_to_swap_out() [p. 481 in 'Understanding the Linux
> Kernel']:
> > > If the page in question already belongs to the swap cache, the
> function performs no data transfer to the swap space on the disk (but
> only marks the page as swapped out).
> > > The corresponding comment in the try_to_swap_out() functions states
> 'Is the page already in the swap cache? If so, ..... - it is already
> up-to-date on disk.
> > > Understanding the Linux Kernel states on p. 482 'If the page belongs
> to the swap cache .... no memory transfer is performed'.
> > > Now my question is, couldn't the page have been modified since it
> was added to the swap cache (and written to disk), and thus differ from
> the data in the swap space? In
> > > this case shouldn't the page be written to disk (again)?
> >
> > If the page is in the swap cache, it's *effectively* up to date on
> disk,
> > because the swap cache page is *the* authoritative image of the page.
> > If it's dirty it will get written out by page_launder() in short
> > order, because whomever dirtied it set the page_dirty bit in the
> > page struct. That issue is unimportant to the process doing the
> > swap_out, though - all it cares about is that the page is going
> > to be taken care of by the cache machinery.
> 
> Assume a page P that is marked as clean (i.e. PG_dirty bit not set), and
> is in the page cache. Additionaly assume that P is mapped by a process
> A. Now let A perform a store
> operation into the page P, which will mark A's page table entry mapping
> P as dirty (i.e. set the dirty bit).
> Subsequently assume that try_to_swap_out() is called on A's page table
> entry that maps P. try_to_swap_out() will see that P is in the swap
> cache already,
>>>> For the first time P would never be found in the swap cache, infact
try_to_swap_out shall do following
a] Page is dirty (in page table entry), so set PG_DIRTY in struct page
b] Allocate a swap entry and add this page to swap cache
c] release the page, and add the modify page table entry to point it to
swap entry

Now We have 
a] Page table entry for P contains swap info
b] Page P in swap cache
c] PG_DIRTY _is_ set (infact for a page in swap cache this is always
true)

Do remember, along with the swap cache P may be party of inactive_dirty
list.

The actual swapping to backing store is done by page scanner.
It shall do following. Assume it has decided to _really_ free P
1] As page is dirty, call the page write back function. Thus here for
the first time page found its place in swap.
2] send P back home, to buddy allocator

If process A again access the page, then page fault handler shall do
following
1] allocate a swap cache page
2] read the page from swap.
3] Modify page table entry of A to point to this page 

Just give a little thought about all this, VM shall reveal herself to
you :)

bye
Amol



 and thus drop the pte.
> This leads to a situation, where P is in the swap cache, marked as clear
> (i.e. PG_dirty bit clear), while the disk image differs from the data
> that is in the main memory page
> frame.
> I would have expected try_to_swap_out() to check the page table entries
> dirty bit, and to mark the page dirty. However, I can't see any such
> code in the function (I pasted the
> relevant lines of code from linux 2.2.18 below).
> 
> static int try_to_swap_out(struct task_struct * tsk, struct
> vm_area_struct* vma,
>          unsigned long address, pte_t * page_table, int gfp_mask)
>  {
>          pte_t pte;
>          unsigned long entry;
>          unsigned long page;
>          struct page * page_map;
> 
>          pte = *page_table;
>          if (!pte_present(pte))
>                  return 0;
>          page = pte_page(pte);
>          if (MAP_NR(page) >= max_mapnr)
>                  return 0;
>          page_map = mem_map + MAP_NR(page);
> 
>          if (pte_young(pte)) {
>                  /*
>                   * Transfer the "accessed" bit from the page
>                   * tables to the global page map.
>                   */
>                  set_pte(page_table, pte_mkold(pte));
>                  flush_tlb_page(vma, address);
>                  set_bit(PG_referenced, &page_map->flags);
>                  return 0;
>          }
> 
>          if (PageReserved(page_map)
>              || PageLocked(page_map)
>              || ((gfp_mask & __GFP_DMA) && !PageDMA(page_map)))
>                  return 0;
> 
>          /*
>           * Is the page already in the swap cache? If so, then
>           * we can just drop our reference to it without doing
>           * any IO - it's already up-to-date on disk.
>           *
>           * Return 0, as we didn't actually free any real
>           * memory, and we should just continue our scan.
>           */
>          if (PageSwapCache(page_map)) {
>                  entry = page_map->offset;
>                  swap_duplicate(entry);
>                  set_pte(page_table, __pte(entry));
>  drop_pte:
>                  vma->vm_mm->rss--;
>                  flush_tlb_page(vma, address);
>                  __free_page(page_map);
>                  return 0;
>          }
> ............
> 
> 
> Thanks again, with best regards
> Martin
> 
> --
> Supercomputing System AG          email: maletinsky@scs.ch
> Martin Maletinsky                 phone: +41 (0)1 445 16 05
> Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
> CH-8005 Zurich
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
