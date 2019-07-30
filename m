Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89126C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FD472087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HAiKpX1E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FD472087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E07B58E000B; Tue, 30 Jul 2019 01:52:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D92988E0002; Tue, 30 Jul 2019 01:52:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7EC28E000B; Tue, 30 Jul 2019 01:52:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 941A58E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:37 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so34658024pla.3
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gUN1ysYphbaom7o3SlTt3jkBtHdaNGKW2RkJa25nOPs=;
        b=iGtgEazVVuNS/Ztq9F8gCNQS3lXJzWzYzDsbp/osUSolHl4Ez2rlaulWgmjUnSlWn7
         fW++tfmH+sI5MZXiItk9x9fcB4W0BtJirOtISBBCITU2bkL1bS+ghlY+DoZWWzw2uXxn
         hTanYtj4jt0OrQxYZNm4Oxe8XDtPdNKvBAUlm3hd0feq5DSpoIBy24KJyQ48sWa7ZPER
         FbmsJbwH78Cp8gPpuEvDggg8aG8Mm0mLfiRujOheeDrkn9i6H2XzhYjPs+IO7As5W7mi
         qmDWVvGWXBPVOZgWDw9z0qBw4E6D7wnNO3lVa6I6gb4s9L/oo8JOpVYtBrDp9Ukkpp8f
         Coyg==
X-Gm-Message-State: APjAAAUYsXMe6NZQWh1hh5VkYZJ7xxxj8o16QSVXkg12esswXZs6uSuO
	rXHdzJryoUhUYo/4pGmIJjDSfwfRTEPOg583owLqdJC3oCECT5tl7AiGhiSAkZvM2+SVR9Ep2u+
	effikaRveb+mi8/uitNL/ZctXL3kHSiEuYToEkrd1nYhVAGDilhB9lBb5IacB3NU=
X-Received: by 2002:a63:8ac3:: with SMTP id y186mr107078607pgd.13.1564465957073;
        Mon, 29 Jul 2019 22:52:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZJ6LHAUn9zU6Qs2RC4ChyVpMlS2JvzUtSRESmoYSoBYMWXeA6dKby/f7aFdpg2xM8+etm
X-Received: by 2002:a63:8ac3:: with SMTP id y186mr107078559pgd.13.1564465955736;
        Mon, 29 Jul 2019 22:52:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465955; cv=none;
        d=google.com; s=arc-20160816;
        b=fsVByk2MOmmpMAr0yRWxozlInDbMAgEPyzXfKXU67JfT+CyWYBmKG49keatl48PtHO
         crhwtlaqQinF2v1nUtf5mne/FsK8wOuhhb6KOtCruxfT/cFG1oD7b1k28JrobzibI7Yj
         VxqXOOmxugv3z2vIYkoaPwmBCT9ufS5t4npPuxI/k98gi9U3V8umwzHh0Rk3hJjqbJxA
         YJ4xQeKDlP5EjvmBZqfxf0bA0UIH1lMlsCIR7oXcTtfqS8uI1qxm5FmnJ9eIEYkwtK0h
         6fw6oZcp8gZKLb9Ve4TZtIqKJOII4jcPou8VxQM+ldkXCIVv6ZEHDGfoAT9b7O1wN67+
         Cj0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=gUN1ysYphbaom7o3SlTt3jkBtHdaNGKW2RkJa25nOPs=;
        b=QeFEeqIYHRGXZ9dMVtzCWi99HhQqrf5yljvhApZfzizt8wvPDKCI7aYPNG6Nk7FpA2
         bfRJVINIEX392yqP9Gf73foRR+EWNrBPMgW2F2ARLCL7lIPGZGyuxvIpvQekw8xnKuKD
         HeBb8t+6hpWQEBhjYyCxKqnHjtDy8e3GYphC+5QNbzApcIsAZhPup47qO9TPDDLPF2yE
         5IVPecoelYUg9ttgVh/oTPIQM5uCNQFIx8rWSH8YgQSgTGBehCoe8UxkwEBc+jyL3Gwa
         CCEqKiCbalI5dCnJG89eNP/7t4VjQAa9Oge+sKK3CcKRNUSCSVzhpNsCWoPV7lMPR46t
         UkWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HAiKpX1E;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o131si29665314pgo.445.2019.07.29.22.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HAiKpX1E;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=gUN1ysYphbaom7o3SlTt3jkBtHdaNGKW2RkJa25nOPs=; b=HAiKpX1EVNOPs9UAiXpBK7RtOr
	zWukhNQVhuMZwGpox0xkimd9OFR2Ina8VGIPXExI+LErg/VnNm4GKw3KhxEHcuS6/LRmr138bugv5
	vNpJF/+SAhyuf8MH5RCG47zhWLt0kP5bM2tUSa6/9lHeqc4acuR/Q/iWZCz3+2uVGPw4DAQIlnpoh
	fnaTSPET4vYNsZeP/lcOk31QyTLoeN7vASsyNjZ/ynhufNdRmdM/Jzi+1OeWixGX72h02GqhtFvg4
	YlZr6QULf+iUQhX4wBYbOqwf03LD8S1F5OaHDFK8eFbdtQ5tnFaet/ViEYVOX5jwe2IVoZ0qJck9p
	yoAN3cVQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL3o-0001Iz-GC; Tue, 30 Jul 2019 05:52:32 +0000
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
Subject: [PATCH 06/13] mm: remove superflous arguments from hmm_range_register
Date: Tue, 30 Jul 2019 08:51:56 +0300
Message-Id: <20190730055203.28467-7-hch@lst.de>
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

The start, end and page_shift values are all saved in the range
structure, so we might as well use that for argument passing.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/vm/hmm.rst                |  2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |  7 +++++--
 drivers/gpu/drm/nouveau/nouveau_svm.c   |  5 ++---
 include/linux/hmm.h                     |  6 +-----
 mm/hmm.c                                | 20 +++++---------------
 5 files changed, 14 insertions(+), 26 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index ddcb5ca8b296..e63c11f7e0e0 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -222,7 +222,7 @@ The usage pattern is::
       range.flags = ...;
       range.values = ...;
       range.pfn_shift = ...;
-      hmm_range_register(&range);
+      hmm_range_register(&range, mirror);
 
       /*
        * Just wait for range to be valid, safe to ignore return value as we
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index f0821638bbc6..71d6e7087b0b 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -818,8 +818,11 @@ int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo, struct page **pages)
 				0 : range->flags[HMM_PFN_WRITE];
 	range->pfn_flags_mask = 0;
 	range->pfns = pfns;
-	hmm_range_register(range, mirror, start,
-			   start + ttm->num_pages * PAGE_SIZE, PAGE_SHIFT);
+	range->page_shift = PAGE_SHIFT;
+	range->start = start;
+	range->end = start + ttm->num_pages * PAGE_SIZE;
+
+	hmm_range_register(range, mirror);
 
 	/*
 	 * Just wait for range to be valid, safe to ignore return value as we
diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index b889d5ec4c7e..40e706234554 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -492,9 +492,7 @@ nouveau_range_fault(struct nouveau_svmm *svmm, struct hmm_range *range)
 	range->default_flags = 0;
 	range->pfn_flags_mask = -1UL;
 
-	ret = hmm_range_register(range, &svmm->mirror,
-				 range->start, range->end,
-				 PAGE_SHIFT);
+	ret = hmm_range_register(range, &svmm->mirror);
 	if (ret) {
 		up_read(&range->hmm->mm->mmap_sem);
 		return (int)ret;
@@ -682,6 +680,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 			 args.i.p.addr + args.i.p.size, fn - fi);
 
 		/* Have HMM fault pages within the fault window to the GPU. */
+		range.page_shift = PAGE_SHIFT;
 		range.start = args.i.p.addr;
 		range.end = args.i.p.addr + args.i.p.size;
 		range.pfns = args.phys;
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 59be0aa2476d..c5b51376b453 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -400,11 +400,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
 /*
  * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
-int hmm_range_register(struct hmm_range *range,
-		       struct hmm_mirror *mirror,
-		       unsigned long start,
-		       unsigned long end,
-		       unsigned page_shift);
+int hmm_range_register(struct hmm_range *range, struct hmm_mirror *mirror);
 void hmm_range_unregister(struct hmm_range *range);
 
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index 3a3852660757..926735a3aef9 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -843,35 +843,25 @@ static void hmm_pfns_clear(struct hmm_range *range,
  * hmm_range_register() - start tracking change to CPU page table over a range
  * @range: range
  * @mm: the mm struct for the range of virtual address
- * @start: start virtual address (inclusive)
- * @end: end virtual address (exclusive)
- * @page_shift: expect page shift for the range
+ *
  * Return: 0 on success, -EFAULT if the address space is no longer valid
  *
  * Track updates to the CPU page table see include/linux/hmm.h
  */
-int hmm_range_register(struct hmm_range *range,
-		       struct hmm_mirror *mirror,
-		       unsigned long start,
-		       unsigned long end,
-		       unsigned page_shift)
+int hmm_range_register(struct hmm_range *range, struct hmm_mirror *mirror)
 {
-	unsigned long mask = ((1UL << page_shift) - 1UL);
+	unsigned long mask = ((1UL << range->page_shift) - 1UL);
 	struct hmm *hmm = mirror->hmm;
 	unsigned long flags;
 
 	range->valid = false;
 	range->hmm = NULL;
 
-	if ((start & mask) || (end & mask))
+	if ((range->start & mask) || (range->end & mask))
 		return -EINVAL;
-	if (start >= end)
+	if (range->start >= range->end)
 		return -EINVAL;
 
-	range->page_shift = page_shift;
-	range->start = start;
-	range->end = end;
-
 	/* Prevent hmm_release() from running while the range is valid */
 	if (!mmget_not_zero(hmm->mm))
 		return -EFAULT;
-- 
2.20.1

