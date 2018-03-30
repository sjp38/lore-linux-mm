Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 145906B002C
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:42:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p189so6257188pfp.1
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:42:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x4-v6si7252789plv.81.2018.03.29.20.42.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Mar 2018 20:42:57 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v10 53/62] dax: dax_insert_mapping_entry always succeeds
Date: Thu, 29 Mar 2018 20:42:36 -0700
Message-Id: <20180330034245.10462-54-willy@infradead.org>
In-Reply-To: <20180330034245.10462-1-willy@infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

It does not return an error, so we don't need to check the return value
for IS_ERR().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 371d50a1c14e..3bd9f624c1f8 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -994,18 +994,12 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 	struct inode *inode = mapping->host;
 	unsigned long vaddr = vmf->address;
 	int ret = VM_FAULT_NOPAGE;
-	void *entry2;
 	pfn_t pfn = pfn_to_pfn_t(my_zero_pfn(vaddr));
 
-	entry2 = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
+	dax_insert_mapping_entry(mapping, vmf, entry, pfn,
 			DAX_ZERO_PAGE, false);
-	if (IS_ERR(entry2)) {
-		ret = VM_FAULT_SIGBUS;
-		goto out;
-	}
 
 	vm_insert_mixed(vmf->vma, vaddr, pfn);
-out:
 	trace_dax_load_hole(inode, vmf, ret);
 	return ret;
 }
@@ -1315,10 +1309,6 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 
 		entry = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
 						 0, write && !sync);
-		if (IS_ERR(entry)) {
-			error = PTR_ERR(entry);
-			goto error_finish_iomap;
-		}
 
 		/*
 		 * If we are doing synchronous page fault and inode needs fsync,
@@ -1402,8 +1392,6 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 	pfn = page_to_pfn_t(zero_page);
 	ret = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
 			DAX_PMD | DAX_ZERO_PAGE, false);
-	if (IS_ERR(ret))
-		goto fallback;
 
 	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
 	if (!pmd_none(*(vmf->pmd))) {
@@ -1525,8 +1513,6 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 
 		entry = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
 						DAX_PMD, write && !sync);
-		if (IS_ERR(entry))
-			goto finish_iomap;
 
 		/*
 		 * If we are doing synchronous page fault and inode needs fsync,
-- 
2.16.2
