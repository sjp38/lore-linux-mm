Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 864A66B026F
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 16:01:50 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i23-v6so2527835qtf.9
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 13:01:50 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id o3-v6si610509qkd.87.2018.08.02.13.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 13:01:49 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v2 9/9] [SCSI] mpt3sas: replace chain_dma_pool
Message-ID: <bd0b747f-3424-e402-07ba-44e642937d8f@cybernetics.com>
Date: Thu, 2 Aug 2018 16:01:47 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

Replace chain_dma_pool with direct calls to dma_alloc_coherent() and
dma_free_coherent().  Since the chain lookup can involve hundreds of
thousands of allocations, it is worthwile to avoid the overhead of the
dma_pool API.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

No changes since v1.

The original code called _base_release_memory_pools() before "goto out"
if dma_pool_alloc() failed, but this was unnecessary because
mpt3sas_base_attach() will call _base_release_memory_pools() after "goto
out_free_resources".  It may have been that way because the out-of-tree
vendor driver (from https://www.broadcom.com/support/download-search)
has a slightly-more-complicated error handler there that adjusts
max_request_credit, calls _base_release_memory_pools() and then does
"goto retry_allocation" under some circumstances, but that is missing
from the in-tree driver.

diff --git a/drivers/scsi/mpt3sas/mpt3sas_base.c b/drivers/scsi/mpt3sas/mpt3sas_base.c
index 569392d..2cb567a 100644
--- a/drivers/scsi/mpt3sas/mpt3sas_base.c
+++ b/drivers/scsi/mpt3sas/mpt3sas_base.c
@@ -4224,6 +4224,134 @@ void mpt3sas_base_clear_st(struct MPT3SAS_ADAPTER *ioc,
 }
 
 /**
+ * _base_release_chain_lookup - release chain_lookup memory pools
+ * @ioc: per adapter object
+ *
+ * Free memory allocated from _base_allocate_chain_lookup.
+ */
+static void
+_base_release_chain_lookup(struct MPT3SAS_ADAPTER *ioc)
+{
+	unsigned int chains_avail = 0;
+	struct chain_tracker *ct;
+	int i, j;
+
+	if (!ioc->chain_lookup)
+		return;
+
+	/*
+	 * NOTE
+	 *
+	 * To make this code easier to understand and maintain, the for loops
+	 * and the management of the chains_avail value are designed to be
+	 * similar to the _base_allocate_chain_lookup() function.  That way,
+	 * the code for freeing the memory is similar to the code for
+	 * allocating the memory.
+	 */
+	for (i = 0; i < ioc->scsiio_depth; i++) {
+		if (!ioc->chain_lookup[i].chains_per_smid)
+			break;
+
+		for (j = ioc->chains_per_prp_buffer;
+				j < ioc->chains_needed_per_io; j++) {
+			/*
+			 * If chains_avail is 0, then the chain represents a
+			 * real allocation, so free it.
+			 *
+			 * If chains_avail is nonzero, then the chain was
+			 * initialized at an offset from a previous allocation,
+			 * so don't free it.
+			 */
+			if (chains_avail == 0) {
+				ct = &ioc->chain_lookup[i].chains_per_smid[j];
+				if (ct->chain_buffer)
+					dma_free_coherent(
+						&ioc->pdev->dev,
+						ioc->chain_allocation_sz,
+						ct->chain_buffer,
+						ct->chain_buffer_dma);
+				chains_avail = ioc->chains_per_allocation;
+			}
+			chains_avail--;
+		}
+		kfree(ioc->chain_lookup[i].chains_per_smid);
+	}
+
+	kfree(ioc->chain_lookup);
+	ioc->chain_lookup = NULL;
+}
+
+/**
+ * _base_allocate_chain_lookup - allocate chain_lookup memory pools
+ * @ioc: per adapter object
+ * @total_sz: external value that tracks total amount of memory allocated
+ *
+ * Return: 0 success, anything else error
+ */
+static int
+_base_allocate_chain_lookup(struct MPT3SAS_ADAPTER *ioc, u32 *total_sz)
+{
+	unsigned int aligned_chain_segment_sz;
+	const unsigned int align = 16;
+	unsigned int chains_avail = 0;
+	struct chain_tracker *ct;
+	dma_addr_t dma_addr = 0;
+	void *vaddr = NULL;
+	int i, j;
+
+	/* Round up the allocation size for alignment. */
+	aligned_chain_segment_sz = ioc->chain_segment_sz;
+	if (aligned_chain_segment_sz % align != 0)
+		aligned_chain_segment_sz =
+			ALIGN(aligned_chain_segment_sz, align);
+
+	/* Allocate a page of chain buffers at a time. */
+	ioc->chain_allocation_sz =
+		max_t(unsigned int, aligned_chain_segment_sz, PAGE_SIZE);
+
+	/* Calculate how many chain buffers we can get from one allocation. */
+	ioc->chains_per_allocation =
+		ioc->chain_allocation_sz / aligned_chain_segment_sz;
+
+	for (i = 0; i < ioc->scsiio_depth; i++) {
+		for (j = ioc->chains_per_prp_buffer;
+				j < ioc->chains_needed_per_io; j++) {
+			/*
+			 * Check if there are any chain buffers left in the
+			 * previously-allocated block.
+			 */
+			if (chains_avail == 0) {
+				/* Allocate a new block of chain buffers. */
+				vaddr = dma_alloc_coherent(
+					&ioc->pdev->dev,
+					ioc->chain_allocation_sz,
+					&dma_addr,
+					GFP_KERNEL);
+				if (!vaddr) {
+					pr_err(MPT3SAS_FMT
+						"chain_lookup: dma_alloc_coherent failed\n",
+						ioc->name);
+					return -1;
+				}
+				chains_avail = ioc->chains_per_allocation;
+			}
+
+			ct = &ioc->chain_lookup[i].chains_per_smid[j];
+			ct->chain_buffer     = vaddr;
+			ct->chain_buffer_dma = dma_addr;
+
+			/* Go to the next chain buffer in the block. */
+			vaddr     += aligned_chain_segment_sz;
+			dma_addr  += aligned_chain_segment_sz;
+			*total_sz += ioc->chain_segment_sz;
+			chains_avail--;
+		}
+	}
+
+	return 0;
+}
+
+/**
  * _base_release_memory_pools - release memory
  * @ioc: per adapter object
  *
@@ -4235,8 +4363,6 @@ void mpt3sas_base_clear_st(struct MPT3SAS_ADAPTER *ioc,
 _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
 {
 	int i = 0;
-	int j = 0;
-	struct chain_tracker *ct;
 	struct reply_post_struct *rps;
 
 	dexitprintk(ioc, pr_info(MPT3SAS_FMT "%s\n", ioc->name,
@@ -4326,22 +4452,7 @@ void mpt3sas_base_clear_st(struct MPT3SAS_ADAPTER *ioc,
 
 	kfree(ioc->hpr_lookup);
 	kfree(ioc->internal_lookup);
-	if (ioc->chain_lookup) {
-		for (i = 0; i < ioc->scsiio_depth; i++) {
-			for (j = ioc->chains_per_prp_buffer;
-			    j < ioc->chains_needed_per_io; j++) {
-				ct = &ioc->chain_lookup[i].chains_per_smid[j];
-				if (ct && ct->chain_buffer)
-					dma_pool_free(ioc->chain_dma_pool,
-						ct->chain_buffer,
-						ct->chain_buffer_dma);
-			}
-			kfree(ioc->chain_lookup[i].chains_per_smid);
-		}
-		dma_pool_destroy(ioc->chain_dma_pool);
-		kfree(ioc->chain_lookup);
-		ioc->chain_lookup = NULL;
-	}
+	_base_release_chain_lookup(ioc);
 }
 
 /**
@@ -4784,29 +4895,8 @@ void mpt3sas_base_clear_st(struct MPT3SAS_ADAPTER *ioc,
 		total_sz += sz * ioc->scsiio_depth;
 	}
 
-	ioc->chain_dma_pool = dma_pool_create("chain pool", &ioc->pdev->dev,
-	    ioc->chain_segment_sz, 16, 0);
-	if (!ioc->chain_dma_pool) {
-		pr_err(MPT3SAS_FMT "chain_dma_pool: dma_pool_create failed\n",
-			ioc->name);
+	if (_base_allocate_chain_lookup(ioc, &total_sz))
 		goto out;
-	}
-	for (i = 0; i < ioc->scsiio_depth; i++) {
-		for (j = ioc->chains_per_prp_buffer;
-				j < ioc->chains_needed_per_io; j++) {
-			ct = &ioc->chain_lookup[i].chains_per_smid[j];
-			ct->chain_buffer = dma_pool_alloc(
-					ioc->chain_dma_pool, GFP_KERNEL,
-					&ct->chain_buffer_dma);
-			if (!ct->chain_buffer) {
-				pr_err(MPT3SAS_FMT "chain_lookup: "
-				" pci_pool_alloc failed\n", ioc->name);
-				_base_release_memory_pools(ioc);
-				goto out;
-			}
-		}
-		total_sz += ioc->chain_segment_sz;
-	}
 
 	dinitprintk(ioc, pr_info(MPT3SAS_FMT
 		"chain pool depth(%d), frame_size(%d), pool_size(%d kB)\n",
diff --git a/drivers/scsi/mpt3sas/mpt3sas_base.h b/drivers/scsi/mpt3sas/mpt3sas_base.h
index f02974c..7ee81d5 100644
--- a/drivers/scsi/mpt3sas/mpt3sas_base.h
+++ b/drivers/scsi/mpt3sas/mpt3sas_base.h
@@ -1298,7 +1298,6 @@ struct MPT3SAS_ADAPTER {
 	/* chain */
 	struct chain_lookup *chain_lookup;
 	struct list_head free_chain_list;
-	struct dma_pool *chain_dma_pool;
 	ulong		chain_pages;
 	u16		max_sges_in_main_message;
 	u16		max_sges_in_chain_message;
@@ -1306,6 +1305,8 @@ struct MPT3SAS_ADAPTER {
 	u32		chain_depth;
 	u16		chain_segment_sz;
 	u16		chains_per_prp_buffer;
+	u32		chain_allocation_sz;
+	u32		chains_per_allocation;
 
 	/* hi-priority queue */
 	u16		hi_priority_smid;
