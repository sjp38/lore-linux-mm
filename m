Date: Wed, 14 Jun 2000 03:18:41 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006132146370.2954-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006140306110.12042-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jun 2000, Rik van Riel wrote:

>> It have to do with the classzone idea, because you shouldn't
>> even try to repeat the loop because you should notice that the
>> ZONE_NORMAL _classzone_ is not under the watermark because you
>> succeeded freeing the cache from the ZONE_DMA.
>
>You're playing with words here. If the cache was allocated before
>the mlock()ed memory, classzone would loop forever on trying to
>free memory from the DMA zone. There is no fundamental difference
>in the manifestation of the bug on either classzone or the normal
>VM.

There's a _lot_ of difference: in your scenario the dma zone is in empty
and the next allocation GFP_DMA will fail. So it's right and necessary to
loop in kswapd because we are really low on memory on such zone (the dma
zone)!

In the scenario that I raised previously where the stock kernel loops
forever (so first mlocked in normal zone and then cache in dma zone)  the
recycling will _succeed_ and there's no reason to keep looping in kswapd
trying to free the normal zone because the next allocation will succeed 
without any problem. Do you see the difference?

>and we can support all corner cases of usage well without it. In
>fact, as I demonstrated above, even your own contorted example will
>hang classzone if I only switch the order in which the allocations
>happen...

It won't hang, but kswapd will eat CPU and that's right in your case. The
difference that you can't see is that in the second scenario where the
classzone would spend CPU in kswapd the CPU is spent for a purpose that
have a sense. In the first scenario where classzone wouldn't any spend
CPU, the CPU in kswapd would infact be _wasted_.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
