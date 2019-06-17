Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F118C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A0502087F
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FbRn9tnx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A0502087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D74F08E0006; Mon, 17 Jun 2019 08:27:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFF758E0001; Mon, 17 Jun 2019 08:27:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B29E08E0006; Mon, 17 Jun 2019 08:27:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CCED8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:27:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i3so5905718plb.8
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:27:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7iZXhGqknpU44tD1MPjuSqDckdpKS/nLGoa4L7/1O94=;
        b=VfzkmcxorRnH/bBmmeULoLXsDjvGTnvoU5Trt8UfA/EpWujkyBgmgIcHLpsw1osy8y
         6k/Lzqg7JGxSoxOFMKClfqMrA3fiJEJNQUdocltXHqKSEQisvC8FJRzwMtDPEGt9Jc3B
         0lwPdpQDw1vEpIks/RYWUy0JaLorHaNaLz6o3rXVbZCeXAd/Cfz1T/DmCt6cugya7LcW
         V1J7oz9AEwvhDMb3nYrnMOtv2S2+51g78t80Y8ayayLEwik02zc4s6xUt9NDy0eoDrqB
         oEeMLrNXTgobPxpRy7m3yHxR4ey2/1UfFpjhS3/3nUWp6hKGKAmp6K/CeIQna0mR8ACf
         6/+g==
X-Gm-Message-State: APjAAAVE5JBWqlBRzSfJjXYQFXkirG83w7eG97Ty/5JZelTUGNX5VAUX
	QdKdXJyDSHZUpTvfeAXHB/aXpvmVy1KZlS/1buEghXlDBPzjSkncdwstxtRk5qp+rTUrEgSle0+
	jP+TkgDuZEgpyFAg8GEinOh/yl0DxG9nhPTah+aNIDiaNR2BE5ixUPc2bi0zZnnU=
X-Received: by 2002:a65:62cc:: with SMTP id m12mr48757975pgv.237.1560774467056;
        Mon, 17 Jun 2019 05:27:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJBDlHs2uOue2PnDpvP3RptzGznjVlya2nFhM6FncKj8FUr2joQB2BMnNJp4cZh6XmgPQn
X-Received: by 2002:a65:62cc:: with SMTP id m12mr48757931pgv.237.1560774466148;
        Mon, 17 Jun 2019 05:27:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774466; cv=none;
        d=google.com; s=arc-20160816;
        b=EggGR4PV2GSpcSsJFDJKP6Y4FG0G69WQHbhK/60DARhtX4avP9O0QRBKIfm+XjXIPs
         W4jvKOyuoU1MAITqgCsqLAr6dqmqpHF0/jea5bUlDIf27am2sL8boCCiVCUgKFZyu89s
         sixKnRR9Hnp4f8CHJ0f14CyBHikClKkFLHv5hBxhDCdwa57LrFpx3D48Hu1K5pUNBczV
         Aywubu7xuoVLQxb0brTF1i4v4q4W9wNFWdfvOI8cLjeV3I/iGHhIHb7pXu0+I5+Fv4Xy
         3Xtu+4XRsVzfIUnDHdmlucnV2G0I8gO2HLD3HyYZP6kzTuLYLvNV3hPAgHZpAZ32av7Y
         vr9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7iZXhGqknpU44tD1MPjuSqDckdpKS/nLGoa4L7/1O94=;
        b=VsrrX0YA/6c16N5vh2NQqsEAJjt4i+xYx3g3rMdbTGhaLjPyLNU3XYQGaKN2EDeI7Z
         zJShGtVODv7cJjVD/F0CKlkFezn0U7FeOJm87xBlQRTbSvLY3+O5kyOkVVUNneULgbwE
         zIBqls5lWiNZ54cF9QRWSAyzRR6fb2aGGW/3OHd8iz32hKfcRW3piqYeDSSJ+bz3z95K
         H1u2OhkoZJfQOY3IMguUTbzW1HFRP9A1/mdr3vyKOf51lr9RCpnMg/lo+2m4FSYkTADs
         uPsSHErbWGx2E3epFKMNwvK5wsrx9rmuOAc5CxlDWHCVjcQFL/+5GWVg/zduoCKuBZ+T
         FRDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FbRn9tnx;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x3si10853777pgk.413.2019.06.17.05.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:27:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FbRn9tnx;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=7iZXhGqknpU44tD1MPjuSqDckdpKS/nLGoa4L7/1O94=; b=FbRn9tnxZ5wWW5q5U1pZRBVxXs
	CxGwGMXKAq/9Ihv+awdUqjfKfebfLDdbVNObc0HyuE8WXKatstvj5dw/HK/igbfwoSFPnkwWo7ebj
	rUGor0jqTaP/NW3YZeZfVSnvBwAlo3Lo8EiyGtMu2ND6pJBqRtA/O5D4bGF6fo8S0K5psWYBY5XxU
	2c+lcusAC9Bxse0Kr01AZ9/JkVgMHxvoDiwKVC1jNIBFfo+VKR+KrNeDEBaA0xzhkfYUvWAgWPrWC
	Lfcmv9DujdDUWC5tNLBcO6Ok6TTvo8HvDhBnnc9rcvR5/dgumLg41lBugJqDsgZ6cxqqK5EVO2485
	CgZI5zyQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjf-0008Kt-OO; Mon, 17 Jun 2019 12:27:44 +0000
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
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 03/25] mm: remove hmm_devmem_add_resource
Date: Mon, 17 Jun 2019 14:27:11 +0200
Message-Id: <20190617122733.22432-4-hch@lst.de>
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

This function has never been used since it was first added to the kernel
more than a year and a half ago, and if we ever grow a consumer of the
MEMORY_DEVICE_PUBLIC infrastructure it can easily use devm_memremap_pages
directly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h |  3 ---
 mm/hmm.c            | 50 ---------------------------------------------
 2 files changed, 53 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index c92f353d701a..31e1c5347331 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -724,9 +724,6 @@ struct hmm_devmem {
 struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 				  struct device *device,
 				  unsigned long size);
-struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
-					   struct device *device,
-					   struct resource *res);
 
 /*
  * hmm_devmem_page_set_drvdata - set per-page driver data field
diff --git a/mm/hmm.c b/mm/hmm.c
index f3350fc567ab..dc251c51803a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1475,54 +1475,4 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
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

