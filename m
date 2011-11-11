Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0C6706B0080
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:31 -0500 (EST)
Message-Id: <20111111200728.365224076@linux.com>
Date: Fri, 11 Nov 2011 14:07:16 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 05/18] slub: Simplify control flow in __slab_alloc()
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=min_cleaups
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

Simplify control flow.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-09 11:11:22.381541568 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:11:25.881561697 -0600
@@ -2219,16 +2219,16 @@ new_slab:
 
 	freelist = get_partial(s, gfpflags, node, c);
 
-	if (unlikely(!freelist)) {
+	if (!freelist)
 		freelist = new_slab_objects(s, gfpflags, node, &c);
 
-		if (unlikely(!freelist)) {
-			if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
-				slab_out_of_memory(s, gfpflags, node);
-
-			local_irq_restore(flags);
-			return NULL;
-		}
+
+	if (unlikely(!freelist)) {
+		if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
+			slab_out_of_memory(s, gfpflags, node);
+
+		local_irq_restore(flags);
+		return NULL;
 	}
 
 	if (likely(!kmem_cache_debug(s)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
