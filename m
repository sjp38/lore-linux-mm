Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3601728029C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:36:14 -0400 (EDT)
Received: by qgy5 with SMTP id 5so20674858qgy.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:36:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k39si6008483qgk.87.2015.07.15.09.36.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 09:36:12 -0700 (PDT)
Subject: [PATCH 3/3] slub: build detached freelist with look-ahead
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 15 Jul 2015 18:02:39 +0200
Message-ID: <20150715160212.17525.88123.stgit@devil>
In-Reply-To: <20150715155934.17525.2835.stgit@devil>
References: <20150715155934.17525.2835.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Jesper Dangaard Brouer <brouer@redhat.com>

This change is a more advanced use of detached freelist.  The bulk
free array is scanned is a progressive manor with a limited look-ahead
facility.

To maintain the same performance level, as the previous simple
implementation, the look-ahead have been limited to only 3 objects.
This number have been determined my experimental micro benchmarking.

For performance the free loop in kmem_cache_free_bulk have been
significantly reorganized, with a focus on making the branches more
predictable for the compiler.  E.g. the per CPU c->freelist is also
build as a detached freelist, even-though it would be just as fast as
freeing directly to it, but it save creating an unpredictable branch.

Another benefit of this change is that kmem_cache_free_bulk() runs
mostly with IRQs enabled.  The local IRQs are only disabled when
updating the per CPU c->freelist.  This should please Thomas Gleixner.

Pitfall(1): Removed kmem debug support.

Pitfall(2): No BUG_ON() freeing NULL pointers, but the algorithm
            handles and skips these NULL pointers.

Compare against previous patch:
 There is some fluctuation in the benchmarks between runs.  To counter
this I've run some specific[1] bulk sizes, repeated 100 times and run
dmesg through  Rusty's "stats"[2] tool.

Command line:
  sudo dmesg -c ;\
  for x in `seq 100`; do \
    modprobe slab_bulk_test02 bulksz=48 loops=100000 && rmmod slab_bulk_test02; \
    echo $x; \
    sleep 0.${RANDOM} ;\
  done; \
  dmesg | stats

Results:

bulk size:16, average: +2.01 cycles
 Prev: between 19-52 (average: 22.65 stddev:+/-6.9)
 This: between 19-67 (average: 24.67 stddev:+/-9.9)

bulk size:48, average: +1.54 cycles
 Prev: between 23-45 (average: 27.88 stddev:+/-4)
 This: between 24-41 (average: 29.42 stddev:+/-3.7)

bulk size:144, average: +1.73 cycles
 Prev: between 44-76 (average: 60.31 stddev:+/-7.7)
 This: between 49-80 (average: 62.04 stddev:+/-7.3)

bulk size:512, average: +8.94 cycles
 Prev: between 50-68 (average: 60.11 stddev: +/-4.3)
 This: between 56-80 (average: 69.05 stddev: +/-5.2)

bulk size:2048, average: +26.81 cycles
 Prev: between 61-73 (average: 68.10 stddev:+/-2.9)
 This: between 90-104(average: 94.91 stddev:+/-2.1)

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test02.c
[2] https://github.com/rustyrussell/stats

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
bulk- Fallback                  - Bulk API
  1 -  64 cycles(tsc) 16.144 ns - 47 cycles(tsc) 11.931 - improved 26.6%
  2 -  57 cycles(tsc) 14.397 ns - 29 cycles(tsc)  7.368 - improved 49.1%
  3 -  55 cycles(tsc) 13.797 ns - 24 cycles(tsc)  6.003 - improved 56.4%
  4 -  53 cycles(tsc) 13.500 ns - 22 cycles(tsc)  5.543 - improved 58.5%
  8 -  52 cycles(tsc) 13.008 ns - 20 cycles(tsc)  5.047 - improved 61.5%
 16 -  51 cycles(tsc) 12.763 ns - 20 cycles(tsc)  5.015 - improved 60.8%
 30 -  50 cycles(tsc) 12.743 ns - 20 cycles(tsc)  5.062 - improved 60.0%
 32 -  51 cycles(tsc) 12.908 ns - 20 cycles(tsc)  5.089 - improved 60.8%
 34 -  87 cycles(tsc) 21.936 ns - 28 cycles(tsc)  7.006 - improved 67.8%
 48 -  79 cycles(tsc) 19.840 ns - 31 cycles(tsc)  7.755 - improved 60.8%
 64 -  86 cycles(tsc) 21.669 ns - 68 cycles(tsc) 17.203 - improved 20.9%
128 - 101 cycles(tsc) 25.340 ns - 72 cycles(tsc) 18.195 - improved 28.7%
158 - 112 cycles(tsc) 28.152 ns - 73 cycles(tsc) 18.372 - improved 34.8%
250 - 110 cycles(tsc) 27.727 ns - 73 cycles(tsc) 18.430 - improved 33.6%

 mm/slub.c |  138 ++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 90 insertions(+), 48 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ce4118566761..06fef8f503a1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2762,71 +2762,113 @@ struct detached_freelist {
 	int cnt;
 };
 
-/* Note that interrupts must be enabled when calling this function. */
-void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+/*
+ * This function extract objects belonging to the same page, and
+ * builds a detached freelist directly within the given page/objects.
+ * This can happen without any need for synchronization, because the
+ * objects are owned by running process.  The freelist is build up as
+ * a single linked list in the objects.  The idea is, that this
+ * detached freelist can then be bulk transferred to the real
+ * freelist(s), but only requiring a single synchronization primitive.
+ */
+static inline int build_detached_freelist(
+	struct kmem_cache *s, size_t size, void **p,
+	struct detached_freelist *df, int start_index)
 {
-	struct kmem_cache_cpu *c;
 	struct page *page;
 	int i;
-	/* Opportunistically delay updating page->freelist, hoping
-	 * next free happen to same page.  Start building the freelist
-	 * in the page, but keep local stack ptr to freelist.  If
-	 * successful several object can be transferred to page with a
-	 * single cmpxchg_double.
-	 */
-	struct detached_freelist df = {0};
+	int lookahead = 0;
+	void *object;
 
-	local_irq_disable();
-	c = this_cpu_ptr(s->cpu_slab);
+	/* Always re-init detached_freelist */
+	do {
+		object = p[start_index];
+		if (object) {
+			/* Start new delayed freelist */
+			df->page = virt_to_head_page(object);
+			df->tail_object = object;
+			set_freepointer(s, object, NULL);
+			df->freelist = object;
+			df->cnt = 1;
+			p[start_index] = NULL; /* mark object processed */
+		} else {
+			df->page = NULL; /* Handle NULL ptr in array */
+		}
+		start_index++;
+	} while (!object && start_index < size);
 
-	for (i = 0; i < size; i++) {
-		void *object = p[i];
+	for (i = start_index; i < size; i++) {
+		object = p[i];
 
-		BUG_ON(!object);
-		/* kmem cache debug support */
-		s = cache_from_obj(s, object);
-		if (unlikely(!s))
-			goto exit;
-		slab_free_hook(s, object);
+		if (!object)
+			continue; /* Skip processed objects */
 
 		page = virt_to_head_page(object);
 
-		if (page == df.page) {
-			/* Oppotunity to delay real free */
-			set_freepointer(s, object, df.freelist);
-			df.freelist = object;
-			df.cnt++;
-		} else if (c->page == page) {
-			/* Fastpath: local CPU free */
-			set_freepointer(s, object, c->freelist);
-			c->freelist = object;
+		/* df->page is always set at this point */
+		if (page == df->page) {
+			/* Oppotunity build freelist */
+			set_freepointer(s, object, df->freelist);
+			df->freelist = object;
+			df->cnt++;
+			p[i] = NULL; /* mark object processed */
+			if (!lookahead)
+				start_index++;
 		} else {
-			/* Slowpath: Flush delayed free */
-			if (df.page) {
+			/* Limit look ahead search */
+			if (++lookahead >= 3 )
+				return start_index;
+			continue;
+		}
+	}
+	return start_index;
+}
+
+/* Note that interrupts must be enabled when calling this function. */
+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+{
+	struct kmem_cache_cpu *c;
+	int iterator = 0;
+	struct detached_freelist df;
+
+	BUG_ON(!size);
+
+	/* Per CPU ptr may change afterwards */
+	c = this_cpu_ptr(s->cpu_slab);
+
+	while (likely(iterator < size)) {
+		iterator = build_detached_freelist(s, size, p, &df, iterator);
+		if (likely(df.page)) {
+		redo:
+			if (c->page == df.page) {
+				/*
+				 * Local CPU free require disabling
+				 * IRQs.  It is possible to miss the
+				 * oppotunity and instead free to
+				 * page->freelist, but it does not
+				 * matter as page->freelist will
+				 * eventually be transferred to
+				 * c->freelist
+				 */
+				local_irq_disable();
+				c = this_cpu_ptr(s->cpu_slab); /* reload */
+				if (c->page != df.page) {
+					local_irq_enable();
+					goto redo;
+				}
+				/* Bulk transfer to CPU c->freelist */
+				set_freepointer(s, df.tail_object, c->freelist);
+				c->freelist = df.freelist;
+
 				c->tid = next_tid(c->tid);
 				local_irq_enable();
+			} else {
+				/* Bulk transfer to page->freelist */
 				__slab_free(s, df.page, df.tail_object,
 					    _RET_IP_, df.freelist, df.cnt);
-				local_irq_disable();
-				c = this_cpu_ptr(s->cpu_slab);
 			}
-			/* Start new round of delayed free */
-			df.page = page;
-			df.tail_object = object;
-			set_freepointer(s, object, NULL);
-			df.freelist = object;
-			df.cnt = 1;
 		}
 	}
-exit:
-	c->tid = next_tid(c->tid);
-	local_irq_enable();
-
-	/* Flush detached freelist */
-	if (df.page) {
-		__slab_free(s, df.page, df.tail_object,
-			    _RET_IP_, df.freelist, df.cnt);
-	}
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
