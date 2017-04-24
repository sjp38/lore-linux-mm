Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5A6D6B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 02:40:47 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id c67so60068748itg.23
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 23:40:47 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id g26si17786356plj.197.2017.04.23.23.40.46
        for <linux-mm@kvack.org>;
        Sun, 23 Apr 2017 23:40:46 -0700 (PDT)
Date: Mon, 24 Apr 2017 15:40:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: swapping file pages
Message-ID: <20170424064043.GB11287@bbox>
References: <CAA25o9SP_Axuhvrr-YNYdfj=NHjX1KaDrE-EOmw1gHYS2PpZCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9SP_Axuhvrr-YNYdfj=NHjX1KaDrE-EOmw1gHYS2PpZCw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>, Johannes Weiner <hannes@cmpxchg.org>, vinmenon@codeaurora.org

Hello Luigi,

On Fri, Apr 21, 2017 at 11:26:45AM -0700, Luigi Semenzato wrote:
> On an SSD used by a typical chromebook (i.e. the one on my desk right
> now), it takes about 300us to read a random 4k page, but it takes less
> than 10us to lzo-decompress a page from the zram device.

IMO, it should be solved by VM itself rather than adding another layer
I mentioned below. IOW, If VM found file-backed page's reclaim/refaut
cost is higher than anonymous, VM should tip toward anonymous LRU.
I guess upcoming patches from Johannes's work would be key for the
issue.

> 
> Code compresses reasonably well (down to almost 50% for x86_64,
> although only 66% for ARM32), so I may be better off swapping file
> pages to zram, rather than reading them back from the SSD.  Before I
> even get started trying to do this, can anybody tell me if this is a
> stupid idea?  Or possibly a good idea, but totally impractical from an
> implementation perspective?

Although I believe it should be solved by VM itself in the long run,
I think cleancache might help you at this moment.

Please look at cleancache. It's hook layer of page cache so you can
compress pages dropped from page cache if FS supports cleancache_ops.
zcache was one of implementation for that. If the hit ratio is high,
it would be reasonable.

https://lwn.net/Articles/397574/

One of the problem at that time was cache miss ratio was too high
for stream-write workload because it have kept used-once pages
in the memory. It was pointelss.

Dan suggested PG_activated bit to detect pages promoted to active
LRU list for the life time and store only those pages in the
backend(ie, allocator) but he retired in the middle of the work.
Johannes's patch introduced PG_workingset which is same with
PG_activiated Dan suggested so maybe we can use the flag to avoid
overhead.

Another idea to use cleacache/frontswap although it didn't provide
cleancache backend at that time was GCMA. GCMA's main goal is
to guarantee get contiguous area in deterministic time. For that,
it used frontswap/cleancache concept.

http://events.linuxfoundation.org/sites/events/files/slides/gcma-guaranteed_contiguous_memory_allocator-lfklf2014_0.pdf

I hope it helps you a bit.

> 
> Thanks!
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
