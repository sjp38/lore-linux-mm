Date: Fri, 5 Jul 2002 11:25:44 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: vm lock contention reduction
In-Reply-To: <3D2540CE.89A1688E@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207051123160.8346-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2002, Andrew Morton wrote:
> Linus Torvalds wrote:

> > You probably want the occasional allocator able to jump the queue, but the
> > "big spenders" to be caught eventually. "Fairness" really doesn't mean
> > that "everybody should wait equally much", it really means "people should
> > wait roughly relative to how much as they 'spend' memory".
>
> Right.  And that implies heuristics to divine which tasks are
> heavy page allocators.  uh-oh.

This isn't too hard. In order to achieve this you:

1) wait for one kswapd loop when you get below a high water mark
2) allocate one page when kswapd wakes everybody up again
   (at this point we're NOT necessarily above the high water
   mark again...)

This means that once the system is under a lot of pressure
heavy allocators will be throttled a lot more than light
allocators and the system gets a chance to free things.

Of course, kswapd does everything (except get_request)
asynchronously so a kswapd loop should be relatively short.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
