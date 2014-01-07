Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E4C986B0036
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 22:01:35 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fa1so19517964pad.3
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 19:01:35 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id sz7si55309834pab.29.2014.01.06.19.01.32
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 19:01:34 -0800 (PST)
Date: Tue, 7 Jan 2014 12:01:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: swap, compress, discard: what's in the future?
Message-ID: <20140107030148.GA24188@bbox>
References: <CAA25o9Q921VnXvTo2OhXK5taif6MSF6LBtgPKve=kpgeW5XQ9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9Q921VnXvTo2OhXK5taif6MSF6LBtgPKve=kpgeW5XQ9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org

Hello Luigi,

On Mon, Jan 06, 2014 at 06:31:29PM -0800, Luigi Semenzato wrote:
> I would like to know (and I apologize if there is an obvious answer)
> if folks on this list have pointers to documents or discussions
> regarding the long-term evolution of the Linux memory manager.  I
> realize there is plenty of shorter-term stuff to worry about, but a
> long-term vision would be helpful---even more so if there is some
> agreement.
> 
> My super-simple view is that when memory reclaim is possible there is
> a cost attached to it, and the goal is to minimize the cost.  The cost
> for reclaiming a unit of memory of some kind is a function of various
> parameters: the CPU cycles, the I/O bandwidth, and the latency, to
> name the main components.  This function can change a lot depending on
> the load and in practice it may have to be grossly approximated, but
> the concept is valid IMO.
> 
> For instance, the cost of compressing and decompressing RAM is mainly
> CPU cycles.  A user program (a browser, for instance :) may be caching
> decompressed JPEGs into transcendent (discardable) memory, for quick
> display.  In this case, almost certainly the decompressed JPEGs should
> be discarded before memory is compressed, under the realistic
> assumption that one JPEG decompression is cheaper than one LZO
> compression/decompression.  But there may be situations in which a lot
> more work has gone into creating the application cache, and then it
> makes sense to compress/decompress it rather than discard it.  It may
> be hard for the kernel to figure out how expensive it is to recreate
> the application cache, so the application should tell it.

Agreed. It's very hard for kernel to figure it out so VM should depend
on user's hint. and thing you said is the exact example of volatile
range system call that I am suggesting.

http://lwn.net/Articles/578761/

> 
> Of course, for a cache the cost needs to be multiplied by the
> probability that the memory will be used again in the future.  A good
> part of the Linux VM is dedicated to estimating that probability, for
> some kinds of memory.  But I don't see simple hooks for describing
> various costs such as the one I mentioned, and I wonder if this
> paradigm makes sense in general, or if it is peculiar to Chrome OS.

Your statement makes sense to me but unfortunately, current VM doesn't
consider everything you mentioned.
It is just based on page access recency by approximate LRU logic +
some heuristic(ex, mapped page and VM_EXEC pages are more precious).
The reason it makes hard is just complexity/overhead of implementation.
If someone has nice idea to define parameters and implement with
small overhead, it would be very nice!


> 
> Thanks!
> ... and Happy New Year
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
