Date: Fri, 6 Apr 2001 01:40:23 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] swap_state.c thinko
Message-ID: <20010406014023.B1330@athlon.random>
References: <Pine.LNX.4.21.0104051304450.27736-100000@imladris.rielhome.conectiva> <Pine.LNX.4.30.0104051310470.1767-100000@today.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.30.0104051310470.1767-100000@today.toronto.redhat.com>; from bcrl@redhat.com on Thu, Apr 05, 2001 at 01:11:30PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, arjanv@redhat.com, alan@redhat.com, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 05, 2001 at 01:11:30PM -0400, Ben LaHaise wrote:
> diff -ur v2.4.3/mm/swap_state.c work-2.4.3/mm/swap_state.c
> --- v2.4.3/mm/swap_state.c	Fri Dec 29 18:04:27 2000
> +++ work-2.4.3/mm/swap_state.c	Thu Apr  5 13:10:27 2001
> @@ -140,10 +140,9 @@
>  	/*
>  	 * If we are the only user, then try to free up the swap cache.
>  	 */
> -	if (PageSwapCache(page) && !TryLockPage(page)) {
> -		if (!is_page_shared(page)) {
> +	if (!TryLockPage(page)) {
> +		if (PageSwapCache(page) && !is_page_shared(page))
>  			delete_from_swap_cache_nolock(page);
> -		}
>  		UnlockPage(page);
>  	}
>  	page_cache_release(page);

swap cache pages should not be freeable by the memory balancing code because if
you're running at that point the reference count of the swap cache has to be > 1.

swapoff will grab the pagetable spinlock before dropping the swap cache
so it shouldn't run under such code either (and swapoff was used to
have other window for races anyways).

could you elaborate what can eat the swap cache from under you if you
don't first lock down the page before checking the swapcache bit? I thought
the reason for grabbing the lock there is just to do the trylock instead
of lock_page(): we can't use the delete_from_swap_cache that could otherwise
sleep if the page was for example locked down by the memory balancing code
while we were running there (if we fail we simply left some more spurious swap
cache).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
