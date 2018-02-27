Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEA1B6B0005
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 05:23:25 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id g76so6005411lfg.1
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 02:23:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h82sor2444826lfb.70.2018.02.27.02.23.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Feb 2018 02:23:23 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC v1] mm: add the preempt check into alloc_vmap_area()
Date: Tue, 27 Feb 2018 11:22:59 +0100
Message-Id: <20180227102259.4629-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

During finding a suitable hole in the vmap_area_list
there is an explicit rescheduling check for latency reduction.
We do it, since there are workloads which are sensitive for
long (more than 1 millisecond) preemption off scenario.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 57 +++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 45 insertions(+), 12 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 673942094328..60a57752f8fc 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -325,6 +325,7 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 
 #define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
+#define VM_LAZY_FREE_DEFER	0x08
 
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
@@ -491,6 +492,20 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 		if (addr + size < addr)
 			goto overflow;
 
+		/*
+		 * Put on hold this VA preventing it from being
+		 * removed from the list because of dropping the
+		 * vmap_area_lock. It means we are save to proceed
+		 * the search after the lock is taken again if we
+		 * were scheduled out or the spin needed a break.
+		 */
+		if (gfpflags_allow_blocking(gfp_mask) &&
+				!(first->flags & VM_LAZY_FREE_DEFER)) {
+			first->flags |= VM_LAZY_FREE_DEFER;
+			cond_resched_lock(&vmap_area_lock);
+			first->flags &= ~VM_LAZY_FREE_DEFER;
+		}
+
 		if (list_is_last(&first->list, &vmap_area_list))
 			goto found;
 
@@ -586,16 +601,6 @@ static void __free_vmap_area(struct vmap_area *va)
 }
 
 /*
- * Free a region of KVA allocated by alloc_vmap_area
- */
-static void free_vmap_area(struct vmap_area *va)
-{
-	spin_lock(&vmap_area_lock);
-	__free_vmap_area(va);
-	spin_unlock(&vmap_area_lock);
-}
-
-/*
  * Clear the pagetable entries of a given vmap_area
  */
 static void unmap_vmap_area(struct vmap_area *va)
@@ -678,6 +683,7 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	struct vmap_area *va;
 	struct vmap_area *n_va;
 	bool do_free = false;
+	int va_nr_pages;
 
 	lockdep_assert_held(&vmap_purge_lock);
 
@@ -697,10 +703,19 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 
 	spin_lock(&vmap_area_lock);
 	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
-		int nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
+		if (unlikely(va->flags & VM_LAZY_FREE_DEFER)) {
+			/*
+			 * Put deferred VA back to the vmap_purge_list.
+			 * We do not need to modify vmap_lazy_nr since
+			 * the va will not be removed now.
+			 */
+			llist_add(&va->purge_list, &vmap_purge_list);
+			continue;
+		}
 
+		va_nr_pages = (va->va_end - va->va_start) >> PAGE_SHIFT;
 		__free_vmap_area(va);
-		atomic_sub(nr, &vmap_lazy_nr);
+		atomic_sub(va_nr_pages, &vmap_lazy_nr);
 		cond_resched_lock(&vmap_area_lock);
 	}
 	spin_unlock(&vmap_area_lock);
@@ -750,6 +765,24 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 }
 
 /*
+ * Free a region of KVA allocated by alloc_vmap_area
+ */
+static void free_vmap_area(struct vmap_area *va)
+{
+	bool do_lazy_free = false;
+
+	spin_lock(&vmap_area_lock);
+	if (unlikely(va->flags & VM_LAZY_FREE_DEFER))
+		do_lazy_free = true;
+	else
+		__free_vmap_area(va);
+	spin_unlock(&vmap_area_lock);
+
+	if (unlikely(do_lazy_free))
+		free_vmap_area_noflush(va);
+}
+
+/*
  * Free and unmap a vmap area
  */
 static void free_unmap_vmap_area(struct vmap_area *va)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
