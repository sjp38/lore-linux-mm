Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A8B2C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 435D021473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FHc5fDnC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 435D021473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8156B6B026F; Thu, 13 Jun 2019 05:44:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79FD26B0270; Thu, 13 Jun 2019 05:44:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 616EE6B0271; Thu, 13 Jun 2019 05:44:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5086B026F
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so14093408pff.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xYfBteKZe/e5Ckife8ohrecFQV6hfjj2YQprkCVN138=;
        b=XvmL+oFaNZeNJTQkin5AZJpSxBSiBCq4gvRZeUDSLhsWZQSxvIvrPZxWtONHbqFMEf
         bH/F2uiq3CnG6p/1wYBkwNJGxTe+vcwLn/XRIe5sW1ncp4raRTc6Yi9ZWeq8pYiVzSgx
         TCVf5kAf+L6dU5S1CX6IAqv2XM34BAlkJzUJKRBAf9lbTYO31fhL3pkKJ7fWR67D0xJl
         13GX9P9S3bgUhsjh4jTemRS2FXPD8dHPXoDNJhAnoSCPtv1NJnOxPVmcBjBijUgh3buz
         gTh6ol1VU0kPmiu95tb4VGiQ89aQHG1IroiAGerFAtd/DK1xMeZEK6ZUNj3aPA0xtqZ9
         BAEw==
X-Gm-Message-State: APjAAAXfvSfZ5ETiDkzBD8/kgD0xIDofpQzgcppSApjxM2spg9B13wJi
	D21GWCKN16OYbCuzhXAL3R0DuA6Bt2F59WVrXEbZS0G2vHDCpbzSdz283WafqWZQtMMIE6RZ749
	S0bMwOCUM85jbfUJc4xOefamwNNqj1GKwGBkhTh7rhxhxro7M00ftZa0jVg01hTQ=
X-Received: by 2002:a17:90a:8a91:: with SMTP id x17mr4352725pjn.95.1560419055769;
        Thu, 13 Jun 2019 02:44:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyydGgyi3jmCjmZPf/ZPEVnnGFHjefo/DocGzpyYvBJ1SxqhP6p6cTkHqhh09ZMFQ8OcQA0
X-Received: by 2002:a17:90a:8a91:: with SMTP id x17mr4352618pjn.95.1560419054822;
        Thu, 13 Jun 2019 02:44:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419054; cv=none;
        d=google.com; s=arc-20160816;
        b=gPt1oap7E5b3aG2AQJ5UPOFk0sw65SyD5bhaHe3U8Jgm9J1ZlxOzSrBcXwiabiHYVY
         EDiRVCpm0h7o2QZ5lWtbFN816458t8cbLYsMF0NMcKQ+otlPAeHy/VxVR1Pa+nyXBLFk
         PSuyKQLuQ6k4kih39NMp11YgPc0urJNynYaoBldIjrdsoxabOg5gIEjejvgy+dw6Juib
         KirINW+iNf+IzhJXUiSEe6ysRfTahFZWmZyMjy/cZEVCVW+4A71mCtD/TPRaxgtWF2nw
         MzSKj2yhn3fv94A9To/6+HT8bwquiNJaGCALWCp7Uk2gIiFnB/ukjnOh7ymAguOnGPBt
         6qjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xYfBteKZe/e5Ckife8ohrecFQV6hfjj2YQprkCVN138=;
        b=IBDC87YRZKURNGMGLLWZajx9qe4foGVgC5/L9T8V85dSaOLXyG13Wm3oBaEJRpIT0Y
         AEJ4ddp5hZlsLg2i6xuUpA1EtL1qX97kKdHSPT01OUzKmeADtDqQabOzrY16lKHO0DQI
         0+lJgvHb4qn2v7HRFTMSsiyzucB8meyT/VWAYTl9X0A9ASG2HJP2iadTSqvpfcjB+EjQ
         xKrBgrDPB85242uBMXYOmvdx5922C6HOrsSgls2ieZnHwLX2ghRPNDUqNJdCG7j2IX4o
         KD/PVttCS1MFtO+DRKOuezVWGq6UgVXQwK5D8EMD8IjYT9PeTNvhkAfc6VDE8tR9X4R7
         IKkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FHc5fDnC;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l10si2688248pgk.276.2019.06.13.02.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FHc5fDnC;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=xYfBteKZe/e5Ckife8ohrecFQV6hfjj2YQprkCVN138=; b=FHc5fDnCPAlG2X1P5hqmN6BAee
	WHf3iENBPRs8zYQpDQqPHSt6VFl+W/mC4zAPs7QsvZ5+2/s2LsCURy9tSKz1/q4hFYNZylr+Oqv5B
	zjYfm+hFE3TcyvD6fP6qk2GNuODPVs4jZRq81oI3rTvaACEI8Km27qsiPAX8JsYZb4lHLwTHE03tG
	9d6udUEpc2xY47EFvzzUdk14MpPcrfZ3EMMY7JNQPXp8Sy9a7L35wlI8DB7oV5VASIbgmY0nwXAu1
	clBKVjIf19N93xjC8Ygkyyt70lJKIA3r2MZyU8I7YH4B8xSktOWIurHDeOMEjy+T3JRDHMXtyUE8W
	Q1zQJh1A==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMHD-0001tQ-VU; Thu, 13 Jun 2019 09:44:12 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 15/22] nouveau: use devm_memremap_pages directly
Date: Thu, 13 Jun 2019 11:43:18 +0200
Message-Id: <20190613094326.24093-16-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just use devm_memremap_pages instead of hmm_devmem_add pages to allow
killing that wrapper which doesn't provide a whole lot of benefits.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 80 ++++++++++++--------------
 1 file changed, 38 insertions(+), 42 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index a50f6fd2fe24..9e32bc8ecbc7 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -72,7 +72,8 @@ struct nouveau_dmem_migrate {
 };
 
 struct nouveau_dmem {
-	struct hmm_devmem *devmem;
+	struct nouveau_drm *drm;
+	struct dev_pagemap pagemap;
 	struct nouveau_dmem_migrate migrate;
 	struct list_head chunk_free;
 	struct list_head chunk_full;
@@ -80,6 +81,11 @@ struct nouveau_dmem {
 	struct mutex mutex;
 };
 
+static inline struct nouveau_dmem *page_to_dmem(struct page *page)
+{
+	return container_of(page->pgmap, struct nouveau_dmem, pagemap);
+}
+
 struct nouveau_dmem_fault {
 	struct nouveau_drm *drm;
 	struct nouveau_fence *fence;
@@ -96,8 +102,7 @@ struct nouveau_migrate {
 	unsigned long dma_nr;
 };
 
-static void
-nouveau_dmem_free(struct hmm_devmem *devmem, struct page *page)
+static void nouveau_dmem_page_free(struct page *page)
 {
 	struct nouveau_dmem_chunk *chunk;
 	unsigned long idx;
@@ -260,29 +265,21 @@ static const struct migrate_vma_ops nouveau_dmem_fault_migrate_ops = {
 	.finalize_and_map	= nouveau_dmem_fault_finalize_and_map,
 };
 
-static vm_fault_t
-nouveau_dmem_fault(struct hmm_devmem *devmem,
-		   struct vm_area_struct *vma,
-		   unsigned long addr,
-		   const struct page *page,
-		   unsigned int flags,
-		   pmd_t *pmdp)
+static vm_fault_t nouveau_dmem_devmem_migrate(struct vm_fault *vmf)
 {
-	struct drm_device *drm_dev = dev_get_drvdata(devmem->device);
+	struct nouveau_dmem *dmem = page_to_dmem(vmf->page);
 	unsigned long src[1] = {0}, dst[1] = {0};
-	struct nouveau_dmem_fault fault = {0};
+	struct nouveau_dmem_fault fault = { .drm = dmem->drm };
 	int ret;
 
-
-
 	/*
 	 * FIXME what we really want is to find some heuristic to migrate more
 	 * than just one page on CPU fault. When such fault happens it is very
 	 * likely that more surrounding page will CPU fault too.
 	 */
-	fault.drm = nouveau_drm(drm_dev);
-	ret = migrate_vma(&nouveau_dmem_fault_migrate_ops, vma, addr,
-			  addr + PAGE_SIZE, src, dst, &fault);
+	ret = migrate_vma(&nouveau_dmem_fault_migrate_ops, vmf->vma,
+			vmf->address, vmf->address + PAGE_SIZE,
+			src, dst, &fault);
 	if (ret)
 		return VM_FAULT_SIGBUS;
 
@@ -292,10 +289,9 @@ nouveau_dmem_fault(struct hmm_devmem *devmem,
 	return 0;
 }
 
-static const struct hmm_devmem_ops
-nouveau_dmem_devmem_ops = {
-	.free = nouveau_dmem_free,
-	.fault = nouveau_dmem_fault,
+static const struct dev_pagemap_ops nouveau_dmem_pagemap_ops = {
+	.page_free		= nouveau_dmem_page_free,
+	.migrate		= nouveau_dmem_devmem_migrate,
 };
 
 static int
@@ -581,7 +577,8 @@ void
 nouveau_dmem_init(struct nouveau_drm *drm)
 {
 	struct device *device = drm->dev->dev;
-	unsigned long i, size;
+	struct resource *res;
+	unsigned long i, size, pfn_first;
 	int ret;
 
 	/* This only make sense on PASCAL or newer */
@@ -591,6 +588,7 @@ nouveau_dmem_init(struct nouveau_drm *drm)
 	if (!(drm->dmem = kzalloc(sizeof(*drm->dmem), GFP_KERNEL)))
 		return;
 
+	drm->dmem->drm = drm;
 	mutex_init(&drm->dmem->mutex);
 	INIT_LIST_HEAD(&drm->dmem->chunk_free);
 	INIT_LIST_HEAD(&drm->dmem->chunk_full);
@@ -600,11 +598,8 @@ nouveau_dmem_init(struct nouveau_drm *drm)
 
 	/* Initialize migration dma helpers before registering memory */
 	ret = nouveau_dmem_migrate_init(drm);
-	if (ret) {
-		kfree(drm->dmem);
-		drm->dmem = NULL;
-		return;
-	}
+	if (ret)
+		goto out_free;
 
 	/*
 	 * FIXME we need some kind of policy to decide how much VRAM we
@@ -612,14 +607,16 @@ nouveau_dmem_init(struct nouveau_drm *drm)
 	 * and latter if we want to do thing like over commit then we
 	 * could revisit this.
 	 */
-	drm->dmem->devmem = hmm_devmem_add(&nouveau_dmem_devmem_ops,
-					   device, size);
-	if (IS_ERR(drm->dmem->devmem)) {
-		kfree(drm->dmem);
-		drm->dmem = NULL;
-		return;
-	}
-
+	res = devm_request_free_mem_region(device, &iomem_resource, size);
+	if (IS_ERR(res))
+		goto out_free;
+	drm->dmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
+	drm->dmem->pagemap.res = *res;
+	drm->dmem->pagemap.ops = &nouveau_dmem_pagemap_ops;
+	if (IS_ERR(devm_memremap_pages(device, &drm->dmem->pagemap)))
+		goto out_free;
+
+	pfn_first = res->start >> PAGE_SHIFT;
 	for (i = 0; i < (size / DMEM_CHUNK_SIZE); ++i) {
 		struct nouveau_dmem_chunk *chunk;
 		struct page *page;
@@ -632,8 +629,7 @@ nouveau_dmem_init(struct nouveau_drm *drm)
 		}
 
 		chunk->drm = drm;
-		chunk->pfn_first = drm->dmem->devmem->pfn_first;
-		chunk->pfn_first += (i * DMEM_CHUNK_NPAGES);
+		chunk->pfn_first = pfn_first + (i * DMEM_CHUNK_NPAGES);
 		list_add_tail(&chunk->list, &drm->dmem->chunk_empty);
 
 		page = pfn_to_page(chunk->pfn_first);
@@ -643,6 +639,10 @@ nouveau_dmem_init(struct nouveau_drm *drm)
 	}
 
 	NV_INFO(drm, "DMEM: registered %ldMB of device memory\n", size >> 20);
+	return;
+out_free:
+	kfree(drm->dmem);
+	drm->dmem = NULL;
 }
 
 static void
@@ -835,11 +835,7 @@ nouveau_dmem_page(struct nouveau_drm *drm, struct page *page)
 {
 	if (!is_device_private_page(page))
 		return false;
-
-	if (drm->dmem->devmem != page->pgmap->data)
-		return false;
-
-	return true;
+	return drm->dmem == page_to_dmem(page);
 }
 
 void
-- 
2.20.1

