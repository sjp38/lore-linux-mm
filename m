Date: Fri, 21 Jan 2000 14:02:35 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] 2.2.15-pre3 kswapd fix
In-Reply-To: <Pine.LNX.4.10.10001210326330.27593-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001211354380.486-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Rik van Riel wrote:

>More than that. Min is supposed to be the absolute boundary
>below which nothing can allocate memory (except for ATOMIC
>allocations).

That's definitely not true. min is supposed to be the watermark that force
the task to block but if you succeed freeing some memory, then you go
uncoditionally ahaead also in the GFP_USER case if you succeed to free
some memory despite of the nr_free_pages level. GFP_KERNEL go ahead even
if it's not been possible to free some memory.

> It's not with the old code, that's broken.

The old code is been implemented in mid 2.1.x and it's still the same in
2.2.14.

>> How do you get a wakeup now? :) now it's pure too slow polling.
>
>I copied this from the 2.3 code in the expectation that
>schedule_timeout(HZ); is interruptible. If it's not, then
>we've just found a 2.3 bug :)

Nooo 2.3 has a pointer to the task struct so you wakeup the task directly
but that's very wrong (and I had not yet time to fix it in 2.3.x) because
you'll wakeup kswapd even when it's waiting for I/O completation so
causing not necessary scheduling and so on. It was buggy also in 2.2.13
and I fixed it in 2.2.14.

>> > 	wake_up_interruptible(&kswapd_wait);
>> >-	if (gfp_mask & __GFP_WAIT)
>> >+	if ((gfp_mask & __GFP_WAIT) && (nr_free_pages < (freepages.low - 4)))
>> 
>> Again treshing_mem heuristic broken...
>
>Please explain to me why this is broken? I've carefully
>explained why this makes sense and you haven't given
>any practical explanation on your point of view...

I given the explanation in my first comment about it.

You must _block_ the task until the watermark returns to _high_
again. This ensure that a trashing program will do all the work to free
memory and thus ensure the trashing program won't be able to trash the
machine because it will have to do all the hard work.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
