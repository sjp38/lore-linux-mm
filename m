Date: Thu, 4 May 2000 12:57:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <Pine.LNX.4.10.10005040808490.1137-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005041253310.23740-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Linus Torvalds wrote:

> 	for (;;) {
> 		int something_to_do = 0;
> 		pgdat = pgdat_list;
> 		while (pgdat) {
> 			for(i = 0; i < MAX_NR_ZONES; i++) {
> 				zone = pgdat->node_zones+ i;
> 				if (!zone->size || !zone->zone_wake_kswapd)
> 					continue;
> 				something_to_do = 1;
> 				do_try_to_free_pages(GFP_KSWAPD, zone);
> 			}
> 			run_task_queue(&tq_disk);
> 			pgdat = pgdat->node_next;
> 		}
> 		if (something_to_do) {
> 			if (tsk->need_resched)
> 				schedule();
> 			continue;
> 		}
> 		tsk->state = TASK_INTERRUPTIBLE;
> 		interruptible_sleep_on(&kswapd_wait);
> 	}
> 
> See? This has two changes to the current logic:
>  - it is more "balanced" on the do_try_to_free_pages(), ie it calls it for
>    different zones instead of repeating one zone until no longer needed.
>  - it continues to do this until no zone needs balancing any more, unlike
>    the old one that could easily lose kswapd wakeup-requests and just do
>    one zone.
> 
> What do you think?

Indeed, this probably better ...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
