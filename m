Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D165F6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:03:21 -0400 (EDT)
Date: Fri, 12 Jun 2009 12:03:22 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or suspending
In-Reply-To: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, npiggin@suse.de, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

As explained by Benjamin Herrenschmidt:

  Oh and btw, your patch alone doesn't fix powerpc, because it's missing
  a whole bunch of GFP_KERNEL's in the arch code... You would have to
  grep the entire kernel for things that check slab_is_available() and
  even then you'll be missing some.

  For example, slab_is_available() didn't always exist, and so in the
  early days on powerpc, we used a mem_init_done global that is set form
  mem_init() (not perfect but works in practice). And we still have code
  using that to do the test.

Therefore, ignore __GFP_WAIT in the slab allocators if we're booting or
suspending.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
v1 -> v2: fix up some missing cases pointed out by BenH

 mm/slab.c |   19 ++++++++++++++++++-
 mm/slub.c |   24 ++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index f46b65d..5119c22 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2812,6 +2812,15 @@ static int cache_grow(struct kmem_cache *cachep,
 
 	offset *= cachep->colour_off;
 
+	/*
+	 * Lets not wait if we're booting up or suspending even if the user
+	 * asks for it.
+	 */
+	if (system_state != SYSTEM_RUNNING)
+		local_flags &= ~__GFP_WAIT;
+
+	might_sleep_if(local_flags & __GFP_WAIT);
+
 	if (local_flags & __GFP_WAIT)
 		local_irq_enable();
 
@@ -3073,7 +3082,6 @@ alloc_done:
 static inline void cache_alloc_debugcheck_before(struct kmem_cache *cachep,
 						gfp_t flags)
 {
-	might_sleep_if(flags & __GFP_WAIT);
 #if DEBUG
 	kmem_flagcheck(cachep, flags);
 #endif
@@ -3238,6 +3246,15 @@ retry:
 
 	if (!obj) {
 		/*
+		 * Lets not wait if we're booting up or suspending even if the user
+		 * asks for it.
+		 */
+		if (system_state != SYSTEM_RUNNING)
+			local_flags &= ~__GFP_WAIT;
+
+		might_sleep_if(local_flags & __GFP_WAIT);
+
+		/*
 		 * This allocation will be performed within the constraints
 		 * of the current cpuset / memory policy requirements.
 		 * We may trigger various forms of reclaim on the allowed
diff --git a/mm/slub.c b/mm/slub.c
index 3964d3c..6387c19 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1548,6 +1548,20 @@ new_slab:
 		goto load_freelist;
 	}
 
+	/*
+	 * Lets not wait if we're booting up or suspending even if the user
+	 * asks for it.
+	 */
+	if (system_state != SYSTEM_RUNNING)
+		gfpflags &= ~__GFP_WAIT;
+
+	/*
+	 * Now that we really know whether or not we're going to sleep or not,
+	 * lets do our debugging checks.
+	 */
+	lockdep_trace_alloc(gfpflags);
+	might_sleep_if(gfpflags & __GFP_WAIT);
+
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 
@@ -1595,8 +1609,7 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
 	unsigned long flags;
 	unsigned int objsize;
 
-	lockdep_trace_alloc(gfpflags);
-	might_sleep_if(gfpflags & __GFP_WAIT);
+	lockdep_trace_alloc(gfpflags & ~__GFP_WAIT);
 
 	if (should_failslab(s->objsize, gfpflags))
 		return NULL;
@@ -2607,6 +2620,13 @@ static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
 	if (s)
 		return s;
 
+	/*
+	 * Lets not wait if we're booting up or suspending even if the user
+	 * asks for it.
+	 */
+	if (system_state != SYSTEM_RUNNING)
+		flags &= ~__GFP_WAIT;
+
 	/* Dynamically create dma cache */
 	if (flags & __GFP_WAIT)
 		down_write(&slub_lock);
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
