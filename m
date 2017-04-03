Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 953596B0397
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 14:58:14 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v78so14038485qkl.10
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:14 -0700 (PDT)
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com. [209.85.220.177])
        by mx.google.com with ESMTPS id q66si6214478qki.83.2017.04.03.11.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 11:58:13 -0700 (PDT)
Received: by mail-qk0-f177.google.com with SMTP id p22so122961324qka.3
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:13 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 01/22] cma: Store a name in the cma structure
Date: Mon,  3 Apr 2017 11:57:43 -0700
Message-Id: <1491245884-15852-2-git-send-email-labbott@redhat.com>
In-Reply-To: <1491245884-15852-1-git-send-email-labbott@redhat.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

Frameworks that may want to enumerate CMA heaps (e.g. Ion) will find it
useful to have an explicit name attached to each region. Store the name
in each CMA structure.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v3: Added default name suggestion per Sumit. Fixup powerpc call site.
---
 arch/powerpc/kvm/book3s_hv_builtin.c |  3 ++-
 drivers/base/dma-contiguous.c        |  5 +++--
 include/linux/cma.h                  |  4 +++-
 mm/cma.c                             | 17 +++++++++++++++--
 mm/cma.h                             |  1 +
 mm/cma_debug.c                       |  2 +-
 6 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv_builtin.c b/arch/powerpc/kvm/book3s_hv_builtin.c
index 4d6c64b..b739ff8 100644
--- a/arch/powerpc/kvm/book3s_hv_builtin.c
+++ b/arch/powerpc/kvm/book3s_hv_builtin.c
@@ -100,7 +100,8 @@ void __init kvm_cma_reserve(void)
 			 (unsigned long)selected_size / SZ_1M);
 		align_size = HPT_ALIGN_PAGES << PAGE_SHIFT;
 		cma_declare_contiguous(0, selected_size, 0, align_size,
-			KVM_CMA_CHUNK_ORDER - PAGE_SHIFT, false, &kvm_cma);
+			KVM_CMA_CHUNK_ORDER - PAGE_SHIFT, false, "kvm_cma",
+			&kvm_cma);
 	}
 }
 
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
index a6033e3..43c1b2c 100644
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
@@ -198,6 +204,13 @@ int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 	 * subsystems (like slab allocator) are available.
 	 */
 	cma = &cma_areas[cma_area_count];
+	if (name) {
+		cma->name = name;
+	} else {
+		cma->name = kasprintf(GFP_KERNEL, "cma%d\n", cma_area_count);
+		if (!cma->name)
+			return -ENOMEM;
+	}
 	cma->base_pfn = PFN_DOWN(base);
 	cma->count = size >> PAGE_SHIFT;
 	cma->order_per_bit = order_per_bit;
@@ -229,7 +242,7 @@ int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 int __init cma_declare_contiguous(phys_addr_t base,
 			phys_addr_t size, phys_addr_t limit,
 			phys_addr_t alignment, unsigned int order_per_bit,
-			bool fixed, struct cma **res_cma)
+			bool fixed, const char *name, struct cma **res_cma)
 {
 	phys_addr_t memblock_end = memblock_end_of_DRAM();
 	phys_addr_t highmem_start;
@@ -335,7 +348,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
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
