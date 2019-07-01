Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFCB2C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA5FC20B7C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pvfk1jdk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA5FC20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8DF88E0005; Mon,  1 Jul 2019 02:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A19F16B000C; Mon,  1 Jul 2019 02:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77F368E0005; Mon,  1 Jul 2019 02:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f207.google.com (mail-pl1-f207.google.com [209.85.214.207])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8AA6B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:42 -0400 (EDT)
Received: by mail-pl1-f207.google.com with SMTP id u10so6739087plq.21
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WF4tHB/Skt9G3b9J2cGNsUS+Db4fSie+CUUuGe98tR0=;
        b=Xf27sWLCQ1ksKWOCPHP/AQAnt9tXWvtjEy4DBgQHOd3IkojbhCFKEAZNZSOsFRdt/+
         Uy2IpuSCt2uKLlhv4QQA21evBMJombebGoJ6tqoe0vQP8byeCjovjN5aoJLQrcPRidUd
         IIjYAVrIiSAnoNgLWmRRggG1dA+0kck2PPZ3J+cXtylngsqU+wBIlDW/OYbXhezDvtjz
         0DetRY66676//7XwVrhDE+7yKwxu+50I9oJl8H/n/LDULfT5ptMVuMHmDD7BNoCwxzL9
         oj5wAulOCPU+ZdHpojYXdxNtoXB/zX7j8XnAZoGq3QrS9CtONNx/d7ZWPEd2TLN8tWQo
         oW9g==
X-Gm-Message-State: APjAAAWZGKjmmksU8GvjDeHO4Gn1w9o7UgACzUoGVxCoxBx8xKD9YD8N
	P1g+JC1UsP7v5Dpu+dwXDT7BdcfpG6bC8uAwuhoooZ7GPHAWGiOsTiI7JHK9ST14o2eIBk9h3PC
	+hUWc5nTELGwaGqEiCPjM9SvuUMB3Wa8gptdNDaPr9fWz9n4+mSBypcfv+ZcZtHs=
X-Received: by 2002:a63:7b18:: with SMTP id w24mr19688945pgc.328.1561962041827;
        Sun, 30 Jun 2019 23:20:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiNYcahBUit8KDMOfKVM9YwfKRdyyfiby8v98qJOvm2FzdqoTxz3J3V/s3Fdd0uR+i04YM
X-Received: by 2002:a63:7b18:: with SMTP id w24mr19688886pgc.328.1561962040987;
        Sun, 30 Jun 2019 23:20:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962040; cv=none;
        d=google.com; s=arc-20160816;
        b=rBjDXNBApiIjwN5uLUbOAyoXkC/cvo0bFPreWSOHhvS4/t+pB+t7c1DuO0UDDaauFJ
         4CWRdGDl1n3MmDcmFds4vDwjkz5Kz2BQMzRzLscJ1PBmwgVb1UJPmafuYTiGriP0GkhD
         jKGD+8m3o9FsHhgAjJ4A53HvmpdUklm7o0snt3YZOkHcIoUvPGT+ktcu3BKR/CG9lax/
         pyYapPyEHM245+i1JF3xWtt2wLWYCLExggy8cJ8F9bGTqzSlLLCrUmEmwtjxYV0qt3rr
         iw4bkhtDlGj1ku/vy5X26rmK3PM8yodtC1WoQSWuIFYRtcqsDJIvdyglyRQg7oByGrm0
         FttA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WF4tHB/Skt9G3b9J2cGNsUS+Db4fSie+CUUuGe98tR0=;
        b=e0csCYBxq/jTPi9EgiE8L5iQ91zH2w3pEiPXX+oIRVgyv4BN2RR3x8JrtXcMpdqqLd
         FdwyVurX//fIRjYVA23NomCcKFkWyyL4fnBfi6L7hwQh+/9TV5e35nI+W3cQ4uLFoNE/
         SKNkdtdmgz1IURaNVh6Kd6kj5SpHnbM+SJ47qky8Xam8drfbuDAWh6r3DRoSGO5uH8JA
         5EWQ4bk7OEtIy5IWaOwrFc7dDN1ro8MBuIwAJWGtkl7EJo9TBlB7l8w0cLP15a9P/dIQ
         4+nuviff/5/p3/rN3zLCXha8v32u2DhoQzY5Nte5UwjFmjNsUhCwgb/1MrXQWD7/RLH1
         aS3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pvfk1jdk;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d31si9670610pla.393.2019.06.30.23.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pvfk1jdk;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=WF4tHB/Skt9G3b9J2cGNsUS+Db4fSie+CUUuGe98tR0=; b=pvfk1jdkUzEbDkGH+OR9rAHyIe
	kR8atU5kSv/EQToxLIjdsRba/jDPvJY79AkV5c9POhc8OEOnkOYGx3sDbU9BQX4OTpjP1OiMwNB8G
	Mr3B1wZ6mvB0ReFKDK9kAyOrFR3cFOU1pOOJAA2HuLhksS4VANVCw0zg1mFE13Q21vRUPTpXy0agl
	klOHn1A4qhv0abiLTq348XVdq3wl/B8i7Pzq6GmWavPxglIVnsTMy1yx8Hd9yBWwpnQDb2cCQUB5/
	Of51BOJ0vhGHXiGXtGHuj8RzNUSqCPrQXBAMst2TA75JLvCwMCyYDnCASQb0SyEWfjXv+/n3G60Re
	6sNUsc+Q==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpg6-0002vW-0H; Mon, 01 Jul 2019 06:20:38 +0000
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
	linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 07/22] mm/hmm: Use hmm_mirror not mm as an argument for hmm_range_register
Date: Mon,  1 Jul 2019 08:20:05 +0200
Message-Id: <20190701062020.19239-8-hch@lst.de>
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

From: Jason Gunthorpe <jgg@mellanox.com>

Ralph observes that hmm_range_register() can only be called by a driver
while a mirror is registered. Make this clear in the API by passing in the
mirror structure as a parameter.

This also simplifies understanding the lifetime model for struct hmm, as
the hmm pointer must be valid as part of a registered mirror so all we
need in hmm_register_range() is a simple kref_get.

Suggested-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
 include/linux/hmm.h                   |  7 ++++---
 mm/hmm.c                              | 13 ++++---------
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 93ed43c413f0..8c92374afcf2 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -649,7 +649,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = hmm_vma_fault(&range, true);
+		ret = hmm_vma_fault(&svmm->mirror, &range, true);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
 			if (!hmm_vma_range_done(&range)) {
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index cb01cf1fa3c0..1fba6979adf4 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -496,7 +496,7 @@ static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
  * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
 int hmm_range_register(struct hmm_range *range,
-		       struct mm_struct *mm,
+		       struct hmm_mirror *mirror,
 		       unsigned long start,
 		       unsigned long end,
 		       unsigned page_shift);
@@ -532,7 +532,8 @@ static inline bool hmm_vma_range_done(struct hmm_range *range)
 }
 
 /* This is a temporary helper to avoid merge conflict between trees. */
-static inline int hmm_vma_fault(struct hmm_range *range, bool block)
+static inline int hmm_vma_fault(struct hmm_mirror *mirror,
+				struct hmm_range *range, bool block)
 {
 	long ret;
 
@@ -545,7 +546,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 	range->default_flags = 0;
 	range->pfn_flags_mask = -1UL;
 
-	ret = hmm_range_register(range, range->vma->vm_mm,
+	ret = hmm_range_register(range, mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
 	if (ret)
diff --git a/mm/hmm.c b/mm/hmm.c
index f6956d78e3cb..22a97ada108b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -914,13 +914,13 @@ static void hmm_pfns_clear(struct hmm_range *range,
  * Track updates to the CPU page table see include/linux/hmm.h
  */
 int hmm_range_register(struct hmm_range *range,
-		       struct mm_struct *mm,
+		       struct hmm_mirror *mirror,
 		       unsigned long start,
 		       unsigned long end,
 		       unsigned page_shift)
 {
 	unsigned long mask = ((1UL << page_shift) - 1UL);
-	struct hmm *hmm;
+	struct hmm *hmm = mirror->hmm;
 
 	range->valid = false;
 	range->hmm = NULL;
@@ -934,20 +934,15 @@ int hmm_range_register(struct hmm_range *range,
 	range->start = start;
 	range->end = end;
 
-	hmm = hmm_get_or_create(mm);
-	if (!hmm)
-		return -EFAULT;
-
 	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead) {
-		hmm_put(hmm);
+	if (hmm->mm == NULL || hmm->dead)
 		return -EFAULT;
-	}
 
 	/* Initialize range to track CPU page table updates. */
 	mutex_lock(&hmm->lock);
 
 	range->hmm = hmm;
+	kref_get(&hmm->kref);
 	list_add_rcu(&range->list, &hmm->ranges);
 
 	/*
-- 
2.20.1

