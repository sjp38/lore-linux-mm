Date: Thu, 12 Apr 2001 15:25:00 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
In-Reply-To: <200104121659.f3CGxX714605@tuttle.kansas.net>
Message-ID: <Pine.LNX.4.21.0104121519270.18260-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Slats Grobnik <kannzas@excite.com>
Cc: linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Apr 2001, Slats Grobnik wrote:

	[snip special-purpose part]

> By running `free -s1' or `top' it's clear that once swap memory gets
> maxed out, *cache* memory size decreases until, at about 4M, mouse & 
> keyboard response becomes noticeably sluggish.  At cache=3M or less,
> all hope is lost.  But at this point, *free* RAM size may not be
> affected much.  And since CPU activity is down to a crawl, it may
> take a while to reach minimum (or some small arbitrary figure.)
> So I altered the `out_of_memory' function accordingly, and expect to
> never reboot again.  (Except for changing kernels, and power outage.

*nod*  We need to OOM-kill before we're dead in the water due to
thrashing.

> -	/*
> -	 * Niced processes are most likely less important, so double
> -	 * their badness points.
> -	 */
> -	if (p->nice > 0)
> -		points *= 2;
> +	/* Niced processes less important?  Distributed.net would disagree! */

Agreed. A while ago there was a discussion about this and we
agreed that we should remove this test (only, we never got
around to sending something to Linus ;)).


> -	/* Enough free memory?  Not OOM. */
> -	if (nr_free_pages() > freepages.min)
> -		return 0;
> +	/* Even if free memory stays big enough...  */
> +	/*  ...a cramped cache means thrashing, then keyboard lockout. */
>  
> -	if (nr_free_pages() + nr_inactive_clean_pages() > freepages.low)
> +	if ((atomic_read(&page_cache_size) << PAGE_SHIFT)  >  (3 << 20)-1 )
>  		return 0;

1) you DO need to check to see if the system still has enough
   free pages
2) the cache size may be better expressed as some percentage
   of system memory ... it's still not good, but the 3 MB you
   chose is probably completely wrong for 90% of the systems
   out there ;)

I believe Andrew Morton was also looking at making changes to the
out_of_memory() function, but only to make sure the OOM killer
isn't started to SOON. I guess we can work something out that will
both kill soon enough *and* not too soon  ;)

Any suggestions for making Slats' ideas more generic so they work
on every system ?

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
