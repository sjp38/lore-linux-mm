Message-ID: <39145287.D8F1F0C1@sgi.com>
Date: Sat, 06 May 2000 10:12:39 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: [DATAPOINT] pre7-6 will not swap
References: <8evk0f$7jote$1@fido.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>, torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin Redelings I wrote:
> 
> Hi,
>         I just compiled pre7-6.  It seems more useable than pre7-5.  However,
> it basically does not swap.  The first time there is any memory
> pressure, it swaps 32 pages (128k), and it never swaps again.
>         In similar circumstances, pre7-4 has gotten up to 30Mb swapped.  There
> are many unused daemons running in my 64Mb RAM.
> 
>         I also reverted to
>   count = nr_threads / (priority +1)
>         though I didn't check carefully what this did.  Anyway, it doesn't
> seem to make a difference.
> 


Yes, your observation is a good summarization of 7-6 behaviour.
I'm also not seeing good results.  The writes from dbench
start failing; i guess the grab_page_cache in generic_file_write
is returning ENOMEM.

Again, as you say, the system doesn't want to swap after an intial
flurry of activity.

Linus has taken in the fix to "old" vs. "young" in shrink_mmap,
and taken out the aggressive counter change (also in shrink_mmap).
But apparently another change in try_to_swap_out is causing problems.
I haven't an analytical evaluation, but empericically, if I remove this
in try_to_swap_out (mm/vmscan.c), dbench runs ok.

--------------- mm/vmscan.c around line 113 --------------
        /*
         * Don't do any of the expensive stuff if
         * we're not really interested in this zone.
	 */
        if (!page->zone->zone_wake_kswapd)
                goto out_unlock;
----------------------------------------------------------

Benjamin, can you comment this line out and see if it improves things?

Linus, one thing crossed my mind. With the above change swap_out()
will "count" as having tried this process, although the zone may
never need balancing. Aren't the initial system threads at the
beginning of the task_list? If so, do you think their zones may
never balancing?  ... and hence swap_out in essence gives up early?





--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
