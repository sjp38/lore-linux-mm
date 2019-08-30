Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5931DC3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 06:29:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1875F23405
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 06:29:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="S4wbMxok"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1875F23405
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A6756B000C; Fri, 30 Aug 2019 02:29:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED02E6B000D; Fri, 30 Aug 2019 02:29:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D74416B000E; Fri, 30 Aug 2019 02:29:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by kanga.kvack.org (Postfix) with ESMTP id AE7756B000C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 02:29:44 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2986F1A4D3
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 06:29:44 +0000 (UTC)
X-FDA: 75878118288.15.game48_54f0dcf39f00f
X-HE-Tag: game48_54f0dcf39f00f
X-Filterd-Recvd-Size: 6584
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 06:29:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=6jAaX0ieW9MeYxDW2dKKumY+12F0P2cEPjb+jbaeszE=; b=S4wbMxok2D8k4ZFzpm9aUIl5c/
	jgwwzPbSLdJgX8cRz41Y7ZQnuqZSwAQRGqDHZnxg5XEYRKLtsxPd8zmgp3TcyG5GH1onLI5FFum3P
	hzh25CiCsqTk9CYibwrquJNd0MC/wJxQu0nCiwAKM9Njy0aus0zKACd7aOMhmp0O24hB0fhncq047
	BoUaLLB29lTXHWd0e3T5TLWCPE+hMJrzhoGxJZkjLqtBPx2NPp1cfrc15Ws/P6s+sxZLKrikd/9ow
	Hdd7JegC0ismFSSRgcRZqopjx1TzT/zBaPsi5Q1gXiVvMxdPKz0tQSZvDC/UwNL1WPBQnn1j42I2W
	Bz4iWtlg==;
Received: from [93.83.86.253] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i3aPg-0002tB-7G; Fri, 30 Aug 2019 06:29:36 +0000
From: Christoph Hellwig <hch@lst.de>
To: iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-xtensa@linux-xtensa.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/4] dma-mapping: introduce a dma_common_find_pages helper
Date: Fri, 30 Aug 2019 08:29:23 +0200
Message-Id: <20190830062924.21714-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190830062924.21714-1-hch@lst.de>
References: <20190830062924.21714-1-hch@lst.de>
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A helper to find the backing page array based on a virtual address.
This also ensures we do the same vm_flags check everywhere instead
of slightly different or missing ones in a few places.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/mm/dma-mapping.c   |  7 +------
 drivers/iommu/dma-iommu.c   | 15 +++------------
 include/linux/dma-mapping.h |  1 +
 kernel/dma/remap.c          | 13 +++++++++++--
 4 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 054a66f725b3..d07e5c865557 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1447,18 +1447,13 @@ static struct page **__atomic_get_pages(void *add=
r)
=20
 static struct page **__iommu_get_pages(void *cpu_addr, unsigned long att=
rs)
 {
-	struct vm_struct *area;
-
 	if (__in_atomic_pool(cpu_addr, PAGE_SIZE))
 		return __atomic_get_pages(cpu_addr);
=20
 	if (attrs & DMA_ATTR_NO_KERNEL_MAPPING)
 		return cpu_addr;
=20
-	area =3D find_vm_area(cpu_addr);
-	if (area && (area->flags & VM_DMA_COHERENT))
-		return area->pages;
-	return NULL;
+	return dma_common_find_pages(cpu_addr);
 }
=20
 static void *__iommu_alloc_simple(struct device *dev, size_t size, gfp_t=
 gfp,
diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index 013416f5ad38..eafc378da448 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -541,15 +541,6 @@ static struct page **__iommu_dma_alloc_pages(struct =
device *dev,
 	return pages;
 }
=20
-static struct page **__iommu_dma_get_pages(void *cpu_addr)
-{
-	struct vm_struct *area =3D find_vm_area(cpu_addr);
-
-	if (!area || !area->pages)
-		return NULL;
-	return area->pages;
-}
-
 /**
  * iommu_dma_alloc_remap - Allocate and map a buffer contiguous in IOVA =
space
  * @dev: Device to allocate memory for. Must be a real device
@@ -938,7 +929,7 @@ static void __iommu_dma_free(struct device *dev, size=
_t size, void *cpu_addr)
 		 * If it the address is remapped, then it's either non-coherent
 		 * or highmem CMA, or an iommu_dma_alloc_remap() construction.
 		 */
-		pages =3D __iommu_dma_get_pages(cpu_addr);
+		pages =3D dma_common_find_pages(cpu_addr);
 		if (!pages)
 			page =3D vmalloc_to_page(cpu_addr);
 		dma_common_free_remap(cpu_addr, alloc_size);
@@ -1045,7 +1036,7 @@ static int iommu_dma_mmap(struct device *dev, struc=
t vm_area_struct *vma,
 		return -ENXIO;
=20
 	if (IS_ENABLED(CONFIG_DMA_REMAP) && is_vmalloc_addr(cpu_addr)) {
-		struct page **pages =3D __iommu_dma_get_pages(cpu_addr);
+		struct page **pages =3D dma_common_find_pages(cpu_addr);
=20
 		if (pages)
 			return __iommu_dma_mmap(pages, size, vma);
@@ -1067,7 +1058,7 @@ static int iommu_dma_get_sgtable(struct device *dev=
, struct sg_table *sgt,
 	int ret;
=20
 	if (IS_ENABLED(CONFIG_DMA_REMAP) && is_vmalloc_addr(cpu_addr)) {
-		struct page **pages =3D __iommu_dma_get_pages(cpu_addr);
+		struct page **pages =3D dma_common_find_pages(cpu_addr);
=20
 		if (pages) {
 			return sg_alloc_table_from_pages(sgt, pages,
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index c9725390fbbc..e4840f40ae69 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -615,6 +615,7 @@ extern int dma_common_mmap(struct device *dev, struct=
 vm_area_struct *vma,
 		void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		unsigned long attrs);
=20
+struct page **dma_common_find_pages(void *cpu_addr);
 void *dma_common_contiguous_remap(struct page *page, size_t size,
 			pgprot_t prot, const void *caller);
=20
diff --git a/kernel/dma/remap.c b/kernel/dma/remap.c
index 01d4ef5685a4..3482fc585c59 100644
--- a/kernel/dma/remap.c
+++ b/kernel/dma/remap.c
@@ -11,6 +11,15 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
=20
+struct page **dma_common_find_pages(void *cpu_addr)
+{
+	struct vm_struct *area =3D find_vm_area(cpu_addr);
+
+	if (!area || area->flags !=3D VM_DMA_COHERENT)
+		return NULL;
+	return area->pages;
+}
+
 static struct vm_struct *__dma_common_pages_remap(struct page **pages,
 			size_t size, pgprot_t prot, const void *caller)
 {
@@ -78,9 +87,9 @@ void *dma_common_contiguous_remap(struct page *page, si=
ze_t size,
  */
 void dma_common_free_remap(void *cpu_addr, size_t size)
 {
-	struct vm_struct *area =3D find_vm_area(cpu_addr);
+	struct page **pages =3D dma_common_find_pages(cpu_addr);
=20
-	if (!area || area->flags !=3D VM_DMA_COHERENT) {
+	if (!pages) {
 		WARN(1, "trying to free invalid coherent area: %p\n", cpu_addr);
 		return;
 	}
--=20
2.20.1


