Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id AE91F6B00F3
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 09:43:30 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1J00EXKQ42PD60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:15 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1J0002KQ49U6@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:22 +0100 (BST)
Date: Tue, 27 Mar 2012 15:42:44 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 10/14] Hexagon: adapt for dma_map_ops changes
In-reply-to: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1332855768-32583-11-git-send-email-m.szyprowski@samsung.com>
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kevin Cernekee <cernekee@gmail.com>, Dezhong Diao <dediao@cisco.com>, Richard Kuo <rkuo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Paul Mundt <lethal@linux-sh.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Adapt core Hexagon architecture code for dma_map_ops changes: replace
alloc/free_coherent with generic alloc/free methods.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/hexagon/include/asm/dma-mapping.h |   18 ++++++++++++------
 arch/hexagon/kernel/dma.c              |    9 +++++----
 2 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/arch/hexagon/include/asm/dma-mapping.h b/arch/hexagon/include/asm/dma-mapping.h
index 448b224..233ed3d 100644
--- a/arch/hexagon/include/asm/dma-mapping.h
+++ b/arch/hexagon/include/asm/dma-mapping.h
@@ -71,29 +71,35 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return (dma_addr == bad_dma_address);
 }
 
-static inline void *dma_alloc_coherent(struct device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t flag)
+#define dma_alloc_coherent(d,s,h,f)	dma_alloc_attrs(d,s,h,f,NULL)
+
+static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+				    dma_addr_t *dma_handle, gfp_t flag,
+				    struct dma_attrs *attrs)
 {
 	void *ret;
 	struct dma_map_ops *ops = get_dma_ops(dev);
 
 	BUG_ON(!dma_ops);
 
-	ret = ops->alloc_coherent(dev, size, dma_handle, flag);
+	ret = ops->alloc(dev, size, dma_handle, flag, attrs);
 
 	debug_dma_alloc_coherent(dev, size, *dma_handle, ret);
 
 	return ret;
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
 
 	BUG_ON(!dma_ops);
 
-	dma_ops->free_coherent(dev, size, cpu_addr, dma_handle);
+	dma_ops->free(dev, size, cpu_addr, dma_handle, attrs);
 
 	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
 }
diff --git a/arch/hexagon/kernel/dma.c b/arch/hexagon/kernel/dma.c
index e711ace..3730221 100644
--- a/arch/hexagon/kernel/dma.c
+++ b/arch/hexagon/kernel/dma.c
@@ -54,7 +54,8 @@ static struct gen_pool *coherent_pool;
 /* Allocates from a pool of uncached memory that was reserved at boot time */
 
 void *hexagon_dma_alloc_coherent(struct device *dev, size_t size,
-				 dma_addr_t *dma_addr, gfp_t flag)
+				 dma_addr_t *dma_addr, gfp_t flag,
+				 struct dma_attrs *attrs)
 {
 	void *ret;
 
@@ -81,7 +82,7 @@ void *hexagon_dma_alloc_coherent(struct device *dev, size_t size,
 }
 
 static void hexagon_free_coherent(struct device *dev, size_t size, void *vaddr,
-				  dma_addr_t dma_addr)
+				  dma_addr_t dma_addr, struct dma_attrs *attrs)
 {
 	gen_pool_free(coherent_pool, (unsigned long) vaddr, size);
 }
@@ -202,8 +203,8 @@ static void hexagon_sync_single_for_device(struct device *dev,
 }
 
 struct dma_map_ops hexagon_dma_ops = {
-	.alloc_coherent	= hexagon_dma_alloc_coherent,
-	.free_coherent	= hexagon_free_coherent,
+	.alloc		= hexagon_dma_alloc_coherent,
+	.free		= hexagon_free_coherent,
 	.map_sg		= hexagon_map_sg,
 	.map_page	= hexagon_map_page,
 	.sync_single_for_cpu = hexagon_sync_single_for_cpu,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
