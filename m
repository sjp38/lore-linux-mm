Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 309D1C31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA66D20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uRK7ZFAn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA66D20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 805116B026A; Fri, 14 Jun 2019 09:48:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78E316B026B; Fri, 14 Jun 2019 09:48:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62FC86B026C; Fri, 14 Jun 2019 09:48:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7236B026A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i123so1803047pfb.19
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=voUH/VESvtWj4I6HLsXBpYRJA1I9bz8V8FhWnyIglGY=;
        b=FK+nWcfcWqJf2pQ7L5e+NE26fkP1G0Qj7TzvazCEuWP5Sxv83cTZZhgAVJMRR+MjPq
         JD8rIg+Ma91SyvdZyfLNC/nDxrL+oxSrxACePhUNW9wMYZlmIuB0zjN2ToXomAEd/k9P
         +4LX6vGJtXXTNMdAzbkStZa84mrHBZekz+qkS2/AV7QPl2uYwYy4Pwd7O69nIv10cyZO
         81NBuMaiGFgryH4xGem2timYtNQFka9nJpoCiHYYMTq/zTbGZhu715sEP7Qe4I5Trvil
         l92WILwb84WLPYsxkTgyB7A2Wkp6U+gv75nvnTQ7oJJeCnGbXfC/pL+XmGuUyowVdKzq
         7PoA==
X-Gm-Message-State: APjAAAU+WQEQHx8pgtHPRw5zOn/N9W/bexX1abKJ63o1WvbV/DpdhDQ5
	uYNLh38FebPwwAPmPmZ4WGwTTjJOihtrwxeMReHM86NXM1mb9ZWOR7DaCogwoS/8NV5y9UjoaR2
	B7/uZRtw1O+akXezDatjr4QBfTiadmQ4Juy3Nru2fwm95WNF4r3ujE+IElbuQFlk=
X-Received: by 2002:a63:f70b:: with SMTP id x11mr5106439pgh.212.1560520094743;
        Fri, 14 Jun 2019 06:48:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcJfzQ7bc6O+BsYgJTUeSiR46b7EXJNPWPyPZ27mraowZoWi91aAQo7sueUxJ2BA/H8KvP
X-Received: by 2002:a63:f70b:: with SMTP id x11mr5106376pgh.212.1560520093908;
        Fri, 14 Jun 2019 06:48:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520093; cv=none;
        d=google.com; s=arc-20160816;
        b=FGxfduJoR9Dr3bYvsrjRpk9BTEZo+ufGRTOYOIpaQ9CClHdWO8OIYUwjZuoIkABjRO
         A5IwwGAAVAEZp+PY7z+DZRoFko5GU4cjWwy/1NxA1EaAAUKOa6EaxhjccQ3X0nBs0NrK
         0QCV5TRNw+BVjMenP8ziAdFOb60vyy01GlQqI3ajIivC2KBV01+xsq2jnL4SQTHPo6nJ
         xT/oaL4qlC1UGmQfTy4Pk/CPZEHLD3ZQqFz1jyolTyd99o+RhaneoxgifPKQSUoJB3Qz
         UYSekdSleyfGppNooUeM0dLw7xTfMcHLynkqUS+/tkojALyCuUZnWNGQzu8FUnSL6UN6
         F3NA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=voUH/VESvtWj4I6HLsXBpYRJA1I9bz8V8FhWnyIglGY=;
        b=MwM1t/I7qX7A03nzxTGko037DnhGPTKhV6Oad+lVAqj+NQEuPyuFHcZtyg0qylbvVs
         SXTAbELvb/2jVOOalXP3ApcXyWdQigZWAI+IZO780y1Wdkkk3RGAZaP0ZKWGwu7aiL2F
         4/EYDt6Y+NexySOwSeF5SIeqm4Z0Yo7Hmt9Pmb0bB+nXOIpK4tk6Kl3xnFrz5gjpsXEq
         VYomd0FAwldcL/wAmgzpE841yQOaBfNiDXJ4A35CSJYTS86i8dS3xHax0EPsMRc8NySl
         DcYwzkzD49koRlcMVsH8Ph1sQi44+Js49jdXBmC8KbDRImM+IoeX56WaGyCyD3fiVe87
         U7cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uRK7ZFAn;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j125si2594440pgc.453.2019.06.14.06.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uRK7ZFAn;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=voUH/VESvtWj4I6HLsXBpYRJA1I9bz8V8FhWnyIglGY=; b=uRK7ZFAnjpL2rr/0CUfA2lvRvn
	MMA/TT67HwvKwHALsH6Yi1bK/9hQpeF2Y9WNSQiuHCQZk3pGo5Iut8pm4tAYvEGrw/6WXYNTmPxKO
	dAMk/oU/QBEx/xXpnJFg9G8wz5Fp9ysZOZxj3YySGlQxOS9aKURHvR4B3f1nS4JChwui9qEEY8i6X
	bJlC9leC1vR0nEGsTg5/vqnuj4fdWff3QX72bE0zpkRJHcgzwvQf1m9HIJwDxhhdbqgBXTTX3ixSJ
	5oYDmNfDcKyAIPrOHNouEAsKLx5bVbDJIHGyKOFWk1kar/q9/gTj6w2JpvlWTWoobtck9JM+dFHSI
	3wLzosZw==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYd-00054z-8V; Fri, 14 Jun 2019 13:47:56 +0000
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
Subject: [PATCH 07/16] IB/hfi1: stop passing bogus gfp flags arguments to dma_alloc_coherent
Date: Fri, 14 Jun 2019 15:47:17 +0200
Message-Id: <20190614134726.3827-8-hch@lst.de>
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
 drivers/infiniband/hw/hfi1/init.c | 22 +++-------------------
 1 file changed, 3 insertions(+), 19 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/init.c b/drivers/infiniband/hw/hfi1/init.c
index 71cb9525c074..ff9d106ee784 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -1846,17 +1846,10 @@ int hfi1_create_rcvhdrq(struct hfi1_devdata *dd, struct hfi1_ctxtdata *rcd)
 	u64 reg;
 
 	if (!rcd->rcvhdrq) {
-		gfp_t gfp_flags;
-
 		amt = rcvhdrq_size(rcd);
 
-		if (rcd->ctxt < dd->first_dyn_alloc_ctxt || rcd->is_vnic)
-			gfp_flags = GFP_KERNEL;
-		else
-			gfp_flags = GFP_USER;
 		rcd->rcvhdrq = dma_alloc_coherent(&dd->pcidev->dev, amt,
-						  &rcd->rcvhdrq_dma,
-						  gfp_flags | __GFP_COMP);
+						  &rcd->rcvhdrq_dma, GFP_KERNEL);
 
 		if (!rcd->rcvhdrq) {
 			dd_dev_err(dd,
@@ -1870,7 +1863,7 @@ int hfi1_create_rcvhdrq(struct hfi1_devdata *dd, struct hfi1_ctxtdata *rcd)
 			rcd->rcvhdrtail_kvaddr = dma_alloc_coherent(&dd->pcidev->dev,
 								    PAGE_SIZE,
 								    &rcd->rcvhdrqtailaddr_dma,
-								    gfp_flags);
+								    GFP_KERNEL);
 			if (!rcd->rcvhdrtail_kvaddr)
 				goto bail_free;
 		}
@@ -1926,19 +1919,10 @@ int hfi1_setup_eagerbufs(struct hfi1_ctxtdata *rcd)
 {
 	struct hfi1_devdata *dd = rcd->dd;
 	u32 max_entries, egrtop, alloced_bytes = 0;
-	gfp_t gfp_flags;
 	u16 order, idx = 0;
 	int ret = 0;
 	u16 round_mtu = roundup_pow_of_two(hfi1_max_mtu);
 
-	/*
-	 * GFP_USER, but without GFP_FS, so buffer cache can be
-	 * coalesced (we hope); otherwise, even at order 4,
-	 * heavy filesystem activity makes these fail, and we can
-	 * use compound pages.
-	 */
-	gfp_flags = __GFP_RECLAIM | __GFP_IO | __GFP_COMP;
-
 	/*
 	 * The minimum size of the eager buffers is a groups of MTU-sized
 	 * buffers.
@@ -1969,7 +1953,7 @@ int hfi1_setup_eagerbufs(struct hfi1_ctxtdata *rcd)
 			dma_alloc_coherent(&dd->pcidev->dev,
 					   rcd->egrbufs.rcvtid_size,
 					   &rcd->egrbufs.buffers[idx].dma,
-					   gfp_flags);
+					   GFP_KERNEL);
 		if (rcd->egrbufs.buffers[idx].addr) {
 			rcd->egrbufs.buffers[idx].len =
 				rcd->egrbufs.rcvtid_size;
-- 
2.20.1

