From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003270121.RAA88890@google.engr.sgi.com>
Subject: Re: [PATCH] Re: kswapd
Date: Sun, 26 Mar 2000 17:21:11 -0800 (PST)
In-Reply-To: <Pine.LNX.4.21.0003262143500.1104-100000@duckman.conectiva> from "Rik van Riel" at Mar 26, 2000 09:59:23 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> On Sun, 26 Mar 2000, Russell King wrote:
> 
> > I think I've solved (very dirtily) my kswapd problem
> 
> Your patch is the correct one. I've added an extra reschedule
> point and cleaned up the code a little bit. I wonder who sent
> the brown-paper-bag patch with the superfluous while loop to
> Linus ...        (please raise your hand and/or buy rmk a beer)

That would be me ...

What is the problem that your patch is fixing? Other than the 
while loop cosmetic changes, the only thing I see is to do 
with rescheduling (ie, do not invoke do_try_to_free_pages or
run_task_queue() if need_resched is set). Note that before this 
patch went in, as in 2.3.43 for example, the loop used to be:

                do {
                        /* kswapd is critical to provide GFP_ATOMIC
                           allocations (not GFP_HIGHMEM ones). */
                        if (nr_free_pages() - nr_free_highpages() >= freepages.high)
                                break;
                        if (!do_try_to_free_pages(GFP_KSWAPD, 0))
                                break;
                        run_task_queue(&tq_disk);
                } while (!tsk->need_resched);
                tsk->state = TASK_INTERRUPTIBLE;
                interruptible_sleep_on(&kswapd_wait);
        }

Which is the behavior I _tried_ to preserve. Oh, btw, I am not convinced
that you should do a run_task_queue after _all_ pgdats have been scanned,
rather than after each one.

Kanoj

> 
> Linus, could you please apply this patch ASAP? :)
> 
> regards,
> 
> Rik  (PS. I'm still planning to implement the VM changes I posted
> to linux-mm earlier today, kswapd could be better and more efficient)
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/		http://www.surriel.com/
> 
> 
> 
> --- linux-2.3.99-pre3/mm/vmscan.c.orig	Sat Mar 25 12:57:20 2000
> +++ linux-2.3.99-pre3/mm/vmscan.c	Sun Mar 26 21:37:19 2000
> @@ -499,19 +499,19 @@
>  		 * the processes needing more memory will wake us
>  		 * up on a more timely basis.
>  		 */
> -		do {
> -			pgdat = pgdat_list;
> -			while (pgdat) {
> -				for (i = 0; i < MAX_NR_ZONES; i++) {
> -					zone = pgdat->node_zones + i;
> -					if ((!zone->size) || (!zone->zone_wake_kswapd))
> -						continue;
> -					do_try_to_free_pages(GFP_KSWAPD, zone);
> -				}
> -				pgdat = pgdat->node_next;
> +		pgdat = pgdat_list;
> +		while (pgdat) {
> +			for (i = 0; i < MAX_NR_ZONES; i++) {
> +				zone = pgdat->node_zones + i;
> +				if (tsk->need_resched)
> +					schedule();
> +				if ((!zone->size) || (!zone->zone_wake_kswapd))
> +					continue;
> +				do_try_to_free_pages(GFP_KSWAPD, zone);
>  			}
> -			run_task_queue(&tq_disk);
> -		} while (!tsk->need_resched);
> +			pgdat = pgdat->node_next;
> +		}
> +		run_task_queue(&tq_disk);
>  		tsk->state = TASK_INTERRUPTIBLE;
>  		interruptible_sleep_on(&kswapd_wait);
>  	}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
