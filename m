Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 39CAD6B0072
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 07:35:42 -0500 (EST)
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 4/4] slub: min order when corrupt_dbg
Date: Fri, 11 Nov 2011 13:36:34 +0100
Message-Id: <1321014994-2426-4-git-send-email-sgruszka@redhat.com>
In-Reply-To: <1321014994-2426-1-git-send-email-sgruszka@redhat.com>
References: <1321014994-2426-1-git-send-email-sgruszka@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>, Stanislaw Gruszka <sgruszka@redhat.com>

Disable slub debug facilities and allocate slabs at minimal order when
corrupt_dbg > 0 to increase probability to catch random memory
corruption by cpu exception.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 mm/slub.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 7d2a996..b0e4318 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2844,7 +2844,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	unsigned long flags = s->flags;
 	unsigned long size = s->objsize;
 	unsigned long align = s->align;
-	int order;
+	int order, min_order;
 
 	/*
 	 * Round up object size to the next word boundary. We can only
@@ -2929,8 +2929,11 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	 */
 	size = ALIGN(size, align);
 	s->size = size;
+	min_order = get_order(size);
 	if (forced_order >= 0)
 		order = forced_order;
+	else if (corrupt_dbg())
+		order = min_order;
 	else
 		order = calculate_order(size, s->reserved);
 
@@ -2951,7 +2954,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	 * Determine the number of objects per slab
 	 */
 	s->oo = oo_make(order, size, s->reserved);
-	s->min = oo_make(get_order(size), size, s->reserved);
+	s->min = oo_make(min_order, size, s->reserved);
 	if (oo_objects(s->oo) > oo_objects(s->max))
 		s->max = s->oo;
 
@@ -3645,6 +3648,9 @@ void __init kmem_cache_init(void)
 	struct kmem_cache *temp_kmem_cache_node;
 	unsigned long kmalloc_size;
 
+	if (corrupt_dbg())
+		slub_debug = 0;
+
 	kmem_size = offsetof(struct kmem_cache, node) +
 				nr_node_ids * sizeof(struct kmem_cache_node *);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
