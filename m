Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 553166B025E
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:25:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u138so8362476wmu.19
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:25:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f71si360853wme.81.2017.10.24.08.25.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 08:25:28 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 03/17] dax: Simplify arguments of dax_insert_mapping()
Date: Tue, 24 Oct 2017 17:24:00 +0200
Message-Id: <20171024152415.22864-4-jack@suse.cz>
In-Reply-To: <20171024152415.22864-1-jack@suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

dax_insert_mapping() has lots of arguments and a lot of them is actuall
duplicated by passing vm_fault structure as well. Change the function to
take the same arguments as dax_pmd_insert_mapping().

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index f001d8c72a06..0bc42ac294ca 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -820,23 +820,30 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 }
 EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
 
-static int dax_insert_mapping(struct address_space *mapping,
-		struct block_device *bdev, struct dax_device *dax_dev,
-		sector_t sector, size_t size, void *entry,
-		struct vm_area_struct *vma, struct vm_fault *vmf)
+static sector_t dax_iomap_sector(struct iomap *iomap, loff_t pos)
+{
+	return iomap->blkno + (((pos & PAGE_MASK) - iomap->offset) >> 9);
+}
+
+static int dax_insert_mapping(struct vm_fault *vmf, struct iomap *iomap,
+			      loff_t pos, void *entry)
 {
+	const sector_t sector = dax_iomap_sector(iomap, pos);
+	struct vm_area_struct *vma = vmf->vma;
+	struct address_space *mapping = vma->vm_file->f_mapping;
 	unsigned long vaddr = vmf->address;
 	void *ret, *kaddr;
 	pgoff_t pgoff;
 	int id, rc;
 	pfn_t pfn;
 
-	rc = bdev_dax_pgoff(bdev, sector, size, &pgoff);
+	rc = bdev_dax_pgoff(iomap->bdev, sector, PAGE_SIZE, &pgoff);
 	if (rc)
 		return rc;
 
 	id = dax_read_lock();
-	rc = dax_direct_access(dax_dev, pgoff, PHYS_PFN(size), &kaddr, &pfn);
+	rc = dax_direct_access(iomap->dax_dev, pgoff, PHYS_PFN(PAGE_SIZE),
+			       &kaddr, &pfn);
 	if (rc < 0) {
 		dax_read_unlock(id);
 		return rc;
@@ -936,11 +943,6 @@ int __dax_zero_page_range(struct block_device *bdev,
 }
 EXPORT_SYMBOL_GPL(__dax_zero_page_range);
 
-static sector_t dax_iomap_sector(struct iomap *iomap, loff_t pos)
-{
-	return iomap->blkno + (((pos & PAGE_MASK) - iomap->offset) >> 9);
-}
-
 static loff_t
 dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		struct iomap *iomap)
@@ -1087,7 +1089,6 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 	struct inode *inode = mapping->host;
 	unsigned long vaddr = vmf->address;
 	loff_t pos = (loff_t)vmf->pgoff << PAGE_SHIFT;
-	sector_t sector;
 	struct iomap iomap = { 0 };
 	unsigned flags = IOMAP_FAULT;
 	int error, major = 0;
@@ -1140,9 +1141,9 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 		goto error_finish_iomap;
 	}
 
-	sector = dax_iomap_sector(&iomap, pos);
-
 	if (vmf->cow_page) {
+		sector_t sector = dax_iomap_sector(&iomap, pos);
+
 		switch (iomap.type) {
 		case IOMAP_HOLE:
 		case IOMAP_UNWRITTEN:
@@ -1175,8 +1176,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 			count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
 			major = VM_FAULT_MAJOR;
 		}
-		error = dax_insert_mapping(mapping, iomap.bdev, iomap.dax_dev,
-				sector, PAGE_SIZE, entry, vmf->vma, vmf);
+		error = dax_insert_mapping(vmf, &iomap, pos, entry);
 		/* -EBUSY is fine, somebody else faulted on the same PTE */
 		if (error == -EBUSY)
 			error = 0;
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
