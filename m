Received: from mate.bln.innominate.de (cerberus.berlin.innominate.de [212.84.234.251])
	by hermes.mixx.net (Postfix) with ESMTP id BBA9AF80C
	for <linux-mm@kvack.org>; Fri, 29 Dec 2000 15:22:13 +0100 (CET)
Received: from innominate.de (gimli.bln.innominate.de [10.0.0.90])
	by mate.bln.innominate.de (Postfix) with ESMTP id 383B02CAA3
	for <linux-mm@kvack.org>; Fri, 29 Dec 2000 15:22:13 +0100 (CET)
Message-ID: <3A4C9D86.FCF5A8DB@innominate.de>
Date: Fri, 29 Dec 2000 15:19:50 +0100
From: Daniel Phillips <phillips@innominate.de>
MIME-Version: 1.0
Subject: Re: Interesting item came up while working on FreeBSD's pageout daemon
References: <Pine.LNX.4.21.0012211741410.1613-100000@duckman.distro.conectiva> <00122900094502.00966@gimli> <200012290624.eBT6O3s14135@apollo.backplane.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Dillon wrote:
> :Thanks for clearing that up, but it doesn't change the observation -
> :it still looks like he's keeping dirty pages 'on probation' twice as
> :long as before.  Having each page take an extra lap the inactive_dirty
> :list isn't exactly equivalent to just scanning the list more slowly,
> :but it's darn close.  Is there a fundamental difference?
> :
> :--
> :Daniel
> 
>     Well, scanning the list more slowly would still give dirty and clean
>     pages the same effective priority relative to each other before being
>     cleaned.  Giving the dirty pages an extra lap around the inactive
>     queue gives clean pages a significantly higher priority over dirty
>     pages in regards to choosing which page to launder next.
>     So there is a big difference there.

There's the second misunderstanding.  I assumed you had separate clean
vs dirty inactive lists.

>     The effect of this (and, more importantly, limiting the number of dirty
>     pages one is willing to launder in the first pageout pass) is rather
>     significant due to the big difference in cost in dealing with clean
>     pages verses dirty pages.
> 
>     'cleaning' a clean page means simply throwing it away, which costs maybe
>     a microsecond of cpu time and no I/O.  'cleaning' a dirty page requires
>     flushing it to its backing store prior to throwing it away, which costs
>     a significant bit of cpu and at least one write I/O.  One write I/O
>     may not seem like a lot, but if the disk is already loaded down and the
>     write I/O has to seek we are talking at least 5 milliseconds of disk
>     time eaten by the operation.  Multiply this by the number of dirty pages
>     being flushed and it can cost a huge and very noticeable portion of
>     your disk bandwidth, verses zip for throwing away a clean page.

To estimate the cost of paging io you have to think in terms of the
extra work you have to do because you don't have infinite memory.  In
other words, you would have had to write those dirty pages anyway - this
is an unavoidable cost.  You incur an avoidable cost when you reclaim a
page that will be needed again sooner than some other candidate.  If the
page was clean the cost is an extra read, if dirty it's a write plus a
read.  Alternatively, the dirty page might be written again soon - if
it's a partial page write the cost is an extra read and a write, if it's
a full page the cost is just a write.  So it costs at most twice as much
to guess wrong about a dirty vs clean page.  This difference is
significant, but it's not as big as the 1 usec vs 5 msec you suggesed.

If I'm right then making the dirty page go 3 times around the loop
should result in worse performance vs 2 times.

>     Due to the (relatively speaking) huge cost involved in laundering a dirty
>     page, the extra cpu time we eat giving the dirty pages a longer life on
>     the inactive queue in the hopes of avoiding the flush, or skipping them
>     entirely with a per-pass dirty page flushing limit, is well worth it.
> 
>     This is a classic algorithmic tradeoff... spend a little extra cpu to
>     choose the best pages to launder in order to save a whole lot of cpu
>     (and disk I/O) later on.
 
--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
