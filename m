Date: Mon, 1 May 2000 18:13:26 -0700
Message-Id: <200005020113.SAA31341@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.21.0005012154440.7508-100000@duckman.conectiva>
	(message from Rik van Riel on Mon, 1 May 2000 22:03:35 -0300 (BRST))
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
References: <Pine.LNX.4.21.0005012154440.7508-100000@duckman.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: roger.larsson@norran.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   On Mon, 1 May 2000, David S. Miller wrote:

   > BTW, what loop are you trying to "continue;" out of here?
   > 
   > +			    do {
   >  				if (tsk->need_resched)
   >  					schedule();
   >  				if ((!zone->size) || (!zone->zone_wake_kswapd))
   >  					continue;
   >  				do_try_to_free_pages(GFP_KSWAPD, zone);
   > +			   } while (zone->free_pages < zone->pages_low &&
   > +					   --count);
   > 
   > :-)  Just add a "next_zone:" label at the end of that code and
   > change the continue; to a goto next_zone;

   I want kswapd to continue with freeing pages from this zone if
   there aren't enough free pages in this zone. This is needed
   because kswapd used to stop freeing pages even if we were below
   pages_min...

Rik, zone_wake_kswapd implies this information, via what
__free_pages_ok does to that flag.

I see it like this:

	if "!zone->size || !zone->zone_wake_kswapd"

		then zone->free_pages >= zone->pages_high by
		implication

Therefore when the continue happens, the loop will currently just
execute:

	if (!zone->size || !zone->zone_wake_kswapd)
		continue;
    ...
	} while (zone->free_pages < zone->pages_low &&

and the while condition is false and therefore will branch out of the
loop.  __free_pages_ok _always_ clears the zone_wake_kswapd flag when
zone->free_pages goes beyond zone->pages_high.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
