Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59086C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0881120850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="nqSoFbcl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0881120850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91CF76B026B; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 856186B026D; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65AB76B026C; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E30D6B026B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g30so691577qtm.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OqqjfqwYsPO/UoPKKcnblUG+sfS41bCL5Aovzlt5Fak=;
        b=gjSL4vCIWnOkzYr+yF0u1cNRdOF+K3arveQPSqZM99/GQPOzywE552JOrjEtlkgw7B
         b0Op+kSsaVvYgXgquqK6yXWJan+DknaoH76xVsMEif5EtNPcbLNqB4MhAICESIY+Q135
         aISGDE+XRam7G3hAmFGdTWCHjfKspXTqXkm2Fju/CSEfwVILn5VyqG+tOAHO5Im7A87K
         gPfAhrL0Vecttc57sbckipEsGAcdP2ej8ehBa48L/T3zowawb15G1IgkDYpIIZgqX/zQ
         r6jCDebgwzMoCcT7ZEDRmp6zqZkScViJdYqb2WKmGPqJ2x4zxn6C9viHcbxXsSZ/Tp0U
         2pYg==
X-Gm-Message-State: APjAAAW9BurrJD8O/jnXgBYswaRHP3h9gngP3WjYlDu0A9ZKQBZ4/y9R
	JhcNe8uVkyGdeZK1YvnLhAfSNbmnPU/PRX5paqaAR4uUGca0nZWBkCucDY5Y43M4BhKp2TY9/I6
	UqGR24TQzaUR6GBPLsI8KI9dx3NxfyjI3aKILtEyMJt5PeWIeX984ZnZNmzj+YX6sGw==
X-Received: by 2002:ac8:2bdc:: with SMTP id n28mr40007631qtn.197.1560473096936;
        Thu, 13 Jun 2019 17:44:56 -0700 (PDT)
X-Received: by 2002:ac8:2bdc:: with SMTP id n28mr40007602qtn.197.1560473096276;
        Thu, 13 Jun 2019 17:44:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473096; cv=none;
        d=google.com; s=arc-20160816;
        b=P4t/QZ66ligwcnIIk0kHhL8y+mPiKWdmJO+nhDem8WtMY3Z+OPj4JwVpOmn5p0eFPG
         3XaOKRyMZ52205m4FTSXqdDG1KwJ+3tDmpR+CHSC6KOp7t2hWazVO7NuKmsmd5ThOtG/
         FU+bnwLWyCF2yD92u1WSO1oYuSVbVCdCNgOKerMUI4IXT0JfEJ5u89odaMqtRm/CmWWh
         PSv0Or7/PVfRBVPaxFI1kkmXoOyBflziGox/+z9olNHzv5Asxt6Xq7yQ9VsW+u06n4zm
         l+B+pixEcijAWTE9R0zEsg8nSduG7rT1NGLMoBUyITPKJ+KXtS4xSzc6WLFQzT7F7ZNM
         0nZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=OqqjfqwYsPO/UoPKKcnblUG+sfS41bCL5Aovzlt5Fak=;
        b=sqS6Hx+fdr9RhfmZoNOzQS0WVG/9SoizyChQA9kDeGA0LDI34FT/KArqiLqtFUZB2K
         RqyBy8JEp32NpeePo0qjfyw1jrIEEbnsXJPjAazOGipIkChwkskaN8LPrQcalkijTufQ
         xYIzFSwrw2upUhKOH1xEfyyTMBQeQCfb+XH/Fgc8lyg4AA+QwDypoPtS7IHPt85vvi3Y
         O3pEcUod+bQTvDRFBu7HovVMOkvHdD24PGq4uVq/wg9eCWDSsub26TVxP9vZeaPGOxIB
         64clDDCdWvcUUyurgZ8vjramLyD3A+7tRq23U/g7CSMgJdrCGszlM/66mfmNsRh8ouPM
         aQSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nqSoFbcl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z124sor1069641qkd.42.2019.06.13.17.44.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nqSoFbcl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=OqqjfqwYsPO/UoPKKcnblUG+sfS41bCL5Aovzlt5Fak=;
        b=nqSoFbcl84tRTGM0WJXSa71SkzhvazEOiTJYeTLGJQq74mfUC1lqiEvr2Cco4L/nEy
         +weOauOt2ZTDcB4618svO7UVbc6fH2ldmdAwFFTugHFlngHnhlI1EIp+5Pb4DZ+cU9DH
         nCFbS0OWzHmOdR7HoiKIJusLGSKZAhdQlbxUq/KvAcwi16XKsKuEurWf26yqrEIaa3Vl
         RR10h9G3VhLECokaJc79c/MVxgdr2FpTEz0w1U1aSeyvMQnIU2P999ygE45IVDHnmpyJ
         uyVIkUfl3punGaCvwfhde1GHKE3NYN65JghNbdZrKyPDAkr38tiYFJFciWM5POtH84K2
         Ahcw==
X-Google-Smtp-Source: APXvYqw4a4tKkG03NQONcZyCSERYSMaSwwsyoSMJBpDffae71sBOEyhn8TO2i7nXdfVHe4fh2n7xcw==
X-Received: by 2002:a37:be41:: with SMTP id o62mr62770902qkf.356.1560473095934;
        Thu, 13 Jun 2019 17:44:55 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id b203sm657058qkg.29.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005Jk-MM; Thu, 13 Jun 2019 21:44:53 -0300
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
Subject: [PATCH v3 hmm 03/12] mm/hmm: Hold a mmgrab from hmm to mm
Date: Thu, 13 Jun 2019 21:44:41 -0300
Message-Id: <20190614004450.20252-4-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190614004450.20252-1-jgg@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

So long as a struct hmm pointer exists, so should the struct mm it is
linked too. Hold the mmgrab() as soon as a hmm is created, and mmdrop() it
once the hmm refcount goes to zero.

Since mmdrop() (ie a 0 kref on struct mm) is now impossible with a !NULL
mm->hmm delete the hmm_hmm_destroy().

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2:
 - Fix error unwind paths in hmm_get_or_create (Jerome/Jason)
---
 include/linux/hmm.h |  3 ---
 kernel/fork.c       |  1 -
 mm/hmm.c            | 22 ++++------------------
 3 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 1fba6979adf460..1d97b6d62c5bcf 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -577,14 +577,11 @@ static inline int hmm_vma_fault(struct hmm_mirror *mirror,
 }
 
 /* Below are for HMM internal use only! Not to be used by device driver! */
-void hmm_mm_destroy(struct mm_struct *mm);
-
 static inline void hmm_mm_init(struct mm_struct *mm)
 {
 	mm->hmm = NULL;
 }
 #else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-static inline void hmm_mm_destroy(struct mm_struct *mm) {}
 static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 75675b9bf6dfd3..c704c3cedee78d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -673,7 +673,6 @@ void __mmdrop(struct mm_struct *mm)
 	WARN_ON_ONCE(mm == current->active_mm);
 	mm_free_pgd(mm);
 	destroy_context(mm);
-	hmm_mm_destroy(mm);
 	mmu_notifier_mm_destroy(mm);
 	check_mm(mm);
 	put_user_ns(mm->user_ns);
diff --git a/mm/hmm.c b/mm/hmm.c
index 22a97ada108b4e..080b17a2e87e2d 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -20,6 +20,7 @@
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
 #include <linux/memremap.h>
+#include <linux/sched/mm.h>
 #include <linux/jump_label.h>
 #include <linux/dma-mapping.h>
 #include <linux/mmu_notifier.h>
@@ -73,6 +74,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	hmm->notifiers = 0;
 	hmm->dead = false;
 	hmm->mm = mm;
+	mmgrab(hmm->mm);
 
 	spin_lock(&mm->page_table_lock);
 	if (!mm->hmm)
@@ -100,6 +102,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 error:
+	mmdrop(hmm->mm);
 	kfree(hmm);
 	return NULL;
 }
@@ -121,6 +124,7 @@ static void hmm_free(struct kref *kref)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 
+	mmdrop(hmm->mm);
 	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
@@ -129,24 +133,6 @@ static inline void hmm_put(struct hmm *hmm)
 	kref_put(&hmm->kref, hmm_free);
 }
 
-void hmm_mm_destroy(struct mm_struct *mm)
-{
-	struct hmm *hmm;
-
-	spin_lock(&mm->page_table_lock);
-	hmm = mm_get_hmm(mm);
-	mm->hmm = NULL;
-	if (hmm) {
-		hmm->mm = NULL;
-		hmm->dead = true;
-		spin_unlock(&mm->page_table_lock);
-		hmm_put(hmm);
-		return;
-	}
-
-	spin_unlock(&mm->page_table_lock);
-}
-
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
-- 
2.21.0

