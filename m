Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD1956B0283
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 11:27:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b9so2486629wmh.5
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:27:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y130si362740wmg.119.2017.10.24.08.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 08:25:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 13/17] dax, iomap: Add support for synchronous faults
Date: Tue, 24 Oct 2017 17:24:10 +0200
Message-Id: <20171024152415.22864-14-jack@suse.cz>
In-Reply-To: <20171024152415.22864-1-jack@suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Add a flag to iomap interface informing the caller that inode needs
fdstasync(2) for returned extent to become persistent and use it in DAX
fault code so that we don't map such extents into page tables
immediately. Instead we propagate the information that fdatasync(2) is
necessary from dax_iomap_fault() with a new VM_FAULT_NEEDDSYNC flag.
Filesystem fault handler is then responsible for calling fdatasync(2)
and inserting pfn into page tables.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c              | 39 +++++++++++++++++++++++++++++++++++++--
 include/linux/iomap.h |  1 +
 include/linux/mm.h    |  6 +++++-
 3 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index efc210ff6665..bb9ff907738c 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1091,6 +1091,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	unsigned flags = IOMAP_FAULT;
 	int error, major = 0;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
+	bool sync;
 	int vmf_ret = 0;
 	void *entry;
 	pfn_t pfn;
@@ -1169,6 +1170,8 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		goto finish_iomap;
 	}
 
+	sync = (vma->vm_flags & VM_SYNC) && (iomap.flags & IOMAP_F_DIRTY);
+
 	switch (iomap.type) {
 	case IOMAP_MAPPED:
 		if (iomap.flags & IOMAP_F_NEW) {
@@ -1182,12 +1185,27 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 
 		entry = dax_insert_mapping_entry(mapping, vmf, entry,
 						 dax_iomap_sector(&iomap, pos),
-						 0, write);
+						 0, write && !sync);
 		if (IS_ERR(entry)) {
 			error = PTR_ERR(entry);
 			goto error_finish_iomap;
 		}
 
+		/*
+		 * If we are doing synchronous page fault and inode needs fsync,
+		 * we can insert PTE into page tables only after that happens.
+		 * Skip insertion for now and return the pfn so that caller can
+		 * insert it after fsync is done.
+		 */
+		if (sync) {
+			if (WARN_ON_ONCE(!pfnp)) {
+				error = -EIO;
+				goto error_finish_iomap;
+			}
+			*pfnp = pfn;
+			vmf_ret = VM_FAULT_NEEDDSYNC | major;
+			goto finish_iomap;
+		}
 		trace_dax_insert_mapping(inode, vmf, entry);
 		if (write)
 			error = vm_insert_mixed_mkwrite(vma, vaddr, pfn);
@@ -1287,6 +1305,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
+	bool sync;
 	unsigned int iomap_flags = (write ? IOMAP_WRITE : 0) | IOMAP_FAULT;
 	struct inode *inode = mapping->host;
 	int result = VM_FAULT_FALLBACK;
@@ -1371,6 +1390,8 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	if (iomap.offset + iomap.length < pos + PMD_SIZE)
 		goto finish_iomap;
 
+	sync = (vma->vm_flags & VM_SYNC) && (iomap.flags & IOMAP_F_DIRTY);
+
 	switch (iomap.type) {
 	case IOMAP_MAPPED:
 		error = dax_iomap_pfn(&iomap, pos, PMD_SIZE, &pfn);
@@ -1379,10 +1400,24 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 
 		entry = dax_insert_mapping_entry(mapping, vmf, entry,
 						dax_iomap_sector(&iomap, pos),
-						RADIX_DAX_PMD, write);
+						RADIX_DAX_PMD, write && !sync);
 		if (IS_ERR(entry))
 			goto finish_iomap;
 
+		/*
+		 * If we are doing synchronous page fault and inode needs fsync,
+		 * we can insert PMD into page tables only after that happens.
+		 * Skip insertion for now and return the pfn so that caller can
+		 * insert it after fsync is done.
+		 */
+		if (sync) {
+			if (WARN_ON_ONCE(!pfnp))
+				goto finish_iomap;
+			*pfnp = pfn;
+			result = VM_FAULT_NEEDDSYNC;
+			goto finish_iomap;
+		}
+
 		trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
 		result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
 					    write);
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index f64dc6ce5161..4bc0a6fe3b15 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -22,6 +22,7 @@ struct vm_fault;
  * Flags for all iomap mappings:
  */
 #define IOMAP_F_NEW	0x01	/* blocks have been newly allocated */
+#define IOMAP_F_DIRTY	0x02	/* block mapping is not yet on persistent storage */
 
 /*
  * Flags that only need to be reported for IOMAP_REPORT requests:
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411cb7442de..f57e55782d7d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1182,6 +1182,9 @@ static inline void clear_page_pfmemalloc(struct page *page)
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
 #define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
 #define VM_FAULT_DONE_COW   0x1000	/* ->fault has fully handled COW */
+#define VM_FAULT_NEEDDSYNC  0x2000	/* ->fault did not modify page tables
+					 * and needs fsync() to complete (for
+					 * synchronous page faults in DAX) */
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
 			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
@@ -1199,7 +1202,8 @@ static inline void clear_page_pfmemalloc(struct page *page)
 	{ VM_FAULT_LOCKED,		"LOCKED" }, \
 	{ VM_FAULT_RETRY,		"RETRY" }, \
 	{ VM_FAULT_FALLBACK,		"FALLBACK" }, \
-	{ VM_FAULT_DONE_COW,		"DONE_COW" }
+	{ VM_FAULT_DONE_COW,		"DONE_COW" }, \
+	{ VM_FAULT_NEEDDSYNC,		"NEEDDSYNC" }
 
 /* Encode hstate index for a hwpoisoned large page */
 #define VM_FAULT_SET_HINDEX(x) ((x) << 12)
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
