Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id CC0E26B011C
	for <linux-mm@kvack.org>; Wed,  9 May 2012 11:10:10 -0400 (EDT)
Message-Id: <20120509151009.038672442@linux.com>
Date: Wed, 09 May 2012 10:09:54 -0500
From: cl@linux.com
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 4/9] slub: Simplify control flow in __slab_alloc()
References: <20120509150950.243797150@linux.com>
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
--- linux-2.6.orig/mm/slub.c	2012-04-10 10:33:01.818750910 -0500
+++ linux-2.6/mm/slub.c	2012-04-10 10:33:06.910750804 -0500
@@ -2272,17 +2272,15 @@ new_slab:
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
