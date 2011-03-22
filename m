Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AAEC48D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 14:35:08 -0400 (EDT)
Date: Tue, 22 Mar 2011 13:35:00 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: slub: Add statistics for this_cmpxchg_double failures
Message-ID: <alpine.DEB.2.00.1103221333130.16870@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org

Add some statistics for debugging.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-03-11 10:34:26.000000000 -0600
+++ linux-2.6/include/linux/slub_def.h	2011-03-11 10:34:49.000000000 -0600
@@ -32,6 +32,7 @@ enum stat_item {
 	DEACTIVATE_TO_TAIL,	/* Cpu slab was moved to the tail of partials */
 	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
+	CMPXCHG_DOUBLE_CPU_FAIL,/* Failure of this_cpu_cmpxchg_double */
 	NR_SLUB_STAT_ITEMS };

 struct kmem_cache_cpu {
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-11 10:34:27.000000000 -0600
+++ linux-2.6/mm/slub.c	2011-03-11 10:34:49.000000000 -0600
@@ -217,7 +217,7 @@ static inline void sysfs_slab_remove(str

 #endif

-static inline void stat(struct kmem_cache *s, enum stat_item si)
+static inline void stat(const struct kmem_cache *s, enum stat_item si)
 {
 #ifdef CONFIG_SLUB_STATS
 	__this_cpu_inc(s->cpu_slab->stat[si]);
@@ -1551,6 +1551,7 @@ static inline void note_cmpxchg_failure(
 		printk("for unknown reason: actual=%lx was=%lx target=%lx\n",
 			actual_tid, tid, next_tid(tid));
 #endif
+	stat(s, CMPXCHG_DOUBLE_CPU_FAIL);
 }

 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
