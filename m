Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0A3CC31E58
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A7D52087F
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JPXmnOG9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A7D52087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22D9D8E0009; Mon, 17 Jun 2019 08:27:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B4E38E0001; Mon, 17 Jun 2019 08:27:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F207C8E0009; Mon, 17 Jun 2019 08:27:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B53568E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:27:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v6so3569264pgh.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:27:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7nriQi4Fr0xgTBcFIe6nSbwkyrDmfJykC6ITRKjgmyg=;
        b=n4Y70A8Rb57VxZnkxpec5M11ZhQtfIrJAy1agGEThpSSH1fTJwqoJrrKFbjwplRJhG
         /u9jwzg+pSyHftj1AL0UpORtFcYmmJ1adRbJiq12abLqjospy1pNjDjrrwneBnYoyFp2
         +ZxEB6Gz4SEeWx58fYNawJRJGFOUneM4tfXviH9/+8Ijyn7QtAnizryelZR8vkC43hX7
         4w5SGhX7uwM2OSjd5AaiuZDs+kkyD9KhlwFYAJqtrL7tfGeKwiDgBFOu3lAAcg1FLPyb
         +ebRdeoXcD6KltN8pgOgg0443Z9eFSyjsz4UqL6IWG11N213p7kTKnjZAlUlHJI3Rex5
         RbZg==
X-Gm-Message-State: APjAAAVe6BSvQMIu/ZFb6lgAbxirCtic44tyJ8aFO2yOomaFU3y3+dHx
	P1FCRfHHxiXINKpZqIcre6AWvN/6Glv3CGWSz2XIWntklBAjI7Q1vXvNLBD89f1fWx99PqL6XlT
	c2l0xq9vR0KE6iGfdXpFno0SXy2YZ4W7C1uy8inYv08E0hQrVit1QRCoCy2FqJaQ=
X-Received: by 2002:aa7:8dd2:: with SMTP id j18mr43812035pfr.88.1560774474758;
        Mon, 17 Jun 2019 05:27:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdN8H651eHy2L+0ZjZbJ2JjO7mImTz3EeleLdDLX88M0jb2dbKgCsEhxyiWvI31wGEq+WE
X-Received: by 2002:aa7:8dd2:: with SMTP id j18mr43811975pfr.88.1560774473694;
        Mon, 17 Jun 2019 05:27:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774473; cv=none;
        d=google.com; s=arc-20160816;
        b=SeHxvOQUCmv1fIlO/9/HJZ31qzML9s6/JgOJcqdH0xQoIn1abuzOrlWzaO4itaj4OP
         ZtOPzD5F2OBrsKIy8uRwwPOMv6qmbzH3km/k3dBKwTlD+JwaOAaFch5CDrkKh7Vqezgw
         /9q81j6gIbEy6/dBa+gyWI68HaaZIT1CZmMzFTv3Pd/wPAfZ0seJOabHBZpOMnTf+37W
         U0pgGQFV1kefpndbLvybpA1a95gwh+it0uwCeRrQiLW6pDk+v2uRG+e5S5qWFf9sCsFZ
         p0q8CAPj5/MApfVnofqsVdLkFxDrSqH4Y1fK8nBYpT8Apb0o3po0VwpMwo7V7x7UfU9r
         6ZNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7nriQi4Fr0xgTBcFIe6nSbwkyrDmfJykC6ITRKjgmyg=;
        b=vR1X072Kaw79z1EF2TsnZjGhyf+V/ZCpZ5mMz1Z6CkCNRs1/x2cHsuwj0o3Wig8chl
         MyI0yjijzw5a7n2qWtrmV3yGk/jnNgI3s2OGpawLhXBrgqelAwo3UGDIZKdTs6JtVvLJ
         aXTQGHKbOhNryHdDg5tR4Zz9nK4AvNGgsY3Z76KF9XIsEG1pxX5EYqaxY/1NtaI9VCLg
         yMGCl7KO4Y+aBSdc9UybgPAZnsxPoyjpJw5fbbforSIdsMwSlVFr+g49w8ai3L/DpHW+
         w4zRpNYJDVF75OSNOe5Sm8XVrfjQqIptNCCB3gOZqj3akytiVJ9WPUWNwHB7xOtzGObt
         Pjqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JPXmnOG9;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o127si11284109pga.593.2019.06.17.05.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:27:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JPXmnOG9;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=7nriQi4Fr0xgTBcFIe6nSbwkyrDmfJykC6ITRKjgmyg=; b=JPXmnOG9f1PEc61lrxbukBEJb8
	kAgyoN6nKfbqF4qgJGeYOSMsnUvVYOiNzN2ELCV9wb331fMUsuDPvIQ2S4r5iVE+JCOIpZVU/ZnK8
	dg10C3MHJYXdAZTmF4BLfxG2dc8Atvw1ja3PcRbuQK5uf0NGUrlWTjZjdUMm+LmT5KZ4mg6dcjzCf
	nA6thuAWoFivx6vFYF6vFwxSQarTAh5reeveHpRf2VHZpvQwxJ0Aubqtm9mIGcUV8G0EMnD/b/Kne
	SuK9ATrScvwfXwUfU3ZjCaF0NF0bDLbzwZtyWHxXaykWVpfZDLI0bYGBnUqh16os+uOXFeWvkX15s
	SRYUphpQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjm-00004r-MH; Mon, 17 Jun 2019 12:27:51 +0000
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
Subject: [PATCH 06/25] mm: factor out a devm_request_free_mem_region helper
Date: Mon, 17 Jun 2019 14:27:14 +0200
Message-Id: <20190617122733.22432-7-hch@lst.de>
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
index 64e788bb1211..172d695dcb8b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -25,8 +25,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
-
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
@@ -1405,7 +1403,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 				  unsigned long size)
 {
 	struct hmm_devmem *devmem;
-	resource_size_t addr;
 	void *result;
 	int ret;
 
@@ -1427,32 +1424,10 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
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

