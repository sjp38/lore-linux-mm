Date: Tue, 9 Nov 2004 12:19:45 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-Id: <20041109121945.7f35d104.akpm@osdl.org>
In-Reply-To: <20041109164642.GE7632@logos.cnet>
References: <20041109164642.GE7632@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> 
> Andrew,
> 
> I was wrong last time I read balance_pgdat() when I thought kswapd
> couldnt sleep under page shortage. 
> 
> It can, because all_zones_ok is set to "1" inside the 
> "priority=DEF_PRIORITY; priority >= 0; priority--" loop.
> 
> So this patch sets "all_zones_ok" to zero even if all_unreclaimable 
> is set, avoiding it from sleeping when zones are under page short.
> 

Does this solve any observed problem?  What testing was done, and what were
the results??

> 
> --- linux-2.6.10-rc1-mm2/mm/vmscan.c.orig	2004-11-09 16:38:04.480873424 -0200
> +++ linux-2.6.10-rc1-mm2/mm/vmscan.c	2004-11-09 16:38:08.624243536 -0200
> @@ -1033,15 +1033,17 @@
>  				if (zone->present_pages == 0)
>  					continue;
>  
> -				if (zone->all_unreclaimable &&
> -						priority != DEF_PRIORITY)
> -					continue;
> -
>  				if (!zone_watermark_ok(zone, order,
>  						zone->pages_high, 0, 0, 0)) {
>  					end_zone = i;
> -					goto scan;
> +					all_zones_ok = 0;
>  				}
> +
> +				if (zone->all_unreclaimable &&
> +						priority != DEF_PRIORITY)
> +					continue;
> +
> +				goto scan;
>  			}
>  			goto out;
>  		} else {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
