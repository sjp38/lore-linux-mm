Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63CEEC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BD672089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="W2VpTqt7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BD672089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B1198E000D; Mon, 17 Jun 2019 08:28:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 364618E000B; Mon, 17 Jun 2019 08:28:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DAFD8E000D; Mon, 17 Jun 2019 08:28:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D86AD8E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:03 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 71so5899139pld.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SrlBfglV2hFr71vKq82TSTUn2RS300iWsrC5HG0Yr4o=;
        b=Vet9qj9lNUrTsPkwmXYn87agUDXV9SRj8/+Awe1B7UupubAIAuuq2bfVPFMHR52t5d
         6+vJaKFMkLLtVo3VFkEepc7PwZTo0o0PL/TiFSe1WqenErPuSLyHEx8RkzTdKiiP0R6E
         2DBU0y6tl67vsmNyRNOh+m0tUM8whFtvXs0Eam7n0zrisAaxypVFiwrgkU1UKE2xd3cq
         /Vk7YcU98/XiPcNNE429IyKJA8Jw6srk1iY+Ncgp+FCIBtd6F5KxoCwH8wCt/K9OH1mY
         Y3J7/tQ2Iw1avGuYNralzKDjR4/Drh/I54nWURl00RThs4Z47x9qqlJIfdgtBQHAtw7N
         3JrQ==
X-Gm-Message-State: APjAAAVshWr61mpfsSg/fJtMz37gVS7ZRNztV4hYHCXYA/JCOrxHrtaU
	xF52Z5mKCxMIKzc4nE1/B73x+U+qVUiqRuObcufuiUQtIWDtx6jarYcq2s7IbiGdJxvniH6qf+D
	WWtDXxkdoAT8dTQ2qh2RjtFr2F6P9xDjJOT35Hlasg1kEcF9ORb4YJr2JZr2CQGw=
X-Received: by 2002:a63:e502:: with SMTP id r2mr20487896pgh.261.1560774483371;
        Mon, 17 Jun 2019 05:28:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9q8oAHlOtVIwODH/PCOpKpF9UwuiimGmtvEAG492si+Nok8wFdqbw4vkOZV73x6C0Wms+
X-Received: by 2002:a63:e502:: with SMTP id r2mr20487849pgh.261.1560774482428;
        Mon, 17 Jun 2019 05:28:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774482; cv=none;
        d=google.com; s=arc-20160816;
        b=V7ABcxES+mJbQM02gScjwGhNcMhK7eSXRDi9xNS90shJdmEwJ8RIqgNWP1dHx25NVU
         0YetqbPdUTof6FUBWFtVdin4EDJg7qlZSGJAFJLpLECMIS0mi92EqXeK8DZl3tTD8R7D
         4ZH2MeDBNPUVyK/b4LtN4bW0gGcig3TTIfNvKTvTwb0SpHJiR+VBsmMjXxf093jF8hsD
         3fkecfaLR47zSScrVPz8lHtTFclOn4+PCfURjJB3nLOFgAKD632ZF8WzZM9jxC4c6mQY
         oNZGd1ITYsYvOZoxoShuk8l/WMQDp9cmwyRVIlPkmcDl2V2zKSId/clvAQduNKAKaN2l
         cifA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SrlBfglV2hFr71vKq82TSTUn2RS300iWsrC5HG0Yr4o=;
        b=v38gxmLij9GuOTMBNZ4pIOxcWzK8yNba9tPan/5vlLY6BLyOMmsgE5JDLXjAMsYfuV
         TxscMxbsovNT6+SGUjZbRwYbCwhzxaMxa8lqkEAdBSsKlRLSW9PZ7rPY/1jvxdoznTWH
         8psGH2zOVzSmFu4nDS+rZ/zmDEzgB/GOJsVJB7JFaeHzvuxaVmWLHKZ+y2JFIyN1XHGT
         AtoDCisL/8myAY0TdHDuc4TnMHUjlgb28llISxjJKcF9iEwC054T+BS/XFx0F/k9uTli
         ldx1Z/Ny9wYCZySCfJFpK2VdhwRzTD3oftt5E9JTIXtccejDVnoYsjB43pSwCWAdv+VE
         U0cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W2VpTqt7;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b139si10497415pfb.38.2019.06.17.05.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W2VpTqt7;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=SrlBfglV2hFr71vKq82TSTUn2RS300iWsrC5HG0Yr4o=; b=W2VpTqt7EskSNl6OuXPvH3bTWa
	Oxg4VSsFhUtYN/smPPmJ/TmFjbu6FrvzGufjEzmKE0uOJrxOjmjRrjYb/YHVyc13wqj4131sLqdMW
	Di83pcGzCmYLYtdJivugv1+KG0NJ3i0vHj4cqwGx6dLona+c6BJTgo+6AyG47cNDxzrOuhEbFZgta
	sSTuRxsX8hlFCFBDHEQVB7HhiHPeE6HZ+5YwoMol64nHRFYkCX0Sca+lcM6aXnuI41SjltLH0lSfU
	X9k4JK6mamu83Z+QHUj8CXn+SiW++AFS5aMwKTYRlnBMa8VbjP/mTavSO9PsG15HZSuj3gzWVrqZT
	Th+7BvSw==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjv-0000AI-IK; Mon, 17 Jun 2019 12:27:59 +0000
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
Subject: [PATCH 10/25] memremap: lift the devmap_enable manipulation into devm_memremap_pages
Date: Mon, 17 Jun 2019 14:27:18 +0200
Message-Id: <20190617122733.22432-11-hch@lst.de>
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

Just check if there is a ->page_free operation set and take care of the
static key enable, as well as the put using device managed resources.
Also check that a ->page_free is provided for the pgmaps types that
require it, and check for a valid type as well while we are at it.

Note that this also fixes the fact that hmm never called
dev_pagemap_put_ops and thus would leave the slow path enabled forever,
even after a device driver unload or disable.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/nvdimm/pmem.c | 23 +++--------------
 include/linux/mm.h    | 10 --------
 kernel/memremap.c     | 57 ++++++++++++++++++++++++++-----------------
 mm/hmm.c              |  2 --
 4 files changed, 39 insertions(+), 53 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 469a0f5b3380..85364c59c607 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -342,11 +342,6 @@ static void pmem_release_disk(void *__pmem)
 	put_disk(pmem->disk);
 }
 
-static void pmem_release_pgmap_ops(void *__pgmap)
-{
-	dev_pagemap_put_ops();
-}
-
 static void pmem_pagemap_page_free(struct page *page, void *data)
 {
 	wake_up_var(&page->_refcount);
@@ -358,16 +353,6 @@ static const struct dev_pagemap_ops fsdax_pagemap_ops = {
 	.cleanup		= pmem_pagemap_cleanup,
 };
 
-static int setup_pagemap_fsdax(struct device *dev, struct dev_pagemap *pgmap)
-{
-	dev_pagemap_get_ops();
-	if (devm_add_action_or_reset(dev, pmem_release_pgmap_ops, pgmap))
-		return -ENOMEM;
-	pgmap->type = MEMORY_DEVICE_FS_DAX;
-	pgmap->ops = &fsdax_pagemap_ops;
-	return 0;
-}
-
 static int pmem_attach_disk(struct device *dev,
 		struct nd_namespace_common *ndns)
 {
@@ -423,8 +408,8 @@ static int pmem_attach_disk(struct device *dev,
 	pmem->pfn_flags = PFN_DEV;
 	pmem->pgmap.ref = &q->q_usage_counter;
 	if (is_nd_pfn(dev)) {
-		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
-			return -ENOMEM;
+		pmem->pgmap.type = MEMORY_DEVICE_FS_DAX;
+		pmem->pgmap.ops = &fsdax_pagemap_ops;
 		addr = devm_memremap_pages(dev, &pmem->pgmap);
 		pfn_sb = nd_pfn->pfn_sb;
 		pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
@@ -436,8 +421,8 @@ static int pmem_attach_disk(struct device *dev,
 	} else if (pmem_should_map_pages(dev)) {
 		memcpy(&pmem->pgmap.res, &nsio->res, sizeof(pmem->pgmap.res));
 		pmem->pgmap.altmap_valid = false;
-		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
-			return -ENOMEM;
+		pmem->pgmap.type = MEMORY_DEVICE_FS_DAX;
+		pmem->pgmap.ops = &fsdax_pagemap_ops;
 		addr = devm_memremap_pages(dev, &pmem->pgmap);
 		pmem->pfn_flags |= PFN_MAP;
 		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..edcf2b821647 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -921,8 +921,6 @@ static inline bool is_zone_device_page(const struct page *page)
 #endif
 
 #ifdef CONFIG_DEV_PAGEMAP_OPS
-void dev_pagemap_get_ops(void);
-void dev_pagemap_put_ops(void);
 void __put_devmap_managed_page(struct page *page);
 DECLARE_STATIC_KEY_FALSE(devmap_managed_key);
 static inline bool put_devmap_managed_page(struct page *page)
@@ -969,14 +967,6 @@ static inline bool is_pci_p2pdma_page(const struct page *page)
 #endif /* CONFIG_PCI_P2PDMA */
 
 #else /* CONFIG_DEV_PAGEMAP_OPS */
-static inline void dev_pagemap_get_ops(void)
-{
-}
-
-static inline void dev_pagemap_put_ops(void)
-{
-}
-
 static inline bool put_devmap_managed_page(struct page *page)
 {
 	return false;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index ba7156bd52d1..7272027fbdd7 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -17,6 +17,35 @@ static DEFINE_XARRAY(pgmap_array);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
+#ifdef CONFIG_DEV_PAGEMAP_OPS
+DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
+EXPORT_SYMBOL(devmap_managed_key);
+static atomic_t devmap_enable;
+
+static void dev_pagemap_put_ops(void *data)
+{
+	if (atomic_dec_and_test(&devmap_enable))
+		static_branch_disable(&devmap_managed_key);
+}
+
+static int dev_pagemap_get_ops(struct device *dev, struct dev_pagemap *pgmap)
+{
+	if (!pgmap->ops->page_free) {
+		WARN(1, "Missing page_free method\n");
+		return -EINVAL;
+	}
+
+	if (atomic_inc_return(&devmap_enable) == 1)
+		static_branch_enable(&devmap_managed_key);
+	return devm_add_action_or_reset(dev, dev_pagemap_put_ops, NULL);
+}
+#else
+static int dev_pagemap_get_ops(struct device *dev, struct dev_pagemap *pgmap)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_DEV_PAGEMAP_OPS */
+
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
 vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
 		       unsigned long addr,
@@ -190,6 +219,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		return ERR_PTR(-EINVAL);
 	}
 
+	if (pgmap->type != MEMORY_DEVICE_PCI_P2PDMA) {
+		error = dev_pagemap_get_ops(dev, pgmap);
+		if (error)
+			return ERR_PTR(error);
+	}
+
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
 		- align_start;
@@ -356,28 +391,6 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 EXPORT_SYMBOL_GPL(get_dev_pagemap);
 
 #ifdef CONFIG_DEV_PAGEMAP_OPS
-DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
-EXPORT_SYMBOL(devmap_managed_key);
-static atomic_t devmap_enable;
-
-/*
- * Toggle the static key for ->page_free() callbacks when dev_pagemap
- * pages go idle.
- */
-void dev_pagemap_get_ops(void)
-{
-	if (atomic_inc_return(&devmap_enable) == 1)
-		static_branch_enable(&devmap_managed_key);
-}
-EXPORT_SYMBOL_GPL(dev_pagemap_get_ops);
-
-void dev_pagemap_put_ops(void)
-{
-	if (atomic_dec_and_test(&devmap_enable))
-		static_branch_disable(&devmap_managed_key);
-}
-EXPORT_SYMBOL_GPL(dev_pagemap_put_ops);
-
 void __put_devmap_managed_page(struct page *page)
 {
 	int count = page_ref_dec_return(page);
diff --git a/mm/hmm.c b/mm/hmm.c
index ec3bf2c5c699..0add50944d64 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1412,8 +1412,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	void *result;
 	int ret;
 
-	dev_pagemap_get_ops();
-
 	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
 	if (!devmem)
 		return ERR_PTR(-ENOMEM);
-- 
2.20.1

