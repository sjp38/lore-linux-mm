Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D7AFC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1814B216B7
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cmioyjZC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1814B216B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B15536B0008; Tue,  6 Aug 2019 12:06:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A794B6B000A; Tue,  6 Aug 2019 12:06:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A7C26B000C; Tue,  6 Aug 2019 12:06:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34ACE6B0008
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so56107999pfo.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jw2njJjxDN00xjjd9oeT2JTOUWmPpUSj71zvFEWivDw=;
        b=UqJ+Z1iKY4fPiRsPDamrYva8rEHnL9m0smstcy6Ry/4P9+TXnGL+jS+XZqRRSnyYEC
         VuJnJHHsTKQ9iZMuBIDQoBM8+SomFhAAEZ6V//RToHpVjae+pG1MJS0dC5Gtk/1wxvFR
         /sLNYda9yuCN56XZN1AHsdAePsshPeVBF5SQQ2i6+X1qTCMvUzeUPHfBPSwwllLtAy8/
         EcCvUlm7L+RcICkV7ra4uxunqtBTYmyUN2LrzsrX8vw+s1yEji5ucf00fGXCRqL1ROnr
         hkw5YpC/SDQ+nMgD1x0E+2sjPvU448sigc2n0V2dPohtFEJnAtBVOkUkhz8QzxtSlr5H
         t8zA==
X-Gm-Message-State: APjAAAUnnFO8NqabjoC1oiz87gAGSLAEERpBKB7RkgXAAvPXqeM83Oul
	b7I4nVIpQiuMhH+oNkoh3fT+1Qog6X1EQT18i1z1AXvYHDbbju7LE/pdtd0uf2eAl81D6K8sKLJ
	8x6dLIyymTHIrIRKpPwTjVzwidUudIhuDKYXH6HHLuoCmPdg4AKlEvZjERn2YPkY=
X-Received: by 2002:a17:90a:d998:: with SMTP id d24mr3919201pjv.89.1565107567820;
        Tue, 06 Aug 2019 09:06:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeOwuyBI34ezvV+7pe1pu/1+U9TBB3wwXh5YJtj6QP1vcyZXycdyUJ3Sk8s0KCUzvb8gpC
X-Received: by 2002:a17:90a:d998:: with SMTP id d24mr3919131pjv.89.1565107567043;
        Tue, 06 Aug 2019 09:06:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107567; cv=none;
        d=google.com; s=arc-20160816;
        b=oa4Wr7XT3u508T+KiGt+NvNbW1FJFPTLO0Pf5mofpAywfAYCjnE4GtCtj2w7MCTCOl
         0awWgQYy4kkEWNgVfbacOjcXOrh4kJb99Il5vJ2NQhejrLo2FQQvfx1kPedyUZBhhp1m
         DXFEE9LcBxM+uCuQDqVPuCQR44PM+xbAqvxoyzs65hn4qxlPmOfctQEj3MKGXQlPBYRz
         Ig+0+LM0L2xqqCzjXbSMKYowvLXYDruaEDwf6LAhoxPAJDmLmGHjhy22i5ahSZ33FId2
         rsEfUeTIbNihLXK27msEkKMPvlA+9p3GhN0K9pQpNlaPyTSietLsiUUVu2aYIzzCRChZ
         DTgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=jw2njJjxDN00xjjd9oeT2JTOUWmPpUSj71zvFEWivDw=;
        b=xw3lkQ5rqLqhDZaEk5gAdeKbv1ZQpsfSlmOzwlmbzYihbFbN43x5HIXzIuS+Y4VbqC
         1mVve4dqrGjxInqqvp6yobS6NdwtxusoxH65HN6q24uiMklIonCDGh2iZOktqgIwlUDj
         hT+/00Oc42XVjlPIvVVtx/jFK7q5ywUz9sQBQb4oiAWFBQcGZDnRsHbrwQgZ7SZq6rA7
         rpBLaClEPEfoETmhCIlJCwZZNhiOIuCUjdAL10WL9dwe4if6wj/kvibo1ZP3OPpCxLIr
         AaqkuNj9JSMDSxuK+ZkHBv0g4spKp3HTt+CKJcSCLtgpWQg5Gyf8peav+JWSYK+iPqZh
         3V4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cmioyjZC;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l9si42216945plb.317.2019.08.06.09.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cmioyjZC;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=jw2njJjxDN00xjjd9oeT2JTOUWmPpUSj71zvFEWivDw=; b=cmioyjZCRaAvXECnpQCfCtKV3C
	K6YAmV14z7KzaLLRcZnOGNm3ot7ObXpIslQKkBo302RvxpCZ57t1lyfgPMlq0K6LpFLAnnuXnxN2l
	oK6v0GVmq4XYrQlvovjELgFqZz8EvXaxN7ZAD+Zzn5q9BWmWt0Bj9Ng4wanLQM9xg9QLPubAnfYfs
	o87f0v3ABw2MP8ipKyGHf5hthuEMCBJiFKlblJH1sngrV+4+Yt59Ls/zba8gozAbC/+Xx83B8UIBT
	qbQ8T3GYeHHLhVMf6okW/RCk/RAHVfakdX+WZ43C01pgYavVeXeSjx5UpdazVVL0bwLYw0obZTQhj
	gvK/DVXQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yO-0000X0-0k; Tue, 06 Aug 2019 16:06:04 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 03/15] nouveau: pass struct nouveau_svmm to nouveau_range_fault
Date: Tue,  6 Aug 2019 19:05:41 +0300
Message-Id: <20190806160554.14046-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806160554.14046-1-hch@lst.de>
References: <20190806160554.14046-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We'll need the nouveau_svmm structure to improve the function soon.
For now this allows using the svmm->mm reference to unlock the
mmap_sem, and thus the same dereference chain that the caller uses
to lock and unlock it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index a74530b5a523..98072fd48cf7 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -485,23 +485,23 @@ nouveau_range_done(struct hmm_range *range)
 }
 
 static int
-nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
+nouveau_range_fault(struct nouveau_svmm *svmm, struct hmm_range *range)
 {
 	long ret;
 
 	range->default_flags = 0;
 	range->pfn_flags_mask = -1UL;
 
-	ret = hmm_range_register(range, mirror,
+	ret = hmm_range_register(range, &svmm->mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
 	if (ret) {
-		up_read(&range->hmm->mm->mmap_sem);
+		up_read(&svmm->mm->mmap_sem);
 		return (int)ret;
 	}
 
 	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
-		up_read(&range->hmm->mm->mmap_sem);
+		up_read(&svmm->mm->mmap_sem);
 		return -EBUSY;
 	}
 
@@ -509,7 +509,7 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 	if (ret <= 0) {
 		if (ret == 0)
 			ret = -EBUSY;
-		up_read(&range->hmm->mm->mmap_sem);
+		up_read(&svmm->mm->mmap_sem);
 		hmm_range_unregister(range);
 		return ret;
 	}
@@ -689,7 +689,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = nouveau_range_fault(&svmm->mirror, &range);
+		ret = nouveau_range_fault(svmm, &range);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
 			if (!nouveau_range_done(&range)) {
-- 
2.20.1

