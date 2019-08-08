Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26671C41514
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5F682184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ObdDVS93"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5F682184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EABB6B0008; Thu,  8 Aug 2019 11:34:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 799E76B000E; Thu,  8 Aug 2019 11:34:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 689B66B0010; Thu,  8 Aug 2019 11:34:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4DA6B0008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:34:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s21so55616359plr.2
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:34:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x7ybZjKxR0l979mP5Y8wGTwoC7YG2fijyFoop9SwmvY=;
        b=YX6Dw8nUn5dr6V3yuyDl3NX5VNVcsTaV2daxbu2v5efWdnTpEZfdrZBqbXqmPNW4on
         X0CAlBeOFGUFJrzEQhHnlZqHI1tHkGXlRPuvQk6XHPwPSQff+137/skUvxBEAShLwH8M
         3fblSvWxsggsDFRWgSVET/7BRXC8nV1A1aBRVcxcG4FdiGVNA5ynlaeaJ8BfqDfYKFbx
         Hbx/N2hi/P7MDz1G3KtIxLtcch/WBawOIaqQbOHM7L33Uu2sY9Z2MduvnZ8+ZVoiMZGl
         n2ln/OMC6B4W5rhKMTSfHDOhD9ey9U2K27b4o0juwuhiiBiWb/dBq5x6YPjNprIQ5tQD
         lu0w==
X-Gm-Message-State: APjAAAUdJvKZwAaTWayVRVQUcYJ7FyxUgQ0+IZDK4oWv7L+lGTnOnak4
	nANIe9NiE8lCSxQVve/ozpvgBCEZkGhSmwtxiimR0ePlXMzHICvhUtallwyCWU50x4KLwkOGWQ2
	DQ7Y45eT4uaki0UIqucoNSyn8RTAsx9aY0QAzfE+7RSQFWgW6bFhXjJkss7+9274=
X-Received: by 2002:aa7:9254:: with SMTP id 20mr16669552pfp.212.1565278461860;
        Thu, 08 Aug 2019 08:34:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuQ9+rxYnJRxcHLtwgrwxDkmVMTM7/8Yp2OoG5MFaktWxcQY757DmIVVSOXEdnjPRJFmSH
X-Received: by 2002:aa7:9254:: with SMTP id 20mr16669441pfp.212.1565278460986;
        Thu, 08 Aug 2019 08:34:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278460; cv=none;
        d=google.com; s=arc-20160816;
        b=A2WoKp3zjzHFh8owRlBz3I71wJO/b290ST2VTaic070eSYW+GwJsM3zmvS6JhIMIzQ
         MiwsLJ9IVCBYd3AwKS7tElPpw5gVKvlXq7L4S2EAqG+3TWl+c/44AmmRp3hsfraGxrw/
         ImZpu9RfyJn/6gOh2kciOibFFOnj6Z9gJjG/+Qr4QoCI2Ad4aHYzoDYEBlxD2ZZ8XplR
         PWNH/Hbr7/5t42ymf8yB/SQSDoVb0wUIqMWE8MPN5MCfR0cToc8m71YUlRd+EOxT6Syu
         +6guKkuUjl8c/dS12r6RcENxwzx+iPUgYwCoioFIZ7GwkHrg23lTiE/h1x2CQ2PKVedn
         F1Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=x7ybZjKxR0l979mP5Y8wGTwoC7YG2fijyFoop9SwmvY=;
        b=wJlfDV1e+v8lsA1iYxc8fhc3T2vVgmIZZqiIxpp7IJEF2vlLxcTrKQI1Kfy6ZOUnqW
         gkoccPr9Fl3zmqSOrzdVKrceFlZXhFHajd8CBX6yBg+4BdZu9BgEQsajzQPuNIkqwnFO
         uIZhryM57FddlWaLdVgKdG1VipEXTErbjDk0U/ejZ0jAcim1CM1TbZAX6wFhGn8uUhoN
         qLtw3PLx1xuEL8H+69li4hrO1vIlkltJPDcVv8UXbS78jVRR1vPTFUvnhxRrVHWYyyOW
         9FP7eB9X8r1bBdm6yzFnzFWRF8V6UzmFfff7+UyJwUQcMASOJQ16z8X7dF8/60y13o/+
         DZfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ObdDVS93;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 124si3301669pgd.142.2019.08.08.08.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:34:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ObdDVS93;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=x7ybZjKxR0l979mP5Y8wGTwoC7YG2fijyFoop9SwmvY=; b=ObdDVS93ijfBipfxkruL3vThKy
	YnxggEEQI8ykUgMl/26hlGDBk03JnB6FP4dzUD3ApPS0lnql9HLqZCpje4BTnbrWfBVLGMaBEGA88
	HLJh/R1WQa+bPh3MUsY5w3uZyfozroQFpaIDNKVac4kvUC7E5rvD4YDg/FDwsMgmL3A7rcVOTbz4a
	PBITSwWfVqiOZKRqYZBSushqapyrlBvxP+Zt5FyXgyWKIumCpl+d+vdpV7/IlOw4UGYnjaLGu3NdQ
	50hJ5hO+d03U0TYzdfPi67eqLNQRKRsf7IxW337l5Mtkf6OmcyfV0xL69jFYoi/G/mURABb4p5/So
	GgYtMfFw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkQg-0005DV-B3; Thu, 08 Aug 2019 15:34:16 +0000
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
Subject: [PATCH 5/9] nouveau: remove a few function stubs
Date: Thu,  8 Aug 2019 18:33:42 +0300
Message-Id: <20190808153346.9061-6-hch@lst.de>
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

nouveau_dmem_migrate_vma and nouveau_dmem_convert_pfn are only called
when CONFIG_DRM_NOUVEAU_SVM is enabled, so there is no need to provide
!CONFIG_DRM_NOUVEAU_SVM stubs for them.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.h | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.h b/drivers/gpu/drm/nouveau/nouveau_dmem.h
index 9d97d756fb7d..92394be5d649 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.h
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.h
@@ -45,16 +45,5 @@ static inline void nouveau_dmem_init(struct nouveau_drm *drm) {}
 static inline void nouveau_dmem_fini(struct nouveau_drm *drm) {}
 static inline void nouveau_dmem_suspend(struct nouveau_drm *drm) {}
 static inline void nouveau_dmem_resume(struct nouveau_drm *drm) {}
-
-static inline int nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
-					   struct vm_area_struct *vma,
-					   unsigned long start,
-					   unsigned long end)
-{
-	return 0;
-}
-
-static inline void nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
-					    struct hmm_range *range) {}
 #endif /* IS_ENABLED(CONFIG_DRM_NOUVEAU_SVM) */
 #endif
-- 
2.20.1

