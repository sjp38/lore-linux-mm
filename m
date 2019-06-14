Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFFA5C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99E9C20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="owRHpuK6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99E9C20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40C6C6B026F; Fri, 14 Jun 2019 09:48:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 395FC6B0270; Fri, 14 Jun 2019 09:48:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25E496B0271; Fri, 14 Jun 2019 09:48:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E16896B026F
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d2so1620240pla.18
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yT59YDuDyJ+PxdfRPqwI/alSJ84EPbJSnwgnpwBRCag=;
        b=fdkyues9F3cYPv86PnxgeIxTvw+izJ/0FlaA2X6OCoHi4D3rU8HgWFMBGPNPdpYTWz
         jD5p2DQWZQTsIccV+gXMPWOikE9CJYOaUdwK2NSu/aYY4n/klYSDadxpODT0gcSkr7ik
         vI+tBYRxcxIt3AfTt0+vFlTeReSLRM1SBqiElhME7Bm0+abnZlJkK0sQzQhjlJ8iZi/U
         NStGICHSfEsVrIetUJckYRX2j253cYGtsWAzJpPjub4200yad5bZMZ7638e8i0JmzIXL
         pt7ea0fY+sBTigXsThnpIWkPhJknSY7rL4hb1amJkOBB44zAhmFG4RlRYM9k8hilglR0
         U1XQ==
X-Gm-Message-State: APjAAAXH+nRMkuxT+zwvqPX8iW55hikMftPCogUKLGHvJaxTXmJ7rHRE
	8SEFs4y3LxAzWK0UPdSPADufJNX8B9j1Oc0/t62JKu3RXiYd/iU0q4/U0v28naonu4DdE/DVpwW
	6ZtIpvv1LoQkkmmiMC2s9+3w2X3Bw7DuAxbKUlCIZdaI06il+Azy+TQQkMi34Ptg=
X-Received: by 2002:a63:1f04:: with SMTP id f4mr37034316pgf.423.1560520114537;
        Fri, 14 Jun 2019 06:48:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsl21jLFRWJFTsw2CcVniZ8CQh/VkP3fjkdrFqEyIOot8u4T9UKVIAtzkYJQf/BFeDFGo4
X-Received: by 2002:a63:1f04:: with SMTP id f4mr37034259pgf.423.1560520113844;
        Fri, 14 Jun 2019 06:48:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520113; cv=none;
        d=google.com; s=arc-20160816;
        b=ZqGC2bCVnNuSUg75vPpb7wMH1MDPiDdTNyfrnXW01jq0m7+iZQXJWaU601iJoliF6O
         T2UhdwMrUi4J+mS2Uf6AMSgTFoijI0ajqOfl0E/IZ5spCngk7DCPT9HkcsVvVnC0IasD
         B2vsTnFQHkNjkjkZc/A000v4JTBeQ0VbfCuyO1z+mqVX7CcpIRfswt4RBIvvpXVdQ9Cf
         zC9+OzAMdKucxZNxdkui1CK3NQWikSJDDlNuDHZjtEyP34x/IFIMdqiF/kTEjV2GF4bu
         2C/ShYT6woFOF/h37o+tSy7B7lFerMkXKxUdLVDeNQpaHlYoWcTYbF1tCOk69JeuqlG1
         Wn0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=yT59YDuDyJ+PxdfRPqwI/alSJ84EPbJSnwgnpwBRCag=;
        b=rOahPpyikxjW8bW/JpicQUUT+4g/AHHbHeK2VJLCLEwSfVWJlz6t02r8gXZgF0/Zvi
         5YuVJTup+stRyl7nnw6Dv7mYUt+0cES0KDETe74fYxrjT1abuDYNuYGv4zkrsaeZyrHb
         Zb63eqVYcpaGQ/vBBshdllsSF9rZGZF9dQ/iZsyKYvZuM3Uxqa0niT70AiPGtRWjuf7f
         0MXrZc4b6Hra6p2aomfx6lgVNMeug3f5Qb++QeoiKhlWuq8SAVc4HDB97UI6ajzc1Gap
         Zh4sUMXXUgLMS8pFsHiqF+yBu7X1hK2ebUjCXSEPX6itCc+lIL9VYmONUpZbknEUJ1hS
         GK/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=owRHpuK6;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x9si2281903plo.228.2019.06.14.06.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=owRHpuK6;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=yT59YDuDyJ+PxdfRPqwI/alSJ84EPbJSnwgnpwBRCag=; b=owRHpuK6KPpEPbej7i1YhZs6AX
	wN7yNoV43C+ez1kJ8mjyYksBoNb/QnO43qmDtaoXcejQN8JVymeq+ihqkSdORxH9DTolc8g44wL/n
	4LSqiLNL1pznmOxp4ws/5vWu11eRtAmNuWXern/02xHfx/UTArA2cLwNsqFsJR3FHm32czvwMjXp2
	7sGt2jHFZhtBCFB/p80y7vCA6bbzdpMVufvVVb+aSI6J4MNffPlYXrnmf1qIq+XF2XIQg2V9t5O5b
	b1wpDdk22coEH5ua9xigsjiut+9bxXp+UfE0duTuPjXZxk7HNsybWuKX1NvzSJkdd8inzEtTrVrtu
	gzlO+vIg==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYq-0005Ma-VZ; Fri, 14 Jun 2019 13:48:09 +0000
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
Subject: [PATCH 11/16] s390/ism: stop passing bogus gfp flags arguments to dma_alloc_coherent
Date: Fri, 14 Jun 2019 15:47:21 +0200
Message-Id: <20190614134726.3827-12-hch@lst.de>
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
 drivers/s390/net/ism_drv.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/s390/net/ism_drv.c b/drivers/s390/net/ism_drv.c
index 4fc2056bd227..4ff5506fa4c6 100644
--- a/drivers/s390/net/ism_drv.c
+++ b/drivers/s390/net/ism_drv.c
@@ -241,7 +241,8 @@ static int ism_alloc_dmb(struct ism_dev *ism, struct smcd_dmb *dmb)
 
 	dmb->cpu_addr = dma_alloc_coherent(&ism->pdev->dev, dmb->dmb_len,
 					   &dmb->dma_addr,
-					   GFP_KERNEL | __GFP_NOWARN | __GFP_NOMEMALLOC | __GFP_COMP | __GFP_NORETRY);
+					   GFP_KERNEL | __GFP_NOWARN |
+					   __GFP_NORETRY);
 	if (!dmb->cpu_addr)
 		clear_bit(dmb->sba_idx, ism->sba_bitmap);
 
-- 
2.20.1

