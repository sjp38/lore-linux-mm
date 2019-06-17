Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86C28C31E59
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E23620657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sb1bPHYS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E23620657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4E7C8E0004; Mon, 17 Jun 2019 08:27:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFCD98E0001; Mon, 17 Jun 2019 08:27:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C12158E0004; Mon, 17 Jun 2019 08:27:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBDC8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:27:45 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so5911703plo.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:27:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PvDb2Ox1k4dZazYGdHDZANbuB1HI2/N93WOg6eXhjAQ=;
        b=f0EvmgtSBp3I4VPUogExj4FF2qOkameNa+lTy9xIko9Nm0fUkE3fy6e6O3GU2qBnka
         TgbKDJ+fDcI93+C968u+0LIzuGnAqeCYrSRVeGyIeb2VOEBUjJ1glDosI7JkOSKvgJBB
         WF4Jp+12x3I9XXxW10hfcg3iyfbjlgNrRM2P4YwLT7MwPogCPoLuMOEsa/836wWI26T4
         v8H8g2w9wwgfyC6gxIjd+BjLTjnaQReQ1g+Xu8U/ONvfALoP02l8lhnEeCZ6EcxOb9fZ
         lgypxoL4LV4umct7KmpJBTzY8XeyxCskMwSdCsDYPLgw76tvMS6G1kk1sGUVKaQSx6TH
         tQFQ==
X-Gm-Message-State: APjAAAUevc6Ojq99Duf0p5woXYs9fh/lErA7uSdW1fxtG+qj3YQmxePM
	6xcQQHnnQSeh56iIfou2tPmvx2ufsvmuiJl+N0rhzzQl481iGrWZJje7A/TZZumSC4B+0owLRX5
	Q59Yp7Yqt+UwsvLER8/mAv2RFLtt5shY76nNJhtyzfZPBmhVZjL0yRe5uzjAEHpk=
X-Received: by 2002:a65:5308:: with SMTP id m8mr23383097pgq.54.1560774464379;
        Mon, 17 Jun 2019 05:27:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEq0W0oM+uqrLCs35qpc+CGPrUvnJDuo7CnlcMVEnC881qwA+NI78NvS9P2XXqd9ZGmi+B
X-Received: by 2002:a65:5308:: with SMTP id m8mr23383054pgq.54.1560774463465;
        Mon, 17 Jun 2019 05:27:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774463; cv=none;
        d=google.com; s=arc-20160816;
        b=m51aGx7XK71B6SwdO8ys1+63xDfvA+fIjVFbJwMibJnOdY+DqOJvUqMzGqjLzjHb7v
         y67f7ygQJ0B0rwYpCivSwXv9UUa7rezagXWtwfgJotN6az2poRFlnl8uQTD+53p1w72+
         YeVj7qNKwNYm3nLzgZjEof0eSR7161x+7LVkCYAwKrG9vVaSlY34ExWZAzO265AYCAsP
         hvia5O3EjDuvsVjdR/r2I2oQ8+2Vu6rwdn5ai7qSAgv31QohHb75X1TvJ1Hvh+7+3uHs
         pQCtUIkIwZgiDCWLrtkpXtLd0p9yteNsQn2BoRz7scJR4lfOPMS4ARfKYoEL2j+sHO9g
         ZMzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PvDb2Ox1k4dZazYGdHDZANbuB1HI2/N93WOg6eXhjAQ=;
        b=QDVi8HeLNColEUukyhTNL+79gWhO6Cm9q2nq9Nfyq7hUR7j4+znDpc+++e4lv0aSa3
         NKLtUcwdZxrg7zboDkbOMSYM9gOVWdlIugY8FLBiU9JCUoCFPchXQ3OcgUv4dJg41c/9
         E3InaXRu7lT7cdfzCSTJKDwE4E9wOlpTqfUfTCN9ZSV0fMwaK3Yo5T4zAuRozCGvb0Qg
         XpkC/DG+ZVI5BFkc1hKHxSijuTUqb+RiS/i2YAcJ/2yWVDbnx+2ov/Jt1rGR3GDYNbfV
         A2EDqx0tEjmiwfeKZs6zpqavr2wMV5BiwT6f+Si4A0FwB42ajOepwk0rhoHSxSPkVLUs
         PN/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sb1bPHYS;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t23si10590077pgu.320.2019.06.17.05.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:27:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sb1bPHYS;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=PvDb2Ox1k4dZazYGdHDZANbuB1HI2/N93WOg6eXhjAQ=; b=sb1bPHYSDLwe702WgBPwsLs+J0
	vhPm0vc39IREraw5fNiKWwVi9b2XYJL8w6l2OeJY6AgdG8fPQh63r1aibZKvGoX4P777qmADQIXze
	OYKNAjycAzImv4MUUNJ1Sv6fOnX95UP0Tu509ppILxE5n4d614sDWPMcRXsHXnhq1gEXEUCA1AvUq
	OqgqDRRmXt/AFAdHkWOVd0/MMaDaR60es8wSgvkI32aP283KFFhUOZkJ79kLqoS/P/7e6eF2EVA7o
	0cDAzMOCQw8d61JCfYZgkqA5mYDhyXUXH6xL/G5qSJueB/oc/v0KwCGT+woKWUhfY5a9eI/qAtVq6
	jjs4LpNQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjb-0008KG-Cp; Mon, 17 Jun 2019 12:27:39 +0000
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
Date: Mon, 17 Jun 2019 14:27:09 +0200
Message-Id: <20190617122733.22432-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
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

