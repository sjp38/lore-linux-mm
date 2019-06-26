Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46545C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F134B20663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Tbo19KxP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F134B20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AE888E001D; Wed, 26 Jun 2019 08:28:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BE658E0005; Wed, 26 Jun 2019 08:28:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 738888E001D; Wed, 26 Jun 2019 08:28:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3907C8E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:32 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e16so1535686pga.4
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q7MnaJX/iVm/t0Em26EnUyAunznzqEObFDwyR3G5AJk=;
        b=UK76uyjAK82+t3wyFZKqrrFwC6U0RSVj88psUmGr9601fWPR1QxbN89TTSlaI9Vitw
         TBlyjlZCurdhGV2Qzzn80+Jgp9LBHpWj32ZA/vMZy6FKJeowKFrFfJIq1I9hS458Z1W6
         /HdVzvDRRbQqLJHhs8nFRJiVSh2sfbSObK/l5CVKawhi6U0528adLuzMe8eDr2LXpDwu
         GNKL1oGIBbjYUxoeAJSPJACt6tVucFaVKHlEq9pOzf7VzFenc14REhoI0lGzYChv9zKF
         x2DtRa2DqK62MYZA3Yy4q/tFDf/shpq6zUEY/9Q3Nhx12U4PPcr7njJ3TTdOwPqXLKiK
         yXbg==
X-Gm-Message-State: APjAAAXbM+DqnIJBdQt8anNZ0klrn6f7r8g+RH+g1iW5fu5cNgFPMe62
	r/Pc+zwm2GfrInMNKeGty/d6mPSRMuEgLE3r6dI78rmDARWo24FvlWDbPQqTyyhaWR+asAaNUgP
	Pir1dxQgqOtdPhrHGdoNwpbzlw6jYPDnlg3HHq+4M/xIKsgCRVO/QhiB2TbZicFY=
X-Received: by 2002:a17:90a:b903:: with SMTP id p3mr4393731pjr.79.1561552111918;
        Wed, 26 Jun 2019 05:28:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJZIE1qldqfF37c/P3DSmMQne0ERmCOJ7iA0kShgxSyJ1Xw1kHE5LeMispF1RjLBBPRWJQ
X-Received: by 2002:a17:90a:b903:: with SMTP id p3mr4393667pjr.79.1561552111229;
        Wed, 26 Jun 2019 05:28:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552111; cv=none;
        d=google.com; s=arc-20160816;
        b=S5nV4kQWu4X41HUZ8dCFcpIdQEtLV5TfIEmetpUP22tenzEpf7chAWK2RKUj99PJIY
         xCOpo5YDlj3/J0Dy53Zb/quYzgsVECLJ/AvBv5/4lFjdY2OFt4GBcDxxu3OkYU+fhwBS
         VVL8efNaKv7docExd+LbBODiuuoRXMwUQVOSMXeWUSXNYhH3l0AH2/v1OTlI2vRl36rP
         eOO1g6fxzpt4HU6MI9fBL5EFHghIN8zW/qLTXRyGBdB4E1td9DKYinJZp601ugTQRLze
         g+6IiSCtEtaj0xPKU/xLyrzo02HjuUnaOPbrXlWvnb7NE7ZWCbCADTpO0bFANeJmIfIh
         Oklg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Q7MnaJX/iVm/t0Em26EnUyAunznzqEObFDwyR3G5AJk=;
        b=zVml5SfAbUQMy5zpNBWohHmOGQdMjBV7gN47VJmMtVjUp2+2RehIJJvBYgI7p1np26
         BYmBrBVqjbjh5w3wMuuVRA7V6st5Ivsl0VmjlvjBbnI5+VAssHuty3G3QhvpmZw5PtC5
         7zFGU1YSgazNVgr6/WeNoEJC5TAXM6+9vceqjDTSCg+jz4M0jIV31fCD499oTD3NK/x1
         jHe3G2IE+0XE6qQK1Fesn0ID8NAoM/Rya+mnhuc7odYNnO5Pi018dvH64bvEHQjFYlQt
         gNMuC4WKG2nFp/XGkBLtTw/NEY4Nqh6K7fk6e18+7ck9HvY9IpzqPw4tEtZZqQZP75K2
         D5ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Tbo19KxP;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c82si18147756pfb.32.2019.06.26.05.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Tbo19KxP;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Q7MnaJX/iVm/t0Em26EnUyAunznzqEObFDwyR3G5AJk=; b=Tbo19KxPBD9CoStAag7hFRkhL1
	UVbFR8/CEYnn6vco/RRdP7PkksW7LjaWOT2ywOSCt9dpWa1RFcZy8LipzSnYlREvTu9l5/oK26ATg
	Nk0WFaww+s7avBAde8Jm8KV50DOvVQEgDhHB6A8NSXWHXbsvgvkGAlYyeSqX2vJCoK3eLU9ouWC1p
	iel5ayxHoDx57ghhSjAUcaejPQLgxHwBJURlO9R2A5MY23VdntE10dntwJYao10el5aD5sXkfAOSY
	FOQs8Fuhnmthsq51h7FNDZAyBxsUOGDEFV0k50lYyd/nwnlHH9m9h+Q6hRj6OU7uwuOEV50gFx+DI
	HsH+LMPw==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg72K-0001eP-1U; Wed, 26 Jun 2019 12:28:28 +0000
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
Subject: [PATCH 23/25] mm: sort out the DEVICE_PRIVATE Kconfig mess
Date: Wed, 26 Jun 2019 14:27:22 +0200
Message-Id: <20190626122724.13313-24-hch@lst.de>
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

The ZONE_DEVICE support doesn't depend on anything HMM related, just on
various bits of arch support as indicated by the architecture.  Also
don't select the option from nouveau as it isn't present in many setups,
and depend on it instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/Kconfig | 2 +-
 mm/Kconfig                      | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
index dba2613f7180..6303d203ab1d 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -85,10 +85,10 @@ config DRM_NOUVEAU_BACKLIGHT
 config DRM_NOUVEAU_SVM
 	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
 	depends on ARCH_HAS_HMM
+	depends on DEVICE_PRIVATE
 	depends on DRM_NOUVEAU
 	depends on STAGING
 	select HMM_MIRROR
-	select DEVICE_PRIVATE
 	default n
 	help
 	  Say Y here if you want to enable experimental support for
diff --git a/mm/Kconfig b/mm/Kconfig
index 6f35b85b3052..eecf037a54b3 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -677,13 +677,13 @@ config ARCH_HAS_HMM_MIRROR
 
 config ARCH_HAS_HMM
 	bool
-	default y
 	depends on (X86_64 || PPC64)
 	depends on ZONE_DEVICE
 	depends on MMU && 64BIT
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP
+	default y
 
 config MIGRATE_VMA_HELPER
 	bool
@@ -709,8 +709,7 @@ config HMM_MIRROR
 
 config DEVICE_PRIVATE
 	bool "Unaddressable device memory (GPU memory, ...)"
-	depends on ARCH_HAS_HMM
-	select HMM
+	depends on ZONE_DEVICE
 	select DEV_PAGEMAP_OPS
 
 	help
-- 
2.20.1

