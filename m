Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52AECC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FE1920B1F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jgy09Umb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FE1920B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE2A98E001A; Wed, 26 Jun 2019 08:28:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6D0A8E0005; Wed, 26 Jun 2019 08:28:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E71B8E001A; Wed, 26 Jun 2019 08:28:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE4A8E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:21 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y7so1681663pfy.9
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=h3EyOBgzIzwY5aTyr8+M/7FbufnJaVYVU0zNDtVIxKY=;
        b=YZSTGTF7nnEADo+LQJNbZT7Ey+gBHpzeh+2lLfnpLT2KBX0CL8JQ3munFxxswpHZoo
         PM5FGwDKVE1It7R578ToUOCaZtH4XefnIVTnvfZ6WSO9YLSt3tQ5rBRlljcZJBZ+UQ8I
         PPuHtcYcMKtUvKUfxPC9P4Un0sQtQpxHT8eesZnxOTjp/Bn42AODgAp64lhGq5SgdKkW
         7qHOt4luB8xUoHFCHkneplajwaFXduolUrT4lp+Rq7SquJz7tZOOp8GdtOWoejOoukoj
         IMGtqAAXiCeWBXTm2ueXkOWosLnQUrAEcQy4K/B0MfgYnYA2xzPNbhmM4P03mbhoWNne
         xQsw==
X-Gm-Message-State: APjAAAWAjYon10+mnZWZ9fp5iIX0p6YnvA16nodIBP8+IT7brwtIHJg6
	D883gavGoZ85BEb7e3isyOX73DLJz9rrp/f6ITaDGUOf8M/6K7oIU0sTPbnJqOFMxXTpG/qFVqo
	cC54PTPijLXmIkrhvSlhWy3kw4q51HiHqgXvj8bnXole4XFOpiTD3UO9zvs3gNEY=
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr4515221pjn.134.1561552100984;
        Wed, 26 Jun 2019 05:28:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHhVRvzsjyj7OzOzAuLaUJO7p67z4agbrlbku5uJr/h3HwPYKf+D1K1pY2UKBssLXYyLfT
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr4515144pjn.134.1561552100090;
        Wed, 26 Jun 2019 05:28:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552100; cv=none;
        d=google.com; s=arc-20160816;
        b=nSOfcymj3ouEN5In46COVXNPwpw3Odd3e6iBmBWjCcQpohbUdM31A+zSGDv3fyPjA1
         Ziao1cDvfovHIWuRxgUKwt6BoM9VjEb90/2lVZpixR84eN+juFXOd5gRMwLpo/ua0jG4
         QqkikN1oyCh4qM8cwExlTgPIsXd/VCii661577BXXFJRTQcIfb1+QXrwWUiUdVQJawRF
         sB8FxsJ60S8o9mQ3uI5YaAehf2/kT2G++w0Fm/8erZTPtCZPF+lw7wh+03xP4pSgJKSc
         q+Oi00zJCDn+0/kmyl42RGMXKzcVbV0kxr4K4q/s6QHb5+4KLd2u6FqY1HwUfYp+9u2I
         DPuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=h3EyOBgzIzwY5aTyr8+M/7FbufnJaVYVU0zNDtVIxKY=;
        b=FIc57KcSakXlKsIioH1RBcYVJY1Cie/cT/aDgGmDO9tUbhgtHFjPIE8p1Zra7hsS0x
         ddwxgarf39vy2KlPNWCN+mFtgP+DjelKpoUyuB9EyMPJQNPZXmDzAFsTTG5GjS1PfZ+s
         LtqiLCL+l7GRzOEyZ7xFFM6Q1gyV8v1AVrLIk9WpIRhLcwYWR3DX/leHWOuYpzFTxqLv
         WPG/y8FUvcSW9k85VCsaS1qLaSGFTM+nsP316oMmzii68+duEbNuFX6GFA4zSscywyQG
         la0DxD1sZFexcLVdtfDJqmfpK8Q3caSmQfyWJl988Dd+pB04+Twxh5TVexmppargTBO5
         meaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jgy09Umb;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q23si1920964pjp.63.2019.06.26.05.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jgy09Umb;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=h3EyOBgzIzwY5aTyr8+M/7FbufnJaVYVU0zNDtVIxKY=; b=jgy09UmbLfN+TWf3ytByumWWNU
	MBpzdiGmKPVtjV+r0URWfeF2E9GRBVEM/c8PnQUO2wZiW0zBK04cKMOZbgGnhwOq4cUSwiniKoMeX
	nT+P2ZmloBddnkxKnDLCv0p9C9VKIfvJhCYoDMLDhebT7jxtq+qTcxT+DpTV1aEPuh24GfFM+21jc
	kOYj7R6c4SAui71wSqq81SUZTzHwpTbjiSuAhN1+J8BxHpjAxvSj7bpXQIAp5IJs+sveIvxCpy3e5
	M8/sKyXAXPj85iSMU4X7j+qpHu/XpfkJAYPDnm1oVPWTY+HoDT6ptwrKa0Hjb/nKTsoEaSJKqs41g
	dD55ye6w==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg729-0001ab-Cw; Wed, 26 Jun 2019 12:28:17 +0000
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
Subject: [PATCH 19/25] nouveau: use devm_memremap_pages directly
Date: Wed, 26 Jun 2019 14:27:18 +0200
Message-Id: <20190626122724.13313-20-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626122724.13313-1-hch@lst.de>
References: <20190626122724.13313-1-hch@lst.de>
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
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 82 ++++++++++++--------------
 1 file changed, 38 insertions(+), 44 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index a50f6fd2fe24..0fb7a44b8bc4 100644
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
+static vm_fault_t nouveau_dmem_migrate_to_ram(struct vm_fault *vmf)
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
+	.migrate_to_ram		= nouveau_dmem_migrate_to_ram,
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
@@ -833,13 +833,7 @@ nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
 static inline bool
 nouveau_dmem_page(struct nouveau_drm *drm, struct page *page)
 {
-	if (!is_device_private_page(page))
-		return false;
-
-	if (drm->dmem->devmem != page->pgmap->data)
-		return false;
-
-	return true;
+	return is_device_private_page(page) && drm->dmem == page_to_dmem(page);
 }
 
 void
-- 
2.20.1

