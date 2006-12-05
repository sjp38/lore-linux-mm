Date: Tue, 5 Dec 2006 15:33:50 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
In-Reply-To: <20061205214721.GE20614@skynet.ie>
Message-ID: <Pine.LNX.4.64.0612051521060.20570@schroedinger.engr.sgi.com>
References: <20061204113051.4e90b249.akpm@osdl.org>
 <Pine.LNX.4.64.0612041133020.32337@schroedinger.engr.sgi.com>
 <20061204120611.4306024e.akpm@osdl.org> <Pine.LNX.4.64.0612041211390.32337@schroedinger.engr.sgi.com>
 <20061204131959.bdeeee41.akpm@osdl.org> <Pine.LNX.4.64.0612041337520.851@schroedinger.engr.sgi.com>
 <20061204142259.3cdda664.akpm@osdl.org> <Pine.LNX.4.64.0612050754560.11213@schroedinger.engr.sgi.com>
 <20061205112541.2a4b7414.akpm@osdl.org> <Pine.LNX.4.64.0612051159510.18687@schroedinger.engr.sgi.com>
 <20061205214721.GE20614@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006, Mel Gorman wrote:

> There are times you want to reclaim just part of a zone - specifically
> satisfying a high-order allocations. See sitations 1 and 2 from elsewhere
> in this thread. On a similar vein, there will be times when you want to
> migrate a PFN range for similar reasons.

This is confusing reclaim with defragmentation. I think we are in 
conceptually unclean territory because we mix the two. If you must use 
reclaim to get a portion of contiguous memory free then yes we have this 
problem. If you can migrate pages then no there is no need for reclaiming 
a part of a zone. You can occasionally shuffle pages around to 
get a large continous chunk. If there is not enough memory then an 
independent reclaim subsystem can take care of freeing a sufficient amount 
of memory. Marrying the two seems to be getting a bit complex and maybe 
very difficult to get right.

The classification of the memory allocations is useful
to find a potential starting point to reduce the minimum number of pages 
to move to open up that hole.

> > Why would one want to allocate from the 1/4th of a zone? (Are we still 
> > discussing Mel's antifrag scheme or what is this about?)
> Because you wanted contiguous blocks of pages.  This is related to anti-frag
> because with anti-frag, reclaiming memory or migration memory will free up
> contiguous blocks. Without it, you're probably wasting your time.

I am still not sure how this should work. Reclaim in a portion of the 
reclaimable/movable portion of the zone? Or pick a huge page and simply 
reclaim all the pages in that range? 

This is required for anti-frag regardless of additonal zones right?

BTW If one would successfully do this partial reclaim thing then we also 
have no need anymore DMA zones because we can free up memory in the DMA 
area of a zone at will if we run short on memory there.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
