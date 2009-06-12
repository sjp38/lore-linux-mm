Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 55F186B005D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 04:13:19 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:13:40 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 2/2] slab,slub: ignore __GFP_WAIT if we're booting or suspending
Message-ID: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, npiggin@suse.de, benh@kernel.crashing.org
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
 mm/slab.c |    7 +++++++
 mm/slub.c |    7 +++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index f46b65d..4b932e0 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2812,6 +2812,13 @@ static int cache_grow(struct kmem_cache *cachep,
 
 	offset *= cachep->colour_off;
 
+	/*
+	 * Lets not wait if we're booting up or suspending even if the user
+	 * asks for it.
+	 */
+	if (system_state != SYSTEM_RUNNING)
+		local_flags &= ~__GFP_WAIT;
+
 	if (local_flags & __GFP_WAIT)
 		local_irq_enable();
 
diff --git a/mm/slub.c b/mm/slub.c
index 3964d3c..053ea3e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1548,6 +1548,13 @@ new_slab:
 		goto load_freelist;
 	}
 
+	/*
+	 * Lets not wait if we're booting up or suspending even if the user
+	 * asks for it.
+	 */
+	if (system_state != SYSTEM_RUNNING)
+		gfpflags &= ~__GFP_WAIT;
+
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
