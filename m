Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B07DC5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 254E42145D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Sh+xg97C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 254E42145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D74F46B0269; Mon,  1 Jul 2019 02:21:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFD1A8E000E; Mon,  1 Jul 2019 02:21:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B52BB8E000D; Mon,  1 Jul 2019 02:21:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f207.google.com (mail-pg1-f207.google.com [209.85.215.207])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6F16B0269
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:21:14 -0400 (EDT)
Received: by mail-pg1-f207.google.com with SMTP id s195so7030531pgs.13
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:21:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pfzb7DKQGxSim4j5P5NViAehCYDnD7twhlehxZF4/mk=;
        b=Zw6VShdveEEhk2CYkFFAmxDzpjK+DpY6ZOPJf25GPPvdRSpB/lLsI1dh4PrT1NQ3WW
         xBhMdMzyIkD03wrzq3tgE3HgmjCK9aFEj27FdEnOFrYO6JMcXJCxTdfTuZKAD/9fQhI8
         NzTW4ZubZbRFHzhfE/o7BtIChKC3Ff2X1DpXXZ8BhKmFxeMzKO/nPFEKAa0R58dE2EWE
         ZnOL+gCDVx0EJzHZ3lMdyq7uBX5SzgnlWIRtmF1nvxzTnIJQrF/oYkXtItoeYEd3QbJS
         /j8gYJZKgRR+Ll86b4sdCC4/WIPL6a1ue/bsJCLtbGRy2su/reosZVoQU7OtOm4gNS+Y
         yxVw==
X-Gm-Message-State: APjAAAUKabBDpan/ID5Yn1n9CKgzvRhc3vpVJ6tYKKcOxRh+X0wgta+A
	hZ+6tTs9E1bt85zsA6ngxOpc0ZD8Q+PIzycJbHzfB9YjbSbDjvFCuONtQsWV1RvZLTQvcAMnTRH
	GsEaPtjvrFOPjAHSb527cWKTNhh/qXadvncqJ9IjCrZKIh4ji9cS/MYUcTsX8eb8=
X-Received: by 2002:a63:62c5:: with SMTP id w188mr11577470pgb.129.1561962073969;
        Sun, 30 Jun 2019 23:21:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAeZ7TbJMTPYC6IAZK4FDBS07Jvwe7mpvRv2DR2DzhFbcH0ztrdMrW9nQZMCNZ6RfclRL4
X-Received: by 2002:a63:62c5:: with SMTP id w188mr11577412pgb.129.1561962073143;
        Sun, 30 Jun 2019 23:21:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962073; cv=none;
        d=google.com; s=arc-20160816;
        b=qUuD7qsPhWNdwiB0zban7Xj5DxHyTvYx/JgWmvQOHmkevNCuoW6WM2oU4Z2DaBHS3j
         ow7Xqw0E3r7LkeMjU254QjVAzeDj2H8YNqzr+AuTXxauAer/oQ6ktjXlWQ+BNrKpNfDw
         d0OJ/h0P+FmoY7FtmQ4rVf7drD95aSluH1iaDOyqe2D7Ox6XIT9Ne69zAefT2nC6VxcF
         Sv1LFwvMWuH3kPM22E8TvwSmpu29L/VAAXxN+KVVkSJrt8iYhW+NL8HRDM6xDwfqYtlo
         TYQL3a1I2D1YDmJZ21Z7GlUAwFUwuB5NonoPrcwXTd+yfocES3fLZJmTIv2gJTChpAi5
         RrvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pfzb7DKQGxSim4j5P5NViAehCYDnD7twhlehxZF4/mk=;
        b=gXzpDMjkHjoS4YdsnV2ikognKdBbYFw6AtLxU+qcvTw9tS+3fcOaBR2ta/veGRqrY6
         cb+YCnsQ36IsfuI1CYthMAWy/l6dEuI841gVkTtJBp7bUICW47owBICdhgAlY4YTEZRq
         jMjjSu2hrm6+3vEek59gEKl2NGhEpPIhmEYP7v1KMWsyYwe/dfBrw9k2stUeeyFK4XNI
         R8/t6zA1RjFsluRhEL0w3i3q+O6fw6/w97M1q7qhPqscACK2+vz+gFDMNkLkZUYqF7Vg
         1xoiyhPy+f2uPNcBfaGFAAPxhEK2Tna5pj7mzgmpzzPqAfLh4cSExLMrAnA1AdHPn7eX
         wwZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Sh+xg97C;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s24si10371036pfh.227.2019.06.30.23.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:21:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Sh+xg97C;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=pfzb7DKQGxSim4j5P5NViAehCYDnD7twhlehxZF4/mk=; b=Sh+xg97CAaxfCofmcqXvvWAphg
	/FC2T86IXntWnlzo7VNQ0a7nvzkSU5M8Vor1yTinwL8XHWySWdAmf559BGxhLygWpZkXa+jWcNQpF
	yiqysTo4IQb6Xpt1GUM99QV4WcYAL16tbM/uA/Iri95ouR7gdrojQ0Q1FFO88taxm3tHE0W2P75Ls
	uFALgpav78FJe/L2HvoUQuW9Nx75lFKVz+WQqk7Svyo2Nz6faU7+QmTVPfGCiVaW1HVgnmdn0SnRa
	bWnACDf6hys4JLjnsuvv+pNy9oG68GRh5KBdYs5IrjoRydXBE/posTx59K1lsO1UsoEGdwy2Of8G0
	zfk6CmHg==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgb-0003W2-Ks; Mon, 01 Jul 2019 06:21:09 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 21/22] nouveau: unlock mmap_sem on all errors from nouveau_range_fault
Date: Mon,  1 Jul 2019 08:20:19 +0200
Message-Id: <20190701062020.19239-22-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
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
 drivers/gpu/drm/nouveau/nouveau_svm.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index e831f4184a17..c0cf7aeaefb3 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -500,8 +500,10 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
 	ret = hmm_range_register(range, mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
-	if (ret)
+	if (ret) {
+		up_read(&range->vma->vm_mm->mmap_sem);
 		return (int)ret;
+	}
 
 	if (!hmm_range_wait_until_valid(range, NOUVEAU_RANGE_FAULT_TIMEOUT)) {
 		/*
@@ -515,15 +517,14 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
 
 	ret = hmm_range_fault(range, block);
 	if (ret <= 0) {
-		if (ret == -EBUSY || !ret) {
-			/* Same as above, drop mmap_sem to match old API. */
-			up_read(&range->vma->vm_mm->mmap_sem);
-			ret = -EBUSY;
-		} else if (ret == -EAGAIN)
+		if (ret == 0)
 			ret = -EBUSY;
+		if (ret != -EAGAIN)
+			up_read(&range->vma->vm_mm->mmap_sem);
 		hmm_range_unregister(range);
 		return ret;
 	}
+
 	return 0;
 }
 
@@ -718,8 +719,8 @@ nouveau_svm_fault(struct nvif_notify *notify)
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

