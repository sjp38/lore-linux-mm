Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id A8BB3908C2
	for <linux-mm@kvack.org>; Fri, 17 Aug 2007 14:52:50 -0700 (PDT)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1IM9kQ-0002p0-00
	for <linux-mm@kvack.org>; Fri, 17 Aug 2007 14:52:50 -0700
Date: Fri, 17 Aug 2007 14:52:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Use atomic_long_read for atomic_long variables
Message-ID: <Pine.LNX.4.64.0708171452380.10842@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---------- Forwarded message ----------
Date: Fri, 17 Aug 2007 14:49:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
To: akpm@linux-foundation.org
Cc: linux-mm@vger.kernel.org
Subject: SLUB: Use atomic_long_read for atomic_long variables

SLUB is using atomic_read() for variables declared atomic_long_t.
Switch to atomic_long_read().

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ac0728a..6db1725 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3112,7 +3112,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 		unsigned long flags;
 		struct page *page;
 
-		if (!atomic_read(&n->nr_slabs))
+		if (!atomic_long_read(&n->nr_slabs))
 			continue;
 
 		spin_lock_irqsave(&n->list_lock, flags);
@@ -3247,7 +3247,7 @@ static unsigned long slab_objects(struct kmem_cache *s,
 		}
 
 		if (flags & SO_FULL) {
-			int full_slabs = atomic_read(&n->nr_slabs)
+			int full_slabs = atomic_long_read(&n->nr_slabs)
 					- per_cpu[node]
 					- n->nr_partial;
 
@@ -3283,7 +3283,7 @@ static int any_slab_objects(struct kmem_cache *s)
 	for_each_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		if (n->nr_partial || atomic_read(&n->nr_slabs))
+		if (n->nr_partial || atomic_long_read(&n->nr_slabs))
 			return 1;
 	}
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
