Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B88CC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B653620850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UA1C5NPq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B653620850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E72E16B026A; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAD5A6B026C; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8D1D6B026F; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7022B6B026A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:57 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id u129so642289qkd.12
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iQFZUVD3bm8q29tG8rKodDV9niV08KJ4TO1srbmenK4=;
        b=E/taCVPq+f97Ed9wscAUpd/Fp1rtKG8wLsm9pmlinKogMM29vZThMs6EZjL5l2RR0r
         7zM7m4eTJEQnCvugytFYHc2j2oaHvq1YUsmwtXHaXPtOzWygPGYBLtenywJ3vX18l0gH
         LBYH+G82FtpvVHmC5bm5axEXZO6jNEGV3qc+gj66BSd6UMkTFmSWkv0VmyBr2+L31s8h
         px8lC50IfxgF7d5hxIwmVcjaNZVeTdu/ZeUy6PR5j9M2ZbRQsE33T5jIMf61rYvSwZQX
         C10O77jj+Y9WMUYWQHv17LQcs3wqEdGgBPNd8ijByHLLTrhp7qZIZX1koLFD4bbjzGlI
         VZaQ==
X-Gm-Message-State: APjAAAVLXF1Y49yTRCrHI6lMm7tR81GDK0mcZSo/CTRSaVoAo4spB3K/
	8yfNtTcni/Kyj6H6x2zzAB8UVhfqE0OSIivWYex+ngs9Rvfv2pVnoFmXNHzqvh+wInwuBsQ1QMo
	Kqyb9tcYT4vkQGs+jBx7vNEj5Wae8Ehf69rBFncSe03HAyOTaTX1+bRavpoiQfhYDMA==
X-Received: by 2002:a37:de18:: with SMTP id h24mr18765496qkj.147.1560473097240;
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
X-Received: by 2002:a37:de18:: with SMTP id h24mr18765470qkj.147.1560473096612;
        Thu, 13 Jun 2019 17:44:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473096; cv=none;
        d=google.com; s=arc-20160816;
        b=z2vwekf0JYqv5CTw+lY+BO0tgfBvfKzvW0GXymUbvqvm/Gj9qi1ZKihUlW6oFeSyVw
         jKlcqtBI7fxAenVC4qLFBGa6NTR4yZfEDOrJj90xo2mbSg7agVS+485RdfcEBYSvMQw/
         /3ALDdT+SB3TO25Lj5dKnW4BNgJT2Gu7VqV8OBO94cr0lWi5Osx6DTpcUnKjjRyGfzlJ
         9vNl/8cYEKGvHv2xQb+ikpL8fPfdV1TnGBtgRPLfOYCIBsZsBJI7HPiRAhqvLZ5I5CMT
         fu0Kuj6ACe704BdyntI3IprUXLQ8tgciOHIPWqoO5paWiiB7ljhCMSPwrZIHyT704Krm
         qNQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=iQFZUVD3bm8q29tG8rKodDV9niV08KJ4TO1srbmenK4=;
        b=eyOcvSGUvgcCpAFwsGZxuSuyiRiYhUlXs6OvgKLv5KuxAxc1npm/8jJGX3tjTaInwd
         DK3bNSDdhrv6WZAnYCtR+vtGszQzyOZSw2tEsQPWjjtJcoMKe1FFo4e+s3INyx26uj83
         ttuvsYE8uEdqEzuCCnD/PIcc4rXekrvy9tz3EoeuqKBCt8DbMje9KNymtEDSEfG+2L2/
         2iV5AHA8hyxT7ETLHcKShuq3g/CbkC2NPRHL6oDcGFUKh41OPUod3vWeYHvMfjw9xBnZ
         VaS3HtsUfze9mcJI3Zhk0pCJn7wI8zwRleNnSLWu3RaSpEzeRso2wfCiCat7CkZRlOdS
         IK2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UA1C5NPq;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o7sor1032381qvf.60.2019.06.13.17.44.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UA1C5NPq;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=iQFZUVD3bm8q29tG8rKodDV9niV08KJ4TO1srbmenK4=;
        b=UA1C5NPqvlm8z++G2laNCnwB/GWT7FWVDsQKpzNw396EnXD5grCbfeRcH4MVcv9Pxt
         Bw608pa0SQVwTZPesERpsVjDiheiUA0ZxpcaOhSCg3wFfLyCKPSY6m0rcqgkt0F7+Btu
         VcnvcuEPLZ4+31oNvXwgQ7Mzr5sdaFHqpO9DtB7bD2Mphja5lK5GoftxQttJJRITdM9l
         ZjsrOqKbZRdEDMQmdCny9EgekTtIr+yc7ps9gI2Z9j+YV7fGRjNJ2Dq2ZT34qRz8bx4L
         2H+VNusPv5/abMz/Jh+ee/Y2I8OCp7Q6Wc38Z0vyw+mbGlfjmn34SHlMrcpzNY0sbebl
         RR8A==
X-Google-Smtp-Source: APXvYqw56kQGKLPlj2Zgzkw2ysxgtbRlSboLCdNQH17EQruEZjbScaFJD3FwSz5lL9I3GIRJGcwbsg==
X-Received: by 2002:a0c:afa2:: with SMTP id s31mr5894610qvc.186.1560473096316;
        Thu, 13 Jun 2019 17:44:56 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id l3sm683628qkd.49.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005Jq-Ni; Thu, 13 Jun 2019 21:44:53 -0300
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
Subject: [PATCH v3 hmm 04/12] mm/hmm: Simplify hmm_get_or_create and make it reliable
Date: Thu, 13 Jun 2019 21:44:42 -0300
Message-Id: <20190614004450.20252-5-jgg@ziepe.ca>
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

As coded this function can false-fail in various racy situations. Make it
reliable and simpler by running under the write side of the mmap_sem and
avoiding the false-failing compare/exchange pattern. Due to the mmap_sem
this no longer has to avoid racing with a 2nd parallel
hmm_get_or_create().

Unfortunately this still has to use the page_table_lock as the
non-sleeping lock protecting mm->hmm, since the contexts where we free the
hmm are incompatible with mmap_sem.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2:
- Fix error unwind of mmgrab (Jerome)
- Use hmm local instead of 2nd container_of (Jerome)
v3:
- Can't use mmap_sem in the SRCU callback, keep using the
  page_table_lock (Philip)
---
 mm/hmm.c | 84 ++++++++++++++++++++++++--------------------------------
 1 file changed, 36 insertions(+), 48 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 080b17a2e87e2d..4c64d4c32f4825 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -31,16 +31,6 @@
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
-static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
-{
-	struct hmm *hmm = READ_ONCE(mm->hmm);
-
-	if (hmm && kref_get_unless_zero(&hmm->kref))
-		return hmm;
-
-	return NULL;
-}
-
 /**
  * hmm_get_or_create - register HMM against an mm (HMM internal)
  *
@@ -55,11 +45,19 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
  */
 static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 {
-	struct hmm *hmm = mm_get_hmm(mm);
-	bool cleanup = false;
+	struct hmm *hmm;
 
-	if (hmm)
-		return hmm;
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
+
+	/* Abuse the page_table_lock to also protect mm->hmm. */
+	spin_lock(&mm->page_table_lock);
+	if (mm->hmm) {
+		if (kref_get_unless_zero(&mm->hmm->kref)) {
+			spin_unlock(&mm->page_table_lock);
+			return mm->hmm;
+		}
+	}
+	spin_unlock(&mm->page_table_lock);
 
 	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
 	if (!hmm)
@@ -74,57 +72,47 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	hmm->notifiers = 0;
 	hmm->dead = false;
 	hmm->mm = mm;
-	mmgrab(hmm->mm);
 
-	spin_lock(&mm->page_table_lock);
-	if (!mm->hmm)
-		mm->hmm = hmm;
-	else
-		cleanup = true;
-	spin_unlock(&mm->page_table_lock);
+	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
+	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
+		kfree(hmm);
+		return NULL;
+	}
 
-	if (cleanup)
-		goto error;
+	mmgrab(hmm->mm);
 
 	/*
-	 * We should only get here if hold the mmap_sem in write mode ie on
-	 * registration of first mirror through hmm_mirror_register()
+	 * We hold the exclusive mmap_sem here so we know that mm->hmm is
+	 * still NULL or 0 kref, and is safe to update.
 	 */
-	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
-	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
-		goto error_mm;
-
-	return hmm;
-
-error_mm:
 	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
+	mm->hmm = hmm;
 	spin_unlock(&mm->page_table_lock);
-error:
-	mmdrop(hmm->mm);
-	kfree(hmm);
-	return NULL;
+	return hmm;
 }
 
 static void hmm_free_rcu(struct rcu_head *rcu)
 {
-	kfree(container_of(rcu, struct hmm, rcu));
+	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
+
+	/*
+	 * The mm->hmm pointer is kept valid while notifier ops can be running
+	 * so they don't have to deal with a NULL mm->hmm value
+	 */
+	spin_lock(&hmm->mm->page_table_lock);
+	if (hmm->mm->hmm == hmm)
+		hmm->mm->hmm = NULL;
+	spin_unlock(&hmm->mm->page_table_lock);
+	mmdrop(hmm->mm);
+
+	kfree(hmm);
 }
 
 static void hmm_free(struct kref *kref)
 {
 	struct hmm *hmm = container_of(kref, struct hmm, kref);
-	struct mm_struct *mm = hmm->mm;
-
-	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
 
-	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
-	spin_unlock(&mm->page_table_lock);
-
-	mmdrop(hmm->mm);
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
 	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
-- 
2.21.0

