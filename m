Date: Wed, 14 Jun 2000 02:21:43 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <ytthfax87yh.fsf@serpe.mitica>
Message-ID: <Pine.LNX.4.21.0006140213020.9129-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 14 Jun 2000, Juan J. Quintela wrote:

>I think that if you have a program that mlocked 95% of your normal
>memory you have two options:
>       - tweak the values of freepages.{min,low,high}
>       - buy more memory

You don't need to buy more memory: you have the memory and it's just been
recycled in the previous pass of the loop of kswapd. Why the heck should I
buy more memory because kswapd doesn't notice it should stop looping
and that enough memory is _just_ been released? :)

>What is the difference with the case where we mlocked *all* memory.

The only difference is that in such case there's not memory, but in the
scenario I described there is free memory and the VM is stpuid and it's
not using it.

>DMA zone and the NORMAL zone.  If we have the 95% of the DMA zone and
>the 95% of the NORMAL zone mlocked, we are really in problems....

Only 95% of the normal zone is mlocked and a sane VM must continue to work
like a charm because it can shrink all cache it wants from the first
15mbyte that are all freeable and in cache.

>as I told before, if you want to have 95% of your memory mlocked, you
>should tweak the values of freepages.*

Ok so set freepages.{min,low,high} to zero, then oracle exits and then all
the normal zone is allocated in cache because you're reading emails, and
then such cache is not shrunk anymore because you set freepages.high to
zero. Setting one of the others watermark to zero will lead to similar
side effects.

>then compare the design.  I conceptually preffer the zones desing, but
>I can be proved wrong.

I proved it to be wrong.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
