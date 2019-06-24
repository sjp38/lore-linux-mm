Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D137C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25C9A20656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="eEL2e+Rd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25C9A20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1E2C8E000A; Mon, 24 Jun 2019 17:02:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B91378E000C; Mon, 24 Jun 2019 17:02:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BBCA8E000D; Mon, 24 Jun 2019 17:02:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 484828E000C
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:09 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id e6so6857353wrv.20
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tsR/80TrTiUsWjQJpDlrT4mzZAmfUfoSI9FV/A0UaHU=;
        b=Gi9i/VMmy4CYHQ+v+9t6E0aCIjItxT7LUzL9N3qKh0N/whwn374g8Z0eVLWxlxhkHF
         pdszpHzF5atiA9OfvX4rwHRhUEhagt2DjSL4OMAf7uhKeNCqIp09rgOkEgDGK3MF8m6l
         Km5qtCQJpC5BaLjwXJiQ6IQibkfX65w2W3YK2XENsi7AMXz2x0nw26bb7YRAFz+iFNgY
         JCqDvwtgLjNJK/T1HLmEzAgWNpQXWK8ZIt/e+zLYkXgJlHRR23l0Uq6o2S/v+qtkc5Kl
         1QZAfRttCT/goS7goWHcoi67Pp8rFC8BMpKtDzXGQ4iZDCji7PRKthHy8ud5C7DTJTpt
         kmvw==
X-Gm-Message-State: APjAAAUapMYhqqOYFB39xS4ZKABDdyYANAhficwXFqbxVHVJCzUSy/6O
	EnEMGOAmzZA2Q+nuJqI/MolEq4D3roR/VHL6U0ht077MJrywkw/xS6eAZ1olW3+k3X4j4Lpp1r8
	5poF4+RiXg5yTpAxnje7wtTVx2Io3KVcnHQ/lWuQOLT3CWFz45ycHVahG4w+yyVW6XA==
X-Received: by 2002:adf:f34b:: with SMTP id e11mr26147353wrp.230.1561410128806;
        Mon, 24 Jun 2019 14:02:08 -0700 (PDT)
X-Received: by 2002:adf:f34b:: with SMTP id e11mr26147308wrp.230.1561410127912;
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410127; cv=none;
        d=google.com; s=arc-20160816;
        b=QMPSgDpWPbze10RIH7pBgypYtu77YsmvjskqIh0vZIe3t3buLqK4DamYBQ/aNG24WD
         TPC6eYQvrhy/X3vXG4VhsW3HoRWR8nszj5PU0W5Vml9oS0moWk7K1YpSocFwXM3VaI9y
         e2SOvzE64kpS9HguWFxG8nxSOSKl9kmEb11Wc1EfREwAfByyDX0wy/fW+7Wsn/FnX7l/
         gAmrsEcx+cQxciretPNgBg+2MZCK8mB5i7cGEg9Y6gcy/+6v5hNhP+c1zcYvHyZHNqJJ
         s3fjIbi/yMSdnBbMOQBGOh1rFJkn4nknKJBNAaGJMhs0KKvopyTr4pWJf0JrAs54C3pG
         gcBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=tsR/80TrTiUsWjQJpDlrT4mzZAmfUfoSI9FV/A0UaHU=;
        b=ihClauULuSr2xf6vuSq/pY1YrYqck7Cv9UBI/3BwNepGugBk748RH3lQ4DytqZRmYV
         Qo2Qb8jZzwRZNRY5n2Q86oJUMKqCisIr/r4IaKVcRyUAMqyFWrC5czbw0n6J7Q5OeEId
         8eZfRvUoK++QVu2cB4qvnZfUaJmELq86+qsEZ5C4KhzWeZqeS0izvjgw1bAgPe+iFbvQ
         1beOIVAkbciDV630XVRLC/CDpESWqrtD0lq2UgKVDIf1J0Ls1GzCHrY2V9xPFHNLd0WN
         CQbShHqDerzu7uaMfUik4161Kif0OwwJMrBMpqO6gtlb5Enr1+s3l2XQ7flrEywOexE6
         sreA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eEL2e+Rd;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15sor2502495wru.2.2019.06.24.14.02.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eEL2e+Rd;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=tsR/80TrTiUsWjQJpDlrT4mzZAmfUfoSI9FV/A0UaHU=;
        b=eEL2e+Rdsoiw+QWNMAoS5eOmfH9fxVT52iqVy3PrFcraDcKDNUukaiSHGjOkUDbkf4
         8WHJYUyZdN7bf/y/Jstfu3A1fXcJitPxheR1/65Jv090zH+Eo5OQi1q+O4dWucKvZtrF
         Svhl2dcm8mOneehpNFXJVkZ7TYkrWa7CSn4DrBB60/QLpDJEVZeh45IqxTnVZkAWRCWG
         fnhCq6Ea5ODgJg75hQ/Xpeto43ZyjWXSU53z1FdntKD0LH/Otni2IWokQ2rJk9vV5gII
         L0dENrfxVOm9si6Xksz7dp0Ey4NfHgch3yvMfxoEZTAShU86NCM8h0UHtjz8kyN+4J6G
         MbOw==
X-Google-Smtp-Source: APXvYqyzrTyoPhYHFWjo48jic83g1/CALuSvPyW3MCerg+RPA+Kf+K4POtxSR/W0sWmHBTVwQ3b5Mw==
X-Received: by 2002:adf:a312:: with SMTP id c18mr18493691wrb.332.1561410127528;
        Mon, 24 Jun 2019 14:02:07 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id x11sm469692wmg.23.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6C-0001MW-VA; Mon, 24 Jun 2019 18:02:00 -0300
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
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v4 hmm 07/12] mm/hmm: Hold on to the mmget for the lifetime of the range
Date: Mon, 24 Jun 2019 18:01:05 -0300
Message-Id: <20190624210110.5098-8-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190624210110.5098-1-jgg@ziepe.ca>
References: <20190624210110.5098-1-jgg@ziepe.ca>
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
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2:
 - Use Jerome's idea of just holding the mmget() for the range lifetime,
   rework the patch to use that as as simplification to remove dead in
   one step
v3:
 - Use list_del_careful (Christoph)
---
 include/linux/hmm.h | 26 --------------------------
 mm/hmm.c            | 32 +++++++++++---------------------
 2 files changed, 11 insertions(+), 47 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 26e7c477490c4e..bf013e96525771 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -82,7 +82,6 @@
  * @mirrors_sem: read/write semaphore protecting the mirrors list
  * @wq: wait queue for user waiting on a range invalidation
  * @notifiers: count of active mmu notifiers
- * @dead: is the mm dead ?
  */
 struct hmm {
 	struct mm_struct	*mm;
@@ -95,7 +94,6 @@ struct hmm {
 	wait_queue_head_t	wq;
 	struct rcu_head		rcu;
 	long			notifiers;
-	bool			dead;
 };
 
 /*
@@ -459,30 +457,6 @@ struct hmm_mirror {
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
index 73c8af4827fe87..1eddda45cefae7 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -67,7 +67,6 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	mutex_init(&hmm->lock);
 	kref_init(&hmm->kref);
 	hmm->notifiers = 0;
-	hmm->dead = false;
 	hmm->mm = mm;
 
 	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
@@ -120,21 +119,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
-	struct hmm_range *range;
 
 	/* Bail out if hmm is in the process of being freed */
 	if (!kref_get_unless_zero(&hmm->kref))
 		return;
 
-	/* Report this HMM as dying. */
-	hmm->dead = true;
-
-	/* Wake-up everyone waiting on any range. */
-	mutex_lock(&hmm->lock);
-	list_for_each_entry(range, &hmm->ranges, list)
-		range->valid = false;
-	wake_up_all(&hmm->wq);
-	mutex_unlock(&hmm->lock);
+	/*
+	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
+	 * prevented as long as a range exists.
+	 */
+	WARN_ON(!list_empty_careful(&hmm->ranges));
 
 	down_write(&hmm->mirrors_sem);
 	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
@@ -903,8 +897,8 @@ int hmm_range_register(struct hmm_range *range,
 	range->start = start;
 	range->end = end;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
+	/* Prevent hmm_release() from running while the range is valid */
+	if (!mmget_not_zero(hmm->mm))
 		return -EFAULT;
 
 	/* Initialize range to track CPU page table updates. */
@@ -942,11 +936,12 @@ void hmm_range_unregister(struct hmm_range *range)
 		return;
 
 	mutex_lock(&hmm->lock);
-	list_del(&range->list);
+	list_del_init(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
 	range->valid = false;
+	mmput(hmm->mm);
 	hmm_put(hmm);
 	range->hmm = NULL;
 }
@@ -974,10 +969,7 @@ long hmm_range_snapshot(struct hmm_range *range)
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
@@ -1072,9 +1064,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	struct mm_walk mm_walk;
 	int ret;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
-		return -EFAULT;
+	lockdep_assert_held(&hmm->mm->mmap_sem);
 
 	do {
 		/* If range is no longer valid force retry. */
-- 
2.22.0

