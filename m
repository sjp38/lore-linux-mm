Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA22788
	for <linux-mm@kvack.org>; Tue, 11 May 1999 14:47:12 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14136.31444.33068.416501@dukat.scot.redhat.com>
Date: Tue, 11 May 1999 19:45:40 +0100 (BST)
Subject: Re: [PATCH] dirty pages in memory & co.
In-Reply-To: <Pine.LNX.4.05.9905111334580.929-100000@laser.random>
References: <m1g154e7ou.fsf@flinx.ccr.net>
	<Pine.LNX.4.05.9905111334580.929-100000@laser.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 11 May 1999 13:38:48 +0200 (CEST), Andrea Arcangeli
<andrea@e-mind.com> said:

> But I am worried by page faults. The page fault that allow us to know
> where there is an uptodate swap-entry on disk just hurt performances more
> than not having such information (I did benchmarks).

It obviously depends on whether you are swap-bound or CPU-bound.  Have
you tried both?

One thing I definitely agree with is that it may sometimes be preferable
to drop the swap cache to avoid fragmentation.  If we have a new dirty
page requiring writing to swap, and its VA neighbours are already in the
swap cache, it makes sense to eliminate the swap cache and write all the
pages to the new location to keep them contiguous on disk.  

The real aim here is to allow us to keep dirty pages in the swap cache
too: this will allow us to keep good, unfragmented swap allocations by
persistently assigning a contiguous range of swap to a contiguous range
of process data pages, even if the process is only dirtying some of
those pages.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
