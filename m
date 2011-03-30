Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 28EA38D0055
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:24:27 -0400 (EDT)
Message-Id: <20110330202424.617825534@linux.com>
Date: Wed, 30 Mar 2011 15:23:57 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubll1 15/19] slub: Disable interrupts in free_debug processing
References: <20110330202342.669400887@linux.com>
Content-Disposition: inline; filename=irqoff_in_free_debug_processing
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

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
--- linux-2.6.orig/mm/slub.c	2011-03-23 16:25:00.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-24 08:50:37.000000000 -0500
@@ -1024,6 +1024,10 @@ bad:
 static noinline int free_debug_processing(struct kmem_cache *s,
 		 struct page *page, void *object, unsigned long addr)
 {
+	unsigned long flags;
+
+	local_irq_save(flags);
+
 	if (!check_slab(s, page))
 		goto fail;
 
@@ -1059,10 +1063,12 @@ static noinline int free_debug_processin
 		set_track(s, object, TRACK_FREE, addr);
 	trace(s, page, object, 0);
 	init_object(s, object, SLUB_RED_INACTIVE);
+	local_irq_restore(flags);
 	return 1;
 
 fail:
 	slab_fix(s, "Object at 0x%p not freed", object);
+	local_irq_restore(flags);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
