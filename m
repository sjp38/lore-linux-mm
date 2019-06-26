Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECE93C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A878C2063F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qQ/u8z56"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A878C2063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 369B88E001C; Wed, 26 Jun 2019 08:28:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F3DC8E0005; Wed, 26 Jun 2019 08:28:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 147A78E001C; Wed, 26 Jun 2019 08:28:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCF0D8E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:29 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id e7so1357015plt.13
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=U8ovc4WTwnLx7F/LiZCoIjre+/SW/FETirwHxoajq6c=;
        b=HGsyytbf1JI34xzgeP18qASU27o2mxb0ZAp8I3krP9V74F/wwvHj/GwR34NoUKfkn7
         5Ov0spUWbNdcz9P0nAdLpgSKXlDh5TPaHo4fz+wY2yAY4kHYYgUw6IE+ZoVWPWBxMnuB
         95IIK3JhRk7r8rsIoY46dR+s0yU6sJfVj7xPv23cOo9wQYHU7T/q4vrv/4uYCsfq6jQG
         ynZnlcjWTO2yqeypwzjzTMJop823tQN98EulZEBYy4Cr6g6NCgZSlpf5x44f3/Tqy0uG
         FqUOqOVtE9R62UGAHSodekYpaHu1gOglZPIPM3X5Y0Ydf9yVPmw32STpvRcp1EMTTQfa
         5HNw==
X-Gm-Message-State: APjAAAWZh451XMrz70l4kTbWfguIiatjVkppTA3ulM84WSmpLeVLkfGf
	+7z4LPeC0RvUCJdunhMOsVxqsqC64WCW+3/H73GLSVBTp1cKXpzX/quIjaiwd1A5WhFG0U4bChu
	DbfMdEFTSxGa5TI93ObGwAKbTAfqVmwUch7sGpRDI5wnpZuFFWpHHIbMwWbq14Qs=
X-Received: by 2002:a63:ee0c:: with SMTP id e12mr2791552pgi.184.1561552109402;
        Wed, 26 Jun 2019 05:28:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdaN4hC3L/frASv9O0PGMwMXIKlEjeSNDLmbiG6Jr5tCeqZb43itc0gPwzjGUAmsNi1QE3
X-Received: by 2002:a63:ee0c:: with SMTP id e12mr2791488pgi.184.1561552108525;
        Wed, 26 Jun 2019 05:28:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552108; cv=none;
        d=google.com; s=arc-20160816;
        b=p3wxAL89/SmshplNTGYk+l7GhWsiLvkixw1S5qBL0vCNFAS8JKGtPHXeCDcQRoAU5u
         PdGrnpj96BKubSgQvwWCP76KNMDb8W9OcEPnCRzaOKMhX7hbVtlZRG/oOdg8Qy31GPBU
         5fOXha+9NG1inndFa3V+Zw2WbSXYaz2qz6UKsPy4EbcNM69+lbizg6PsTPDXWL19iP5i
         EebH/MErrpoOBAAOO3+tEHeJZ3RCbfqplWAofbRS9q3Y5l54g9SXI2fMSKknDy30hQaF
         lMQHCyqDPX3umHR85o+M0qyDz+k0Z7QKeVQ3kkg0tfQUY3zSjRZd7bZtKkUAHgh/QQVi
         WiIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=U8ovc4WTwnLx7F/LiZCoIjre+/SW/FETirwHxoajq6c=;
        b=ga6ErPXB3BzJSoWc+GQchhgrDD0fGHd9OG/DwMtRqzyTa30TQhMTsk73vSVVAcfUko
         7DANj8jXIj67tcGSyN5sBHWARej5ckW9HRNQpfyAbGCZz7xN0L0lvW/T2192vxzcn23K
         ksZQ77ojGcrzbKM31X/p0KoiDeJ5KXCBJRQCYTSrpAC/nRfJzwaYJaUMOuxenf0kgmRZ
         c+Be05HEtTh6R1UX/8dlE2Cwiv/r1Yv5D5NOwNWBOBbLSh8RmwDKfxiUElEXTgwctf7B
         vAsi//zRo5cpVxkszCrSu788+3KNUWiJgGq6Agwjo5tfrjV1oQ+MWqN07b65Adf6Xbrl
         uQfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="qQ/u8z56";
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g3si15846814pgq.247.2019.06.26.05.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="qQ/u8z56";
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=U8ovc4WTwnLx7F/LiZCoIjre+/SW/FETirwHxoajq6c=; b=qQ/u8z56xU9mfbqQN6tyeQBlFM
	ZK9nFZF90cDqpofPjuvNx4qSQiOJWXKAvNK1R4pNh5ZU7sgI9qEokbjwoKNqOq2jdl6uarrX/vc0p
	hvwUNz1VZ0Ma1qiyc0HQN+WoNz48SUGdFZlf4pPv9ii1mC6pe5F/2u7IxmCniJbsX3uq7jTvLv78S
	Z4v6+5F9aAkLS0+Vac/orsjkQURZePG57AJddUchAi/8lOdQsc7akhimT4jFDMZNvyH/urTu9zV4n
	byCoV/htdJTMJbMfUzfUnkyudRhO13bGJRA2vcLzOKbVmOip+aXQKAaaYhQvwH9+qaP12x4YxvJ5C
	XBpgHV2w==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg72H-0001di-9H; Wed, 26 Jun 2019 12:28:25 +0000
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
Date: Wed, 26 Jun 2019 14:27:21 +0200
Message-Id: <20190626122724.13313-23-hch@lst.de>
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

Remove the clumsy hmm_devmem_page_{get,set}_drvdata helpers, and
instead just access the page directly.  Also make the page data
a void pointer, and thus much easier to use.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 18 ++++++---------
 include/linux/hmm.h                    | 32 --------------------------
 include/linux/mm_types.h               |  2 +-
 mm/page_alloc.c                        |  8 +++----
 4 files changed, 12 insertions(+), 48 deletions(-)

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
index 86aa4ec3404c..3d00e9550e77 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -584,36 +584,4 @@ static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
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
-#endif /* CONFIG_DEVICE_PRIVATE */
-#else /* IS_ENABLED(CONFIG_HMM) */
-static inline void hmm_mm_destroy(struct mm_struct *mm) {}
-static inline void hmm_mm_init(struct mm_struct *mm) {}
-#endif /* IS_ENABLED(CONFIG_HMM) */
-
 #endif /* LINUX_HMM_H */
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

