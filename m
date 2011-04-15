Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B17790009B
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:08 -0400 (EDT)
Message-Id: <20110415201301.353064020@linux.com>
Date: Fri, 15 Apr 2011 15:12:57 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: Add cmpxchg_double_slab()
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=cmpxchg_double_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

Add a function that operates on the second doubleword in the page struct
and manipulates the object counters, the freelist and the frozen attribute.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |   45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 13:14:40.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 13:14:51.000000000 -0500
@@ -131,6 +131,9 @@ static inline int kmem_cache_debug(struc
 /* Enable to test recovery from slab corruption on boot */
 #undef SLUB_RESILIENCY_TEST
 
+/* Enable to log cmpxchg failures */
+#undef SLUB_DEBUG_CMPXCHG
+
 /*
  * Mininum number of partial slabs. These will be left on the partial
  * lists even if they are empty. kmem_cache_shrink may reclaim them.
@@ -170,6 +173,7 @@ static inline int kmem_cache_debug(struc
 
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
+#define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
 
 static int kmem_size = sizeof(struct kmem_cache);
 
@@ -326,6 +330,37 @@ static inline int oo_objects(struct kmem
 	return x.x & OO_MASK;
 }
 
+static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
+		void *freelist_old, unsigned long counters_old,
+		void *freelist_new, unsigned long counters_new,
+		const char *n)
+{
+#ifdef CONFIG_CMPXCHG_DOUBLE
+	if (s->flags & __CMPXCHG_DOUBLE) {
+		if (cmpxchg_double(&page->freelist,
+			freelist_old, counters_old,
+			freelist_new, counters_new))
+		return 1;
+	} else
+#endif
+	{
+		if (page->freelist == freelist_old && page->counters == counters_old) {
+			page->freelist = freelist_new;
+			page->counters = counters_new;
+			return 1;
+		}
+	}
+
+	cpu_relax();
+	stat(s, CMPXCHG_DOUBLE_FAIL);
+
+#ifdef SLUB_DEBUG_CMPXCHG
+	printk(KERN_INFO "%s %s: cmpxchg double redo ", n, s->name);
+#endif
+
+	return 0;
+}
+
 /*
  * Determine a map of object in use on a page.
  *
@@ -2654,6 +2689,12 @@ static int kmem_cache_open(struct kmem_c
 		}
 	}
 
+#ifdef CONFIG_CMPXCHG_DOUBLE
+	if (system_has_cmpxchg_double() && (s->flags & SLAB_DEBUG_FLAGS) == 0)
+		/* Enable fast mode */
+		s->flags |= __CMPXCHG_DOUBLE;
+#endif
+
 	/*
 	 * The larger the object size is, the more pages we want on the partial
 	 * list to avoid pounding the page allocator excessively.
@@ -4551,6 +4592,8 @@ STAT_ATTR(DEACTIVATE_TO_HEAD, deactivate
 STAT_ATTR(DEACTIVATE_TO_TAIL, deactivate_to_tail);
 STAT_ATTR(DEACTIVATE_REMOTE_FREES, deactivate_remote_frees);
 STAT_ATTR(ORDER_FALLBACK, order_fallback);
+STAT_ATTR(CMPXCHG_DOUBLE_CPU_FAIL, cmpxchg_double_cpu_fail);
+STAT_ATTR(CMPXCHG_DOUBLE_FAIL, cmpxchg_double_fail);
 #endif
 
 static struct attribute *slab_attrs[] = {
@@ -4608,6 +4651,8 @@ static struct attribute *slab_attrs[] =
 	&deactivate_to_tail_attr.attr,
 	&deactivate_remote_frees_attr.attr,
 	&order_fallback_attr.attr,
+	&cmpxchg_double_fail_attr.attr,
+	&cmpxchg_double_cpu_fail_attr.attr,
 #endif
 #ifdef CONFIG_FAILSLAB
 	&failslab_attr.attr,
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-04-13 15:19:53.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2011-04-15 13:14:51.000000000 -0500
@@ -33,6 +33,7 @@ enum stat_item {
 	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	CMPXCHG_DOUBLE_CPU_FAIL,/* Failure of this_cpu_cmpxchg_double */
+	CMPXCHG_DOUBLE_FAIL,	/* Number of times that cmpxchg double did not match */
 	NR_SLUB_STAT_ITEMS };
 
 struct kmem_cache_cpu {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
