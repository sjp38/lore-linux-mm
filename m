Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 000AD6B0038
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 12:26:11 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so48497586wjb.7
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 09:26:11 -0800 (PST)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id t131si3533856wmf.99.2017.01.27.09.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 09:26:10 -0800 (PST)
From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH v2 2/3] mm: cma_alloc: allow to specify GFP mask
Date: Fri, 27 Jan 2017 18:23:27 +0100
Message-Id: <20170127172328.18574-2-l.stach@pengutronix.de>
In-Reply-To: <20170127172328.18574-1-l.stach@pengutronix.de>
References: <20170127172328.18574-1-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mips@linux-mips.org, Michal Hocko <mhocko@suse.com>, kvm@vger.kernel.org, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Max Filippov <jcmvbkbc@gmail.com>, "H . Peter Anvin" <hpa@zytor.com>, Joerg Roedel <joro@8bytes.org>, Russell King <linux@armlinux.org.uk>, patchwork-lst@pengutronix.de, Ingo Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-xtensa@linux-xtensa.org, kvm-ppc@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Chris Zankel <chris@zankel.net>, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, iommu@lists.linux-foundation.org, kernel@pengutronix.de, Paolo Bonzini <pbonzini@redhat.com>, David Woodhouse <dwmw2@infradead.org>, Alexander Graf <agraf@suse.com>

Most users of this interface just want to use it with the default
GFP_KERNEL flags, but for cases where DMA memory is allocated it may
be called from a different context.

No functional change yet, just passing through the flag to the
underlying alloc_contig_range function.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/powerpc/kvm/book3s_hv_builtin.c | 3 ++-
 drivers/base/dma-contiguous.c        | 2 +-
 include/linux/cma.h                  | 3 ++-
 mm/cma.c                             | 5 +++--
 mm/cma_debug.c                       | 2 +-
 5 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv_builtin.c b/arch/powerpc/kvm/book3s_hv_builtin.c
index 5bb24be0b346..56a62d97ab2d 100644
--- a/arch/powerpc/kvm/book3s_hv_builtin.c
+++ b/arch/powerpc/kvm/book3s_hv_builtin.c
@@ -56,7 +56,8 @@ struct page *kvm_alloc_hpt(unsigned long nr_pages)
 {
 	VM_BUG_ON(order_base_2(nr_pages) < KVM_CMA_CHUNK_ORDER - PAGE_SHIFT);
 
-	return cma_alloc(kvm_cma, nr_pages, order_base_2(HPT_ALIGN_PAGES));
+	return cma_alloc(kvm_cma, nr_pages, order_base_2(HPT_ALIGN_PAGES),
+			 GFP_KERNEL);
 }
 EXPORT_SYMBOL_GPL(kvm_alloc_hpt);
 
diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index e167a1e1bccb..d1a9cbabc627 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -193,7 +193,7 @@ struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
 	if (align > CONFIG_CMA_ALIGNMENT)
 		align = CONFIG_CMA_ALIGNMENT;
 
-	return cma_alloc(dev_get_cma_area(dev), count, align);
+	return cma_alloc(dev_get_cma_area(dev), count, align, GFP_KERNEL);
 }
 
 /**
diff --git a/include/linux/cma.h b/include/linux/cma.h
index 6f0a91b37f68..03f32d0bd1d8 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -29,6 +29,7 @@ extern int __init cma_declare_contiguous(phys_addr_t base,
 extern int cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 					unsigned int order_per_bit,
 					struct cma **res_cma);
-extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align);
+extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
+			      gfp_t gfp_mask);
 extern bool cma_release(struct cma *cma, const struct page *pages, unsigned int count);
 #endif
diff --git a/mm/cma.c b/mm/cma.c
index fbd67d866f67..a33ddfde315d 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -362,7 +362,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
  * This function allocates part of contiguous memory on specific
  * contiguous memory area.
  */
-struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
+struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
+		       gfp_t gfp_mask)
 {
 	unsigned long mask, offset;
 	unsigned long pfn = -1;
@@ -408,7 +409,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
 		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
 		mutex_lock(&cma_mutex);
 		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA,
-					 GFP_KERNEL);
+					 gfp_mask);
 		mutex_unlock(&cma_mutex);
 		if (ret == 0) {
 			page = pfn_to_page(pfn);
diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index f8e4b60db167..ffc0c3d0ae64 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -138,7 +138,7 @@ static int cma_alloc_mem(struct cma *cma, int count)
 	if (!mem)
 		return -ENOMEM;
 
-	p = cma_alloc(cma, count, 0);
+	p = cma_alloc(cma, count, 0, GFP_KERNEL);
 	if (!p) {
 		kfree(mem);
 		return -ENOMEM;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
