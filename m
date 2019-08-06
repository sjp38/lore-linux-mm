Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E0E2C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7BD620679
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RzYHdp4m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7BD620679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B03F6B026D; Tue,  6 Aug 2019 12:06:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23C3B6B026E; Tue,  6 Aug 2019 12:06:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08A9D6B026F; Tue,  6 Aug 2019 12:06:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C36326B026D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:36 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z35so8828974pgk.10
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AGGvPGg8AA1Gw6ylv1raBDjNXF6ccyWYsPpDnZmLmBg=;
        b=IXKsZ69+v4KcZzS0vJExSFGVjUUz1yOU7qgaEYz9OtEh7jh4QZRnLPOQvyzl7i4djr
         GjF4YmNXrqHXUZKZwajeZ+jG4apkGimh8eyiMzpcb5K4v4NFVPvz7/MNUTlOaiTKJZBP
         Rw50iiwHwtmFKPWtVPubOCbIa/bFiyCC090RuvhIqr9XTELltcXMjGr/x15ChOMjvadu
         h1MOqTxXVSWWewEPFZuAxrjKh1InJ0OmG8Btm+CpAd3PxA6Q/YsdLzCr9fL54MLTE0i/
         Umh7KLy+O7ZEK6/ss7tg5JtP33ufk+fN408AI6W3I9sWGwpAzmXpjI4FoAz+PiIMUi60
         OE/Q==
X-Gm-Message-State: APjAAAVt8b2NEcpYObshKaNBpYYJpxfsteJVkYRqeSa4CCMEB/3yRcWy
	1mtMuLlORU6kzVMld3yLQBet/wKac2Myrf7l7OhPf0fv5+Sydp+4FxbrUiINc51yxNCiSIEQIEA
	oqYhrjrEaywF0knE+CzKE1X49NjhzGPmQDlX9YEjchseezm5aFzjAF9GfhKuQJao=
X-Received: by 2002:a65:57ca:: with SMTP id q10mr3829217pgr.52.1565107596333;
        Tue, 06 Aug 2019 09:06:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQkhY206EW7pOVKOtScbVplEwridPo3VuCzddzZTVQWFxlixev1coAomBHwmoYQuazUJgF
X-Received: by 2002:a65:57ca:: with SMTP id q10mr3829145pgr.52.1565107595389;
        Tue, 06 Aug 2019 09:06:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107595; cv=none;
        d=google.com; s=arc-20160816;
        b=zNURGfrJcWwMeFS2Te3EOcJJz7GQi/2FVFe8BoCvLF3TNMKbjo4CrgXvfU3Uh6bXxc
         bv11PRt7SxHfdmBPGkYqp5NbH+b9FAcJNIks/QwIO/0evr5HCM3aDP9dpH46EKDFIe8i
         h3IW+kOhhOB/29/cNYeCqLyAmVsHxYPInBH2sUT7PI8X5SmWnZNnfGTsP6gOYTvYUbEW
         z4CzahUOObjV+rEWloQSW0AuJ6gbOJiMf0G+0+rsEKcd7bSAn6E3o5BUxVIqiXy8kDYv
         gH9/AkccZrXfrC0Bwjz+sXQnPvxDTpQo/aT1WjSmb0cU+dTrD9VZYnKrsXJjzEVr6Fx8
         XYAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AGGvPGg8AA1Gw6ylv1raBDjNXF6ccyWYsPpDnZmLmBg=;
        b=L/KSr9tLFAxZf9fi4pduHft6v9eXlCE9iQVwrpVy0bXJeiom2jBoDZ7kHmeD0O78B+
         XYSKi1s8WmICGOxWR3jwwElDyHh4nfmPBG7rA395TuijMqO9fbbyIp9l9U/mOG1PYTyS
         FfS+Nt/OGkLNb54VdvUnlWu6RBWH5mAxaqFGbgweraD8HA8LjmQGo596n1Jc+7tIWBLe
         LQ8wuHS4orWNsQBo1cYOxA2KmqsST3A9LsoCHmvkNQt0vdUgH2NC96fzP8NXgd5YIWlu
         X+9eHxfQTIfY18371H+79PJ0ZvfbErGEFMlH/QUMPXQfXJMewaADJ/rD5fmVVdWO/vuR
         tzYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RzYHdp4m;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t31si8310105plb.309.2019.08.06.09.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RzYHdp4m;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=AGGvPGg8AA1Gw6ylv1raBDjNXF6ccyWYsPpDnZmLmBg=; b=RzYHdp4mJtW15Li7cWdiL7Rv01
	hFHEseFq+n0UFJMU+3w0w0dcwm6oTnyxs0LPJqTeUb/aik4SEyGDvWEb+rGvDp6r84fKCRpR8iku+
	LvpAQVKD7G9QKkzdJ/DeuZbZbTKro358y+zjuzVRUmFj6CfDmyP5rU7cFg+Mei2TOZGLqki/rhkRI
	+TaF7MWaORAz4mLE/jjH44uvJ1K8vxtIQOYU/+SL0CT+znouLR7X0cSZDFf8qWgYeOqRr0qwLahZj
	AwGNkm8JajYbsE5/lptaYXs7oJbj9ULssrgVQGlVhokMiDkdGrjv85x55+c8YH7Bg4a1zNcPtjDA3
	0XcoXJNg==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yq-0000ee-I1; Tue, 06 Aug 2019 16:06:32 +0000
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
Subject: [PATCH 14/15] mm: make HMM_MIRROR an implicit option
Date: Tue,  6 Aug 2019 19:05:52 +0300
Message-Id: <20190806160554.14046-15-hch@lst.de>
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

Make HMM_MIRROR an option that is selected by drivers wanting to use it
instead of a user visible option as it is just a low-level
implementation detail.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/amd/amdgpu/Kconfig |  4 +++-
 drivers/gpu/drm/nouveau/Kconfig    |  4 +++-
 mm/Kconfig                         | 14 ++++++--------
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/Kconfig b/drivers/gpu/drm/amd/amdgpu/Kconfig
index f6e5c0282fc1..2e98c016cb47 100644
--- a/drivers/gpu/drm/amd/amdgpu/Kconfig
+++ b/drivers/gpu/drm/amd/amdgpu/Kconfig
@@ -27,7 +27,9 @@ config DRM_AMDGPU_CIK
 config DRM_AMDGPU_USERPTR
 	bool "Always enable userptr write support"
 	depends on DRM_AMDGPU
-	depends on HMM_MIRROR
+	depends on MMU
+	select HMM_MIRROR
+	select MMU_NOTIFIER
 	help
 	  This option selects CONFIG_HMM and CONFIG_HMM_MIRROR if it
 	  isn't already selected to enabled full userptr support.
diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
index 96b9814e6d06..df4352c279ba 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -86,9 +86,11 @@ config DRM_NOUVEAU_SVM
 	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
 	depends on DEVICE_PRIVATE
 	depends on DRM_NOUVEAU
-	depends on HMM_MIRROR
+	depends on MMU
 	depends on STAGING
+	select HMM_MIRROR
 	select MIGRATE_VMA_HELPER
+	select MMU_NOTIFIER
 	default n
 	help
 	  Say Y here if you want to enable experimental support for
diff --git a/mm/Kconfig b/mm/Kconfig
index b18782be969c..563436dc1f24 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -675,16 +675,14 @@ config MIGRATE_VMA_HELPER
 config DEV_PAGEMAP_OPS
 	bool
 
+#
+# Helpers to mirror range of the CPU page tables of a process into device page
+# tables.
+#
 config HMM_MIRROR
-	bool "HMM mirror CPU page table into a device page table"
+	bool
 	depends on MMU
-	select MMU_NOTIFIER
-	help
-	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
-	  process into a device page table. Here, mirror means "keep synchronized".
-	  Prerequisites: the device must provide the ability to write-protect its
-	  page tables (at PAGE_SIZE granularity), and must be able to recover from
-	  the resulting potential page faults.
+	depends on MMU_NOTIFIER
 
 config DEVICE_PRIVATE
 	bool "Unaddressable device memory (GPU memory, ...)"
-- 
2.20.1

