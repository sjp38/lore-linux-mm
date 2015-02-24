Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D1A4E6B0075
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:45:22 -0500 (EST)
Received: by paceu11 with SMTP id eu11so37978937pac.10
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:45:22 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id vy6si8163496pbc.138.2015.02.24.10.45.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 24 Feb 2015 10:45:21 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKA00BBSHM8M450@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Feb 2015 18:49:20 +0000 (GMT)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH v3 4/4] mm: cma: add functions to get region pages counters
Date: Tue, 24 Feb 2015 21:44:35 +0300
Message-id: 
 <39c295d8354268391d62904ec57626596c835d34.1424802755.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>, Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

From: Dmitry Safonov <d.safonov@partner.samsung.com>

Here are two functions that provide interface to compute/get used size
and size of biggest free chunk in cma region. Add that information to debugfs.

Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>
---
 include/linux/cma.h |  2 ++
 mm/cma.c            | 30 ++++++++++++++++++++++++++++++
 mm/cma_debug.c      | 24 ++++++++++++++++++++++++
 3 files changed, 56 insertions(+)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index 9384ba6..855e6f2 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -18,6 +18,8 @@ struct cma;
 extern unsigned long totalcma_pages;
 extern phys_addr_t cma_get_base(struct cma *cma);
 extern unsigned long cma_get_size(struct cma *cma);
+extern unsigned long cma_get_used(struct cma *cma);
+extern unsigned long cma_get_maxchunk(struct cma *cma);
 
 extern int __init cma_declare_contiguous(phys_addr_t base,
 			phys_addr_t size, phys_addr_t limit,
diff --git a/mm/cma.c b/mm/cma.c
index e97c0ad..51f9d83 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -53,6 +53,36 @@ unsigned long cma_get_size(struct cma *cma)
 	return cma->count << PAGE_SHIFT;
 }
 
+unsigned long cma_get_used(struct cma *cma)
+{
+	unsigned long ret = 0;
+
+	mutex_lock(&cma->lock);
+	/* pages counter is smaller than sizeof(int) */
+	ret = bitmap_weight(cma->bitmap, (int)cma->count);
+	mutex_unlock(&cma->lock);
+
+	return ret << cma->order_per_bit;
+}
+
+unsigned long cma_get_maxchunk(struct cma *cma)
+{
+	unsigned long maxchunk = 0;
+	unsigned long start, end = 0;
+
+	mutex_lock(&cma->lock);
+	for (;;) {
+		start = find_next_zero_bit(cma->bitmap, cma->count, end);
+		if (start >= cma->count)
+			break;
+		end = find_next_bit(cma->bitmap, cma->count, start);
+		maxchunk = max(end - start, maxchunk);
+	}
+	mutex_unlock(&cma->lock);
+
+	return maxchunk << cma->order_per_bit;
+}
+
 static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
 {
 	if (align_order <= cma->order_per_bit)
diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index cb74a0c..f995b07 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -133,6 +133,28 @@ static int cma_debugfs_get(void *data, u64 *val)
 
 DEFINE_SIMPLE_ATTRIBUTE(cma_debugfs_fops, cma_debugfs_get, NULL, "%llu\n");
 
+static int cma_used_get(void *data, u64 *val)
+{
+	struct cma *cma = data;
+
+	*val = cma_get_used(cma);
+
+	return 0;
+}
+
+DEFINE_SIMPLE_ATTRIBUTE(cma_used_fops, cma_used_get, NULL, "%llu\n");
+
+static int cma_maxchunk_get(void *data, u64 *val)
+{
+	struct cma *cma = data;
+
+	*val = cma_get_maxchunk(cma);
+
+	return 0;
+}
+
+DEFINE_SIMPLE_ATTRIBUTE(cma_maxchunk_fops, cma_maxchunk_get, NULL, "%llu\n");
+
 static void cma_add_to_cma_mem_list(struct cma *cma, struct cma_mem *mem)
 {
 	spin_lock(&cma->mem_head_lock);
@@ -300,6 +322,8 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 				&cma->count, &cma_debugfs_fops);
 	debugfs_create_file("order_per_bit", S_IRUGO, tmp,
 				&cma->order_per_bit, &cma_debugfs_fops);
+	debugfs_create_file("used", S_IRUGO, tmp, cma, &cma_used_fops);
+	debugfs_create_file("maxchunk", S_IRUGO, tmp, cma, &cma_maxchunk_fops);
 #ifdef CONFIG_CMA_BUFFER_LIST
 	debugfs_create_file("buffers", S_IRUGO, tmp, cma,
 				&cma_buffer_list_fops);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
