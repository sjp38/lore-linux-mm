Date: Fri, 25 Apr 2008 12:21:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: slabinfo: Support printout of the number of fallbacks
Message-ID: <Pine.LNX.4.64.0804251218530.5971@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add functionality to slabinfo to print out the number of fallbacks
that have occurred for each slab cache when the -D option is specified.
Also widen the allocation / free field since the numbers became
too big after a week.

[On top of defrag patches I am afraid]

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/vm/slabinfo.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6/Documentation/vm/slabinfo.c
===================================================================
--- linux-2.6.orig/Documentation/vm/slabinfo.c	2008-04-24 22:47:43.089898936 -0700
+++ linux-2.6/Documentation/vm/slabinfo.c	2008-04-24 22:48:48.939895821 -0700
@@ -40,7 +40,7 @@ struct slabinfo {
 	unsigned long alloc_from_partial, alloc_slab, free_slab, alloc_refill;
 	unsigned long cpuslab_flush, deactivate_full, deactivate_empty;
 	unsigned long deactivate_to_head, deactivate_to_tail;
-	unsigned long deactivate_remote_frees;
+	unsigned long deactivate_remote_frees, order_fallback;
 	unsigned long shrink_calls, shrink_attempt_defrag, shrink_empty_slab;
 	unsigned long shrink_slab_skipped, shrink_slab_reclaimed;
 	unsigned long shrink_object_reclaim_failure;
@@ -302,7 +302,7 @@ int line = 0;
 void first_line(void)
 {
 	if (show_activity)
-		printf("Name                   Objects    Alloc     Free   %%Fast\n");
+		printf("Name                   Objects      Alloc       Free   %%Fast Fallb O\n");
 	else
 		printf("Name                   Objects Objsize    Space "
 			"Slabs/Part/Cpu  O/S O %%Ra %%Ef Flg\n");
@@ -601,11 +601,12 @@ void slabcache(struct slabinfo *s)
 		total_alloc = s->alloc_fastpath + s->alloc_slowpath;
 		total_free = s->free_fastpath + s->free_slowpath;
 
-		printf("%-21s %8ld %8ld %8ld %3ld %3ld \n",
+		printf("%-21s %8ld %10ld %10ld %3ld %3ld %5ld %1d\n",
 			s->name, s->objects,
 			total_alloc, total_free,
 			total_alloc ? (s->alloc_fastpath * 100 / total_alloc) : 0,
-			total_free ? (s->free_fastpath * 100 / total_free) : 0);
+			total_free ? (s->free_fastpath * 100 / total_free) : 0,
+			s->order_fallback, s->order);
 	}
 	else
 		printf("%-21s %8ld %7d %8s %14s %4d %1d %3ld %3ld %s\n",
@@ -1217,6 +1218,7 @@ void read_slab_dir(void)
 			slab->deactivate_to_head = get_obj("deactivate_to_head");
 			slab->deactivate_to_tail = get_obj("deactivate_to_tail");
 			slab->deactivate_remote_frees = get_obj("deactivate_remote_frees");
+			slab->order_fallback = get_obj("order_fallback");
 			slab->shrink_calls = get_obj("shrink_calls");
 			slab->shrink_attempt_defrag = get_obj("shrink_attempt_defrag");
 			slab->shrink_empty_slab = get_obj("shrink_empty_slab");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
