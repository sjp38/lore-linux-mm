Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA16111
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 17:14:02 -0500
Date: Mon, 23 Nov 1998 22:59:38 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Running 2.1.129 at extrem load [patch] (Was: Linux-2.1.129..)
In-Reply-To: <19981123215359.45625@boole.suse.de>
Message-ID: <Pine.LNX.3.96.981123224942.6626B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm <linux-mm@kvack.org>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Nov 1998, Dr. Werner Fink wrote:

>  	struct page *next_hash;
>  	atomic_t count;
> -	unsigned int unused;
> +	unsigned int lifetime;
>  	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */

Hmm, this looks suspiciously like a new incarnation of
page aging (which we want to avoid, at least in some
parts of the kernel).

> --- linux-2.1.129/mm/filemap.c	Thu Nov 19 20:44:18 1998
> +++ linux/mm/filemap.c	Mon Nov 23 13:38:47 1998
> @@ -167,15 +167,14 @@
>  	case 1:
>  		/* is it a swap-cache or page-cache page? */
>  		if (page->inode) {
> -			/* Throw swap-cache pages away more aggressively */
> -			if (PageSwapCache(page)) {
> -				delete_from_swap_cache(page);
> -				return 1;
> -			}
>  			if (test_and_clear_bit(PG_referenced, &page->flags))
>  				break;
>  			if (pgcache_under_min())
>  				break;
> +			if (PageSwapCache(page)) {
> +				delete_from_swap_cache(page);
> +				return 1;
> +			}

This piece looks good and will result in us keeping swap cached
pages when the page cache is low. We might want to include this
in the current kernel tree, together with the removal of the
free_after construction.

> diff -urN linux-2.1.129/mm/vmscan.c linux/mm/vmscan.c
> --- linux-2.1.129/mm/vmscan.c	Thu Nov 19 20:44:18 1998
> +++ linux/mm/vmscan.c	Mon Nov 23 19:34:21 1998
> @@ -131,12 +131,21 @@
>  		return 0;
>  	}
>  
> +	/* life time decay */
> +	if (page_map->lifetime > PAGE_DECLINE)
> +		page_map->lifetime -= PAGE_DECLINE;
> +	else
> +		page_map->lifetime = 0;
> +	if (page_map->lifetime)
> +		return 0;
> +

Sorry Werner, but this is exactly the place where we need to
remove any from of page aging. We can do some kind of aging
in the swap cache, page cache and buffer cache, but doing
aging here is just prohibitively expensive and needs to be
removed.

IMHO a better construction be to have a page->fresh flag
which would be set on unmapping from swap_out(). Then
shrink_mmap() would free pages with page->fresh reset
and reset page->fresh if it is set. This way we can
free a page at it's second scan so we avoid freeing
a page that was just unmapped (and giving each page a
bit of a chance to undergo cheap aging).

regards,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
