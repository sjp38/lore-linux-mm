Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f54.google.com (mail-vn0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0F544900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 06:32:32 -0400 (EDT)
Received: by vnbf7 with SMTP id f7so4505032vnb.7
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 03:32:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id oo12si6407846vdb.27.2015.06.04.03.32.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 03:32:31 -0700 (PDT)
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH] slub: RFC: Improving SLUB performance with 38% on
	NO-PREEMPT
Date: Thu, 04 Jun 2015 12:31:59 +0200
Message-ID: <20150604103159.4744.75870.stgit@ivy>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, netdev@vger.kernel.org

This patch improves performance of SLUB allocator fastpath with 38% by
avoiding the call to this_cpu_cmpxchg_double() for NO-PREEMPT kernels.

Reviewers please point out why this change is wrong, as such a large
improvement should not be possible ;-)

My primarily motivation for this patch is to understand and
microbenchmark the MM-layer of the kernel, due to an increasing demand
from the networking stack.

This "microbenchmark" is merely to demonstrate the cost of the
instruction CMPXCHG16B (without LOCK prefix).

My microbench is avail on github[1] (reused "qmempool_bench").

The fastpath-reuse (alloc+free cost) (CPU E5-2695):
 * 47 cycles(tsc) - 18.948 ns  (normal with this_cpu_cmpxchg_double)
 * 29 cycles(tsc) - 11.791 ns  (with patch)

Thus, the difference deduct the cost of CMPXCHG16B
 * Total saved 18 cycles - 7.157ns
 * for two CMPXCHG16B (alloc+free): per-inst saved 9 cycles - 3.579ns
 * http://instlatx64.atw.hu/ says 9 cycles cost of CMPXCHG16B

This also shows that the cost of this_cpu_cmpxchg_double() in SLUB is
approx 38% of fast-path cost.

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/qmempool_bench.c

The cunning reviewer would also like to know the cost of disabling
interrupts, on this CPU. Here it is interesting to see how the
save/restore variant is significantly more expensive:

Cost of local IRQ toggling (CPU E5-2695):
 *  local_irq_{disable,enable}:  7 cycles(tsc) -  2.861 ns
 *  local_irq_{save,restore}  : 37 cycles(tsc) - 14.846 ns

With the additional overhead of local_irq_{disable,enable}, there
would still be a saving of 11 cycles (out of 47) 23%.
---

 mm/slub.c |   52 +++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 54c0876..b31991f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2489,13 +2489,32 @@ redo:
 		 * against code executing on this cpu *not* from access by
 		 * other cpus.
 		 */
-		if (unlikely(!this_cpu_cmpxchg_double(
-				s->cpu_slab->freelist, s->cpu_slab->tid,
-				object, tid,
-				next_object, next_tid(tid)))) {
-
-			note_cmpxchg_failure("slab_alloc", s, tid);
-			goto redo;
+		if (IS_ENABLED(CONFIG_PREEMPT)) {
+			if (unlikely(!this_cpu_cmpxchg_double(
+					s->cpu_slab->freelist, s->cpu_slab->tid,
+					object, tid,
+					next_object, next_tid(tid)))) {
+
+				note_cmpxchg_failure("slab_alloc", s, tid);
+				goto redo;
+			}
+		} else {
+			// HACK - On a NON-PREEMPT cmpxchg is not necessary(?)
+			__this_cpu_write(s->cpu_slab->tid, next_tid(tid));
+			__this_cpu_write(s->cpu_slab->freelist, next_object);
+		/*
+		 * Q: What happens in-case called from interrupt handler?
+		 *
+		 * If we need to disable (local) IRQs then most of the
+		 * saving is lost.  E.g. the local_irq_{save,restore}
+		 * is too costly.
+		 *
+		 * Saved (alloc+free): 18 cycles - 7.157ns
+		 *
+		 * Cost of (CPU E5-2695):
+		 *  local_irq_{disable,enable}:  7 cycles(tsc) -  2.861 ns
+		 *  local_irq_{save,restore}  : 37 cycles(tsc) - 14.846 ns
+		 */
 		}
 		prefetch_freepointer(s, next_object);
 		stat(s, ALLOC_FASTPATH);
@@ -2726,14 +2745,21 @@ redo:
 	if (likely(page == c->page)) {
 		set_freepointer(s, object, c->freelist);
 
-		if (unlikely(!this_cpu_cmpxchg_double(
-				s->cpu_slab->freelist, s->cpu_slab->tid,
-				c->freelist, tid,
-				object, next_tid(tid)))) {
+		if (IS_ENABLED(CONFIG_PREEMPT)) {
+			if (unlikely(!this_cpu_cmpxchg_double(
+					s->cpu_slab->freelist, s->cpu_slab->tid,
+					c->freelist, tid,
+					object, next_tid(tid)))) {
 
-			note_cmpxchg_failure("slab_free", s, tid);
-			goto redo;
+				note_cmpxchg_failure("slab_free", s, tid);
+				goto redo;
+			}
+		} else {
+			// HACK - On a NON-PREEMPT cmpxchg is not necessary(?)
+			__this_cpu_write(s->cpu_slab->tid, next_tid(tid));
+			__this_cpu_write(s->cpu_slab->freelist, object);
 		}
+
 		stat(s, FREE_FASTPATH);
 	} else
 		__slab_free(s, page, x, addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
