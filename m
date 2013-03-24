Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 974E26B00D1
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:34:23 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bg2so541399pad.9
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:34:22 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 33/39] mm/tile: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:25:23 +0800
Message-Id: <1364109934-7851-58-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Bjorn Helgaas <bhelgaas@google.com>, "David S. Miller" <davem@davemloft.net>

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/tile/kernel/setup.c |   16 ++++++++--------
 arch/tile/mm/init.c      |   15 +--------------
 2 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/arch/tile/kernel/setup.c b/arch/tile/kernel/setup.c
index a986b71..54469a5 100644
--- a/arch/tile/kernel/setup.c
+++ b/arch/tile/kernel/setup.c
@@ -329,6 +329,7 @@ static void __init setup_memory(void)
 #if defined(CONFIG_HIGHMEM) || defined(__tilegx__)
 	long lowmem_pages;
 #endif
+	unsigned long physpages = 0;
 
 	/* We are using a char to hold the cpu_2_node[] mapping */
 	BUILD_BUG_ON(MAX_NUMNODES > 127);
@@ -388,8 +389,8 @@ static void __init setup_memory(void)
 				continue;
 			}
 		}
-		if (num_physpages + PFN_DOWN(range.size) > maxmem_pfn) {
-			int max_size = maxmem_pfn - num_physpages;
+		if (physpages + PFN_DOWN(range.size) > maxmem_pfn) {
+			int max_size = maxmem_pfn - physpages;
 			if (max_size > 0) {
 				pr_err("Maxmem reduced node %d to %d pages\n",
 				       i, max_size);
@@ -446,7 +447,7 @@ static void __init setup_memory(void)
 		node_start_pfn[i] = start;
 		node_end_pfn[i] = end;
 		node_controller[i] = range.controller;
-		num_physpages += size;
+		physpages += size;
 		max_pfn = end;
 
 		/* Mark node as online */
@@ -465,7 +466,7 @@ static void __init setup_memory(void)
 	 * we're willing to use at 8 million pages (32GB of 4KB pages).
 	 */
 	cap = 8 * 1024 * 1024;  /* 8 million pages */
-	if (num_physpages > cap) {
+	if (physpages > cap) {
 		int num_nodes = num_online_nodes();
 		int cap_each = cap / num_nodes;
 		unsigned long dropped_pages = 0;
@@ -476,10 +477,10 @@ static void __init setup_memory(void)
 				node_end_pfn[i] = node_start_pfn[i] + cap_each;
 			}
 		}
-		num_physpages -= dropped_pages;
+		physpages -= dropped_pages;
 		pr_warning("Only using %ldMB memory;"
 		       " ignoring %ldMB.\n",
-		       num_physpages >> (20 - PAGE_SHIFT),
+		       physpages >> (20 - PAGE_SHIFT),
 		       dropped_pages >> (20 - PAGE_SHIFT));
 		pr_warning("Consider using a larger page size.\n");
 	}
@@ -497,7 +498,7 @@ static void __init setup_memory(void)
 
 	lowmem_pages = (mappable_physpages > MAXMEM_PFN) ?
 		MAXMEM_PFN : mappable_physpages;
-	highmem_pages = (long) (num_physpages - lowmem_pages);
+	highmem_pages = (long) (physpages - lowmem_pages);
 
 	pr_notice("%ldMB HIGHMEM available.\n",
 	       pages_to_mb(highmem_pages > 0 ? highmem_pages : 0));
@@ -514,7 +515,6 @@ static void __init setup_memory(void)
 		pr_warning("Use a HIGHMEM enabled kernel.\n");
 		max_low_pfn = MAXMEM_PFN;
 		max_pfn = MAXMEM_PFN;
-		num_physpages = MAXMEM_PFN;
 		node_end_pfn[0] = MAXMEM_PFN;
 	} else {
 		pr_notice("%ldMB memory available.\n",
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index f2ac2f4..e182958 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -821,7 +821,6 @@ static void __init set_max_mapnr_init(void)
 
 void __init mem_init(void)
 {
-	int codesize, datasize, initsize;
 	int i;
 #ifndef __tilegx__
 	void *last;
@@ -853,19 +852,7 @@ void __init mem_init(void)
 	set_non_bootmem_pages_init();
 #endif
 
-	codesize =  (unsigned long)&_etext - (unsigned long)&_text;
-	datasize =  (unsigned long)&_end - (unsigned long)&_sdata;
-	initsize =  (unsigned long)&_einittext - (unsigned long)&_sinittext;
-	initsize += (unsigned long)&_einitdata - (unsigned long)&_sinitdata;
-
-	pr_info("Memory: %luk/%luk available (%dk kernel code, %dk data, %dk init, %ldk highmem)\n",
-		(unsigned long) nr_free_pages() << (PAGE_SHIFT-10),
-		num_physpages << (PAGE_SHIFT-10),
-		codesize >> 10,
-		datasize >> 10,
-		initsize >> 10,
-		(unsigned long) (totalhigh_pages << (PAGE_SHIFT-10))
-	       );
+	mem_init_print_info(NULL);
 
 	/*
 	 * In debug mode, dump some interesting memory mappings.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
