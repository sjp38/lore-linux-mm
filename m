Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7E2406B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:18:56 -0400 (EDT)
Message-Id: <20100521211452.659982351@quilx.com>
Date: Fri, 21 May 2010 16:14:52 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(V2 some more work as time permitted this week)

SLEB is a merging of SLUB with some queuing concepts from SLAB and a new way
of managing objects in the slabs using bitmaps. It uses a percpu queue so that
free operations can be properly buffered and a bitmap for managing the
free/allocated state in the slabs. It is slightly more inefficient than
SLUB (due to the need to place large bitmaps --sized a few words--in some
slab pages if there are more than BITS_PER_LONG objects in a slab page) but
in general does compete well with SLUB (and therefore also with SLOB) 
in terms of memory wastage.

It does not have the excessive memory requirements of SLAB because
there is no slab management structure nor alien caches. Under NUMA
the remote shared caches are used instead (which may have its issues).

The SLAB scheme of not touching the object during management is adopted.
SLEB can efficiently free and allocate cache cold objects without
causing cache misses.

There are numerous SLAB schemes that are not supported. Those could be
added if needed and if they really make a difference.

WARNING: This only ran successfully using hackbench in kvm instances so far.
But works with NUMA, SMP and UP there.

V1->V2 Add NUMA capabilities. Refine queue size configurations (not complete).
   Test in UP, SMP, NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
