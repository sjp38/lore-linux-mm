Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E221C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44B2F20679
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ki48yLXE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44B2F20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E54628E0006; Tue, 30 Jul 2019 01:52:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E054B8E0002; Tue, 30 Jul 2019 01:52:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1E698E0006; Tue, 30 Jul 2019 01:52:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA2C8E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k20so39837707pgg.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wGT0bIW6ZV4QHMeBIyzrsptb3Nkhx6kX9nD5TRsY+c8=;
        b=KlALUit05vILSIZo8E1Gw5wBnXHtivvpTDOf1T/gycU8I83A51We0WjVOHlnGtvJjk
         ZK39dERRu5pL2W+8otyylkLJu2/YsgYXb+n+s97zLoTrMVMrZjXVokz2Lh2DjMZwAT7K
         ukbMLAdrWN0/0tM9tPe1scTQ/pHspcszUD8L30otOH5/lRAnqXPW/djOtuJcbQI2J2p+
         wpn62YZMFNlrcrm4ae4hrRyzvDsAgl0fjZqIuef7dSAx+PeQ79ZWCfaSruhzrCV2lJyK
         IpxJ7CKLGG4m7pPXZd8owPtxca3RyTvQFb99PLpuJdMnLz6YKhr1pkFu2GUZtlbCDa1f
         ZWHA==
X-Gm-Message-State: APjAAAXLxTlxsKjJEJ/KrkZbTOweIhaN9YEdd28kqMXSSDZA4ZSN8dPH
	G/BTebMC2/Hu9S5J8tx3CYeyOQs/0lOsHLes5wXm7P2x/y3ukLHmt9ca92uOGhj6zIGj76pzOvt
	MnlVwdSfeZFUEWAlF5zZHgANf064zDd5FU/nHnl2UiwaSXW10Lmo49aW3SI7tYoo=
X-Received: by 2002:a17:90a:258b:: with SMTP id k11mr110679085pje.110.1564465942225;
        Mon, 29 Jul 2019 22:52:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzF2Sd1a49bfYN6QbP5Ddkbm4vhX0ggad1HfNDN2VXracneiQHJg2qivt+6KO21d7nc/wKq
X-Received: by 2002:a17:90a:258b:: with SMTP id k11mr110679063pje.110.1564465941540;
        Mon, 29 Jul 2019 22:52:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465941; cv=none;
        d=google.com; s=arc-20160816;
        b=FUXUzREsjs0xpww/KQJUMm6/gov5h/DTCjLbqn/VoGk961+h1SnF9E+5b9AnhOZ3iw
         d8RXebtZFN7PVPiOt3HN/K0b2fGnUwmK+FHLFM1Hk5Fw3F6RspJGPNN/UjBsT8Sy8DRp
         ahLwd87rBovSmtgcIx0LgjWy3K7FalPcNUYyKy2U0ax2MhkJrDUwtTayvgLWqAzNibmk
         N+EublLsNtaaaUe/4fBiVBUMHhFBdX1qteRq/wgsB4NTrlPNylGhvqAwjZciWwzmYpGh
         Nr8W/kFCL8vHrgEn+onFmfuuTp4bKLKGaDzP/pa6PNUQAjcFhsG8gJZZhxYNHVNifcEK
         twyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wGT0bIW6ZV4QHMeBIyzrsptb3Nkhx6kX9nD5TRsY+c8=;
        b=B5C08SxIWNOEFalU6elc4sNKQcLkAq6JUdihIBEsJdehTf3Wk3vFJh9O6xGvDQN0hO
         zNhX5nr+y9/Bpn5VmiS2Ei7RmWommwHGoIVIEJtOC2T+3qaJ2sCfvPvR7W/PNrSBp2hJ
         RGIirPz8MGcZbJ3zwMw0VfJmguQuNKZkvfY2ZJzWwsCyNhou2IcOWzABKz3bMqdDrdLU
         4/TjKOpwy80u+3YQycGAmDFUaLv59c/83Tes1PLgKaa3sWGRQ0y4wAF0+JuXT/8FDTj0
         MJKGWG5JMY0wh+SMLhqED3kvZuxWqvQQrFGuZq/SYGOhxVZHeBYxt3leKnqrLwZe7Hyf
         bseg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ki48yLXE;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 205si1134069pge.295.2019.07.29.22.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ki48yLXE;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=wGT0bIW6ZV4QHMeBIyzrsptb3Nkhx6kX9nD5TRsY+c8=; b=ki48yLXEl1xJO9gV+39wOL1+y4
	wZUPYoqzhuNLoAUej9SJNFqjxYoDfeF+zcoWTFIq79SU2dw9V4rtDFH9JYB6dp5qDlHOfUF6g5GUx
	JPpQ+gBYb9/5cNNU1yw5rxdau5EGWyoD1usdNNwqaDiB2NAzGKDv39L59sbM/rDJL0O/c8V8icRLO
	IDGx1Argn4Mazv1HFxn+KxWQbirB8spS5aq6oofxF4YASh2sIDt4wCApTnUblx5u77wLLZLq+Mq8q
	EkU5EF5o8yTZ2SfJUnTVtafXCPfDL7NTm4L9dySd4Nqc3T4K/jP1nQG6ETC9e6EK/1Vr44X4BbE1V
	nstFkRew==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL3Z-000154-Lg; Tue, 30 Jul 2019 05:52:18 +0000
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
Subject: [PATCH 01/13] amdgpu: remove -EAGAIN handling for hmm_range_fault
Date: Tue, 30 Jul 2019 08:51:51 +0300
Message-Id: <20190730055203.28467-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055203.28467-1-hch@lst.de>
References: <20190730055203.28467-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hmm_range_fault can only return -EAGAIN if called with the block
argument set to false, so remove the special handling for it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
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

