Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E5B2C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:02:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAEB521E6C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:02:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="onI4no/d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAEB521E6C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D0316B0007; Wed,  7 Aug 2019 11:02:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 581CA6B0008; Wed,  7 Aug 2019 11:02:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 448936B000A; Wed,  7 Aug 2019 11:02:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0ACFC6B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 11:02:56 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 65so52398453plf.16
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 08:02:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=wGZQLypYopVpR2zcFxaVbPhYio/AUJ4Ba+D3g3fb9YU=;
        b=aWNUCgNVfkARkdQAsaE6+HoI72GQsILqZhQHXHZ/Q2JNUHewRyyUUwkOdVfYPeY6N9
         rXzVW+GeDLTyw0Ogh5ZBveYHgJWSaLgYI1fi4K4Tz0UXTEFOIJa6c3oYZtT+52tt9/Ca
         Go1i0vMe6gao/TkT+UigM+5W5E0/iYjWmYubB7EEGDQwYq50vIu9IZOpNQQYg0vn7iGR
         ZjPH8qVjUUznmaFHd3HhwPAozPyXM9BmjP4W0FRD3WyrCry864lOjd2SnAzZoEfUJ2ak
         8L8zMP2KqQIwoHFhjeQRmx1ncVF6ArNm8H3gUK7abs0+b0MX7hpd2Y20hCkSypJJllmP
         suTg==
X-Gm-Message-State: APjAAAV7dWGAqTC+nsJhe+X6DrJUnfFPxERZFm1Oxpzq3zKKj20G2QzR
	RkaClauhHY4UN6PdWbYSt0nCmf1ycyIE0RMpuaQJWQ52y7rlPQWRpYKNf/NOpIYDgbi5/SAz5yD
	9HuCccO8FK1nQWzbHfvCm5hI7zuezS0+vX1wxPSMUOe/W3bKuttiifQf0ksLhN+g40A==
X-Received: by 2002:a17:90a:9f08:: with SMTP id n8mr379112pjp.102.1565190175622;
        Wed, 07 Aug 2019 08:02:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNS77qzzCyT7DfWgLPLaln+t6XRnAiTviaOdLOaIavyTfVqC6huWXQaZf4T+dumxlBfqMx
X-Received: by 2002:a17:90a:9f08:: with SMTP id n8mr378950pjp.102.1565190173874;
        Wed, 07 Aug 2019 08:02:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565190173; cv=none;
        d=google.com; s=arc-20160816;
        b=G7CIdpgx/N+/WEfxwpnWFkpu7c+4v1UQhM7+KBlR4hhpOMQF2Zb6O0DbMXH8Zm5yBy
         WLX+Hc/wggzOB74sYdAFk+RzBbDcW1x8jEBVCWwYD6ygDaBSpGjhJDGa6QmNXBR1kGa8
         Clbi5MdvgXdcUP3mPCPRqGH8BQT5rh89rdfSe4+I2n4EcQ0NFFff8bv2b+rEEUf4huKV
         tDXC6VPiL60Nys81pOW4N2fyHf9bYgc1yDCdaG7nHsv48VDYx4e0zj7LkKC8JTYLRnCy
         SeXGC0j1iS/mX107/v7VUSuusd5TNzoJ+leSpWJ/Q63IcMw2rN9zF3ycBCxfA8dejZfv
         TDiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=wGZQLypYopVpR2zcFxaVbPhYio/AUJ4Ba+D3g3fb9YU=;
        b=nNi8VJs2jL5qehJCcXFKatNP/9CWoKU/OvNIFMasrbDfgsmN1O6LjMjgtE9mrz4kfz
         0qLx7sPYXcWZ3a3wuzvE5kEZ/bu6O9VZ1cSPR5I25Lz/8AK7xnUhNKP6v/95cul/OPqQ
         R5yHAiCG+VClyP22cqCcStGhoTRCW/6Kqu0pK+iADMc88HJ/ppWsIEI4oXJzmhpbivc8
         cA5mq4lD7Ag7x1d2Fe69P/2iM9bybCB50u3I97ihk4qcK+++1wYz3FiDnlpECjFJf0Ag
         iUI0avQNErLdQte5VD8qBStgXIGDOGfTFPS3ETOkjnuOrL/M+sDt8HkZwDH6T5ty50y5
         HUCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="onI4no/d";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 12si50045541pfi.199.2019.08.07.08.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 08:02:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="onI4no/d";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4ae8270000>; Wed, 07 Aug 2019 08:03:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 07 Aug 2019 08:02:53 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 07 Aug 2019 08:02:53 -0700
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 7 Aug
 2019 15:02:51 +0000
Received: from hqnvemgw02.nvidia.com (172.16.227.111) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 7 Aug 2019 15:02:51 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw02.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d4ae81b0001>; Wed, 07 Aug 2019 08:02:51 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>, "Ralph
 Campbell" <rcampbell@nvidia.com>, Christoph Hellwig <hch@lst.de>, "Jason
 Gunthorpe" <jgg@mellanox.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>
Subject: [PATCH] nouveau/hmm: map pages after migration
Date: Wed, 7 Aug 2019 08:02:14 -0700
Message-ID: <20190807150214.3629-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565190183; bh=wGZQLypYopVpR2zcFxaVbPhYio/AUJ4Ba+D3g3fb9YU=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=onI4no/dzvK1PtPWj65mZ6yPUlwn8/J0b9uUMp9Gvf3H4GtcbOW+7/L5rdTHF2ETc
	 3YZGE3df9PSQ3bF5C7qx35edzqpGaNjgEh+YiPJ/NXmOL/oWRaSP2xl0vXnxKmTThp
	 VHowUrXZRgJXidLqcHRBgiTla88UXGmU5lb9ia4WCMGeX4t1n+W+RvCuG2kdqH2A/J
	 gjLkZmrb+Yp9FpC49MVJGEQRgCltJ9RxHwLF/DwVpMzcT3TVa8QX6pcReCIWmAxoJm
	 HndelJGx0uUj/+tU5oFE7rL9qW9N2BSYa2tT+tIWCAizkGKToV2vsiRQHZxHIt9l/H
	 dZv3+xu/Z+hTg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When memory is migrated to the GPU it is likely to be accessed by GPU
code soon afterwards. Instead of waiting for a GPU fault, map the
migrated memory into the GPU page tables with the same access permissions
as the source CPU page table entries. This preserves copy on write
semantics.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
---

This patch is based on top of Christoph Hellwig's 9 patch series
https://lore.kernel.org/linux-mm/20190729234611.GC7171@redhat.com/T/#u
"turn the hmm migrate_vma upside down" but without patch 9
"mm: remove the unused MIGRATE_PFN_WRITE" and adds a use for the flag.


 drivers/gpu/drm/nouveau/nouveau_dmem.c | 45 +++++++++-----
 drivers/gpu/drm/nouveau/nouveau_svm.c  | 86 ++++++++++++++++++++++++++
 drivers/gpu/drm/nouveau/nouveau_svm.h  | 19 ++++++
 3 files changed, 133 insertions(+), 17 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouve=
au/nouveau_dmem.c
index ef9de82b0744..c83e6f118817 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -25,11 +25,13 @@
 #include "nouveau_dma.h"
 #include "nouveau_mem.h"
 #include "nouveau_bo.h"
+#include "nouveau_svm.h"
=20
 #include <nvif/class.h>
 #include <nvif/object.h>
 #include <nvif/if500b.h>
 #include <nvif/if900b.h>
+#include <nvif/if000c.h>
=20
 #include <linux/sched/mm.h>
 #include <linux/hmm.h>
@@ -560,11 +562,12 @@ nouveau_dmem_init(struct nouveau_drm *drm)
 }
=20
 static unsigned long nouveau_dmem_migrate_copy_one(struct nouveau_drm *drm=
,
-		struct vm_area_struct *vma, unsigned long addr,
-		unsigned long src, dma_addr_t *dma_addr)
+		struct vm_area_struct *vma, unsigned long src,
+		dma_addr_t *dma_addr, u64 *pfn)
 {
 	struct device *dev =3D drm->dev->dev;
 	struct page *dpage, *spage;
+	unsigned long paddr;
=20
 	spage =3D migrate_pfn_to_page(src);
 	if (!spage || !(src & MIGRATE_PFN_MIGRATE))
@@ -572,17 +575,21 @@ static unsigned long nouveau_dmem_migrate_copy_one(st=
ruct nouveau_drm *drm,
=20
 	dpage =3D nouveau_dmem_page_alloc_locked(drm);
 	if (!dpage)
-		return 0;
+		goto out;
=20
 	*dma_addr =3D dma_map_page(dev, spage, 0, PAGE_SIZE, DMA_BIDIRECTIONAL);
 	if (dma_mapping_error(dev, *dma_addr))
 		goto out_free_page;
=20
+	paddr =3D nouveau_dmem_page_addr(dpage);
 	if (drm->dmem->migrate.copy_func(drm, 1, NOUVEAU_APER_VRAM,
-			nouveau_dmem_page_addr(dpage), NOUVEAU_APER_HOST,
-			*dma_addr))
+			paddr, NOUVEAU_APER_HOST, *dma_addr))
 		goto out_dma_unmap;
=20
+	*pfn =3D NVIF_VMM_PFNMAP_V0_V | NVIF_VMM_PFNMAP_V0_VRAM |
+		((paddr >> PAGE_SHIFT) << NVIF_VMM_PFNMAP_V0_ADDR_SHIFT);
+	if (src & MIGRATE_PFN_WRITE)
+		*pfn |=3D NVIF_VMM_PFNMAP_V0_W;
 	return migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;
=20
 out_dma_unmap:
@@ -590,18 +597,19 @@ static unsigned long nouveau_dmem_migrate_copy_one(st=
ruct nouveau_drm *drm,
 out_free_page:
 	nouveau_dmem_page_free_locked(drm, dpage);
 out:
+	*pfn =3D NVIF_VMM_PFNMAP_V0_NONE;
 	return 0;
 }
=20
 static void nouveau_dmem_migrate_chunk(struct migrate_vma *args,
-		struct nouveau_drm *drm, dma_addr_t *dma_addrs)
+		struct nouveau_drm *drm, dma_addr_t *dma_addrs, u64 *pfns)
 {
 	struct nouveau_fence *fence;
 	unsigned long addr =3D args->start, nr_dma =3D 0, i;
=20
 	for (i =3D 0; addr < args->end; i++) {
 		args->dst[i] =3D nouveau_dmem_migrate_copy_one(drm, args->vma,
-				addr, args->src[i], &dma_addrs[nr_dma]);
+				args->src[i], &dma_addrs[nr_dma], &pfns[i]);
 		if (args->dst[i])
 			nr_dma++;
 		addr +=3D PAGE_SIZE;
@@ -615,10 +623,6 @@ static void nouveau_dmem_migrate_chunk(struct migrate_=
vma *args,
 		dma_unmap_page(drm->dev->dev, dma_addrs[nr_dma], PAGE_SIZE,
 				DMA_BIDIRECTIONAL);
 	}
-	/*
-	 * FIXME optimization: update GPU page table to point to newly migrated
-	 * memory.
-	 */
 	migrate_vma_finalize(args);
 }
=20
@@ -631,11 +635,12 @@ nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
 	unsigned long npages =3D (end - start) >> PAGE_SHIFT;
 	unsigned long max =3D min(SG_MAX_SINGLE_ALLOC, npages);
 	dma_addr_t *dma_addrs;
+	u64 *pfns;
 	struct migrate_vma args =3D {
 		.vma		=3D vma,
 		.start		=3D start,
 	};
-	unsigned long c, i;
+	unsigned long i;
 	int ret =3D -ENOMEM;
=20
 	args.src =3D kcalloc(max, sizeof(args.src), GFP_KERNEL);
@@ -649,19 +654,25 @@ nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
 	if (!dma_addrs)
 		goto out_free_dst;
=20
-	for (i =3D 0; i < npages; i +=3D c) {
-		c =3D min(SG_MAX_SINGLE_ALLOC, npages);
-		args.end =3D start + (c << PAGE_SHIFT);
+	pfns =3D nouveau_pfns_alloc(max);
+	if (!pfns)
+		goto out_free_dma;
+
+	for (i =3D 0; i < npages; i +=3D max) {
+		args.end =3D start + (max << PAGE_SHIFT);
 		ret =3D migrate_vma_setup(&args);
 		if (ret)
-			goto out_free_dma;
+			goto out_free_pfns;
=20
 		if (args.cpages)
-			nouveau_dmem_migrate_chunk(&args, drm, dma_addrs);
+			nouveau_dmem_migrate_chunk(&args, drm, dma_addrs,
+						   pfns);
 		args.start =3D args.end;
 	}
=20
 	ret =3D 0;
+out_free_pfns:
+	nouveau_pfns_free(pfns);
 out_free_dma:
 	kfree(dma_addrs);
 out_free_dst:
diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouvea=
u/nouveau_svm.c
index a74530b5a523..3e6d7f226576 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -70,6 +70,12 @@ struct nouveau_svm {
 #define SVM_DBG(s,f,a...) NV_DEBUG((s)->drm, "svm: "f"\n", ##a)
 #define SVM_ERR(s,f,a...) NV_WARN((s)->drm, "svm: "f"\n", ##a)
=20
+struct nouveau_pfnmap_args {
+	struct nvif_ioctl_v0 i;
+	struct nvif_ioctl_mthd_v0 m;
+	struct nvif_vmm_pfnmap_v0 p;
+};
+
 struct nouveau_ivmm {
 	struct nouveau_svmm *svmm;
 	u64 inst;
@@ -734,6 +740,86 @@ nouveau_svm_fault(struct nvif_notify *notify)
 	return NVIF_NOTIFY_KEEP;
 }
=20
+static inline struct nouveau_pfnmap_args *
+nouveau_pfns_to_args(void *pfns)
+{
+	struct nvif_vmm_pfnmap_v0 *p =3D
+		container_of(pfns, struct nvif_vmm_pfnmap_v0, phys);
+
+	return container_of(p, struct nouveau_pfnmap_args, p);
+}
+
+u64 *
+nouveau_pfns_alloc(unsigned long npages)
+{
+	struct nouveau_pfnmap_args *args;
+
+	args =3D kzalloc(sizeof(*args) + npages * sizeof(args->p.phys[0]),
+			GFP_KERNEL);
+	if (!args)
+		return NULL;
+
+	args->i.type =3D NVIF_IOCTL_V0_MTHD;
+	args->m.method =3D NVIF_VMM_V0_PFNMAP;
+	args->p.page =3D PAGE_SHIFT;
+
+	return args->p.phys;
+}
+
+void
+nouveau_pfns_free(u64 *pfns)
+{
+	struct nouveau_pfnmap_args *args =3D nouveau_pfns_to_args(pfns);
+
+	kfree(args);
+}
+
+static struct nouveau_svmm *
+nouveau_find_svmm(struct nouveau_svm *svm, struct mm_struct *mm)
+{
+	struct nouveau_ivmm *ivmm;
+
+	list_for_each_entry(ivmm, &svm->inst, head) {
+		if (ivmm->svmm->mm =3D=3D mm)
+			return ivmm->svmm;
+	}
+	return NULL;
+}
+
+void
+nouveau_pfns_map(struct nouveau_drm *drm, struct mm_struct *mm,
+		 unsigned long addr, u64 *pfns, unsigned long npages)
+{
+	struct nouveau_svm *svm =3D drm->svm;
+	struct nouveau_svmm *svmm;
+	struct nouveau_pfnmap_args *args;
+	int ret;
+
+	if (!svm)
+		return;
+
+	mutex_lock(&svm->mutex);
+	svmm =3D nouveau_find_svmm(svm, mm);
+	if (!svmm) {
+		mutex_unlock(&svm->mutex);
+		return;
+	}
+	mutex_unlock(&svm->mutex);
+
+	args =3D nouveau_pfns_to_args(pfns);
+	args->p.addr =3D addr;
+	args->p.size =3D npages << PAGE_SHIFT;
+
+	mutex_lock(&svmm->mutex);
+
+	svmm->vmm->vmm.object.client->super =3D true;
+	ret =3D nvif_object_ioctl(&svmm->vmm->vmm.object, args, sizeof(*args) +
+				npages * sizeof(args->p.phys[0]), NULL);
+	svmm->vmm->vmm.object.client->super =3D false;
+
+	mutex_unlock(&svmm->mutex);
+}
+
 static void
 nouveau_svm_fault_buffer_fini(struct nouveau_svm *svm, int id)
 {
diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.h b/drivers/gpu/drm/nouvea=
u/nouveau_svm.h
index e839d8189461..c00c177e51ed 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.h
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.h
@@ -18,6 +18,11 @@ void nouveau_svmm_fini(struct nouveau_svmm **);
 int nouveau_svmm_join(struct nouveau_svmm *, u64 inst);
 void nouveau_svmm_part(struct nouveau_svmm *, u64 inst);
 int nouveau_svmm_bind(struct drm_device *, void *, struct drm_file *);
+
+u64 *nouveau_pfns_alloc(unsigned long npages);
+void nouveau_pfns_free(u64 *pfns);
+void nouveau_pfns_map(struct nouveau_drm *drm, struct mm_struct *mm,
+		      unsigned long addr, u64 *pfns, unsigned long npages);
 #else /* IS_ENABLED(CONFIG_DRM_NOUVEAU_SVM) */
 static inline void nouveau_svm_init(struct nouveau_drm *drm) {}
 static inline void nouveau_svm_fini(struct nouveau_drm *drm) {}
@@ -44,5 +49,19 @@ static inline int nouveau_svmm_bind(struct drm_device *d=
evice, void *p,
 {
 	return -ENOSYS;
 }
+
+u64 *nouveau_pfns_alloc(unsigned long npages)
+{
+	return NULL;
+}
+
+void nouveau_pfns_free(u64 *pfns)
+{
+}
+
+void nouveau_pfns_map(struct nouveau_drm *drm, struct mm_struct *mm,
+		      unsigned long addr, u64 *pfns, unsigned long npages)
+{
+}
 #endif /* IS_ENABLED(CONFIG_DRM_NOUVEAU_SVM) */
 #endif
--=20
2.20.1

