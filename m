Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A259AC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 505C2208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FlKgJYh7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 505C2208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F37E36B000E; Wed, 14 Aug 2019 03:59:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE8D36B0010; Wed, 14 Aug 2019 03:59:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAFEF6B0266; Wed, 14 Aug 2019 03:59:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0118.hostedemail.com [216.40.44.118])
	by kanga.kvack.org (Postfix) with ESMTP id B6D986B000E
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 03:59:58 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6C05A180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:58 +0000 (UTC)
X-FDA: 75820284876.11.flock31_56feb50a5f516
X-HE-Tag: flock31_56feb50a5f516
X-Filterd-Recvd-Size: 10119
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=G1qptC8ExGAI7IzSTHWI3AKxErgtDoyIVBMa+L7+WEk=; b=FlKgJYh71dmy2V4OumWFBO6spq
	W1njJhcczTwkppEs3jic0jQJprFvQ9q3rshp+cT2QSA3VtPS7diz7+gNoDV4YeR0cREkIDDfcRBJX
	C+nzUhn+Eh85TTeqR/8ODH54AuHMokyuxnns0cQpZaMHnkjOPwz+uqzI8UmGo9wT/Ul2Mh/qS3xba
	FAtDsY4e62d1QmIZyokMFbKGZW5aVZbHD9rubKrRrRocf78pv2Yg2F79eJoF3vHWTmSB2JNG4vPOl
	rZS0pFUvinXXngIDJYuENYaUqQS0ycCDsUpKWJSuw2FJcZlpRoltgheqDguXPrIV3lMK79i5gl+q/
	OJovl5NA==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hxoCH-00083a-4w; Wed, 14 Aug 2019 07:59:53 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 07/10] nouveau: simplify nouveau_dmem_migrate_vma
Date: Wed, 14 Aug 2019 09:59:25 +0200
Message-Id: <20190814075928.23766-8-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190814075928.23766-1-hch@lst.de>
References: <20190814075928.23766-1-hch@lst.de>
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Factor the main copy page to vram routine out into a helper that acts
on a single page and which doesn't require the nouveau_dmem_migrate
structure for argument passing.  As an added benefit the new version
only allocates the dma address array once and reuses it for each
subsequent chunk of work.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 184 ++++++++-----------------
 1 file changed, 55 insertions(+), 129 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nou=
veau/nouveau_dmem.c
index 7dded864022c..d96b987b9982 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -44,8 +44,6 @@
 #define DMEM_CHUNK_SIZE (2UL << 20)
 #define DMEM_CHUNK_NPAGES (DMEM_CHUNK_SIZE >> PAGE_SHIFT)
=20
-struct nouveau_migrate;
-
 enum nouveau_aper {
 	NOUVEAU_APER_VIRT,
 	NOUVEAU_APER_VRAM,
@@ -86,15 +84,6 @@ static inline struct nouveau_dmem *page_to_dmem(struct=
 page *page)
 	return container_of(page->pgmap, struct nouveau_dmem, pagemap);
 }
=20
-struct nouveau_migrate {
-	struct vm_area_struct *vma;
-	struct nouveau_drm *drm;
-	struct nouveau_fence *fence;
-	unsigned long npages;
-	dma_addr_t *dma;
-	unsigned long dma_nr;
-};
-
 static unsigned long nouveau_dmem_page_addr(struct page *page)
 {
 	struct nouveau_dmem_chunk *chunk =3D page->zone_device_data;
@@ -568,131 +557,66 @@ nouveau_dmem_init(struct nouveau_drm *drm)
 	drm->dmem =3D NULL;
 }
=20
-static void
-nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
-				    const unsigned long *src_pfns,
-				    unsigned long *dst_pfns,
-				    unsigned long start,
-				    unsigned long end,
-				    struct nouveau_migrate *migrate)
+static unsigned long nouveau_dmem_migrate_copy_one(struct nouveau_drm *d=
rm,
+		unsigned long src, dma_addr_t *dma_addr)
 {
-	struct nouveau_drm *drm =3D migrate->drm;
 	struct device *dev =3D drm->dev->dev;
-	unsigned long addr, i, npages =3D 0;
-	nouveau_migrate_copy_t copy;
-	int ret;
-
-	/* First allocate new memory */
-	for (addr =3D start, i =3D 0; addr < end; addr +=3D PAGE_SIZE, i++) {
-		struct page *dpage, *spage;
-
-		dst_pfns[i] =3D 0;
-		spage =3D migrate_pfn_to_page(src_pfns[i]);
-		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE))
-			continue;
-
-		dpage =3D nouveau_dmem_page_alloc_locked(drm);
-		if (!dpage)
-			continue;
-
-		dst_pfns[i] =3D migrate_pfn(page_to_pfn(dpage)) |
-			      MIGRATE_PFN_LOCKED |
-			      MIGRATE_PFN_DEVICE;
-		npages++;
-	}
-
-	if (!npages)
-		return;
-
-	/* Allocate storage for DMA addresses, so we can unmap later. */
-	migrate->dma =3D kmalloc(sizeof(*migrate->dma) * npages, GFP_KERNEL);
-	if (!migrate->dma)
-		goto error;
-	migrate->dma_nr =3D 0;
-
-	/* Copy things over */
-	copy =3D drm->dmem->migrate.copy_func;
-	for (addr =3D start, i =3D 0; addr < end; addr +=3D PAGE_SIZE, i++) {
-		struct page *spage, *dpage;
-
-		dpage =3D migrate_pfn_to_page(dst_pfns[i]);
-		if (!dpage || dst_pfns[i] =3D=3D MIGRATE_PFN_ERROR)
-			continue;
-
-		spage =3D migrate_pfn_to_page(src_pfns[i]);
-		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE)) {
-			nouveau_dmem_page_free_locked(drm, dpage);
-			dst_pfns[i] =3D 0;
-			continue;
-		}
-
-		migrate->dma[migrate->dma_nr] =3D
-			dma_map_page_attrs(dev, spage, 0, PAGE_SIZE,
-					   PCI_DMA_BIDIRECTIONAL,
-					   DMA_ATTR_SKIP_CPU_SYNC);
-		if (dma_mapping_error(dev, migrate->dma[migrate->dma_nr])) {
-			nouveau_dmem_page_free_locked(drm, dpage);
-			dst_pfns[i] =3D 0;
-			continue;
-		}
-
-		ret =3D copy(drm, 1, NOUVEAU_APER_VRAM,
-				nouveau_dmem_page_addr(dpage),
-				NOUVEAU_APER_HOST,
-				migrate->dma[migrate->dma_nr++]);
-		if (ret) {
-			nouveau_dmem_page_free_locked(drm, dpage);
-			dst_pfns[i] =3D 0;
-			continue;
-		}
-	}
+	struct page *dpage, *spage;
=20
-	nouveau_fence_new(drm->dmem->migrate.chan, false, &migrate->fence);
+	spage =3D migrate_pfn_to_page(src);
+	if (!spage || !(src & MIGRATE_PFN_MIGRATE))
+		goto out;
=20
-	return;
+	dpage =3D nouveau_dmem_page_alloc_locked(drm);
+	if (!dpage)
+		return 0;
=20
-error:
-	for (addr =3D start, i =3D 0; addr < end; addr +=3D PAGE_SIZE, ++i) {
-		struct page *page;
+	*dma_addr =3D dma_map_page(dev, spage, 0, PAGE_SIZE, DMA_BIDIRECTIONAL)=
;
+	if (dma_mapping_error(dev, *dma_addr))
+		goto out_free_page;
=20
-		if (!dst_pfns[i] || dst_pfns[i] =3D=3D MIGRATE_PFN_ERROR)
-			continue;
+	if (drm->dmem->migrate.copy_func(drm, 1, NOUVEAU_APER_VRAM,
+			nouveau_dmem_page_addr(dpage), NOUVEAU_APER_HOST,
+			*dma_addr))
+		goto out_dma_unmap;
=20
-		page =3D migrate_pfn_to_page(dst_pfns[i]);
-		dst_pfns[i] =3D MIGRATE_PFN_ERROR;
-		if (page =3D=3D NULL)
-			continue;
+	return migrate_pfn(page_to_pfn(dpage)) |
+		MIGRATE_PFN_LOCKED | MIGRATE_PFN_DEVICE;
=20
-		__free_page(page);
-	}
+out_dma_unmap:
+	dma_unmap_page(dev, *dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
+out_free_page:
+	nouveau_dmem_page_free_locked(drm, dpage);
+out:
+	return 0;
 }
=20
-static void
-nouveau_dmem_migrate_finalize_and_map(struct nouveau_migrate *migrate)
+static void nouveau_dmem_migrate_chunk(struct nouveau_drm *drm,
+		struct migrate_vma *args, dma_addr_t *dma_addrs)
 {
-	struct nouveau_drm *drm =3D migrate->drm;
+	struct nouveau_fence *fence;
+	unsigned long addr =3D args->start, nr_dma =3D 0, i;
+
+	for (i =3D 0; addr < args->end; i++) {
+		args->dst[i] =3D nouveau_dmem_migrate_copy_one(drm, args->src[i],
+				dma_addrs + nr_dma);
+		if (args->dst[i])
+			nr_dma++;
+		addr +=3D PAGE_SIZE;
+	}
=20
-	nouveau_dmem_fence_done(&migrate->fence);
+	nouveau_fence_new(drm->dmem->migrate.chan, false, &fence);
+	migrate_vma_pages(args);
+	nouveau_dmem_fence_done(&fence);
=20
-	while (migrate->dma_nr--) {
-		dma_unmap_page(drm->dev->dev, migrate->dma[migrate->dma_nr],
-			       PAGE_SIZE, PCI_DMA_BIDIRECTIONAL);
+	while (nr_dma--) {
+		dma_unmap_page(drm->dev->dev, dma_addrs[nr_dma], PAGE_SIZE,
+				DMA_BIDIRECTIONAL);
 	}
-	kfree(migrate->dma);
-
 	/*
-	 * FIXME optimization: update GPU page table to point to newly
-	 * migrated memory.
+	 * FIXME optimization: update GPU page table to point to newly migrated
+	 * memory.
 	 */
-}
-
-static void nouveau_dmem_migrate_chunk(struct migrate_vma *args,
-		struct nouveau_migrate *migrate)
-{
-	nouveau_dmem_migrate_alloc_and_copy(args->vma, args->src, args->dst,
-			args->start, args->end, migrate);
-	migrate_vma_pages(args);
-	nouveau_dmem_migrate_finalize_and_map(migrate);
 	migrate_vma_finalize(args);
 }
=20
@@ -704,38 +628,40 @@ nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
 {
 	unsigned long npages =3D (end - start) >> PAGE_SHIFT;
 	unsigned long max =3D min(SG_MAX_SINGLE_ALLOC, npages);
+	dma_addr_t *dma_addrs;
 	struct migrate_vma args =3D {
 		.vma		=3D vma,
 		.start		=3D start,
 	};
-	struct nouveau_migrate migrate =3D {
-		.drm		=3D drm,
-		.vma		=3D vma,
-		.npages		=3D npages,
-	};
 	unsigned long c, i;
 	int ret =3D -ENOMEM;
=20
-	args.src =3D kzalloc(sizeof(long) * max, GFP_KERNEL);
+	args.src =3D kcalloc(max, sizeof(args.src), GFP_KERNEL);
 	if (!args.src)
 		goto out;
-	args.dst =3D kzalloc(sizeof(long) * max, GFP_KERNEL);
+	args.dst =3D kcalloc(max, sizeof(args.dst), GFP_KERNEL);
 	if (!args.dst)
 		goto out_free_src;
=20
+	dma_addrs =3D kmalloc_array(max, sizeof(*dma_addrs), GFP_KERNEL);
+	if (!dma_addrs)
+		goto out_free_dst;
+
 	for (i =3D 0; i < npages; i +=3D c) {
 		c =3D min(SG_MAX_SINGLE_ALLOC, npages);
 		args.end =3D start + (c << PAGE_SHIFT);
 		ret =3D migrate_vma_setup(&args);
 		if (ret)
-			goto out_free_dst;
+			goto out_free_dma;
=20
 		if (args.cpages)
-			nouveau_dmem_migrate_chunk(&args, &migrate);
+			nouveau_dmem_migrate_chunk(drm, &args, dma_addrs);
 		args.start =3D args.end;
 	}
=20
 	ret =3D 0;
+out_free_dma:
+	kfree(dma_addrs);
 out_free_dst:
 	kfree(args.dst);
 out_free_src:
--=20
2.20.1


