Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EA115660020
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:27 -0400 (EDT)
Message-Id: <20100804024527.315890239@linux.com>
Date: Tue, 03 Aug 2010 21:45:20 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 06/23] slub: Check kasprintf results in kmem_cache_init()
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=slub_check_kasprintf_result
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Small allocations may fail during slab bringup which is fatal. Add a BUG_ON()
so that we fail immediately rather than failing later during sysfs
processing.

CC: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-06 15:12:14.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-06 15:13:48.000000000 -0500
@@ -3118,9 +3118,12 @@ void __init kmem_cache_init(void)
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */
-	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++)
-		kmalloc_caches[i]. name =
-			kasprintf(GFP_NOWAIT, "kmalloc-%d", 1 << i);
+	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
+		char *s = kasprintf(GFP_NOWAIT, "kmalloc-%d", 1 << i);
+
+		BUG_ON(!s);
+		kmalloc_caches[i].name = s;
+	}
 
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
