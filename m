Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 633A56B0068
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 15:17:09 -0500 (EST)
Message-Id: <20120123201707.746733370@linux.com>
Date: Mon, 23 Jan 2012 14:16:50 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 4/9] slub: Simplify control flow in __slab_alloc()
References: <20120123201646.924319545@linux.com>
Content-Disposition: inline; filename=control_flow_simplify
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Simplify control flow a bit avoiding nesting.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-01-13 08:47:17.158748674 -0600
+++ linux-2.6/mm/slub.c	2012-01-13 08:47:20.490748604 -0600
@@ -2247,17 +2247,15 @@ new_slab:
 	/* Then do expensive stuff like retrieving pages from the partial lists */
 	freelist = get_partial(s, gfpflags, node, c);
 
-	if (unlikely(!freelist)) {
-
+	if (!freelist)
 		freelist = new_slab_objects(s, gfpflags, node, &c);
 
-		if (unlikely(!freelist)) {
-			if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
-				slab_out_of_memory(s, gfpflags, node);
+	if (unlikely(!freelist)) {
+		if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
+			slab_out_of_memory(s, gfpflags, node);
 
-			local_irq_restore(flags);
-			return NULL;
-		}
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
