Date: Mon, 1 May 2000 22:31:58 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <200005020113.SAA31341@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0005012229280.7508-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: roger.larsson@norran.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2000, David S. Miller wrote:
> From: Rik van Riel <riel@conectiva.com.br>
>    On Mon, 1 May 2000, David S. Miller wrote:
> 
>    > BTW, what loop are you trying to "continue;" out of here?
>    > 
>    > +			    do {
>    >  				if (tsk->need_resched)
>    >  					schedule();
>    >  				if ((!zone->size) || (!zone->zone_wake_kswapd))
>    >  					continue;
>    >  				do_try_to_free_pages(GFP_KSWAPD, zone);
>    > +			   } while (zone->free_pages < zone->pages_low &&
>    > +					   --count);
>    > 
>    > :-)  Just add a "next_zone:" label at the end of that code and
>    > change the continue; to a goto next_zone;
> 
>    I want kswapd to continue with freeing pages from this zone if
>    there aren't enough free pages in this zone. This is needed
>    because kswapd used to stop freeing pages even if we were below
>    pages_min...
> 
> Rik, zone_wake_kswapd implies this information, via what
> __free_pages_ok does to that flag.

Indeed, I should have moved the test for zone->zone_wake_kswapd to 
before the loop. But using zone->zone_wake_kswapd for the test isn't
really enough since that is only turned off if zone->free_pages 
reaches zone->pages_high, but we probably don't want to do agressive
swapout when we're already above zone->pages_low ...

(just background swapping that happens incidentally when we're
swapping stuff for other zones)

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
