Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 955EEC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 514492173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QwHN3Ivc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 514492173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECD7A6B000E; Thu, 13 Jun 2019 05:43:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE21D6B0010; Thu, 13 Jun 2019 05:43:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B730E6B0266; Thu, 13 Jun 2019 05:43:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 705BB6B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j26so13472745pgj.6
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:43:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=U+naUp6GJ2c/vfJkCwMO0IpliZVzAgQ1geAwtt/0bck=;
        b=pWs2oiQ8VvYebTpOkS1nCeh30EfRc65w1TpAirZopRuHcOr0BCKDZrcolG9gcko5ex
         i5GgpVuKCH/9m2smB3DCr3ifqxnCDaDQRx/xRO9/ajGJO29MDPdyrRbIt4+15wxlq9DM
         MDgPqdUYAyLh5NMqzsmCm8hH/erbP7SA9drGZWmtj0WCyJmg5+q3VHAOaZ+P1ZiKGb5/
         YF6hmSU5u+VmZr+JAnjwIEnEAc7g4WiFbLsixYQqBgRwonpZVerLvPVCRPnR9o+20VK+
         r1hYRrAVPgJNKUWoaVUlQxevjYSpUID7xfakEZDYx9/nOtMCKfBeYv0qXkGwE1Bew7ZL
         LkFA==
X-Gm-Message-State: APjAAAX1QZgLRytWa9CuRLD/9NA+YUaD2HAOB4//32a56AoPxEx072MK
	2HYPs71cWZMohfoUoRbJj7+3OSIe3aGiOkSBnzG2NeTXrueE+IumRk+jbScd7Xp4ZXBKyHvgTRM
	2iaQcC7+C16yLSNNHrzt1XZSupk6jesm6YrF+z0nr+lEmFEVb1P6sAe4mhYQcl9w=
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr84862002pla.33.1560419030114;
        Thu, 13 Jun 2019 02:43:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLjnhGgpcjVJuR/9513zF9olHZVP3cA6F0+a6kaBbGaLErXVs5OLucSXr+HAqWxqaNp4XY
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr84861915pla.33.1560419029360;
        Thu, 13 Jun 2019 02:43:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419029; cv=none;
        d=google.com; s=arc-20160816;
        b=C0T4sCp1Ukus3qxCQ1EAmpHE9srL0/CeOJ7C9b0JfKBUUBd3pVDt5VLONcJuqjtQ1d
         gvXpL7W4GH0WwLkOPYJ7yRIbtwpyhp+wAtX3PxsqwlOtec26b+CGE/gLYWHf1H8/JKix
         HKztxVFhY7HXYlExXZmc0ZEB+2JxfmDbibpQ5qO1sHFeSQw3/sdLQ7NZqoZZ07PJJI5v
         MMRHbO8GIPh/zqn+ARVmA5ddA+Qn7n0P9srlPcTR5d+fojeOW47flZ8GEeEaYKyFm2fA
         a8R6IRfe0w9pS3PwezT+2lw2mox/ym+AR2ZrBisK4laG1vrUH3fYy+gMd3kX7xrwHszQ
         2JBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=U+naUp6GJ2c/vfJkCwMO0IpliZVzAgQ1geAwtt/0bck=;
        b=ixPvnUX4uYHgwBoR02m1pE1Id31hyo5nAWgxlZdPTkzvaNXcvBSVtourV/TYgiG5Gw
         dRjFK2Yk4p7VORRkHfyt9hzgT62R7JoM4SXcWGgA8HqKfVgv5W0P3kwHoFXnfdn02tct
         DTBDnz8kbIj+Pxt5c1ROwWI9qQ3lpRZHfv3OhqfLabEaFjSt+MnbZ458nFnWwZ5E7No7
         mQhcbnDfko8TtpnG9AfFOUIEqRL7jBQAH+e2D8A61l8BovHTWNTs/TdTSLLHI8bblG23
         V/bZGlBPfUMOpmgEyagnRXzkP/N05W11Ti99/j0hbpo/tbTyBomvTXhzuN2TnZjEM5QK
         1/sg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QwHN3Ivc;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j59si2483235plb.176.2019.06.13.02.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:43:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QwHN3Ivc;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=U+naUp6GJ2c/vfJkCwMO0IpliZVzAgQ1geAwtt/0bck=; b=QwHN3Ivc9/431JjZXwTTSF08rO
	hXrz9haLO+d9Q3IUHfpmJTWlt7YXy/NmVHDKKTD/S+hOE4Iu0sImh3ze2ah7uPgw3Ei9X4uKveyn/
	nsmcYq0LFNlYJpg+2os1UWxfhf/0nIJoqy+Sw+YSOCSsLRjhEfzfdB5pljAfNGKYcC0tMcDPRgbPE
	fc5wdASA11vbKRHWzIsWFALeW2JqScCVdyapFn6VpyWwynpkuTmK8WBHg8NlvHxlGwpmm3SGTXN+Q
	yYignYCrY/T0XlMl97q/6sfhwXRxvc26NXzsHK9MeWjhS6x6hjc2xLbTs1LjAwLCYlTdNCmJxrgk4
	fOpj7qYg==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMGo-0001lZ-Cj; Thu, 13 Jun 2019 09:43:46 +0000
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
Subject: [PATCH 06/22] mm: factor out a devm_request_free_mem_region helper
Date: Thu, 13 Jun 2019 11:43:09 +0200
Message-Id: <20190613094326.24093-7-hch@lst.de>
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

Keep the physical address allocation that hmm_add_device does with the
rest of the resource code, and allow future reuse of it without the hmm
wrapper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/ioport.h |  2 ++
 kernel/resource.c      | 39 +++++++++++++++++++++++++++++++++++++++
 mm/hmm.c               | 33 ++++-----------------------------
 3 files changed, 45 insertions(+), 29 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index da0ebaec25f0..76a33ae3bf6c 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -286,6 +286,8 @@ static inline bool resource_overlaps(struct resource *r1, struct resource *r2)
        return (r1->start <= r2->end && r1->end >= r2->start);
 }
 
+struct resource *devm_request_free_mem_region(struct device *dev,
+		struct resource *base, unsigned long size);
 
 #endif /* __ASSEMBLY__ */
 #endif	/* _LINUX_IOPORT_H */
diff --git a/kernel/resource.c b/kernel/resource.c
index 158f04ec1d4f..99c58134ed1c 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -1628,6 +1628,45 @@ void resource_list_free(struct list_head *head)
 }
 EXPORT_SYMBOL(resource_list_free);
 
+#ifdef CONFIG_DEVICE_PRIVATE
+/**
+ * devm_request_free_mem_region - find free region for device private memory
+ *
+ * @dev: device struct to bind the resource too
+ * @size: size in bytes of the device memory to add
+ * @base: resource tree to look in
+ *
+ * This function tries to find an empty range of physical address big enough to
+ * contain the new resource, so that it can later be hotpluged as ZONE_DEVICE
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
index e1dc98407e7b..13a16faf0a77 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -26,8 +26,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
-
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
@@ -1372,7 +1370,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 				  unsigned long size)
 {
 	struct hmm_devmem *devmem;
-	resource_size_t addr;
 	void *result;
 	int ret;
 
@@ -1398,32 +1395,10 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
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

