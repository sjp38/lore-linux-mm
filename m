Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FD78C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C144B20868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="jwj7m66y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C144B20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 050CD6B027F; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 001366B0281; Thu,  6 Jun 2019 14:44:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0C1D6B0280; Thu,  6 Jun 2019 14:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B52D76B027D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:48 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l185so2763499qkd.14
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cKkqHG6lA8ec9OmOBivsmV6gRcE/obxU2CCqIDGlTpM=;
        b=IAPT+lwiUnQlOTuQ/7r9lRnGaeJCWUAvL6QzfQJyCnVfJilHXBCd/872tNjgfqiOzq
         RRkcsMU6DfReo9WQEYqyc8ooamfDIEJqyhu9/KJhqS9QiWNVQDpVK3gLixThXAtKIZc/
         VGTrA3uqDLapWahTR73wXuO5peVKbkkylQFoGFvSwN3VDModnlGoz875RxDrYaxXu0be
         Ulab+r7y4lwDmYAJofinNCTRWxw0QRzaHK/snGVN1fzxyK54ejIiQb1dkYzWj2qMdx7e
         1iGJd/nQiQpwyumHkEwK7GytNnmb+mUP/O3P+oioC5zN8jV3zRpc6XFAsEazWgky1sdB
         Nx7A==
X-Gm-Message-State: APjAAAXQT2uLd8denINGRCssENuy4FzNS9hilEVyFyxQZmNjm3mSA9vv
	NPzohmW91bcQcKQ7XhXz90EGsj9sK6W/JXhY/Kra8zhDAJ6PKpVUYicspRE/kZjIp+1cR8UnOXF
	NPS6ZVaVPdkjpQuUZ1sy5k9LhDcZVDTXPyZ+CmqrB4ze+Vd7sKf575SOlVoOvgvUaxA==
X-Received: by 2002:a05:620a:14a8:: with SMTP id x8mr40354465qkj.35.1559846688484;
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
X-Received: by 2002:a05:620a:14a8:: with SMTP id x8mr40354402qkj.35.1559846687367;
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846687; cv=none;
        d=google.com; s=arc-20160816;
        b=CxcEe4b9voM7U5CR4HbsQeAFjPNb46NJ9qQSU4uGud4yrbPgsUYtJK/KN9PkL7Vucb
         XxUbsm3bWS7IdowEXN2UpKZQUAwVJOUQNyujKUHIrX7Zywi1oDAqjQHYvZ13d8zjqqch
         l1uWxGtUJN2eIrMsWewiQ167cMSH2Aa1fkvG/a/hJRsNlchjefYy2vqlvH2KAc7bUVv3
         JzK2TTmP6ijjWc2zwcapJJ0u7QSgxk9aD7wW/RyzQssaw3JGowlYEsmCkLXq6SKztw48
         Vq3XCVRLpDQPt+ZruwsLkHU0RVrEorXvC6/bEu5b7p0/KjEROaHLl75vPPrjM0J0Glfn
         dAEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=cKkqHG6lA8ec9OmOBivsmV6gRcE/obxU2CCqIDGlTpM=;
        b=TZPv+YQKghHzpB+s60ETG5eAmjcIWCdnrB6XBHTTMWSGqWm+xM5guJzmUACXE7BqD0
         trcTCwi/KN91Gh3kfiFjQwmkYf4wXqin4F/21VRKHgd+mSmAbCS+ZXSsRJNXwC9vTDsI
         yhKRT6V7u/SYpHqT6BPRzRZKMvwRRWs1cxTuxHhdIF8YthxkykxjdkaVCUywRc6a+gKc
         kP0e8c6zr9VgigrlSwsK8WF9K5+Yh4Vy8jD0l1L5+w2j1igrcA9l4wwd7YQmllrAMFLl
         dJ5KFgecFYmR9H6l1ZEblTqjSixC/j2FQrCBddNZaw5gwZaEzqY71cYBYjUmT0ERGO8p
         PAzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=jwj7m66y;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l66sor1449557qkd.125.2019.06.06.11.44.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=jwj7m66y;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=cKkqHG6lA8ec9OmOBivsmV6gRcE/obxU2CCqIDGlTpM=;
        b=jwj7m66yktUzAAVuBGGSCtyJS/egSnF1B/vxHFcHYcF2Uik/EqL4UNPU57byfvPnPV
         EUOhSE6Yc2ULsjPzk2Q0cPgGDWJT6t2SoK+wEhbAq1wIixyAii3w6eS/3F4aOcLSPwis
         wISfz8dx+YNMVHjshe7Qu1Sb1slKfIiBQMNHt3ytiNJzaiH2eoJOAMMz+9NSZ0N4cZIj
         IOJsM/44sVtvL3oMoPVTtng3fKxXbLORwQK9ZTj6pDXhMqEyH4epdWP8UfEJY1SfdN0a
         cUwOJj4KyRl8nUp5tdavSJ2m0nYwjfI9rz5uUmGGXTAadrKsObhys9ToUrWKVFbjE5E+
         wb4w==
X-Google-Smtp-Source: APXvYqwVkPweqvQyzdMm8hrdxDc8fcdFbLwJPBzLxuUMc6ON/X0Bc6zX6ARY8mPOX6I9iWyD4gOp2g==
X-Received: by 2002:a37:a0e:: with SMTP id 14mr21589009qkk.203.1559846687100;
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id e66sm1557234qtb.55.2019.06.06.11.44.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008IB-G5; Thu, 06 Jun 2019 15:44:45 -0300
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
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v2 hmm 02/11] mm/hmm: Use hmm_mirror not mm as an argument for hmm_range_register
Date: Thu,  6 Jun 2019 15:44:29 -0300
Message-Id: <20190606184438.31646-3-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
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
---
v2
- Include the oneline patch to nouveau_svm.c
---
 drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
 include/linux/hmm.h                   |  7 ++++---
 mm/hmm.c                              | 15 ++++++---------
 3 files changed, 11 insertions(+), 13 deletions(-)

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
index 688c5ca7068795..2d519797cb134a 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -505,7 +505,7 @@ static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
  * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
 int hmm_range_register(struct hmm_range *range,
-		       struct mm_struct *mm,
+		       struct hmm_mirror *mirror,
 		       unsigned long start,
 		       unsigned long end,
 		       unsigned page_shift);
@@ -541,7 +541,8 @@ static inline bool hmm_vma_range_done(struct hmm_range *range)
 }
 
 /* This is a temporary helper to avoid merge conflict between trees. */
-static inline int hmm_vma_fault(struct hmm_range *range, bool block)
+static inline int hmm_vma_fault(struct hmm_mirror *mirror,
+				struct hmm_range *range, bool block)
 {
 	long ret;
 
@@ -554,7 +555,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 	range->default_flags = 0;
 	range->pfn_flags_mask = -1UL;
 
-	ret = hmm_range_register(range, range->vma->vm_mm,
+	ret = hmm_range_register(range, mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
 	if (ret)
diff --git a/mm/hmm.c b/mm/hmm.c
index 547002f56a163d..8796447299023c 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -925,13 +925,13 @@ static void hmm_pfns_clear(struct hmm_range *range,
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
@@ -945,15 +945,12 @@ int hmm_range_register(struct hmm_range *range,
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
+
+	range->hmm = hmm;
+	kref_get(&hmm->kref);
 
 	/* Initialize range to track CPU page table updates. */
 	mutex_lock(&hmm->lock);
-- 
2.21.0

