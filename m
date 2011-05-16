Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D1284900116
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:31 -0400 (EDT)
Message-Id: <20110516202629.279893737@linux.com>
Date: Mon, 16 May 2011 15:26:19 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 14/25] slub: Disable interrupts in free_debug processing
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=irqoff_in_free_debug_processing
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

We will be calling free_debug_processing with interrupts disabled
in some case when the later patches are applied. Some of the
functions called by free_debug_processing expect interrupts to be
off.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-12 16:19:44.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-05-12 16:19:56.000000000 -0500
@@ -1035,6 +1035,10 @@ bad:
 static noinline int free_debug_processing(struct kmem_cache *s,
 		 struct page *page, void *object, unsigned long addr)
 {
+	unsigned long flags;
+	int rc = 0;
+
+	local_irq_save(flags);
 	slab_lock(page);
 
 	if (!check_slab(s, page))
@@ -1051,7 +1055,7 @@ static noinline int free_debug_processin
 	}
 
 	if (!check_object(s, page, object, SLUB_RED_ACTIVE))
-		return 0;
+		goto out;
 
 	if (unlikely(s != page->slab)) {
 		if (!PageSlab(page)) {
@@ -1072,13 +1076,15 @@ static noinline int free_debug_processin
 		set_track(s, object, TRACK_FREE, addr);
 	trace(s, page, object, 0);
 	init_object(s, object, SLUB_RED_INACTIVE);
+	rc = 1;
+out:
 	slab_unlock(page);
-	return 1;
+	local_irq_restore(flags);
+	return rc;
 
 fail:
 	slab_fix(s, "Object at 0x%p not freed", object);
-	slab_unlock(page);
-	return 0;
+	goto out;
 }
 
 static int __init setup_slub_debug(char *str)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
