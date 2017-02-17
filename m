Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2764D4405FA
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:11 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id e1so24609940qkh.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:11 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id w5si7665649qte.45.2017.02.17.07.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:10 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 12/14] migrate: Add copy_page_dma to use DMA Engine to copy pages.
Date: Fri, 17 Feb 2017 10:05:49 -0500
Message-Id: <20170217150551.117028-13-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-1-zi.yan@sent.com>
References: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <ziy@nvidia.com>

vm.use_all_dma_chans will grab all usable DMA channels
vm.limit_dma_chans will limit how many DMA channels in use

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/highmem.h      |   1 +
 include/linux/sched/sysctl.h |   4 +
 kernel/sysctl.c              |  21 ++++
 mm/copy_pages.c              | 281 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 307 insertions(+)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index e1f4f1b82812..1388ff5d0e53 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -237,6 +237,7 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
 #endif
 
 int copy_pages_mthread(struct page *to, struct page *from, int nr_pages);
+int copy_page_dma(struct page *to, struct page *from, int nr_pages);
 
 static inline void copy_highpage(struct page *to, struct page *from)
 {
diff --git a/include/linux/sched/sysctl.h b/include/linux/sched/sysctl.h
index 22db1e63707e..d5efb4093386 100644
--- a/include/linux/sched/sysctl.h
+++ b/include/linux/sched/sysctl.h
@@ -78,4 +78,8 @@ extern int sysctl_schedstats(struct ctl_table *table, int write,
 				 void __user *buffer, size_t *lenp,
 				 loff_t *ppos);
 
+extern int sysctl_dma_page_migration(struct ctl_table *table, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos);
+
 #endif /* _SCHED_SYSCTL_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 70a654146519..55c812c313b8 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -99,6 +99,10 @@
 
 extern int mt_page_copy;
 
+extern int use_all_dma_chans;
+extern int limit_dma_chans;
+
+
 /* External variables not in a header file. */
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1372,6 +1376,23 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 	 {
+		.procname	= "use_all_dma_chans",
+		.data		= &use_all_dma_chans,
+		.maxlen		= sizeof(use_all_dma_chans),
+		.mode		= 0644,
+		.proc_handler	= sysctl_dma_page_migration,
+		.extra1		= &zero,
+		.extra2		= &one,
+	 },
+	 {
+		.procname	= "limit_dma_chans",
+		.data		= &limit_dma_chans,
+		.maxlen		= sizeof(limit_dma_chans),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &zero,
+	 },
+	 {
 		.procname	= "hugetlb_shm_group",
 		.data		= &sysctl_hugetlb_shm_group,
 		.maxlen		= sizeof(gid_t),
diff --git a/mm/copy_pages.c b/mm/copy_pages.c
index 879e2d944ad0..f135bf505183 100644
--- a/mm/copy_pages.c
+++ b/mm/copy_pages.c
@@ -10,7 +10,16 @@
 #include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/freezer.h>
+#include <linux/dmaengine.h>
+#include <linux/dma-mapping.h>
 
+#define NUM_AVAIL_DMA_CHAN 16
+
+int use_all_dma_chans = 0;
+int limit_dma_chans = NUM_AVAIL_DMA_CHAN;
+
+struct dma_chan *copy_chan[NUM_AVAIL_DMA_CHAN] = {0};
+struct dma_device *copy_dev[NUM_AVAIL_DMA_CHAN] = {0};
 /*
  * nr_copythreads can be the highest number of threads for given node
  * on any architecture. The actual number of copy threads will be
@@ -279,3 +288,275 @@ int exchange_page_lists_mthread(struct page **to, struct page **from,
 
 	return err;
 }
+
+#ifdef CONFIG_PROC_SYSCTL
+int sysctl_dma_page_migration(struct ctl_table *table, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos)
+{
+	int err = 0;
+	int use_all_dma_chans_prior_val = use_all_dma_chans;
+	dma_cap_mask_t copy_mask;
+
+	if (write && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	err = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+
+	if (err < 0)
+		return err;
+	if (write) {
+		/* Grab all DMA channels  */
+		if (use_all_dma_chans_prior_val == 0 && use_all_dma_chans == 1) {
+			int i;
+
+			dma_cap_zero(copy_mask);
+			dma_cap_set(DMA_MEMCPY, copy_mask);
+
+			dmaengine_get();
+			for (i = 0; i < NUM_AVAIL_DMA_CHAN; ++i) {
+				if (!copy_chan[i])
+					copy_chan[i] = dma_request_channel(copy_mask, NULL, NULL);
+				if (!copy_chan[i]) {
+					pr_err("%s: cannot grab channel: %d\n", __func__, i);
+					continue;
+				}
+
+				copy_dev[i] = copy_chan[i]->device;
+
+				if (!copy_dev[i]) {
+					pr_err("%s: no device: %d\n", __func__, i);
+					continue;
+				}
+			}
+
+		} 
+		/* Release all DMA channels  */
+		else if (use_all_dma_chans_prior_val == 1 && use_all_dma_chans == 0) {
+			int i;
+
+			for (i = 0; i < NUM_AVAIL_DMA_CHAN; ++i) {
+				if (copy_chan[i]) {
+					dma_release_channel(copy_chan[i]);
+					copy_chan[i] = NULL;
+					copy_dev[i] = NULL;
+				}
+			}
+
+			dmaengine_put();
+		}
+
+		if (err)
+			use_all_dma_chans = use_all_dma_chans_prior_val;
+	}
+	return err;
+}
+
+#endif
+
+static int copy_page_dma_once(struct page *to, struct page *from, int nr_pages)
+{
+	static struct dma_chan *copy_chan = NULL;
+	struct dma_device *device = NULL;
+	struct dma_async_tx_descriptor *tx = NULL;
+	dma_cookie_t cookie;
+	enum dma_ctrl_flags flags = 0;
+	struct dmaengine_unmap_data *unmap = NULL;
+	dma_cap_mask_t mask;
+	int ret_val = 0;
+
+	
+	dma_cap_zero(mask);
+	dma_cap_set(DMA_MEMCPY, mask);
+
+	dmaengine_get();
+
+	copy_chan = dma_request_channel(mask, NULL, NULL);
+
+	if (!copy_chan) {
+		pr_err("%s: cannot get a channel\n", __func__);
+		ret_val = -1;
+		goto no_chan;
+	}
+
+	device = copy_chan->device;
+
+	if (!device) {
+		pr_err("%s: cannot get a device\n", __func__);
+		ret_val = -2;
+		goto release;
+	}
+		
+	unmap = dmaengine_get_unmap_data(device->dev, 2, GFP_NOWAIT);
+
+	if (!unmap) {
+		pr_err("%s: cannot get unmap data\n", __func__);
+		ret_val = -3;
+		goto release;
+	}
+
+	unmap->to_cnt = 1;
+	unmap->addr[0] = dma_map_page(device->dev, from, 0, PAGE_SIZE*nr_pages,
+					  DMA_TO_DEVICE);
+	unmap->from_cnt = 1;
+	unmap->addr[1] = dma_map_page(device->dev, to, 0, PAGE_SIZE*nr_pages,
+					  DMA_FROM_DEVICE);
+	unmap->len = PAGE_SIZE*nr_pages;
+
+	tx = device->device_prep_dma_memcpy(copy_chan, 
+						unmap->addr[1],
+						unmap->addr[0], unmap->len,
+						flags);
+
+	if (!tx) {
+		pr_err("%s: null tx descriptor\n", __func__);
+		ret_val = -4;
+		goto unmap_dma;
+	}
+
+	cookie = tx->tx_submit(tx);
+
+	if (dma_submit_error(cookie)) {
+		pr_err("%s: submission error\n", __func__);
+		ret_val = -5;
+		goto unmap_dma;
+	}
+
+	if (dma_sync_wait(copy_chan, cookie) != DMA_COMPLETE) {
+		pr_err("%s: dma does not complete properly\n", __func__);
+		ret_val = -6;
+	}
+
+unmap_dma:
+	dmaengine_unmap_put(unmap);
+release:
+	if (copy_chan) {
+		dma_release_channel(copy_chan);
+	}
+no_chan:
+	dmaengine_put();
+
+	return ret_val;
+}
+
+static int copy_page_dma_always(struct page *to, struct page *from, int nr_pages)
+{
+	struct dma_async_tx_descriptor *tx[NUM_AVAIL_DMA_CHAN] = {0};
+	dma_cookie_t cookie[NUM_AVAIL_DMA_CHAN];
+	enum dma_ctrl_flags flags[NUM_AVAIL_DMA_CHAN] = {0};
+	struct dmaengine_unmap_data *unmap[NUM_AVAIL_DMA_CHAN] = {0};
+	int ret_val = 0;
+	int total_available_chans = NUM_AVAIL_DMA_CHAN;
+	int i;
+	size_t page_offset;
+
+	for (i = 0; i < NUM_AVAIL_DMA_CHAN; ++i) {
+		if (!copy_chan[i])
+			total_available_chans = i;
+	}
+	if (total_available_chans != NUM_AVAIL_DMA_CHAN) {
+		pr_err("%d channels are missing", NUM_AVAIL_DMA_CHAN - total_available_chans);
+	}
+
+	total_available_chans = min_t(int, total_available_chans, limit_dma_chans);
+
+	/* round down to closest 2^x value  */
+	total_available_chans = 1<<ilog2(total_available_chans);
+
+	if ((nr_pages != 1) && (nr_pages % total_available_chans != 0))
+		return -EFAULT;
+	
+	for (i = 0; i < total_available_chans; ++i) {
+		unmap[i] = dmaengine_get_unmap_data(copy_dev[i]->dev, 2, GFP_NOWAIT);
+		if (!unmap[i]) {
+			pr_err("%s: no unmap data at chan %d\n", __func__, i);
+			ret_val = -EFAULT;
+			goto unmap_dma;
+		}
+	}
+
+	for (i = 0; i < total_available_chans; ++i) {
+		if (nr_pages == 1) {
+			page_offset = PAGE_SIZE / total_available_chans;
+
+			unmap[i]->to_cnt = 1;
+			unmap[i]->addr[0] = dma_map_page(copy_dev[i]->dev, from, page_offset*i,
+							  page_offset,
+							  DMA_TO_DEVICE);
+			unmap[i]->from_cnt = 1;
+			unmap[i]->addr[1] = dma_map_page(copy_dev[i]->dev, to, page_offset*i,
+							  page_offset,
+							  DMA_FROM_DEVICE);
+			unmap[i]->len = page_offset;
+		} else {
+			page_offset = nr_pages / total_available_chans;
+
+			unmap[i]->to_cnt = 1;
+			unmap[i]->addr[0] = dma_map_page(copy_dev[i]->dev, 
+								from + page_offset*i, 
+								0,
+								PAGE_SIZE*page_offset,
+								DMA_TO_DEVICE);
+			unmap[i]->from_cnt = 1;
+			unmap[i]->addr[1] = dma_map_page(copy_dev[i]->dev, 
+								to + page_offset*i, 
+								0,
+								PAGE_SIZE*page_offset,
+								DMA_FROM_DEVICE);
+			unmap[i]->len = PAGE_SIZE*page_offset;
+		}
+	}
+
+	for (i = 0; i < total_available_chans; ++i) {
+		tx[i] = copy_dev[i]->device_prep_dma_memcpy(copy_chan[i], 
+							unmap[i]->addr[1],
+							unmap[i]->addr[0], 
+							unmap[i]->len,
+							flags[i]);
+		if (!tx[i]) {
+			pr_err("%s: no tx descriptor at chan %d\n", __func__, i);
+			ret_val = -EFAULT;
+			goto unmap_dma;
+		}
+	}
+
+	for (i = 0; i < total_available_chans; ++i) {
+		cookie[i] = tx[i]->tx_submit(tx[i]);
+
+		if (dma_submit_error(cookie[i])) {
+			pr_err("%s: submission error at chan %d\n", __func__, i);
+			ret_val = -EFAULT;
+			goto unmap_dma;
+		}
+					
+		dma_async_issue_pending(copy_chan[i]);
+	}
+
+	for (i = 0; i < total_available_chans; ++i) {
+		if (dma_sync_wait(copy_chan[i], cookie[i]) != DMA_COMPLETE) {
+			ret_val = -EFAULT;
+			pr_err("%s: dma does not complete at chan %d\n", __func__, i);
+		}
+	}
+
+unmap_dma:
+
+	for (i = 0; i < total_available_chans; ++i) {
+		if (unmap[i])
+			dmaengine_unmap_put(unmap[i]);
+	}
+
+	return ret_val;
+}
+
+int copy_page_dma(struct page *to, struct page *from, int nr_pages)
+{
+	BUG_ON(hpage_nr_pages(from) != nr_pages);
+	BUG_ON(hpage_nr_pages(to) != nr_pages);
+
+	if (!use_all_dma_chans) {
+		return copy_page_dma_once(to, from, nr_pages);
+	} 
+
+	return copy_page_dma_always(to, from, nr_pages);
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
