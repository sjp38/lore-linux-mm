Date: Fri, 12 May 2000 19:48:45 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005122149120.6188-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0005121944580.28943-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2000, Ingo Molnar wrote:

> --- linux/mm/vmscan.c.orig	Fri May 12 12:28:58 2000
> +++ linux/mm/vmscan.c	Fri May 12 12:29:50 2000
> @@ -543,13 +543,14 @@
>  				something_to_do = 1;
>  				do_try_to_free_pages(GFP_KSWAPD);
>  				if (tsk->need_resched)
> -					schedule();
> +					goto sleep;
>  			}
>  			run_task_queue(&tq_disk);
>  			pgdat = pgdat->node_next;
>  		} while (pgdat);
>  
>  		if (!something_to_do) {
> +sleep:
>  			tsk->state = TASK_INTERRUPTIBLE;
>  			interruptible_sleep_on(&kswapd_wait);
>  		}

This is wrong. It will make it much much easier for processes to
get killed (as demonstrated by quintela's VM test suite).

The correct fix probably is to have the _same_ watermark for
something_to_do *and* the "easy allocation" in __alloc_pages.

(very much untested patch versus pre7-9 below)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- vmscan.c.orig	Thu May 11 12:13:08 2000
+++ vmscan.c	Fri May 12 19:46:49 2000
@@ -542,8 +542,9 @@
 				zone_t *zone = pgdat->node_zones+ i;
 				if (!zone->size || !zone->zone_wake_kswapd)
 					continue;
-				something_to_do = 1;
 				do_try_to_free_pages(GFP_KSWAPD);
+				if (zone->free_pages < zone->pages_low)
+					something_to_do = 1;
 				if (tsk->need_resched)
 					schedule();
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
