Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCCD1C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85C16204FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E0DF6Ggy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85C16204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A6D28E000B; Wed, 26 Jun 2019 08:27:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22F3F8E0009; Wed, 26 Jun 2019 08:27:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A8EB8E000B; Wed, 26 Jun 2019 08:27:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0E2D8E0009
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:39 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x9so1657095pfm.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PvDb2Ox1k4dZazYGdHDZANbuB1HI2/N93WOg6eXhjAQ=;
        b=bmHabRRv4dQuatEihOaA1mJQzYkvtpuHUoAbH/h7QaUuzkmgm4o3sf6SIkQI8n3XAR
         NEO0RDqd9AjSs0BZqz08KfIxqwmA8zLnGbWCjNhJ3+57nLPATUaqicos71gMLHhUdchM
         E6a3D1Muc2cDH0zPNFY3IWDLNrzBvQbNXw04OhS/VBhtZVgJtWOKqG0/1JNPaG35Pjtn
         wu2/+E9GXzIfumvi6fHy3kOVlzGynXEtxKlIXaVruHqHAl+UG62U+nBqDD+Kap0N/fS8
         ODc4wyYphRgb0YcPEmIBMMv+WAdPj4nelerPAbC3zvrdRcnTmGATl13kYYH/yUr4Zctn
         bxqg==
X-Gm-Message-State: APjAAAUxboW3HOleRbm6p15CnrbGTQu4y6ByIbGP+2jLGsi2fNmM48EL
	BUgS8V7IWQz22Ta2LftgLYgfbsFedjRJ6yisIef8/SkTTD52DYv1M9cdxzBFFzLNtbSEc/hptiL
	M+vrB3hvRhZeOIhDoXgAyD/2p0jl34ZvxHDaQ5mBbytcibYfO2DX8oVv+/RtXjDs=
X-Received: by 2002:a17:90a:36a9:: with SMTP id t38mr4487300pjb.19.1561552059399;
        Wed, 26 Jun 2019 05:27:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFgFa0uVjGwni38CKV3K/hPICdDkU6etNqpoU/EmAl7pVwJr7WapSd7lzDCHv4cLfH8oLa
X-Received: by 2002:a17:90a:36a9:: with SMTP id t38mr4487254pjb.19.1561552058715;
        Wed, 26 Jun 2019 05:27:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552058; cv=none;
        d=google.com; s=arc-20160816;
        b=ULc9S/KHmTNxEJNo8nvZdXYrifsgGio5boQOL4Ur/a8iKyDGG5newQshrDgdl7O9En
         ydh3a85nyqzi57wkuo7JnvG1xmolpGErhY6h+tF3OjOgapoCK3tvDaatUOs5aLWWJ5yL
         eJCrx1tx88kbl8aWh6oJ/vJ3u00fNcoRFsBAfm56m1Nzhzaf7zKpbnVNlaGx4qp50fYw
         MYxqkkpl9RPHYqIftTl4GK8SQ/WqMGo44XwMxHeN/1hD1ubd4ODEu1WfTMNU5RZaaGV1
         lyCzyEbKUouy57jr9pBkyzHlqw4U9Sch9BtEc3siXYtjPsNBDCI2sbW3LK4VOTyE6PvZ
         WRjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PvDb2Ox1k4dZazYGdHDZANbuB1HI2/N93WOg6eXhjAQ=;
        b=yoeeoq801IfW0bM2YV/6psDpZXXgWV1V6YBYBKHoPNA6QVU5xap/Vh6Lcx2tr47o+g
         QcrrbfEgSHAKBjDx6WAVEGGXhM4nZQHv3Qg/Q/JjkVafagv07y/KftTe5IgK8T4YL6sL
         +Ieddd/B9xTX4pQalsR4Sr649m06r99KAf0B28RCBwm4Oyn+7RzowsDjzhcA1EOTXY2F
         a3lBAjsEbgFXF1AbQReEv3jRQfDXsNoyrji1fFRUI9PjQEJiKiHoSTXddW67ARatpng+
         9b5pa2y2KVgNOwvtM1GVLjBsAMuwdZMJ0LFy3HALP/1DGz1L3AA3u4hamnR+S6S0UO6/
         tK7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E0DF6Ggy;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a12si16447187pgq.208.2019.06.26.05.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E0DF6Ggy;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=PvDb2Ox1k4dZazYGdHDZANbuB1HI2/N93WOg6eXhjAQ=; b=E0DF6Ggytv3Gi+tFrPw6dw4aqu
	+rHPjpovju8YpMPWpK5hdOjnPjIlRW48unTSpelufSzvKLWSUt/e34ssiioe1/5ZxXrtVnFEEqsDN
	MtZ05kIuc//K5X5/7YpQRRVj1Oo+GhI7xi0UNf4PVchnRbBhm0nr+E9y6T3ABZpYjZyWuLI1/1cKh
	UGePfkrWV5swka70VMAVR29do3YDNhIBRV8ceMW8c7eylWdxCeNEBOaIJPfNB1dCtfb6fGcett8tv
	KDQgObu/s9B8jBGA2uPUlv/nWmYitPoXpSy3/pbWVkhz+4PSZAUYIe+3z7PsMxjYj75CGTH5ctbb9
	dc3QNZbg==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71O-0001Kx-7F; Wed, 26 Jun 2019 12:27:30 +0000
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
Subject: [PATCH 01/25] mm: remove the unused ARCH_HAS_HMM_DEVICE Kconfig option
Date: Wed, 26 Jun 2019 14:27:00 +0200
Message-Id: <20190626122724.13313-2-hch@lst.de>
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

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/Kconfig | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index f0c76ba47695..0d2ba7e1f43e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -675,16 +675,6 @@ config ARCH_HAS_HMM_MIRROR
 	depends on (X86_64 || PPC64)
 	depends on MMU && 64BIT
 
-config ARCH_HAS_HMM_DEVICE
-	bool
-	default y
-	depends on (X86_64 || PPC64)
-	depends on MEMORY_HOTPLUG
-	depends on MEMORY_HOTREMOVE
-	depends on SPARSEMEM_VMEMMAP
-	depends on ARCH_HAS_ZONE_DEVICE
-	select XARRAY_MULTI
-
 config ARCH_HAS_HMM
 	bool
 	default y
-- 
2.20.1

