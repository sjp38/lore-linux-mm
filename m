Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 607A46B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 17:06:55 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id i66so23338967itf.0
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 14:06:55 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id y135si15603910itb.85.2017.12.27.14.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 14:06:54 -0800 (PST)
Message-Id: <20171227220636.361857279@linux.com>
Date: Wed, 27 Dec 2017 16:06:36 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 0/8] Xarray object migration V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

This is a patchset on top of Matthew Wilcox Xarray code and implements
object migration of xarray nodes. The migration is integrated into
the defragmetation and shrinking logic of the slab allocator.

Defragmentation will ensure that all xarray slab pages have
less objects available than specified by the slab defrag ratio.

Slab shrinking will create a slab cache with optimal object
density. Only one slab page will have available objects per node.

To test apply this patchset on top of Matthew Wilcox Xarray code
from Dec 11th (See infradead github).

Then go to

/sys/kernel/slab/radix_tree

Inspect the number of partial slab pages

	cat partial

And then perform a cache shrink operation

	echo 1 >shrink


This is just a barebones approach using a special mode
of the slab migration patchset that does not require refcounts.

If this is acceptable then additional functionality can be added:

1. Migration of objects to a specific node

2. Dispersion of objects across all nodes (MPOL_INTERLEAVE)

3. Subsystems can request to move an object to a specific node.

4. Tying into the page migration and page defragmentation logic so
   that so far unmovable pages that are in the way of creating a
   contiguous block of memory will become movable.

This is only possible for xarray for now but it would be worthwhile
to extend this to dentries and inodes.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
