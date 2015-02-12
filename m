Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7D46382905
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:24 -0500 (EST)
Received: by pdjg10 with SMTP id g10so10212882pdj.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:24 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ja3si3992505pbc.81.2015.02.11.23.30.12
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:13 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 09/16] mm/cma: introduce cma_total_pages() for future use
Date: Thu, 12 Feb 2015 16:32:13 +0900
Message-Id: <1423726340-4084-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In the following patches, total reserved page count is needed to
initialize ZONE_CMA. This is the preparation step for that.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/cma.h |    9 +++++++++
 mm/cma.c            |   17 +++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index a93438b..aeaea90 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -15,6 +15,9 @@
 
 struct cma;
 
+#ifdef CONFIG_CMA
+extern unsigned long cma_total_pages(unsigned long node_start_pfn,
+				unsigned long node_end_pfn);
 extern phys_addr_t cma_get_base(struct cma *cma);
 extern unsigned long cma_get_size(struct cma *cma);
 
@@ -27,4 +30,10 @@ extern int cma_init_reserved_mem(phys_addr_t base,
 					struct cma **res_cma);
 extern struct page *cma_alloc(struct cma *cma, int count, unsigned int align);
 extern bool cma_release(struct cma *cma, struct page *pages, int count);
+
+#else
+static inline unsigned long cma_total_pages(unsigned long node_start_pfn,
+				unsigned long node_end_pfn) { return 0; }
+
+#endif /* CONFIG_CMA */
 #endif
diff --git a/mm/cma.c b/mm/cma.c
index c35ceef..f817b91 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -40,6 +40,23 @@ struct cma cma_areas[MAX_CMA_AREAS];
 unsigned cma_area_count;
 static DEFINE_MUTEX(cma_mutex);
 
+unsigned long cma_total_pages(unsigned long node_start_pfn,
+				unsigned long node_end_pfn)
+{
+	int i;
+	unsigned long total_pages = 0;
+
+	for (i = 0; i < cma_area_count; i++) {
+		struct cma *cma = &cma_areas[i];
+
+		if (node_start_pfn <= cma->base_pfn &&
+			cma->base_pfn < node_end_pfn)
+			total_pages += cma->count;
+	}
+
+	return total_pages;
+}
+
 phys_addr_t cma_get_base(struct cma *cma)
 {
 	return PFN_PHYS(cma->base_pfn);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
