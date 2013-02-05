Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 250436B000C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 12:13:38 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so148653dal.15
        for <linux-mm@kvack.org>; Tue, 05 Feb 2013 09:13:37 -0800 (PST)
Message-ID: <51113DB7.8060706@gmail.com>
Date: Wed, 06 Feb 2013 01:13:27 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] mm: rename nr_free_buffer_pages to nr_free_buffer_high_pages
References: <51113CE3.5090000@gmail.com>
In-Reply-To: <51113CE3.5090000@gmail.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Linux MM <linux-mm@kvack.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, m.szyprowski@samsung.com
Cc: linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

This function actually counts RAM pages that are above high watermark within
ZONE_DMA and ZONE_NORMAL, so rename it to a reasonable name.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/ia64/mm/contig.c          |    3 ++-
 arch/ia64/mm/discontig.c       |    3 ++-
 drivers/mmc/card/mmc_test.c    |    4 ++--
 fs/buffer.c                    |    2 +-
 fs/nfsd/nfs4state.c            |    2 +-
 fs/nfsd/nfssvc.c               |    2 +-
 include/linux/swap.h           |    2 +-
 mm/huge_memory.c               |    2 +-
 mm/page-writeback.c            |    2 +-
 mm/page_alloc.c                |    9 +++++----
 net/9p/trans_virtio.c          |    2 +-
 net/ipv4/tcp.c                 |    4 ++--
 net/ipv4/udp.c                 |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 net/sctp/protocol.c            |    2 +-
 15 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 1516d1d..a2f45ce 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -93,7 +93,8 @@ void show_mem(unsigned int filter)
 	printk(KERN_INFO "%d pages swap cached\n", total_cached);
 	printk(KERN_INFO "Total of %ld pages in page table cache\n",
 	       quicklist_total_size());
-	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
+	printk(KERN_INFO "%d free buffer pages above high watermark\n",
+	       nr_free_buffer_high_pages());
 }
 
 
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index c641333..cc55453 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -666,7 +666,8 @@ void show_mem(unsigned int filter)
 	printk(KERN_INFO "%d pages swap cached\n", total_cached);
 	printk(KERN_INFO "Total of %ld pages in page table cache\n",
 	       quicklist_total_size());
-	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
+	printk(KERN_INFO "%d free buffer pages above high watermark\n",
+	       nr_free_buffer_pages());
 }
 
 /**
diff --git a/drivers/mmc/card/mmc_test.c b/drivers/mmc/card/mmc_test.c
index 759714e..8271d4d 100644
--- a/drivers/mmc/card/mmc_test.c
+++ b/drivers/mmc/card/mmc_test.c
@@ -16,7 +16,7 @@
 #include <linux/slab.h>
 
 #include <linux/scatterlist.h>
-#include <linux/swap.h>		/* For nr_free_buffer_pages() */
+#include <linux/swap.h>		/* For nr_free_buffer_high_pages() */
 #include <linux/list.h>
 
 #include <linux/debugfs.h>
@@ -323,7 +323,7 @@ static struct mmc_test_mem *mmc_test_alloc_mem(unsigned long min_sz,
 	unsigned long min_page_cnt = DIV_ROUND_UP(min_sz, PAGE_SIZE);
 	unsigned long max_seg_page_cnt = DIV_ROUND_UP(max_seg_sz, PAGE_SIZE);
 	unsigned long page_cnt = 0;
-	unsigned long limit = nr_free_buffer_pages() >> 4;
+	unsigned long limit = nr_free_buffer_high_pages() >> 4;
 	struct mmc_test_mem *mem;
 
 	if (max_page_cnt > limit)
diff --git a/fs/buffer.c b/fs/buffer.c
index 7a75c3e..c1bcb6d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3354,7 +3354,7 @@ void __init buffer_init(void)
 	/*
 	 * Limit the bh occupancy to 10% of ZONE_NORMAL
 	 */
-	nrpages = (nr_free_buffer_pages() * 10) / 100;
+	nrpages = (nr_free_buffer_high_pages() * 10) / 100;
 	max_buffer_heads = nrpages * (PAGE_SIZE / sizeof(struct buffer_head));
 	hotcpu_notifier(buffer_cpu_notify, 0);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ac8ed96..cddd447 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4813,7 +4813,7 @@ set_max_delegations(void)
 	 * is for a different inode), a delegation could take about 1.5K,
 	 * giving a worst case usage of about 6% of memory.
 	 */
-	max_delegations = nr_free_buffer_pages() >> (20 - 2 - PAGE_SHIFT);
+	max_delegations = nr_free_buffer_high_pages() >> (20 - 2 - PAGE_SHIFT);
 }
 
 static int nfs4_state_create_net(struct net *net)
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index cee62ab..2820409 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -338,7 +338,7 @@ void nfsd_reset_versions(void)
 static void set_max_drc(void)
 {
 	#define NFSD_DRC_SIZE_SHIFT	10
-	nfsd_drc_max_mem = (nr_free_buffer_pages()
+	nfsd_drc_max_mem = (nr_free_buffer_high_pages()
 					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
 	nfsd_drc_mem_used = 0;
 	spin_lock_init(&nfsd_drc_lock);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 68df9c1..0df8905 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -216,7 +216,7 @@ struct swap_list_t {
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
 extern unsigned long dirty_balance_reserve;
-extern unsigned int nr_free_buffer_pages(void);
+extern unsigned int nr_free_buffer_high_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
 
 /* Definition of global_page_state not available yet */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b5783d8..c483e20 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -127,7 +127,7 @@ static int set_recommended_min_free_kbytes(void)
 
 	/* don't ever allow to reserve more than 5% of the lowmem */
 	recommended_min = min(recommended_min,
-			      (unsigned long) nr_free_buffer_pages() / 20);
+			      (unsigned long) nr_free_buffer_high_pages() / 20);
 	recommended_min <<= (PAGE_SHIFT-10);
 
 	if (recommended_min > min_free_kbytes)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0713bfb..246d0bd 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1640,7 +1640,7 @@ static struct notifier_block __cpuinitdata ratelimit_nb = {
  *
  * We used to scale dirty pages according to how total memory
  * related to pages that could be allocated for buffers (by
- * comparing nr_free_buffer_pages() to vm_total_pages.
+ * comparing nr_free_buffer_high_pages() to vm_total_pages.
  *
  * However, that was when we used "dirty_ratio" to scale with
  * all memory, and we don't do that any more. "dirty_ratio"
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4aea19e..a021d91 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2806,13 +2806,14 @@ static unsigned int nr_free_zone_high_pages(int offset)
 }
 
 /*
- * Amount of free RAM allocatable within ZONE_DMA and ZONE_NORMAL
+ * Amount of free RAM allocatable that is above high watermark
+ * within ZONE_DMA and ZONE_NORMAL
  */
-unsigned int nr_free_buffer_pages(void)
+unsigned int nr_free_buffer_high_pages(void)
 {
 	return nr_free_zone_high_pages(gfp_zone(GFP_USER));
 }
-EXPORT_SYMBOL_GPL(nr_free_buffer_pages);
+EXPORT_SYMBOL_GPL(nr_free_buffer_high_pages);
 
 /*
  * Amount of free RAM allocatable within all zones
@@ -5351,7 +5352,7 @@ int __meminit init_per_zone_wmark_min(void)
 {
 	unsigned long lowmem_kbytes;
 
-	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
+	lowmem_kbytes = nr_free_buffer_high_pages() * (PAGE_SIZE >> 10);
 
 	min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
 	if (min_free_kbytes < 128)
diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index fd05c81..da5b0bc 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -542,7 +542,7 @@ static int p9_virtio_probe(struct virtio_device *vdev)
 	init_waitqueue_head(chan->vc_wq);
 	chan->ring_bufs_avail = 1;
 	/* Ceiling limit to avoid denial of service attacks */
-	chan->p9_max_pages = nr_free_buffer_pages()/4;
+	chan->p9_max_pages = nr_free_buffer_high_pages() / 4;
 
 	mutex_lock(&virtio_9p_lock);
 	list_add_tail(&chan->chan_list, &virtio_chan_list);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2aa69c8..44a6ace 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3565,7 +3565,7 @@ __setup("thash_entries=", set_thash_entries);
 
 void tcp_init_mem(struct net *net)
 {
-	unsigned long limit = nr_free_buffer_pages() / 8;
+	unsigned long limit = nr_free_buffer_high_pages() / 8;
 	limit = max(limit, 128UL);
 	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
 	net->ipv4.sysctl_tcp_mem[1] = limit;
@@ -3635,7 +3635,7 @@ void __init tcp_init(void)
 
 	tcp_init_mem(&init_net);
 	/* Set per-socket limits to no more than 1/128 the pressure threshold */
-	limit = nr_free_buffer_pages() << (PAGE_SHIFT - 7);
+	limit = nr_free_buffer_high_pages() << (PAGE_SHIFT - 7);
 	max_wshare = min(4UL*1024*1024, limit);
 	max_rshare = min(6UL*1024*1024, limit);
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1f4d405..cd61b9f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2235,7 +2235,7 @@ void __init udp_init(void)
 	unsigned long limit;
 
 	udp_table_init(&udp_table, "UDP");
-	limit = nr_free_buffer_pages() / 8;
+	limit = nr_free_buffer_high_pages() / 8;
 	limit = max(limit, 128UL);
 	sysctl_udp_mem[0] = limit / 4 * 3;
 	sysctl_udp_mem[1] = limit;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ec664cb..a53cfb3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3723,7 +3723,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_sync_ver;
 	ipvs->sysctl_sync_ports = 1;
 	tbl[idx++].data = &ipvs->sysctl_sync_ports;
-	ipvs->sysctl_sync_qlen_max = nr_free_buffer_pages() / 32;
+	ipvs->sysctl_sync_qlen_max = nr_free_buffer_high_pages() / 32;
 	tbl[idx++].data = &ipvs->sysctl_sync_qlen_max;
 	ipvs->sysctl_sync_sock_size = 0;
 	tbl[idx++].data = &ipvs->sysctl_sync_sock_size;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index f898b1c..8c135af 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1354,7 +1354,7 @@ SCTP_STATIC __init int sctp_init(void)
 	/* Initialize handle used for association ids. */
 	idr_init(&sctp_assocs_id);
 
-	limit = nr_free_buffer_pages() / 8;
+	limit = nr_free_buffer_high_pages() / 8;
 	limit = max(limit, 128UL);
 	sysctl_sctp_mem[0] = limit / 4 * 3;
 	sysctl_sctp_mem[1] = limit;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
