Message-ID: <39139EA3.89BBA5E5@ucla.edu>
Date: Fri, 05 May 2000 21:25:07 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: [DATAPOINT] pre7-6 will not swap
References: <8evk0f$7jote$1@fido.engr.sgi.com> <39145287.D8F1F0C1@sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> --------------- mm/vmscan.c around line 113 --------------
>         /*
>          * Don't do any of the expensive stuff if
>          * we're not really interested in this zone.
>          */
>         if (!page->zone->zone_wake_kswapd)
>                 goto out_unlock;
> ----------------------------------------------------------
> 
> Benjamin, can you comment this line out and see if it improves things?

	OK, reverted this.  I also reverted to "count = nr_threads / (priority
+ 1)", I hope that doesn't cause a problem.
	With the above patch reverted, the system swaps amazingly well, as
opposed to almost never.  It swaps out tasks in the correct order.  It
is also a bit more aggressive than pre7-4, swapping out unused daemons
even when there is lots of cache that presumably could be freed (e.g.
BEFORE I run netscape).  But this seems to be the right decision, given
that that stuff isn't swapped back in later.
	After running lots of processes, I can also say that this kernel does
not have a permanent cache size of 30Mb/64Mb.  It actually decreases
eventually instead of swapping out foreground programs like before.


	Does this mean that the zone_wake_kswapd essentially has the wrong
value, so that we don't even balance the zone for which we were called?

-benRI
UP PPro, 64MB RAM, IDE
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
