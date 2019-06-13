Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8571FC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4197C21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hN3Tg/pf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4197C21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E08F66B0006; Thu, 13 Jun 2019 05:43:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1D066B0007; Thu, 13 Jun 2019 05:43:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B21006B000A; Thu, 13 Jun 2019 05:43:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7886B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s4so8648693pgr.3
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:43:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EySscp3yKN+jDnjqTeB/vXgNBmJu+8rQ8w0cniT2gLU=;
        b=OJm9/ZVrt9+mExfi0Buzgte6HdYYyWqNJ3jYC0jd7vZoNkoN1R7L/dHGupap4OnsbL
         esOHWyjl8thUiFSp9eYrfD8GUCPSopzlztl+hfFGG48j56h3qmYIcshGeoxtLO5Brivn
         WyyvgDOTnsHEmKu8mh9GZyKWrDBsaBTbOfg+FXkCOogBx0NB2dtt/80HkuTQb75CuZvD
         od+keT3OiOdXzh+UweFFN4S6IPdFxLh5fQyANE/sFFDYbYiiXt85XByfiGazySMCuLl+
         bcNWXYDKVEt0uA9MLL3hNu8Ci63OOieBkTxJzXMkJl6M+yZDDiYTS34FxQzMWSqlFE0Y
         TrZw==
X-Gm-Message-State: APjAAAW86W19ezFFNQGFjTrgs066iR3fryWVUNsKvAoNbVBXFr6P7FmU
	0cxxRq1aTTfoy6fJq8zLIUp4XdtsxnN8bTF3XV204iCJkET7bm/o0KifKLCRLk6OjQO2U07a6Vq
	5+dfKyLg6NVUKPRD7mwTVY5rQjAAjWTc+IPrEw+tpQd9nQeldJsmZg7DM7BlHUr4=
X-Received: by 2002:a17:90a:bb01:: with SMTP id u1mr3400554pjr.92.1560419019120;
        Thu, 13 Jun 2019 02:43:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLyRlemFFktmGBgyWxpTIuwHlZC1u8gGjgh03/jZVukHCGAmuNW1llIBcSMV31euEQQwX0
X-Received: by 2002:a17:90a:bb01:: with SMTP id u1mr3400453pjr.92.1560419018215;
        Thu, 13 Jun 2019 02:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419018; cv=none;
        d=google.com; s=arc-20160816;
        b=kfV2TwUALLKs6ml6qHluEq1dYrTLSPOFKHQkclWTBZ7lLWuCeabaBNN6Tm7nJi5PzB
         JLD8fdMoVgxN9G0AGlYSZ6q8g/oTpKP7UOjLS2c6i4Lk5f+jqiK1qi/DnPsRHZZYiT8v
         yIGm4uQaMEel+Grqlc/P44fsyoY4Gu5hyTLxZ8UmnYmWoRHjnqZcoM1KyKgeheSdsHS/
         90O96DzQAprVePcQlVSaqU5tl1b4cdZELjj/SHDp7Iku2D9mb6rhgY9xMrBWKXeiTTXu
         MvtNebgEyfyoPoyzLxgGUM01K/GMSLlq8lM8K55iYoSBiZdcAb60+Eq9oxjbRzWopwJb
         8KFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EySscp3yKN+jDnjqTeB/vXgNBmJu+8rQ8w0cniT2gLU=;
        b=RfGna9iO4iPxkS7NGcUCGIAN14wtyY2BI7oGGd0TdEkb8Uv+hd7IY1X3CcnqxnL3Hy
         zJfkD2ShpZXMgPSazOW2usmhdBpZ7Y8F/s3gvUtn1Eih14RPRvplWhZg0i2Dg143pfmE
         zD0GzeW1qBsMEiJ2OtLEuh7RINjCi7pFG4y7uq3DCWpXvSdmUzMCoYKVCphsmiNN52PU
         KzElwlM1uN9fEREt2VtnnOo0Vp9EYmDtAIT1Peo9Dj/wtv53Iyr+PVsVUYV14aucbjqU
         /huUWnf0wTi9vOY5JzDXDKAuE9VoxxacJHGw5XOzYHV7At7Jc4njMt+Bd5/TneoHjdTq
         q3bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="hN3Tg/pf";
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 64si225458ply.399.2019.06.13.02.43.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:43:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="hN3Tg/pf";
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=EySscp3yKN+jDnjqTeB/vXgNBmJu+8rQ8w0cniT2gLU=; b=hN3Tg/pfc+DF3o2cE7RN16eAtU
	DSJVtP39I0bEcArETT1vSti3Crp6Qi6ZMUwozDmHcDkQP6AOPVOaSSisOOKmzApBa5KRd3Fc1dp2r
	g2XyhbubQhZWdnpR3yZQ12YlHZkEEwfLnzPENVeG2YNLsIJ43CAeQQvZPRB+G30UAOvUcGpwczkNe
	mnogyEbipMza1tYUKcfQqaQG3/M5pHI887fdLfo7flgv0cPauHj9XEiy7UM73W0JlaNeb622kfoPX
	R8Nu1l/kCfDiGUY+PLUbgk+PMfKovQLWD4DYNK3g20GKfH1m6doMiSXTnDatQF7W8R9hsse0hbDbU
	TtnGqz2Q==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMGd-0001kC-6s; Thu, 13 Jun 2019 09:43:35 +0000
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
Subject: [PATCH 02/22] mm: remove the struct hmm_device infrastructure
Date: Thu, 13 Jun 2019 11:43:05 +0200
Message-Id: <20190613094326.24093-3-hch@lst.de>
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

This code is a trivial wrapper around device model helpers, which
should have been integrated into the driver device model usage from
the start.  Assuming it actually had users, which it never had since
the code was added more than 1 1/2 years ago.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/hmm.h | 20 ------------
 mm/hmm.c            | 80 ---------------------------------------------
 2 files changed, 100 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 0fa8ea34ccef..4867b9da1b6c 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -717,26 +717,6 @@ static inline unsigned long hmm_devmem_page_get_drvdata(const struct page *page)
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
index 886b18695b97..ff2598eb7377 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1499,84 +1499,4 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
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

