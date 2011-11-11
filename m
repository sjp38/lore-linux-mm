Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 74A986B0074
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:36 -0500 (EST)
Message-Id: <20111111200733.782713279@linux.com>
Date: Fri, 11 Nov 2011 14:07:24 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 13/18] slub: Add functions to manage per cpu freelists
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=newfuncs
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Add a couple of functions that will be used later to manage the per cpu
freelists.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-10 13:50:40.250719277 -0600
+++ linux-2.6/mm/slub.c	2011-11-10 13:56:05.602531668 -0600
@@ -2111,6 +2111,58 @@ static inline void *new_slab_objects(str
 }
 
 /*
+ * Retrieve pointer to the current freelist and
+ * zap the per cpu object list.
+ *
+ * Returns NULL if there was no object on the freelist.
+ */
+void *get_cpu_objects(struct kmem_cache *s)
+{
+	void *freelist;
+	unsigned long tid;
+
+	do {
+		struct kmem_cache_cpu *c = this_cpu_ptr(s->cpu_slab);
+
+		tid = c->tid;
+		barrier();
+		freelist = c->freelist;
+		if (!freelist)
+			return NULL;
+
+	} while (!this_cpu_cmpxchg_double(s->cpu_slab->freelist, s->cpu_slab->tid,
+			freelist, tid,
+			NULL, next_tid(tid)));
+
+	return freelist;
+}
+
+/*
+ * Set the per cpu object list to the freelist. The page must
+ * be frozen.
+ *
+ * Page will be unfrozen (and the freelist object put onto the pages freelist)
+ * if the per cpu freelist has been used in the meantime.
+ */
+static inline void put_cpu_objects(struct kmem_cache *s,
+				struct page *page, void *freelist)
+{
+	unsigned long tid;
+
+	tid = this_cpu_read(s->cpu_slab->tid);
+	barrier();
+
+	VM_BUG_ON(!page->frozen);
+	if (!irqsafe_cpu_cmpxchg_double(s->cpu_slab->freelist, s->cpu_slab->tid,
+		NULL, tid, freelist, next_tid(tid)))
+
+		/*
+		 * There was an intervening free or alloc. Cannot free to the
+		 * per cpu queue. Must unfreeze page.
+		 */
+		deactivate_slab(s, page, freelist);
+}
+/*
  * Check the page->freelist of a page and either transfer the freelist to the per cpu freelist
  * or deactivate the page.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
