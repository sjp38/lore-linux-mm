Date: Thu, 28 Dec 2000 22:24:03 -0800 (PST)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200012290624.eBT6O3s14135@apollo.backplane.com>
Subject: Re: Interesting item came up while working on FreeBSD's pageout daemon
References: <Pine.LNX.4.21.0012211741410.1613-100000@duckman.distro.conectiva> <00122900094502.00966@gimli>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@innominate.de>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

:Thanks for clearing that up, but it doesn't change the observation -
:it still looks like he's keeping dirty pages 'on probation' twice as
:long as before.  Having each page take an extra lap the inactive_dirty
:list isn't exactly equivalent to just scanning the list more slowly,
:but it's darn close.  Is there a fundamental difference?
:
:-- 
:Daniel

    Well, scanning the list more slowly would still give dirty and clean
    pages the same effective priority relative to each other before being
    cleaned.  Giving the dirty pages an extra lap around the inactive
    queue gives clean pages a significantly higher priority over dirty
    pages in regards to choosing which page to launder next.
    So there is a big difference there.

    The effect of this (and, more importantly, limiting the number of dirty
    pages one is willing to launder in the first pageout pass) is rather
    significant due to the big difference in cost in dealing with clean
    pages verses dirty pages.

    'cleaning' a clean page means simply throwing it away, which costs maybe 
    a microsecond of cpu time and no I/O.  'cleaning' a dirty page requires
    flushing it to its backing store prior to throwing it away, which costs 
    a significant bit of cpu and at least one write I/O.  One write I/O
    may not seem like a lot, but if the disk is already loaded down and the
    write I/O has to seek we are talking at least 5 milliseconds of disk
    time eaten by the operation.  Multiply this by the number of dirty pages
    being flushed and it can cost a huge and very noticeable portion of
    your disk bandwidth, verses zip for throwing away a clean page.

    Due to the (relatively speaking) huge cost involved in laundering a dirty
    page, the extra cpu time we eat giving the dirty pages a longer life on
    the inactive queue in the hopes of avoiding the flush, or skipping them 
    entirely with a per-pass dirty page flushing limit, is well worth it.  

    This is a classic algorithmic tradeoff... spend a little extra cpu to
    choose the best pages to launder in order to save a whole lot of cpu
    (and disk I/O) later on.

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
