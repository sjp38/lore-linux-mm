Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A58B3C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B80C21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="trz7K9US"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B80C21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAC1A6B027C; Thu, 13 Jun 2019 05:44:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A348D6B027D; Thu, 13 Jun 2019 05:44:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 889ED6B027E; Thu, 13 Jun 2019 05:44:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1B86B027C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y7so14120123pfy.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0sAfzDlcAsndHKBt75dqqx/GnOCOQqtRdathOjahJzQ=;
        b=KNzGQ9G2NyXWF4SCd1zGB7Wazh7FsU9OrfkEPz6fI6e9gjAtDRV2FJImYYz3UFz9vN
         6X1CaSosjpsmIr+FwsgJCwQmDI5tM2/dCXh0Cb93cOGaLIgmSlnNlxF20aUOvAtk0wlo
         hk9xbXOT/lHS94/XT3cmt2qS4kdvDWLwzr2oz7jEpSLBurRhxxTymJdxtuliRioZfKCa
         Jc66n2Ypw7Ey5u5Iq/Hobt+/MIiYc4x3p9h+NoaVwhwELSH6wQZxU+FTNwvPCchawfBr
         NKSDjyZRTIopaTLW4JltmYbtwVRo0fqH9+uecpRyGVFruS8ECqjuCRhtRB3JXfT6muvA
         GHww==
X-Gm-Message-State: APjAAAULn4ZGOK3nD25MLrosYAakc0DtS3A94kBagjyyPtLXwrGfUhU1
	2LFshHX0fBq80oT3gq5SJzID4RoWTuBecvh4CBXgmhEcrao7b7gDeK3NTUptaNzUNpt1E7QSpEJ
	TMVouKJtKnDHFPLDlsawXT+jApvBJ2hqEaXKGF5hUyxER7+d0ftcMQL3Pm3Kpn2s=
X-Received: by 2002:a63:511b:: with SMTP id f27mr13939592pgb.135.1560419076793;
        Thu, 13 Jun 2019 02:44:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8M4iDY5OrEQQ/BfQmHJgcItcCfq66V5MfvlozA5elWk7LCUxwpYBbivauDkOWO0wyw+Jv
X-Received: by 2002:a63:511b:: with SMTP id f27mr13939505pgb.135.1560419075904;
        Thu, 13 Jun 2019 02:44:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419075; cv=none;
        d=google.com; s=arc-20160816;
        b=uD5PKV9egpRsx4ZBvTQavKXTBZOJpwPEV4YehHYqXAFUMkj17j7ELSef1pkFkowdKv
         uQaFiiwIREFxYsiZTXj47ElzWa9LZrnytp+fGcGjyic1C4eWe0Af1LhcXCRzyS+igTVG
         cxMZId3fjviiRcVL5OgfgF8cCoRXi46doUn0upHlJfQmCJbaP7GFqwTeFNWCbANYpeTP
         /Vv85zRMyKlVqVonht9tIE2Jv4Bk5sqpkz3yD6W/YprVMoqB8oSKEv1YoBbqQnQk5wlD
         cw8y6IMSTpXUQdfHXYwvdpVUbCt4kMpoqgcxT1pO8OzQ+GwVakwPOVDDyEOP3gcAO6fK
         lRtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0sAfzDlcAsndHKBt75dqqx/GnOCOQqtRdathOjahJzQ=;
        b=Z1fLgYKcCcX8vJtzIY6DCn8IEWI8B5esZQP2DIr0d4mLe1ZhrHDArDdC034mbE2asf
         Zaf8/CXdMXup+icVLbCS5xx3VPZQTGYOE21DYN3x3BW6Gzc1KdbWsDIo98MwUlBjNB8t
         RczLLKvnJ0Lp4PoGCg6Oo7OyQ6FXjJUKpqKMpr1TzytKWjw4In1CpJMSUn5r/otqD4b+
         pSo9oxieaWUDV2V1H0UmchC6GUgVECAKrEN2VfxikRX5HNWwxocBNMmGj9T8awZSS2Xm
         g0RLv4+sFG0qNUNkdeUaVoDL2gF6jtTAxhSxO2C3xAhELCnaisnTrFOZq44y9SwYPBD0
         SBXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=trz7K9US;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t3si2629246pgq.254.2019.06.13.02.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=trz7K9US;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=0sAfzDlcAsndHKBt75dqqx/GnOCOQqtRdathOjahJzQ=; b=trz7K9USBFzK+xAnepin47AmRr
	Ru/Ufe0ArOAav00lGoPPzRUVxrswp05DRpD2d5fXaeZItnlHIGrtF1O1z/B5eK/v1ypkuEUV33AoE
	O6sWXD/9uMVmrJLXNRSSRwxNiWV3okj38PS6HOorCIE1095zMfIxNPliWKgHj+KFNGQYjRJfvAAE9
	OZPPi7DMhfjs+Ay9FbxkmMkIi0kMa6qSNkzN8TL3yorsUR6y30VoiV0rQhnhlXUczuR6wnoc3Tr3D
	5CrUdFq3rR6UxwQZviB1fSzfyE69t0fvrojVXmSEKwbbynKreccgHDzaxSTGmzkzt23o/mQnE0h+e
	YEeclslA==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMHY-0001yQ-Rm; Thu, 13 Jun 2019 09:44:33 +0000
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
Subject: [PATCH 22/22] mm: don't select MIGRATE_VMA_HELPER from HMM_MIRROR
Date: Thu, 13 Jun 2019 11:43:25 +0200
Message-Id: <20190613094326.24093-23-hch@lst.de>
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

The migrate_vma helper is only used by noveau to migrate device private
pages around.  Other HMM_MIRROR users like amdgpu or infiniband don't
need it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/Kconfig | 1 +
 mm/Kconfig                      | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
index 66c839d8e9d1..96b9814e6d06 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -88,6 +88,7 @@ config DRM_NOUVEAU_SVM
 	depends on DRM_NOUVEAU
 	depends on HMM_MIRROR
 	depends on STAGING
+	select MIGRATE_VMA_HELPER
 	default n
 	help
 	  Say Y here if you want to enable experimental support for
diff --git a/mm/Kconfig b/mm/Kconfig
index 73676cb4693f..eca88679b624 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -679,7 +679,6 @@ config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
 	depends on MMU
 	select MMU_NOTIFIER
-	select MIGRATE_VMA_HELPER
 	help
 	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
 	  process into a device page table. Here, mirror means "keep synchronized".
-- 
2.20.1

