Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F58C31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ED0221537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fFAKLKpe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ED0221537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC4126B026C; Fri, 14 Jun 2019 09:48:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A27706B026D; Fri, 14 Jun 2019 09:48:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 853456B026F; Fri, 14 Jun 2019 09:48:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA886B026C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:16 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i3so1630600plb.8
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7ZdZ3kFG7vLtpGzKUifkfy5au7mGeecDZr7pOAa/mbQ=;
        b=Q/XIkBH3y0qt6znmIewr5agPaxCaZVKB/q1tWrc5odOFcoOBuh3jAgG807m/iMerKN
         PjCky5dN1IThBtWJNNdatrLV5z8wlyx5Zs1KTQt6f/KgS6lsn9yW8e2U+cmZ8W9LM/jm
         wwPxSaF5BDzsJ1wquOaKEbdtlLt6LM9aZY6brgNBt3b106uYjmbHhIWB8HQtfRUQIyUZ
         RRAG43K62d7VkWretN1L+YmcqQ10Rhv+6QnEilLY9ur1B7xI8N+eqb/coZtFTLciaogW
         4jvRvCSbROEAnK4U0ljSHjbRM4R4jTeJnhvMnF8sczs9a06ezpRObyZYvScENVXzI4Qo
         z4VA==
X-Gm-Message-State: APjAAAVlprFG3n5uKr0qNuTGD3WAYSdrjJ0uVbgquHA59smf9obuTV3x
	dKNTSOuQxunRZ+S6Lylkrovh10+WNAGHOEYRt6pa1O/HcTIwOXvdqoNHmMi8g6NXaAA1SKVUD39
	xdF7ov6TBf4e/6YQyIquH5rg131O9SyisQcl/fFEt8cziM1DywCc8q2M/dtlNckE=
X-Received: by 2002:a63:4d05:: with SMTP id a5mr33576453pgb.19.1560520095824;
        Fri, 14 Jun 2019 06:48:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyClw/58KQwRxGlmk6aN+ujplATb86gi20dxu0sU8pVd3pNk1oTrNF/8tIaGVeL+Y4GPws3
X-Received: by 2002:a63:4d05:: with SMTP id a5mr33576411pgb.19.1560520095120;
        Fri, 14 Jun 2019 06:48:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520095; cv=none;
        d=google.com; s=arc-20160816;
        b=jhGwebIaNYztrJnBbZdTq5ucs+kjSs76B14i8v/sl78uOVLAEfcgWlcFpNHiwka7p7
         /MzWzv7Ps/elZ56BxBbZTo0HE2+imAGmYf4uCU6QLLaLKbby3+wPU6HJ9WTPqBDPgrCE
         1/taCRkvXdHxdbqOUm755P91caTg/f8QqAp3W/W6Nd6VUoCDLOncfPNZ0cHj8rde6nG7
         iUQf4DxttVOYNTaQOOZhVuTWT//UZp+IPb7THxAqgIJ4DT+rwKxkRk4Q9w/tLJ6Sys2i
         mW+1C2t4mVNOSmr71q3clZDAzaDNe+D/H7yJ70oNYlKRVupC95XKZpX6PLHcmBw9j3rr
         jOyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7ZdZ3kFG7vLtpGzKUifkfy5au7mGeecDZr7pOAa/mbQ=;
        b=f35o0HW9OjYYp+soEuv8lb4Ws6clMfjksfKaXvpLyTVTI8MnkgA50R0MqGg81k8zlD
         pV6oOyAFVMM+pKnzVe2x5LxkWJCaf7LIhFdZSUQ33KqOlW2UlUek4cYGl59wG82xn63M
         wPe7FFpoIQ1Ia/Vdtx1UyVlgPAbc1/hpkxdTGy2+3Tp0qm8BVQCwiGmBHNtTnMGnS/zL
         zEsgoK9fr/2PVIHVWQachqNIQw0Ui/LkBHIqPpwhPftJpBCKtt8jmBhPn9f16fSJcsSc
         lhRPdn61x9ERLEszBGLq3tUbt2H6KhEN4ZNcrSlRGi1QwvdmHXYL+gGPWSCYnid302qj
         JtAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fFAKLKpe;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f1si2474991pld.78.2019.06.14.06.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fFAKLKpe;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=7ZdZ3kFG7vLtpGzKUifkfy5au7mGeecDZr7pOAa/mbQ=; b=fFAKLKpeX1UXm3FTcf0KpVo86s
	TAVWErFRg7UqZpj/joIjhsfplRvSdKGAbFeP6PmZqe8B9ErySOXGc93t2ofqJ0PfW5tVLu+2bO7c7
	tlkcsmUTpcJGdiZudPM+9H/J7qA++YYntqBAP5nQMfi/0VmsaFYiz8iIh+FqmdmOSIDCUkX2AxyUg
	4+iPQe6FbA5imHkaPuPHdlmpbWkOZY2IPMBFcFQu5749gI0wQ18r1UkUghz38MdwIvcYqglGbv42Q
	OE9k8pQvOkUoTghcB7fXqj/U8J8TtUon4YKIlHWSSpbaJgmCuw3j4dq3Y7DAL3QyTY+SLK4x/iHsn
	p71d6N7w==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYk-0005GV-78; Fri, 14 Jun 2019 13:48:02 +0000
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
Subject: [PATCH 09/16] cnic: stop passing bogus gfp flags arguments to dma_alloc_coherent
Date: Fri, 14 Jun 2019 15:47:19 +0200
Message-Id: <20190614134726.3827-10-hch@lst.de>
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

dma_alloc_coherent is not just the page allocator.  The only valid
arguments to pass are either GFP_ATOMIC or GFP_ATOMIC with possible
modifiers of __GFP_NORETRY or __GFP_NOWARN.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/broadcom/cnic.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 57dc3cbff36e..bd1c993680e5 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1028,7 +1028,7 @@ static int __cnic_alloc_uio_rings(struct cnic_uio_dev *udev, int pages)
 	udev->l2_ring_size = pages * CNIC_PAGE_SIZE;
 	udev->l2_ring = dma_alloc_coherent(&udev->pdev->dev, udev->l2_ring_size,
 					   &udev->l2_ring_map,
-					   GFP_KERNEL | __GFP_COMP);
+					   GFP_KERNEL);
 	if (!udev->l2_ring)
 		return -ENOMEM;
 
@@ -1036,7 +1036,7 @@ static int __cnic_alloc_uio_rings(struct cnic_uio_dev *udev, int pages)
 	udev->l2_buf_size = CNIC_PAGE_ALIGN(udev->l2_buf_size);
 	udev->l2_buf = dma_alloc_coherent(&udev->pdev->dev, udev->l2_buf_size,
 					  &udev->l2_buf_map,
-					  GFP_KERNEL | __GFP_COMP);
+					  GFP_KERNEL);
 	if (!udev->l2_buf) {
 		__cnic_free_uio_rings(udev);
 		return -ENOMEM;
-- 
2.20.1

