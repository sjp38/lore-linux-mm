Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [RFT][PATCH] even out background aging
Date: Fri, 29 Jun 2001 16:37:29 -0400
References: <Pine.LNX.4.33.0106151211360.2262-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.33.0106151211360.2262-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Message-Id: <01062916372900.07483@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On June 15, 2001 11:17 am, Rik van Riel wrote:
> [Request For Testers:  please test this on your system...]

Like what this does except for one item.  When patched with this on
2.4.6-pre5 or pre6 I can trigger a repeatable hang doing a backup.
(The reiserfs fix for vm deadlocks is applied).  

I use tob to backup.  The hang occures when it is doing a 'find' to
get all the names to backup.  The stall does not stop the softdog
driver, which manages to reboot the system.

Ed Tomlinson

> the following patch makes use of the fact that refill_inactive()
> now calls swap_out() before calling refill_inactive_scan() and
> the fact that the inactive_dirty list is now reclaimed in a fair
> LRU order.
>
> Background scanning can now be replaced by a simple call to
> refill_inactive(), instead of the refill_inactive_scan(), which
> gave mapped pages an unfair advantage over unmapped ones.
>
> The special-casing of the amount to scan in refill_inactive_scan()
> is removed as well, there's absolutely no reason we'd need it with
> the current VM balance.
>
> regards,
>
> Rik
> --
>
>
> --- linux-2.4.6-pre3/mm/vmscan.c.orig	Thu Jun 14 12:28:03 2001
> +++ linux-2.4.6-pre3/mm/vmscan.c	Fri Jun 15 11:55:09 2001
> @@ -695,13 +695,6 @@
>  	int page_active = 0;
>  	int nr_deactivated = 0;
>
> -	/*
> -	 * When we are background aging, we try to increase the page aging
> -	 * information in the system.
> -	 */
> -	if (!target)
> -		maxscan = nr_active_pages >> 4;
> -
>  	/* Take the lock while messing with the list... */
>  	spin_lock(&pagemap_lru_lock);
>  	while (maxscan-- > 0 && (page_lru = active_list.prev) != &active_list) {
> @@ -978,7 +971,7 @@
>  			recalculate_vm_stats();
>
>  			/* Do background page aging. */
> -			refill_inactive_scan(DEF_PRIORITY, 0);
> +			refill_inactive(GFP_KSWAPD, 0);
>  		}
>
>  		run_task_queue(&tq_disk);
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
