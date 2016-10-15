Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 09C836B0038
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 12:46:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so143205104pfj.6
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 09:46:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id h8si19420576pao.135.2016.10.15.09.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 09:46:18 -0700 (PDT)
Date: Sat, 15 Oct 2016 09:46:13 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3] mm: vmalloc: Replace purge_lock spinlock with atomic
 refcount
Message-ID: <20161015164613.GA26079@infradead.org>
References: <1476535979-27467-1-git-send-email-joelaf@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476535979-27467-1-git-send-email-joelaf@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, Chris Wilson <chris@chris-wilson.co.uk>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

atomic_t magic for llocking is always a bit iffy.

The real question is: what is purge_lock even supposed to protect?

 - purge_fragmented_blocks seems to have it's own local protection.
 - all handling of of valist is implicity protected by the atomic
   list deletion in llist_del_all
 - the manipulation of vmap_lazy_nr already is atomic
 - flush_tlb_kernel_range should not require any synchronization
 - the calls to __free_vmap_area are sychronized by vmap_area_lock
 - *start and *end always point to on-stack variables, never mind
   that the caller never looks at the updated values anyway.

And once we use the cmpxchg in llist_del_all as the effectit protection
against multiple concurrent callers (slightly sloopy) there just be
nothing else to synchronize.

And while we're at it the code structure here is totally grotty.

So what about the patch below (only boot tested):

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f2481cb..c2b9a98 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -613,82 +613,43 @@ void set_iounmap_nonlazy(void)
 	atomic_set(&vmap_lazy_nr, lazy_max_pages()+1);
 }
 
-/*
- * Purges all lazily-freed vmap areas.
- *
- * If sync is 0 then don't purge if there is already a purge in progress.
- * If force_flush is 1, then flush kernel TLBs between *start and *end even
- * if we found no lazy vmap areas to unmap (callers can use this to optimise
- * their own TLB flushing).
- * Returns with *start = min(*start, lowest purged address)
- *              *end = max(*end, highest purged address)
- */
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
-
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
-
-	if (nr || force_flush)
-		flush_tlb_kernel_range(*start, *end);
-
-	if (nr) {
-		spin_lock(&vmap_area_lock);
-		llist_for_each_entry_safe(va, n_va, valist, purge_list)
-			__free_vmap_area(va);
-		spin_unlock(&vmap_area_lock);
-	}
-	spin_unlock(&purge_lock);
-}
+	if (!nr)
+		return false;
 
-/*
- * Kick off a purge of the outstanding lazy areas. Don't bother if somebody
- * is already purging.
- */
-static void try_purge_vmap_area_lazy(void)
-{
-	unsigned long start = ULONG_MAX, end = 0;
+	atomic_sub(nr, &vmap_lazy_nr);
 
-	__purge_vmap_area_lazy(&start, &end, 0, 0);
+	spin_lock(&vmap_area_lock);
+	llist_for_each_entry_safe(va, n_va, valist, purge_list)
+		__free_vmap_area(va);
+	spin_unlock(&vmap_area_lock);
+	return true;
 }
 
 /*
- * Kick off a purge of the outstanding lazy areas.
+ * Kick off a purge of the outstanding lazy areas, including the fragment
+ * blocks on the per-cpu lists.
  */
 static void purge_vmap_area_lazy(void)
 {
-	unsigned long start = ULONG_MAX, end = 0;
+	purge_fragmented_blocks_allcpus();
+	__purge_vmap_area_lazy(ULONG_MAX, 0);
 
-	__purge_vmap_area_lazy(&start, &end, 1, 0);
 }
 
 /*
@@ -706,8 +667,12 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 	/* After this point, we may free va at any time */
 	llist_add(&va->purge_list, &vmap_purge_list);
 
+	/*
+	 * Kick off a purge of the outstanding lazy areas. Don't bother to
+	 * to purge the per-cpu lists of fragmented blocks.
+	 */
 	if (unlikely(nr_lazy > lazy_max_pages()))
-		try_purge_vmap_area_lazy();
+		__purge_vmap_area_lazy(ULONG_MAX, 0);
 }
 
 /*
@@ -1094,7 +1059,9 @@ void vm_unmap_aliases(void)
 		rcu_read_unlock();
 	}
 
-	__purge_vmap_area_lazy(&start, &end, 1, flush);
+	purge_fragmented_blocks_allcpus();
+	if (!__purge_vmap_area_lazy(start, end) && flush)
+		flush_tlb_kernel_range(start, end);
 }
 EXPORT_SYMBOL_GPL(vm_unmap_aliases);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
