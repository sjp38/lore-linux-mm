Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5BE2C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E81521473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="o60fvrdj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E81521473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5A256B0276; Thu, 13 Jun 2019 05:44:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDF1F6B0277; Thu, 13 Jun 2019 05:44:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5AA56B0278; Thu, 13 Jun 2019 05:44:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 892746B0276
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 21so13471368pgl.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ST5vXDP0wxZAFs+13zRZ2VJKiKZc1CoEKVcbqRs6asg=;
        b=USNWYmxoizgx4aPCACe3vnZxzIysqBEMGHDYg1ZX/p0sUZbV8vazYvUp7gJ7VqJCMB
         eHUvHGicuc0fWVUwoGXQT40c9cAzW8HIyd+0+PLPmvlswp7DJgGfvHD8gDSwEgJp0u/c
         rCEp2Dxpobdy4go5sDFkMILmZe0bVTLZsYbuALPTxyLBUBi5LUXEISOfyTEzhnjZ/exx
         0y7QTpS8TNFLY60l+Qby0/WLXdavPrSY23AtExkKNH+Tw3GsgkWtzV+lpfpkWZoD6rtc
         DHshNSRYQFgHsRf2W3YTElrcG8q422fV9HkrR0sTvewQlbChOikiYnrDdcyX5Bg/oGKp
         cy6w==
X-Gm-Message-State: APjAAAU/X3eZtqOhu/tBFBL7/WEV5TFxUokUYYttwfJrrGj5bNVsunJU
	Fe4jZXgvE0+qeDr/vJK57qZPNvOYlQPm0MkcubAC2FdEwh+cG0XvyqLl7IxqCwhNp6kDJNatIuW
	JbT9xIrMl+tOUE14zfS6C0aIofJmHC6O9qZgjgmtejj7QuZnmlBTBgbMIp10Rw1M=
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr4426300pje.130.1560419068203;
        Thu, 13 Jun 2019 02:44:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1CdVZ9Ybe80xKsLbEM+9aLlGWeU6tb0gIEkJrsAZBiwV9Ctdl81RAVvzm/qaerOECGIJL
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr4426186pje.130.1560419067183;
        Thu, 13 Jun 2019 02:44:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419067; cv=none;
        d=google.com; s=arc-20160816;
        b=j2wg5FKsx8z4zm0aV0FWB8h4vuwYNu3O7PPfU64xry3ZOJL5bZ4Wq3fzkgqr4EZV7J
         IEIYE8TnIKwaOx4uItmSQnM8vssKLJPEYyIOEoKasGaLgXaJDNZwdC+c76t0ju+M1tAW
         qTJe6fEyTgz5Rg8i7EI9O/R5dHBQN1Z7LNZSNNwy6JCpcNV4Ob7VJ7qK4eQwemv1ZSEy
         OSFEbgtQrGK7MSkTsB20aOdhvPrJwvacYs0HFKTkrfmjDw0aPlBbHLdXT0TplIg0Kjlp
         wbW887QzOgi2NnFm90Mv7bQrqhWqCjxfJ++s1d7z5hxHdmTDtMTi1ghuoLxKK3onkgtX
         TDgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ST5vXDP0wxZAFs+13zRZ2VJKiKZc1CoEKVcbqRs6asg=;
        b=r/fyeIlK2xgzvBrfM7/BkW8IE3DVsG1tQUXdW9gOk7i3HMxoxPdX1T3o+EeWkd0pdn
         ZtmBu6DJ72SVKY/ghDRS8EK+ze40MWmaDTpT+lUzzCZM+sogX4Pl4K3ymFbOKvHZM0HF
         hUfq82NpDYr21kY3837NfX1LQgdwP3YvvsdB1JS/W6WzFk06LbOC/SSNbdbsmLMJY8Pu
         Hfji/pUwZ3So3T5a+Avqx9M0r+f2I0pjrccZ5edj6DkVrjlpw38mlcqlJqzIQWBUO4cF
         krcP/Vj3y+YnxMoAFcp2tDfBAZZ8xO3tmBJen+RWClEO5Vx6ALibg9yQkmjZ4wZDYhQn
         MG2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=o60fvrdj;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s24si2632447pgm.327.2019.06.13.02.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=o60fvrdj;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ST5vXDP0wxZAFs+13zRZ2VJKiKZc1CoEKVcbqRs6asg=; b=o60fvrdjva6GPXOY7bWBawc6ta
	0VTdlbWHmmpNA05wC2tx9zYyp5vxCSFXni3mwAYEo/JBfwXp+ip6D7QSxCyt6RsLm6bkCBG4evj7W
	uLJKEpwWIrv5wjFFQ+/vT588yk1NuNPnmFI/ifWHUX2+fx93ET4T0o8OjB+Ag5kwwEpG4PAAQ4evQ
	5Qmy0oIpRMwn7fkxXQK5/g1paPzm38DzgVl72fd1ZqQ/K8gUf1mi0G9Qv1PWHT0qLuF6X42bqPSGX
	It5fsP86hUBvvu/gab1CK5Bz5//1Jz5zbVZXS9iFZbny1chkNTg7sqFV9amTjjSAiH8zqxZoqFe7y
	bMa6st9A==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMHP-0001w6-RZ; Thu, 13 Jun 2019 09:44:24 +0000
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
Subject: [PATCH 19/22] mm: simplify ZONE_DEVICE page private data
Date: Thu, 13 Jun 2019 11:43:22 +0200
Message-Id: <20190613094326.24093-20-hch@lst.de>
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
index 9e32bc8ecbc7..27aa4e72abe9 100644
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
 
@@ -864,7 +860,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 			continue;
 		}
 
-		chunk = (void *)hmm_devmem_page_get_drvdata(page);
+		chunk = page->zone_device_data;
 		addr = page_to_pfn(page) - chunk->pfn_first;
 		addr = (addr + chunk->bo->bo.mem.start) << PAGE_SHIFT;
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 13152ab504ec..e095a8b55dfa 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -550,33 +550,6 @@ static inline void hmm_mm_init(struct mm_struct *mm)
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
index d66bc8abe0af..d069ee1f4c2e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5887,12 +5887,12 @@ void __ref memmap_init_zone_device(struct zone *zone,
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
+		page->zone_device_data = 0;
 
 		/*
 		 * Mark the block movable so that blocks are reserved for
-- 
2.20.1

