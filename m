Date: Wed, 31 Mar 2004 17:26:43 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040331152643.GD2143@dualathlon.random>
References: <Pine.LNX.4.58.0403261013480.672@ruby.engin.umich.edu> <20040326175842.GC9604@dualathlon.random> <Pine.GSO.4.58.0403271448120.28539@sapphire.engin.umich.edu> <20040329172248.GR3808@dualathlon.random> <Pine.GSO.4.58.0403291240040.14450@eecs2340u20.engin.umich.edu> <20040329180109.GW3808@dualathlon.random> <20040329124027.36335d93.akpm@osdl.org> <20040329223900.GK3808@dualathlon.random> <20040329144243.393d21a8.akpm@osdl.org> <20040331150718.GC2143@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040331150718.GC2143@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2004 at 05:07:18PM +0200, Andrea Arcangeli wrote:
> diff -urNp --exclude CVS --exclude BitKeeper --exclude {arch} --exclude .arch-ids x-ref/mm/page_io.c x/mm/page_io.c
> --- x-ref/mm/page_io.c	2004-03-31 16:57:25.505978008 +0200
> +++ x/mm/page_io.c	2004-03-31 17:06:07.028694504 +0200
> @@ -139,7 +139,7 @@ struct address_space_operations swap_aop
>  
>  /*
>   * A scruffy utility function to read or write an arbitrary swap page
> - * and wait on the I/O.
> + * and wait on the I/O.  The caller must have a ref on the page.
>   */
>  int rw_swap_page_sync(int rw, swp_entry_t entry, struct page *page)
>  {
> @@ -149,10 +149,9 @@ int rw_swap_page_sync(int rw, swp_entry_
>  	};
>  
>  	lock_page(page);
> -
> -	BUG_ON(page->mapping);
> -	page->mapping = &swapper_space;
> -	page->index = entry.val;
> +	ret = add_to_swap_cache(page, entry);
> +	if (unlikely(ret))
> +		goto out_unlock;
>  
>  	if (rw == READ) {
>  		ret = swap_readpage(NULL, page);
> @@ -161,7 +160,12 @@ int rw_swap_page_sync(int rw, swp_entry_
>  		ret = swap_writepage(page, &swap_wbc);
>  		wait_on_page_writeback(page);
>  	}
> -	page->mapping = NULL;
> +
> +	lock_page(page);
> +	delete_from_swap_cache(page);
> + out_unlock:
> +	unlock_page(page);
> +
>  	if (ret == 0 && (!PageUptodate(page) || PageError(page)))
>  		ret = -EIO;
>  	return ret;
> 
> 

this trivial bit is needed as well to allow compilation, you can append
it to the previous patch:

--- x/include/linux/swap.h.~1~	2004-03-31 17:13:05.064143456 +0200
+++ x/include/linux/swap.h	2004-03-31 17:21:34.241736696 +0200
@@ -192,6 +192,7 @@ extern struct address_space swapper_spac
 #define total_swapcache_pages  swapper_space.nrpages
 extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *);
+extern int add_to_swap_cache(struct page *page, swp_entry_t entry);
 extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern int move_to_swap_cache(struct page *, swp_entry_t);
--- x/mm/swap_state.c.~1~	2004-03-31 17:13:05.249115336 +0200
+++ x/mm/swap_state.c	2004-03-31 17:21:15.201631232 +0200
@@ -56,7 +56,7 @@ void show_swap_cache_info(void)
 		swap_cache_info.noent_race, swap_cache_info.exist_race);
 }
 
-static int add_to_swap_cache(struct page *page, swp_entry_t entry)
+int add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
 	int error;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
