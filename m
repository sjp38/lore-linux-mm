Date: Thu, 5 Apr 2001 18:21:10 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.30.0104051155380.1767-100000@today.toronto.redhat.com>
Message-ID: <Pine.LNX.4.21.0104051758360.1715-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: arjanv@redhat.com, alan@redhat.com, torvalds@transmeta.com, sct@redhat.com, jerrell@missioncriticallinux.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2001, Ben LaHaise wrote:
> 
> Here's another one liner that closes an smp race that could corrupt
> things.
> 
> diff -urN v2.4.3/mm/swap_state.c work-2.4.3/mm/swap_state.c
> --- v2.4.3/mm/swap_state.c	Fri Dec 29 18:04:27 2000
> +++ work-2.4.3/mm/swap_state.c	Thu Apr  5 11:55:00 2001
> @@ -140,7 +140,7 @@
>  	/*
>  	 * If we are the only user, then try to free up the swap cache.
>  	 */
> -	if (PageSwapCache(page) && !TryLockPage(page)) {
> +	if (!TryLockPage(page) && PageSwapCache(page)) {
>  		if (!is_page_shared(page)) {
>  			delete_from_swap_cache_nolock(page);
>  		}

I agree that PageSwapCache(page) needs to be retested when(if) the
page lock is acquired, but isn't it best to check PageSwapCache(page)
first as at present - won't it very often fail? won't the overhead of
TryLocking and Unlocking every page slow down a hot path?

And isn't this free_page_and_swap_cache(), precisely the area that's
currently subject to debate and patches, because swap pages are not
getting freed soon enough?  I haven't been following that discussion
with full understanding, and haven't seen a full explanation of the
problem to be solved; but I'd rather _imagined_ it was that the page
would here be on an LRU list, raising its count and causing the
is_page_shared(page) test to succeed despite not really shared.
So I'd been expecting a patch to remove this code completely.

Forgive me if way off base...
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
