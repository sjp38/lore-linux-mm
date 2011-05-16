Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 555436B0028
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:25 -0400 (EDT)
Message-Id: <20110516202622.862544137@linux.com>
Date: Mon, 16 May 2011 15:26:08 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 03/25] slub: Make CONFIG_PAGE_ALLOC work with new fastpath
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=fixup
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Fastpath can do a speculative access to a page that CONFIG_PAGE_ALLOC may have
marked as invalid to retrieve the pointer to the next free object.

Use probe_kernel_read in that case in order not to cause a page fault.

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-10 14:31:28.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-05-10 14:31:35.000000000 -0500
@@ -261,6 +261,18 @@ static inline void *get_freepointer(stru
 	return *(void **)(object + s->offset);
 }
 
+static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
+{
+	void *p;
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
+#else
+	p = get_freepointer(s, object);
+#endif
+	return p;
+}
+
 static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 {
 	*(void **)(object + s->offset) = fp;
@@ -1933,7 +1945,7 @@ redo:
 		if (unlikely(!irqsafe_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
 				object, tid,
-				get_freepointer(s, object), next_tid(tid)))) {
+				get_freepointer_safe(s, object), next_tid(tid)))) {
 
 			note_cmpxchg_failure("slab_alloc", s, tid);
 			goto redo;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
