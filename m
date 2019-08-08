Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D9FAC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 469572173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pJX0tV82"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 469572173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF6B36B0006; Thu,  8 Aug 2019 11:34:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA54F6B0008; Thu,  8 Aug 2019 11:34:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1E4E6B000E; Thu,  8 Aug 2019 11:34:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75AD06B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:34:06 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id u10so55656683plq.21
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:34:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hfS6RsR5kjsKcGJBFHaOUQyC3/8MsUUHBDSv8Fc2tAY=;
        b=ko4l4rzrxTdcpsqMH7fS/9W0YfoixbWBWB3eteK7ra6ZogH7ggiRHjvhb1PME65F8M
         VGVgViti33YbTbs/t2IOwPLJYmMzR3UJQVgvf+LvEVLPZ1LIPMyUNkT5dPhn02rW5N8U
         nvSYiLV7BN0OkU3K5XFYDMRj6y/gomj6XbOjb3N7Xj9to8+5/ecu7MvQbxV0xSNUW1Js
         dSxRamEd9TWJpVs59SRkP43JaxMnRPWhSwNF1sVmX59XgIXyx9u+qqMDKgbccUVwegrI
         NTJ+fyBqTZEPfF+wRsJlQnV3vgBlxpCeYlW9h8GXduAt6a/aomEI25Z8MW0amOHeJwq7
         4Eng==
X-Gm-Message-State: APjAAAW5QHHoHXXI7Trv1MApxM/sjuJ9+mMHw1yzm3oNWwbI+AnjQuXu
	W2xMjystJslILNHUuRZV8SrW8SnBnL3dB2ICVsF58njZiSXVegYdPNmFAboxiuctl/nTfrtoQ2+
	o8LvSlrF+xzKA7dHZ5bidM+cj9cL/6DVFsVLlJtZ/wIgfOEpS02KKowgi2AwY6w8=
X-Received: by 2002:a17:902:3341:: with SMTP id a59mr13980764plc.186.1565278446144;
        Thu, 08 Aug 2019 08:34:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylOWpUZJ0f31pjybjwmAc7roOzZhAPkC7wysrAcmbfD8sPpMipAy/OkrqX5D1Q8wpA3FiB
X-Received: by 2002:a17:902:3341:: with SMTP id a59mr13980646plc.186.1565278444793;
        Thu, 08 Aug 2019 08:34:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278444; cv=none;
        d=google.com; s=arc-20160816;
        b=g2zQiwLBmqvIi7jm010NVBzfSKZccFMYR89r3KEKvBZILSUvZSvubhV8z0teGz2qBA
         LyQ3Sv+oyGvzW/nXrlMLvQ5mLMDnj2Q9DCvQAOmNyp5wmX2O2KZtZXd9Ac8owdvUlP2V
         xPun2tJjMerFlhps5SASP5DvIsd8czAmUVF/qML3q/gDJlwGltuJ6g/kGc9brlSEArJq
         EqmuSlexVpXUha0cYKGEo+0i9N5cikgsZosPSguYNpl8h1kDDEP9mPihw17SzNbqbyeu
         177uz7kLd+inLUG+4NWzDkKMl9/YZzQOTdW6Px7f6GDp0AmKEaIU6yo1UI4ZHPPcYwQa
         85fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hfS6RsR5kjsKcGJBFHaOUQyC3/8MsUUHBDSv8Fc2tAY=;
        b=hSVcUVYFB8jIpE7Fhls2BAodnSA31gQgmiBTe0BnYQpXM2UO8W1HB2MEW2DU9kS1Ti
         kifVzV4ypxChuwQbSdsr4jj5b81e25IO/8oBJHRBrgoWRFhSz+mYrklgEZooHYA7GXvD
         uFWY+pfxGJTFZd0DtsOW+/lI56qAxuLEXI21oaJQ3ZME6Iipsz6ICgPUwQipdiCZx3aR
         TgTvdEN4BhFtAI/fd3+EaacEwEkPUkEvDFzm+lC1vQTfDfAi0YjF6095v53Isvpr49ik
         SBdB91ldydTYXwznnQrEeueicnszS5MhZ15Pgwjizn8S6lOD4hEqmHJqBLhXiEdaTI1O
         XKyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pJX0tV82;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d13si53148412pgu.268.2019.08.08.08.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:34:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pJX0tV82;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=hfS6RsR5kjsKcGJBFHaOUQyC3/8MsUUHBDSv8Fc2tAY=; b=pJX0tV82090Kv/glM1Mdq/E8dL
	y9UOCu5Z7bdSxe1J1Q/EKiTn/OWwaFq36ShFBf7sJjnBIwKmOBUgHic/Zar0nWnTJ16dlhsbblNZl
	/gJgPxgcXRd2UFdTI0tzY0zkQjn9vKBOkayCs9AKbxsF/OyzuODvpTLUnvmm52cp5te4T4VSy6LqR
	b7rsrT82LqLbMJHjhBuxIitYZfk9eXQfOUVEFLVVZq0XvAD3yVuMXyIo/7I4HXVRMNuuLBUFaKQuu
	csUlpxfSUVUk6wRyOevo01MRleaFVKuT/mPQs7onZOHmkWrpqFbe9DN+SQ3eTEEqRL+2G+tQmA3P9
	SCGJkJMg==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkQR-0005B9-Ja; Thu, 08 Aug 2019 15:34:01 +0000
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
Subject: [PATCH 3/9] nouveau: factor out device memory address calculation
Date: Thu,  8 Aug 2019 18:33:40 +0300
Message-Id: <20190808153346.9061-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808153346.9061-1-hch@lst.de>
References: <20190808153346.9061-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
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

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index e696157f771e..d469bc334438 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -102,6 +102,14 @@ struct nouveau_migrate {
 	unsigned long dma_nr;
 };
 
+static unsigned long nouveau_dmem_page_addr(struct page *page)
+{
+	struct nouveau_dmem_chunk *chunk = page->zone_device_data;
+	unsigned long idx = page_to_pfn(page) - chunk->pfn_first;
+
+	return (idx << PAGE_SHIFT) + chunk->bo->bo.offset;
+}
+
 static void nouveau_dmem_page_free(struct page *page)
 {
 	struct nouveau_dmem_chunk *chunk = page->zone_device_data;
@@ -169,9 +177,7 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 	/* Copy things over */
 	copy = drm->dmem->migrate.copy_func;
 	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
-		struct nouveau_dmem_chunk *chunk;
 		struct page *spage, *dpage;
-		u64 src_addr, dst_addr;
 
 		dpage = migrate_pfn_to_page(dst_pfns[i]);
 		if (!dpage || dst_pfns[i] == MIGRATE_PFN_ERROR)
@@ -194,14 +200,10 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 			continue;
 		}
 
-		dst_addr = fault->dma[fault->npages++];
-
-		chunk = spage->zone_device_data;
-		src_addr = page_to_pfn(spage) - chunk->pfn_first;
-		src_addr = (src_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
-
-		ret = copy(drm, 1, NOUVEAU_APER_HOST, dst_addr,
-				   NOUVEAU_APER_VRAM, src_addr);
+		ret = copy(drm, 1, NOUVEAU_APER_HOST,
+				fault->dma[fault->npages++],
+				NOUVEAU_APER_VRAM,
+				nouveau_dmem_page_addr(spage));
 		if (ret) {
 			dst_pfns[i] = MIGRATE_PFN_ERROR;
 			__free_page(dpage);
@@ -687,18 +689,12 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
 	/* Copy things over */
 	copy = drm->dmem->migrate.copy_func;
 	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
-		struct nouveau_dmem_chunk *chunk;
 		struct page *spage, *dpage;
-		u64 src_addr, dst_addr;
 
 		dpage = migrate_pfn_to_page(dst_pfns[i]);
 		if (!dpage || dst_pfns[i] == MIGRATE_PFN_ERROR)
 			continue;
 
-		chunk = dpage->zone_device_data;
-		dst_addr = page_to_pfn(dpage) - chunk->pfn_first;
-		dst_addr = (dst_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
-
 		spage = migrate_pfn_to_page(src_pfns[i]);
 		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE)) {
 			nouveau_dmem_page_free_locked(drm, dpage);
@@ -716,10 +712,10 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
 			continue;
 		}
 
-		src_addr = migrate->dma[migrate->dma_nr++];
-
-		ret = copy(drm, 1, NOUVEAU_APER_VRAM, dst_addr,
-				   NOUVEAU_APER_HOST, src_addr);
+		ret = copy(drm, 1, NOUVEAU_APER_VRAM,
+				nouveau_dmem_page_addr(dpage),
+				NOUVEAU_APER_HOST,
+				migrate->dma[migrate->dma_nr++]);
 		if (ret) {
 			nouveau_dmem_page_free_locked(drm, dpage);
 			dst_pfns[i] = 0;
@@ -846,7 +842,6 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 
 	npages = (range->end - range->start) >> PAGE_SHIFT;
 	for (i = 0; i < npages; ++i) {
-		struct nouveau_dmem_chunk *chunk;
 		struct page *page;
 		uint64_t addr;
 
@@ -864,10 +859,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 			continue;
 		}
 
-		chunk = page->zone_device_data;
-		addr = page_to_pfn(page) - chunk->pfn_first;
-		addr = (addr + chunk->bo->bo.mem.start) << PAGE_SHIFT;
-
+		addr = nouveau_dmem_page_addr(page);
 		range->pfns[i] &= ((1UL << range->pfn_shift) - 1);
 		range->pfns[i] |= (addr >> PAGE_SHIFT) << range->pfn_shift;
 	}
-- 
2.20.1

