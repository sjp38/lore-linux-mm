Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1DE6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 12:09:26 -0400 (EDT)
Received: by oier21 with SMTP id r21so41954344oie.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 09:09:26 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id x5si23447607pdo.93.2015.03.16.09.09.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Mar 2015 09:09:25 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NLB00HBNBQ3F300@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Mar 2015 16:13:16 +0000 (GMT)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH v4 5/5] mm: cma: add functions to get region pages counters
Date: Mon, 16 Mar 2015 19:09:11 +0300
Message-id: 
 <a8956273a6dacb3df330ab9d7a84b7038fedbb50.1426521377.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1426521377.git.s.strogin@partner.samsung.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>, Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

From: Dmitry Safonov <d.safonov@partner.samsung.com>

Here are two functions that provide interface to compute/get used size
and size of biggest free chunk in cma region. Add that information to debugfs.

Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
---
 include/linux/cma.h |  2 ++
 mm/cma.c            | 30 ++++++++++++++++++++++++++++++
 mm/cma_debug.c      | 24 ++++++++++++++++++++++++
 3 files changed, 56 insertions(+)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index f7ef093..1231f50 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -18,6 +18,8 @@ struct cma;
 extern unsigned long totalcma_pages;
 extern phys_addr_t cma_get_base(const struct cma *cma);
 extern unsigned long cma_get_size(const struct cma *cma);
+extern unsigned long cma_get_used(struct cma *cma);
+extern unsigned long cma_get_maxchunk(struct cma *cma);
 
 extern int __init cma_declare_contiguous(phys_addr_t base,
 			phys_addr_t size, phys_addr_t limit,
diff --git a/mm/cma.c b/mm/cma.c
index faf8eac..78b262a 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -53,6 +53,36 @@ unsigned long cma_get_size(const struct cma *cma)
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
 static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
 					     int align_order)
 {
diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 20bad2d..e1ba160 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -146,6 +146,28 @@ static int cma_debugfs_get(void *data, u64 *val)
 
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
@@ -349,6 +371,8 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 				&cma->count, &cma_debugfs_fops);
 	debugfs_create_file("order_per_bit", S_IRUGO, tmp,
 				&cma->order_per_bit, &cma_debugfs_fops);
+	debugfs_create_file("used", S_IRUGO, tmp, cma, &cma_used_fops);
+	debugfs_create_file("maxchunk", S_IRUGO, tmp, cma, &cma_maxchunk_fops);
 #ifdef CONFIG_CMA_BUFFER_LIST
 	debugfs_create_file("buffers", S_IRUGO, tmp, cma,
 				&cma_buffers_fops);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
