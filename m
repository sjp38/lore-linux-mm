Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47D3CC41514
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2F4F21880
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HlRA67z+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2F4F21880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 997D06B0003; Thu,  8 Aug 2019 11:34:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 948906B0008; Thu,  8 Aug 2019 11:34:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E93F6B000E; Thu,  8 Aug 2019 11:34:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 451116B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:34:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y66so59313121pfb.21
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:34:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=13C43s4pw+qYxbSiHBqNJBxy3y8L+AabNOPsvifMBs4=;
        b=lTp6w/0eL0IbG9S7N2I05wvwb7l/aYKGv2hQhlbGllN52q/RVN09jCPUOiaxiTWS70
         kkE7rzTIuIhHXNRzUImAboQh0SJOzqqjWEow12S0lOZGbnzwC5BDaewbnjVjtTzp3sy0
         nSnVN9ngZJCvpNQgCzLmF17S+EXncEiJ6rNzi+JqiR9yhD0VYDYVt7fyzOGuHYjOaufb
         SnR/HxPyAya+SIkuNQ6qQhCrsXJ+/sQlGWNxNqzuKprmM5ngnd+fDM0r4o3HGtBBuONT
         N/SbKZxcAMwZHFRl3zYDPhR6ifzRtNHZi7TiMMKLqYpqlc3DEKCKtltrUU1dcIqeXs5a
         bLBw==
X-Gm-Message-State: APjAAAU7Orav5EwPiQ8iCrzd7ZbtBvuqY1jlUYYkhWu7NQLq2kwCc+sI
	v0ZpFFscT1y7dUND5/PrfKFNYUT9haFS3LaHpuWNJibJY02JB/iKRiWOXhYaR0e9TWg6XO1SBpV
	TS+2/10FNIpASSDCUi+YvuQv2uzR0n128xzPR9WNIVpFCgJCjfTNvLc3fdQwmVgE=
X-Received: by 2002:a63:36cc:: with SMTP id d195mr13067625pga.157.1565278452838;
        Thu, 08 Aug 2019 08:34:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZG1QYFMlQS87zhwuuKFpRSF0YwfVVkFq+OWXlN1Dekac9hH8myPJ9fnpIUy2m1uS1vqa7
X-Received: by 2002:a63:36cc:: with SMTP id d195mr13067529pga.157.1565278451606;
        Thu, 08 Aug 2019 08:34:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278451; cv=none;
        d=google.com; s=arc-20160816;
        b=ZGCXGkNLqVfgIDBxob1NY+zSGoZOOZmrcZ67rmZpRxHAtoKxUWIaI/ZjeFRhrn4bxg
         yc39UrHKF2ol8orzwF26X5tOS3ML3nnmv95cdCcx/L3rQvVYIVVmVpTOy6AjrK5TEtK9
         ijKKZyf8fcZ8NPbjZbXLcrXARYYySoRmb2ekQgNVKpzJyWOqTxeO4w1Xx9+nVVR/df5a
         30ia3ZhaBRcfdYgiLMqFWDTtIxhLg7pVvTxWIngC7P4dRfiFgnRg4ss5xf2PdRcDaRa9
         5zhbabA3Zj6/Cwf1kI1+hLFuWRFISIqN+Hlw3mHqf/bf/5WeFDyng3C680CaxAdVmtRy
         xahA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=13C43s4pw+qYxbSiHBqNJBxy3y8L+AabNOPsvifMBs4=;
        b=V9IhZ3MBu0u8LQRSQkPJF4tsqUZwt36yukm1+hjwrZ5DKLuyYxfkn7lA8BIlvkqOhU
         PO8ChggQet2eAQ7tQkcKO2p/ux6k8jRaDpFdhfQQe545aIUbhNDPTMpstjm3tEjRCN6d
         2ulIMSB9KA16wDt9a44A+VcmT8WtW6eVGxdUpTZIAahuVOqBvcH9M5OBFBP3fyw1je1c
         G6ysSKG1r/qxOhwfpsJkGh/jc6LoP7FC3+eWYVNOkMHam3ozBjC0dkbfBn2EDKaZmBv+
         w8RAPiKgHY8i8y9mDOd4QeTWsMghNejKmAEPk5WhVLP3inn2BYrXqyCOlG4hMEoBZjK2
         L3Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HlRA67z+;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n20si49416588plp.395.2019.08.08.08.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:34:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HlRA67z+;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=13C43s4pw+qYxbSiHBqNJBxy3y8L+AabNOPsvifMBs4=; b=HlRA67z+7DZXRQzzlMsS7G/gsF
	2f86pIZ0g34YKp5IRb1k2QL+ETeNm/rq8lsA09BotnC7Sw+FIxdazkIygvpC9Np39mZU9YYonu+1x
	qZGmcNt4D72r2QIXtpYRbcJEAEgVd+js+ukBUV1KP1sgTlVzheWG/cYKmD6l+Ms8Z6GzqmOxY3vyt
	/Kscw8q+cDoXwo8YJfVLNFXkmy+MHL2U3/lIDBR5Ie9UpXSi93XJ92d1CIfdLVGR4PSn3sdObJPf7
	fzjfmKSNtTxX1hw4B6o7UBcnvMT3KLQ5eTOBCx8TAQV/LQAlwLIC5BOS/8cjeEI0g2Sz8Z2wMK9vw
	FPUqcdkQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkQZ-0005C4-2B; Thu, 08 Aug 2019 15:34:08 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/9] nouveau: factor out dmem fence completion
Date: Thu,  8 Aug 2019 18:33:41 +0300
Message-Id: <20190808153346.9061-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808153346.9061-1-hch@lst.de>
References: <20190808153346.9061-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Factor out the end of fencing logic from the two migration routines.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 33 ++++++++++++--------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index d469bc334438..21052a4aaf69 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -133,6 +133,19 @@ static void nouveau_dmem_page_free(struct page *page)
 	spin_unlock(&chunk->lock);
 }
 
+static void nouveau_dmem_fence_done(struct nouveau_fence **fence)
+{
+	if (fence) {
+		nouveau_fence_wait(*fence, true, false);
+		nouveau_fence_unref(fence);
+	} else {
+		/*
+		 * FIXME wait for channel to be IDLE before calling finalizing
+		 * the hmem object.
+		 */
+	}
+}
+
 static void
 nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 				  const unsigned long *src_pfns,
@@ -236,15 +249,7 @@ nouveau_dmem_fault_finalize_and_map(struct nouveau_dmem_fault *fault)
 {
 	struct nouveau_drm *drm = fault->drm;
 
-	if (fault->fence) {
-		nouveau_fence_wait(fault->fence, true, false);
-		nouveau_fence_unref(&fault->fence);
-	} else {
-		/*
-		 * FIXME wait for channel to be IDLE before calling finalizing
-		 * the hmem object below (nouveau_migrate_hmem_fini()).
-		 */
-	}
+	nouveau_dmem_fence_done(&fault->fence);
 
 	while (fault->npages--) {
 		dma_unmap_page(drm->dev->dev, fault->dma[fault->npages],
@@ -748,15 +753,7 @@ nouveau_dmem_migrate_finalize_and_map(struct nouveau_migrate *migrate)
 {
 	struct nouveau_drm *drm = migrate->drm;
 
-	if (migrate->fence) {
-		nouveau_fence_wait(migrate->fence, true, false);
-		nouveau_fence_unref(&migrate->fence);
-	} else {
-		/*
-		 * FIXME wait for channel to be IDLE before finalizing
-		 * the hmem object below (nouveau_migrate_hmem_fini()) ?
-		 */
-	}
+	nouveau_dmem_fence_done(&migrate->fence);
 
 	while (migrate->dma_nr--) {
 		dma_unmap_page(drm->dev->dev, migrate->dma[migrate->dma_nr],
-- 
2.20.1

