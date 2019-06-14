Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 071BFC31E4F
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A806620866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="h+BXnX3J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A806620866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B42C6B0266; Fri, 14 Jun 2019 09:48:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 915D56B0269; Fri, 14 Jun 2019 09:48:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CD696B026A; Fri, 14 Jun 2019 09:48:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0446B0266
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 21so1927480pgl.5
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EZXX45MA5Kr/jRAVRE8+C8CWSuTwR7IM5YlBjilZCgk=;
        b=jcRI56J2NEPQYCxGK3CvdfP+yzoc/zA/3vxY7a/xCcP3kyObqMQH4DSRF2lYOsvQ4C
         2ZJgkRKneQGg7dq172l14EN7BdpSA96nTR3r/xHq1OtLH+DasdqFwc38VfEg9DOvQt43
         YBvevJ385BN8zTvgba2Phg2I9yd1fDQEWuDoP1y0wNAQjUWxhh9EvB5uSMsaoMW3vtcz
         KHSTQjT0j5nMyZ81SM5eQ1iBijHD1SAW791VY1SH2go1UN3t4GLNLHAfTcqJNzrgm2m2
         OF34NK/tJIiloyMHgNaeOuFmIHjMPESuv9G0EIad6TE8ABQcn14XOpSyFJiaxuTmKZ8N
         cP/Q==
X-Gm-Message-State: APjAAAWC30FAksGU0CatBarQuxbxlpzOMXO/cUWW2zgPQbzzWj2woWYl
	S/ewgrNzGOftmSjAfWpC9d+McrQ0Hwde7CAvy4WOChy8/oip6Btucy8D1vT0W+Rjt9emWhXb9Ed
	ZS5rJP77MVMuXIhFp5xhylAsJ+8MH3gl77nec0K94W3xA1FYgRD7htkMJYqPVcec=
X-Received: by 2002:a63:3710:: with SMTP id e16mr35455702pga.391.1560520081579;
        Fri, 14 Jun 2019 06:48:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVLs/GI/ncag1BwwrwUS+ekRgMHFXTTd2sOIcemsgRFTpuFGvHSpz+5j+iLf4QGzr4ndC4
X-Received: by 2002:a63:3710:: with SMTP id e16mr35455638pga.391.1560520080644;
        Fri, 14 Jun 2019 06:48:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520080; cv=none;
        d=google.com; s=arc-20160816;
        b=VOkVSnw2PuCORuwhGk+zbt92l2Z8VJLV7wEtbSmVauLt8e6Hww4fWSpgFqemrXC0L5
         zVI50SlnMC6Y6eGyjgSofCfpsTxkiyyam/dWEI7bQREGYEzMcOloQQyvBaNXE2QHVY7X
         MxhN8qhNRaZ8DYcVodABOXiWRchMy9HHdvYRON51ANLqalXapFgKkZJf+AcQgz+6CPO6
         ywCnmCgKh+V8FPZoyQGBMK3oqmAdDCMQDX5L3e3pgyqkVoJy4MViKysrs158vLD/UXCZ
         6pDr8sFcbh4hwHd0hm3ceMM8QORWgPorH73SXa+zSNgB7jYJa6blkPnA+JrGXyQWm/xf
         snnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EZXX45MA5Kr/jRAVRE8+C8CWSuTwR7IM5YlBjilZCgk=;
        b=H/IaxS4AFW6nt8lYiJnHZQqa1bZsGtEQF27gebUb63iJzVEzAaUq1bCeRfS7kE3l0L
         FOCbHDY5zN4qv13QacDFFGHc19oNh81RAahXb3Lyc87q0qlK2ChmKTR+ilPTOKKx9y5E
         g/7XR5sQ6wx6XNhyvJl8QNjJT1mHIJ9BlKvMGjQYLhrFM4oVwKbq8dh10jYqfZbKpwhN
         +ou2Z5jf8c5VSofZl3zQI8HB3ghVeJf+VOdOGUyS/4rCkULSt4GwhVwRlRdFQEXr7VxP
         r93OCf0KTdDBC2gH/yipHssRaFkRWp7NvHjfxIAGbTCOKI4xIOV6yD2LF9C/CHmogEqI
         quhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=h+BXnX3J;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l7si2623957pgl.562.2019.06.14.06.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=h+BXnX3J;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=EZXX45MA5Kr/jRAVRE8+C8CWSuTwR7IM5YlBjilZCgk=; b=h+BXnX3J4b+gwgk8yPNC/LWr1d
	p0nnzOOFRXth82UzpFCB2ZuQda+YSnZqn1gWN/qSy0zb/PDbkxwFXXm4UiBO6y21DGjJKIpj+/E7T
	t81qzz/2oo9KHsBbfxcBTc0XdOWVcD8Me/I1N4dbHkRIHmscQ3E5EqrB++XzFTrpq2R8zML45F/Ps
	oaAmNvGeU78znGJDV3igN+bPWzpoiS+4Hp8Fqr+cK6dinRTkZnWt3NgNbOOp66Pzk7n5TbtG2mGCw
	5/Tp8vxU8u23qdHv/v9KZKGd58ml8mZRHwcNFbLAEjZXspFap861gPdI5rNvUFMPWJb+9Ka6ShI2/
	EDWZG46A==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYT-0004pk-75; Fri, 14 Jun 2019 13:47:45 +0000
From: Christoph Hellwig <hch@lst.de>
To: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
	linux-arm-kernel@lists.infradead.org (moderated list:ARM PORT),
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	linux-s390@vger.kernel.org,
	devel@driverdev.osuosl.org,
	linux-mm@kvack.org,
	iommu@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 04/16] drm: move drm_pci_{alloc,free} to drm_legacy
Date: Fri, 14 Jun 2019 15:47:14 +0200
Message-Id: <20190614134726.3827-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190614134726.3827-1-hch@lst.de>
References: <20190614134726.3827-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These functions are rather broken in that they try to pass __GFP_COMP
to dma_alloc_coherent, call virt_to_page on the return value and
mess with PageReserved.  And not actually used by any modern driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/drm_bufs.c | 85 ++++++++++++++++++++++++++++++++++++
 drivers/gpu/drm/drm_pci.c  | 89 --------------------------------------
 2 files changed, 85 insertions(+), 89 deletions(-)

diff --git a/drivers/gpu/drm/drm_bufs.c b/drivers/gpu/drm/drm_bufs.c
index bfc419ed9d6c..7418872d87c6 100644
--- a/drivers/gpu/drm/drm_bufs.c
+++ b/drivers/gpu/drm/drm_bufs.c
@@ -38,6 +38,91 @@
 
 #include <linux/nospec.h>
 
+/**
+ * drm_pci_alloc - Allocate a PCI consistent memory block, for DMA.
+ * @dev: DRM device
+ * @size: size of block to allocate
+ * @align: alignment of block
+ *
+ * FIXME: This is a needless abstraction of the Linux dma-api and should be
+ * removed.
+ *
+ * Return: A handle to the allocated memory block on success or NULL on
+ * failure.
+ */
+drm_dma_handle_t *drm_pci_alloc(struct drm_device * dev, size_t size, size_t align)
+{
+	drm_dma_handle_t *dmah;
+	unsigned long addr;
+	size_t sz;
+
+	/* pci_alloc_consistent only guarantees alignment to the smallest
+	 * PAGE_SIZE order which is greater than or equal to the requested size.
+	 * Return NULL here for now to make sure nobody tries for larger alignment
+	 */
+	if (align > size)
+		return NULL;
+
+	dmah = kmalloc(sizeof(drm_dma_handle_t), GFP_KERNEL);
+	if (!dmah)
+		return NULL;
+
+	dmah->size = size;
+	dmah->vaddr = dma_alloc_coherent(&dev->pdev->dev, size,
+					 &dmah->busaddr,
+					 GFP_KERNEL | __GFP_COMP);
+
+	if (dmah->vaddr == NULL) {
+		kfree(dmah);
+		return NULL;
+	}
+
+	/* XXX - Is virt_to_page() legal for consistent mem? */
+	/* Reserve */
+	for (addr = (unsigned long)dmah->vaddr, sz = size;
+	     sz > 0; addr += PAGE_SIZE, sz -= PAGE_SIZE) {
+		SetPageReserved(virt_to_page((void *)addr));
+	}
+
+	return dmah;
+}
+
+/*
+ * Free a PCI consistent memory block without freeing its descriptor.
+ *
+ * This function is for internal use in the Linux-specific DRM core code.
+ */
+void __drm_legacy_pci_free(struct drm_device * dev, drm_dma_handle_t * dmah)
+{
+	unsigned long addr;
+	size_t sz;
+
+	if (dmah->vaddr) {
+		/* XXX - Is virt_to_page() legal for consistent mem? */
+		/* Unreserve */
+		for (addr = (unsigned long)dmah->vaddr, sz = dmah->size;
+		     sz > 0; addr += PAGE_SIZE, sz -= PAGE_SIZE) {
+			ClearPageReserved(virt_to_page((void *)addr));
+		}
+		dma_free_coherent(&dev->pdev->dev, dmah->size, dmah->vaddr,
+				  dmah->busaddr);
+	}
+}
+
+/**
+ * drm_pci_free - Free a PCI consistent memory block
+ * @dev: DRM device
+ * @dmah: handle to memory block
+ *
+ * FIXME: This is a needless abstraction of the Linux dma-api and should be
+ * removed.
+ */
+void drm_pci_free(struct drm_device * dev, drm_dma_handle_t * dmah)
+{
+	__drm_legacy_pci_free(dev, dmah);
+	kfree(dmah);
+}
+
 static struct drm_map_list *drm_find_matching_map(struct drm_device *dev,
 						  struct drm_local_map *map)
 {
diff --git a/drivers/gpu/drm/drm_pci.c b/drivers/gpu/drm/drm_pci.c
index 693748ad8b88..77a215f2a8e4 100644
--- a/drivers/gpu/drm/drm_pci.c
+++ b/drivers/gpu/drm/drm_pci.c
@@ -31,95 +31,6 @@
 #include "drm_internal.h"
 #include "drm_legacy.h"
 
-/**
- * drm_pci_alloc - Allocate a PCI consistent memory block, for DMA.
- * @dev: DRM device
- * @size: size of block to allocate
- * @align: alignment of block
- *
- * FIXME: This is a needless abstraction of the Linux dma-api and should be
- * removed.
- *
- * Return: A handle to the allocated memory block on success or NULL on
- * failure.
- */
-drm_dma_handle_t *drm_pci_alloc(struct drm_device * dev, size_t size, size_t align)
-{
-	drm_dma_handle_t *dmah;
-	unsigned long addr;
-	size_t sz;
-
-	/* pci_alloc_consistent only guarantees alignment to the smallest
-	 * PAGE_SIZE order which is greater than or equal to the requested size.
-	 * Return NULL here for now to make sure nobody tries for larger alignment
-	 */
-	if (align > size)
-		return NULL;
-
-	dmah = kmalloc(sizeof(drm_dma_handle_t), GFP_KERNEL);
-	if (!dmah)
-		return NULL;
-
-	dmah->size = size;
-	dmah->vaddr = dma_alloc_coherent(&dev->pdev->dev, size,
-					 &dmah->busaddr,
-					 GFP_KERNEL | __GFP_COMP);
-
-	if (dmah->vaddr == NULL) {
-		kfree(dmah);
-		return NULL;
-	}
-
-	/* XXX - Is virt_to_page() legal for consistent mem? */
-	/* Reserve */
-	for (addr = (unsigned long)dmah->vaddr, sz = size;
-	     sz > 0; addr += PAGE_SIZE, sz -= PAGE_SIZE) {
-		SetPageReserved(virt_to_page((void *)addr));
-	}
-
-	return dmah;
-}
-
-EXPORT_SYMBOL(drm_pci_alloc);
-
-/*
- * Free a PCI consistent memory block without freeing its descriptor.
- *
- * This function is for internal use in the Linux-specific DRM core code.
- */
-void __drm_legacy_pci_free(struct drm_device * dev, drm_dma_handle_t * dmah)
-{
-	unsigned long addr;
-	size_t sz;
-
-	if (dmah->vaddr) {
-		/* XXX - Is virt_to_page() legal for consistent mem? */
-		/* Unreserve */
-		for (addr = (unsigned long)dmah->vaddr, sz = dmah->size;
-		     sz > 0; addr += PAGE_SIZE, sz -= PAGE_SIZE) {
-			ClearPageReserved(virt_to_page((void *)addr));
-		}
-		dma_free_coherent(&dev->pdev->dev, dmah->size, dmah->vaddr,
-				  dmah->busaddr);
-	}
-}
-
-/**
- * drm_pci_free - Free a PCI consistent memory block
- * @dev: DRM device
- * @dmah: handle to memory block
- *
- * FIXME: This is a needless abstraction of the Linux dma-api and should be
- * removed.
- */
-void drm_pci_free(struct drm_device * dev, drm_dma_handle_t * dmah)
-{
-	__drm_legacy_pci_free(dev, dmah);
-	kfree(dmah);
-}
-
-EXPORT_SYMBOL(drm_pci_free);
-
 #ifdef CONFIG_PCI
 
 static int drm_get_pci_domain(struct drm_device *dev)
-- 
2.20.1

