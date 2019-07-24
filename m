Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CA09C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25E0E20644
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="U64OF7RD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25E0E20644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE9D36B000C; Wed, 24 Jul 2019 02:53:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9A486B000D; Wed, 24 Jul 2019 02:53:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA7348E0002; Wed, 24 Jul 2019 02:53:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 819BD6B000C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:53:13 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so23489072pll.22
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:53:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=af+9ggTzrooQN+U8Gtergf04cohbJyE/zmcmEx1oVXE=;
        b=hJv70QHQBC4myk26gDVupYcXXHMtXV0BUCP9yQcowBJA5EqlSPgCupOSzdCJZdhuDz
         kNdj0+mTtabyyAAAiHICZYzhNVSMopYycuM9YRnGFOIWUeVYVbSOskWQygoLNb2v8sn9
         KoIsiAwAb/fRypwuR4u/rGTHKYv+AllUv15jlrfhxlnp6yGdojztPoS8LY4m7zK9EL9W
         N4YyJxk/hir8cLjayGPbSNZIX62fL0h+QnzyO7B5arMCBVvgfJGXavc15ZDjOAywJ6Hi
         JF6P8MwnGevbch0Y9mg4TSjT9jRHXT6rqEfodsbs/WcElPHcu3nxK2E7qPC7nPbTZJVM
         rdtg==
X-Gm-Message-State: APjAAAW7l5HcPxFyvydnCxgyCj7dFnMfPmPx9jg8vyGOIHt6eDxXMBCj
	yTseodx6eeYMg51ztsgH27blQ1v586j+2pa02pWfZqmIHRM9W2Zx4LLb/Fn7OJHDBDNFYhwLWtT
	wBu/L7RM/VW2CJfR9yntSHz3+qTPPSNSBzF2dqV5wJICg+uOQduwgB9dmQpIkELg=
X-Received: by 2002:a63:124a:: with SMTP id 10mr79407345pgs.254.1563951192803;
        Tue, 23 Jul 2019 23:53:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNqrJyj+LYYW1U7WEU67QtyTBVu/Le/Olv1rkI7sudsILCb02xsFfa++MwCCXBaxvIWc2y
X-Received: by 2002:a63:124a:: with SMTP id 10mr79407264pgs.254.1563951191259;
        Tue, 23 Jul 2019 23:53:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951191; cv=none;
        d=google.com; s=arc-20160816;
        b=a2LG9JuirW27+H0uGehJYj9OJT7ji7YROx2h4d2QpIwQqAGFIUdiBtnBfMMnJmn7eD
         ZXV24GciO0ESnGP+SDx83rAO3LW5XW28a8IS2achNbd5cFQ15sX6r5Mls3a/Bj8W9yuB
         uOcfnHoQ1Uv28UMfL1WQ05NZuWjJQvBNRljIk4JmHODAxzHK4SoofYGt0q5UxqBTyf5m
         9a+lpsRztYB40P8ag1BVSCG8vizmNEVApoUejOwk+3uSbkVOHTiao96gd69KQrGeBWZ9
         6jKcKlD5lZf+WkL0na8fv8tgzsYrLgzrzB/c5y9kEw/oJRe0zgyNLZc+egYim3MUwUlw
         G4tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=af+9ggTzrooQN+U8Gtergf04cohbJyE/zmcmEx1oVXE=;
        b=Xs0Hhg7SfC1fIXpX1kdbItdzx6bd0RfMDTffbYiC0dVyHkFpa10xtr6rX5TubC6/fH
         7XQTk5SzWwUSWOqrGqP94uTC19lKxQL73+gpaKpAvfxTxWKcG19yn6woeqAStwt1L4e8
         NZzQVs03J2TGNxbHQ5JPsxQ6g+10T9DudbJNeTzkByqTSu4wgIv2ANYFocQLTAAaa5Hv
         LWaVpROs+NPb+xSDoQbTBwclqg9jyYwdg3ZcOAtU1xgxwSYceYiCoRMViRKkDFQw3Zar
         EhBiM6Bk5zjAeh8gz/Js1Z99+XpnqPFBSf/mTZoSiU8hLwviIEvvnStiXZQ1xIwd5ydA
         2C6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=U64OF7RD;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h36si14033430plb.199.2019.07.23.23.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 23:53:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=U64OF7RD;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=af+9ggTzrooQN+U8Gtergf04cohbJyE/zmcmEx1oVXE=; b=U64OF7RDtIK4aPH8u2Yfe/rBOz
	hVAMPpGIhOwvLO6YSlRDICqyAY7C5IJgR8qZmyRdzrygG4sxifcodjj4gVKlpDoRNbrlF7RbPGDOU
	oMZbjtjiEIovtu73ZIBM+/nwUvVOK5QMGVdeAz6w4nhu8fetVX4ejYQYQWfedyluBtF1D6JYOENMp
	l6QRVkOsSz78O1fPMZBUPxNpteExp9DlQHBp9YHkk+OS2Fp6HTFbCTff1LvoMdXdYELaaNGZRR/LA
	Dt3vndxXBqfKVFdVPR89amKow08m2weDkcEgz3UrRD+ic/YC1nffLvntUV+JIgW7TE96rzOm4ZszC
	7DeJxm+A==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqB9A-0004IS-3A; Wed, 24 Jul 2019 06:53:08 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/7] mm: move hmm_vma_range_done and hmm_vma_fault to nouveau
Date: Wed, 24 Jul 2019 08:52:53 +0200
Message-Id: <20190724065258.16603-3-hch@lst.de>
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

These two functions are marked as a legacy APIs to get rid of, but seem
to suit the current nouveau flow.  Move it to the only user in
preparation for fixing a locking bug involving caller and callee.
All comments referring to the old API have been removed as this now
is a driver private helper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 46 ++++++++++++++++++++++-
 include/linux/hmm.h                   | 54 ---------------------------
 2 files changed, 44 insertions(+), 56 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 8c92374afcf2..6c1b04de0db8 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -475,6 +475,48 @@ nouveau_svm_fault_cache(struct nouveau_svm *svm,
 		fault->inst, fault->addr, fault->access);
 }
 
+static inline bool
+nouveau_range_done(struct hmm_range *range)
+{
+	bool ret = hmm_range_valid(range);
+
+	hmm_range_unregister(range);
+	return ret;
+}
+
+static int
+nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
+		    bool block)
+{
+	long ret;
+
+	range->default_flags = 0;
+	range->pfn_flags_mask = -1UL;
+
+	ret = hmm_range_register(range, mirror,
+				 range->start, range->end,
+				 PAGE_SHIFT);
+	if (ret)
+		return (int)ret;
+
+	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
+		up_read(&range->vma->vm_mm->mmap_sem);
+		return -EAGAIN;
+	}
+
+	ret = hmm_range_fault(range, block);
+	if (ret <= 0) {
+		if (ret == -EBUSY || !ret) {
+			up_read(&range->vma->vm_mm->mmap_sem);
+			ret = -EBUSY;
+		} else if (ret == -EAGAIN)
+			ret = -EBUSY;
+		hmm_range_unregister(range);
+		return ret;
+	}
+	return 0;
+}
+
 static int
 nouveau_svm_fault(struct nvif_notify *notify)
 {
@@ -649,10 +691,10 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = hmm_vma_fault(&svmm->mirror, &range, true);
+		ret = nouveau_range_fault(&svmm->mirror, &range, true);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
-			if (!hmm_vma_range_done(&range)) {
+			if (!nouveau_range_done(&range)) {
 				mutex_unlock(&svmm->mutex);
 				goto again;
 			}
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index b8a08b2a10ca..7ef56dc18050 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -484,60 +484,6 @@ long hmm_range_dma_unmap(struct hmm_range *range,
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
-/* This is a temporary helper to avoid merge conflict between trees. */
-static inline int hmm_vma_fault(struct hmm_mirror *mirror,
-				struct hmm_range *range, bool block)
-{
-	long ret;
-
-	/*
-	 * With the old API the driver must set each individual entries with
-	 * the requested flags (valid, write, ...). So here we set the mask to
-	 * keep intact the entries provided by the driver and zero out the
-	 * default_flags.
-	 */
-	range->default_flags = 0;
-	range->pfn_flags_mask = -1UL;
-
-	ret = hmm_range_register(range, mirror,
-				 range->start, range->end,
-				 PAGE_SHIFT);
-	if (ret)
-		return (int)ret;
-
-	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
-		/*
-		 * The mmap_sem was taken by driver we release it here and
-		 * returns -EAGAIN which correspond to mmap_sem have been
-		 * drop in the old API.
-		 */
-		up_read(&range->vma->vm_mm->mmap_sem);
-		return -EAGAIN;
-	}
-
-	ret = hmm_range_fault(range, block);
-	if (ret <= 0) {
-		if (ret == -EBUSY || !ret) {
-			/* Same as above, drop mmap_sem to match old API. */
-			up_read(&range->vma->vm_mm->mmap_sem);
-			ret = -EBUSY;
-		} else if (ret == -EAGAIN)
-			ret = -EBUSY;
-		hmm_range_unregister(range);
-		return ret;
-	}
-	return 0;
-}
-
 /* Below are for HMM internal use only! Not to be used by device driver! */
 static inline void hmm_mm_init(struct mm_struct *mm)
 {
-- 
2.20.1

