Message-ID: <39119655.D6E97EF6@norran.net>
Date: Thu, 04 May 2000 17:25:09 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] Alternate shrink_mmap
References: <Pine.LNX.4.21.0005021837080.10610-100000@duckman.conectiva> <39116F1B.7882BF6A@norran.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I have noticed (not by running - lucky me) that I break this
assumption....
/*
 * NOTE: to avoid deadlocking you must never acquire the pagecache_lock
with
 *       the pagemap_lru_lock held.
 */

/RogerL

Roger Larsson wrote:
> 
> Hi all,
> 
> Here is an alternative shrink_mmap.
> It tries to touch the list as little as possible
> (only young pages are moved)
> 
> And tries to be quick.
> 
> Comments please.
> 
> It compiles but I have not dared to run it yet...
> (My biggest patch yet)
> 
> /RogerL
> 
> --
> Home page:
>   http://www.norran.net/nra02596/
> 
>   ------------------------------------------------------------------------
> diff -Naur linux-2.3-pre7+/mm/filemap.c linux-2.3/mm/filemap.c
> --- linux-2.3-pre7+/mm/filemap.c        Mon May  1 21:41:10 2000
> +++ linux-2.3/mm/filemap.c      Thu May  4 13:30:36 2000
> @@ -237,143 +237,149 @@
>  {
>         int ret = 0, count;
>         LIST_HEAD(young);
> -       LIST_HEAD(old);
>         LIST_HEAD(forget);
>         struct list_head * page_lru, * dispose;
>         struct page * page = NULL;
>         struct zone_struct * p_zone;
> -
> +
> +       /* This could be removed.
> +        * NULL translates to: fulfill all zone requests. */
>         if (!zone)
>                 BUG();
> 
>         count = nr_lru_pages >> priority;
> -       if (!count)
> -               return ret;
> 
>         spin_lock(&pagemap_lru_lock);
>  again:
> -       /* we need pagemap_lru_lock for list_del() ... subtle code below */
> -       while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
> -               page = list_entry(page_lru, struct page, lru);
> -               list_del(page_lru);
> -               p_zone = page->zone;
> -
> -               /* This LRU list only contains a few pages from the system,
> -                * so we must fail and let swap_out() refill the list if
> -                * there aren't enough freeable pages on the list */
> -
> -               /* The page is in use, or was used very recently, put it in
> -                * &young to make sure that we won't try to free it the next
> -                * time */
> -               dispose = &young;
> -               if (test_and_clear_bit(PG_referenced, &page->flags))
> -                       goto dispose_continue;
> -
> -               if (p_zone->free_pages > p_zone->pages_high)
> -                       goto dispose_continue;
> -
> -               if (!page->buffers && page_count(page) > 1)
> -                       goto dispose_continue;
> -
> -               count--;
> -               /* Page not used -> free it or put it on the old list
> -                * so it gets freed first the next time */
> -               dispose = &old;
> -               if (TryLockPage(page))
> -                       goto dispose_continue;
> -
> -               /* Release the pagemap_lru lock even if the page is not yet
> -                  queued in any lru queue since we have just locked down
> -                  the page so nobody else may SMP race with us running
> -                  a lru_cache_del() (lru_cache_del() always run with the
> -                  page locked down ;). */
> -               spin_unlock(&pagemap_lru_lock);
> -
> -               /* avoid freeing the page while it's locked */
> -               get_page(page);
> -
> -               /* Is it a buffer page? */
> -               if (page->buffers) {
> -                       if (!try_to_free_buffers(page))
> -                               goto unlock_continue;
> -                       /* page was locked, inode can't go away under us */
> -                       if (!page->mapping) {
> -                               atomic_dec(&buffermem_pages);
> -                               goto made_buffer_progress;
> -                       }
> -               }
> -
> -               /* Take the pagecache_lock spinlock held to avoid
> -                  other tasks to notice the page while we are looking at its
> -                  page count. If it's a pagecache-page we'll free it
> -                  in one atomic transaction after checking its page count. */
> -               spin_lock(&pagecache_lock);
> -
> -               /*
> -                * We can't free pages unless there's just one user
> -                * (count == 2 because we added one ourselves above).
> -                */
> -               if (page_count(page) != 2)
> -                       goto cache_unlock_continue;
> -
> -               /*
> -                * Is it a page swap page? If so, we want to
> -                * drop it if it is no longer used, even if it
> -                * were to be marked referenced..
> -                */
> -               if (PageSwapCache(page)) {
> -                       spin_unlock(&pagecache_lock);
> -                       __delete_from_swap_cache(page);
> -                       goto made_inode_progress;
> -               }
> -
> -               /* is it a page-cache page? */
> -               if (page->mapping) {
> -                       if (!PageDirty(page) && !pgcache_under_min()) {
> -                               remove_page_from_inode_queue(page);
> -                               remove_page_from_hash_queue(page);
> -                               page->mapping = NULL;
> -                               spin_unlock(&pagecache_lock);
> -                               goto made_inode_progress;
> -                       }
> -                       goto cache_unlock_continue;
> -               }
> -
> -               dispose = &forget;
> -               printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
> -
> +       for (page_lru = lru_cache.prev;
> +            count-- && page_lru != &lru_cache;
> +            page_lru = page_lru->prev) {
> +         page = list_entry(page_lru, struct page, lru);
> +         p_zone = page->zone;
> +
> +
> +         /* Check if zone has pressure, most pages would continue here.
> +          * Also pages from zones that initally was under pressure */
> +         if (!p_zone->zone_wake_kswapd)
> +           continue;
> +
> +         /* Can't do anything about this... */
> +         if (!page->buffers && page_count(page) > 1)
> +           continue;
> +
> +         /* Page not used -> free it
> +          * If it could not be locked it is somehow in use
> +          * try another time */
> +         if (TryLockPage(page))
> +           continue;
> +
> +         /* Ok, a possible page.
> +         * Note: can't unlock lru if we do we will have
> +         * to restart this loop */
> +
> +         /* The page is in use, or was used very recently, put it in
> +          * &young to make it ulikely that we will try to free it the next
> +          * time */
> +         dispose = &young;
> +         if (test_and_clear_bit(PG_referenced, &page->flags))
> +           goto dispose_continue;
> +
> +
> +         /* avoid freeing the page while it's locked [RL???] */
> +         get_page(page);
> +
> +         /* If it can not be freed here it is unlikely to
> +          * at next attempt. */
> +         dispose = NULL;
> +
> +         /* Is it a buffer page? */
> +         if (page->buffers) {
> +           if (!try_to_free_buffers(page))
> +             goto unlock_continue;
> +           /* page was locked, inode can't go away under us */
> +           if (!page->mapping) {
> +             atomic_dec(&buffermem_pages);
> +             goto made_buffer_progress;
> +           }
> +         }
> +
> +
> +         /* Take the pagecache_lock spinlock held to avoid
> +            other tasks to notice the page while we are looking at its
> +            page count. If it's a pagecache-page we'll free it
> +            in one atomic transaction after checking its page count. */
> +         spin_lock(&pagecache_lock);
> +
> +         /*
> +          * We can't free pages unless there's just one user
> +          * (count == 2 because we added one ourselves above).
> +          */
> +         if (page_count(page) != 2)
> +           goto cache_unlock_continue;
> +
> +         /*
> +          * Is it a page swap page? If so, we want to
> +          * drop it if it is no longer used, even if it
> +          * were to be marked referenced..
> +          */
> +         if (PageSwapCache(page)) {
> +           spin_unlock(&pagecache_lock);
> +           __delete_from_swap_cache(page);
> +           goto made_inode_progress;
> +         }
> +
> +         /* is it a page-cache page? */
> +         if (page->mapping) {
> +           if (!PageDirty(page) && !pgcache_under_min()) {
> +             remove_page_from_inode_queue(page);
> +             remove_page_from_hash_queue(page);
> +             page->mapping = NULL;
> +             spin_unlock(&pagecache_lock);
> +             goto made_inode_progress;
> +           }
> +           goto cache_unlock_continue;
> +         }
> +
> +         dispose = &forget;
> +         printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
> +
>  cache_unlock_continue:
> -               spin_unlock(&pagecache_lock);
> +         spin_unlock(&pagecache_lock);
>  unlock_continue:
> -               spin_lock(&pagemap_lru_lock);
> -               UnlockPage(page);
> -               put_page(page);
> -               list_add(page_lru, dispose);
> -               continue;
> +         /* never released... spin_lock(&pagemap_lru_lock); */
> +         UnlockPage(page);
> +         put_page(page);
> +         if (dispose == NULL) /* only forget should end up here - predicted taken */
> +           continue;
> 
> -               /* we're holding pagemap_lru_lock, so we can just loop again */
>  dispose_continue:
> -               list_add(page_lru, dispose);
> -       }
> -       goto out;
> +         list_del(page_lru);
> +         list_add(page_lru, dispose);
> +         continue;
> 
>  made_inode_progress:
> -       page_cache_release(page);
> +         page_cache_release(page);
>  made_buffer_progress:
> -       UnlockPage(page);
> -       put_page(page);
> -       ret = 1;
> -       spin_lock(&pagemap_lru_lock);
> -       /* nr_lru_pages needs the spinlock */
> -       nr_lru_pages--;
> -
> -       /* wrong zone?  not looped too often?    roll again... */
> -       if (page->zone != zone && count)
> -               goto again;
> +         UnlockPage(page);
> +         put_page(page);
> +         ret++;
> +         /* never unlocked... spin_lock(&pagemap_lru_lock); */
> +         /* nr_lru_pages needs the spinlock */
> +         list_del(page_lru);
> +         nr_lru_pages--;
> +
> +         /* Might (and should) have been done by free calls
> +          * p_zone->zone_wake_kswapd = 0;
> +          */
> +
> +         /* If no more pages are needed to release on specifically
> +            requested zone concider it done!
> +            Note: zone might be NULL to make all requests fulfilled */
> +         if (p_zone == zone && !p_zone->zone_wake_kswapd)
> +           break;
> +       }
> 
> -out:
>         list_splice(&young, &lru_cache);
> -       list_splice(&old, lru_cache.prev);
> 
>         spin_unlock(&pagemap_lru_lock);
> 

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
