Message-ID: <3911E03A.D33BB657@norran.net>
Date: Thu, 04 May 2000 22:40:26 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <Pine.LNX.4.10.10005040808490.1137-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@nl.linux.org>
List-ID: <linux-mm.kvack.org>

Oh,

This moves the need_resched test out of the inner loop.
Not good if you like low latencies (I like them).
(The do_try_to_free_pages can take quite some time...)

>                         if (tsk->need_resched)
>                                 schedule();

Please move it back into the inner loop!

/RogerL

Linus Torvalds wrote:
> 
> On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> >
> > I did some testing of this patch with dbench.
> > The kernel starts shooting processes down pretty quickly
> > ("VM: killing process XXX") on a 2 CPU 64MB system,
> > with nothing but dbench (8 clients). A concurrently
> > running vmstat shows very low free memory with some swapping,
> > and the buffer space remaining around 50MB.
> 
> Ok. The page locking patch should not change any swap behaviour at all, so
> this behaviour is likely to be due to the pageout changes by Rik.
> 
> (Oh, the page locking might cause another part of the vmscanning logic to
> temporarily ignore a page because it is locked, but that should be a very
> small second-order effect compared to the "big picture" changes in how
> much to page out).
> 
> Rik, I think the kswapd logic is wrong, and I suspect you made it
> worsewhen you added the while-loop. The problem looks like that while
> kswapd is working on one zone, it will entirely ignore any other zones. I
> think the logic should be more like
> 
>         for (;;) {
>                 int something_to_do = 0;
>                 pgdat = pgdat_list;
>                 while (pgdat) {
>                         for(i = 0; i < MAX_NR_ZONES; i++) {
>                                 zone = pgdat->node_zones+ i;
>                                 if (!zone->size || !zone->zone_wake_kswapd)
>                                         continue;
>                                 something_to_do = 1;
>                                 do_try_to_free_pages(GFP_KSWAPD, zone);
>                         }
>                         run_task_queue(&tq_disk);
>                         pgdat = pgdat->node_next;
>                 }
>                 if (something_to_do) {
>                         if (tsk->need_resched)
>                                 schedule();
>                         continue;
>                 }
>                 tsk->state = TASK_INTERRUPTIBLE;
>                 interruptible_sleep_on(&kswapd_wait);
>         }
> 
> See? This has two changes to the current logic:
>  - it is more "balanced" on the do_try_to_free_pages(), ie it calls it for
>    different zones instead of repeating one zone until no longer needed.
>  - it continues to do this until no zone needs balancing any more, unlike
>    the old one that could easily lose kswapd wakeup-requests and just do
>    one zone.
> 
> What do you think? I suspect that the added do-loop in pre7 just made the
> "lost wakeups" problem worse by concentrating on one zone for a longer
> while and thus more likely to lose wakeups for lower zones (because it
> already looked at those).
> 
> There might be other details like this lurking, but this looks like a good
> first try. Ananth, willing to give it a whirl?
> 
>                         Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
