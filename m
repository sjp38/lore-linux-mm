Message-ID: <3978B6DB.A0CCC681@norran.net>
Date: Fri, 21 Jul 2000 22:47:23 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH] test5-1 vmfix-3.0
References: <3976205E.4C604102@norran.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi again,

Reread what I had written.
One documentation error.

Roger Larsson wrote:
> 
> Hi,
> 
> Another attempt.
> 
> With this patch I get noticeable improvements in streaming write +16%!
> (streaming write throughput is close to streaming read :-)
> 
> dbench results are mixed - slightly worse than plain test5-1...
> It now survives mmap002, as opposed to vmfix-2.x :-)  there were
> bugs of cause.
> 
> * Basic idea in this patch is to keep free pages of zones in the
>   range [pages_high ... pages_low].

This part:
>                                     Kswapd will only run until
>   one zone gets pages_high. In this situation pages from all zones
>   are free able.

Should read:

Kswapd will start when all zones have zone_wake_kswapd
(free_pages < pages_low). In this situation pages from all zones are
freeable. Kswapd will run until one zone drops zone_wake_kswapd
(free_pages > pages_high).


> * In addition kswapd will run if any zone has less than pages_low.
> 
> * Actually implemented by using three values in zone_wake_kswapd
>   0 = zone initially above pages_high, allocs allowed until zone
>       gets < pages_low
>   1 = zone < pages_low
>  -1 = additional alloc done after zone become < pages_low
>  Most of the time there will only be one zone to with
>  zone_wake_kswapd zero. This zone will get the allocs until it
>  also gets < pages_low, then kswapd starts and runs until any
>  zone gets > pages_high - it will probably be another zone. Now
>  that one gets the allocs, ...
> 
> * There are some additional stuff that needs cleaning / further
>   investigations.
> 
> /RogerL
> 
> --
> Home page:
>   http://www.norran.net/nra02596/
> 
>   ------------------------------------------------------------------------
>                                    Name: patch-2.4.0-test5-1-vmfix.30
>    patch-2.4.0-test5-1-vmfix.30    Type: Plain Text (text/plain)
>                                Encoding: 7bit

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
