Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49B88C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 068E3204FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TYyr8+iI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 068E3204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B4E28E0009; Wed, 26 Jun 2019 08:27:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53D3A8E0002; Wed, 26 Jun 2019 08:27:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 408CC8E000C; Wed, 26 Jun 2019 08:27:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E15A18E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:39 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y5so1652875pfb.20
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rGvR8Y3VXb8jN+vdsmRnpGP1SMJpLPi/itvVIHyAWXU=;
        b=KRPp+B0UMxRw/U7+swTQEeSqRNwZ2MBTIo3tYNDpmMK4Uxs2TmbOOjOU8pxXWNtlqZ
         L0UKc1nmej28TG6SYzDDGKtDGOG16YfYblTIvYEyTPX9KFtsZ4T3jQ26Eyr99XZCieYD
         buy0JmFD0Y5SulQhjjT7LBOb7PG0cXZIrgm//uOtkgRQDTxaEWSGiBRHgzGyPPUXfnOo
         Ziag92Ix573fY+R6+9lLphsl5Fr3GsC60dEDADQYskOxn0p//y1JkZlMK4thDL+aJZFj
         A7jSB1i6gG7NScSE7rM6KyHJTQawI/YQUk80LL/TihLDIxoL2GWtX57cAKpBFqL5R6WB
         tFbA==
X-Gm-Message-State: APjAAAXLRFbagMsEvA/idA8/yP4I1rnL9aZ3WWqD5kN9MEwHM0acfS6M
	b/Al4ZELCZba3TDJeousJQfLL+kq6jmzYg83+bDkK+/018yYCmETIVJC7SroH3asWHxxcC5VF9E
	HhLf3PG1lWjIeMfjJZqnMotDyOEEgwdskDmUw0Tsgbj49KZd4luIotmZeEme88Ws=
X-Received: by 2002:a17:90a:3270:: with SMTP id k103mr4331355pjb.54.1561552059576;
        Wed, 26 Jun 2019 05:27:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVKRJDE2NkbkZcF73H8+l+D/O2tFIoYknMZ76wChJEwNPwc7Cbjv9PM3LHh6Io3cW23ap+
X-Received: by 2002:a17:90a:3270:: with SMTP id k103mr4331299pjb.54.1561552058716;
        Wed, 26 Jun 2019 05:27:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552058; cv=none;
        d=google.com; s=arc-20160816;
        b=yYKA/4GWE+FYFijbI7NJW0+POLz7frGRMpoomllXu05w/3UIiTnP7RShEPWa4sxgZa
         +7MfRLWET2Bu63QlMecdm4TKZzrcfcYwetVk2MOo0olr4FEb0erqQpVE9se0gKtN/Ufq
         hufyeQC0DOV5L0hRHBn1yDQYNYRJvfz26N0rDJyVLOy0M1Hho9nyc6e+2vIqopgaLPat
         BMucVnzNjrfgI3vhe8KyLvHE83C0Hi1/ICw1QNduS5Reihr3VNAWEMfHQBpno9x1rrcF
         js04kzCdA8LaZj4XVnnQEJuRgnNVkIB2yTS1S18vLRJINcSo0v2GeKnMzxRzvsUqjUUp
         IZDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rGvR8Y3VXb8jN+vdsmRnpGP1SMJpLPi/itvVIHyAWXU=;
        b=cDsLRmjFZWRD2YrFY9cSNIbbC8WeWnyECqvF7UZm/J5e4UsJfO7JFoGcmil1zdsWQe
         a3k5njL02t8j1VOuk9fpdRxTW2om1LNAtHViYwrW2CSgNYWMAbhBAZZ+n7oZxjRHiwC2
         31hyODcrTufit/76UngQ3EoJiZLTiQ0gPy75M9kizTjqyS9tKS6NI1xeChKjnZ5cYSn4
         uRL+GQQfPtSTm9k+kt1Wnabye91r1fk3+zwJ966FY/c2dFy+jgYAP+PEP3cBb8WHKajN
         kTkFSRLR1L5oyz9YMpeKYZZQXwV1+XKOgLYw+41xldWwU4lNQidOm01Thjl8sv2M31K9
         dvLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TYyr8+iI;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l1si16163461pgi.278.2019.06.26.05.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TYyr8+iI;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=rGvR8Y3VXb8jN+vdsmRnpGP1SMJpLPi/itvVIHyAWXU=; b=TYyr8+iIscH+GbFojbkVfsiLy/
	6V8UUXvizUy8y3RPIBP8D9fnAAWP1Qp3sQ0sR+7bkQT1JQTmAlVGgzV+v5fI+1/jsOTIaD9g9Nlt5
	eCg4w7LDJEp3UasjTwmhklZTb1RKuStpx3O6WBj284yuzSZ465ORbD41rf5TlpnjWseyj/9ZGWUX0
	jqEcyt7u3QkIFSnlYttTQKFW4z74J/M3DrSAahyhlWyJz59xYJo/uIeeQJH4OkHQ1zhCjJF4xHu8+
	OrPQl82tMjsj6r5fhLBWxDUhgn578TysCuob8uYDDrRMv8kZyxSJieY3eDm5K6J4NdLz48vrSb/oq
	+rsECRcw==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71Q-0001L5-OE; Wed, 26 Jun 2019 12:27:33 +0000
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
Date: Wed, 26 Jun 2019 14:27:01 +0200
Message-Id: <20190626122724.13313-3-hch@lst.de>
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
index 044a36d7c3f8..99765be3284d 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -751,26 +751,6 @@ static inline unsigned long hmm_devmem_page_get_drvdata(const struct page *page)
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
index f702a3895d05..00cc642b3d7e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1528,84 +1528,4 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
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

