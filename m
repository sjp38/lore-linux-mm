Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id DFB3B6B005A
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 07:28:01 -0500 (EST)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LWN007O3PAMTC@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 23 Dec 2011 12:27:58 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWN008DGPALPZ@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Dec 2011 12:27:58 +0000 (GMT)
Date: Fri, 23 Dec 2011 13:27:22 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 03/14] MIPS: adapt for dma_map_ops changes
In-reply-to: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1324643253-3024-4-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Adapt core MIPS architecture code for dma_map_ops changes: replace
alloc/free_coherent with generic alloc/free methods.

Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/mips/include/asm/dma-mapping.h |   18 ++++++++++++------
 arch/mips/mm/dma-default.c          |    8 ++++----
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/arch/mips/include/asm/dma-mapping.h b/arch/mips/include/asm/dma-mapping.h
index 7aa37dd..cbd41f5 100644
--- a/arch/mips/include/asm/dma-mapping.h
+++ b/arch/mips/include/asm/dma-mapping.h
@@ -57,25 +57,31 @@ dma_set_mask(struct device *dev, u64 mask)
 extern void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 	       enum dma_data_direction direction);
 
-static inline void *dma_alloc_coherent(struct device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t gfp)
+#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
+
+static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+				    dma_addr_t *dma_handle, gfp_t gfp,
+				    struct dma_attrs *attrs)
 {
 	void *ret;
 	struct dma_map_ops *ops = get_dma_ops(dev);
 
-	ret = ops->alloc_coherent(dev, size, dma_handle, gfp);
+	ret = ops->alloc(dev, size, dma_handle, gfp, NULL);
 
 	debug_dma_alloc_coherent(dev, size, *dma_handle, ret);
 
 	return ret;
 }
 
-static inline void dma_free_coherent(struct device *dev, size_t size,
-				     void *vaddr, dma_addr_t dma_handle)
+#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
+
+static inline void dma_free_attrs(struct device *dev, size_t size,
+				  void *vaddr, dma_addr_t dma_handle,
+				  struct dma_attrs *attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 
-	ops->free_coherent(dev, size, vaddr, dma_handle);
+	ops->free(dev, size, vaddr, dma_handle, NULL);
 
 	debug_dma_free_coherent(dev, size, vaddr, dma_handle);
 }
diff --git a/arch/mips/mm/dma-default.c b/arch/mips/mm/dma-default.c
index 4608491..3fab204 100644
--- a/arch/mips/mm/dma-default.c
+++ b/arch/mips/mm/dma-default.c
@@ -98,7 +98,7 @@ void *dma_alloc_noncoherent(struct device *dev, size_t size,
 EXPORT_SYMBOL(dma_alloc_noncoherent);
 
 static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
-	dma_addr_t * dma_handle, gfp_t gfp)
+	dma_addr_t * dma_handle, gfp_t gfp, struct dma_attrs *attrs)
 {
 	void *ret;
 
@@ -132,7 +132,7 @@ void dma_free_noncoherent(struct device *dev, size_t size, void *vaddr,
 EXPORT_SYMBOL(dma_free_noncoherent);
 
 static void mips_dma_free_coherent(struct device *dev, size_t size, void *vaddr,
-	dma_addr_t dma_handle)
+	dma_addr_t dma_handle, struct dma_attrs *attrs)
 {
 	unsigned long addr = (unsigned long) vaddr;
 	int order = get_order(size);
@@ -323,8 +323,8 @@ void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 EXPORT_SYMBOL(dma_cache_sync);
 
 static struct dma_map_ops mips_default_dma_map_ops = {
-	.alloc_coherent = mips_dma_alloc_coherent,
-	.free_coherent = mips_dma_free_coherent,
+	.alloc = mips_dma_alloc_coherent,
+	.free = mips_dma_free_coherent,
 	.map_page = mips_dma_map_page,
 	.unmap_page = mips_dma_unmap_page,
 	.map_sg = mips_dma_map_sg,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
