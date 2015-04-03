Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 68B6A6B0032
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 08:42:53 -0400 (EDT)
Received: by patj18 with SMTP id j18so115450336pat.2
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 05:42:53 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id e12si11873128pat.195.2015.04.03.05.42.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 03 Apr 2015 05:42:51 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NM80029GE5XI230@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 03 Apr 2015 13:46:45 +0100 (BST)
From: Stefan Strogin <stefan.strogin@gmail.com>
Subject: [PATCH] mm: cma: add functions to get region pages counters
Date: Fri, 03 Apr 2015 15:42:40 +0300
Message-id: <1428064960-8279-1-git-send-email-stefan.strogin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>, Stefan Strogin <s.strogin@partner.samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Pintu Kumar <pintu.k@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, Stefan Strogin <stefan.strogin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>

From: Dmitry Safonov <d.safonov@partner.samsung.com>

Here are two functions that provide interface to compute/get used size
and size of biggest free chunk in cma region. Add that information to debugfs.

Signed-off-by: Dmitry Safonov <d.safonov@partner.samsung.com>
Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
---

Took out from the patch set "mm: cma: add some debug information for CMA" v4
(http://thread.gmane.org/gmane.linux.kernel.mm/129903) because of probable
uselessness of the most part of the set.

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
index 3a7a67b..d839011 100644
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
index ec915e6..984cedd 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -33,6 +33,28 @@ static int cma_debugfs_get(void *data, u64 *val)
 
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
@@ -149,6 +171,8 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 				&cma->count, &cma_debugfs_fops);
 	debugfs_create_file("order_per_bit", S_IRUGO, tmp,
 				&cma->order_per_bit, &cma_debugfs_fops);
+	debugfs_create_file("used", S_IRUGO, tmp, cma, &cma_used_fops);
+	debugfs_create_file("maxchunk", S_IRUGO, tmp, cma, &cma_maxchunk_fops);
 
 	u32s = DIV_ROUND_UP(cma_bitmap_maxno(cma), BITS_PER_BYTE * sizeof(u32));
 	debugfs_create_u32_array("bitmap", S_IRUGO, tmp, (u32*)cma->bitmap, u32s);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
