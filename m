Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 13F746B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 01:08:14 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id r10so34475968pdi.9
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 22:08:13 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id mz9si14518318pdb.205.2015.01.18.22.08.10
        for <linux-mm@kvack.org>;
        Sun, 18 Jan 2015 22:08:12 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 1/2] mm/slub: optimize alloc/free fastpath by removing preemption on/off
Date: Mon, 19 Jan 2015 15:08:49 +0900
Message-Id: <1421647730-11568-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>, Guenter Roeck <linux@roeck-us.net>

We had to insert a preempt enable/disable in the fastpath a while ago
in order to guarantee that tid and kmem_cache_cpu are retrieved on the
same cpu. It is the problem only for CONFIG_PREEMPT in which scheduler
can move the process to other cpu during retrieving data.

Now, I reach the solution to remove preempt enable/disable in the fastpath.
If tid is matched with kmem_cache_cpu's tid after tid and kmem_cache_cpu
are retrieved by separate this_cpu operation, it means that they are
retrieved on the same cpu. If not matched, we just have to retry it.

With this guarantee, preemption enable/disable isn't need at all even if
CONFIG_PREEMPT, so this patch removes it.

I saw roughly 5% win in a fast-path loop over kmem_cache_alloc/free
in CONFIG_PREEMPT. (14.821 ns -> 14.049 ns)

Below is the result of Christoph's slab_test reported by
Jesper Dangaard Brouer.

* Before

 Single thread testing
 =====================
 1. Kmalloc: Repeatedly allocate then free test
 10000 times kmalloc(8) -> 49 cycles kfree -> 62 cycles
 10000 times kmalloc(16) -> 48 cycles kfree -> 64 cycles
 10000 times kmalloc(32) -> 53 cycles kfree -> 70 cycles
 10000 times kmalloc(64) -> 64 cycles kfree -> 77 cycles
 10000 times kmalloc(128) -> 74 cycles kfree -> 84 cycles
 10000 times kmalloc(256) -> 84 cycles kfree -> 114 cycles
 10000 times kmalloc(512) -> 83 cycles kfree -> 116 cycles
 10000 times kmalloc(1024) -> 81 cycles kfree -> 120 cycles
 10000 times kmalloc(2048) -> 104 cycles kfree -> 136 cycles
 10000 times kmalloc(4096) -> 142 cycles kfree -> 165 cycles
 10000 times kmalloc(8192) -> 238 cycles kfree -> 226 cycles
 10000 times kmalloc(16384) -> 403 cycles kfree -> 264 cycles
 2. Kmalloc: alloc/free test
 10000 times kmalloc(8)/kfree -> 68 cycles
 10000 times kmalloc(16)/kfree -> 68 cycles
 10000 times kmalloc(32)/kfree -> 69 cycles
 10000 times kmalloc(64)/kfree -> 68 cycles
 10000 times kmalloc(128)/kfree -> 68 cycles
 10000 times kmalloc(256)/kfree -> 68 cycles
 10000 times kmalloc(512)/kfree -> 74 cycles
 10000 times kmalloc(1024)/kfree -> 75 cycles
 10000 times kmalloc(2048)/kfree -> 74 cycles
 10000 times kmalloc(4096)/kfree -> 74 cycles
 10000 times kmalloc(8192)/kfree -> 75 cycles
 10000 times kmalloc(16384)/kfree -> 510 cycles

* After

 Single thread testing
 =====================
 1. Kmalloc: Repeatedly allocate then free test
 10000 times kmalloc(8) -> 46 cycles kfree -> 61 cycles
 10000 times kmalloc(16) -> 46 cycles kfree -> 63 cycles
 10000 times kmalloc(32) -> 49 cycles kfree -> 69 cycles
 10000 times kmalloc(64) -> 57 cycles kfree -> 76 cycles
 10000 times kmalloc(128) -> 66 cycles kfree -> 83 cycles
 10000 times kmalloc(256) -> 84 cycles kfree -> 110 cycles
 10000 times kmalloc(512) -> 77 cycles kfree -> 114 cycles
 10000 times kmalloc(1024) -> 80 cycles kfree -> 116 cycles
 10000 times kmalloc(2048) -> 102 cycles kfree -> 131 cycles
 10000 times kmalloc(4096) -> 135 cycles kfree -> 163 cycles
 10000 times kmalloc(8192) -> 238 cycles kfree -> 218 cycles
 10000 times kmalloc(16384) -> 399 cycles kfree -> 262 cycles
 2. Kmalloc: alloc/free test
 10000 times kmalloc(8)/kfree -> 65 cycles
 10000 times kmalloc(16)/kfree -> 66 cycles
 10000 times kmalloc(32)/kfree -> 65 cycles
 10000 times kmalloc(64)/kfree -> 66 cycles
 10000 times kmalloc(128)/kfree -> 66 cycles
 10000 times kmalloc(256)/kfree -> 71 cycles
 10000 times kmalloc(512)/kfree -> 72 cycles
 10000 times kmalloc(1024)/kfree -> 71 cycles
 10000 times kmalloc(2048)/kfree -> 71 cycles
 10000 times kmalloc(4096)/kfree -> 71 cycles
 10000 times kmalloc(8192)/kfree -> 65 cycles
 10000 times kmalloc(16384)/kfree -> 511 cycles

Most of the results are better than before.

Note that this change slightly worses performance in !CONFIG_PREEMPT,
roughly 0.3%. Implementing each case separately would help performance,
but, since it's so marginal, I didn't do that. This would help
maintanance since we have same code for all cases.

Change from v1: add comment about barrier() usage
Change from v2:
- use raw_cpu_ptr() rather than this_cpu_ptr() to avoid warning from
 preemption debug check since this is intended behaviour
- fix typo alogorithm -> algorithm

Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slub.c |   35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index fe376fe..e7ed6f8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2398,13 +2398,24 @@ redo:
 	 * reading from one cpu area. That does not matter as long
 	 * as we end up on the original cpu again when doing the cmpxchg.
 	 *
-	 * Preemption is disabled for the retrieval of the tid because that
-	 * must occur from the current processor. We cannot allow rescheduling
-	 * on a different processor between the determination of the pointer
-	 * and the retrieval of the tid.
+	 * We should guarantee that tid and kmem_cache are retrieved on
+	 * the same cpu. It could be different if CONFIG_PREEMPT so we need
+	 * to check if it is matched or not.
 	 */
-	preempt_disable();
-	c = this_cpu_ptr(s->cpu_slab);
+	do {
+		tid = this_cpu_read(s->cpu_slab->tid);
+		c = raw_cpu_ptr(s->cpu_slab);
+	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
+
+	/*
+	 * Irqless object alloc/free algorithm used here depends on sequence
+	 * of fetching cpu_slab's data. tid should be fetched before anything
+	 * on c to guarantee that object and page associated with previous tid
+	 * won't be used with current tid. If we fetch tid first, object and
+	 * page could be one associated with next tid and our alloc/free
+	 * request will be failed. In this case, we will retry. So, no problem.
+	 */
+	barrier();
 
 	/*
 	 * The transaction ids are globally unique per cpu and per operation on
@@ -2412,8 +2423,6 @@ redo:
 	 * occurs on the right processor and that there was no operation on the
 	 * linked list in between.
 	 */
-	tid = c->tid;
-	preempt_enable();
 
 	object = c->freelist;
 	page = c->page;
@@ -2659,11 +2668,13 @@ redo:
 	 * data is retrieved via this pointer. If we are on the same cpu
 	 * during the cmpxchg then the free will succedd.
 	 */
-	preempt_disable();
-	c = this_cpu_ptr(s->cpu_slab);
+	do {
+		tid = this_cpu_read(s->cpu_slab->tid);
+		c = raw_cpu_ptr(s->cpu_slab);
+	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
 
-	tid = c->tid;
-	preempt_enable();
+	/* Same with comment on barrier() in slab_alloc_node() */
+	barrier();
 
 	if (likely(page == c->page)) {
 		set_freepointer(s, object, c->freelist);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
