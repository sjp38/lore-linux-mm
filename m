Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0F36B006E
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 20:35:34 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so103062pac.36
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 17:35:34 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id zn6si12344375pac.126.2014.12.18.17.35.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 17:35:32 -0800 (PST)
Message-ID: <54938052.3030809@huawei.com>
Date: Fri, 19 Dec 2014 09:33:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V2] CMA: add the amount of cma memory in meminfo
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, m.szyprowski@samsung.com, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, vishnu.ps@samsung.com
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>

Add the amount of cma memory in the following meminfo.
/proc/meminfo
/sys/devices/system/node/nodeXX/meminfo

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 drivers/base/node.c | 16 ++++++++++------
 fs/proc/meminfo.c   |  6 ++++++
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 472168c..bc123f9 100644
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
+		       ,nid, K(node_page_state(nid,
+			NR_ANON_TRANSPARENT_HUGEPAGES) * HPAGE_PMD_NR)
+#endif
+#ifdef CONFIG_CMA
+		       ,nid, K(node_page_state(nid, NR_FREE_CMA_PAGES))
 #endif
+			);
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
 }
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index aa1eee0..9a7e446 100644
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
@@ -193,6 +196,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
 		   HPAGE_PMD_NR)
 #endif
+#ifdef CONFIG_CMA
+		,K(global_page_state(NR_FREE_CMA_PAGES))
+#endif
 		);
 
 	hugetlb_report_meminfo(m);
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
