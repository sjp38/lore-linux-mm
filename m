Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58D7EC31E4D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12CF321537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LZajKbx8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12CF321537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC4F16B000E; Fri, 14 Jun 2019 09:48:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4F706B0266; Fri, 14 Jun 2019 09:48:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EEB06B0269; Fri, 14 Jun 2019 09:48:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 546396B000E
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z15so1916306pgk.10
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+xs8xEvecIN+pidhw5Y71rlRjZmb8fJOnZhp8o/DsSw=;
        b=gj/byjEedTfpOogHcY6w97iDw4s7XqgwgpZ9CmcBITiH6FS521OfHIQWiPImuAO+qX
         Wsw6qyn6Rwc+zgWBeaQFMPv2ztSunTK0dxJdFBJEezaQhrY5rkzSeiRgwbo3OKiCxOPl
         nKa9W7RLM3/bXr+PNJQJrVv50gmi6chK9crYo3RAJqEPupReO8xiEQjZo/pIqM/DzSTC
         /SUCJfZyxZcR40aaVcCANvCbAXtrKJX1q+oA1xJaWqr9cd3nc0nZRUAAOdS1jqEHQGi9
         gdtZ5I1rNYFp34ye+JNRoZdrQaWPELYDf4lu1HUuDBY4cpUlIGc9lPwo3o1LWZdZjAxE
         UKAQ==
X-Gm-Message-State: APjAAAXUgvajqw3zErGzurCSEbRiCr8erEhGvzccvheywWyuODLNejeN
	8lkbCIpJHZNHaSiP7QPihT04GEZr6aSwBDq0LTgEpINTYduRkri0+Hjgbb5rw4RK4Yz+qhqQe6/
	yz8rsjL2cmEnuB+ozKwBy8Pk74HGJT0rn+8L/i3KBIEVSGi3kaScSbySpde4vYB0=
X-Received: by 2002:a17:90a:e397:: with SMTP id b23mr11329366pjz.117.1560520080918;
        Fri, 14 Jun 2019 06:48:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYQd8MCquW6wh+uFOwv3xQ5t0Gz8qpRrHn8vyPnZkTmgyKqX4Vww0pa9WXfYAnh82F0wdn
X-Received: by 2002:a17:90a:e397:: with SMTP id b23mr11329295pjz.117.1560520079897;
        Fri, 14 Jun 2019 06:47:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520079; cv=none;
        d=google.com; s=arc-20160816;
        b=BHEy55i1xAyJkw+KvuCD+b+vB3E/Kfh2lvFc7Bf55s+GuarzvTYmbHa2VtWJ/xbmz4
         O7I6WJwRSQS3d5KBZLz7P76Oy0BBuYRA5F2saxVTF9+7x8ET6JGPS9rNCbC/4+5fIKa3
         kITeyHx2yVyh+Lym5MmbtPETUHR34ie5qA7o3HRcypXZDzdsLcva0Q7emNsMtP0tAQdW
         yEYxH758rSb1Rj0kLOEAl3xlwA2WgW2lp5xGnZOeG1uPkwjX+ejyAgH6bOakyr6/6/3z
         MFOiSUgXnIMmsarwEmV8H7GthW6tunz7DcWy0KDnrIAc3LEG0IV6mQTr76JtI3H71+zw
         XSXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+xs8xEvecIN+pidhw5Y71rlRjZmb8fJOnZhp8o/DsSw=;
        b=C/E0kCMtXyWOsYTyxQL0Da4RETHvrL0likwHfSerr5kzU2QA/yHj8HQ6txUqN32xnb
         XiiVCXDJFSLgQ+eOz+SsoraWU18OUPeAfQq9AAncUawfam2BFXCW9bbJTN/17GFrln40
         s1qskpzlhXVzzUVjLRTegj8AOtQLzNBJbEJRW78JJ90Fo7NupGePw1bJjFpDD1iKpWjw
         bXf4KkGvVEmXU5y8VXpBFtjiiIpP7fnHUZ27NpZWw440CP07K6UZ1VpjDk3uhiGDDSk7
         CwCgfntxQR9SyI2TCvSWjOJCJpoIir/dXBhOrYmj1WXtZ/uJFySZKcW7qu29dhBgr7C9
         Pb+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LZajKbx8;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u20si2398864plq.421.2019.06.14.06.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:47:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LZajKbx8;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=+xs8xEvecIN+pidhw5Y71rlRjZmb8fJOnZhp8o/DsSw=; b=LZajKbx8vMWmoPyPihl3W8b1II
	oarEXVrrz2rxvZ0BgXTxaFSJ89DHAoMwNs46qftGPIs2iOcmI3PGUZe+ESDrKJqwk8Pn/9InuTjbe
	w/TkgWs39UEZl5gAqGPQNkS8QJr9eK5xRj4GSD3z1xgEem0WZvNMx/y06DWCWoiPPtMn6DV1KJtT4
	3dephzfXQQJVrhS8KA9VAcX9i7Lqdp6j+6fd+Du7mG+QFzmKyVufezvRPWVqUb7kH/R5PAyOXYi6v
	YOEZa1MgatXouQX+rfRB0aOlbZAvy1un6+StmE3Bzk1C+2JjRxYHzmpazpOIF5cCv5pJpncKedcmm
	mul+NSrA==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYQ-0004jF-5L; Fri, 14 Jun 2019 13:47:42 +0000
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
Subject: [PATCH 03/16] drm/i915: stop using drm_pci_alloc
Date: Fri, 14 Jun 2019 15:47:13 +0200
Message-Id: <20190614134726.3827-4-hch@lst.de>
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

Remove usage of the legacy drm PCI DMA wrappers, and with that the
incorrect usage cocktail of __GFP_COMP, virt_to_page on DMA allocation
and SetPageReserved.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/i915/i915_gem.c        | 30 +++++++++++++-------------
 drivers/gpu/drm/i915/i915_gem_object.h |  3 ++-
 drivers/gpu/drm/i915/intel_display.c   |  2 +-
 3 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index ad01c92aaf74..8f2053c91aff 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -228,7 +228,6 @@ i915_gem_get_aperture_ioctl(struct drm_device *dev, void *data,
 static int i915_gem_object_get_pages_phys(struct drm_i915_gem_object *obj)
 {
 	struct address_space *mapping = obj->base.filp->f_mapping;
-	drm_dma_handle_t *phys;
 	struct sg_table *st;
 	struct scatterlist *sg;
 	char *vaddr;
@@ -242,13 +241,13 @@ static int i915_gem_object_get_pages_phys(struct drm_i915_gem_object *obj)
 	 * to handle all possible callers, and given typical object sizes,
 	 * the alignment of the buddy allocation will naturally match.
 	 */
-	phys = drm_pci_alloc(obj->base.dev,
-			     roundup_pow_of_two(obj->base.size),
-			     roundup_pow_of_two(obj->base.size));
-	if (!phys)
+	obj->phys_vaddr = dma_alloc_coherent(&obj->base.dev->pdev->dev,
+			roundup_pow_of_two(obj->base.size),
+			&obj->phys_handle, GFP_KERNEL);
+	if (!obj->phys_vaddr)
 		return -ENOMEM;
 
-	vaddr = phys->vaddr;
+	vaddr = obj->phys_vaddr;
 	for (i = 0; i < obj->base.size / PAGE_SIZE; i++) {
 		struct page *page;
 		char *src;
@@ -286,18 +285,17 @@ static int i915_gem_object_get_pages_phys(struct drm_i915_gem_object *obj)
 	sg->offset = 0;
 	sg->length = obj->base.size;
 
-	sg_dma_address(sg) = phys->busaddr;
+	sg_dma_address(sg) = obj->phys_handle;
 	sg_dma_len(sg) = obj->base.size;
 
-	obj->phys_handle = phys;
-
 	__i915_gem_object_set_pages(obj, st, sg->length);
 
 	return 0;
 
 err_phys:
-	drm_pci_free(obj->base.dev, phys);
-
+	dma_free_coherent(&obj->base.dev->pdev->dev,
+			roundup_pow_of_two(obj->base.size), obj->phys_vaddr,
+			obj->phys_handle);
 	return err;
 }
 
@@ -335,7 +333,7 @@ i915_gem_object_put_pages_phys(struct drm_i915_gem_object *obj,
 
 	if (obj->mm.dirty) {
 		struct address_space *mapping = obj->base.filp->f_mapping;
-		char *vaddr = obj->phys_handle->vaddr;
+		char *vaddr = obj->phys_vaddr;
 		int i;
 
 		for (i = 0; i < obj->base.size / PAGE_SIZE; i++) {
@@ -363,7 +361,9 @@ i915_gem_object_put_pages_phys(struct drm_i915_gem_object *obj,
 	sg_free_table(pages);
 	kfree(pages);
 
-	drm_pci_free(obj->base.dev, obj->phys_handle);
+	dma_free_coherent(&obj->base.dev->pdev->dev,
+			roundup_pow_of_two(obj->base.size), obj->phys_vaddr,
+			obj->phys_handle);
 }
 
 static void
@@ -603,7 +603,7 @@ i915_gem_phys_pwrite(struct drm_i915_gem_object *obj,
 		     struct drm_i915_gem_pwrite *args,
 		     struct drm_file *file)
 {
-	void *vaddr = obj->phys_handle->vaddr + args->offset;
+	void *vaddr = obj->phys_vaddr + args->offset;
 	char __user *user_data = u64_to_user_ptr(args->data_ptr);
 
 	/* We manually control the domain here and pretend that it
@@ -1431,7 +1431,7 @@ i915_gem_pwrite_ioctl(struct drm_device *dev, void *data,
 		ret = i915_gem_gtt_pwrite_fast(obj, args);
 
 	if (ret == -EFAULT || ret == -ENOSPC) {
-		if (obj->phys_handle)
+		if (obj->phys_vaddr)
 			ret = i915_gem_phys_pwrite(obj, args, file);
 		else
 			ret = i915_gem_shmem_pwrite(obj, args);
diff --git a/drivers/gpu/drm/i915/i915_gem_object.h b/drivers/gpu/drm/i915/i915_gem_object.h
index ca93a40c0c87..14bd2d61d0f6 100644
--- a/drivers/gpu/drm/i915/i915_gem_object.h
+++ b/drivers/gpu/drm/i915/i915_gem_object.h
@@ -290,7 +290,8 @@ struct drm_i915_gem_object {
 	};
 
 	/** for phys allocated objects */
-	struct drm_dma_handle *phys_handle;
+	dma_addr_t phys_handle;
+	void *phys_vaddr;
 
 	struct reservation_object __builtin_resv;
 };
diff --git a/drivers/gpu/drm/i915/intel_display.c b/drivers/gpu/drm/i915/intel_display.c
index 5098228f1302..4f8b368ac4e2 100644
--- a/drivers/gpu/drm/i915/intel_display.c
+++ b/drivers/gpu/drm/i915/intel_display.c
@@ -10066,7 +10066,7 @@ static u32 intel_cursor_base(const struct intel_plane_state *plane_state)
 	u32 base;
 
 	if (INTEL_INFO(dev_priv)->display.cursor_needs_physical)
-		base = obj->phys_handle->busaddr;
+		base = obj->phys_handle;
 	else
 		base = intel_plane_ggtt_offset(plane_state);
 
-- 
2.20.1

