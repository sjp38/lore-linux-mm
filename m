Received: by ti-out-0910.google.com with SMTP id j3so679875tid.8
        for <linux-mm@kvack.org>; Sun, 24 Aug 2008 10:49:55 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [PATCH] kmemtrace: SLUB hooks for caller-tracking functions.
Date: Sun, 24 Aug 2008 20:49:35 +0300
Message-Id: <1219600175-5253-1-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

This patch adds kmemtrace hooks for __kmalloc_track_caller() and
__kmalloc_node_track_caller(). Currently, they set the call site pointer
to the value recieved as a parameter. (This could change if we implement
stack trace exporting in kmemtrace.)

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 mm/slub.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 06755e2..e79b814 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3254,6 +3254,7 @@ static struct notifier_block __cpuinitdata slab_notifier = {
 void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, void *caller)
 {
 	struct kmem_cache *s;
+	void *ret;
 
 	if (unlikely(size > PAGE_SIZE))
 		return kmalloc_large(size, gfpflags);
@@ -3263,13 +3264,21 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, void *caller)
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	return slab_alloc(s, gfpflags, -1, caller);
+	ret = slab_alloc(s, gfpflags, -1, caller);
+
+	/* Honor the call site pointer we recieved. */
+	kmemtrace_mark_alloc(KMEMTRACE_TYPE_KMALLOC,
+			     (unsigned long) caller, ret,
+			     size, s->size, gfpflags);
+
+	return ret;
 }
 
 void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 					int node, void *caller)
 {
 	struct kmem_cache *s;
+	void *ret;
 
 	if (unlikely(size > PAGE_SIZE))
 		return kmalloc_large_node(size, gfpflags, node);
@@ -3279,7 +3288,14 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
-	return slab_alloc(s, gfpflags, node, caller);
+	ret = slab_alloc(s, gfpflags, node, caller);
+
+	/* Honor the call site pointer we recieved. */
+	kmemtrace_mark_alloc_node(KMEMTRACE_TYPE_KMALLOC,
+				  (unsigned long) caller, ret,
+				  size, s->size, gfpflags, node);
+
+	return ret;
 }
 
 #ifdef CONFIG_SLUB_DEBUG
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
