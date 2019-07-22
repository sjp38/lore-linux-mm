Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0701C76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 680C32190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KBrWujtJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 680C32190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E7FC8E0005; Mon, 22 Jul 2019 05:44:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FC1E6B026A; Mon, 22 Jul 2019 05:44:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FEE68E0005; Mon, 22 Jul 2019 05:44:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F35EA6B0269
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:44:41 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q10so130139pgi.9
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:44:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7FsIrxY02SwL66nSI+mJn6yPhyHFx4vF4xrsx6w9rHE=;
        b=nFKSgzGTm4djdKxq8OvRaziEANcG51ocmdE4iRTiAmDHqxBjU1+VQV5gaNqy1gO4Y4
         a2ly/pbsXzstzPgK1sVLLKrELJdSLsXsHVkf7REYgyhppeBVr3w4ba+wFf9Pki+b5oMf
         D5gJl1HXB6fWr0VQv4erGqyqK6Sv9KeGzij1GIDGmpnJ38zWM3+UaJmLCbHfEsU5k649
         QvXzwR9Ry8YdlUxh7T625LkToaoD6KVqPCEv7xcsMBr0NbkeO5/m7E9iZVInaXV6piOh
         H8OhI4MBEDUErHVYC3xUeQVZinjH/lH62L2aj+M4Kttau8C/p+QVWTXzR4a5fgbp8qzW
         3gLw==
X-Gm-Message-State: APjAAAUs8RuPNVgvno2E6qVOxnooIHyJSNhQcAq64F7Xhlg3QuOWu6Yh
	SSoU1vxjXhxmAxVv/UDTh6HJ7cQnqIgyw5ZsQswPEsfiaJ2G+5qztHKFXsFMcs1wwQiONmThpJj
	1Lkev13xGQNH8gt8IqYFVpIm9m5ghh1qPZr6tPdM42OhCbhEigxCD25acqlAL8Y4=
X-Received: by 2002:a63:c508:: with SMTP id f8mr72160163pgd.48.1563788681575;
        Mon, 22 Jul 2019 02:44:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrnU42Tvc2xVfkCLyZJwcg098GKFNpEshDy8AwvVLBfEnpPxPMJOlyCPJx/8DXLPosX4x+
X-Received: by 2002:a63:c508:: with SMTP id f8mr72160093pgd.48.1563788680812;
        Mon, 22 Jul 2019 02:44:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788680; cv=none;
        d=google.com; s=arc-20160816;
        b=IzkaR0ZI7QzOsJKWw0h1NBLXaj4VuQo2yaaXthX/9fX/PTjmgJykWgNgvX1CNdE99E
         mN2t+zzwILPOtCq9ai2RH9GndZdZMNZolFL37Xq/cDmpT1Yyhb2haYnII697Db/vSJsk
         I3GAD8WU71VNMzNj0Non98b+Q6455UMkd6N0v9zeO957iXNBSeDRdLe/qXcLitMSYCOU
         /NNTzimEHVVGom22ddP0IInJqVUahX4BH2gepFRVKof4G76mTkwmw3fLjVfE9WcGqGkP
         YICkwH0E/kw0wCxyZuv8cHReyY4E+wvFH8sSEBE70MnHzgUond6iWDeRch6pv4WsuR0G
         IKEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7FsIrxY02SwL66nSI+mJn6yPhyHFx4vF4xrsx6w9rHE=;
        b=bBmD5fQfKiq6dX1TzuQu5cyU/O3FdzL9nMYp5NT6uTXs5sAG+PF0OsQF5G2uBWxL4V
         nSEMl1nq61r+lW6h4h7zSMD8J1CPjJ/ojiXW+FkqYJYlys7cbarnBBJrAam18plAwWL5
         wk61ykyqbTpenL90h/KnIw4sFxCziDLcGoo5uLHiAMhs8Zh7y9FQ2TGkZMNo6dko+0cq
         iUIzJTTprIFGuwFuFT7z8EfU+kkOcMNCyxhhP1YzmDh76X33xZuBY1DhsChIrpIggEXw
         y7h7LApmj3r5HC/Hph2qr8MYjMciU+VJwUbdNdsOE6fV0fVByYuNxbv7B5KaqS8q5WsF
         lu9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KBrWujtJ;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f131si8064637pgc.265.2019.07.22.02.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 02:44:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KBrWujtJ;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=7FsIrxY02SwL66nSI+mJn6yPhyHFx4vF4xrsx6w9rHE=; b=KBrWujtJOcYc9XfEbicugrh0Ld
	WNtLBZQsXjaV9zG4rza6opsoXkHSVU7X6uZkzlxFHi6MsHHy0+PcuHhana1BszUNp8Vz6cBez9Ue4
	lR4CHnIFsGeZ/Y9okLdcFzmr7AM8zdJeoz88kBt4imZWSN9mspryETy3V896mi/j7diZq7x5xf6Xl
	9wcVv5WzOBsbGHk8ZDhV5+bt1qqSHyVvaTrKA4lFLINhGHFemEvdx228VplD4T33YKY3JBy4Ybui8
	rV5r1H5tG+d8FVqHsVlNuFyYCzShgyzz/le6tL8pmGTUPrA72N4i8B1la8aDBZTfhXBNtMdEklZ69
	BqQvr05Q==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hpUs2-0001ss-AE; Mon, 22 Jul 2019 09:44:38 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/6] nouveau: unlock mmap_sem on all errors from nouveau_range_fault
Date: Mon, 22 Jul 2019 11:44:24 +0200
Message-Id: <20190722094426.18563-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722094426.18563-1-hch@lst.de>
References: <20190722094426.18563-1-hch@lst.de>
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
 drivers/gpu/drm/nouveau/nouveau_svm.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 5dd83a46578f..5de2d54b9782 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -494,8 +494,10 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
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
@@ -504,11 +506,9 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 
 	ret = hmm_range_fault(range, true);
 	if (ret <= 0) {
-		if (ret == -EBUSY || !ret) {
-			up_read(&range->vma->vm_mm->mmap_sem);
-			ret = -EBUSY;
-		} else if (ret == -EAGAIN)
+		if (ret == 0)
 			ret = -EBUSY;
+		up_read(&range->vma->vm_mm->mmap_sem);
 		hmm_range_unregister(range);
 		return ret;
 	}
@@ -706,8 +706,8 @@ nouveau_svm_fault(struct nvif_notify *notify)
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

