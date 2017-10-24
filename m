Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62EDE6B026B
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:25:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b9so2484805wmh.5
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:25:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y62si345326wmy.261.2017.10.24.08.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 08:25:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 07/17] dax: Inline dax_insert_mapping() into the callsite
Date: Tue, 24 Oct 2017 17:24:04 +0200
Message-Id: <20171024152415.22864-8-jack@suse.cz>
In-Reply-To: <20171024152415.22864-1-jack@suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

dax_insert_mapping() has only one callsite and we will need to further
fine tune what it does for synchronous faults. Just inline it into the
callsite so that we don't have to pass awkward bools around.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c | 46 +++++++++++++++++++---------------------------
 1 file changed, 19 insertions(+), 27 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 5ea71381dba0..5b20c6456926 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -858,32 +858,6 @@ static int dax_iomap_pfn(struct iomap *iomap, loff_t pos, size_t size,
 	return rc;
 }
 
-static int dax_insert_mapping(struct vm_fault *vmf, struct iomap *iomap,
-			      loff_t pos, void *entry)
-{
-	const sector_t sector = dax_iomap_sector(iomap, pos);
-	struct vm_area_struct *vma = vmf->vma;
-	struct address_space *mapping = vma->vm_file->f_mapping;
-	unsigned long vaddr = vmf->address;
-	void *ret;
-	int rc;
-	pfn_t pfn;
-
-	rc = dax_iomap_pfn(iomap, pos, PAGE_SIZE, &pfn);
-	if (rc < 0)
-		return rc;
-
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, sector, 0);
-	if (IS_ERR(ret))
-		return PTR_ERR(ret);
-
-	trace_dax_insert_mapping(mapping->host, vmf, ret);
-	if (vmf->flags & FAULT_FLAG_WRITE)
-		return vm_insert_mixed_mkwrite(vma, vaddr, pfn);
-	else
-		return vm_insert_mixed(vma, vaddr, pfn);
-}
-
 /*
  * The user has performed a load from a hole in the file.  Allocating a new
  * page in the file would cause excessive storage usage for workloads with
@@ -1119,6 +1093,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	int vmf_ret = 0;
 	void *entry;
+	pfn_t pfn;
 
 	trace_dax_pte_fault(inode, vmf, vmf_ret);
 	/*
@@ -1201,7 +1176,24 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 			count_memcg_event_mm(vma->vm_mm, PGMAJFAULT);
 			major = VM_FAULT_MAJOR;
 		}
-		error = dax_insert_mapping(vmf, &iomap, pos, entry);
+		error = dax_iomap_pfn(&iomap, pos, PAGE_SIZE, &pfn);
+		if (error < 0)
+			goto error_finish_iomap;
+
+		entry = dax_insert_mapping_entry(mapping, vmf, entry,
+						 dax_iomap_sector(&iomap, pos),
+						 0);
+		if (IS_ERR(entry)) {
+			error = PTR_ERR(entry);
+			goto error_finish_iomap;
+		}
+
+		trace_dax_insert_mapping(inode, vmf, entry);
+		if (write)
+			error = vm_insert_mixed_mkwrite(vma, vaddr, pfn);
+		else
+			error = vm_insert_mixed(vma, vaddr, pfn);
+
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
