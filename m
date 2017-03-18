Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE13E6B038B
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:03 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p5so80515842qtb.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:03 -0700 (PDT)
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com. [209.85.216.180])
        by mx.google.com with ESMTPS id t126si7670111qkf.303.2017.03.17.17.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:55:03 -0700 (PDT)
Received: by mail-qt0-f180.google.com with SMTP id i34so75398234qtc.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:03 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 01/21] cma: Store a name in the cma structure
Date: Fri, 17 Mar 2017 17:54:33 -0700
Message-Id: <1489798493-16600-2-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


Frameworks that may want to enumerate CMA heaps (e.g. Ion) will find it
useful to have an explicit name attached to each region. Store the name
in each CMA structure.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/base/dma-contiguous.c |  5 +++--
 include/linux/cma.h           |  4 +++-
 mm/cma.c                      | 11 +++++++++--
 mm/cma.h                      |  1 +
 mm/cma_debug.c                |  2 +-
 5 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index b55804c..ea9726e 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -165,7 +165,8 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
 {
 	int ret;
 
-	ret = cma_declare_contiguous(base, size, limit, 0, 0, fixed, res_cma);
+	ret = cma_declare_contiguous(base, size, limit, 0, 0, fixed,
+					"reserved", res_cma);
 	if (ret)
 		return ret;
 
@@ -258,7 +259,7 @@ static int __init rmem_cma_setup(struct reserved_mem *rmem)
 		return -EINVAL;
 	}
 
-	err = cma_init_reserved_mem(rmem->base, rmem->size, 0, &cma);
+	err = cma_init_reserved_mem(rmem->base, rmem->size, 0, rmem->name, &cma);
 	if (err) {
 		pr_err("Reserved memory: unable to setup CMA region\n");
 		return err;
diff --git a/include/linux/cma.h b/include/linux/cma.h
index 03f32d0..d41d1f8 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -21,13 +21,15 @@ struct cma;
 extern unsigned long totalcma_pages;
 extern phys_addr_t cma_get_base(const struct cma *cma);
 extern unsigned long cma_get_size(const struct cma *cma);
+extern const char *cma_get_name(const struct cma *cma);
 
 extern int __init cma_declare_contiguous(phys_addr_t base,
 			phys_addr_t size, phys_addr_t limit,
 			phys_addr_t alignment, unsigned int order_per_bit,
-			bool fixed, struct cma **res_cma);
+			bool fixed, const char *name, struct cma **res_cma);
 extern int cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 					unsigned int order_per_bit,
+					const char *name,
 					struct cma **res_cma);
 extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 			      gfp_t gfp_mask);
diff --git a/mm/cma.c b/mm/cma.c
index a6033e3..0d187b1 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -53,6 +53,11 @@ unsigned long cma_get_size(const struct cma *cma)
 	return cma->count << PAGE_SHIFT;
 }
 
+const char *cma_get_name(const struct cma *cma)
+{
+	return cma->name ? cma->name : "(undefined)";
+}
+
 static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
 					     int align_order)
 {
@@ -168,6 +173,7 @@ core_initcall(cma_init_reserved_areas);
  */
 int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 				 unsigned int order_per_bit,
+				 const char *name,
 				 struct cma **res_cma)
 {
 	struct cma *cma;
@@ -201,6 +207,7 @@ int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 	cma->base_pfn = PFN_DOWN(base);
 	cma->count = size >> PAGE_SHIFT;
 	cma->order_per_bit = order_per_bit;
+	cma->name = name;
 	*res_cma = cma;
 	cma_area_count++;
 	totalcma_pages += (size / PAGE_SIZE);
@@ -229,7 +236,7 @@ int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 int __init cma_declare_contiguous(phys_addr_t base,
 			phys_addr_t size, phys_addr_t limit,
 			phys_addr_t alignment, unsigned int order_per_bit,
-			bool fixed, struct cma **res_cma)
+			bool fixed, const char *name, struct cma **res_cma)
 {
 	phys_addr_t memblock_end = memblock_end_of_DRAM();
 	phys_addr_t highmem_start;
@@ -335,7 +342,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
 		base = addr;
 	}
 
-	ret = cma_init_reserved_mem(base, size, order_per_bit, res_cma);
+	ret = cma_init_reserved_mem(base, size, order_per_bit, name, res_cma);
 	if (ret)
 		goto err;
 
diff --git a/mm/cma.h b/mm/cma.h
index 17c75a4..4986128 100644
--- a/mm/cma.h
+++ b/mm/cma.h
@@ -11,6 +11,7 @@ struct cma {
 	struct hlist_head mem_head;
 	spinlock_t mem_head_lock;
 #endif
+	const char *name;
 };
 
 extern struct cma cma_areas[MAX_CMA_AREAS];
diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index ffc0c3d..595b757 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -167,7 +167,7 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 	char name[16];
 	int u32s;
 
-	sprintf(name, "cma-%d", idx);
+	sprintf(name, "cma-%s", cma->name);
 
 	tmp = debugfs_create_dir(name, cma_debugfs_root);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
