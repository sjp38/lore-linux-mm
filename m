Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE7A8C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7799204EC
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="M5RvEFLk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7799204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 404D98E000C; Wed, 26 Jun 2019 08:27:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38E848E0002; Wed, 26 Jun 2019 08:27:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 230458E000C; Wed, 26 Jun 2019 08:27:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA1808E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:47 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so1646810pfo.22
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tNgbIaFusBSvgAH0tfiGZyikD01HyoX3FofXPz2PChg=;
        b=AgLNfXLf7Y35/sZuM43DUXEe42RAuc09FHT8IYSB0dNF/T5ygzidlV3OXsPD5h5kjI
         +n5tCquUanBq4jXTO0CkDhX7tqt2NnOlC+BQf5yyI1ffTt0D9pKB6Hg/X6eJQ1YiDYPf
         Ak805aMD6HOohEiBGSTqiSPaQrDQ0msSLx9EIJkY/xs8AkkvtyCrg422KEnIsqmk5qPn
         v8Jq/PVco58ZXgAN55Q42oUr7bmNQDQCVnfpjeXR1ODMb6rRZFRIxae9NQV1WbEJW+zy
         9qIFpBEtGhY5oaGYcixQXiWO46hFjV1qvyxV5aImYrea3B4ZXG8bIaaxslcUX9Tfq1ym
         i/BA==
X-Gm-Message-State: APjAAAVAkKkxuu0zlt32T4e0HHxr+owdFhfovBAA+ICOWrUjn7NfybBn
	XJGUckkMxX3V2WaPyF2hiCVTCG5xP2mXs972x5Ly6tKWqEyGvOWb5N+vzb3ZNJdRY7H8pnsidKg
	x3sR2rY3xmId72yQWwsJiHlgi1nbfCwjc683lpISDZjMdHlapp+IEVhj0T0/aAdA=
X-Received: by 2002:a17:90b:d8f:: with SMTP id bg15mr4474915pjb.65.1561552067531;
        Wed, 26 Jun 2019 05:27:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLouxRZ7cTX1z5xuKoi3zZ08bQgJzPrce75tCSE9Sx4YcoCCGBEemOayjwUMe48dFtM2Sh
X-Received: by 2002:a17:90b:d8f:: with SMTP id bg15mr4474853pjb.65.1561552066756;
        Wed, 26 Jun 2019 05:27:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552066; cv=none;
        d=google.com; s=arc-20160816;
        b=zcsP0lzKpA7Y6C3B9srptiK1pV7r00yguzRY6LDvxY0FC1Fj6R6IsS1TPVwhQogz7o
         sArTVmv0m2N5zXcZljNfZbySgJsvkDjx4wkKCj0/CIc/LqqlXy2MUQ936hkLbNPkcUWK
         g3EsBm8Y1n/izUOebsv+MkrEC9x1TngyFFXFtE5SePSVkzmkACnpoUblzeDoefqmohqz
         HpBdZ9cwIBv98OL3P5oSFX9rp4PRbKVOBqXbKZ/wds+7vHospzhMyIJOk6IZIFdxB/8U
         iJvbEAxkCcxNZ5nIz3EvpSHnB7la+zBZQriGwbOttKHGt8gNsqudgC/NcQbqFqkOGnl0
         9wlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=tNgbIaFusBSvgAH0tfiGZyikD01HyoX3FofXPz2PChg=;
        b=lArN1CSxEOvOmIfbUb3rKMRbGOxjvxL4IiCTeFnkAoAX6lXXJ2OP32aqAXZ1icQh4x
         V1uwmUhv0c7VcQSDv7o1MEqEHgC6n5752kouxPn0fFxOYRzNcaB2Dr1QNErxquRMiFl6
         VzdJ5TmzpRXzRszj8zWVkLThKbaHhWnnaoJiBmh9/kEB7Aqdh5xDiCOgkNddelvkHBBC
         79DRE4/f52SreKlQgaiGLirCFpS5T2gfHDGaiUV9DkEt5HLPxvu9+SBaM5oYcbLcbqrG
         u5489cFE4T8wqArTmrIyc39LO1C6duUPZQQKEA0q2MYbOWwHB69dCUS269DUC49UOpxS
         fvGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=M5RvEFLk;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e1si18037428pfl.121.2019.06.26.05.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=M5RvEFLk;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=tNgbIaFusBSvgAH0tfiGZyikD01HyoX3FofXPz2PChg=; b=M5RvEFLk+xIi2sTIO00V1tX6nN
	Gas2OAPsm1RlVSmT8mEzUg67uQy5Ztrh4Dy2+VDFaybxSBu9cD+Zubb2kEKq3ZgXa2N3+M+MjK4RS
	/lvmIiR4bg6GCmFpkNQJEblVadLbxP29esClvEVUoJpempikVE3+jPaymXArWMF5wu1d+pU/lenHS
	O832RJqlERaIYCMWPFXMC2DpvqxzI2jLAIukePF57ECvYnIUGaEn08FT4Md+/es9ooWC8+J73/u2t
	wKW9puCoUaWunC/FTlqtJUVADewWKckr6vI895VX3CSClMhkQHH6I2GbIPFNNNGq5kmrXIBkvg173
	XtY/cvdg==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71T-0001LI-FP; Wed, 26 Jun 2019 12:27:36 +0000
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
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 03/25] mm: remove hmm_devmem_add_resource
Date: Wed, 26 Jun 2019 14:27:02 +0200
Message-Id: <20190626122724.13313-4-hch@lst.de>
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

This function has never been used since it was first added to the kernel
more than a year and a half ago, and if we ever grow a consumer of the
MEMORY_DEVICE_PUBLIC infrastructure it can easily use devm_memremap_pages
directly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/hmm.h |  3 ---
 mm/hmm.c            | 50 ---------------------------------------------
 2 files changed, 53 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 99765be3284d..5c46b0f603fd 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -722,9 +722,6 @@ struct hmm_devmem {
 struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 				  struct device *device,
 				  unsigned long size);
-struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
-					   struct device *device,
-					   struct resource *res);
 
 /*
  * hmm_devmem_page_set_drvdata - set per-page driver data field
diff --git a/mm/hmm.c b/mm/hmm.c
index 00cc642b3d7e..bd260a3b6b09 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1478,54 +1478,4 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	return devmem;
 }
 EXPORT_SYMBOL_GPL(hmm_devmem_add);
-
-struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
-					   struct device *device,
-					   struct resource *res)
-{
-	struct hmm_devmem *devmem;
-	void *result;
-	int ret;
-
-	if (res->desc != IORES_DESC_DEVICE_PUBLIC_MEMORY)
-		return ERR_PTR(-EINVAL);
-
-	dev_pagemap_get_ops();
-
-	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
-	if (!devmem)
-		return ERR_PTR(-ENOMEM);
-
-	init_completion(&devmem->completion);
-	devmem->pfn_first = -1UL;
-	devmem->pfn_last = -1UL;
-	devmem->resource = res;
-	devmem->device = device;
-	devmem->ops = ops;
-
-	ret = percpu_ref_init(&devmem->ref, &hmm_devmem_ref_release,
-			      0, GFP_KERNEL);
-	if (ret)
-		return ERR_PTR(ret);
-
-	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
-	devmem->pfn_last = devmem->pfn_first +
-			   (resource_size(devmem->resource) >> PAGE_SHIFT);
-	devmem->page_fault = hmm_devmem_fault;
-
-	devmem->pagemap.type = MEMORY_DEVICE_PUBLIC;
-	devmem->pagemap.res = *devmem->resource;
-	devmem->pagemap.page_free = hmm_devmem_free;
-	devmem->pagemap.altmap_valid = false;
-	devmem->pagemap.ref = &devmem->ref;
-	devmem->pagemap.data = devmem;
-	devmem->pagemap.kill = hmm_devmem_ref_kill;
-	devmem->pagemap.cleanup = hmm_devmem_ref_exit;
-
-	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
-	if (IS_ERR(result))
-		return result;
-	return devmem;
-}
-EXPORT_SYMBOL_GPL(hmm_devmem_add_resource);
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-- 
2.20.1

