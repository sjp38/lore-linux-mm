Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 68BCF6B018B
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 10:43:42 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rp8so2457163pbb.5
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 07:43:41 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 12/41] mm/ARC: prepare for removing num_physpages and simplify mem_init()
Date: Sat,  6 Apr 2013 22:32:11 +0800
Message-Id: <1365258760-30821-13-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Vineet Gupta <vgupta@synopsys.com>, James Hogan <james.hogan@imgtec.com>, Rob Herring <rob.herring@calxeda.com>

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/arc/mm/init.c |   36 +++---------------------------------
 1 file changed, 3 insertions(+), 33 deletions(-)

diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index 78d8c31..8ba6562 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -74,7 +74,7 @@ void __init setup_arch_memory(void)
 	/* Last usable page of low mem (no HIGHMEM yet for ARC port) */
 	max_low_pfn = max_pfn = PFN_DOWN(end_mem);
 
-	max_mapnr = num_physpages = max_low_pfn - min_low_pfn;
+	max_mapnr = max_low_pfn - min_low_pfn;
 
 	/*------------- reserve kernel image -----------------------*/
 	memblock_reserve(CONFIG_LINUX_LINK_BASE,
@@ -84,7 +84,7 @@ void __init setup_arch_memory(void)
 
 	/*-------------- node setup --------------------------------*/
 	memset(zones_size, 0, sizeof(zones_size));
-	zones_size[ZONE_NORMAL] = num_physpages;
+	zones_size[ZONE_NORMAL] = max_low_pfn - min_low_pfn;
 
 	/*
 	 * We can't use the helper free_area_init(zones[]) because it uses
@@ -106,39 +106,9 @@ void __init setup_arch_memory(void)
  */
 void __init mem_init(void)
 {
-	int codesize, datasize, initsize, reserved_pages, free_pages;
-	int tmp;
-
 	high_memory = (void *)(CONFIG_LINUX_LINK_BASE + arc_mem_sz);
-
 	free_all_bootmem();
-
-	/* count all reserved pages [kernel code/data/mem_map..] */
-	reserved_pages = 0;
-	for (tmp = 0; tmp < max_mapnr; tmp++)
-		if (PageReserved(mem_map + tmp))
-			reserved_pages++;
-
-	/* XXX: nr_free_pages() is equivalent */
-	free_pages = max_mapnr - reserved_pages;
-
-	/*
-	 * For the purpose of display below, split the "reserve mem"
-	 * kernel code/data is already shown explicitly,
-	 * Show any other reservations (mem_map[ ] et al)
-	 */
-	reserved_pages -= (((unsigned int)_end - CONFIG_LINUX_LINK_BASE) >>
-								PAGE_SHIFT);
-
-	codesize = _etext - _text;
-	datasize = _end - _etext;
-	initsize = __init_end - __init_begin;
-
-	pr_info("Memory Available: %dM / %ldM (%dK code, %dK data, %dK init, %dK reserv)\n",
-		PAGES_TO_MB(free_pages),
-		TO_MB(arc_mem_sz),
-		TO_KB(codesize), TO_KB(datasize), TO_KB(initsize),
-		PAGES_TO_KB(reserved_pages));
+	mem_init_print_info(NULL);
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
