Date: Fri, 12 May 2000 21:54:06 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005121200590.4959-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10005122149120.6188-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

yes, this appears to have done the trick (patch attached). A 15MB/sec
stream of pure read activity started filling up highmem first. There was
still a light spike of kswapd activity once highmem got filled up, but it
stabilized after a few seconds. Then the pagecache filled up the normal
zone just as fast as it filled up the highmem zone, and now it's in steady
state, with kswapd using up ~5% CPU time [fluctuating, sometimes as high
as 15%, sometimes zero]. (it's recycling LRU pages?) Cool!

	Ingo

--- linux/mm/vmscan.c.orig	Fri May 12 12:28:58 2000
+++ linux/mm/vmscan.c	Fri May 12 12:29:50 2000
@@ -543,13 +543,14 @@
 				something_to_do = 1;
 				do_try_to_free_pages(GFP_KSWAPD);
 				if (tsk->need_resched)
-					schedule();
+					goto sleep;
 			}
 			run_task_queue(&tq_disk);
 			pgdat = pgdat->node_next;
 		} while (pgdat);
 
 		if (!something_to_do) {
+sleep:
 			tsk->state = TASK_INTERRUPTIBLE;
 			interruptible_sleep_on(&kswapd_wait);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
