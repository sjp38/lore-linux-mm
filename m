Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1B242900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:12:40 -0400 (EDT)
Received: by oihd6 with SMTP id d6so30789588oih.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:12:39 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 203si1626440oic.114.2015.06.04.06.12.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:12:39 -0700 (PDT)
Message-ID: <55704C1C.6040101@huawei.com>
Date: Thu, 4 Jun 2015 21:01:16 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 06/12] mm: add free mirrored pages info
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add the count of free mirrored pages in the following paths:
/proc/meminfo
/proc/zoneinfo
/sys/devices/system/node/node XX/meminfo
/sys/devices/system/node/node XX/vmstat

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 drivers/base/node.c | 17 +++++++++++------
 fs/proc/meminfo.c   |  6 ++++++
 mm/page_alloc.c     |  7 +++++--
 3 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index a2aa65b..d1a3556 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -114,6 +114,9 @@ static ssize_t node_read_meminfo(struct device *dev,
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       "Node %d AnonHugePages:  %8lu kB\n"
 #endif
+#ifdef CONFIG_MEMORY_MIRROR
+		       "Node %d MirrorFree:     %8lu kB\n"
+#endif
 			,
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
 		       nid, K(node_page_state(nid, NR_WRITEBACK)),
@@ -130,14 +133,16 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE) +
 				node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
 		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE)),
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE))
-			, nid,
-			K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
-			HPAGE_PMD_NR));
-#else
-		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		     , nid, K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
+				HPAGE_PMD_NR)
+#endif
+#ifdef CONFIG_MEMORY_MIRROR
+		     , nid, K(node_page_state(nid, NR_FREE_MIRROR_PAGES))
 #endif
+			);
+
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
 }
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index d3ebf2e..d1ebb20 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -145,6 +145,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		"CmaTotal:       %8lu kB\n"
 		"CmaFree:        %8lu kB\n"
 #endif
+#ifdef CONFIG_MEMORY_MIRROR
+		"MirrorFree:     %8lu kB\n"
+#endif
 		,
 		K(i.totalram),
 		K(i.freeram),
@@ -204,6 +207,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		, K(totalcma_pages)
 		, K(global_page_state(NR_FREE_CMA_PAGES))
 #endif
+#ifdef CONFIG_MEMORY_MIRROR
+		, K(global_page_state(NR_FREE_MIRROR_PAGES))
+#endif
 		);
 
 	hugetlb_report_meminfo(m);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fe0187..249a8f6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3316,7 +3316,7 @@ void show_free_areas(unsigned int filter)
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-		" free:%lu free_pcp:%lu free_cma:%lu\n",
+		" free:%lu free_pcp:%lu free_cma:%lu free_mirror:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_ISOLATED_ANON),
@@ -3335,7 +3335,8 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_BOUNCE),
 		global_page_state(NR_FREE_PAGES),
 		free_pcp,
-		global_page_state(NR_FREE_CMA_PAGES));
+		global_page_state(NR_FREE_CMA_PAGES),
+		global_page_state(NR_FREE_MIRROR_PAGES));
 
 	for_each_populated_zone(zone) {
 		int i;
@@ -3376,6 +3377,7 @@ void show_free_areas(unsigned int filter)
 			" free_pcp:%lukB"
 			" local_pcp:%ukB"
 			" free_cma:%lukB"
+			" free_mirror:%lukB"
 			" writeback_tmp:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -3409,6 +3411,7 @@ void show_free_areas(unsigned int filter)
 			K(free_pcp),
 			K(this_cpu_read(zone->pageset->pcp.count)),
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
+			K(zone_page_state(zone, NR_FREE_MIRROR_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			K(zone_page_state(zone, NR_PAGES_SCANNED)),
 			(!zone_reclaimable(zone) ? "yes" : "no")
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
