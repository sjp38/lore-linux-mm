Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 977276B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:09:04 -0400 (EDT)
Date: Wed, 14 Apr 2010 10:07:19 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414140719.GR13327@think>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
 <20100413095815.GU25756@csn.ul.ie>
 <20100413111902.GY2493@dastard>
 <20100413193428.GI25756@csn.ul.ie>
 <20100413202021.GZ13327@think>
 <877hoa9wlv.fsf@basil.nowhere.org>
 <20100414112015.GO13327@think>
 <20100414132349.GL25756@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100414132349.GL25756@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 02:23:50PM +0100, Mel Gorman wrote:
> On Wed, Apr 14, 2010 at 07:20:15AM -0400, Chris Mason wrote:

[ nods ]

> 
> Bear in mind that the context of lumpy reclaim that the VM doesn't care
> about where the data is on the file or filesystem. It's only concerned
> about where the data is located in memory. There *may* be a correlation
> between location-of-data-in-file and location-of-data-in-memory but only
> if readahead was a factor and readahead happened to hit at a time the page
> allocator broke up a contiguous block of memory.
> 
> > I know Mel mentioned before he wasn't interested in waiting for helper
> > threads, but I don't see how we can work without it.
> > 
> 
> I'm not against the idea as such. It would have advantages in that the
> thread could reorder the IO for better seeks for example and lumpy
> reclaim is already potentially waiting a long time so another delay
> won't hurt. I would worry that it's just hiding the stack usage by
> moving it to another thread and that there would be communication cost
> between a direct reclaimer and this writeback thread. The main gain
> would be in hiding the "splicing" effect between subsystems that direct
> reclaim can have.

The big gain from the helper threads is that storage operates at a
roughly fixed iop rate.  This is true for ssd as well, it's just a much
higher rate.  So the threads can send down 4K ios and recover clean pages at
exactly the same rate it would sending down 64KB ios. 

I know that for lumpy purposes it might not be the best 64KB, but the
other side of it is that we have to write those pages eventually anyway.
We might as well write them when it is more or less free.

The per-bdi writeback threads are a pretty good base for changing the
ordering for writeback, it seems like a good place to integrate requests
from the VM about which files (and which offsets in those files) to
write back first.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
