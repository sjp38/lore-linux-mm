Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id ABAE96B0071
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 07:44:18 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/17] mm: slub: Optimise the SLUB fast path to avoid pfmemalloc checks
Date: Wed, 20 Jun 2012 12:43:57 +0100
Message-Id: <1340192652-31658-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1340192652-31658-1-git-send-email-mgorman@suse.de>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

From: Christoph Lameter <cl@linux.com>

This patch removes the check for pfmemalloc from the alloc hotpath and
puts the logic after the election of a new per cpu slab. For a pfmemalloc
page we do not use the fast path but force the use of the slow path which
is also used for the debug case.

This has the side-effect of weakening pfmemalloc processing in the
following way;

1. A process that is allocating for network swap calls __slab_alloc.
   pfmemalloc_match is true so the freelist is loaded and c->freelist is
   now pointing to a pfmemalloc page.

2. A process that is attempting normal allocations calls slab_alloc,
   finds the pfmemalloc page on the freelist and uses it because it did
   not check pfmemalloc_match()

The patch allows non-pfmemalloc allocations to use pfmemalloc pages with
the kmalloc slabs being the most vunerable caches on the grounds they
are most likely to have a mix of pfmemalloc and !pfmemalloc requests. A
later patch will still protect the system as processes will get throttled
if the pfmemalloc reserves get depleted but performance will not degrade
as smoothly.

[mgorman@suse.de: Expanded changelog]
Signed-off-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/slub.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 3cf24b4..dd13305 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2301,11 +2301,11 @@ new_slab:
 		}
 	}
 
-	if (likely(!kmem_cache_debug(s)))
+	if (likely(!kmem_cache_debug(s) && pfmemalloc_match(c, gfpflags)))
 		goto load_freelist;
 
 	/* Only entered in the debug case */
-	if (!alloc_debug_processing(s, c->page, object, addr))
+	if (kmem_cache_debug(s) && !alloc_debug_processing(s, c->page, object, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
 	c->freelist = get_freepointer(s, object);
@@ -2355,8 +2355,7 @@ redo:
 	barrier();
 
 	object = c->freelist;
-	if (unlikely(!object || !node_match(c, node) ||
-					!pfmemalloc_match(c, gfpflags)))
+	if (unlikely(!object || !node_match(c, node)))
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
