Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F0E5E900145
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:41 -0400 (EDT)
Message-Id: <20110902204657.105194589@linux.com>
Date: Fri, 02 Sep 2011 15:46:57 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 00/12] slub: RFC lockless allocation paths V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

Draft of a patchset to make the allocation paths lockless as well.

I have done just a hackbench test on this to make sure that it works.
Various additional overhead is added to the fastpaths so this may
require additional work before it becomes mergeable.

The first two patches are cleanup patches that have been posted a couple of
times. Those can be merged.

The basic principle is to use double word atomic allocations to check
lists of objects in and out of the per cpu structures and the
per page structures.

Since we can only handle two words atomically we need to reduce the
state being kept for per cpu queues. Thus the page and the node field
in kmem_cache_cpu have to be dropped. Both of those values can be
determined from an object pointer after all but the calculation of
those values impacts the performance of the allocator. Not sure what
the impact is. Could be offset by the removal of the overhead for
interrupt disabling/enabling and the code savings because the per
cpu state for queueing is much less.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
