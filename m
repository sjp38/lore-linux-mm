Message-ID: <487E1958.9060606@linux-foundation.org>
Date: Wed, 16 Jul 2008 10:52:56 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] slub: increasing order reduces memory usage of some
 key caches
References: <1216211371.3122.46.camel@castor.localdomain>
In-Reply-To: <1216211371.3122.46.camel@castor.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

You can get a similar effect by booting with a kernel parameter slub_min_objects=20 or so.

The fundamental difference in your patch is that you check for the wasted space in terms of a fraction of the size of a single object whereas the current logic only checks in terms of fractions of a page.

We could add an additional condition that the wasted space be no larger than half an object?

Affected slab configurations 

24 byte sized caches now become an order 1 cache.
72 byte sizes caches now become order 3
96 byte 0 - > 1
320 1 -> 2
448 2 -> 3

buffer_head 0 -> 1
idr_layer_cache 2 -> 3
inode_cache 2 -> 3
journal_*  1 -> 2

etc

So the effect would be a significant enlargement of caches.

In general the speed of slub is bigger the larger the allocations it can get from the page allocator. The page allocators performance is pretty slow compared to slub alloc logic so its a win to minimize calls to it. However, that in turn will put pressure on
larger page allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
