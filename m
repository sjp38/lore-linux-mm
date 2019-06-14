Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AD21C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D1D620850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="KUyynqtg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D1D620850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 859056B026D; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B9D56B026C; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6338C6B0270; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0496B026C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p43so674182qtk.23
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vOT/1//lPYO2KnTg7JAYlGe+L6wOGbnqhk1iQ3bfzXA=;
        b=EpttiUUm26FVUI4Mln1mOXkMZd/lsZE8j8zPy18pFLK01XQi9xzAETW2kM/1arYOJG
         SemmzzXHFyUUataGohH6ll0+v8Pey9oR8UYj+ypS2oOssK4oyRQd7uEtQP6qc+2VkTqz
         bWr9qA8Ud52iEe7J/QiYQQDXrSzCvmw8KHXRLOtAk+UFF4w8816eb4rlVqyA4nnlg98E
         TMCycHmorN7fhVeCLuM3DCGtwVXgE7gLf/Q4vgqjCnl1rrkeC0ICKV+/UF0P7SqazlNH
         74fafiJRAUyUqG4SN+M2+xPGTjWBQma5AG0G875VnMY4pHIl9dX0G/88vJbpop03uK1R
         /B+w==
X-Gm-Message-State: APjAAAWTKjfM8tTiBTwxPrcQx2MUgJjG9tkc6nXBjglmcKcw21GYcSsU
	0QaRwX0iRVifzjIkbSoUEmOVpH5lIiJ9fJQwVJsFS8swj+WW3fwZnAI4arM+O7psRotyboOWA5c
	ObEQtAokgUTvzoU55Q4uLRUhTMxJEqZ/4aYBz9rJPE0kNzt5fEBpM4VZBkQfTT/hNzw==
X-Received: by 2002:a37:4f51:: with SMTP id d78mr73989732qkb.253.1560473097967;
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
X-Received: by 2002:a37:4f51:: with SMTP id d78mr73989702qkb.253.1560473097127;
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473097; cv=none;
        d=google.com; s=arc-20160816;
        b=AbZk+IrUiPfCBt6QJVgpAXaaI8AxziPRyGRlUB5VXhRc1feBpXfvI9Zy1flwgK2UYj
         3EAB7MlL20R9xblPJvAHlDMhZmB2xVtz8uO7c7EeYSlK1lybAq3VQj+CbZ/wFvoj57+e
         pSafxxbABstNClL1vRxKUpL05hDhIMSLXxuM0nJNr5IoRD+VtEYG69t+KWy+hMnJOJz0
         Y0cs59bBcSCJIIvvaDpH5L+S8tHdd2U7Xa9t20tjkqdaJEhRxIekbXFyoLLU0yjWKfuL
         PsMHvQFflDMiiVqVuzOkrmIyLipHfO00eALmgaBGAoR5SOmuEpkSMqbeaCmwiP9NMeGE
         Swog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vOT/1//lPYO2KnTg7JAYlGe+L6wOGbnqhk1iQ3bfzXA=;
        b=V13zMOuKi4DHrcXBy/3wRsq79wjX1jGg2BhNSt9Bn0OsBjbW38xqeshR/hJYJZqzOz
         ytm0T/RCJdzefB2axMuvZwD0lCcBSV0Ri6/YlESILn8awcu+K4fQCIg6YOaJ9a8EhH1a
         fdoeo6Co9x2NKVBmb/wO5XwX3YieVzYRYTazW1XAWDsARJUXwqVeXINVx6mC9IuRrzyp
         GxwmDQ4qTrg2Xq0oBjft++MHhydQsTvTc4acalg1ivG0biQ4pzbLAqnKNM8/Ksr36SHK
         zaeITvmNe6eVa6Mg/NjaeYnJjOof6PQJGKXkCXLDUJfLB/3PE2GAMN84pSCg8du6HI6Y
         nKPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KUyynqtg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v83sor1036472qkb.100.2019.06.13.17.44.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KUyynqtg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vOT/1//lPYO2KnTg7JAYlGe+L6wOGbnqhk1iQ3bfzXA=;
        b=KUyynqtgRE6EpplNjkgK7xEKW+4i8YtoCdu847R/HKHbJfnzbjofwdI3Ea6k0EuVSe
         1CZaEOJYQRtMq3h0sFFCemgzzSgbiIlR01ffFmvPX9pmujQZhT4dybPJ0azLpv2M3X9+
         6Tb39zktfnoe3oIet0A0akwq1fikYli3gOB8Ej+qnnX38PCI4BOZsTugxauTr9grN1NY
         o/xA6GHrOsOdFk1lM9xdmnpjoyYypBmE2AejoMzAHHaTMtA6L+OhWLo1qhD7nA3VHByF
         jua1HGswi4DoY/NGhXWwkfny9XYjh5QfCt8aiJgJGRL1dZHZMavFJ9hgwEsQQVXXj1WN
         tnCg==
X-Google-Smtp-Source: APXvYqxEi3V4pWZnBZ6Egs6ifesaB2oNEQOI04AD8yR+MI7rsCDs0etSdyPsSPlsZHy2Q2fiQCFnwA==
X-Received: by 2002:a05:620a:1310:: with SMTP id o16mr71613012qkj.196.1560473096852;
        Thu, 13 Jun 2019 17:44:56 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id z126sm884276qkb.7.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005K2-Rs; Thu, 13 Jun 2019 21:44:53 -0300
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
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH v3 hmm 06/12] mm/hmm: Hold on to the mmget for the lifetime of the range
Date: Thu, 13 Jun 2019 21:44:44 -0300
Message-Id: <20190614004450.20252-7-jgg@ziepe.ca>
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
Tested-by: Philip Yang <Philip.Yang@amd.com>
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
index 4c64d4c32f4825..58712d74edd585 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -70,7 +70,6 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	mutex_init(&hmm->lock);
 	kref_init(&hmm->kref);
 	hmm->notifiers = 0;
-	hmm->dead = false;
 	hmm->mm = mm;
 
 	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
@@ -125,20 +124,17 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
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
@@ -908,8 +904,8 @@ int hmm_range_register(struct hmm_range *range,
 	range->start = start;
 	range->end = end;
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL || hmm->dead)
+	/* Prevent hmm_release() from running while the range is valid */
+	if (!mmget_not_zero(hmm->mm))
 		return -EFAULT;
 
 	/* Initialize range to track CPU page table updates. */
@@ -952,6 +948,7 @@ void hmm_range_unregister(struct hmm_range *range)
 
 	/* Drop reference taken by hmm_range_register() */
 	range->valid = false;
+	mmput(hmm->mm);
 	hmm_put(hmm);
 	range->hmm = NULL;
 }
@@ -979,10 +976,7 @@ long hmm_range_snapshot(struct hmm_range *range)
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
@@ -1077,9 +1071,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
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

