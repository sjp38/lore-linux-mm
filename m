Subject: Re: [PATCH] Re: kswapd
References: <200003270121.RAA88890@google.engr.sgi.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 27 Mar 2000 00:02:31 -0600
In-Reply-To: kanoj@google.engr.sgi.com's message of "Sun, 26 Mar 2000 17:21:11 -0800 (PST)"
Message-ID: <m1aejlvtl4.fsf@flinx.hidden>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:

> What is the problem that your patch is fixing? 

> 
>                 do {
>                         /* kswapd is critical to provide GFP_ATOMIC
>                            allocations (not GFP_HIGHMEM ones). */
>                         if (nr_free_pages() - nr_free_highpages() >=
> freepages.high)
> 
>                                 break;
>                         if (!do_try_to_free_pages(GFP_KSWAPD, 0))
>                                 break;
>                         run_task_queue(&tq_disk);
>                 } while (!tsk->need_resched);
>                 tsk->state = TASK_INTERRUPTIBLE;
>                 interruptible_sleep_on(&kswapd_wait);
>         }

Hmm.  This loop runs until either 
(a) it has free pages or
(b) it has used up it's time slice.

> > --- linux-2.3.99-pre3/mm/vmscan.c.orig	Sat Mar 25 12:57:20 2000
> > +++ linux-2.3.99-pre3/mm/vmscan.c	Sun Mar 26 21:37:19 2000
> > @@ -499,19 +499,19 @@
> >  		 * the processes needing more memory will wake us
> >  		 * up on a more timely basis.
> >  		 */
> > -		do {
> > -			pgdat = pgdat_list;
> > -			while (pgdat) {
> > -				for (i = 0; i < MAX_NR_ZONES; i++) {
> > -					zone = pgdat->node_zones + i;
> > - if ((!zone->size) || (!zone->zone_wake_kswapd))
> 
> > -						continue;
> > -					do_try_to_free_pages(GFP_KSWAPD, zone);
> > -				}
> > -				pgdat = pgdat->node_next;
> > +		pgdat = pgdat_list;
> > +		while (pgdat) {
> > +			for (i = 0; i < MAX_NR_ZONES; i++) {
> > +				zone = pgdat->node_zones + i;
> > +				if (tsk->need_resched)
> > +					schedule();
> > +				if ((!zone->size) || (!zone->zone_wake_kswapd))
> > +					continue;
> > +				do_try_to_free_pages(GFP_KSWAPD, zone);
> >  			}
> > -			run_task_queue(&tq_disk);
> > -		} while (!tsk->need_resched);
> > +			pgdat = pgdat->node_next;
> > +		}
> > +		run_task_queue(&tq_disk);
> >  		tsk->state = TASK_INTERRUPTIBLE;
> >  		interruptible_sleep_on(&kswapd_wait);
> >  	}

The removed loop runs until a reschedule is needed.
Having enough memory isn't sufficient to get out of the loop.
So it can spin in run_task_queue(&tq_disk);

The added loop runs only while (pgdat).
Running out of time slice will put it to sleep now.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
