Message-ID: <3D250A47.DEF108DA@zip.com.au>
Date: Thu, 04 Jul 2002 19:53:59 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vm lock contention reduction
References: <3D2501FA.4B14EB14@zip.com.au> <Pine.LNX.4.44L.0207042315560.6047-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Thu, 4 Jul 2002, Andrew Morton wrote:
> 
> > Of course, that change means that we wouldn't be able to throttle
> > page allocators against IO any more, and we'd have to do something
> > smarter.  What a shame ;)
> 
> We want something smarter anyway.  It just doesn't make
> sense to throttle on one page in one memory zone while
> the pages in another zone could have already become
> freeable by now.
> 

Or pages from the same zone, indeed.

I think what we're saying here is: during writeback, park the
pages somewhere out of the way.  Page allocators go to sleep
on some waitqueue somewhere.  Disk completion interrupts put
pages back onto the LRU and wake up waiting page allocators.

That's all fairly straightforward, but one remaining problem
is: who does the writeback?  We can get large amounts of 
page allocation latency due to get_request_wait(), not just
wait_on_page().

Generally, the pdflush pool should be sufficient for this but
with many spindles it is possible that the kernel will run out
of pdflush resources.

So we may still need to make page allocating processes start I/O
if wakeup_bdflush() fails to find a thread.   If so, then the
implementation should prefer to make processes which are dirtying
memory start the IO.

Or provide a non-blocking try_to_submit_bio() for pdflush.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
