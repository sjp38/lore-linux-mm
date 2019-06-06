Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BF49C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D9E9208E4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="QCSARRqk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D9E9208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24E206B0280; Thu,  6 Jun 2019 14:44:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D6656B0281; Thu,  6 Jun 2019 14:44:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09EFC6B0282; Thu,  6 Jun 2019 14:44:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D737F6B0281
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:49 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l11so2846594qtp.22
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vDRIilFVldnvkbkMJDKjjlCneF+91QuQaIvOaI3TwIs=;
        b=HmFnN82E+p7OkX/hzxZz2I0tAbK9WRNRnYyoHqUAh14z6YSNObUHDFtCRCwUuOcXcM
         QQC29sB5o+aWof7CFxIeQqx63rdogl+EgMKPIC1IY55WKh4KfhBmX8vxNwsmb0axodhj
         wqdC67upX41Wf8R/0WNnqNmHjpmpNb39Vjj8jHvhlMa2bko1Bs4ElVq8eZhUx0JqGJCI
         H6k5iDzyJcR8ytVmj9sO0vfzTovZutUkS/H85c9fXNoNhhu2Ze2MPHH/IhI7CAqUzSNZ
         4CfuGAHE23memUy+TSEUEbS28FJHp8eE/hfxjIKthP+MxI2qBsCEIsf6U6ePcQR5fvpE
         7+Nw==
X-Gm-Message-State: APjAAAXycY5MYlrCNotwZDFwWnRyNJDNdWu+LWEcVRb+qX8lAyQUnHGn
	yUUqxEfX74FjWW6gEZjyoZtWLwwbPzyEdL12+G63+LnmEmFs1VaeZYXVHJZeJvS2NbP5bJ0D5i+
	vpId52PCKRDEjiDmeUJB0ClUW9PCUCYx/GtmnNYgd1rDvAXbzYpHc83vQIZ3xKsvkLA==
X-Received: by 2002:ac8:3301:: with SMTP id t1mr36740577qta.209.1559846689606;
        Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
X-Received: by 2002:ac8:3301:: with SMTP id t1mr36740539qta.209.1559846688830;
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846688; cv=none;
        d=google.com; s=arc-20160816;
        b=jsj5B3d7x2IH3hcH5Pp/F3+XCCpujYPyGtdsAGnuNajMbOARKbJea6xZlBPvk2uQE+
         xbAzZCcmVgtHwoGo2wJDA+2LHtx+0F6uAsQpqtOeqCoJ1lX2JoUIZYctpy5nEuyD5vUf
         TygkUssSVP/sNiPpmMl+ANuDjiXtV5jZnYS5AxN056h3RJpEo9UaI/2tCYHx6picvISv
         IBOCCkBdJa9dP+6hqaQsOP6si+uyUtQxYJRfwppCJG0uBy0AvFpOjBZCoMFsJzpeFdIF
         yPQ3jv+92MV2FHSwzirqJPatDKmptWMglMJpLw+2itUUIyhwiA48pbfh0Vkn1jtVmCJK
         7u5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vDRIilFVldnvkbkMJDKjjlCneF+91QuQaIvOaI3TwIs=;
        b=HSZhy/qQ+HI6YlkFGDzuL003wwrlumK0qs+6WAtdsKhzF12/nfHQo0XJS+R9P3kJwp
         xjZm6hQI9CjxDEZxRLq/Vw4HtGqv0Z3z+HrT1NPx02qII/heOdPDlcFMWkUO2GCthkZz
         yBHyKThbC7ILLOnSkMT86OS80u3asIPgRwEECnVQCvRJfHbwM0V5GSaVv3nkyVQ565DD
         OfKRgqqEGjEQqTODUR1Pl5ZdC7q1DihGIC/m/cbprNN2bZ7w57LNDYVr7RC8TxHVwERa
         Rx00IXI4Py1Xz+vkI8QOBcgDs0bob7H2FFo322GLYKVmpV2bdYKDkBd5OVrskBIfmUn4
         Ht4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=QCSARRqk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r2sor3143973qti.71.2019.06.06.11.44.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=QCSARRqk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vDRIilFVldnvkbkMJDKjjlCneF+91QuQaIvOaI3TwIs=;
        b=QCSARRqkANiDuo9Zt0gh3n3vfALB6ijEiRwqIMaXCX3/qGzEYVq5zDKzohmDrx2kEq
         E/nLyL1hf/Yw2YVKQK2mevK/3x7wbrlWVevgrKFbIiCf3/EB6QRExm5LWe5UtxC9rV5d
         UQwAlzEs9kATjD+x85Cuz49AhNxPFC7gKS60FnQfbxtiMvkSooOuUBX+Iv5TIFtZIcqQ
         Aee5zzJxne/q8crQAD9Is+y1upCG3grwwPRQuj39icbmd1uTk0pCmr+5K/a+fe+W+cWn
         Ye97kdTtyZ2qAfyBP9hoRiiA8P1jinSjAUnj4sUnxQAhfyk59Kal+WLdZQytIQm+fu8L
         ZYtQ==
X-Google-Smtp-Source: APXvYqxDHwC4C9hnk7VytBkovRfN98/hasmwmCm/dELdXMnufTdP+P+aFJn1ExmavzkvjsH0ryaMNg==
X-Received: by 2002:ac8:28dd:: with SMTP id j29mr42963672qtj.34.1559846688561;
        Thu, 06 Jun 2019 11:44:48 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 77sm871850qkd.59.2019.06.06.11.44.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008IZ-M7; Thu, 06 Jun 2019 15:44:45 -0300
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
Subject: [PATCH v2 hmm 06/11] mm/hmm: Hold on to the mmget for the lifetime of the range
Date: Thu,  6 Jun 2019 15:44:33 -0300
Message-Id: <20190606184438.31646-7-jgg@ziepe.ca>
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

Range functions like hmm_range_snapshot() and hmm_range_fault() call
find_vma, which requires hodling the mmget() and the mmap_sem for the mm.

Make this simpler for the callers by holding the mmget() inside the range
for the lifetime of the range. Other functions that accept a range should
only be called if the range is registered.

This has the side effect of directly preventing hmm_release() from
happening while a range is registered. That means range->dead cannot be
false during the lifetime of the range, so remove dead and
hmm_mirror_mm_is_alive() entirely.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
v2:
 - Use Jerome's idea of just holding the mmget() for the range lifetime,
   rework the patch to use that as as simplification to remove dead in
   one step
---
 include/linux/hmm.h | 26 --------------------------
 mm/hmm.c            | 28 ++++++++++------------------
 2 files changed, 10 insertions(+), 44 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 2ab35b40992b24..0e20566802967a 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -91,7 +91,6 @@
  * @mirrors_sem: read/write semaphore protecting the mirrors list
  * @wq: wait queue for user waiting on a range invalidation
  * @notifiers: count of active mmu notifiers
- * @dead: is the mm dead ?
  */
 struct hmm {
 	struct mm_struct	*mm;
@@ -104,7 +103,6 @@ struct hmm {
 	wait_queue_head_t	wq;
 	struct rcu_head		rcu;
 	long			notifiers;
-	bool			dead;
 };
 
 /*
@@ -469,30 +467,6 @@ struct hmm_mirror {
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
-/*
- * hmm_mirror_mm_is_alive() - test if mm is still alive
- * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
- * Return: false if the mm is dead, true otherwise
- *
- * This is an optimization, it will not always accurately return false if the
- * mm is dead; i.e., there can be false negatives (process is being killed but
- * HMM is not yet informed of that). It is only intended to be used to optimize
- * out cases where the driver is about to do something time consuming and it
- * would be better to skip it if the mm is dead.
- */
-static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
-{
-	struct mm_struct *mm;
-
-	if (!mirror || !mirror->hmm)
-		return false;
-	mm = READ_ONCE(mirror->hmm->mm);
-	if (mirror->hmm->dead || !mm)
-		return false;
-
-	return true;
-}
-
 /*
  * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
diff --git a/mm/hmm.c b/mm/hmm.c
index dc30edad9a8a02..f67ba32983d9f1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -80,7 +80,6 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	mutex_init(&hmm->lock);
 	kref_init(&hmm->kref);
 	hmm->notifiers = 0;
-	hmm->dead = false;
 	hmm->mm = mm;
 
 	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
@@ -124,20 +123,17 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
-	struct hmm_range *range;
 
 	/* hmm is in progress to free */
 	if (!kref_get_unless_zero(&hmm->kref))
 		return;
 
-	/* Report this HMM as dying. */
-	hmm->dead = true;
-
-	/* Wake-up everyone waiting on any range. */
 	mutex_lock(&hmm->lock);
-	list_for_each_entry(range, &hmm->ranges, list)
-		range->valid = false;
-	wake_up_all(&hmm->wq);
+	/*
+	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
+	 * prevented as long as a range exists.
+	 */
+	WARN_ON(!list_empty(&hmm->ranges));
 	mutex_unlock(&hmm->lock);
 
 	down_write(&hmm->mirrors_sem);
@@ -909,8 +905,8 @@ int hmm_range_register(struct hmm_range *range,
 	range->start = start;
 	range->end = end;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
+	/* Prevent hmm_release() from running while the range is valid */
+	if (!mmget_not_zero(hmm->mm))
 		return -EFAULT;
 
 	range->hmm = hmm;
@@ -955,6 +951,7 @@ void hmm_range_unregister(struct hmm_range *range)
 
 	/* Drop reference taken by hmm_range_register() */
 	range->valid = false;
+	mmput(hmm->mm);
 	hmm_put(hmm);
 	range->hmm = NULL;
 }
@@ -982,10 +979,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 	struct vm_area_struct *vma;
 	struct mm_walk mm_walk;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
-		return -EFAULT;
-
+	lockdep_assert_held(&hmm->mm->mmap_sem);
 	do {
 		/* If range is no longer valid force retry. */
 		if (!range->valid)
@@ -1080,9 +1074,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	struct mm_walk mm_walk;
 	int ret;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
-		return -EFAULT;
+	lockdep_assert_held(&hmm->mm->mmap_sem);
 
 	do {
 		/* If range is no longer valid force retry. */
-- 
2.21.0

