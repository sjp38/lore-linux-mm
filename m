Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 970DAC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DB2C20818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hikw7GF8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DB2C20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E96966B0006; Tue,  6 Aug 2019 12:06:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E45846B0007; Tue,  6 Aug 2019 12:06:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5CB26B0008; Tue,  6 Aug 2019 12:06:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99B1A6B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:03 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j9so1205060pgk.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ilF0L5eSgEyyYaXFSbddhy3bpJmKXINzOGRCtzZ9aSI=;
        b=J8M7ae/AXdCFqMTxS19CfczqCqQKnv7J2vNR6v89pjBVLiMgxQ92/kYoTqIK5eCf/9
         YU6Q4x3SX+TV+UQC2OHwkKs1ZR+YW4zpWoijxlBofog5gXS5q5+4PewvFImuqzX32cqo
         SkX/Xe+0OWepTf1WR7T9roBGDlnSUbpojxu60gh8Z/5ua3WxWsGC727PLz8sYEyjJAFE
         uL/DjNYYC/+rg8mwuV7givtzILI7PCyAiN70yALDX1vQ8N8tc+xbbmzP2ZSfsxtE60JL
         WD7bqAdIMMUbe6FIwabyfn9E5gTQob67N6BLwUqrDyOhw0uDXEz9OfACj3105IpwnqR2
         lFlQ==
X-Gm-Message-State: APjAAAWpddciLXcY48IUcPYSkfiOjS6mV6NyR9CRwOd9xSVzrurYGl9Z
	hYwQJBWJyKgZPn5inubdwNLESw3yU05fKlk0EdKkgepi9GO9LO0rh/ewfwVm4rUJRt6p+LBsNOm
	N0/JDCYkwYp2n31fdj6w3DW7IwfL/qVZ48gGwCWSKFrbikw3sDiNP5oVGKOqltic=
X-Received: by 2002:a63:1341:: with SMTP id 1mr3820415pgt.48.1565107563006;
        Tue, 06 Aug 2019 09:06:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxy3rMWXNjuBsbjMbPrKuhAcXcUCRh3JL635sMkd1IcTGqtX9pASVasmMzz7WiR0SjeTTSq
X-Received: by 2002:a63:1341:: with SMTP id 1mr3820348pgt.48.1565107561985;
        Tue, 06 Aug 2019 09:06:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107561; cv=none;
        d=google.com; s=arc-20160816;
        b=Kb8p4/KxPERh9Wx8mIfRv8Xtt7dwupBZa6t+uwaomamvetFUH1Bbu01CQpsmyiTCOa
         3SPH4iKibgZd9/tlDou0tuHcCOGYNC1uxA1NgHfoP8zEW/76MsgprYJQAWiyEG7G6ZD/
         ghVSn6dHbi7Zb3WyGybrVev1uuu2GHmfxZMO46MrgPqeDkE1rBNaYIlKWbrWi61vGNmd
         Enk1/5e0Ob6+5lDrx8fXk+OrNT4tv9mBG6Twh0cPgtsrgLCv+etStp1AcOds90w4NXra
         tRyeOnPhxXBK4PPEhslfDXisWKcCTbRSxAflZxKk1jqvQ8yID8mBida/2yKw5V6MTXhw
         P3mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ilF0L5eSgEyyYaXFSbddhy3bpJmKXINzOGRCtzZ9aSI=;
        b=BvUHZRoLBz4BWoy30xX5a7ooYYXN5bj5aeg9UPFNL35+ncwlZpCdLACbnA5f+d2c4D
         beQrJ1Er8dGjEk2QDVwBxxYbN0FWy0+Rg1wOKlMXXSNWXi0sLktOtYYft/snWIJpbC2y
         vuXIzVwlxywhVoZiqkoy5qQoCX5jgRncm00br+SiL8+L2Qiv84GmQGKcSScbTS5KVNOF
         iFU+NgoFmaNdcHwOdVfJxAOvcHYIF3IUiCp+qcqPqXrmN8Klj9aPTy7yuj5B8JGd8z3M
         0PKyiAITfqiPAUc8FhoHVxBb9ZjN/chOs41gSQ2Z0f6jXkI7wY3vkmBY/RwbrpP4K5bq
         H2VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hikw7GF8;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 21si49887909pfo.138.2019.08.06.09.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hikw7GF8;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ilF0L5eSgEyyYaXFSbddhy3bpJmKXINzOGRCtzZ9aSI=; b=hikw7GF8n+d60ROTxLBfZvDIvt
	lWGBz9OAMJ4nVqhoGyF4yYzPEmJ50hwItuCKNXTUScMYDtgdD6ZtVj3qYG7++ZGVk2Q9ltV1R4RHc
	VqGAKowzDVzvNZ7dsp+tGHAjV0mYw5H5M1cyez5eq1JzrGvXUiS7lApWz9SBQ/bibG532unQjBY13
	ObQgADiTMFp8hoPx6SpBkPuWGpWTBCAbirU5kADQ6QscvnjbmbVC0GEWrdHpMovVv26BjA8cMUAt3
	tEUUxB/GXyk0FXHu5Z89DXWfkmfju4jCd9ICs/SYWALm/vkEEUwmU+M8iyftX3yZHv5hdll4Qa2Lc
	j6pVLf9Q==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yI-0000Vj-LP; Tue, 06 Aug 2019 16:05:59 +0000
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
Subject: [PATCH 01/15] amdgpu: remove -EAGAIN handling for hmm_range_fault
Date: Tue,  6 Aug 2019 19:05:39 +0300
Message-Id: <20190806160554.14046-2-hch@lst.de>
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

hmm_range_fault can only return -EAGAIN if called with the
HMM_FAULT_ALLOW_RETRY flag, which amdgpu never does.  Remove the
handling for the -EAGAIN case with its non-standard locking scheme.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c | 23 +++--------------------
 1 file changed, 3 insertions(+), 20 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 12a59ac83f72..f0821638bbc6 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -778,7 +778,6 @@ int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo, struct page **pages)
 	struct hmm_range *range;
 	unsigned long i;
 	uint64_t *pfns;
-	int retry = 0;
 	int r = 0;
 
 	if (!mm) /* Happens during process shutdown */
@@ -822,7 +821,6 @@ int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo, struct page **pages)
 	hmm_range_register(range, mirror, start,
 			   start + ttm->num_pages * PAGE_SIZE, PAGE_SHIFT);
 
-retry:
 	/*
 	 * Just wait for range to be valid, safe to ignore return value as we
 	 * will use the return value of hmm_range_fault() below under the
@@ -831,24 +829,12 @@ int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo, struct page **pages)
 	hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT);
 
 	down_read(&mm->mmap_sem);
-
 	r = hmm_range_fault(range, 0);
-	if (unlikely(r < 0)) {
-		if (likely(r == -EAGAIN)) {
-			/*
-			 * return -EAGAIN, mmap_sem is dropped
-			 */
-			if (retry++ < MAX_RETRY_HMM_RANGE_FAULT)
-				goto retry;
-			else
-				pr_err("Retry hmm fault too many times\n");
-		}
-
-		goto out_up_read;
-	}
-
 	up_read(&mm->mmap_sem);
 
+	if (unlikely(r < 0))
+		goto out_free_pfns;
+
 	for (i = 0; i < ttm->num_pages; i++) {
 		pages[i] = hmm_device_entry_to_page(range, pfns[i]);
 		if (unlikely(!pages[i])) {
@@ -864,9 +850,6 @@ int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo, struct page **pages)
 
 	return 0;
 
-out_up_read:
-	if (likely(r != -EAGAIN))
-		up_read(&mm->mmap_sem);
 out_free_pfns:
 	hmm_range_unregister(range);
 	kvfree(pfns);
-- 
2.20.1

