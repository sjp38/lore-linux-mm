Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA25619
	for <linux-mm@kvack.org>; Wed, 24 Mar 1999 12:14:53 -0500
Date: Wed, 24 Mar 1999 18:14:02 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: LINUX-MM
In-Reply-To: <14072.61217.315938.743360@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.05.9903241811530.1388-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@nl.linux.org>, Matthias Arnold <Matthias.Arnold@edda.imsid.uni-jena.de>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Mar 1999, Stephen C. Tweedie wrote:

>Hi,
>
>On Wed, 24 Mar 1999 01:33:53 +0100 (CET), Rik van Riel
><riel@nl.linux.org> said:
>
>> It is a bug when it causes other programs to fail
>> miserably...
>
>Does this happen, and if so, in what way?

I don't think that can happens. Anyway I just have a patch to return to
the old behavior, but I can't see any difference here (except that we
won't do the work on demand).

Just for the record my patch is this, probably it won't apply cleanly but
upporting it, it's trivial.

Index: linux/include/linux/swap.h
diff -c linux/include/linux/swap.h:1.1.1.1.14.3 linux/include/linux/swap.h:1.1.1.1.14.4
*** linux/include/linux/swap.h:1.1.1.1.14.3	Thu Oct 29 19:42:56 1998
--- linux/include/linux/swap.h	Sun Nov  1 18:20:48 1998
***************
*** 90,95 ****
--- 90,96 ----
  extern struct page * read_swap_cache_async(unsigned long, int);
  #define read_swap_cache(entry) read_swap_cache_async(entry, 1);
  extern int FASTCALL(swap_count(unsigned long));
+ extern void FASTCALL(try_to_free_last_swap_entry(unsigned long));
  /*
   * Make these inline later once they are working properly.
   */
Index: linux/mm/swap_state.c
diff -c linux/mm/swap_state.c:1.1.1.1.14.4 linux/mm/swap_state.c:1.1.1.1.14.5
*** linux/mm/swap_state.c:1.1.1.1.14.4	Fri Oct 30 19:11:15 1998
--- linux/mm/swap_state.c	Sun Nov  1 18:20:50 1998
***************
*** 287,292 ****
--- 287,316 ----
  	return 0;
  }
  
+ void try_to_free_last_swap_entry(unsigned long entry)
+ {
+ 	struct page * page = lookup_swap_cache(entry);
+ 	if (page)
+ 	{
+ 		/*
+ 		 * The last reference in the swap_map[entry] is caused
+ 		 * by this swap cache page.
+ 		 *
+ 		 * Decrease the page->count increased by __find_page().
+ 		 *						-arca
+ 		 */
+ 		__free_page(page);
+ 		if (atomic_read(&page->count) == 1)
+ 			/*
+ 			 * The page is resident in memory only because
+ 			 * it' s in the swap cache so we can remove it
+ 			 * because it can' t be useful anymore.
+ 			 *					-arca
+ 			 */
+ 			delete_from_swap_cache(page);
+ 	}
+ }
+ 
  /* 
   * Locate a page of swap in physical memory, reserving swap cache space
   * and reading the disk if it is not already cached.  If wait==0, we are
Index: linux/mm/swapfile.c
diff -c linux/mm/swapfile.c:1.1.1.1 linux/mm/swapfile.c:1.1.1.1.16.1
*** linux/mm/swapfile.c:1.1.1.1	Fri Oct  2 19:22:39 1998
--- linux/mm/swapfile.c	Sun Nov  1 18:20:50 1998
***************
*** 144,153 ****
  		p->highest_bit = offset;
  	if (!p->swap_map[offset])
  		goto bad_free;
! 	if (p->swap_map[offset] < SWAP_MAP_MAX) {
! 		if (!--p->swap_map[offset])
  			nr_swap_pages++;
! 	}
  #ifdef DEBUG_SWAP
  	printk("DebugVM: swap_free(entry %08lx, count now %d)\n",
  	       entry, p->swap_map[offset]);
--- 144,158 ----
  		p->highest_bit = offset;
  	if (!p->swap_map[offset])
  		goto bad_free;
! 	if (p->swap_map[offset] < SWAP_MAP_MAX)
! 		switch(--p->swap_map[offset])
! 		{
! 		case 0:
  			nr_swap_pages++;
! 			break;
! 		case 1:
! 			try_to_free_last_swap_entry(entry);
! 		}
  #ifdef DEBUG_SWAP
  	printk("DebugVM: swap_free(entry %08lx, count now %d)\n",
  	       entry, p->swap_map[offset]);

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
