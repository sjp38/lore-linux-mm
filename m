Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E63666B03DC
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:19:03 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so9590985wme.5
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:19:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw10si1844334wjc.41.2016.11.18.01.17.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 01:17:30 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 20/20] dax: Clear dirty entry tags on cache flush
Date: Fri, 18 Nov 2016 10:17:24 +0100
Message-Id: <1479460644-25076-21-git-send-email-jack@suse.cz>
In-Reply-To: <1479460644-25076-1-git-send-email-jack@suse.cz>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>

Currently we never clear dirty tags in DAX mappings and thus address
ranges to flush accumulate. Now that we have locking of radix tree
entries, we have all the locking necessary to reliably clear the radix
tree dirty tag when flushing caches for corresponding address range.
Similarly to page_mkclean() we also have to write-protect pages to get a
page fault when the page is next written to so that we can mark the
entry dirty again.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 64 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index d64465584f4c..cafd5597434b 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -31,6 +31,7 @@
 #include <linux/vmstat.h>
 #include <linux/pfn_t.h>
 #include <linux/sizes.h>
+#include <linux/mmu_notifier.h>
 #include <linux/iomap.h>
 #include "internal.h"
 
@@ -613,6 +614,59 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 	return new_entry;
 }
 
+static inline unsigned long
+pgoff_address(pgoff_t pgoff, struct vm_area_struct *vma)
+{
+	unsigned long address;
+
+	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+	return address;
+}
+
+/* Walk all mappings of a given index of a file and writeprotect them */
+static void dax_mapping_entry_mkclean(struct address_space *mapping,
+				      pgoff_t index, unsigned long pfn)
+{
+	struct vm_area_struct *vma;
+	pte_t *ptep;
+	pte_t pte;
+	spinlock_t *ptl;
+	bool changed;
+
+	i_mmap_lock_read(mapping);
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, index, index) {
+		unsigned long address;
+
+		cond_resched();
+
+		if (!(vma->vm_flags & VM_SHARED))
+			continue;
+
+		address = pgoff_address(index, vma);
+		changed = false;
+		if (follow_pte(vma->vm_mm, address, &ptep, &ptl))
+			continue;
+		if (pfn != pte_pfn(*ptep))
+			goto unlock;
+		if (!pte_dirty(*ptep) && !pte_write(*ptep))
+			goto unlock;
+
+		flush_cache_page(vma, address, pfn);
+		pte = ptep_clear_flush(vma, address, ptep);
+		pte = pte_wrprotect(pte);
+		pte = pte_mkclean(pte);
+		set_pte_at(vma->vm_mm, address, ptep, pte);
+		changed = true;
+unlock:
+		pte_unmap_unlock(ptep, ptl);
+
+		if (changed)
+			mmu_notifier_invalidate_page(vma->vm_mm, address);
+	}
+	i_mmap_unlock_read(mapping);
+}
+
 static int dax_writeback_one(struct block_device *bdev,
 		struct address_space *mapping, pgoff_t index, void *entry)
 {
@@ -686,7 +740,17 @@ static int dax_writeback_one(struct block_device *bdev,
 		goto unmap;
 	}
 
+	dax_mapping_entry_mkclean(mapping, index, pfn_t_to_pfn(dax.pfn));
 	wb_cache_pmem(dax.addr, dax.size);
+	/*
+	 * After we have flushed the cache, we can clear the dirty tag. There
+	 * cannot be new dirty data in the pfn after the flush has completed as
+	 * the pfn mappings are writeprotected and fault waits for mapping
+	 * entry lock.
+	 */
+	spin_lock_irq(&mapping->tree_lock);
+	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_DIRTY);
+	spin_unlock_irq(&mapping->tree_lock);
  unmap:
 	dax_unmap_atomic(bdev, &dax);
 	put_locked_mapping_entry(mapping, index, entry);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
