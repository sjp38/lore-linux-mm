Date: Mon, 1 May 2000 22:03:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <200005020023.RAA31259@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0005012154440.7508-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
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

(leading to out of memory situations when it wasn't needed, or
to dozens or even hundreds of extra context switches / extra
swapin latency when we call balance_zones from alloc_pages, etc)

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
