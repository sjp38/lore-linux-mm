Message-ID: <391777D4.86460218@sgi.com>
Date: Mon, 08 May 2000 19:28:36 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: [DATAPOINT] pre7-6 will not swap
References: <Pine.LNX.4.10.10005061225460.1470-100000@penguin.transmeta.com> <ytt66sov6a9.fsf@vexeta.dc.fi.udc.es>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Quintela Carreira Juan J." <quintela@vexeta.dc.fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Quintela Carreira Juan J." wrote:
> 
> >>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:
> 
> linus> in vmscan.c, and that seems to be quite well-behaved too (but if somebody
> linus> has the energy to test the two different versions, I'd absolutely love to
> linus> hear results..)
> 
> Hi Linus,
>    I have tested two versions of the patch (against vanilla
> pre7-6), the first was to remove the test altogether (I think this is
> from Rajagopal):
> 
> --- pre7-6/mm/vmscan.c  Fri May  5 23:58:56 2000
> +++ testing/mm/vmscan.c Mon May  8 23:30:52 2000
> @@ -114,8 +114,9 @@
>          * Don't do any of the expensive stuff if
>          * we're not really interested in this zone.
>          */
> -       if (!page->zone->zone_wake_kswapd)
> +/*     if (!page->zone->zone_wake_kswapd)
>                 goto out_unlock;
> +*/
> 

I'm having the same experience too. The one thing
that makes stuff better is not to look at the zone at all
in try_to_swap_out (as Juan points out above).

I'm trying to also see if we can do better in shrink_mmap().
Although my gprof statistics say that we can end-up spending
91% of the time skipping pages, I'm not able to comeup with
anything simple to make shrink_mmap behave better ... except
one change which makes swapping a lot less and shrink_mmap
a lot more agressive: don't skip pages based on zone's
high water mark if we are trying hard to free pages (my heuristic
was to stop skipping pages if priority in shrink_mmap was 3; YMMV).
I'm not entirely convinced that this is the right thing to do.

In all, I do think that try_to_swap_out shouldn't skip pages
based on zones. We have now evidence from 3 different "workloads"
in this direction --- my own dbench test, Juan's test above &
Benjamin's "gaming" workload.


--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
