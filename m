Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CF73C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 175D6217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 175D6217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 938AE8E0004; Mon, 18 Feb 2019 16:07:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 911128E0002; Mon, 18 Feb 2019 16:07:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B0588E0004; Mon, 18 Feb 2019 16:07:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 296938E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:07:29 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id j16so6743596wrp.4
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:07:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eTq9HjBTOU/jc5MhAmF8ieTxY15GS5mv/p78sMj8zOY=;
        b=pSbGjTxSaVnZnDNBVmiOsj7ZvXIXOoB7Xl585Db2eZ5yBsbuMMkkbOxrpqlKNyZtcb
         7pZud7jveKSjRKwKaqgxCH52AGpzSB6efXzat7XE9BIaCEE1FBLThPdhdcKQHh1FIFkg
         it3HdfVCDFdiqIWtZtfVO7rv3oAi/FF2zfoQZa4USL2gn9eEydfUCwN7C1UJEiUYSW3N
         v5Xyb8iztM2c9bOIDwQ1e56bc2eWHJj//+Q963YKnFA898CK9I42q3kXs36m/NRIWTKb
         dSbXIIowqhc4JHI2PErSa2004j/iOxMhSfxrVfr7oxu7Si6Eh5nEbSSEX19iRP4QpMcK
         FW3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=krisman@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AHQUAuanfT2lJEr3z2d29KVPi6qks5dY099aInoXH++EhMNLPRPL41nZ
	r6H3kNgCfVEdtNiNTJoBmPP9fpB93FVirXVzGmQ+sYpY5RjluFPG1a3gfw1CvBrFNfCNan+5gBv
	3PQSjAYYxvb67iNVGpngJODRhCItO9hy0Q1WnchzxvfdlJ5Po0QQqAuGuDKYvK5Gpng==
X-Received: by 2002:a1c:eb0a:: with SMTP id j10mr449183wmh.115.1550524048643;
        Mon, 18 Feb 2019 13:07:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYnCrW5epgoki43i0ZoylVupeg7VoeCLNBxj8P+BTnYe1bK+ww29WUGs+qJO9ozpYuGgBzu
X-Received: by 2002:a1c:eb0a:: with SMTP id j10mr449149wmh.115.1550524047444;
        Mon, 18 Feb 2019 13:07:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550524047; cv=none;
        d=google.com; s=arc-20160816;
        b=vT/yZ3RHDsS9HI9UGp1NpLDeo7NN420U5weQvPBA5s/A2GR0vRY7Z6Xil8S8eWrs5m
         sWlMNBYTg0tyWmhRnuuL1GRYW+k9Gwa4XJ8aR7TJeIjbhT44KKjvuuebwGKm5mvp3Jwv
         YDik1BpBDQPGWx0Ax+v/WDBTit2lf3C2aVoSuTE+6PAMtf2M1lT0NhhV4OnnXMdzkXDE
         l6OTvs18XR8jtuP/e+7Mj022qXJDTMSMEreJSPvSsj6FHC4rAw5X8Z9kfO4XcK21Pmr6
         RQ2KMNFz/DTiF65V4QcnM0BP2WZUcrsZIitMRBjGbnVclcIqu67pNh8vNeBmqWaRPVry
         toKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eTq9HjBTOU/jc5MhAmF8ieTxY15GS5mv/p78sMj8zOY=;
        b=KdJHmrsIRguFjym7h6W1nhlgNKEYQvkOi/PfbBKyt5eUkd04nNfsJ8dyPVkx/DqQ/k
         XN89vKMmEl2qKYxNkUvI78K1q89w52hgJWcRkA6nVjk9ATo+cFCZzkFP1BsOIngM3jec
         qTGF5eA5ZTphHojkf5+wSbt0z8/Fw/bGCvnpv24Rk59RONMxyXz2uIl9p089Rb8PsI7w
         Qhk3lsmaetD4NhzNMJun2nJ+hXnWfWe1ZerWA9eUHAKa+dSsge9Ix3T1OkM3DDWnHqrt
         mU/XeO/XFCrqBQphN8+Ez+sy4kEKuX+16898+NJQjpX64Tt3Azdp183U6Lu+lnsERErG
         9SSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id t13si10019593wrn.408.2019.02.18.13.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 13:07:27 -0800 (PST)
Received-SPF: pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) client-ip=2a00:1098:0:82:1000:25:2eeb:e3e3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: krisman)
	with ESMTPSA id F1D6127F9AB
From: Gabriel Krisman Bertazi <krisman@collabora.com>
To: linux-mm@kvack.org
Cc: labbott@redhat.com,
	kernel@collabora.com,
	gael.portay@collabora.com,
	mike.kravetz@oracle.com,
	m.szyprowski@samsung.com,
	Gabriel Krisman Bertazi <krisman@collabora.com>
Subject: [PATCH 1/6] Revert "kernel/dma: remove unsupported gfp_mask parameter from dma_alloc_from_contiguous()"
Date: Mon, 18 Feb 2019 16:07:10 -0500
Message-Id: <20190218210715.1066-2-krisman@collabora.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190218210715.1066-1-krisman@collabora.com>
References: <20190218210715.1066-1-krisman@collabora.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This reverts commit d834c5ab83febf9624ad3b16c3c348aa1e02014c.

Commit d834c5ab83fe ("kernel/dma: remove unsupported gfp_mask parameter
from dma_alloc_from_contiguous()") attempts to make more clear that the
CMA allocator doesn't support all of the standard GFP flags by removing
that parameter from cma_alloc().  Unfortunately, this don't make things
much more clear about what CMA supports, as exemplified by the ARM DMA
layer issue, which simply masks away the GFP_NOIO flag when calling the
CMA allocator, letting it assume it is always the hardcoded GFP_KERNEL.

The removal of gfp_flags doesn't make any easier to eventually support
these flags in the CMA allocator, like the rest of this series attempt
to do.  Instead, this patch and the next patch restores that parameter.

CC: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Gabriel Krisman Bertazi <krisman@collabora.com>
  [Fix new callers]
---
 arch/arm/mm/dma-mapping.c      | 5 ++---
 arch/arm64/mm/dma-mapping.c    | 2 +-
 arch/xtensa/kernel/pci-dma.c   | 2 +-
 drivers/iommu/amd_iommu.c      | 2 +-
 drivers/iommu/intel-iommu.c    | 3 +--
 include/linux/dma-contiguous.h | 4 ++--
 kernel/dma/contiguous.c        | 7 ++++---
 kernel/dma/direct.c            | 3 +--
 kernel/dma/remap.c             | 2 +-
 9 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index f1e2922e447c..bc3a62087f52 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -586,7 +586,7 @@ static void *__alloc_from_contiguous(struct device *dev, size_t size,
 	struct page *page;
 	void *ptr = NULL;
 
-	page = dma_alloc_from_contiguous(dev, count, order, gfp & __GFP_NOWARN);
+	page = dma_alloc_from_contiguous(dev, count, order, gfp);
 	if (!page)
 		return NULL;
 
@@ -1291,8 +1291,7 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
 		unsigned long order = get_order(size);
 		struct page *page;
 
-		page = dma_alloc_from_contiguous(dev, count, order,
-						 gfp & __GFP_NOWARN);
+		page = dma_alloc_from_contiguous(dev, count, order, gfp);
 		if (!page)
 			goto error;
 
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index 78c0a72f822c..660adedaab5d 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -159,7 +159,7 @@ static void *__iommu_alloc_attrs(struct device *dev, size_t size,
 		struct page *page;
 
 		page = dma_alloc_from_contiguous(dev, size >> PAGE_SHIFT,
-					get_order(size), gfp & __GFP_NOWARN);
+						 get_order(size), gfp);
 		if (!page)
 			return NULL;
 
diff --git a/arch/xtensa/kernel/pci-dma.c b/arch/xtensa/kernel/pci-dma.c
index 9171bff76fc4..e15b893caadb 100644
--- a/arch/xtensa/kernel/pci-dma.c
+++ b/arch/xtensa/kernel/pci-dma.c
@@ -157,7 +157,7 @@ void *arch_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 
 	if (gfpflags_allow_blocking(flag))
 		page = dma_alloc_from_contiguous(dev, count, get_order(size),
-						 flag & __GFP_NOWARN);
+						 flag);
 
 	if (!page)
 		page = alloc_pages(flag | __GFP_ZERO, get_order(size));
diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index 2a7b78bb98b4..23346a7a32fc 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -2692,7 +2692,7 @@ static void *alloc_coherent(struct device *dev, size_t size,
 			return NULL;
 
 		page = dma_alloc_from_contiguous(dev, size >> PAGE_SHIFT,
-					get_order(size), flag & __GFP_NOWARN);
+						 get_order(size), flag);
 		if (!page)
 			return NULL;
 	}
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 78188bf7e90d..ebaab2d3750f 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -3791,8 +3791,7 @@ static void *intel_alloc_coherent(struct device *dev, size_t size,
 	if (gfpflags_allow_blocking(flags)) {
 		unsigned int count = size >> PAGE_SHIFT;
 
-		page = dma_alloc_from_contiguous(dev, count, order,
-						 flags & __GFP_NOWARN);
+		page = dma_alloc_from_contiguous(dev, count, order, flags);
 		if (page && iommu_no_mapping(dev) &&
 		    page_to_phys(page) + size > dev->coherent_dma_mask) {
 			dma_release_from_contiguous(dev, page, count);
diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
index f247e8aa5e3d..3c5a4cb3eb95 100644
--- a/include/linux/dma-contiguous.h
+++ b/include/linux/dma-contiguous.h
@@ -112,7 +112,7 @@ static inline int dma_declare_contiguous(struct device *dev, phys_addr_t size,
 }
 
 struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
-				       unsigned int order, bool no_warn);
+				       unsigned int order, gfp_t gfp_mask);
 bool dma_release_from_contiguous(struct device *dev, struct page *pages,
 				 int count);
 
@@ -145,7 +145,7 @@ int dma_declare_contiguous(struct device *dev, phys_addr_t size,
 
 static inline
 struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
-				       unsigned int order, bool no_warn)
+				       unsigned int order, gfp_t gfp_mask)
 {
 	return NULL;
 }
diff --git a/kernel/dma/contiguous.c b/kernel/dma/contiguous.c
index b2a87905846d..b1c3109bbd26 100644
--- a/kernel/dma/contiguous.c
+++ b/kernel/dma/contiguous.c
@@ -182,7 +182,7 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
  * @dev:   Pointer to device for which the allocation is performed.
  * @count: Requested number of pages.
  * @align: Requested alignment of pages (in PAGE_SIZE order).
- * @no_warn: Avoid printing message about failed allocation.
+ * @gfp_mask: GFP flags to use for this allocation.
  *
  * This function allocates memory buffer for specified device. It uses
  * device specific contiguous memory area if available or the default
@@ -190,12 +190,13 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
  * function.
  */
 struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
-				       unsigned int align, bool no_warn)
+				       unsigned int align, gfp_t gfp_mask)
 {
 	if (align > CONFIG_CMA_ALIGNMENT)
 		align = CONFIG_CMA_ALIGNMENT;
 
-	return cma_alloc(dev_get_cma_area(dev), count, align, no_warn);
+	return cma_alloc(dev_get_cma_area(dev), count, align,
+			 gfp_mask & __GFP_NOWARN);
 }
 
 /**
diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index 355d16acee6d..6c7009dc9cab 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -111,8 +111,7 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
 again:
 	/* CMA can be used only in the context which permits sleeping */
 	if (gfpflags_allow_blocking(gfp)) {
-		page = dma_alloc_from_contiguous(dev, count, page_order,
-						 gfp & __GFP_NOWARN);
+		page = dma_alloc_from_contiguous(dev, count, page_order, gfp);
 		if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
 			dma_release_from_contiguous(dev, page, count);
 			page = NULL;
diff --git a/kernel/dma/remap.c b/kernel/dma/remap.c
index 7a723194ecbe..862fc8e781c2 100644
--- a/kernel/dma/remap.c
+++ b/kernel/dma/remap.c
@@ -115,7 +115,7 @@ int __init dma_atomic_pool_init(gfp_t gfp, pgprot_t prot)
 
 	if (dev_get_cma_area(NULL))
 		page = dma_alloc_from_contiguous(NULL, nr_pages,
-						 pool_size_order, false);
+						 pool_size_order, gfp);
 	else
 		page = alloc_pages(gfp, pool_size_order);
 	if (!page)
-- 
2.20.1

