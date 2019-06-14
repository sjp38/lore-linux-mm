Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49F86C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 049FE20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="InfZ/wOT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 049FE20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C71BF6B0275; Fri, 14 Jun 2019 09:48:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFDE96B0276; Fri, 14 Jun 2019 09:48:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4D256B0277; Fri, 14 Jun 2019 09:48:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 634A36B0276
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n1so1629581plk.11
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RVKpwDD7wUATUASeNR+XdAkTqCzdoA7nasScp5npHqs=;
        b=s4LaWAyJiLrpa7gfFDkkmalGBZo9/fprwu/naAkf4VFkcPPyIpatV8TnO37DVhW4Fe
         v8B6rQCi/B6Iqu2Zv8KC8WPFEa+9jPslSTShofYMs6Bc8hA5hyiRXHlXCEwBHGxbBg5r
         u+vzf+MNbJKNPksBrBKOhBZ5RYmSCTWCUSxWyeY0iRRb5GYXHnjJEsdBZiq9QpO0xxb9
         1ZRBJYe4yksSWGBmk6KgNwriYBeESZccUG5i9GpNLHxin/ezAxdQuYGfb2h9z0WeQPNf
         7vw5mBdu8W4hj8Pe+nPRqNz60c+wJrvaELt4dXbY8mVGOZbQiBQLf6dNt+V1+4onDshz
         Ju5w==
X-Gm-Message-State: APjAAAXBF8CigznVNoJKSiL7qCS1SBIZFVdQw2EiBErADvTuqcG7Aqrf
	doDXfvLnWXtWsw62Ds+EJUK8v2EMm/oiwphrkkSR/mO6HTLC8XgftA+8VLzfkF4iryC9ZfBbXcu
	ctuwMURJRLL9S2t2tPPqnwqVxkyrq5xCLWS4swZIisj8VPtMSmnzZj/ogJFNkymg=
X-Received: by 2002:a17:90a:d817:: with SMTP id a23mr11090950pjv.54.1560520122051;
        Fri, 14 Jun 2019 06:48:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyr4PO16wgnAq3F0JP1B19b11gYlQX7pOMPo9LlP+FSobVB78srteJT4vbt5jqVWUiEL6PJ
X-Received: by 2002:a17:90a:d817:: with SMTP id a23mr11090884pjv.54.1560520121179;
        Fri, 14 Jun 2019 06:48:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520121; cv=none;
        d=google.com; s=arc-20160816;
        b=Ho+uatvE9494qoIsT//LhRc/KmYXXwfLRIFhSJcFz6Y/lkyQg1kMVYrW47cVQVru3l
         LLq8WoT6QmvsRxOBpWWE3DOZcIhCY5FtNLtkQQyD9qXt4W0YSA7/gZRY0WDGAtdNPwIf
         Jx7v0MrWoiL24fUg3cqFPkB91/mACYqgkgCDuU3oP6vTk0yBTPHBalqtxnJnc+KrZozv
         isTNCAFe5KaGSy4JWdmd5qFy9sNycCAt+/TvPqhAfJtODtKs5tpw2LhfSvue9NiIRQa8
         7RznOkSyNdUeGCNETUK++6oQHwmF0w9F7fGl51HDZ7tk4NMdNNoMnT27csFXYoYZEJO/
         oYUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=RVKpwDD7wUATUASeNR+XdAkTqCzdoA7nasScp5npHqs=;
        b=o4MqIJvLYTprDQV9MInUzvlqrHltLkrBnI5LB4qBIL4uj0VhotPF+8y58ieKXRswzh
         zEm2VaQpzs//8utVn5ymS/+r+FPWyjfIZE+ppy8u8P4MinBEtLnnOJdShzj86YcAIzji
         vDBo2ox5MU8h+xNSygZVMJ0osNwD9hMpyzFDHXZH9Abe4B/+c4ginEt4sHmyFDd6aecI
         aOlTbL/9E2w1fPViG4IRSOeVXePxYTfon9nw+DYFmD4B5mvAASreZVIqPzb93tkLKPIx
         5w0vIL/vHdukr0nypPpRCV9TBsQYK1osDpUyBbhy594b4Uqo4RaOi3oGhHdpLZhCe+eO
         HMrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="InfZ/wOT";
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h4si2478035plb.206.2019.06.14.06.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="InfZ/wOT";
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=RVKpwDD7wUATUASeNR+XdAkTqCzdoA7nasScp5npHqs=; b=InfZ/wOT5rvjRmLvAJ5YP0wj7w
	MnY2l6T7U9OKNQHOpXU4ecx11Q/eDpbs9QZcUEk1J6VapmhpcCqvhL8/4NsVudmklSgaa2WcxVUBe
	waQaOUcUb4RL/2HYzMKDhBFk0TbOCBJW2bM1HFoiaO8f2Ig4hC482NJbLtwEkvvRfYlxTkYB8GZfS
	F0h9hjSdleNEn2dTrk1H5znVe9s/hC3c40GaTOTSLSDPoVROxZizHibMU3rX0xz8EOQplEK9nB80Z
	xPVZaB3uqh4bQkuTonc69uqBuDRYzL7doJGRuaJI4LbV+3+NfJQNVhZazRojfRluUXrQDfyvbPdjZ
	6hG3FXUA==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmZ7-0005kh-Ep; Fri, 14 Jun 2019 13:48:26 +0000
From: Christoph Hellwig <hch@lst.de>
To: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
	linux-arm-kernel@lists.infradead.org (moderated list:ARM PORT),
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	linux-s390@vger.kernel.org,
	devel@driverdev.osuosl.org,
	linux-mm@kvack.org,
	iommu@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 15/16] dma-mapping: clear __GFP_COMP in dma_alloc_attrs
Date: Fri, 14 Jun 2019 15:47:25 +0200
Message-Id: <20190614134726.3827-16-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190614134726.3827-1-hch@lst.de>
References: <20190614134726.3827-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Lift the code to clear __GFP_COMP from arm into the common DMA
allocator path.  For one this fixes the various other patches that
call alloc_pages_exact or split_page in case a bogus driver passes
the argument, and it also prepares for doing exact allocation in
the generic dma-direct allocator.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/mm/dma-mapping.c | 17 -----------------
 kernel/dma/mapping.c      |  9 +++++++++
 2 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 0a75058c11f3..86135feb2c05 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -759,14 +759,6 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 	if (mask < 0xffffffffULL)
 		gfp |= GFP_DMA;
 
-	/*
-	 * Following is a work-around (a.k.a. hack) to prevent pages
-	 * with __GFP_COMP being passed to split_page() which cannot
-	 * handle them.  The real problem is that this flag probably
-	 * should be 0 on ARM as it is not supported on this
-	 * platform; see CONFIG_HUGETLBFS.
-	 */
-	gfp &= ~(__GFP_COMP);
 	args.gfp = gfp;
 
 	*handle = DMA_MAPPING_ERROR;
@@ -1527,15 +1519,6 @@ static void *__arm_iommu_alloc_attrs(struct device *dev, size_t size,
 		return __iommu_alloc_simple(dev, size, gfp, handle,
 					    coherent_flag, attrs);
 
-	/*
-	 * Following is a work-around (a.k.a. hack) to prevent pages
-	 * with __GFP_COMP being passed to split_page() which cannot
-	 * handle them.  The real problem is that this flag probably
-	 * should be 0 on ARM as it is not supported on this
-	 * platform; see CONFIG_HUGETLBFS.
-	 */
-	gfp &= ~(__GFP_COMP);
-
 	pages = __iommu_alloc_buffer(dev, size, gfp, attrs, coherent_flag);
 	if (!pages)
 		return NULL;
diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
index f7afdadb6770..4b618e1abbc1 100644
--- a/kernel/dma/mapping.c
+++ b/kernel/dma/mapping.c
@@ -252,6 +252,15 @@ void *dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
 	/* let the implementation decide on the zone to allocate from: */
 	flag &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
 
+	/*
+	 * __GFP_COMP interacts badly with splitting up a larger order
+	 * allocation.  But as our allocations might not even come from the
+	 * page allocator, the callers can't rely on the fact that they
+	 * even get pages, never mind which kind.
+	 */
+	if (WARN_ON_ONCE(flag & __GFP_COMP))
+		flag &= ~__GFP_COMP;
+
 	if (dma_is_direct(ops))
 		cpu_addr = dma_direct_alloc(dev, size, dma_handle, flag, attrs);
 	else if (ops->alloc)
-- 
2.20.1

