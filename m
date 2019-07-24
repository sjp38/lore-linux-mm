Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6572C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D2C02253D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DAL1H9X3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D2C02253D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 102166B000E; Wed, 24 Jul 2019 02:53:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B21C8E0003; Wed, 24 Jul 2019 02:53:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBF018E0002; Wed, 24 Jul 2019 02:53:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3D5F6B000E
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:53:17 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t18so17688190pgu.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:53:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OKQjQZNsY1fevItiyMnAbjI1iamy6YdinwRbq9yBGVU=;
        b=nZzFNwxCniBhyz4y4hrhpPG/7m18hugxraiztu5MZrxf2LS9aK4OvKF00VJC8TjeHv
         Tq6sz2uXJ0ecCXkZJ3MDjGgmGFVy1pHpC6DfkKYz2wG7VC9KX5InUsPoimPFuB9UDv9N
         lSFS6Ket6bNsiDjSJJKfUebB0pTKW0snsr202pYMY+6YJPV23y9W3to4YfcShyjGWpDq
         SRXq/ficragTNc2a8aeM6kbYYhRDCIw9UopCbpFnuH6BwCt1/HRVxRRzflZKM/GTLgFz
         QC1awDy/ZVpNV7HRRN4pPTOHqwuMeRieTem9uEzRYH6bRuiZpAzJQupTMFifvNLpIjOR
         htWg==
X-Gm-Message-State: APjAAAWqolG3CQIxW0SYwsL6oEWX5G4K8cmFGwVoJbddhMubmJXA51O2
	m5LktaRRhVuWJ88JniU6HA9KMpXMxLegAh/8+KT1SsRfHrKg3YX6VvdGluLMITTLqXVgNAD9eVu
	2zG50aAgFQN13VI5+PtoN6W1ZBpJGXQNNWjj+JF6X48Qd0PuAYtpnAkwSrJ0J08M=
X-Received: by 2002:a17:902:24e:: with SMTP id 72mr42087758plc.65.1563951197424;
        Tue, 23 Jul 2019 23:53:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTeeMOXYsgLoPzw+8fOTgiLW48dEXpiwVu2Q2Y9yt1dvxWZ1UQSKh17K1HE6jzNb6W/IaR
X-Received: by 2002:a17:902:24e:: with SMTP id 72mr42087722plc.65.1563951196773;
        Tue, 23 Jul 2019 23:53:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951196; cv=none;
        d=google.com; s=arc-20160816;
        b=Wf0ZocgoClxOVJ74w/vzxqDV23Jin5FJjzUl1WhauNnK8JENr0uZV61qDy0JWtVVsD
         foqrUZxI76TbOF9syurgde9Z+v4NnT1VocrW4zydYa04QYIo7uhcMQWSHRSK4pvlpKTP
         RUy+rQZvOj1mAqiS99P17ED7pOGGg9luRsrG61I66gU4S1wqdwJfooHb8gewMXhxhynM
         hsC/jHSMUAhSKhI2VwC5zQffzp2mnTrwd5uB36fujbrcq9a7Mb4abnDLkRQakWpCkmoI
         ygOylYlFgJwK/1YyiphWBD3olfcKKxuLqVAU8OIAQLR4RZ5SAFe7nr6Q0ZSZzoTc6lJu
         Uu1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=OKQjQZNsY1fevItiyMnAbjI1iamy6YdinwRbq9yBGVU=;
        b=Q+DxXGMOVRRmwLCq4FuGMiRd59sjQ1rPQmoXKPkRUaXURMABei9HXRidJaICnCn8PP
         qUXzvEkhHhOak6TciXSRRD5Db3DZuEP87o+9GxqcBwihG1buUJ5JprneuG5zOxeTiFzK
         dTUdWU+rQXb6SOBrWnAh6eO4Ro/QgqwoKiAwAwJByUXYVtcS3UPrr67LfMQ/dImcW+Nx
         Q+dx0dRNoI/surM+XrSXyI7e9N1VpnGAiW7lsYJuhD7+CWwZBC2w3GL0D0Zwbd2nmX8j
         t7XmtNc42a0h/QUqeMalWdBWfztSvenBKWHhT51M6FKWn1s9C/wfROeFcrlhkK1DeWzT
         ru0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DAL1H9X3;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m68si18376450pfb.75.2019.07.23.23.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 23:53:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DAL1H9X3;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=OKQjQZNsY1fevItiyMnAbjI1iamy6YdinwRbq9yBGVU=; b=DAL1H9X37yVytHCPB4G34fgHgw
	f4KZFwd9A4d0cKrfI1i7CUJCG840Ln0mEXPdeYL44trM7bHs9qwiHbF3TxxesmvA1fQZMCVdAGThz
	xtwIzl+2xTdBFdk13/H3mgXI4jmkC54OsNOAeU/WscWj8k7rXOcn4o1pVkTc+cVJxW81/EkoywxsA
	mz/Q6TH9iCrd0DdEL67eyjr8RW7uD8RdDPIt7i/GfCybmcD3VJJ7TKRgHPYZeTfjlrdpFVi6sUDnm
	GaJ9+tkhmgc5dIRddICKPRVHZnbLP5QjyZTFXUc1SXOrAo4nsgnuivXn1T4osetkxmYSwdWjkGwox
	SwYGjFuQ==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqB9G-0004Jk-1l; Wed, 24 Jul 2019 06:53:14 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/7] nouveau: unlock mmap_sem on all errors from nouveau_range_fault
Date: Wed, 24 Jul 2019 08:52:55 +0200
Message-Id: <20190724065258.16603-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724065258.16603-1-hch@lst.de>
References: <20190724065258.16603-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently nouveau_svm_fault expects nouveau_range_fault to never unlock
mmap_sem, but the latter unlocks it for a random selection of error
codes. Fix this up by always unlocking mmap_sem for non-zero return
values in nouveau_range_fault, and only unlocking it in the caller
for successful returns.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index e3097492b4ad..a835cebb6d90 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -495,8 +495,10 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 	ret = hmm_range_register(range, mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
-	if (ret)
+	if (ret) {
+		up_read(&range->vma->vm_mm->mmap_sem);
 		return (int)ret;
+	}
 
 	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
 		up_read(&range->vma->vm_mm->mmap_sem);
@@ -505,10 +507,9 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 
 	ret = hmm_range_fault(range, true);
 	if (ret <= 0) {
-		if (ret == -EBUSY || !ret) {
-			up_read(&range->vma->vm_mm->mmap_sem);
+		if (ret == 0)
 			ret = -EBUSY;
-		}
+		up_read(&range->vma->vm_mm->mmap_sem);
 		hmm_range_unregister(range);
 		return ret;
 	}
@@ -706,8 +707,8 @@ nouveau_svm_fault(struct nvif_notify *notify)
 						NULL);
 			svmm->vmm->vmm.object.client->super = false;
 			mutex_unlock(&svmm->mutex);
+			up_read(&svmm->mm->mmap_sem);
 		}
-		up_read(&svmm->mm->mmap_sem);
 
 		/* Cancel any faults in the window whose pages didn't manage
 		 * to keep their valid bit, or stay writeable when required.
-- 
2.20.1

