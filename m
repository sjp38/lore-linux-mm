Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A6E3C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C6D520818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qZW70f9C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C6D520818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91A616B000D; Tue,  6 Aug 2019 12:06:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87F6C6B000E; Tue,  6 Aug 2019 12:06:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F3B36B0010; Tue,  6 Aug 2019 12:06:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3203E6B000D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:16 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id r7so48614230plo.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mqfjTQaTTQFNSro/hN6gkYpjLV3E2bwnPvulWJTlCQk=;
        b=Ey5VnNj1sUMLv9R04u9MDeD80+tRT3hc7bEgbL9uPd4w1iH40rk0olRY2sZlL3wwHO
         pk/Q4tc4gZlHQ+fBP3ixpsiOgmMjghTzxV4fUJpEDjJp+lOj2EqyK5Ww25D6vq4Y14v7
         8rNdjMFIJoDWNTDgfE0bhuCbf1dlYquQipCeiv6emzVd8wkCiwxAW4vsQqOuthUQF3+T
         +xDy0iuK0vGERzOEz3AyADGWJoEKADAOF4SWgvaSyan6iOuVA12QIAjjMBtkJN2WznKW
         MrQh4c86te6B/zPwI8o7HwtI30X8Snx9tVzqptna9jK8eks1nd3W1lXnEjpHZt31Npxb
         CtWQ==
X-Gm-Message-State: APjAAAXGBzEVaWB+cefbvILsn7PJwXCjeo77zNqtdVHvLgUin0BUCpy1
	/qMSIXoEsKJKvtQVIzS7qcmP8qwuVULiHc0/E/7tTZpOEe61PiZ87w4Mulb49V+gcyVovOt6pJq
	JKkgPiKQ3o7VF+oPEYY00U/9kiKkSC6F+6L7xjd9LOR/RbVYPBzabUQBjGN0LqUc=
X-Received: by 2002:a17:902:2884:: with SMTP id f4mr3839649plb.286.1565107575742;
        Tue, 06 Aug 2019 09:06:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzo+5oOSwWsoQp1iS7W/98xyiqfTqh4AYmggOBGTh6JcSLq2Z3eYQBmXXT/Z7t70EiWPYyt
X-Received: by 2002:a17:902:2884:: with SMTP id f4mr3839580plb.286.1565107574858;
        Tue, 06 Aug 2019 09:06:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107574; cv=none;
        d=google.com; s=arc-20160816;
        b=jx/gX+daliTd9rtE4E4EMxfKq4JE42ztmmPCFPTn7/mFTAag0S8E7a6GzxpoP20LXB
         u1Ccs5VpXcSlaaA+YOHRoVEYHXx16ksmn79MghMWb91Sn/RX+NXXN5l028XzMklIJW/K
         /ULFV1n/2Jcf5O1ipKxGfbSspgo/Nq5QZuyy4UfuNrXPEIgbUQWawhZJ5RFq4w201XAC
         H1fWNLS8RwmRyk/MTGOonthlQbY8BcRNuq0gqxc1PgPtsZbHDZecgNKpacls8OHAXUNY
         RnFNlexv0jSmn6zh1vAHO6UCW6aO/ax16swIOGtSkWBp8OOI2qB40Yi5Rq+Sb6Oe+hTu
         HSdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=mqfjTQaTTQFNSro/hN6gkYpjLV3E2bwnPvulWJTlCQk=;
        b=vN4dzrsxBgq5OLI0yUudcaOFiXNNhZu/5mxcSyyzZqMVg6wjRTMqy7XyP7aAWN7uRy
         gW5dN0xBxOkoZ/G5w9vXMzmOQlvSZdBhSJ5/vtVl5LqM/OYhZBT4eY67h7ftDcVDTWSa
         tHQ/ar/vBoKGHSeGKlMbI8gUjKpcvEQETDWmq3dnbGS+RpPRzo5Ih4JqNHCPfV9nf+nO
         BZY+Z0k9kjIX6IOjy89wDYyaql0I+0RcF3zawAEAtNw1XRv5xkYyz36LljM/q5JYAiIo
         pEdkr4zy84a2u20pgG6swQZE2PqnEZX+CKnlSv3IEKsCnduCBhzOR5X4vZlPwPHt8tT3
         wywg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qZW70f9C;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s128si47972872pfb.207.2019.08.06.09.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qZW70f9C;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=mqfjTQaTTQFNSro/hN6gkYpjLV3E2bwnPvulWJTlCQk=; b=qZW70f9CDkLcMchhuvgQXFX1hB
	gk0dQRjjzMNkOXpQ1vj/+CZf+DGdkKL4wy9lfG80WezxLzvgoBIi65VwKPxRO7XZvSGu4lkfJvtpO
	YLB+2QpTOftupd6T5+u5wIWRCdr7UNLJV9pI2yGFI17FzFotQ9rc45MMEuT6B4ZuXTSOCdG8lIElC
	zh1luwoZ5mTRukbW+Ku/WPNKTQRqYa226GtVA3dqqlnKiykhAF/jkll9ZPoFo+gRfPjqymMQitRIQ
	EbyGZEvR37jYfqmSXzrxeXNhYxuKZ/JVcMkmWceWLyjt1pnZa/P8rF90JPLdFdMkz1Y9M89sHhy44
	fGQB1PQQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yV-0000Ys-M1; Tue, 06 Aug 2019 16:06:12 +0000
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
Subject: [PATCH 06/15] mm: remove superflous arguments from hmm_range_register
Date: Tue,  6 Aug 2019 19:05:44 +0300
Message-Id: <20190806160554.14046-7-hch@lst.de>
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

The start, end and page_shift values are all saved in the range
structure, so we might as well use that for argument passing.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
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
index 98072fd48cf7..41fad4719ac6 100644
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
 		up_read(&svmm->mm->mmap_sem);
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

