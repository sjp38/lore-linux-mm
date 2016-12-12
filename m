Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7696B0260
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:47:23 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o3so26995448wjo.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 08:47:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r3si45175753wjt.38.2016.12.12.08.47.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 08:47:22 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/6] dax: Finish fault completely when loading holes
Date: Mon, 12 Dec 2016 17:47:06 +0100
Message-Id: <20161212164708.23244-5-jack@suse.cz>
In-Reply-To: <20161212164708.23244-1-jack@suse.cz>
References: <20161212164708.23244-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>

The only case when we do not finish the page fault completely is when we
are loading hole pages into a radix tree. Avoid this special case and
finish the fault in that case as well inside the DAX fault handler. It
will allow us for easier iomap handling.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 97858dd5dab6..e186bba0a642 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -540,15 +540,16 @@ int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
  * otherwise it will simply fall out of the page cache under memory
  * pressure without ever having been dirtied.
  */
-static int dax_load_hole(struct address_space *mapping, void *entry,
+static int dax_load_hole(struct address_space *mapping, void **entry,
 			 struct vm_fault *vmf)
 {
 	struct page *page;
+	int ret;
 
 	/* Hole page already exists? Return it...  */
-	if (!radix_tree_exceptional_entry(entry)) {
-		vmf->page = entry;
-		return VM_FAULT_LOCKED;
+	if (!radix_tree_exceptional_entry(*entry)) {
+		page = *entry;
+		goto out;
 	}
 
 	/* This will replace locked radix tree entry with a hole page */
@@ -556,8 +557,17 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 				   vmf->gfp_mask | __GFP_ZERO);
 	if (!page)
 		return VM_FAULT_OOM;
+ out:
 	vmf->page = page;
-	return VM_FAULT_LOCKED;
+	ret = finish_fault(vmf);
+	vmf->page = NULL;
+	*entry = page;
+	if (!ret) {
+		/* Grab reference for PTE that is now referencing the page */
+		get_page(page);
+		return VM_FAULT_NOPAGE;
+	}
+	return ret;
 }
 
 static int copy_user_dax(struct block_device *bdev, sector_t sector, size_t size,
@@ -1164,8 +1174,8 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (!(vmf->flags & FAULT_FLAG_WRITE)) {
-			vmf_ret = dax_load_hole(mapping, entry, vmf);
-			break;
+			vmf_ret = dax_load_hole(mapping, &entry, vmf);
+			goto finish_iomap;
 		}
 		/*FALLTHRU*/
 	default:
@@ -1186,8 +1196,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		}
 	}
  unlock_entry:
-	if (vmf_ret != VM_FAULT_LOCKED || error)
-		put_locked_mapping_entry(mapping, vmf->pgoff, entry);
+	put_locked_mapping_entry(mapping, vmf->pgoff, entry);
  out:
 	if (error == -ENOMEM)
 		return VM_FAULT_OOM | major;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
