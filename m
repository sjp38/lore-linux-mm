Message-ID: <393293E1.4E6A81C4@norran.net>
Date: Mon, 29 May 2000 17:59:29 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] Re: [with-PATCH] deferred swapping + page aging (fwd)
References: <Pine.LNX.4.21.0005261758300.26570-100000@duckman.distro.conectiva>
Content-Type: multipart/mixed;
 boundary="------------72FF315F77920163F0C3B2FD"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------72FF315F77920163F0C3B2FD
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

This patch improves Riels patch by using fewer list modifications.
It could be applied to most shrink_mmaps but Riels version will
gain the most.

Function:
- Do not delete + insert all pages while scanning.
- Scan until a suitable page is found, then move the head.

/RogerL

Rik van Riel wrote:
> 
> [Arghhhh, this time with patch ;)]
> -------
> Hi,
> 
> Here is a WORKING version of the deferred swapping & page aging
> patch for 2.4.0-test1.
> 
> The patch implements:
> - deferred IO for pageout
> - rudimentary page aging, a start of what we want
>   for when we have an active list later
> 
> TODO:
> - deferred swapping for other IO (file, shm)
> - page aging for all pages
> - inactive / laundry / cache queues
> - ...
> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/               http://www.surriel.com/
> 
> --- linux-2.4.0-test1/mm/filemap.c.orig Thu May 25 12:27:47 2000
> +++ linux-2.4.0-test1/mm/filemap.c      Fri May 26 15:05:34 2000
> @@ -264,7 +264,16 @@
>                 page = list_entry(page_lru, struct page, lru);
>                 list_del(page_lru);
> 
> -               if (PageTestandClearReferenced(page))
> +               if (PageTestandClearReferenced(page)) {
> +                       page->age += 3;
> +                       if (page->age > 10)
> +                               page->age = 0;
> +                       goto dispose_continue;
> +               }
> +               if (page->age)
> +                       page->age--;
> +
> +               if (page->age)
>                         goto dispose_continue;
> 
>                 count--;
> @@ -317,28 +326,34 @@
>                         goto cache_unlock_continue;
> 
>                 /*
> +                * Page is from a zone we don't care about.
> +                * Don't drop page cache entries in vain.
> +                */
> +               if (page->zone->free_pages > page->zone->pages_high)
> +                       goto cache_unlock_continue;
> +
> +               /*
>                  * Is it a page swap page? If so, we want to
>                  * drop it if it is no longer used, even if it
>                  * were to be marked referenced..
>                  */
>                 if (PageSwapCache(page)) {
> -                       spin_unlock(&pagecache_lock);
> -                       __delete_from_swap_cache(page);
> -                       goto made_inode_progress;
> -               }
> -
> -               /*
> -                * Page is from a zone we don't care about.
> -                * Don't drop page cache entries in vain.
> -                */
> -               if (page->zone->free_pages > page->zone->pages_high)
> +                       if (!PageDirty(page)) {
> +                               spin_unlock(&pagecache_lock);
> +                               __delete_from_swap_cache(page);
> +                               goto made_inode_progress;
> +                       }
> +                       /* PageDeferswap -> we swap out the page now. */
> +                       if (gfp_mask & __GFP_IO)
> +                               goto async_swap;
>                         goto cache_unlock_continue;
> +               }
> 
>                 /* is it a page-cache page? */
>                 if (page->mapping) {
>                         if (!PageDirty(page) && !pgcache_under_min()) {
> -                               __remove_inode_page(page);
>                                 spin_unlock(&pagecache_lock);
> +                               __remove_inode_page(page);
>                                 goto made_inode_progress;
>                         }
>                         goto cache_unlock_continue;
> @@ -351,6 +366,14 @@
>  unlock_continue:
>                 spin_lock(&pagemap_lru_lock);
>                 UnlockPage(page);
> +               page_cache_release(page);
> +               goto dispose_continue;
> +async_swap:
> +               spin_unlock(&pagecache_lock);
> +               /* Do NOT unlock the page ... that is done after IO. */
> +               ClearPageDirty(page);
> +               rw_swap_page(WRITE, page, 0);
> +               spin_lock(&pagemap_lru_lock);
>                 page_cache_release(page);
>  dispose_continue:
>                 list_add(page_lru, &lru_cache);
> --- linux-2.4.0-test1/mm/page_alloc.c.orig      Thu May 25 12:27:47 2000
> +++ linux-2.4.0-test1/mm/page_alloc.c   Fri May 26 17:23:00 2000
> @@ -93,6 +93,8 @@
>                 BUG();
>         if (PageDecrAfter(page))
>                 BUG();
> +       if (PageDirty(page))
> +               BUG();
> 
>         zone = page->zone;
> 
> --- linux-2.4.0-test1/mm/swap_state.c.orig      Thu May 25 12:27:47 2000
> +++ linux-2.4.0-test1/mm/swap_state.c   Fri May 26 16:57:58 2000
> @@ -73,6 +73,7 @@
>                 PAGE_BUG(page);
> 
>         PageClearSwapCache(page);
> +       ClearPageDirty(page);
>         remove_inode_page(page);
>  }
> 
> --- linux-2.4.0-test1/mm/vmscan.c.orig  Thu May 25 12:27:47 2000
> +++ linux-2.4.0-test1/mm/vmscan.c       Fri May 26 16:55:03 2000
> @@ -62,6 +62,10 @@
>                 goto out_failed;
>         }
> 
> +       /* Can only do this if we age all active pages. */
> +       if (PageActive(page) && page->age > 1)
> +               goto out_failed;
> +
>         if (TryLockPage(page))
>                 goto out_failed;
> 
> @@ -74,6 +78,8 @@
>          * memory, and we should just continue our scan.
>          */
>         if (PageSwapCache(page)) {
> +               if (pte_dirty(pte))
> +                       SetPageDirty(page);
>                 entry.val = page->index;
>                 swap_duplicate(entry);
>                 set_pte(page_table, swp_entry_to_pte(entry));
> @@ -181,7 +187,10 @@
>         vmlist_access_unlock(vma->vm_mm);
> 
>         /* OK, do a physical asynchronous write to swap.  */
> -       rw_swap_page(WRITE, page, 0);
> +       // rw_swap_page(WRITE, page, 0);
> +       /* Let shrink_mmap handle this swapout. */
> +       SetPageDirty(page);
> +       UnlockPage(page);
> 
>  out_free_success:
>         page_cache_release(page);
> --- linux-2.4.0-test1/include/linux/mm.h.orig   Thu May 25 12:28:10 2000
> +++ linux-2.4.0-test1/include/linux/mm.h        Fri May 26 17:52:30 2000
> @@ -153,6 +153,7 @@
>         struct buffer_head * buffers;
>         unsigned long virtual; /* nonzero if kmapped */
>         struct zone_struct *zone;
> +       unsigned int age;
>  } mem_map_t;
> 
>  #define get_page(p)            atomic_inc(&(p)->count)
> @@ -169,7 +170,7 @@
>  #define PG_dirty                4
>  #define PG_decr_after           5
>  #define PG_unused_01            6
> -#define PG__unused_02           7
> +#define PG_active               7
>  #define PG_slab                         8
>  #define PG_swap_cache           9
>  #define PG_skip                        10
> @@ -185,6 +186,7 @@
>  #define ClearPageUptodate(page)        clear_bit(PG_uptodate, &(page)->flags)
>  #define PageDirty(page)                test_bit(PG_dirty, &(page)->flags)
>  #define SetPageDirty(page)     set_bit(PG_dirty, &(page)->flags)
> +#define ClearPageDirty(page)   clear_bit(PG_dirty, &(page)->flags)
>  #define PageLocked(page)       test_bit(PG_locked, &(page)->flags)
>  #define LockPage(page)         set_bit(PG_locked, &(page)->flags)
>  #define TryLockPage(page)      test_and_set_bit(PG_locked, &(page)->flags)
> @@ -192,6 +194,9 @@
>                                         clear_bit(PG_locked, &(page)->flags); \
>                                         wake_up(&page->wait); \
>                                 } while (0)
> +#define PageActive(page)       test_bit(PG_active, &(page)->flags)
> +#define SetPageActive(page)    set_bit(PG_active, &(page)->flags)
> +#define ClearPageActive(page)  clear_bit(PG_active, &(page)->flags)
>  #define PageError(page)                test_bit(PG_error, &(page)->flags)
>  #define SetPageError(page)     set_bit(PG_error, &(page)->flags)
>  #define ClearPageError(page)   clear_bit(PG_error, &(page)->flags)
> --- linux-2.4.0-test1/include/linux/swap.h.orig Thu May 25 12:28:13 2000
> +++ linux-2.4.0-test1/include/linux/swap.h      Fri May 26 16:54:41 2000
> @@ -168,12 +168,15 @@
>         spin_lock(&pagemap_lru_lock);           \
>         list_add(&(page)->lru, &lru_cache);     \
>         nr_lru_pages++;                         \
> +       page->age = 4;                          \
> +       SetPageActive(page);                    \
>         spin_unlock(&pagemap_lru_lock);         \
>  } while (0)
> 
>  #define        __lru_cache_del(page)                   \
>  do {                                           \
>         list_del(&(page)->lru);                 \
> +       ClearPageActive(page);                  \
>         nr_lru_pages--;                         \
>  } while (0)
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--------------72FF315F77920163F0C3B2FD
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test1-deferred_swap-speedup.1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test1-deferred_swap-speedup.1"

261c261
< 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
---
> 	/* we need pagemap_lru_lock for lru_cache head movement... subtle code below */
263c263,268
< 	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
---
> 	page_lru = &lru_cache;
> 	while (count > 0) {
>                 page_lru = page_lru->prev;
>                 if (page_lru == &lru_cache)
> 		  break; /* one whole run */
> 
265d269
< 		list_del(page_lru);
270,271c274,275
< 				page->age = 0;
< 			goto dispose_continue;
---
> 				page->age = 10;
> 			continue;
277c281
< 			goto dispose_continue;
---
> 			continue;
285c289
< 			goto dispose_continue;
---
> 			continue;
288c292,302
< 			goto dispose_continue;
---
> 			continue;
> 
> 		/* move header before unlock...
> 		 * NOTE: the page to scan might move on while having
> 		 * pagemap_lru unlocked. Avoid rescanning same pages
> 		 * by moving head and set page_lru to NULL to avoid
> 		 * misuses!
> 		 */
>                 list_del(&lru_cache);
> 		list_add_tail(&lru_cache, page_lru);
> 		page_lru = NULL;
324a339,341
> 		if (page_count(page) < 2)
> 		  BUG();
> 
348c365
< 				goto async_swap;
---
> 				goto async_swap_continue;
371c388
< async_swap:
---
> async_swap_continue:
375a393
> 		/* no lock held here? SMP? is page_cache_get enough? */
379c397
< 		list_add(page_lru, &lru_cache);
---
> 		page_lru =  &lru_cache;
386,388d403
< 	UnlockPage(page);
< 	page_cache_release(page);
< 	ret = 1;
389a405
>         list_del(&page->lru); /* page_lru is NULL... */
391a408,410
> 	UnlockPage(page);
> 	page_cache_release(page);
> 	ret = 1;

--------------72FF315F77920163F0C3B2FD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
