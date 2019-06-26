Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D26EC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:29:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D630620663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:29:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KN1fXz1V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D630620663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1B778E0020; Wed, 26 Jun 2019 08:28:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D51F48E0005; Wed, 26 Jun 2019 08:28:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCB8D8E0020; Wed, 26 Jun 2019 08:28:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9E58E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:37 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d2so1352480pla.18
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZjBYUWyGZeQFbLdeL3I3vLQlcbJ5I4BbNFzVpFyfAyY=;
        b=LPzyeZDqBg4i4cno3qiOdFb3BMVTbMWu3lQLkjs8kKPqCe7yT0wcClSchhd5MaUSMr
         bDoDWFkPkccNKiwJn2OJs1Kg0MDqUHFqN1AtdvPOUyMsjoeXIIA3NpbkUgRbmBKbfvFN
         EffWFujHdLb1Qu51kW59Rft4cLaFCVxW48kmyOcqBuqGkjnGxPExlh/1F52X3gKT1Qp0
         BV8cUDsdfi9OCuebzff/Z1LcyFKdkg5p0NrsOrA8+DslobgWMGesoc2ozcTdH2nMVQoP
         jgDKOrhXwEe23jd2BCWTiSB/8OJoPdhGaLRiNqgjTumdIAaEpnYUduI+a5WjG/oOp+iK
         3A+A==
X-Gm-Message-State: APjAAAXJjsKBoTN4RF9UnFWhF5Gmte/Ar99nn4g3rG9YrBZUOh+hA0+H
	+JH/gf7RjtwTlzaphR54cbLE4HSv+C2ZqPx58ZV0f3J4YHpkfAcKI04CfJhmEf2rGUXs3K6r7HY
	AWH2tlr+pVwjh1eGnL0utKn+uA8PmGN4sKTw9rnRtXFaCXqWTS4exCmSrz+Y1wLE=
X-Received: by 2002:a17:902:296a:: with SMTP id g97mr5091585plb.115.1561552117186;
        Wed, 26 Jun 2019 05:28:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8rMzVKR3dLLC1/jw5GvNhGjSc3+g9nbh1jIMO0eRczeZpUkIJP4LIQBrKKAPQkYU46vTz
X-Received: by 2002:a17:902:296a:: with SMTP id g97mr5091532plb.115.1561552116486;
        Wed, 26 Jun 2019 05:28:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552116; cv=none;
        d=google.com; s=arc-20160816;
        b=BqBq+5yKuhhnRLgxpwjT6tM2iLOriwN1xZxLZhMde8c6bOFLhH48vQABg9IbuA5muI
         rQzjNG8zBgMhMy5aGBxQVw4M8xPQFc0rBL5OvTkmNw9YIseqgSxXgeKq3qQ+CMg3htsD
         jYXd76PMbKFA57ABNtWyCTuG+KXMiMh3CkgB5QInexxE1XJ2bVReI7pFdnSCc5Oyod2t
         YSVNuVgp0Ou0lvgYeTL96YGVIs9yHpEeZ4sPndk590z1mrQJ1hkwBPqWWEOCPFO+rmDz
         EbV++ykmiCHiQfPsI4TIWT17y5ZTxf6qBztx21+2FE4/pbAQLKV4+77pAJHG1tToGga0
         dymA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZjBYUWyGZeQFbLdeL3I3vLQlcbJ5I4BbNFzVpFyfAyY=;
        b=oFXc/qlDxkU2N9d9lpUhsFAkwijRGArGVXZwmGDCEN/WGacSpL3bDya5/DA2ZWWDCA
         MTgvZDBloOuRFGv6dM67doXf02uLth15mQXV2BUFrzdM+Q8xsoN7pVKo4qEO+WOsdgXn
         mGSFYlAqR7IC9dz1LIQsg3cTmqhxPh78/4hBRqrKmagXVeY/wrBSxZ/QUco8KHQOvqLn
         27daIu2jvoJ/M5NWi3/J5uzx3unvfWckTBd1Lz007SCBfETKCsGnAkxq/5j79N/LfQmb
         meMuSgvuR+0Kts97jXK9C8ng90sJNdcaBLTv4KRTVDOb3ClXFKx0nhTxycZZjbGglMt0
         dPYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KN1fXz1V;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o2si1163993pfg.136.2019.06.26.05.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KN1fXz1V;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ZjBYUWyGZeQFbLdeL3I3vLQlcbJ5I4BbNFzVpFyfAyY=; b=KN1fXz1VRCySW0ycRrfAX1GqWC
	nBzrlUj6EH8tEn5EKRnrhZ/clBQwfvfHZco8c9jjozD1fh/my91ln6undw3f0URs/bl+BIWm9b6hu
	GRC9l8p7WXmZ8Xxi9iA+E0W9Gm1MASDaRp1hsctZvyH++evwZDdjgMK5FluTFNT1RwdwEeDzbsvSM
	2Vaw9si/vPSSHdp8MpGf4yt7KV6VBBfa72BTk2t+4oMw4Ihq6663f/SIsQz3QotN454E3JNgKTXLf
	k83PbIqllqoxK5hwQg9uLoykDjdc5EnRrvh/P54vz5TNn3UfdvW/VR54c5mGcZIc55bXkoE7hGw3x
	iOkrcrng==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg72P-0001gm-Ia; Wed, 26 Jun 2019 12:28:33 +0000
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
Subject: [PATCH 25/25] mm: don't select MIGRATE_VMA_HELPER from HMM_MIRROR
Date: Wed, 26 Jun 2019 14:27:24 +0200
Message-Id: <20190626122724.13313-26-hch@lst.de>
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

The migrate_vma helper is only used by noveau to migrate device private
pages around.  Other HMM_MIRROR users like amdgpu or infiniband don't
need it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
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
index 1e426c26b1d6..40cf0562412d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -680,7 +680,6 @@ config HMM_MIRROR
 	depends on (X86_64 || PPC64)
 	depends on MMU && 64BIT
 	select MMU_NOTIFIER
-	select MIGRATE_VMA_HELPER
 	help
 	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
 	  process into a device page table. Here, mirror means "keep synchronized".
-- 
2.20.1

