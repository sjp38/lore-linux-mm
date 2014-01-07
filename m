Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5166B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:31:31 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i7so3782079yha.11
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:31:30 -0800 (PST)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id m9si18215644yha.198.2014.01.06.18.31.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 18:31:30 -0800 (PST)
Received: by mail-ig0-f169.google.com with SMTP id hk11so8989136igb.0
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:31:29 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 6 Jan 2014 18:31:29 -0800
Message-ID: <CAA25o9Q921VnXvTo2OhXK5taif6MSF6LBtgPKve=kpgeW5XQ9Q@mail.gmail.com>
Subject: swap, compress, discard: what's in the future?
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I would like to know (and I apologize if there is an obvious answer)
if folks on this list have pointers to documents or discussions
regarding the long-term evolution of the Linux memory manager.  I
realize there is plenty of shorter-term stuff to worry about, but a
long-term vision would be helpful---even more so if there is some
agreement.

My super-simple view is that when memory reclaim is possible there is
a cost attached to it, and the goal is to minimize the cost.  The cost
for reclaiming a unit of memory of some kind is a function of various
parameters: the CPU cycles, the I/O bandwidth, and the latency, to
name the main components.  This function can change a lot depending on
the load and in practice it may have to be grossly approximated, but
the concept is valid IMO.

For instance, the cost of compressing and decompressing RAM is mainly
CPU cycles.  A user program (a browser, for instance :) may be caching
decompressed JPEGs into transcendent (discardable) memory, for quick
display.  In this case, almost certainly the decompressed JPEGs should
be discarded before memory is compressed, under the realistic
assumption that one JPEG decompression is cheaper than one LZO
compression/decompression.  But there may be situations in which a lot
more work has gone into creating the application cache, and then it
makes sense to compress/decompress it rather than discard it.  It may
be hard for the kernel to figure out how expensive it is to recreate
the application cache, so the application should tell it.

Of course, for a cache the cost needs to be multiplied by the
probability that the memory will be used again in the future.  A good
part of the Linux VM is dedicated to estimating that probability, for
some kinds of memory.  But I don't see simple hooks for describing
various costs such as the one I mentioned, and I wonder if this
paradigm makes sense in general, or if it is peculiar to Chrome OS.

Thanks!
... and Happy New Year

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
