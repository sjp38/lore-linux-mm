Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3EC6B0032
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 21:56:33 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wp18so12668159obc.1
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 18:56:32 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id ge9si16950228obb.99.2014.12.03.18.56.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 18:56:32 -0800 (PST)
Message-ID: <547FCCE9.2020600@huawei.com>
Date: Thu, 4 Dec 2014 10:54:33 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] CMA: add the amount of cma memory in meminfo
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, m.szyprowski@samsung.com, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>

Add the amount of cma memory in the following meminfo.
/proc/meminfo
/sys/devices/system/node/nodeXX/meminfo

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 drivers/base/node.c | 16 ++++++++++------
 fs/proc/meminfo.c   | 12 +++++++++---
 2 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 472168c..a27e4e0 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -120,6 +120,9 @@ static ssize_t node_read_meminfo(struct device *dev,
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       "Node %d AnonHugePages:  %8lu kB\n"
 #endif
+#ifdef CONFIG_CMA
+		       "Node %d FreeCMAPages:   %8lu kB\n"
+#endif
 			,
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
 		       nid, K(node_page_state(nid, NR_WRITEBACK)),
@@ -136,14 +139,15 @@ static ssize_t node_read_meminfo(struct device *dev,
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
+		       , nid, K(node_page_state(nid,
+				NR_ANON_TRANSPARENT_HUGEPAGES) * HPAGE_PMD_NR)
+#endif
+#ifdef CONFIG_CMA
+		       , nid, K(node_page_state(nid, NR_FREE_CMA_PAGES))
 #endif
+			);
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
 }
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index aa1eee0..d42e082 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -138,6 +138,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		"AnonHugePages:  %8lu kB\n"
 #endif
+#ifdef CONFIG_CMA
+		"FreeCMAPages:   %8lu kB\n"
+#endif
 		,
 		K(i.totalram),
 		K(i.freeram),
@@ -187,11 +190,14 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		vmi.used >> 10,
 		vmi.largest_chunk >> 10
 #ifdef CONFIG_MEMORY_FAILURE
-		,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
+		, atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
-		   HPAGE_PMD_NR)
+		, K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
+				HPAGE_PMD_NR)
+#endif
+#ifdef CONFIG_CMA
+		, K(global_page_state(NR_FREE_CMA_PAGES))
 #endif
 		);
 
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
