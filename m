Date: Fri, 8 Jun 2007 15:15:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB slab validation: Move tracking information alloc outside of
 lock
Message-ID: <Pine.LNX.4.64.0706081510420.3823@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Earlier one liner was intended as the upstream fix. This is a better 
but more invasive solution]

We currently have to do an GFP_ATOMIC allocation because the list_lock
is already taken when we first allocate memory for tracking allocation
information. It would be better if we could avoid atomic allocations.

Allocate a size of the tracking table that is usually sufficient (one 
page) before we take the list lock. We will then only do the atomic 
allocation if we need to resize the table to become larger than a page 
(mostly only needed under large NUMA because of the tracking of cpus and 
nodes otherwise the table stays small).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-06-08 14:27:14.000000000 -0700
+++ slub/mm/slub.c	2007-06-08 14:35:57.000000000 -0700
@@ -2912,18 +2912,14 @@ static void free_loc_track(struct loc_tr
 			get_order(sizeof(struct location) * t->max));
 }
 
-static int alloc_loc_track(struct loc_track *t, unsigned long max)
+static int alloc_loc_track(struct loc_track *t, unsigned long max, gfp_t flags)
 {
 	struct location *l;
 	int order;
 
-	if (!max)
-		max = PAGE_SIZE / sizeof(struct location);
-
 	order = get_order(sizeof(struct location) * max);
 
-	l = (void *)__get_free_pages(GFP_ATOMIC, order);
-
+	l = (void *)__get_free_pages(flags, order);
 	if (!l)
 		return 0;
 
@@ -2989,7 +2985,7 @@ static int add_location(struct loc_track
 	/*
 	 * Not found. Insert new tracking element.
 	 */
-	if (t->count >= t->max && !alloc_loc_track(t, 2 * t->max))
+	if (t->count >= t->max && !alloc_loc_track(t, 2 * t->max, GFP_ATOMIC))
 		return 0;
 
 	l = t->loc + pos;
@@ -3032,11 +3028,12 @@ static int list_locations(struct kmem_ca
 {
 	int n = 0;
 	unsigned long i;
-	struct loc_track t;
+	struct loc_track t = { 0, 0, NULL };
 	int node;
 
-	t.count = 0;
-	t.max = 0;
+	if (!alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
+			GFP_TEMPORARY))
+		return sprintf(buf, "Out of memory\n");
 
 	/* Push back cpu slabs */
 	flush_all(s);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
