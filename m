Date: Wed, 31 Jul 2002 10:01:49 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: swapout bandwidth
In-Reply-To: <3D479C8D.1DAB44D1@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207310959300.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2002, Andrew Morton wrote:

> Seems poor.  On mem=512M, with 30 megs/sec of swap
> bandwidth, a
>
> 	memset(malloc(800megs))
>
> takes 21 seconds, and 16 on 2.5.26.
>
> There are big latencies during this too (vmstat freezes for
> many seconds).  But I seem to have fixed that in the
> pagemap_lru_lock patches.  Not sure how though ;)

I have an explanation for this fenomenon.

Without -rmap we can only swap out a very limited number of
the inactive pages and will wait on a few MB to be swapped
out each time.

With -rmap we can swap out ALL of the inactive pages and
we'll end up waiting on 180 MB of dirty pages to be flushed
to disk before using the first page we submitted for swapout
IO for the program...

It is all about the latency at which we can reclaim the
pages we submitted for IO and consequently the latency at
which the userspace program can continue.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
