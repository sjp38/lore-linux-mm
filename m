Message-ID: <39178682.9AA1AB59@sgi.com>
Date: Mon, 08 May 2000 20:31:14 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: [DATAPOINT] pre7-6 will not swap
References: <Pine.LNX.4.10.10005081927200.839-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Quintela Carreira Juan J." <quintela@vexeta.dc.fi.udc.es>, Andrea Arcangeli <andrea@suse.de>, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
	[ ... ]
> 
> The "don't page out pages from zones that don't need it" test is a good
> test, but it turns out that it triggers a rather serious problem: the way
> the buffer cache dirty page handling is done is by having shrink_mmap() do
> a "try_to_free_buffers()" on the pages it encounters that have
> "page->buffer" set.
> 
> And doing that is quite important, because without that logic the buffers
> don't get written to disk in a timely manner, nor do already-written
> buffers get refiled to their proper lists. So you end up being "out of
> memory" - not because the machine is really out of memory, but because
> those buffers have a tendency to stick around if they aren't constantly
> looked after by "try_to_free_buffers()".
> 
> So the real fix ended up being to re-order the tests in shrink_mmap() a
> bit, so that try_to_free_buffers() is called even for pages that are on
> a good zone that doesn't need any real balancing..

Not sure entirely what effect this has, except for freeing underlying
buffer_head's. The page itself is still skipped. Anyway, brief examination
shows that you've changed several things here (in 7-7), so I'll have to go
at it some more time to get a full picture.

> 
> [ time passes ]
> 
> pre7-7 is there now.
> 
>                 Linus

Unfortunately my dbench test really runs bad with pre 7-7.
Quantitively, the amount of memory in "cache" of vmstat
is higher than before. write()'s start failing. 

More later,

-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
