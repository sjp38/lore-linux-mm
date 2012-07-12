Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id A8FE46B0069
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:39 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/16] mm: slub: Optimise the SLUB fast path to avoid pfmemalloc checks
Date: Thu, 12 Jul 2012 07:40:18 +0100
Message-Id: <1342075232-29267-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075232-29267-1-git-send-email-mgorman@suse.de>
References: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

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
index 98fecc2..8e2a2f3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2287,11 +2287,11 @@ new_slab:
 	}
 
 	page = c->page;
-	if (likely(!kmem_cache_debug(s)))
+	if (likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
 		goto load_freelist;
 
 	/* Only entered in the debug case */
-	if (!alloc_debug_processing(s, page, freelist, addr))
+	if (kmem_cache_debug(s) && !alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
 	deactivate_slab(s, page, get_freepointer(s, freelist));
@@ -2343,8 +2343,7 @@ redo:
 
 	object = c->freelist;
 	page = c->page;
-	if (unlikely(!object || !node_match(page, node)
-					!pfmemalloc_match(page, gfpflags)))
+	if (unlikely(!object || !node_match(page, node)))
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
