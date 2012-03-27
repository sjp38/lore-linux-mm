Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id E704F6B00ED
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 09:43:27 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1J00NXUQ4E2K60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:26 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1J00793Q4BCW@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:24 +0100 (BST)
Date: Tue, 27 Mar 2012 15:42:42 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 08/14] Microblaze: adapt for dma_map_ops changes
In-reply-to: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1332855768-32583-9-git-send-email-m.szyprowski@samsung.com>
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kevin Cernekee <cernekee@gmail.com>, Dezhong Diao <dediao@cisco.com>, Richard Kuo <rkuo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Paul Mundt <lethal@linux-sh.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Adapt core Microblaze architecture code for dma_map_ops changes: replace
alloc/free_coherent with generic alloc/free methods.

Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
[fixed coding style issues]
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/microblaze/include/asm/dma-mapping.h |   18 ++++++++++++------
 arch/microblaze/kernel/dma.c              |   10 ++++++----
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/arch/microblaze/include/asm/dma-mapping.h b/arch/microblaze/include/asm/dma-mapping.h
index 3a3e5b8..01d2282 100644
--- a/arch/microblaze/include/asm/dma-mapping.h
+++ b/arch/microblaze/include/asm/dma-mapping.h
@@ -123,28 +123,34 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
 #define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
 
-static inline void *dma_alloc_coherent(struct device *dev, size_t size,
-					dma_addr_t *dma_handle, gfp_t flag)
+#define dma_alloc_coherent(d, s, h, f) dma_alloc_attrs(d, s, h, f, NULL)
+
+static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+				    dma_addr_t *dma_handle, gfp_t flag,
+				    struct dma_attrs *attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 	void *memory;
 
 	BUG_ON(!ops);
 
-	memory = ops->alloc_coherent(dev, size, dma_handle, flag);
+	memory = ops->alloc(dev, size, dma_handle, flag, attrs);
 
 	debug_dma_alloc_coherent(dev, size, *dma_handle, memory);
 	return memory;
 }
 
-static inline void dma_free_coherent(struct device *dev, size_t size,
-				     void *cpu_addr, dma_addr_t dma_handle)
+#define dma_free_coherent(d,s,c,h) dma_free_attrs(d, s, c, h, NULL)
+
+static inline void dma_free_attrs(struct device *dev, size_t size,
+				  void *cpu_addr, dma_addr_t dma_handle,
+				  struct dma_attrs *attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 
 	BUG_ON(!ops);
 	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
-	ops->free_coherent(dev, size, cpu_addr, dma_handle);
+	ops->free(dev, size, cpu_addr, dma_handle, attrs);
 }
 
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
diff --git a/arch/microblaze/kernel/dma.c b/arch/microblaze/kernel/dma.c
index 65a4af4..a2bfa2c 100644
--- a/arch/microblaze/kernel/dma.c
+++ b/arch/microblaze/kernel/dma.c
@@ -33,7 +33,8 @@ static unsigned long get_dma_direct_offset(struct device *dev)
 #define NOT_COHERENT_CACHE
 
 static void *dma_direct_alloc_coherent(struct device *dev, size_t size,
-				dma_addr_t *dma_handle, gfp_t flag)
+				       dma_addr_t *dma_handle, gfp_t flag,
+				       struct dma_attrs *attrs)
 {
 #ifdef NOT_COHERENT_CACHE
 	return consistent_alloc(flag, size, dma_handle);
@@ -57,7 +58,8 @@ static void *dma_direct_alloc_coherent(struct device *dev, size_t size,
 }
 
 static void dma_direct_free_coherent(struct device *dev, size_t size,
-			      void *vaddr, dma_addr_t dma_handle)
+				     void *vaddr, dma_addr_t dma_handle,
+				     struct dma_attrs *attrs)
 {
 #ifdef NOT_COHERENT_CACHE
 	consistent_free(size, vaddr);
@@ -176,8 +178,8 @@ dma_direct_sync_sg_for_device(struct device *dev,
 }
 
 struct dma_map_ops dma_direct_ops = {
-	.alloc_coherent	= dma_direct_alloc_coherent,
-	.free_coherent	= dma_direct_free_coherent,
+	.alloc		= dma_direct_alloc_coherent,
+	.free		= dma_direct_free_coherent,
 	.map_sg		= dma_direct_map_sg,
 	.unmap_sg	= dma_direct_unmap_sg,
 	.dma_supported	= dma_direct_dma_supported,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
