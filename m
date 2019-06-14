Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 434FDC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECC8A2173C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:44:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="D30mf9PG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECC8A2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ED9A6B0266; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1794B6B026A; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE6C36B026B; Thu, 13 Jun 2019 20:44:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5EC16B0266
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:56 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g56so729540qte.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=op2+qqBk6rWtrVzX85Tdji9xbKocy11Zcttde2t5Nu8=;
        b=m4g3awBRso8JjcRIVaz6RuSf9bN0V1MdxRnHa6ZyMvfxilVihdZXVJYaoQEE4Ry/nJ
         pCuzXd48nujpv+C3xVz0Y2JYR/AxPOWmGIvXD4EKSlYTPk8nFEj1XIZsw84LWI/SKSK4
         OO/vO15E3XHoJEN2uopTA6ehSkIo8HtDylOlDpI6iQ+wHP4eETQ0hp/Vo8CSr7P3+8pS
         2Czz4J2pXqTOxpgECfAX+3mlvsFOPSQbP/1rnWqC2I5a8lrqxpStKGNJq1pu3CzKmB83
         K24cogrkXoa1MVayDLmwkv2ysJTufzgQMCqt8BaYZI4l5x1JbbrxNpH7v5FbuiH+Lps8
         VvQQ==
X-Gm-Message-State: APjAAAULfjGXSKpRIHTlQDwmLuZavqpGwpJlPv+9B+KEcamiECGsJnCF
	EB23Oos1q2IFM2fZDIDI+AQJbzKxyJg9YiFFMYltVWOmjjXM1trrumbqoWMZX7S21lJGWsRyInl
	RijtZbRikmx9ZrDsgj4qnf1Wcwyp02fp8SQT4rFX/C7qlvnxfAgk4rvlRsWQob0SQ8g==
X-Received: by 2002:a0c:d0ab:: with SMTP id z40mr5978640qvg.216.1560473096483;
        Thu, 13 Jun 2019 17:44:56 -0700 (PDT)
X-Received: by 2002:a0c:d0ab:: with SMTP id z40mr5978598qvg.216.1560473095795;
        Thu, 13 Jun 2019 17:44:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473095; cv=none;
        d=google.com; s=arc-20160816;
        b=a3/UFsTV0FqtNrd/BTCMmNdYqlsY6noN1mGJkOhgDWXuZE8sLGRaD956aO6OoOUnB9
         8mxZj7KeoadTRQDKHk9j3c1I8+5ePJl3ZQNoibBEdw+eCvuYSYU+pzrsgmLJb42EBTzW
         SYtAAqseA87KMlX5OYDoYzqjajHa+VS3Ucj5F1HYph2DHGceBXmVmhjAor3qdzXP2DX0
         KsQnMLEnnTSG7tjndih1a4rqZycvGI0A/MXil6fXB9AmyTKnEL4bJr2/6FlR2k0yQyCa
         jOelwMT4zQDbR/sLTFDBlPW93GgsxPftqCTypinUhD6rih3GArfui+drvURGb6ESj4Bb
         zkpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=op2+qqBk6rWtrVzX85Tdji9xbKocy11Zcttde2t5Nu8=;
        b=WbYFbL1Nsnic4CrZ+Zr+HiEE/jF49LQI2P+5y9N3bHFAMAzZfEoYRCi27zr/ag4ryf
         WRWc62J8YYGzkgT7icJQwkGMdgfomjW/IFexazfBVPy7mLkR26JHLiG1GdnLdJDxIfyh
         giCl1d1Dnlo/yGfL6E9rWoBFpS5qj3MlKfZ6ByveeiBK4bYfeQj1o7E1SBscjKFF6bdY
         gHb14dvRnMU2YyaXZynCvcKfuAy6Ys8XSUi4QWZQehlE+O+v/e7aVIviroktL81nqFPp
         h3KziQrtEQqNNOch0St8pYb0Y0FUTGnMrarBcUuJv6eIZRwS1x0hH6dZEiIx9mG8bdt4
         AoJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=D30mf9PG;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t66sor1066556qka.63.2019.06.13.17.44.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=D30mf9PG;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=op2+qqBk6rWtrVzX85Tdji9xbKocy11Zcttde2t5Nu8=;
        b=D30mf9PGmOmg9I5/9g0MzWxEXedyBaWkkmnNqAl4FA9d0B5THPVVzTtCux6VHVWP76
         xPxHkBZrtAGHIjR/J+Se6HOXwAs75X6jrsndrpgNBnZ6e5GoT5vB7IpW5/KkPufHsMig
         /lKj49pcdbL5F8wiFJWjPLmrYeiEWCPItURysc/SGIc3LsiunwY9uiqrmWElrd7Qwv6Q
         mtT1IaGjA4RD5yCV1MA+3beQzN1ULDnUdoMUn+fqlk7WTzzxYo8IKqJG0BdnDdhGjwPC
         zYmW3IXzrRRtAS559siQ/AodNBiqOD7M6e4S7LJU7trsqP+0KuWPmBGt4JAQ6K2dl3hp
         FojQ==
X-Google-Smtp-Source: APXvYqzHD04DoOdk3O8JWoFpyfnlVsPMz9EOodeX9LHTjciArgHYxwJEEoe/sklf3HM5JZVxOOzqsA==
X-Received: by 2002:a37:490c:: with SMTP id w12mr71905018qka.327.1560473095502;
        Thu, 13 Jun 2019 17:44:55 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s134sm759219qke.51.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005Je-Km; Thu, 13 Jun 2019 21:44:53 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH v3 hmm 02/12] mm/hmm: Use hmm_mirror not mm as an argument for hmm_range_register
Date: Thu, 13 Jun 2019 21:44:40 -0300
Message-Id: <20190614004450.20252-3-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190614004450.20252-1-jgg@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
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
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2
- Include the oneline patch to nouveau_svm.c
---
 drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
 include/linux/hmm.h                   |  7 ++++---
 mm/hmm.c                              | 13 ++++---------
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 93ed43c413f0bb..8c92374afcf227 100644
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
index cb01cf1fa3c08b..1fba6979adf460 100644
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
index f6956d78e3cb25..22a97ada108b4e 100644
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
2.21.0

