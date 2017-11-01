Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79E976B0298
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:37:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g75so2527290pfg.4
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:37:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b34si5611plc.22.2017.11.01.08.37.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:37:03 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 08/18] dax: Inline dax_pmd_insert_mapping() into the callsite
Date: Wed,  1 Nov 2017 16:36:37 +0100
Message-Id: <20171101153648.30166-9-jack@suse.cz>
In-Reply-To: <20171101153648.30166-1-jack@suse.cz>
References: <20171101153648.30166-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>

dax_pmd_insert_mapping() has only one callsite and we will need to
further fine tune what it does for synchronous faults. Just inline it
into the callsite so that we don't have to pass awkward bools around.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c                      | 47 +++++++++++++++++--------------------------
 include/trace/events/fs_dax.h |  1 -
 2 files changed, 19 insertions(+), 29 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 5b20c6456926..675fab8ec41f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1235,33 +1235,11 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 }
 
 #ifdef CONFIG_FS_DAX_PMD
-static int dax_pmd_insert_mapping(struct vm_fault *vmf, struct iomap *iomap,
-		loff_t pos, void *entry)
-{
-	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
-	const sector_t sector = dax_iomap_sector(iomap, pos);
-	struct inode *inode = mapping->host;
-	void *ret = NULL;
-	pfn_t pfn = {};
-	int rc;
-
-	rc = dax_iomap_pfn(iomap, pos, PMD_SIZE, &pfn);
-	if (rc < 0)
-		goto fallback;
-
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, sector,
-			RADIX_DAX_PMD);
-	if (IS_ERR(ret))
-		goto fallback;
-
-	trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, ret);
-	return vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd,
-			pfn, vmf->flags & FAULT_FLAG_WRITE);
-
-fallback:
-	trace_dax_pmd_insert_mapping_fallback(inode, vmf, PMD_SIZE, pfn, ret);
-	return VM_FAULT_FALLBACK;
-}
+/*
+ * The 'colour' (ie low bits) within a PMD of a page offset.  This comes up
+ * more often than one might expect in the below functions.
+ */
+#define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
 
 static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 		void *entry)
@@ -1317,6 +1295,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
 	void *entry;
 	loff_t pos;
 	int error;
+	pfn_t pfn;
 
 	/*
 	 * Check whether offset isn't beyond end of file now. Caller is
@@ -1394,7 +1373,19 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
 
 	switch (iomap.type) {
 	case IOMAP_MAPPED:
-		result = dax_pmd_insert_mapping(vmf, &iomap, pos, entry);
+		error = dax_iomap_pfn(&iomap, pos, PMD_SIZE, &pfn);
+		if (error < 0)
+			goto finish_iomap;
+
+		entry = dax_insert_mapping_entry(mapping, vmf, entry,
+						dax_iomap_sector(&iomap, pos),
+						RADIX_DAX_PMD);
+		if (IS_ERR(entry))
+			goto finish_iomap;
+
+		trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
+		result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
+					    write);
 		break;
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
index fbc4a06f7310..88a9d19b8ff8 100644
--- a/include/trace/events/fs_dax.h
+++ b/include/trace/events/fs_dax.h
@@ -148,7 +148,6 @@ DEFINE_EVENT(dax_pmd_insert_mapping_class, name, \
 	TP_ARGS(inode, vmf, length, pfn, radix_entry))
 
 DEFINE_PMD_INSERT_MAPPING_EVENT(dax_pmd_insert_mapping);
-DEFINE_PMD_INSERT_MAPPING_EVENT(dax_pmd_insert_mapping_fallback);
 
 DECLARE_EVENT_CLASS(dax_pte_fault_class,
 	TP_PROTO(struct inode *inode, struct vm_fault *vmf, int result),
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
