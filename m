Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C873C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1499F218D4
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Kkz67VFi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1499F218D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C3B08E0027; Wed,  3 Jul 2019 18:02:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F5F88E0028; Wed,  3 Jul 2019 18:02:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 046198E0021; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEB048E0027
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u21so2280229pfn.15
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 15:02:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/hemVxgPEOdbiVtqmrJ7Pu3HACPpqgUeF/rrQJ8zMho=;
        b=YjkjgEneX+ynAfz12jz6RZe8sSFH8UMAd4NXYa7VixUgKt1WJDmSgq+UxYtrlhR8EV
         DadQv7qwV3NpHQH6aitgLE0QLq+zyIoPIoscbGEhbPvRe91IjTTpTN02qmkY8taf0D9c
         JevznMLVjrihgj4mI3QeSr6xzQ+39RnQA1qDFiQyIbJz9SbocItWpXQBEpjhGdoN/u5t
         lUySS2jyZ6og7b8MxzZj6EPVlw2KyhhhKYCv6I56WZRgPM12GbeNqwk+hR4WtMDMvqeQ
         DrDUE0qh38XhQwHv+OD7ir8iLB5XxFdbJNKqCko8AeE8bSYr3F/3kigcfi2IN42Q9H5Y
         3o1Q==
X-Gm-Message-State: APjAAAXX70n8IUrkLkbrMoGVRlJTc3hLjQBDTkt4uFjpYdVwtotyyBAw
	pJ/AuhCKi0yMw8tgs5zT7Bbt1nvAlxVeY2Yo76pkVQV3d2axotxFYSSc2T1POMxhcJVG+KPoZzN
	ze4eZXXvWNI803ciMCAgQRVLOmPe9Xrq7yt1FQfzbIms1b0TREBLHCyY85jaQNSg=
X-Received: by 2002:a63:3046:: with SMTP id w67mr8384242pgw.37.1562191341285;
        Wed, 03 Jul 2019 15:02:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4PpdS6QoQMty5PL09VSUK/dwAqvxA0lfe69kf8RnAzQn5WFwLZJrHGMTRzGRTNjIsbSeW
X-Received: by 2002:a63:3046:: with SMTP id w67mr8384104pgw.37.1562191339441;
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562191339; cv=none;
        d=google.com; s=arc-20160816;
        b=i/V9zxVD4lPhVwbpGTh97gfKzJk6bGODz6hyuSsN3mw44fh3YgyrpsZKE0fD8eJfna
         Leve3xmX9yTCocBKo4FQrXMQN41bQyWN5YRcuNqbmKyvOv1W7bs6EcntvwElgFv8rE0T
         pMe2+fWWyus4zreIJvI9zwkOpy3Q1KQ1FauiEVa7tcX5kr15g1Zp0Sr43YwWPRCkK9fa
         DJxgYMJ+AGFKd7HGf336ITKtF8m3fNpvCbCYyplIC5/Yb7/sEUqDzOLjzZo3ZBrmGrSz
         ihg3VohnRxT9qRLSrvu98mohhXg8oKDOBFqbEJjO1Bgv/sw4DQhuBx9SA4cmRguYSueG
         Rw+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/hemVxgPEOdbiVtqmrJ7Pu3HACPpqgUeF/rrQJ8zMho=;
        b=lTAnX3CFbxsxjmm40L1Ri7zrkeS/CdUjkSoxYkjMKXRqXOL/ijD2SKXmryUzZBQ/oh
         uSyqnanCzwUCFhqUZKrOPa3mEVoDvSAA9lSi5oarbHuOo/jtfFlSXQw1ZnF2S5UZiAgO
         +Bn7ZD3JhBQ7KpdzyO6Jya/D49ciMUdjNXZJCmPXvORfI8Htr0LGOGMeruK7VjNhNs4S
         zltzEOW5tnFTjYcZu/pweoSN8N+SNPONrfEjaQN3ernEMyWh2V+BfLaS6vCnMSsKqyju
         4nGhLMBBJZ8DzlY0YDFhYPwwVVtGUuMbtYc6zSXC5Fhf7MwvS9BRxTTLgQ5KF2H35u/D
         GU0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Kkz67VFi;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u192si3494941pgb.77.2019.07.03.15.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Kkz67VFi;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=/hemVxgPEOdbiVtqmrJ7Pu3HACPpqgUeF/rrQJ8zMho=; b=Kkz67VFiEYQBRKNbXzQ6Ojm7Ri
	OcwpoDV/CsFrwaqGuhBbSPNg3mkKTGK3IBm4+RL/EUwlT0NR3dRRgi/wPRUKHT9sxRXcnmpRyRMwf
	m6MHJce1FU7Shn767N08Sk0B9F/mSAOHWhU6/7GIcuZm/DWc1kgge97CFqvxLueX1nexjJfh2RFvu
	Gs6UiDeiyfwXE/5jyQ+mVDkX0Cgeidpr53Uwx7wASNMlwTwo61RQBiZYib9OefWnsuFa4yw4ZR+dS
	jGCf81A/6pWNFN7na5WjJOH3ajeY3WvYZLe26FCPeDdEc0pyG2G39NSjTPRsO5OI7H1G9xOMn0fIR
	3b9pwbVA==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hinKS-0004EV-0U; Wed, 03 Jul 2019 22:02:16 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/6] mm: move hmm_vma_range_done and hmm_vma_fault to nouveau
Date: Wed,  3 Jul 2019 15:02:10 -0700
Message-Id: <20190703220214.28319-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703220214.28319-1-hch@lst.de>
References: <20190703220214.28319-1-hch@lst.de>
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
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 52 +++++++++++++++++++++-
 include/linux/hmm.h                   | 63 ---------------------------
 2 files changed, 50 insertions(+), 65 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 8c92374afcf2..033a9241a14a 100644
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
@@ -475,6 +482,47 @@ nouveau_svm_fault_cache(struct nouveau_svm *svm,
 		fault->inst, fault->addr, fault->access);
 }
 
+static inline bool nouveau_range_done(struct hmm_range *range)
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
+	if (!hmm_range_wait_until_valid(range, NOUVEAU_RANGE_FAULT_TIMEOUT)) {
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
@@ -649,10 +697,10 @@ nouveau_svm_fault(struct nvif_notify *notify)
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
index b8a08b2a10ca..fa43a9f53833 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -475,69 +475,6 @@ long hmm_range_dma_unmap(struct hmm_range *range,
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

