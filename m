Date: Sun, 7 May 2000 12:30:15 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [DATAPOINT] pre7-6 will not swap
In-Reply-To: <3915C053.EE77396C@sgi.com>
Message-ID: <Pine.LNX.4.10.10005071227160.30202-100000@cesium.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: riel@nl.linux.org, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 7 May 2000, Rajagopal Ananthanarayanan wrote:
> 
> In the presense unreferenced pages in zones with free_pages > pages_high,
> should shrink_mmap ever fail? Current shrink_mmap will
> always skip over the pages of such zones. This in turn
> can lead to swapping.

I think shrink_mmap() should fail for that case: it tells the logic that
calls it that its time to stop calling shrink_mmap(), and go to vmscan
instead (so that next time we call shrink_mmap, we may in fact find some
pages to free).

If there really are tons of pages with free_pages > pages_high, then we
must have called shrink_mmap() for some other reason, so we're probably
interested in another zone altogether that isn't even a subset of the
"tons of memory" case (because if we had been interested in any class that
has the "lots of free memory" zone as a subset, then the logic in
__alloc_pages() would just have allocated it directly without worrying
about zone balancing at all).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
