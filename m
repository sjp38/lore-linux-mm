Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C27E96B026F
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:25:51 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v88so5604974wrb.22
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:25:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a25si386289wrd.289.2017.10.24.08.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 08:25:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 11/17] dax: Allow tuning whether dax_insert_mapping_entry() dirties entry
Date: Tue, 24 Oct 2017 17:24:08 +0200
Message-Id: <20171024152415.22864-12-jack@suse.cz>
In-Reply-To: <20171024152415.22864-1-jack@suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Currently we dirty radix tree entry whenever dax_insert_mapping_entry()
gets called for a write fault. With synchronous page faults we would
like to insert clean radix tree entry and dirty it only once we call
fdatasync() and update page tables to save some unnecessary cache
flushing. Add 'dirty' argument to dax_insert_mapping_entry() for that.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 5ddf15161390..efc210ff6665 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -526,13 +526,13 @@ static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
 static void *dax_insert_mapping_entry(struct address_space *mapping,
 				      struct vm_fault *vmf,
 				      void *entry, sector_t sector,
-				      unsigned long flags)
+				      unsigned long flags, bool dirty)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
 	void *new_entry;
 	pgoff_t index = vmf->pgoff;
 
-	if (vmf->flags & FAULT_FLAG_WRITE)
+	if (dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 
 	if (dax_is_zero_entry(entry) && !(flags & RADIX_DAX_ZERO_PAGE)) {
@@ -569,7 +569,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 		entry = new_entry;
 	}
 
-	if (vmf->flags & FAULT_FLAG_WRITE)
+	if (dirty)
 		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
 
 	spin_unlock_irq(&mapping->tree_lock);
@@ -881,7 +881,7 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 	}
 
 	entry2 = dax_insert_mapping_entry(mapping, vmf, entry, 0,
-			RADIX_DAX_ZERO_PAGE);
+			RADIX_DAX_ZERO_PAGE, false);
 	if (IS_ERR(entry2)) {
 		ret = VM_FAULT_SIGBUS;
 		goto out;
@@ -1182,7 +1182,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 
 		entry = dax_insert_mapping_entry(mapping, vmf, entry,
 						 dax_iomap_sector(&iomap, pos),
-						 0);
+						 0, write);
 		if (IS_ERR(entry)) {
 			error = PTR_ERR(entry);
 			goto error_finish_iomap;
@@ -1258,7 +1258,7 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 		goto fallback;
 
 	ret = dax_insert_mapping_entry(mapping, vmf, entry, 0,
-			RADIX_DAX_PMD | RADIX_DAX_ZERO_PAGE);
+			RADIX_DAX_PMD | RADIX_DAX_ZERO_PAGE, false);
 	if (IS_ERR(ret))
 		goto fallback;
 
@@ -1379,7 +1379,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 
 		entry = dax_insert_mapping_entry(mapping, vmf, entry,
 						dax_iomap_sector(&iomap, pos),
-						RADIX_DAX_PMD);
+						RADIX_DAX_PMD, write);
 		if (IS_ERR(entry))
 			goto finish_iomap;
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
