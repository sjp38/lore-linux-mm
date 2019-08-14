Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22A50C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB499208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aHIuwPxr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB499208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E4CA6B0008; Wed, 14 Aug 2019 03:59:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 795E86B000A; Wed, 14 Aug 2019 03:59:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6ADF86B000C; Wed, 14 Aug 2019 03:59:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0159.hostedemail.com [216.40.44.159])
	by kanga.kvack.org (Postfix) with ESMTP id 44A006B0008
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 03:59:48 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id BDB47180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:47 +0000 (UTC)
X-FDA: 75820284414.08.grip04_5577a2725ba22
X-HE-Tag: grip04_5577a2725ba22
X-Filterd-Recvd-Size: 6086
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=hfS6RsR5kjsKcGJBFHaOUQyC3/8MsUUHBDSv8Fc2tAY=; b=aHIuwPxrfJ6VgYAFHUe3HF6WvO
	VvC9ZXTXF3YbQgV/nw+aupbSt5/kftWSDJM6y9+Gy9q5iVowI+1f+Eh/0BUa6tRo/mbtIIfhAEw8a
	VG4obijb46aDWR2joJqDlbTtr0HQq+PQmF4b+d1dN52OBLVSGbu9XUDGYucPSNwxnnPsaFuTnYPTo
	EMwQ2U0+5E0XGwApoLUggf8SbKELOmiOF4yRHfgZrpRzKarTgj3W9F5xjqRk4XNOqFe8odjp3SGqY
	eM3+mob4z2HiWLHg+DUzyoZ9FCC5tSvGXwjMpYxgR8s1MokjeKZPzPda7qldT45SDaykrMgF1+6sM
	ytpTgR6g==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hxoC5-0007zb-Cc; Wed, 14 Aug 2019 07:59:41 +0000
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
Subject: [PATCH 03/10] nouveau: factor out device memory address calculation
Date: Wed, 14 Aug 2019 09:59:21 +0200
Message-Id: <20190814075928.23766-4-hch@lst.de>
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

Factor out the repeated device memory address calculation into
a helper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 42 +++++++++++---------------
 1 file changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nou=
veau/nouveau_dmem.c
index e696157f771e..d469bc334438 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -102,6 +102,14 @@ struct nouveau_migrate {
 	unsigned long dma_nr;
 };
=20
+static unsigned long nouveau_dmem_page_addr(struct page *page)
+{
+	struct nouveau_dmem_chunk *chunk =3D page->zone_device_data;
+	unsigned long idx =3D page_to_pfn(page) - chunk->pfn_first;
+
+	return (idx << PAGE_SHIFT) + chunk->bo->bo.offset;
+}
+
 static void nouveau_dmem_page_free(struct page *page)
 {
 	struct nouveau_dmem_chunk *chunk =3D page->zone_device_data;
@@ -169,9 +177,7 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_stru=
ct *vma,
 	/* Copy things over */
 	copy =3D drm->dmem->migrate.copy_func;
 	for (addr =3D start, i =3D 0; addr < end; addr +=3D PAGE_SIZE, i++) {
-		struct nouveau_dmem_chunk *chunk;
 		struct page *spage, *dpage;
-		u64 src_addr, dst_addr;
=20
 		dpage =3D migrate_pfn_to_page(dst_pfns[i]);
 		if (!dpage || dst_pfns[i] =3D=3D MIGRATE_PFN_ERROR)
@@ -194,14 +200,10 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_st=
ruct *vma,
 			continue;
 		}
=20
-		dst_addr =3D fault->dma[fault->npages++];
-
-		chunk =3D spage->zone_device_data;
-		src_addr =3D page_to_pfn(spage) - chunk->pfn_first;
-		src_addr =3D (src_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
-
-		ret =3D copy(drm, 1, NOUVEAU_APER_HOST, dst_addr,
-				   NOUVEAU_APER_VRAM, src_addr);
+		ret =3D copy(drm, 1, NOUVEAU_APER_HOST,
+				fault->dma[fault->npages++],
+				NOUVEAU_APER_VRAM,
+				nouveau_dmem_page_addr(spage));
 		if (ret) {
 			dst_pfns[i] =3D MIGRATE_PFN_ERROR;
 			__free_page(dpage);
@@ -687,18 +689,12 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_=
struct *vma,
 	/* Copy things over */
 	copy =3D drm->dmem->migrate.copy_func;
 	for (addr =3D start, i =3D 0; addr < end; addr +=3D PAGE_SIZE, i++) {
-		struct nouveau_dmem_chunk *chunk;
 		struct page *spage, *dpage;
-		u64 src_addr, dst_addr;
=20
 		dpage =3D migrate_pfn_to_page(dst_pfns[i]);
 		if (!dpage || dst_pfns[i] =3D=3D MIGRATE_PFN_ERROR)
 			continue;
=20
-		chunk =3D dpage->zone_device_data;
-		dst_addr =3D page_to_pfn(dpage) - chunk->pfn_first;
-		dst_addr =3D (dst_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
-
 		spage =3D migrate_pfn_to_page(src_pfns[i]);
 		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE)) {
 			nouveau_dmem_page_free_locked(drm, dpage);
@@ -716,10 +712,10 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_=
struct *vma,
 			continue;
 		}
=20
-		src_addr =3D migrate->dma[migrate->dma_nr++];
-
-		ret =3D copy(drm, 1, NOUVEAU_APER_VRAM, dst_addr,
-				   NOUVEAU_APER_HOST, src_addr);
+		ret =3D copy(drm, 1, NOUVEAU_APER_VRAM,
+				nouveau_dmem_page_addr(dpage),
+				NOUVEAU_APER_HOST,
+				migrate->dma[migrate->dma_nr++]);
 		if (ret) {
 			nouveau_dmem_page_free_locked(drm, dpage);
 			dst_pfns[i] =3D 0;
@@ -846,7 +842,6 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
=20
 	npages =3D (range->end - range->start) >> PAGE_SHIFT;
 	for (i =3D 0; i < npages; ++i) {
-		struct nouveau_dmem_chunk *chunk;
 		struct page *page;
 		uint64_t addr;
=20
@@ -864,10 +859,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 			continue;
 		}
=20
-		chunk =3D page->zone_device_data;
-		addr =3D page_to_pfn(page) - chunk->pfn_first;
-		addr =3D (addr + chunk->bo->bo.mem.start) << PAGE_SHIFT;
-
+		addr =3D nouveau_dmem_page_addr(page);
 		range->pfns[i] &=3D ((1UL << range->pfn_shift) - 1);
 		range->pfns[i] |=3D (addr >> PAGE_SHIFT) << range->pfn_shift;
 	}
--=20
2.20.1


