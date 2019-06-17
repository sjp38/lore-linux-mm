Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11C86C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF34F2084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nUM3O0j+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF34F2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 649DE8E0003; Mon, 17 Jun 2019 08:27:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D1BD8E0001; Mon, 17 Jun 2019 08:27:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C0538E0006; Mon, 17 Jun 2019 08:27:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07A218E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:27:46 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id u10so5895497plq.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:27:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GMyD4ZeUwEyX4TLbYH+teiOZCsmaS5so5bsDBHXs5VU=;
        b=C85Uc63mkFZ7a9qxRcf4JYW2tX680DhCRaA1JsaYBYNNRzQTKj432Ltodr5Cfo5MM0
         +nl673ppQEmK9Qwr1WQ838xYZF44K7cr8iqfyXdWiEs2MrASMoslgz81E3gZ3/2G1HCQ
         xNGvQVBOf5WgacoqLSiYV7F/NidF1b43DSLFqhg4M/cbayW9HHYgHBh18I6ivP2oAUN/
         BAmqrNgZOL7jzEt0086DsWKH9OV7Ury6TfjPgJNz6Ozjow7ZhRMix7S/E9DyRFUb/o/u
         fJkP9/afHind14XAat0drhp1dqzyWlp4tNxA0P4OuUzFKfXYkJPPDjxfEwxYXT4QErHq
         RUSw==
X-Gm-Message-State: APjAAAUUJz+ktOzA00xKPq3qwK3wJHYA3W8BixOUGRa8HQWzWsbs+u0f
	0F+hbRasLwWvA8RJntkjFdvVCiMowtUxmPeVUci/CoXlo7Js6pC/2cM8caw/Nkazdo5wv3ipUd1
	osCNvZY2cPmdShjcCReKIk01DZXzGWsCR7qVlG0PwE3S8UL2NbhLjk9qdUxY/1As=
X-Received: by 2002:a63:de53:: with SMTP id y19mr48787289pgi.166.1560774465546;
        Mon, 17 Jun 2019 05:27:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzY0bk4bUwHt3vHBgHyLvXqKiAOktx7NpO8urNZDkM1LC02Qj9hSPB2IajDQZGPTC0X+kYh
X-Received: by 2002:a63:de53:: with SMTP id y19mr48787240pgi.166.1560774464725;
        Mon, 17 Jun 2019 05:27:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774464; cv=none;
        d=google.com; s=arc-20160816;
        b=0WUuLkGaq4C9KewN3bsBeEnH08gym05a01ao830oo4Mx0PISMaCDvYTbVHzzuWFQJL
         Iq+fqeZcFsl5ptT+YEKzf8hjtxynUAXFaV4YQFho6042JJkrYHIVt6+23h/i8kDXIC79
         9biCoPcpiKh/PKa9grBX6PyGqGu3j3enhsz6i+gOOplw6Xtr/nRyC4t1ZeSe5el222TD
         TLVt1Q7jPCaDrHVFyFzN//ZW21CQQoY+Ym39+HXR96LMEDJKaL8NlYizUzTnIje7roa6
         Bw3MaBlaetqmLVKPBfhnk+UlrWS2yv8n4iGk1uPqzf6Ryt3sgxW0EPdDHKECszsg9PIh
         e9IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GMyD4ZeUwEyX4TLbYH+teiOZCsmaS5so5bsDBHXs5VU=;
        b=BwKLlPmXSBABMQfBKchdqfVBe4bCJQRpa9ATlK/zZCNJliLsDGJZwO3p+M5fPy2LXx
         SeGxiAVcCg67wMTMfGd9JYk7JgcwwOwU1zYT7yic2IsgTZUThON5xM4QEYaGcpfKLgFf
         S5CUZupLYnr/WfLwyri+lE4JWtbkXzeonHrUDLXEhyGwE47+9lA0YyE4WyKMOQil5TGW
         50L5KhGroPAZfY0IVsT+XDoIaP6biaowdIJ+rWQLC4FeoKeK+RSh1tNf9fVw0goXOX0/
         K84SpV47ub1QV1XlvuQhQ217XYKToscOo1t34ah53dHlxAkhfU3AasJ6oKocRyqa0g/D
         VcOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nUM3O0j+;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b92si10355956pjc.17.2019.06.17.05.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:27:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nUM3O0j+;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=GMyD4ZeUwEyX4TLbYH+teiOZCsmaS5so5bsDBHXs5VU=; b=nUM3O0j+v0YkuO+grtlLfHPwaH
	cV0WhQAmaitlmE6ROwsIKJCV/PlKqUn+0O2EWB1Hs1nEpKWW8txqk2fddXoiLre+dVvw9bHopOPj/
	gxJDRUoHl+//i7XrIMZT3FKhCTu/PdfOYJCLGgo7rTAcjPqy99/URAGv7WeM7qn8F0aLO8QPfe2cq
	07WYX982utWhvOtWHTzi5gbbLN1LvS1/WFqavQ6hw3qVrjla8/wu9w23XyHgB/5OiA5nsWfl2v27L
	xDnS8fKvcYcw4DwESFtDIxH0HLpADpbP4XBoQFGVGvrc38bZlNIwtghm8E94lATBAXFDfzbvWHgJL
	wMPWcrTA==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjd-0008Kg-IT; Mon, 17 Jun 2019 12:27:41 +0000
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
Subject: [PATCH 02/25] mm: remove the struct hmm_device infrastructure
Date: Mon, 17 Jun 2019 14:27:10 +0200
Message-Id: <20190617122733.22432-3-hch@lst.de>
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

This code is a trivial wrapper around device model helpers, which
should have been integrated into the driver device model usage from
the start.  Assuming it actually had users, which it never had since
the code was added more than 1 1/2 years ago.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 20 ------------
 mm/hmm.c            | 80 ---------------------------------------------
 2 files changed, 100 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 7007123842ba..c92f353d701a 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -753,26 +753,6 @@ static inline unsigned long hmm_devmem_page_get_drvdata(const struct page *page)
 {
 	return page->hmm_data;
 }
-
-
-/*
- * struct hmm_device - fake device to hang device memory onto
- *
- * @device: device struct
- * @minor: device minor number
- */
-struct hmm_device {
-	struct device		device;
-	unsigned int		minor;
-};
-
-/*
- * A device driver that wants to handle multiple devices memory through a
- * single fake device can use hmm_device to do so. This is purely a helper and
- * it is not strictly needed, in order to make use of any HMM functionality.
- */
-struct hmm_device *hmm_device_new(void *drvdata);
-void hmm_device_put(struct hmm_device *hmm_device);
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 #else /* IS_ENABLED(CONFIG_HMM) */
 static inline void hmm_mm_destroy(struct mm_struct *mm) {}
diff --git a/mm/hmm.c b/mm/hmm.c
index 4c770a734c0d..f3350fc567ab 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1525,84 +1525,4 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 	return devmem;
 }
 EXPORT_SYMBOL_GPL(hmm_devmem_add_resource);
-
-/*
- * A device driver that wants to handle multiple devices memory through a
- * single fake device can use hmm_device to do so. This is purely a helper
- * and it is not needed to make use of any HMM functionality.
- */
-#define HMM_DEVICE_MAX 256
-
-static DECLARE_BITMAP(hmm_device_mask, HMM_DEVICE_MAX);
-static DEFINE_SPINLOCK(hmm_device_lock);
-static struct class *hmm_device_class;
-static dev_t hmm_device_devt;
-
-static void hmm_device_release(struct device *device)
-{
-	struct hmm_device *hmm_device;
-
-	hmm_device = container_of(device, struct hmm_device, device);
-	spin_lock(&hmm_device_lock);
-	clear_bit(hmm_device->minor, hmm_device_mask);
-	spin_unlock(&hmm_device_lock);
-
-	kfree(hmm_device);
-}
-
-struct hmm_device *hmm_device_new(void *drvdata)
-{
-	struct hmm_device *hmm_device;
-
-	hmm_device = kzalloc(sizeof(*hmm_device), GFP_KERNEL);
-	if (!hmm_device)
-		return ERR_PTR(-ENOMEM);
-
-	spin_lock(&hmm_device_lock);
-	hmm_device->minor = find_first_zero_bit(hmm_device_mask, HMM_DEVICE_MAX);
-	if (hmm_device->minor >= HMM_DEVICE_MAX) {
-		spin_unlock(&hmm_device_lock);
-		kfree(hmm_device);
-		return ERR_PTR(-EBUSY);
-	}
-	set_bit(hmm_device->minor, hmm_device_mask);
-	spin_unlock(&hmm_device_lock);
-
-	dev_set_name(&hmm_device->device, "hmm_device%d", hmm_device->minor);
-	hmm_device->device.devt = MKDEV(MAJOR(hmm_device_devt),
-					hmm_device->minor);
-	hmm_device->device.release = hmm_device_release;
-	dev_set_drvdata(&hmm_device->device, drvdata);
-	hmm_device->device.class = hmm_device_class;
-	device_initialize(&hmm_device->device);
-
-	return hmm_device;
-}
-EXPORT_SYMBOL(hmm_device_new);
-
-void hmm_device_put(struct hmm_device *hmm_device)
-{
-	put_device(&hmm_device->device);
-}
-EXPORT_SYMBOL(hmm_device_put);
-
-static int __init hmm_init(void)
-{
-	int ret;
-
-	ret = alloc_chrdev_region(&hmm_device_devt, 0,
-				  HMM_DEVICE_MAX,
-				  "hmm_device");
-	if (ret)
-		return ret;
-
-	hmm_device_class = class_create(THIS_MODULE, "hmm_device");
-	if (IS_ERR(hmm_device_class)) {
-		unregister_chrdev_region(hmm_device_devt, HMM_DEVICE_MAX);
-		return PTR_ERR(hmm_device_class);
-	}
-	return 0;
-}
-
-device_initcall(hmm_init);
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-- 
2.20.1

