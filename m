Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70080C06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F509218B0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ifXnrPew"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F509218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7416E8E0017; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F1AB8E001A; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3AE8E0017; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE2D38E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:45:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k20so2086795pgg.15
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UhdzfqB+ekXr0a76nTnfNFoskUSEXQtkHxxjYnKYjTY=;
        b=Hn7JouB8nDj3B3Qrd19phUBpAU7HsslRnORLVXyoB6RIqpDxZ6TEx6648hSjMrc/oa
         hvhqi2yLswsxmPOreKoo7mWkIai39NQ3a+p4W89IK/v6aIVppwo1m6gUDf3HR+OGVdNL
         j4vjkfsdqa90ZIyr/PN693bQ/nxeQlDPsXvfVWobHQOk3z8FlMI1IVAWfOX4UrWhgJH6
         y399Vo1vYTHYFMH0uz6Vt3pjPyyW03QWXwlYe7l6sYwX+uPR4zG16bwdsRYvPZDlnLIb
         veyDB5AaukaLkVz7gTlUuCYM7272RJDj2quk/Etgq+nDrinRJHNWr7fBW3n892pV1Rpn
         OQtA==
X-Gm-Message-State: APjAAAXGFn3jsPpuLJWv9sY9Da4lBtCXsRirwJItjexdr0VFMql9kS4S
	ScTLa48sgOdNrzaMsOjr2YA5d4sIA2Vz/XMrA31oTfh+RJ9FTaWxoh6eYmyMNiRFHfvvQziDTfL
	v2Mq74jGKUFZ/Ikw1JNyxTtcy5yzkrCRFrnUzvtJ8MD7LJV00+syz2y08Of3yk3E=
X-Received: by 2002:a17:90a:cf8f:: with SMTP id i15mr13843959pju.110.1562179510635;
        Wed, 03 Jul 2019 11:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGCqULxv4X/e/F7uQlZCBDHvuIksEZWZqjIFWAYlAYx+jY6aSN5eXUbcBThOyaJImIrg5F
X-Received: by 2002:a17:90a:cf8f:: with SMTP id i15mr13843819pju.110.1562179509151;
        Wed, 03 Jul 2019 11:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562179509; cv=none;
        d=google.com; s=arc-20160816;
        b=wKvNK4t8IfopyUyIyNThXos4PtGt/ezwnS6nFThhPeZNmpcYlY27aZcxbY/Fn19e4E
         IFF+YYhNIWKM1EKW9WNwEAwig5JZDRoiGOx19L11gtrkI9Ig4uVG8M5ZUL76hTQ3Rld8
         ivPqd5vxawF9qHLmlj095lxBRKgdRs9YtaB+E8jbUyDMlcsiXw9Ys8MLU43zBRxmORQd
         +S2M6gkIx7sBCmL5nJ/uyEfgue16jkLFV7EOIZN0s3dbHRT/xt5c/nPjuRiiVIev2kzs
         hSmLfF2Mllx9J3tIOqv31e6wb5hyeDKEczs6rniaZjzFgIHtDK0yCW+cK9UrG4CNDN/k
         vw+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UhdzfqB+ekXr0a76nTnfNFoskUSEXQtkHxxjYnKYjTY=;
        b=Hw/FQ3l1DLHO866NBxHtBUuf/GBhFoOgScVbpDf7w29dNYGsopGKeaBvhIa12MO9AV
         klFBGorCiy+2CICXNj9ILLNU73I6BMVK5K7Kio+Avm4GNJ6sUwgYsjf6nQi3a6ADSpgR
         iCxweYW5jEYp5fuTKuv+F8BuLJJhwVEDVJggeHBQaz5G7PNo3KzbsRYk5NpnhakR/OGk
         +RFqdCNjhLdO8QGWQShddOsBwfttxCPxDt5535lB0cepLkKQaQAm5F0uqud3tbz+DBnp
         ai53nXB7nrkfy3ZtGPuySlphB3TX3L6YrXxqGLFSxC3U91o8zz88cDXfmcgZd8GQcUDN
         xKUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ifXnrPew;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p11si2896758plq.208.2019.07.03.11.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 11:45:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ifXnrPew;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UhdzfqB+ekXr0a76nTnfNFoskUSEXQtkHxxjYnKYjTY=; b=ifXnrPewbD1CglQLGyI4uxM4Bi
	RiD7ef8pTvkaeGMgCXwRB+w7xVgKJnhfkX+crTc4HemDtKC8PGY0IVIqIxKmUFAqHhXGSGoZ/2yek
	rVrVS3JUBKDNluj42cUIdoTxc+MabgCeNPn0FMXxdaQ80U8nDF3epvxhGyQh/BPnY/NrZkwfSNH3b
	SnwTZKxskOMoXVJUq+f0cFgpuylPWmdgEEQVVbdJ2TI5WeVczYMfh0+okClGrDruR9zvWCrK+NaJV
	cBUlIPRXdxbHtCWgA4WUnvt6l3b1E60wpr03FAneVP1Z97WBVpUVfKV0X+ANJl8KMJ8Q3ueBwXlWe
	I3UevQmw==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hikFb-0007FI-Kp; Wed, 03 Jul 2019 18:45:03 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 3/5] mm: move hmm_vma_fault to nouveau
Date: Wed,  3 Jul 2019 11:45:00 -0700
Message-Id: <20190703184502.16234-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703184502.16234-1-hch@lst.de>
References: <20190703184502.16234-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hmm_vma_fault is marked as a legacy API to get rid of, but seems to suit
the current nouveau flow.  Move it to the only user in preparation for
fixing a locking bug involving caller and callee.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 54 ++++++++++++++++++++++++++-
 include/linux/hmm.h                   | 54 ---------------------------
 2 files changed, 53 insertions(+), 55 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 9d40114d7949..e831f4184a17 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -36,6 +36,13 @@
 #include <linux/sort.h>
 #include <linux/hmm.h>
 
+/*
+ * When waiting for mmu notifiers we need some kind of time out otherwise we
+ * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
+ * wait already.
+ */
+#define NOUVEAU_RANGE_FAULT_TIMEOUT 1000
+
 struct nouveau_svm {
 	struct nouveau_drm *drm;
 	struct mutex mutex;
@@ -475,6 +482,51 @@ nouveau_svm_fault_cache(struct nouveau_svm *svm,
 		fault->inst, fault->addr, fault->access);
 }
 
+static int
+nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
+		    bool block)
+{
+	long ret;
+
+	/*
+	 * With the old API the driver must set each individual entries with
+	 * the requested flags (valid, write, ...). So here we set the mask to
+	 * keep intact the entries provided by the driver and zero out the
+	 * default_flags.
+	 */
+	range->default_flags = 0;
+	range->pfn_flags_mask = -1UL;
+
+	ret = hmm_range_register(range, mirror,
+				 range->start, range->end,
+				 PAGE_SHIFT);
+	if (ret)
+		return (int)ret;
+
+	if (!hmm_range_wait_until_valid(range, NOUVEAU_RANGE_FAULT_TIMEOUT)) {
+		/*
+		 * The mmap_sem was taken by driver we release it here and
+		 * returns -EAGAIN which correspond to mmap_sem have been
+		 * drop in the old API.
+		 */
+		up_read(&range->vma->vm_mm->mmap_sem);
+		return -EAGAIN;
+	}
+
+	ret = hmm_range_fault(range, block);
+	if (ret <= 0) {
+		if (ret == -EBUSY || !ret) {
+			/* Same as above, drop mmap_sem to match old API. */
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
@@ -649,7 +701,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = hmm_vma_fault(&svmm->mirror, &range, true);
+		ret = nouveau_range_fault(&svmm->mirror, &range, true);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
 			if (!hmm_range_unregister(&range)) {
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 6b55e59fd8e3..657606f48796 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -475,60 +475,6 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 			 dma_addr_t *daddrs,
 			 bool dirty);
 
-/*
- * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
- *
- * When waiting for mmu notifiers we need some kind of time out otherwise we
- * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
- * wait already.
- */
-#define HMM_RANGE_DEFAULT_TIMEOUT 1000
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

