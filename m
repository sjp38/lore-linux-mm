Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 185706B0412
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:04:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so252974602pgd.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:04:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id p5si8179681pgk.156.2016.11.18.05.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 05:04:14 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 03/10] mm: refactor __purge_vmap_area_lazy
Date: Fri, 18 Nov 2016 14:03:49 +0100
Message-Id: <1479474236-4139-4-git-send-email-hch@lst.de>
In-Reply-To: <1479474236-4139-1-git-send-email-hch@lst.de>
References: <1479474236-4139-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Move the purge_lock synchronization to the callers, move the call to
purge_fragmented_blocks_allcpus at the beginning of the function to
the callers that need it, move the force_flush behavior to the caller
that needs it, and pass start and end by value instead of by reference.

No change in behavior.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Tested-by: Jisheng Zhang <jszhang@marvell.com>
---
 mm/vmalloc.c | 80 ++++++++++++++++++++++++++----------------------------------
 1 file changed, 35 insertions(+), 45 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cf1a5ab..a4e2cec 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -601,6 +601,13 @@ static unsigned long lazy_max_pages(void)
 
 static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
 
+/*
+ * Serialize vmap purging.  There is no actual criticial section protected
+ * by this look, but we want to avoid concurrent calls for performance
+ * reasons and to make the pcpu_get_vm_areas more deterministic.
+ */
+static DEFINE_SPINLOCK(vmap_purge_lock);
+
 /* for per-CPU blocks */
 static void purge_fragmented_blocks_allcpus(void);
 
@@ -615,59 +622,36 @@ void set_iounmap_nonlazy(void)
 
 /*
  * Purges all lazily-freed vmap areas.
- *
- * If sync is 0 then don't purge if there is already a purge in progress.
- * If force_flush is 1, then flush kernel TLBs between *start and *end even
- * if we found no lazy vmap areas to unmap (callers can use this to optimise
- * their own TLB flushing).
- * Returns with *start = min(*start, lowest purged address)
- *              *end = max(*end, highest purged address)
  */
-static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
-					int sync, int force_flush)
+static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 {
-	static DEFINE_SPINLOCK(purge_lock);
 	struct llist_node *valist;
 	struct vmap_area *va;
 	struct vmap_area *n_va;
 	int nr = 0;
 
-	/*
-	 * If sync is 0 but force_flush is 1, we'll go sync anyway but callers
-	 * should not expect such behaviour. This just simplifies locking for
-	 * the case that isn't actually used at the moment anyway.
-	 */
-	if (!sync && !force_flush) {
-		if (!spin_trylock(&purge_lock))
-			return;
-	} else
-		spin_lock(&purge_lock);
-
-	if (sync)
-		purge_fragmented_blocks_allcpus();
+	lockdep_assert_held(&vmap_purge_lock);
 
 	valist = llist_del_all(&vmap_purge_list);
 	llist_for_each_entry(va, valist, purge_list) {
-		if (va->va_start < *start)
-			*start = va->va_start;
-		if (va->va_end > *end)
-			*end = va->va_end;
+		if (va->va_start < start)
+			start = va->va_start;
+		if (va->va_end > end)
+			end = va->va_end;
 		nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
 	}
 
-	if (nr)
-		atomic_sub(nr, &vmap_lazy_nr);
+	if (!nr)
+		return false;
 
-	if (nr || force_flush)
-		flush_tlb_kernel_range(*start, *end);
+	atomic_sub(nr, &vmap_lazy_nr);
+	flush_tlb_kernel_range(start, end);
 
-	if (nr) {
-		spin_lock(&vmap_area_lock);
-		llist_for_each_entry_safe(va, n_va, valist, purge_list)
-			__free_vmap_area(va);
-		spin_unlock(&vmap_area_lock);
-	}
-	spin_unlock(&purge_lock);
+	spin_lock(&vmap_area_lock);
+	llist_for_each_entry_safe(va, n_va, valist, purge_list)
+		__free_vmap_area(va);
+	spin_unlock(&vmap_area_lock);
+	return true;
 }
 
 /*
@@ -676,9 +660,10 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
  */
 static void try_purge_vmap_area_lazy(void)
 {
-	unsigned long start = ULONG_MAX, end = 0;
-
-	__purge_vmap_area_lazy(&start, &end, 0, 0);
+	if (spin_trylock(&vmap_purge_lock)) {
+		__purge_vmap_area_lazy(ULONG_MAX, 0);
+		spin_unlock(&vmap_purge_lock);
+	}
 }
 
 /*
@@ -686,9 +671,10 @@ static void try_purge_vmap_area_lazy(void)
  */
 static void purge_vmap_area_lazy(void)
 {
-	unsigned long start = ULONG_MAX, end = 0;
-
-	__purge_vmap_area_lazy(&start, &end, 1, 0);
+	spin_lock(&vmap_purge_lock);
+	purge_fragmented_blocks_allcpus();
+	__purge_vmap_area_lazy(ULONG_MAX, 0);
+	spin_unlock(&vmap_purge_lock);
 }
 
 /*
@@ -1075,7 +1061,11 @@ void vm_unmap_aliases(void)
 		rcu_read_unlock();
 	}
 
-	__purge_vmap_area_lazy(&start, &end, 1, flush);
+	spin_lock(&vmap_purge_lock);
+	purge_fragmented_blocks_allcpus();
+	if (!__purge_vmap_area_lazy(start, end) && flush)
+		flush_tlb_kernel_range(start, end);
+	spin_unlock(&vmap_purge_lock);
 }
 EXPORT_SYMBOL_GPL(vm_unmap_aliases);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
