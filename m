Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5CD8F8D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 14:32:58 -0400 (EDT)
Date: Tue, 22 Mar 2011 13:32:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: slub: Add missing irq restore for the OOM path
Message-ID: <alpine.DEB.2.00.1103221332150.16870@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org


OOM path is missing the irq restore in the CONFIG_CMPXCHG_LOCAL case.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-22 13:28:06.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-22 13:30:15.000000000 -0500
@@ -1812,6 +1812,9 @@ new_slab:
 	}
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);
+#ifdef CONFIG_CMPXCHG_LOCAL
+	local_irq_restore(flags);
+#endif
 	return NULL;
 debug:
 	if (!alloc_debug_processing(s, c->page, object, addr))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
