Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id E0AB86B0037
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 05:27:46 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so1289241pbc.34
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 02:27:46 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id j1si10278506pbw.214.2014.06.16.02.27.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 02:27:46 -0700 (PDT)
Message-ID: <539EB7E6.6020201@huawei.com>
Date: Mon, 16 Jun 2014 17:24:54 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/8] mm: add shrink page cache core
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>

Add a new function shrink_page_cache(), it will call do_try_to_free_pages()
to reclaim the page cache.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/swap.h |    2 ++
 mm/page_alloc.c      |   12 ++++++++++++
 mm/vmscan.c          |   24 ++++++++++++++++++++++++
 3 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7e362d7..dcbe1a3 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -363,6 +363,8 @@ extern int cache_limit_ratio_sysctl_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
 extern int cache_limit_mbytes_sysctl_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
+extern unsigned long page_cache_over_limit(void);
+extern void shrink_page_cache(gfp_t mask);
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a9cc034..00707ef 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5829,6 +5829,18 @@ int cache_limit_mbytes_sysctl_handler(struct ctl_table *table, int write,
 	return 0;
 }
 
+unsigned long page_cache_over_limit(void)
+{
+	unsigned long lru_file, limit;
+
+	limit = vm_cache_limit_mbytes * ((1024 * 1024UL) / PAGE_SIZE);
+	lru_file = global_page_state(NR_ACTIVE_FILE)
+		+ global_page_state(NR_INACTIVE_FILE);
+	if (lru_file > limit)
+		return lru_file - limit;
+	return 0;
+}
+
 #ifdef CONFIG_NUMA
 int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 37ea902..ad01ff4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3389,6 +3389,30 @@ static void shrink_page_cache_init(void)
 	vm_cache_limit_mbytes_max = totalram_pages;
 }
 
+static unsigned long __shrink_page_cache(gfp_t mask)
+{
+	struct scan_control sc = {
+		.gfp_mask = (mask = memalloc_noio_flags(mask)),
+		.may_writepage = !laptop_mode,
+		.nr_to_reclaim = SWAP_CLUSTER_MAX,
+		.may_unmap = 1,
+		.may_swap = 1,
+		.order = 0,
+		.priority = DEF_PRIORITY,
+		.target_mem_cgroup = NULL,
+		.nodemask = NULL,
+	};
+	struct zonelist *zonelist = node_zonelist(numa_node_id(), mask);
+
+	return do_try_to_free_pages(zonelist, &sc);
+}
+
+void shrink_page_cache(gfp_t mask)
+{
+	/* We reclaim the highmem zone too, it is useful for 32bit arch */
+	__shrink_page_cache(mask | __GFP_HIGHMEM);
+}
+
 /* It's optimal to keep kswapds on the same CPUs as their memory, but
    not required for correctness.  So if the last cpu in a node goes
    away, we get changed to run anywhere: as the first one comes back,
-- 
1.6.0.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
