Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A58206B0264
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 11:17:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r16so79709209pfg.4
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 08:17:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id da3si2598262pab.317.2016.10.22.08.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Oct 2016 08:17:43 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 7/7] mm: add preempt points into __purge_vmap_area_lazy
Date: Sat, 22 Oct 2016 17:17:20 +0200
Message-Id: <1477149440-12478-8-git-send-email-hch@lst.de>
In-Reply-To: <1477149440-12478-1-git-send-email-hch@lst.de>
References: <1477149440-12478-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

From: Joel Fernandes <joelaf@google.com>

Use cond_resched_lock to avoid holding the vmap_area_lock for a
potentially long time and thus creating bad latencies for various
workloads.

Signed-off-by: Joel Fernandes <joelaf@google.com>
[hch: split from a larger patch by Joel, wrote the crappy changelog]
Signed-off-by: Christoph Hellwig <hch@lst.de>
Tested-by: Jisheng Zhang <jszhang@marvell.com>
---
 mm/vmalloc.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 23d6797..6c8b921 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -628,7 +628,7 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	struct llist_node *valist;
 	struct vmap_area *va;
 	struct vmap_area *n_va;
-	int nr = 0;
+	bool do_free = false;
 
 	lockdep_assert_held(&vmap_purge_lock);
 
@@ -638,18 +638,22 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 			start = va->va_start;
 		if (va->va_end > end)
 			end = va->va_end;
-		nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
+		do_free = true;
 	}
 
-	if (!nr)
+	if (!do_free)
 		return false;
 
-	atomic_sub(nr, &vmap_lazy_nr);
 	flush_tlb_kernel_range(start, end);
 
 	spin_lock(&vmap_area_lock);
-	llist_for_each_entry_safe(va, n_va, valist, purge_list)
+	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
+		int nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
+
 		__free_vmap_area(va);
+		atomic_sub(nr, &vmap_lazy_nr);
+		cond_resched_lock(&vmap_area_lock);
+	}
 	spin_unlock(&vmap_area_lock);
 	return true;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
