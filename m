Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65E70C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D65D2084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Lr8ynP2g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D65D2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4E8A8E0019; Mon, 17 Jun 2019 08:28:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFD4F8E000B; Mon, 17 Jun 2019 08:28:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEE148E0019; Mon, 17 Jun 2019 08:28:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84B058E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:30 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a21so7651061pgh.11
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0yZBn1Jd+ueRQDmZpJ4SByMI24Y/dLErXZNb3pgx5jo=;
        b=HNOzNs2MmgkZIjDh3B1y54Pt5Jqfg/4kbSNRxcjaV9sV07+pYejf8J+jjP4zQaqJ1i
         3EU3pMNxmT9d2leN2AkDIqKKcnKSkRyyZcz7/objlWwXGFv/vG+SIdXoklS8Sm0AdOIt
         3A5T6Gt04fWsq757549BA6y8GybmhnAcsNSu039UvSADF15oNDSc2COc/9O/BjEkw37Q
         AliZhkTM1iUN1fmMFd4DiV3d86S7RPNFuOqJpvyZ5noG67aWpwVJkoE4z8wUAyKba47H
         G96nwQGOVBBpzqqWlGRarQxD5bnZaXKZCj/ZhoRQl/4NOSA24nr4MfWdkgElQZBVMqjh
         YwhQ==
X-Gm-Message-State: APjAAAUyexnShMdhFOgJIV4K4ivhHBm1xEdmQ58PkNaDcgIFPo4fqjos
	tija5SAZXmYldnU5YrencQ1MHZcPqPtqf8Z9hdbQClctgUjc5s3+dVzYNuJGONEv6RIm2yG78fk
	j4Pj6CBia2yj3A37fvzzOp17l2AvFzgecHvPUcA5XJDTlIhfROomhBrQJiiaX+mU=
X-Received: by 2002:a17:902:8a87:: with SMTP id p7mr90649441plo.124.1560774510202;
        Mon, 17 Jun 2019 05:28:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxl7Sy/zba6S0hv1JYSH80MlhcTaKiVKpBsP4CbMaqVDYJvkHtI/8QPQjoIn0V2q9QwyI3G
X-Received: by 2002:a17:902:8a87:: with SMTP id p7mr90649392plo.124.1560774509352;
        Mon, 17 Jun 2019 05:28:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774509; cv=none;
        d=google.com; s=arc-20160816;
        b=bt/4VbHb5bEwSTHgLiJmxiXe3LEJOPZUr1y0styCTcTlUp855FPVOoY9dZzcH+6Jy6
         borFPN8/lTFrsbj5tHBtCKb9kap0nZjMMVSwXlA8ZIAIoJV39C9IJuhdo/oWlf3YVish
         oJGctjT/0NrwZh/hCMCzCm8EFW7Yi/yIfx0fdCzJD2WSnGMvVZY+8Qa301Kx4KpqWCeX
         hGzY9MlKlP5ZD2HKDYF6A4Hjsy5Jbwv0ruNBP00ENjSTbv0ZfUNIkcty0EFL7lK+bFjJ
         QUbv36lRM20YwxOaCtFSy/xOs3qa5FXXxJ+zty6Ef0JQivsMxXVfsqsHw3ZHxj79He5M
         9gqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0yZBn1Jd+ueRQDmZpJ4SByMI24Y/dLErXZNb3pgx5jo=;
        b=hY44kI5C4ZGWrvbpFgaqvaQ/9A+Qy0tfNSMJGQxepcxsKm2iVw9jC8S6w1H8oDRaN1
         fnNGDDNu8fRv5mIyNbVeLxjkcmq6MpcfTD74j/Qkk4c48NIyqq1i26RZxGe9JAd7kBnF
         MtJ5o1Cm38PRThNms33KwOLpyDfvDNIff8c67FTm+GOkEbVWDiqmpt/VLeeyDXfwCGGb
         OHCBx+J5+b3bZzjWvjQWmP+beH/pjLkqQv/bzA5k7n4KcO0CzQIrX/zkc7rXkuvVUFag
         dR0CrhOCIkm1eok+Ij72Q0xGGRwX9wOmvyUP+DG6UN612u/IL+mSGcKUzjeOzZVZJngR
         xGvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Lr8ynP2g;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k8si11398160pgc.106.2019.06.17.05.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Lr8ynP2g;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=0yZBn1Jd+ueRQDmZpJ4SByMI24Y/dLErXZNb3pgx5jo=; b=Lr8ynP2g3Y92KKaQ59/yF3NTjZ
	TWvdMWe/bvOmY4QOoQsr0PAX4STArOCo7mEUi5ObiE2nDvaD0ED1Se4EHb9iG6anywYQJKqI/EoND
	3Stjx5oQyNFSGChcyE3FdbOUC6Vh4H22DHJFnNSOXAxsQPCXYPLk2oa3qawqsH6SF17xDKXt4gqT7
	xRfQ6shEPBOeiXVoxuRIxQWgpjUzdiE4obV9yA0SFl92XkHvzIBK7uHvv5zVWETiOks0YpUrBkFuD
	ihfRs3rPAff7QWBnfqpn0u3FoUBDU7IvFBozznUeNQiQHB9Bu2g0gCk43wHfVG6TxCN6mY5jxGVfX
	r67td82A==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqkM-0000Td-4M; Mon, 17 Jun 2019 12:28:26 +0000
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
Subject: [PATCH 22/25] mm: simplify ZONE_DEVICE page private data
Date: Mon, 17 Jun 2019 14:27:30 +0200
Message-Id: <20190617122733.22432-23-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Remove the clumsy hmm_devmem_page_{get,set}_drvdata helpers, and
instead just access the page directly.  Also make the page data
a void pointer, and thus much easier to use.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 18 +++++++----------
 include/linux/hmm.h                    | 27 --------------------------
 include/linux/mm_types.h               |  2 +-
 mm/page_alloc.c                        |  8 ++++----
 4 files changed, 12 insertions(+), 43 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 0fb7a44b8bc4..42c026010938 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -104,11 +104,8 @@ struct nouveau_migrate {
 
 static void nouveau_dmem_page_free(struct page *page)
 {
-	struct nouveau_dmem_chunk *chunk;
-	unsigned long idx;
-
-	chunk = (void *)hmm_devmem_page_get_drvdata(page);
-	idx = page_to_pfn(page) - chunk->pfn_first;
+	struct nouveau_dmem_chunk *chunk = page->zone_device_data;
+	unsigned long idx = page_to_pfn(page) - chunk->pfn_first;
 
 	/*
 	 * FIXME:
@@ -200,7 +197,7 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 
 		dst_addr = fault->dma[fault->npages++];
 
-		chunk = (void *)hmm_devmem_page_get_drvdata(spage);
+		chunk = spage->zone_device_data;
 		src_addr = page_to_pfn(spage) - chunk->pfn_first;
 		src_addr = (src_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
 
@@ -633,9 +630,8 @@ nouveau_dmem_init(struct nouveau_drm *drm)
 		list_add_tail(&chunk->list, &drm->dmem->chunk_empty);
 
 		page = pfn_to_page(chunk->pfn_first);
-		for (j = 0; j < DMEM_CHUNK_NPAGES; ++j, ++page) {
-			hmm_devmem_page_set_drvdata(page, (long)chunk);
-		}
+		for (j = 0; j < DMEM_CHUNK_NPAGES; ++j, ++page)
+			page->zone_device_data = chunk;
 	}
 
 	NV_INFO(drm, "DMEM: registered %ldMB of device memory\n", size >> 20);
@@ -698,7 +694,7 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
 		if (!dpage || dst_pfns[i] == MIGRATE_PFN_ERROR)
 			continue;
 
-		chunk = (void *)hmm_devmem_page_get_drvdata(dpage);
+		chunk = dpage->zone_device_data;
 		dst_addr = page_to_pfn(dpage) - chunk->pfn_first;
 		dst_addr = (dst_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
 
@@ -862,7 +858,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 			continue;
 		}
 
-		chunk = (void *)hmm_devmem_page_get_drvdata(page);
+		chunk = page->zone_device_data;
 		addr = page_to_pfn(page) - chunk->pfn_first;
 		addr = (addr + chunk->bo->bo.mem.start) << PAGE_SHIFT;
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 50ef29958604..454be41f2eaf 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -586,33 +586,6 @@ static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
-/*
- * hmm_devmem_page_set_drvdata - set per-page driver data field
- *
- * @page: pointer to struct page
- * @data: driver data value to set
- *
- * Because page can not be on lru we have an unsigned long that driver can use
- * to store a per page field. This just a simple helper to do that.
- */
-static inline void hmm_devmem_page_set_drvdata(struct page *page,
-					       unsigned long data)
-{
-	page->hmm_data = data;
-}
-
-/*
- * hmm_devmem_page_get_drvdata - get per page driver data field
- *
- * @page: pointer to struct page
- * Return: driver data value
- */
-static inline unsigned long hmm_devmem_page_get_drvdata(const struct page *page)
-{
-	return page->hmm_data;
-}
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 #else /* IS_ENABLED(CONFIG_HMM) */
 static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8ec38b11b361..f33a1289c101 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -158,7 +158,7 @@ struct page {
 		struct {	/* ZONE_DEVICE pages */
 			/** @pgmap: Points to the hosting device page map. */
 			struct dev_pagemap *pgmap;
-			unsigned long hmm_data;
+			void *zone_device_data;
 			unsigned long _zd_pad_1;	/* uses mapping */
 		};
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 17a39d40a556..c0e031c52db5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5886,12 +5886,12 @@ void __ref memmap_init_zone_device(struct zone *zone,
 		__SetPageReserved(page);
 
 		/*
-		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
-		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
-		 * page is ever freed or placed on a driver-private list.
+		 * ZONE_DEVICE pages union ->lru with a ->pgmap back pointer
+		 * and zone_device_data.  It is a bug if a ZONE_DEVICE page is
+		 * ever freed or placed on a driver-private list.
 		 */
 		page->pgmap = pgmap;
-		page->hmm_data = 0;
+		page->zone_device_data = NULL;
 
 		/*
 		 * Mark the block movable so that blocks are reserved for
-- 
2.20.1

