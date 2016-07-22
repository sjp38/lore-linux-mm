Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A201B828E1
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:20:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so32901624wma.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:20:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cm17si622019wjb.239.2016.07.22.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 14/15] dax: Protect PTE modification on WP fault by radix tree entry lock
Date: Fri, 22 Jul 2016 14:19:40 +0200
Message-Id: <1469189981-19000-15-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Currently PTE gets updated in wp_pfn_shared() after dax_pfn_mkwrite()
has released corresponding radix tree entry lock. When we want to
writeprotect PTE on cache flush, we need PTE modification to happen
under radix tree entry lock to ensure consisten updates of PTE and radix
tree (standard faults use page lock to ensure this consistency). So move
update of PTE bit into dax_pfn_mkwrite().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c    | 6 ++++++
 mm/memory.c | 2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 513881431be6..e8d61ac3d148 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1218,6 +1218,12 @@ int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (!entry || !radix_tree_exceptional_entry(entry))
 		goto out;
 	radix_tree_tag_set(&mapping->page_tree, index, PAGECACHE_TAG_DIRTY);
+	/*
+	 * If we race with somebody updating the PTE and finish_mkwrite_fault()
+	 * fails, we don't care. We need to return VM_FAULT_NOPAGE and retry
+	 * the fault in either case.
+	 */
+	finish_mkwrite_fault(vma, vmf);
 	put_unlocked_mapping_entry(mapping, index, entry);
 out:
 	spin_unlock_irq(&mapping->tree_lock);
diff --git a/mm/memory.c b/mm/memory.c
index 30cf7b36df48..47241c2f6178 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2315,7 +2315,7 @@ static int wp_pfn_shared(struct mm_struct *mm,
 			 linear_page_index(vma, address),
 			 FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE, orig_pte);
 		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf);
-		if (ret & VM_FAULT_ERROR)
+		if (ret & VM_FAULT_ERROR || ret & VM_FAULT_NOPAGE)
 			return ret;
 		if (finish_mkwrite_fault(vma, &vmf) < 0)
 			return 0;
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
