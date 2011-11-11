Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 496A46B0073
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:34 -0500 (EST)
Message-Id: <20111111200731.037659520@linux.com>
Date: Fri, 11 Nov 2011 14:07:20 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 09/18] slub: Run deactivate_slab with interrupts enabled
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=irq_enabled_deactivate_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Do not enable and disable interrupts if we were called with interrupts
enabled.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 11:11:45.341673526 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:11:48.831693571 -0600
@@ -1279,10 +1279,11 @@ static struct page *allocate_slab(struct
 	struct page *page;
 	struct kmem_cache_order_objects oo = s->oo;
 	gfp_t alloc_gfp;
+	int irqs_were_disabled = irqs_disabled();
 
 	flags &= gfp_allowed_mask;
 
-	if (flags & __GFP_WAIT)
+	if (irqs_were_disabled && flags & __GFP_WAIT)
 		local_irq_enable();
 
 	flags |= s->allocflags;
@@ -1306,7 +1307,7 @@ static struct page *allocate_slab(struct
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
