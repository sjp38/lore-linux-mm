Date: Thu, 13 Jan 2000 14:40:14 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <200001122111.NAA68159@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10001131430520.13454-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, andrea@suse.de, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jan 2000, Kanoj Sarcar wrote:

> --- mm/page_alloc.c	Tue Jan 11 11:00:31 2000
> +++ mm/page_alloc.c	Tue Jan 11 23:59:35 2000
> +		cumulative += size;
> +		mask = (cumulative >> 7);
> +		if (mask < 1) mask = 1;
> +		zone->pages_low = mask*2;
> +		zone->pages_high = mask*3;
>  		zone->low_on_memory = 0;

I think that busier machines probably have a larger need
for DMA memory than this code fragment will give us. I
have the gut feeling that we'll want to keep about 512kB
or more free in the lower 16MB of busy machines...

(if only because such a large amount of free pages in
such a small part of the address space will give us
higher-order free pages)

> --- mm/vmscan.c	Tue Jan 11 11:00:31 2000
> +++ mm/vmscan.c	Tue Jan 11 23:29:41 2000
> @@ -534,8 +534,11 @@
>  	int retval = 1;
>  
>  	wake_up_process(kswapd_process);
> -	if (gfp_mask & __GFP_WAIT)
> +	if (gfp_mask & __GFP_WAIT) {
> +		current->flags |= PF_MEMALLOC;
>  		retval = do_try_to_free_pages(gfp_mask, zone);
> +		current->flags &= ~PF_MEMALLOC;
> +	}
>  	return retval;
>  }

Please note that kswapd still exits when the total number
of free pages in the system is high enough. Balancing can
probably better be done in the background by kswapd than
by applications that happen to stumble across a nonbalanced
zone...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
