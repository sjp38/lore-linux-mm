Message-Id: <20081110133841.097024000@suse.de>
References: <20081110133515.011510000@suse.de>
Date: Tue, 11 Nov 2008 00:35:21 +1100
From: npiggin@suse.de
Subject: [patch 6/7] mm: vmalloc use mutex for purge
Content-Disposition: inline; filename=mm-vmalloc-mutex.patch
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com
List-ID: <linux-mm.kvack.org>

The vmalloc purge lock can be a mutex so we can sleep while a purge is going
on (purge involves a global kernel TLB invalidate, so it can take quite a
while).
 
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -14,6 +14,7 @@
 #include <linux/highmem.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/mutex.h>
 #include <linux/interrupt.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -473,7 +474,7 @@ static atomic_t vmap_lazy_nr = ATOMIC_IN
 static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
 					int sync, int force_flush)
 {
-	static DEFINE_SPINLOCK(purge_lock);
+	static DEFINE_MUTEX(purge_lock);
 	LIST_HEAD(valist);
 	struct vmap_area *va;
 	int nr = 0;
@@ -484,10 +485,10 @@ static void __purge_vmap_area_lazy(unsig
 	 * the case that isn't actually used at the moment anyway.
 	 */
 	if (!sync && !force_flush) {
-		if (!spin_trylock(&purge_lock))
+		if (!mutex_trylock(&purge_lock))
 			return;
 	} else
-		spin_lock(&purge_lock);
+		mutex_lock(&purge_lock);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(va, &vmap_area_list, list) {
@@ -519,7 +520,7 @@ static void __purge_vmap_area_lazy(unsig
 			__free_vmap_area(va);
 		spin_unlock(&vmap_area_lock);
 	}
-	spin_unlock(&purge_lock);
+	mutex_unlock(&purge_lock);
 }
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
