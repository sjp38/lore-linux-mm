Date: Sat, 4 Aug 2001 21:02:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] Accelerate dbench
In-Reply-To: <01080502045901.00315@starship>
Message-ID: <Pine.LNX.4.33L.0108042101341.2526-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Aug 2001, Daniel Phillips wrote:

> --- ../2.4.7.clean/mm/filemap.c	Sat Aug  4 14:27:16 2001
> +++ ./mm/filemap.c	Sat Aug  4 14:32:51 2001

> -	/* Mark the page referenced, kswapd will find it later. */
>  	SetPageReferenced(page);
> -
> +	if (!PageActive(page))
> +		activate_page(page);

I think this is wrong.

By doing this the page will end up at the far end
of the active list with the referenced bit already
set.

This doesn't allow us to distinguish between pages
which get accessed again after we put them on the
active list and pages which aren't.

Also, it effectively gives a double boost for this
one access...

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
