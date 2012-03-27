Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 9848F6B00EC
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 09:43:26 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1J00NXUQ4E2K60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:26 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1J00794Q4BCW@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:24 +0100 (BST)
Date: Tue, 27 Mar 2012 15:42:43 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 09/14] Unicore32: adapt for dma_map_ops changes
In-reply-to: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1332855768-32583-10-git-send-email-m.szyprowski@samsung.com>
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kevin Cernekee <cernekee@gmail.com>, Dezhong Diao <dediao@cisco.com>, Richard Kuo <rkuo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Paul Mundt <lethal@linux-sh.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Adapt core Unicore32 architecture code for dma_map_ops changes: replace
alloc/free_coherent with generic alloc/free methods.

Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
[added swiotlb_alloc/free_coherent wrappers]
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/unicore32/include/asm/dma-mapping.h |   18 ++++++++++++------
 arch/unicore32/mm/dma-swiotlb.c          |   18 ++++++++++++++++--
 2 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/arch/unicore32/include/asm/dma-mapping.h b/arch/unicore32/include/asm/dma-mapping.h
index 9258e59..366460a 100644
--- a/arch/unicore32/include/asm/dma-mapping.h
+++ b/arch/unicore32/include/asm/dma-mapping.h
@@ -82,20 +82,26 @@ static inline int dma_set_mask(struct device *dev, u64 dma_mask)
 	return 0;
 }
 
-static inline void *dma_alloc_coherent(struct device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t flag)
+#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
+
+static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+				    dma_addr_t *dma_handle, gfp_t flag,
+				    struct dma_attrs *attrs)
 {
 	struct dma_map_ops *dma_ops = get_dma_ops(dev);
 
-	return dma_ops->alloc_coherent(dev, size, dma_handle, flag);
+	return dma_ops->alloc(dev, size, dma_handle, flag, attrs);
 }
 
-static inline void dma_free_coherent(struct device *dev, size_t size,
-				     void *cpu_addr, dma_addr_t dma_handle)
+#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
+
+static inline void dma_free_attrs(struct device *dev, size_t size,
+				  void *cpu_addr, dma_addr_t dma_handle,
+				  struct dma_attrs *attrs)
 {
 	struct dma_map_ops *dma_ops = get_dma_ops(dev);
 
-	dma_ops->free_coherent(dev, size, cpu_addr, dma_handle);
+	dma_ops->free(dev, size, cpu_addr, dma_handle, attrs);
 }
 
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
diff --git a/arch/unicore32/mm/dma-swiotlb.c b/arch/unicore32/mm/dma-swiotlb.c
index bfa9fbb..4cf5f0c 100644
--- a/arch/unicore32/mm/dma-swiotlb.c
+++ b/arch/unicore32/mm/dma-swiotlb.c
@@ -17,9 +17,23 @@
 
 #include <asm/dma.h>
 
+static void *unicore_swiotlb_alloc_coherent(struct device *dev, size_t size,
+					    dma_addr_t *dma_handle, gfp_t flags,
+					    struct dma_attrs *attrs)
+{
+	return swiotlb_alloc_coherent(dev, size, dma_handle, flags);
+}
+
+static void unicode_swiotlb_free_coherent(struct device *dev, size_t size,
+					  void *vaddr, dma_addr_t dma_addr,
+					  struct dma_attrs *attrs)
+{
+	swiotlb_free_coherent(dev, size, vaddr, dma_addr);
+}
+
 struct dma_map_ops swiotlb_dma_map_ops = {
-	.alloc_coherent = swiotlb_alloc_coherent,
-	.free_coherent = swiotlb_free_coherent,
+	.alloc = unicore_swiotlb_alloc_coherent,
+	.free = unicore_swiotlb_free_coherent,
 	.map_sg = swiotlb_map_sg_attrs,
 	.unmap_sg = swiotlb_unmap_sg_attrs,
 	.dma_supported = swiotlb_dma_supported,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
