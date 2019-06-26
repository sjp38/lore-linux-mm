Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BED0DC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7794520663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nIyI1gI2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7794520663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DC418E0011; Wed, 26 Jun 2019 08:27:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 516818E000E; Wed, 26 Jun 2019 08:27:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DF348E0011; Wed, 26 Jun 2019 08:27:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE3448E000E
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:55 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a20so1656960pfn.19
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mt4+zc9IpSRPEzC4cMWHk/yq2yqrTYKLdoT+AMW6Qz8=;
        b=MbJmMk00PYpPgp48Fc5BnOaL20WshYdFl5NiX0dMYT8eeiQS5DYAYc7Vp0Xv8vcIXg
         ySh9lFAuHhuvt9/wY+RJ3p3ddu5HQkpq7zWBLCdHQCQSdOafjaaN+p8Bp8YF1CmlYRop
         FW9L0RTwvxRqU3oKMMOASNC901bLPpIpGre49t3g1IL/tAl0xjYr5CSD5bXzAyPqd5Om
         ZshWF60IzWXOiFtF7vwWWClA3SG93CBi7QXEDBDInnwvw9uFO1bTgR3UWp2pfZz7H3tb
         tWebQ9dLCnqnM1ysnT4uq/r3GGEIZ5+2vNes8ddZ0nL47QUdHQYvJuq+is3HmAa8zplM
         HwvA==
X-Gm-Message-State: APjAAAU7mn6/lZxy7/Tqw43bVXtCrzreh9My/3gNAr1hdQCukOcPrOdp
	q2DHIJkmIJzfPNPNR4VGknvk3cfYRxqgDrSTeqR8k7UHtIhL2vE+Vcm7mbb4NaGfc37RnfRCn5u
	gJ6mzIwEV0UILdIUumtpaRqVm0h3B6aj+oc6G/+Qu/GafimsVR3KoY2kZu55fAiE=
X-Received: by 2002:a65:64d5:: with SMTP id t21mr2800065pgv.310.1561552075522;
        Wed, 26 Jun 2019 05:27:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyipwSjSJEB4iMLRVxjBSB0iJmdwrf1FF8FL6TsQWNvhY3lbjzXzgucKzjg9msj12dRR/sS
X-Received: by 2002:a65:64d5:: with SMTP id t21mr2799987pgv.310.1561552074489;
        Wed, 26 Jun 2019 05:27:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552074; cv=none;
        d=google.com; s=arc-20160816;
        b=udnfcbSLFc50lis/yjJv4A1TYl+CdXJ7ecTFHuE6KTcoOKkut5exdcySzJmFAha3SO
         HnIi52+WTMzzelgfoMGFmnaSRJOJfBs5172Tmb4rl3ZjTKVfmLPvTLtlzH89u1rD/QDk
         aRreELfbx1L4OJwSRxrA1cHOfbDJGY/H/wCDe8CX4d9QUEnZ/9qOdJ9+uQWGNFLHy5qd
         5B0D3qfKnFRErUk1AMq0fSxqQe8xPzwPrgqSn/5+uuhJc80l6+yjUyxFIzOL5dOAo5BG
         MD3XSVDUCxpcQrmZZuy2/BFOKfvPDwVAdbKTSIHSwXq35CU75wV1dZp1GlqeK+YEtiXh
         vdOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=mt4+zc9IpSRPEzC4cMWHk/yq2yqrTYKLdoT+AMW6Qz8=;
        b=sEc+l7miZKlXGpHCYbCFhCgWKUJ+RaCfPqEJW9MNYAPptwz7F/+Pqaz/Ua/Ic/MYKK
         AmaIbX14uksCeq56j31zXhbOfItwisnx25iTpybSQvJv8b04AprTlITZiYUycGEwC4iZ
         fwI/OQW7jbSZaB3R437jMKCJuMvtjOkpnz7lDr+8yJSLkj5C/LjMqSTrEKicxzbsUt8w
         4/wBcedTPMGWtrx6nsgFqPdYe9jb8vUQk/3w+pacm6OslZMUAr2pMNyJ5q5jlfJaTprj
         pv2Vh9VCD2MB1aF98M3RZNnEHQLbnogoDZIrxKp1hLfjgFnJ/cmjCbLRNjVuiB1F7UPe
         ZE2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nIyI1gI2;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l70si1895402pje.68.2019.06.26.05.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nIyI1gI2;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=mt4+zc9IpSRPEzC4cMWHk/yq2yqrTYKLdoT+AMW6Qz8=; b=nIyI1gI2JcHVUXx+jXX71rKB3G
	/XpA3ZY5LzkiUTJN1oA3IOdt45tcLua2Uy9FyFVXuJC0c5X8BBMzJA41qG8Y99gIfd1C7GCe5DJJd
	Eh4lgGJ1X6o41RIhoOM0BBJxaETP/8Mj5RBgQ4DP+G9fpKqnG1rQdi0mwUTQbrIxb0bsPbFo13NwX
	3xAPRn8oGEMHUyvDW6xdgV80ocjOn88UacI1mjEwcsiAmQWvtKLIFqBidgTpW2fUibEQblL5U/xpS
	usb6ODdl6HifjRKkjVSSirZqtJMju39OzLvmokEvgVxm3ops4idZHit93FdxRmcFIOpreUIAMWn0V
	9GJBgs0A==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71e-0001MX-8g; Wed, 26 Jun 2019 12:27:46 +0000
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
Subject: [PATCH 07/25] mm: factor out a devm_request_free_mem_region helper
Date: Wed, 26 Jun 2019 14:27:06 +0200
Message-Id: <20190626122724.13313-8-hch@lst.de>
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

Keep the physical address allocation that hmm_add_device does with the
rest of the resource code, and allow future reuse of it without the hmm
wrapper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/ioport.h |  2 ++
 kernel/resource.c      | 39 +++++++++++++++++++++++++++++++++++++++
 mm/hmm.c               | 33 ++++-----------------------------
 3 files changed, 45 insertions(+), 29 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index dd961882bc74..a02b290ca08a 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -285,6 +285,8 @@ static inline bool resource_overlaps(struct resource *r1, struct resource *r2)
        return (r1->start <= r2->end && r1->end >= r2->start);
 }
 
+struct resource *devm_request_free_mem_region(struct device *dev,
+		struct resource *base, unsigned long size);
 
 #endif /* __ASSEMBLY__ */
 #endif	/* _LINUX_IOPORT_H */
diff --git a/kernel/resource.c b/kernel/resource.c
index 158f04ec1d4f..d22423e85cf8 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -1628,6 +1628,45 @@ void resource_list_free(struct list_head *head)
 }
 EXPORT_SYMBOL(resource_list_free);
 
+#ifdef CONFIG_DEVICE_PRIVATE
+/**
+ * devm_request_free_mem_region - find free region for device private memory
+ *
+ * @dev: device struct to bind the resource to
+ * @size: size in bytes of the device memory to add
+ * @base: resource tree to look in
+ *
+ * This function tries to find an empty range of physical address big enough to
+ * contain the new resource, so that it can later be hotplugged as ZONE_DEVICE
+ * memory, which in turn allocates struct pages.
+ */
+struct resource *devm_request_free_mem_region(struct device *dev,
+		struct resource *base, unsigned long size)
+{
+	resource_size_t end, addr;
+	struct resource *res;
+
+	size = ALIGN(size, 1UL << PA_SECTION_SHIFT);
+	end = min_t(unsigned long, base->end, (1UL << MAX_PHYSMEM_BITS) - 1);
+	addr = end - size + 1UL;
+
+	for (; addr > size && addr >= base->start; addr -= size) {
+		if (region_intersects(addr, size, 0, IORES_DESC_NONE) !=
+				REGION_DISJOINT)
+			continue;
+
+		res = devm_request_mem_region(dev, addr, size, dev_name(dev));
+		if (!res)
+			return ERR_PTR(-ENOMEM);
+		res->desc = IORES_DESC_DEVICE_PRIVATE_MEMORY;
+		return res;
+	}
+
+	return ERR_PTR(-ERANGE);
+}
+EXPORT_SYMBOL_GPL(devm_request_free_mem_region);
+#endif /* CONFIG_DEVICE_PRIVATE */
+
 static int __init strict_iomem(char *str)
 {
 	if (strstr(str, "relaxed"))
diff --git a/mm/hmm.c b/mm/hmm.c
index e7dd2ab8f9ab..48574f8485bb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -25,8 +25,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
-
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
@@ -1408,7 +1406,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 				  unsigned long size)
 {
 	struct hmm_devmem *devmem;
-	resource_size_t addr;
 	void *result;
 	int ret;
 
@@ -1430,32 +1427,10 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	if (ret)
 		return ERR_PTR(ret);
 
-	size = ALIGN(size, PA_SECTION_SIZE);
-	addr = min((unsigned long)iomem_resource.end,
-		   (1UL << MAX_PHYSMEM_BITS) - 1);
-	addr = addr - size + 1UL;
-
-	/*
-	 * FIXME add a new helper to quickly walk resource tree and find free
-	 * range
-	 *
-	 * FIXME what about ioport_resource resource ?
-	 */
-	for (; addr > size && addr >= iomem_resource.start; addr -= size) {
-		ret = region_intersects(addr, size, 0, IORES_DESC_NONE);
-		if (ret != REGION_DISJOINT)
-			continue;
-
-		devmem->resource = devm_request_mem_region(device, addr, size,
-							   dev_name(device));
-		if (!devmem->resource)
-			return ERR_PTR(-ENOMEM);
-		break;
-	}
-	if (!devmem->resource)
-		return ERR_PTR(-ERANGE);
-
-	devmem->resource->desc = IORES_DESC_DEVICE_PRIVATE_MEMORY;
+	devmem->resource = devm_request_free_mem_region(device, &iomem_resource,
+			size);
+	if (IS_ERR(devmem->resource))
+		return ERR_CAST(devmem->resource);
 	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
 	devmem->pfn_last = devmem->pfn_first +
 			   (resource_size(devmem->resource) >> PAGE_SHIFT);
-- 
2.20.1

