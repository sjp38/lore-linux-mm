Date: Tue, 29 Apr 2008 16:14:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] slabinfo: Support printout of the number of fallbacks
Message-ID: <Pine.LNX.4.64.0804291613470.15436@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Also from your testing tree. Rediffed against current git]

Add functionality to slabinfo to print out the number of fallbacks
that have occurred for each slab cache when the -D option is specified.
Also widen the allocation / free field since the numbers became
too big after a week.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 Documentation/vm/slabinfo.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6/Documentation/vm/slabinfo.c
===================================================================
--- linux-2.6.orig/Documentation/vm/slabinfo.c	2008-04-28 21:20:43.971140163 -0700
+++ linux-2.6/Documentation/vm/slabinfo.c	2008-04-28 21:22:12.919899273 -0700
@@ -38,7 +38,7 @@ struct slabinfo {
 	unsigned long alloc_from_partial, alloc_slab, free_slab, alloc_refill;
 	unsigned long cpuslab_flush, deactivate_full, deactivate_empty;
 	unsigned long deactivate_to_head, deactivate_to_tail;
-	unsigned long deactivate_remote_frees;
+	unsigned long deactivate_remote_frees, order_fallback;
 	int numa[MAX_NODES];
 	int numa_partial[MAX_NODES];
 } slabinfo[MAX_SLABS];
@@ -293,7 +293,7 @@ int line = 0;
 void first_line(void)
 {
 	if (show_activity)
-		printf("Name                   Objects    Alloc     Free   %%Fast\n");
+		printf("Name                   Objects      Alloc       Free   %%Fast Fallb O\n");
 	else
 		printf("Name                   Objects Objsize    Space "
 			"Slabs/Part/Cpu  O/S O %%Fr %%Ef Flg\n");
@@ -573,11 +573,12 @@ void slabcache(struct slabinfo *s)
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
@@ -1188,6 +1189,7 @@ void read_slab_dir(void)
 			slab->deactivate_to_head = get_obj("deactivate_to_head");
 			slab->deactivate_to_tail = get_obj("deactivate_to_tail");
 			slab->deactivate_remote_frees = get_obj("deactivate_remote_frees");
+			slab->order_fallback = get_obj("order_fallback");
 			chdir("..");
 			if (slab->name[0] == ':')
 				alias_targets++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
