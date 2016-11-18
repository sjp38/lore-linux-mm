Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC916B03DE
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:19:05 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so9637066wma.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:19:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si6660058wjk.289.2016.11.18.01.17.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 01:17:30 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 19/20] dax: Protect PTE modification on WP fault by radix tree entry lock
Date: Fri, 18 Nov 2016 10:17:23 +0100
Message-Id: <1479460644-25076-20-git-send-email-jack@suse.cz>
In-Reply-To: <1479460644-25076-1-git-send-email-jack@suse.cz>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>

Currently PTE gets updated in wp_pfn_shared() after dax_pfn_mkwrite()
has released corresponding radix tree entry lock. When we want to
writeprotect PTE on cache flush, we need PTE modification to happen
under radix tree entry lock to ensure consistent updates of PTE and radix
tree (standard faults use page lock to ensure this consistency). So move
update of PTE bit into dax_pfn_mkwrite().

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c    | 22 ++++++++++++++++------
 mm/memory.c |  2 +-
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 2d317328ae90..d64465584f4c 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -782,17 +782,27 @@ int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct file *file = vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
-	void *entry;
+	void *entry, **slot;
 	pgoff_t index = vmf->pgoff;
 
 	spin_lock_irq(&mapping->tree_lock);
-	entry = get_unlocked_mapping_entry(mapping, index, NULL);
-	if (!entry || !radix_tree_exceptional_entry(entry))
-		goto out;
+	entry = get_unlocked_mapping_entry(mapping, index, &slot);
+	if (!entry || !radix_tree_exceptional_entry(entry)) {
+		if (entry)
+			put_unlocked_mapping_entry(mapping, index, entry);
+		spin_unlock_irq(&mapping->tree_lock);
+		return VM_FAULT_NOPAGE;
+	}
 	radix_tree_tag_set(&mapping->page_tree, index, PAGECACHE_TAG_DIRTY);
-	put_unlocked_mapping_entry(mapping, index, entry);
-out:
+	entry = lock_slot(mapping, slot);
 	spin_unlock_irq(&mapping->tree_lock);
+	/*
+	 * If we race with somebody updating the PTE and finish_mkwrite_fault()
+	 * fails, we don't care. We need to return VM_FAULT_NOPAGE and retry
+	 * the fault in either case.
+	 */
+	finish_mkwrite_fault(vmf);
+	put_locked_mapping_entry(mapping, index, entry);
 	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
diff --git a/mm/memory.c b/mm/memory.c
index d4874d3733f4..e37250fc54c2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2319,7 +2319,7 @@ static int wp_pfn_shared(struct vm_fault *vmf)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		vmf->flags |= FAULT_FLAG_MKWRITE;
 		ret = vma->vm_ops->pfn_mkwrite(vma, vmf);
-		if (ret & VM_FAULT_ERROR)
+		if (ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))
 			return ret;
 		return finish_mkwrite_fault(vmf);
 	}
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
