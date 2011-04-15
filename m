Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A8FF8900094
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:06 -0400 (EDT)
Message-Id: <20110415201304.230803174@linux.com>
Date: Fri, 15 Apr 2011 15:13:02 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: Disable interrupts in free_debug processing
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=irqoff_in_free_debug_processing
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

We will be calling free_debug_processing with interrupts disabled
in some case when the later patches are applied. Some of the
functions called by free_debug_processing expect interrupts to be
off.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 13:15:04.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 13:15:06.000000000 -0500
@@ -1023,6 +1023,10 @@ bad:
 static noinline int free_debug_processing(struct kmem_cache *s,
 		 struct page *page, void *object, unsigned long addr)
 {
+	unsigned long flags;
+
+	local_irq_save(flags);
+
 	slab_lock(page);
 
 	if (!check_slab(s, page))
@@ -1061,11 +1065,13 @@ static noinline int free_debug_processin
 	trace(s, page, object, 0);
 	init_object(s, object, SLUB_RED_INACTIVE);
 	slab_unlock(page);
+	local_irq_restore(flags);
 	return 1;
 
 fail:
 	slab_fix(s, "Object at 0x%p not freed", object);
 	slab_unlock(page);
+	local_irq_restore(flags);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
