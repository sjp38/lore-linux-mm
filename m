Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3217DC3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 06:29:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D914521721
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 06:29:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="etH4jWeZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D914521721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8C3E6B000A; Fri, 30 Aug 2019 02:29:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ED606B000C; Fri, 30 Aug 2019 02:29:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B4076B000D; Fri, 30 Aug 2019 02:29:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0084.hostedemail.com [216.40.44.84])
	by kanga.kvack.org (Postfix) with ESMTP id 69DE76B000C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 02:29:42 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 179021B65A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 06:29:42 +0000 (UTC)
X-FDA: 75878118204.15.top60_5455464b8c72e
X-HE-Tag: top60_5455464b8c72e
X-Filterd-Recvd-Size: 6797
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 06:29:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=M4cTuDqudRk4cLlZfby65NiDWkJ9VRA0uOLkwFgPTxQ=; b=etH4jWeZy6AeQgqWzmG5BrZDhi
	jYPypaOfhZpJy/YPY4YX1tXmOLUAsXlQ8qgf9naUicz/VZvwaXN1KiJj8Yl3DPrmqH08BMO3Du24F
	wUNUdx9yCE0LKb1eB/rE277qpdivLaPM1Dq00UPX0pfJUSpTZnof6F93GLg8tyREgyHBuqeowH4AU
	JeYjkpufkOgL7A9b6jQsbLDPLrEfYWBvXogtKqlKF3PYqRRn8OCBhsldW2LWGEbqu4XnOKx5ksTmB
	y+giWSJmd3to7tVjw1bP5pfIDKU13C+McUprzmH26PZ1bEpGNw8JaqyvpREtdbaF2XkUlNdzHAM8p
	hJUt3vpg==;
Received: from [93.83.86.253] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i3aPa-0002p0-Os; Fri, 30 Aug 2019 06:29:31 +0000
From: Christoph Hellwig <hch@lst.de>
To: iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-xtensa@linux-xtensa.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/4] vmalloc: lift the arm flag for coherent mappings to common code
Date: Fri, 30 Aug 2019 08:29:21 +0200
Message-Id: <20190830062924.21714-2-hch@lst.de>
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

The arm architecture had a VM_ARM_DMA_CONSISTENT flag to mark DMA
coherent remapping for a while.  Lift this flag to common code so
that we can use it generically.  We also check it in the only place
VM_USERMAP is directly check so that we can entirely replace that
flag as well (although I'm not even sure why we'd want to allow
remapping DMA appings, but I'd rather not change behavior).

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/mm/dma-mapping.c | 22 +++++++---------------
 arch/arm/mm/mm.h          |  3 ---
 include/linux/vmalloc.h   |  2 ++
 mm/vmalloc.c              |  5 ++++-
 4 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index d42557ee69c2..5c0af4a2faa7 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -340,19 +340,13 @@ static void *
 __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t pr=
ot,
 	const void *caller)
 {
-	/*
-	 * DMA allocation can be mapped to user space, so lets
-	 * set VM_USERMAP flags too.
-	 */
-	return dma_common_contiguous_remap(page, size,
-			VM_ARM_DMA_CONSISTENT | VM_USERMAP,
+	return dma_common_contiguous_remap(page, size, VM_DMA_COHERENT,
 			prot, caller);
 }
=20
 static void __dma_free_remap(void *cpu_addr, size_t size)
 {
-	dma_common_free_remap(cpu_addr, size,
-			VM_ARM_DMA_CONSISTENT | VM_USERMAP);
+	dma_common_free_remap(cpu_addr, size, VM_DMA_COHERENT);
 }
=20
 #define DEFAULT_DMA_COHERENT_POOL_SIZE	SZ_256K
@@ -1379,8 +1373,8 @@ static void *
 __iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_=
t prot,
 		    const void *caller)
 {
-	return dma_common_pages_remap(pages, size,
-			VM_ARM_DMA_CONSISTENT | VM_USERMAP, prot, caller);
+	return dma_common_pages_remap(pages, size, VM_DMA_COHERENT, prot,
+			caller);
 }
=20
 /*
@@ -1464,7 +1458,7 @@ static struct page **__iommu_get_pages(void *cpu_ad=
dr, unsigned long attrs)
 		return cpu_addr;
=20
 	area =3D find_vm_area(cpu_addr);
-	if (area && (area->flags & VM_ARM_DMA_CONSISTENT))
+	if (area && (area->flags & VM_DMA_COHERENT))
 		return area->pages;
 	return NULL;
 }
@@ -1622,10 +1616,8 @@ void __arm_iommu_free_attrs(struct device *dev, si=
ze_t size, void *cpu_addr,
 		return;
 	}
=20
-	if ((attrs & DMA_ATTR_NO_KERNEL_MAPPING) =3D=3D 0) {
-		dma_common_free_remap(cpu_addr, size,
-			VM_ARM_DMA_CONSISTENT | VM_USERMAP);
-	}
+	if ((attrs & DMA_ATTR_NO_KERNEL_MAPPING) =3D=3D 0)
+		dma_common_free_remap(cpu_addr, size, VM_DMA_COHERENT);
=20
 	__iommu_remove_mapping(dev, handle, size);
 	__iommu_free_buffer(dev, pages, size, attrs);
diff --git a/arch/arm/mm/mm.h b/arch/arm/mm/mm.h
index 941356d95a67..88c121ac14b3 100644
--- a/arch/arm/mm/mm.h
+++ b/arch/arm/mm/mm.h
@@ -70,9 +70,6 @@ extern void __flush_dcache_page(struct address_space *m=
apping, struct page *page
 #define VM_ARM_MTYPE(mt)		((mt) << 20)
 #define VM_ARM_MTYPE_MASK	(0x1f << 20)
=20
-/* consistent regions used by dma_alloc_attrs() */
-#define VM_ARM_DMA_CONSISTENT	0x20000000
-
=20
 struct static_vm {
 	struct vm_struct vm;
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 9b21d0047710..dfa718ffdd4f 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -18,6 +18,7 @@ struct notifier_block;		/* in notifier.h */
 #define VM_ALLOC		0x00000002	/* vmalloc() */
 #define VM_MAP			0x00000004	/* vmap()ed pages */
 #define VM_USERMAP		0x00000008	/* suitable for remap_vmalloc_range */
+#define VM_DMA_COHERENT		0x00000010	/* dma_alloc_coherent */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialize=
d */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory *=
/
@@ -26,6 +27,7 @@ struct notifier_block;		/* in notifier.h */
  * vfree_atomic().
  */
 #define VM_FLUSH_RESET_PERMS	0x00000100      /* Reset direct map and flu=
sh TLB on unmap */
+
 /* bits [20..32] reserved for arch specific ioremap internals */
=20
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7ba11e12a11f..c1246d77cf75 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2993,7 +2993,7 @@ int remap_vmalloc_range_partial(struct vm_area_stru=
ct *vma, unsigned long uaddr,
 	if (!area)
 		return -EINVAL;
=20
-	if (!(area->flags & VM_USERMAP))
+	if (!(area->flags & (VM_USERMAP | VM_DMA_COHERENT)))
 		return -EINVAL;
=20
 	if (kaddr + size > area->addr + get_vm_area_size(area))
@@ -3496,6 +3496,9 @@ static int s_show(struct seq_file *m, void *p)
 	if (v->flags & VM_USERMAP)
 		seq_puts(m, " user");
=20
+	if (v->flags & VM_DMA_COHERENT)
+		seq_puts(m, " dma-coherent");
+
 	if (is_vmalloc_addr(v->pages))
 		seq_puts(m, " vpages");
=20
--=20
2.20.1


