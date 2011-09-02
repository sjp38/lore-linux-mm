Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 13F2D900147
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:47 -0400 (EDT)
Message-Id: <20110902204744.379149461@linux.com>
Date: Fri, 02 Sep 2011 15:47:06 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 09/12] slub: Run deactivate_slab with interrupts enabled
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=irq_enabled_deactivate_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

Do not enable and disable interrupts if we were called with interrupts
enabled.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-02 08:22:38.141218609 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 08:22:48.311218548 -0500
@@ -1348,10 +1348,11 @@ static struct page *allocate_slab(struct
 	struct page *page;
 	struct kmem_cache_order_objects oo = s->oo;
 	gfp_t alloc_gfp;
+	int irqs_were_disabled = irqs_disabled();
 
 	flags &= gfp_allowed_mask;
 
-	if (flags & __GFP_WAIT)
+	if (irqs_were_disabled && flags & __GFP_WAIT)
 		local_irq_enable();
 
 	flags |= s->allocflags;
@@ -1375,7 +1376,7 @@ static struct page *allocate_slab(struct
 			stat(s, ORDER_FALLBACK);
 	}
 
-	if (flags & __GFP_WAIT)
+	if (irqs_were_disabled && flags & __GFP_WAIT)
 		local_irq_disable();
 
 	if (!page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
