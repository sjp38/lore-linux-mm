Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA28648
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 15:43:30 -0500
Subject: Re: Linux-2.1.129..
References: <m1r9uudxth.fsf@flinx.ccr.net> <Pine.LNX.3.95.981123120028.5712B-100000@penguin.transmeta.com> <199811241525.PAA00862@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 25 Nov 1998 21:33:50 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Tue, 24 Nov 1998 15:25:03 GMT"
Message-ID: <87n25f5x75.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> --- mm/vmscan.c~	Tue Nov 17 15:43:55 1998
> +++ mm/vmscan.c	Mon Nov 23 17:05:33 1998
> @@ -170,7 +170,7 @@
>  			 * copy in memory, so we add it to the swap
>  			 * cache. */
>  			if (PageSwapCache(page_map)) {
> -				free_page_and_swap_cache(page);
> +				free_page(page);
>  				return (atomic_read(&page_map->count) == 0);
>  			}
>  			add_to_swap_cache(page_map, entry);
> @@ -188,7 +188,7 @@
>  		 * asynchronously.  That's no problem, shrink_mmap() can
>  		 * correctly clean up the occassional unshared page
>  		 * which gets left behind in the swap cache. */
> -		free_page_and_swap_cache(page);
> +		free_page(page);
>  		return 1;	/* we slept: the process may not exist any more */
>  	}
>  
> @@ -202,7 +202,7 @@
>  		set_pte(page_table, __pte(entry));
>  		flush_tlb_page(vma, address);
>  		swap_duplicate(entry);
> -		free_page_and_swap_cache(page);
> +		free_page(page);
>  		return (atomic_read(&page_map->count) == 0);
>  	} 
>  	/* 
> @@ -218,7 +218,11 @@
>  	flush_cache_page(vma, address);
>  	pte_clear(page_table);
>  	flush_tlb_page(vma, address);
> +#if 0
>  	entry = page_unuse(page_map);
> +#else
> +	entry = (atomic_read(&page_map->count) == 1);
> +#endif
>  	__free_page(page_map);
>  	return entry;
>  }

I must admit that after some preliminary testing I can't believe how
GOOD these changes work!

Stephen, you've done a *really* good job.

I will still do some more testing, not to find bugs, but to enjoy
great performance. :)

Everybody, get pre-2.1.130-3 (which already includes above changes),
add #include <linux/interrupt.h> in kernel/itimer.c and enjoy the most
fair MM in Linux, EVER!

Stephen, thanks for such a good code!
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	   REALITY.SYS Corrupted: Re-boot universe? (Y/N/Q)
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
