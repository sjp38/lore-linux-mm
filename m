Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E33AC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0447720818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VqvOXxoz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0447720818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60BC36B026E; Tue,  6 Aug 2019 12:06:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56EDC6B026F; Tue,  6 Aug 2019 12:06:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E78B6B0270; Tue,  6 Aug 2019 12:06:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 067046B026E
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j22so56134295pfe.11
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rJswjijmkpcl3+zNTfEscrNrHCmk4eoJ1fNyJa4rycs=;
        b=r4FL/HdtQMuItoUH0Y6qntq0EEfUlv2hVgap6d1uYFHB4NmdQObwKybrBLmbWFzCdG
         WkcBGtHZKta8lC0iGu7a1n5aqHH0xA9EhQk5z0oQB6DnB3xIW5bAoMcgqqKK/dKhruBU
         GJWx9o7G2ngCHTxzpBBORQ5CoZc1QgbxIqTuej7AOi5kBco8abUD3+Ye1qxxMdWWRmzJ
         uV56hrwPS0PlnyqlHp0vZg3x0BoI8dNYtyUuFTtHV18Tfwu5KpIX/FCeVO87PrqF1e98
         AXp/4BA2PCKd2SX//CmSSEO2FPG4sXiyo1hZNrM882+pXxVzQzYUShfKnD7HFGLiklAm
         AIOA==
X-Gm-Message-State: APjAAAVMBxuLfOeBzmRO6xHRBenrO2k8OqyEMOblGwyF4kR7KR4YhtCa
	BkcHcXw+Mh5yFnoDi8KJ6zWMc5x/xEXupL2oVs+EQldvY6fqoE3ld+480D0pVxfiVfktgpfwIj7
	tEOb3ZcVd09ItZuDXhiWLuTf6Md3rfkhs55whmXV2D/7UyO38W5DZP2G3MYdi5qw=
X-Received: by 2002:a17:90a:350c:: with SMTP id q12mr4020267pjb.46.1565107599664;
        Tue, 06 Aug 2019 09:06:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7xZyD30mwrFvZYfTptTPKJrQKJpdbd9cPVpYDDQJ7z8KYDTk9kC8zdCHW7O9qUalye7Jy
X-Received: by 2002:a17:90a:350c:: with SMTP id q12mr4020164pjb.46.1565107598284;
        Tue, 06 Aug 2019 09:06:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107598; cv=none;
        d=google.com; s=arc-20160816;
        b=Sw3KZAPj7urc2f40Mj03Jtwf5lJYJl/11BX4CL93HgtV2tYVEI1PoxtSQVi7NvZMB4
         5865pnDYsr/KhZLxTgHTTeDpUNGOt4neqZsxa0T8W7mCqgS/4t6XDGlVZsT/jxFS7zGD
         xwAtvJSKC5Mlunr5z+arU+YbMirAdq8G31WMaxkzhnTCEjF9nQ0TcdSBUhRacG3//qml
         zrLVAOKq53liP1eZLTmNgssVDhKsBDYM8CkaOQOTHkZ4A6lntuTBeU0+7nZFIZmtUSG1
         8i6lHcqSfhbRWGUbJnN1JWhGf8qaKVuNNvdSiwqgDukxMoW8GCI4ZqZnYaftWjOIvfae
         xtBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rJswjijmkpcl3+zNTfEscrNrHCmk4eoJ1fNyJa4rycs=;
        b=Jpv8GmryWt8+Rg3sAz5ONyjG3fl+DFf0uQ26MDsth8Yc+c2ViciAy1z0H1o+2owoj8
         GUCC6a4VA0I67Q/r8bBZqJm0t+JknxL1k9TQfLhw19vdeANcoM4LSoYpfNcD3+PgbMVr
         qzeV7l1lvGDjMTZYsUib9FICsKVLjubMFks5QVl44YCxj6JtwYQI7ZZFN2BmROlSx9nF
         ApwOpih2BMcz9QORwCCX5wtjO32fnhkkmssEnWHlOVsI/euK0mJkP3PpN5OxKNYErPtj
         Q68PFCzHcVHAKyPEZ1HKp7irMRHDnadIfhdqwzvBezsJEtx+Ld/Oe2z7z1jbZTtCG5nm
         1gbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VqvOXxoz;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a63si43783399pla.348.2019.08.06.09.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VqvOXxoz;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=rJswjijmkpcl3+zNTfEscrNrHCmk4eoJ1fNyJa4rycs=; b=VqvOXxozSwzI7eFEf4UYNUkBtj
	zcyVitAb2IBMSN93hEBkvpOtxEY7UNDy7CxQ9GwlywMhcQG+yvk1GnvJ95BMTub6P4sOUn/zZ7DL2
	6OGLjDqkUdd0yERlijxCp48M1Sb2SETesO8sl08Tqp3CLKkJt0om/9x2rBHbcNm/RwLcHbbrEg0HO
	OSKL0hAunEvUeoKw2CxinuU3cCbdfwZyg//2UUmstD8wxTIzDYuvmfwcVdjkH+omes3LrNSHjicgO
	WDD51ILtI0PHtJZF9sKmSRarRmER/JhlTblhSLHMs+d7uLKufLh1X/vU4bfr/hI4BkMtdZN+ok155
	BwkIXDrg==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yt-0000fO-41; Tue, 06 Aug 2019 16:06:35 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 15/15] amdgpu: remove CONFIG_DRM_AMDGPU_USERPTR
Date: Tue,  6 Aug 2019 19:05:53 +0300
Message-Id: <20190806160554.14046-16-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806160554.14046-1-hch@lst.de>
References: <20190806160554.14046-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The option is just used to select HMM mirror support and has a very
confusing help text.  Just pull in the HMM mirror code by default
instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/Kconfig                 |  2 ++
 drivers/gpu/drm/amd/amdgpu/Kconfig      | 10 ----------
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |  6 ------
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h | 12 ------------
 4 files changed, 2 insertions(+), 28 deletions(-)

diff --git a/drivers/gpu/drm/Kconfig b/drivers/gpu/drm/Kconfig
index 1d80222587ad..319c1da2e74e 100644
--- a/drivers/gpu/drm/Kconfig
+++ b/drivers/gpu/drm/Kconfig
@@ -226,9 +226,11 @@ config DRM_AMDGPU
 	select DRM_SCHED
         select DRM_TTM
 	select POWER_SUPPLY
+	select HMM_MIRROR
 	select HWMON
 	select BACKLIGHT_CLASS_DEVICE
 	select INTERVAL_TREE
+	select MMU_NOTIFIER
 	select CHASH
 	help
 	  Choose this option if you have a recent AMD Radeon graphics card.
diff --git a/drivers/gpu/drm/amd/amdgpu/Kconfig b/drivers/gpu/drm/amd/amdgpu/Kconfig
index 2e98c016cb47..c5c963164f5e 100644
--- a/drivers/gpu/drm/amd/amdgpu/Kconfig
+++ b/drivers/gpu/drm/amd/amdgpu/Kconfig
@@ -24,16 +24,6 @@ config DRM_AMDGPU_CIK
 
 	  radeon.cik_support=0 amdgpu.cik_support=1
 
-config DRM_AMDGPU_USERPTR
-	bool "Always enable userptr write support"
-	depends on DRM_AMDGPU
-	depends on MMU
-	select HMM_MIRROR
-	select MMU_NOTIFIER
-	help
-	  This option selects CONFIG_HMM and CONFIG_HMM_MIRROR if it
-	  isn't already selected to enabled full userptr support.
-
 config DRM_AMDGPU_GART_DEBUGFS
 	bool "Allow GART access through debugfs"
 	depends on DRM_AMDGPU
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 8bf79288c4e2..00b74adbd790 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -751,9 +751,7 @@ struct amdgpu_ttm_tt {
 	uint64_t		userptr;
 	struct task_struct	*usertask;
 	uint32_t		userflags;
-#if IS_ENABLED(CONFIG_DRM_AMDGPU_USERPTR)
 	struct hmm_range	*range;
-#endif
 };
 
 /**
@@ -763,7 +761,6 @@ struct amdgpu_ttm_tt {
  * Calling function must call amdgpu_ttm_tt_userptr_range_done() once and only
  * once afterwards to stop HMM tracking
  */
-#if IS_ENABLED(CONFIG_DRM_AMDGPU_USERPTR)
 
 #define MAX_RETRY_HMM_RANGE_FAULT	16
 
@@ -892,7 +889,6 @@ bool amdgpu_ttm_tt_get_user_pages_done(struct ttm_tt *ttm)
 
 	return r;
 }
-#endif
 
 /**
  * amdgpu_ttm_tt_set_user_pages - Copy pages in, putting old pages as necessary.
@@ -970,12 +966,10 @@ static void amdgpu_ttm_tt_unpin_userptr(struct ttm_tt *ttm)
 
 	sg_free_table(ttm->sg);
 
-#if IS_ENABLED(CONFIG_DRM_AMDGPU_USERPTR)
 	if (gtt->range &&
 	    ttm->pages[0] == hmm_device_entry_to_page(gtt->range,
 						      gtt->range->pfns[0]))
 		WARN_ONCE(1, "Missing get_user_page_done\n");
-#endif
 }
 
 int amdgpu_ttm_gart_bind(struct amdgpu_device *adev,
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
index caa76c693700..406b1c5e6dd4 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
@@ -101,20 +101,8 @@ int amdgpu_mmap(struct file *filp, struct vm_area_struct *vma);
 int amdgpu_ttm_alloc_gart(struct ttm_buffer_object *bo);
 int amdgpu_ttm_recover_gart(struct ttm_buffer_object *tbo);
 
-#if IS_ENABLED(CONFIG_DRM_AMDGPU_USERPTR)
 int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo, struct page **pages);
 bool amdgpu_ttm_tt_get_user_pages_done(struct ttm_tt *ttm);
-#else
-static inline int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo,
-					       struct page **pages)
-{
-	return -EPERM;
-}
-static inline bool amdgpu_ttm_tt_get_user_pages_done(struct ttm_tt *ttm)
-{
-	return false;
-}
-#endif
 
 void amdgpu_ttm_tt_set_user_pages(struct ttm_tt *ttm, struct page **pages);
 int amdgpu_ttm_tt_set_userptr(struct ttm_tt *ttm, uint64_t addr,
-- 
2.20.1

