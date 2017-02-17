Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 951CF4405FA
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:11 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 11so37460699qkl.4
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:11 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id t190si7654497qkc.53.2017.02.17.07.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:10 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 14/14] mm: Add copy_page_lists_dma_always to support copy a list of pages.
Date: Fri, 17 Feb 2017 10:05:51 -0500
Message-Id: <20170217150551.117028-15-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

Both src and dst page lists should match the page size at each
page and the length of both lists is shared.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/copy_pages.c | 158 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h   |   3 ++
 mm/migrate.c    |   5 +-
 3 files changed, 165 insertions(+), 1 deletion(-)

diff --git a/mm/copy_pages.c b/mm/copy_pages.c
index f135bf505183..cf674840a830 100644
--- a/mm/copy_pages.c
+++ b/mm/copy_pages.c
@@ -560,3 +560,161 @@ int copy_page_dma(struct page *to, struct page *from, int nr_pages)
 
 	return copy_page_dma_always(to, from, nr_pages);
 }
+
+/*
+ * Use DMA copy a list of pages to a new location
+ *
+ * Just put each page into individual DMA channel.
+ *
+ * */
+int copy_page_lists_dma_always(struct page **to, struct page **from, int nr_pages)
+{
+	struct dma_async_tx_descriptor **tx = NULL;
+	dma_cookie_t *cookie = NULL;
+	enum dma_ctrl_flags flags[NUM_AVAIL_DMA_CHAN] = {0};
+	struct dmaengine_unmap_data *unmap[NUM_AVAIL_DMA_CHAN] = {0};
+	int ret_val = 0;
+	int total_available_chans = NUM_AVAIL_DMA_CHAN;
+	int i;
+
+	for (i = 0; i < NUM_AVAIL_DMA_CHAN; ++i) {
+		if (!copy_chan[i])
+			total_available_chans = i;
+	}
+	if (total_available_chans != NUM_AVAIL_DMA_CHAN)
+		pr_err("%d channels are missing\n", NUM_AVAIL_DMA_CHAN - total_available_chans);
+
+	if (limit_dma_chans < total_available_chans)
+		total_available_chans = limit_dma_chans;
+
+	/* round down to closest 2^x value  */
+	total_available_chans = 1<<ilog2(total_available_chans);
+
+	total_available_chans = min_t(int, total_available_chans, nr_pages);
+
+
+	tx = kzalloc(sizeof(struct dma_async_tx_descriptor*)*nr_pages, GFP_KERNEL);
+	if (!tx) {
+		ret_val = -ENOMEM;
+		goto out;
+	}
+	cookie = kzalloc(sizeof(dma_cookie_t)*nr_pages, GFP_KERNEL);
+	if (!cookie) {
+		ret_val = -ENOMEM;
+		goto out_free_tx;
+	}
+
+	
+	for (i = 0; i < total_available_chans; ++i) {
+		int num_xfer_per_dev = nr_pages / total_available_chans;
+		
+		if (i < (nr_pages % total_available_chans))
+			num_xfer_per_dev += 1;
+
+		unmap[i] = dmaengine_get_unmap_data(copy_dev[i]->dev, 
+						2*num_xfer_per_dev, GFP_NOWAIT);
+		if (!unmap[i]) {
+			pr_err("%s: no unmap data at chan %d\n", __func__, i);
+			ret_val = -ENODEV;
+			goto unmap_dma;
+		}
+	}
+
+	for (i = 0; i < total_available_chans; ++i) {
+		int num_xfer_per_dev = nr_pages / total_available_chans;
+		int xfer_idx;
+		
+		if (i < (nr_pages % total_available_chans))
+			num_xfer_per_dev += 1;
+
+		unmap[i]->to_cnt = num_xfer_per_dev;
+		unmap[i]->from_cnt = num_xfer_per_dev;
+		unmap[i]->len = hpage_nr_pages(from[i]) * PAGE_SIZE; 
+
+		for (xfer_idx = 0; xfer_idx < num_xfer_per_dev; ++xfer_idx) {
+			int page_idx = i + xfer_idx * total_available_chans;
+			size_t page_len = hpage_nr_pages(from[page_idx]) * PAGE_SIZE;
+
+			BUG_ON(page_len != hpage_nr_pages(to[page_idx]) * PAGE_SIZE);
+			BUG_ON(unmap[i]->len != page_len);
+
+			unmap[i]->addr[xfer_idx] = 
+				 dma_map_page(copy_dev[i]->dev, from[page_idx], 
+							  0,
+							  page_len,
+							  DMA_TO_DEVICE);
+
+			unmap[i]->addr[xfer_idx+num_xfer_per_dev] = 
+				 dma_map_page(copy_dev[i]->dev, to[page_idx], 
+							  0,
+							  page_len,
+							  DMA_FROM_DEVICE);
+		}
+	}
+
+	for (i = 0; i < total_available_chans; ++i) {
+		int num_xfer_per_dev = nr_pages / total_available_chans;
+		int xfer_idx;
+		
+		if (i < (nr_pages % total_available_chans))
+			num_xfer_per_dev += 1;
+
+		for (xfer_idx = 0; xfer_idx < num_xfer_per_dev; ++xfer_idx) {
+			int page_idx = i + xfer_idx * total_available_chans;
+
+			tx[page_idx] = copy_dev[i]->device_prep_dma_memcpy(copy_chan[i], 
+								unmap[i]->addr[xfer_idx + num_xfer_per_dev],
+								unmap[i]->addr[xfer_idx], 
+								unmap[i]->len,
+								flags[i]);
+			if (!tx[page_idx]) {
+				pr_err("%s: no tx descriptor at chan %d xfer %d\n", 
+					   __func__, i, xfer_idx);
+				ret_val = -ENODEV;
+				goto unmap_dma;
+			}
+
+			cookie[page_idx] = tx[page_idx]->tx_submit(tx[page_idx]);
+
+			if (dma_submit_error(cookie[page_idx])) {
+				pr_err("%s: submission error at chan %d xfer %d\n",
+					   __func__, i, xfer_idx);
+				ret_val = -ENODEV;
+				goto unmap_dma;
+			}
+		}
+
+		dma_async_issue_pending(copy_chan[i]);
+	}
+
+	for (i = 0; i < total_available_chans; ++i) {
+		int num_xfer_per_dev = nr_pages / total_available_chans;
+		int xfer_idx;
+		
+		if (i < (nr_pages % total_available_chans))
+			num_xfer_per_dev += 1;
+
+		for (xfer_idx = 0; xfer_idx < num_xfer_per_dev; ++xfer_idx) {
+			int page_idx = i + xfer_idx * total_available_chans;
+
+			if (dma_sync_wait(copy_chan[i], cookie[page_idx]) != DMA_COMPLETE) {
+				ret_val = -EFAULT;
+				pr_err("%s: dma does not complete at chan %d, xfer %d\n",
+					   __func__, i, xfer_idx);
+			}
+		}
+	}
+
+unmap_dma:
+	for (i = 0; i < total_available_chans; ++i) {
+		if (unmap[i])
+			dmaengine_unmap_put(unmap[i]);
+	}
+
+	kfree(cookie);
+out_free_tx:
+	kfree(tx);
+out:
+
+	return ret_val;
+}
diff --git a/mm/internal.h b/mm/internal.h
index b99a634b4d09..32048e89bfda 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -500,10 +500,13 @@ extern const struct trace_print_flags gfpflag_names[];
 
 extern int copy_page_lists_mthread(struct page **to,
 			struct page **from, int nr_pages);
+extern int copy_page_lists_dma_always(struct page **to,
+			struct page **from, int nr_pages);
 
 extern int exchange_page_mthread(struct page *to, struct page *from,
 			int nr_pages);
 extern int exchange_page_lists_mthread(struct page **to,
 						  struct page **from, 
 						  int nr_pages);
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index 464bc9ba8083..63e44ac65184 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1611,7 +1611,10 @@ static int copy_to_new_pages_concur(struct list_head *unmapped_list_ptr,
 
 	BUG_ON(idx != num_pages);
 	
-	if (mode & MIGRATE_MT)
+	if (mode & MIGRATE_DMA)
+		rc = copy_page_lists_dma_always(dst_page_list, src_page_list,
+							num_pages);
+	else if (mode & MIGRATE_MT)
 		rc = copy_page_lists_mthread(dst_page_list, src_page_list,
 							num_pages);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
