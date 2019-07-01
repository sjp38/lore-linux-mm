Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75735C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FAA32145D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HxhHD1pj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FAA32145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8DF76B000E; Mon,  1 Jul 2019 02:21:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A424E8E000E; Mon,  1 Jul 2019 02:21:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8912B8E000D; Mon,  1 Jul 2019 02:21:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0FA6B000E
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:21:07 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id a5so6764535pla.3
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:21:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NOvUE3MK4PBUVZYjodBNHK+lKTK0X5FfG0LU1tN7KYg=;
        b=ZHtfuFn6gO8ebsqhyqzFR8qyi2QQe3/xHoxFF3ZKjshEpe4ViBjuQmkls/oyf4YDW1
         f6pM/1m4xRQnKiHSy+qnuIbA1ja6vqzYFrj0OC8z/gcxgZ8BRLgXs71o63LMaHwGHbtQ
         UnyxqHW1I6OFNrAXRrHhSRBuzXJbtdT9TVlEkdQwhEY7DhlUIYwSbVORdPHC2ACW4z0C
         Yk5ymM0fnnXi196tMxeJjlv2vzlvoFuUlrKYo/LtM7T6CVp3qunhTDRR6NpHSZblsv5n
         pUdctKsSKnTEGAfZ3iFnD92IRTZTSk0CJtTqLf/Ax+jVd3yAukKF3+uNKidnbvz4cSWE
         RvaQ==
X-Gm-Message-State: APjAAAU4jqk6u0fLdRoJDeOKfvpmaSAPVmWwCtRQn892oXQa1LdgLDlr
	zsqOUf0f85kCP+2rArkcP997ZmOnMH8jL7P4jdwlr0bT7tu6Z2T2HMfVTLepkpo5/A6MpDBP3aN
	3ETBGTeo6Lns+h4AHKEshYAr/s7ld6Ky/weU1cUiDcQmClUhVBtGN0lBPUMcBVpo=
X-Received: by 2002:a17:90a:1b0c:: with SMTP id q12mr29304602pjq.76.1561962067001;
        Sun, 30 Jun 2019 23:21:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKKVt/bkFxoycGIIALfVmyExiiyvvXL/s61xpgVKmrp/YV9a43cxetcD4X3yW4aWhrdxLR
X-Received: by 2002:a17:90a:1b0c:: with SMTP id q12mr29304510pjq.76.1561962065816;
        Sun, 30 Jun 2019 23:21:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962065; cv=none;
        d=google.com; s=arc-20160816;
        b=JNKQdKeZZLsLQkQ8iI5hgVTrro/ovXhOUkShtVj/yyRE7RggUm06x8f3jUZ/uIWO0C
         ZY4NuHYBreZVw9jU84GtZCbpOTlmxX0Gt/vi0cbFXn21PSfoFkCDBVLBx4ggtB+m7DJo
         Ijj1sjU+zf3ACNk9iTdHx9iHyOePLqaqfLJf/hbErhWm8AMiODFLl65A0sjMcdDoBPsC
         YsP4t2vZVaK1lLIS17Tic4BgEtLueUfOPju772Y39/ppQ5JvAZJysveMRb1NPPh2DaK/
         XYQ3tZcU0qYEltVFZPPVS7nETKat4WWeQoYJh0PAX8v/IAPa7B6YIjL1PN++E197+0mJ
         lDHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NOvUE3MK4PBUVZYjodBNHK+lKTK0X5FfG0LU1tN7KYg=;
        b=DoPxG6RVEUW1NhNvW9Pr9iyyDGJ9B36uri2l04hZjdga66sVoDgnrmQC6HW+7q8RXE
         Z3eTzeCtBsf6SjpopD5zvck6NxODSIcuPGuZHJzTKvt4zx0kwaNj2WVgxJFKFGjRSvU0
         nHLBmXw6GWyyghxiIGNqxNlDElbIpkOh4fBq5NiAPe+kI4B8IXeHJd/JA3wM+7QkBKHd
         snkDnnjaZXNEYxIvkE+q5wa7PaTXQLNlynVk9WHTBVoX8aictcD6fpR6mc5iUSOJWA98
         VjMPmF6jOU6CS3We57EB4xjzYcXCYfNmpAOCGeX2grDB8YegmNh8p6lBE6vkCnm8gWW3
         iy3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HxhHD1pj;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i5si9320961pjk.57.2019.06.30.23.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:21:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HxhHD1pj;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=NOvUE3MK4PBUVZYjodBNHK+lKTK0X5FfG0LU1tN7KYg=; b=HxhHD1pjEjG0nbECxGzrXlhFSd
	pYZ6FWrI65g6HDmRODhykjBJp0i+FO3Uewll57/9um1FFD20gH4ojUuQNOIz01ZkUrcxNvZkRgUQN
	d4BYKfrRc9cM6YWvqKXEPU/9hSQZ8afF1Nc8uwN+hYuTZ6mIozhJx0vvBN4rmktvAuaDt+9DRD7YH
	Yt7ORdztBsdCgvFNEe2JgqOp59ScdlPwB/6u5xSmz78zlZR86fRRWnEUBJQYKEd5eEJyrKgYxL8Vc
	B6Ul4VaxPsIcxuFe3qolUUFbeMuW1AiRr8uD2U7S106Nnsa8IJBj/Ut4/rYC3XSWoJDmQO9jELO9k
	1eio7AzQ==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgV-0003Cs-5p; Mon, 01 Jul 2019 06:21:03 +0000
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
Subject: [PATCH 18/22] mm: return valid info from hmm_range_unregister
Date: Mon,  1 Jul 2019 08:20:16 +0200
Message-Id: <20190701062020.19239-19-hch@lst.de>
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

Checking range->valid is trivial and has no meaningful cost, but
nicely simplifies the fastpath in typical callers.  Also remove the
hmm_vma_range_done function, which now is a trivial wrapper around
hmm_range_unregister.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
 include/linux/hmm.h                   | 11 +----------
 mm/hmm.c                              |  6 +++++-
 3 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 8c92374afcf2..9d40114d7949 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -652,7 +652,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		ret = hmm_vma_fault(&svmm->mirror, &range, true);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
-			if (!hmm_vma_range_done(&range)) {
+			if (!hmm_range_unregister(&range)) {
 				mutex_unlock(&svmm->mutex);
 				goto again;
 			}
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 0fa8ea34ccef..4b185d286c3b 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -465,7 +465,7 @@ int hmm_range_register(struct hmm_range *range,
 		       unsigned long start,
 		       unsigned long end,
 		       unsigned page_shift);
-void hmm_range_unregister(struct hmm_range *range);
+bool hmm_range_unregister(struct hmm_range *range);
 long hmm_range_snapshot(struct hmm_range *range);
 long hmm_range_fault(struct hmm_range *range, bool block);
 long hmm_range_dma_map(struct hmm_range *range,
@@ -487,15 +487,6 @@ long hmm_range_dma_unmap(struct hmm_range *range,
  */
 #define HMM_RANGE_DEFAULT_TIMEOUT 1000
 
-/* This is a temporary helper to avoid merge conflict between trees. */
-static inline bool hmm_vma_range_done(struct hmm_range *range)
-{
-	bool ret = hmm_range_valid(range);
-
-	hmm_range_unregister(range);
-	return ret;
-}
-
 /* This is a temporary helper to avoid merge conflict between trees. */
 static inline int hmm_vma_fault(struct hmm_mirror *mirror,
 				struct hmm_range *range, bool block)
diff --git a/mm/hmm.c b/mm/hmm.c
index de35289df20d..c85ed7d4e2ce 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -920,11 +920,14 @@ EXPORT_SYMBOL(hmm_range_register);
  *
  * Range struct is used to track updates to the CPU page table after a call to
  * hmm_range_register(). See include/linux/hmm.h for how to use it.
+ *
+ * Returns if the range was still valid at the time of unregistering.
  */
-void hmm_range_unregister(struct hmm_range *range)
+bool hmm_range_unregister(struct hmm_range *range)
 {
 	struct hmm *hmm = range->hmm;
 	unsigned long flags;
+	bool ret = range->valid;
 
 	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	list_del_init(&range->list);
@@ -941,6 +944,7 @@ void hmm_range_unregister(struct hmm_range *range)
 	 */
 	range->valid = false;
 	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
+	return ret;
 }
 EXPORT_SYMBOL(hmm_range_unregister);
 
-- 
2.20.1

