Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF652C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AA0A21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YfEdLD5C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AA0A21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF9186B0007; Thu, 13 Jun 2019 05:43:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C80026B000A; Thu, 13 Jun 2019 05:43:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAACE6B000C; Thu, 13 Jun 2019 05:43:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 787BA6B0007
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:42 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j26so13472533pgj.6
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xP52k8PSxiWJA231A7iOWwtNJf1wPwc/yjXMJD2RBtk=;
        b=kIG0BZkx/cFTvKGpCtvMRJ1uxpTc2Z3bSMk9L0GLwR3jmv73uGICE36b6l/bY1E4aH
         AylkPYgn6dO+Hy1U84dtzgzHtrhDKU2bOejDoy0h6CvTWxUOVGFs5rGYAu0EVuuVbybZ
         whmox61ijr1NbsQMgEzOT5SiJOP/dl5Bq15krgYJzh3W+FJwfjNJgi4k5wAMKLUprfcD
         cYZ93MD8vDG71ajFX8+7t3V7GBO28D6G25y5ukNQfprbkRtHgt6OxoGlXaJA5gDX+Ljh
         ui9UGUfjC0bsDChopgVlrJqrzQwC1x7PvJunmJwQQ6ZMy64Vo875Hx7VUA8AmdBDDkiY
         +xFw==
X-Gm-Message-State: APjAAAVO1t6hr40eAad+X0zcLDf48aUYrmxXmgj/UBkqQu/y9E82bLqM
	W2wvCYb4XhnWTnb7B+Z9WE53Ht0YQeP+VPoyMn3ddi374NGgDjJwF/ChqAhP5SqI2tV3h2mKIK2
	Mk4/2QeMmQVppoE1a7DN8213tOWbvS1yIEQ9BRi17JvH+2LeF6gVxSMLgJUfWR6o=
X-Received: by 2002:a17:90a:1ac5:: with SMTP id p63mr4287371pjp.25.1560419022103;
        Thu, 13 Jun 2019 02:43:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRj1N0eVFfvsy1phYU+qEbBiqW6EJgxPJr6lv77RlmUU7qsNJrE77qN/qrmgmyDTq37Xn/
X-Received: by 2002:a17:90a:1ac5:: with SMTP id p63mr4287274pjp.25.1560419021267;
        Thu, 13 Jun 2019 02:43:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419021; cv=none;
        d=google.com; s=arc-20160816;
        b=N8Rp263/hPprEOYMj0RS7qrRlRzRb+sTdMLyNBXVFN1G7RoPq2lZSlYoIrSGHq2+46
         JbkuczmOTpWmPyh/CSQTCcnT7tXFhgkanLFI8nWRmvlmCe1wpAKzAqZ+ShfyIa+JLUF9
         FukNXZQcfjRqxQP2SYUHqxLzO6mjevwDKSAT0GHSNwTA4O5mi3OSDUdMck+pPTOMlmMS
         5xsg8dmhr6t3kTjaAr7wF0OOtbeOy1a4izjG3lKmm2usujuiXLKhLQ9s5Z8I3kmzoBQR
         aDjRT7H8bAn7F64JsZR0qTHe0DeF+PPxmnPuSoflTzs3K87uW1JIyS7b38NW06U8fyOc
         PaQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xP52k8PSxiWJA231A7iOWwtNJf1wPwc/yjXMJD2RBtk=;
        b=E7DYCI4M9/x1UUG8eZ+cTvO0FOdsnMI1bM4Num99OtH2ddKhv5m/HlmkwBGNrsSJSn
         fQ2M0jgSEwSCN2oM6f94tWCA+irB2SZKz9InksIA9/Q5UaPIlOHW4A2fKeOnilvVHbdR
         dGyl4LXyyO4yQxfmnSmR00ehJtWua98pJmhqqog/LtN4BomKLL+Q0eWcYNTiont5jmGk
         3QhNantwm+gLG+tJkYUu1vbeka0rKpnGWhz4gWIx5+bYt0Qjg1rLVMtqXFjwZTQ2OWJY
         HhmjFmG6yRz1nwcNKLuNrFITHTagW925NR3Xhq9Ki2XoR21qUq4Lh6xLbqiRlKZ5PzFW
         wDRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YfEdLD5C;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n184si2680587pfn.59.2019.06.13.02.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:43:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YfEdLD5C;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=xP52k8PSxiWJA231A7iOWwtNJf1wPwc/yjXMJD2RBtk=; b=YfEdLD5CH3U9ysOCwdL2FYmTCm
	7+M9qmqGSvaM914U2KnoFaX+n4shPpJhrUd/PvcrkZkqrHimpFDBxMasr7oVEDrDKecmBuTaLZCGM
	iT/KWUgZgRrB5zdJ/8S6pGh3KqkYgPjzhaOvvfgtZVAUrvCGJ6viIrfd+IFAUOmCbaSXdn3Xqi6dP
	IyH7Omvq4XCgzsLItQEh8dQn6hfmBqy4TB1udG/rSepK2+eOtVvT3UK4eCYBuVf36OinvPDjaWT7K
	MXnnYC67WwxGCvY3QR0pM8YGYOMCMRIMWbIz573pF9NwIAyI8Sbpnmm+OJEQEqq7JYkUxrcjdGlkh
	kmjcQnIg==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMGf-0001kQ-VY; Thu, 13 Jun 2019 09:43:38 +0000
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
Subject: [PATCH 03/22] mm: remove hmm_devmem_add_resource
Date: Thu, 13 Jun 2019 11:43:06 +0200
Message-Id: <20190613094326.24093-4-hch@lst.de>
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

This function has never been used since it was first added to the kernel
more than a year and a half ago, and if we ever grow a consumer of the
MEMORY_DEVICE_PUBLIC infrastructure it can easily use devm_memremap_pages
directly now that we've simplified the API for it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/hmm.h |  3 ---
 mm/hmm.c            | 54 ---------------------------------------------
 2 files changed, 57 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4867b9da1b6c..5761a39221a6 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -688,9 +688,6 @@ struct hmm_devmem {
 struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 				  struct device *device,
 				  unsigned long size);
-struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
-					   struct device *device,
-					   struct resource *res);
 
 /*
  * hmm_devmem_page_set_drvdata - set per-page driver data field
diff --git a/mm/hmm.c b/mm/hmm.c
index ff2598eb7377..0c62426d1257 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1445,58 +1445,4 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
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
-	ret = devm_add_action_or_reset(device, hmm_devmem_ref_exit,
-			&devmem->ref);
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

