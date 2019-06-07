Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3C2CC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:06:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2548C20657
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:06:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="h6KpvG8k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2548C20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 802B76B0007; Fri,  7 Jun 2019 12:06:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B24B6B000C; Fri,  7 Jun 2019 12:06:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A10B6B000E; Fri,  7 Jun 2019 12:06:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5566B0007
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 12:06:00 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q26so2247014qtr.3
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 09:06:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mDQI7vDRgVEqfEUUaCyaBBK+4bOYH5UfB7o3hA1mJXA=;
        b=R8XbfYvbiL/I3Y58CoC0Tjy0wnuQ3drbs3jZZ9s+VzMn3f5vJUIkU+EE0KsDaMe1Gx
         kscYIdLF3vXNzTT4Dawxz11xR0sa8GkYOzqPSNyV6MbgWJ6+sy9yIZ710Z5apWpBUu+r
         U/2iqh9jRdENRSa1qmAEH0Gu5TP9l/+5xUVUTL0PwbCJyqY4MSCVG+le8BfFTUiQHIb9
         tWE114H2/yn77dUXTUpB0YQZ4O9N/Su/6yOlDgoht4Xw2HbKENYt1mAVXwkaGNss68uu
         ke51MeHRExx6FM4ifZ2Z4gkXA5EHkzX5EeuSHOJjBD/fF0365aB6ODRNZ7kqd/PgvOto
         eo9g==
X-Gm-Message-State: APjAAAU7+QnVZ84RiQb6Y/YHpNyTlw79ZKI2l7Qi9T7DPn703S4rUM8Q
	Tf+SEPCwiVh4jsIu2RK9WESteKNxdykkIsAMXPsIcvQhR+DXwdqgU88tIUFhAsv4uU3ZyEd1bdP
	Z/rb35CSMNW5V9ddWB83daTZnUigQ/jfxl26cr4vP3tS6seMnbXaFJijrWp6UzcX5Bw==
X-Received: by 2002:ac8:28c2:: with SMTP id j2mr45987407qtj.103.1559923560021;
        Fri, 07 Jun 2019 09:06:00 -0700 (PDT)
X-Received: by 2002:ac8:28c2:: with SMTP id j2mr45987316qtj.103.1559923558871;
        Fri, 07 Jun 2019 09:05:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559923558; cv=none;
        d=google.com; s=arc-20160816;
        b=LWNNSKq2fzP0Pz6ykMLc3oXQo+MAz/4mu53RpQS81Nx1E6b9ETz9z+z1snorSj62ZX
         NYRf0pTAsMlUtNadpF/YLRUVYzizrbXStrP7nP5KQ5Wa6wWwtwyZlrM3UuP3AgEjPJft
         tDmGNlfmGbozGS/PO0CSPrOzkSova1ThbuLiJghryieTNlIkoyY28XiKS077EQuJ/8oR
         /zhk1v24BX78/r8YjCbpOvFI1ss4evY4D23UV6o9ZuA9ov5zjVTzTcuOrT1TgAuqcqdR
         hT6BDenCRuhzXX0VgXI5eSfsf9DKeCZk16mxSPFT0eq8lfal41QI0Qb2dawpH5G3/ZHB
         EIQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mDQI7vDRgVEqfEUUaCyaBBK+4bOYH5UfB7o3hA1mJXA=;
        b=UGYGkM6VZMfCc8KAsHsr5HAEgThs9JwrHzezJuMPnajxEeFn29z9lZSph6N6rLdYcl
         IZ7OUeWfy3vJHu2Q1nSFjZrDE5eDgP9qwhQ95THeox71rMvCYgLe992In937FnyGu22A
         blMaCMIny3IouEMK/d42e1Wu/5MxjM88pT8c1WbJxK1gGriFMXCohcVn+oxx2F24RCRR
         EQf3k7IrCPQ90tk7RHV175CBm1XCqkVPsTbcFJSu6p8uEmcr4Axgjdyx/dAMIgDuuAWa
         T6Dvgvb15ATaTL9lyFXbdegs734bcu0N1/4ddAjhj/O4Rx4Qu0aYM7DqO7P/TUCMl99Z
         zZrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=h6KpvG8k;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j34sor2937948qte.42.2019.06.07.09.05.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 09:05:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=h6KpvG8k;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mDQI7vDRgVEqfEUUaCyaBBK+4bOYH5UfB7o3hA1mJXA=;
        b=h6KpvG8kEPwZ4LEZggj55gXJyseLol+sT11VPWvdlbvHuRB/SDV9CdXfnBVmjGGNUR
         rOaB3khRLP9k43hFFlM7JgJrB+xap09v5WEvcNpCcDm+R7q6tjjOEBwesAVq48cJ/83g
         So0nJITGzjxRk4D0uPQp5n7PvmlL4uFKrl/48pOQIl6ZN2eKDvmwWgXQZlPWvyAnWlIw
         yU5ZwpruBe/84KRjpLYqcD9PBjC1jDUG3G9Ohbk+ythU2LvunFU4UkOUnBzmx4hF6Ao0
         Lnzva0XY+uFw0Y+ynwlkcWlHyp6MBQc24OEdhN/d2qSSoB3U9Jw6KgBVG8SRZERqZzkb
         2hlw==
X-Google-Smtp-Source: APXvYqwIT1CmduZzPGFrLNflexTC0zIShRnLBlA8OsJP0/v7GZFL6ZhIHAbjBC1Kw7kXZZYVQlIuiQ==
X-Received: by 2002:ac8:1af4:: with SMTP id h49mr38593897qtk.183.1559923558110;
        Fri, 07 Jun 2019 09:05:58 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id n124sm1260323qkf.31.2019.06.07.09.05.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 09:05:57 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZHNN-00008j-5Z; Fri, 07 Jun 2019 13:05:57 -0300
Date: Fri, 7 Jun 2019 13:05:57 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: [PATCH v2 12/11] mm/hmm: Fix error flows in
 hmm_invalidate_range_start
Message-ID: <20190607160557.GA335@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If the trylock on the hmm->mirrors_sem fails the function will return
without decrementing the notifiers that were previously incremented. Since
the caller will not call invalidate_range_end() on EAGAIN this will result
in notifiers becoming permanently incremented and deadlock.

If the sync_cpu_device_pagetables() required blocking the function will
not return EAGAIN even though the device continues to touch the
pages. This is a violation of the mmu notifier contract.

Switch, and rename, the ranges_lock to a spin lock so we can reliably
obtain it without blocking during error unwind.

The error unwind is necessary since the notifiers count must be held
incremented across the call to sync_cpu_device_pagetables() as we cannot
allow the range to become marked valid by a parallel
invalidate_start/end() pair while doing sync_cpu_device_pagetables().

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 include/linux/hmm.h |  2 +-
 mm/hmm.c            | 77 +++++++++++++++++++++++++++------------------
 2 files changed, 48 insertions(+), 31 deletions(-)

I almost lost this patch - it is part of the series, hasn't been
posted before, and wasn't sent with the rest, sorry.

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index bf013e96525771..0fa8ea34ccef6d 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -86,7 +86,7 @@
 struct hmm {
 	struct mm_struct	*mm;
 	struct kref		kref;
-	struct mutex		lock;
+	spinlock_t		ranges_lock;
 	struct list_head	ranges;
 	struct list_head	mirrors;
 	struct mmu_notifier	mmu_notifier;
diff --git a/mm/hmm.c b/mm/hmm.c
index 4215edf737ef5b..10103a24e9b7b3 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -68,7 +68,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	init_rwsem(&hmm->mirrors_sem);
 	hmm->mmu_notifier.ops = NULL;
 	INIT_LIST_HEAD(&hmm->ranges);
-	mutex_init(&hmm->lock);
+	spin_lock_init(&hmm->ranges_lock);
 	kref_init(&hmm->kref);
 	hmm->notifiers = 0;
 	hmm->mm = mm;
@@ -114,18 +114,19 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
+	unsigned long flags;
 
 	/* Bail out if hmm is in the process of being freed */
 	if (!kref_get_unless_zero(&hmm->kref))
 		return;
 
-	mutex_lock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	/*
 	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
 	 * prevented as long as a range exists.
 	 */
 	WARN_ON(!list_empty(&hmm->ranges));
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	down_read(&hmm->mirrors_sem);
 	list_for_each_entry(mirror, &hmm->mirrors, list) {
@@ -141,6 +142,23 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	hmm_put(hmm);
 }
 
+static void notifiers_decrement(struct hmm *hmm)
+{
+	lockdep_assert_held(&hmm->ranges_lock);
+
+	hmm->notifiers--;
+	if (!hmm->notifiers) {
+		struct hmm_range *range;
+
+		list_for_each_entry(range, &hmm->ranges, list) {
+			if (range->valid)
+				continue;
+			range->valid = true;
+		}
+		wake_up_all(&hmm->wq);
+	}
+}
+
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
@@ -148,6 +166,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	struct hmm_mirror *mirror;
 	struct hmm_update update;
 	struct hmm_range *range;
+	unsigned long flags;
 	int ret = 0;
 
 	if (!kref_get_unless_zero(&hmm->kref))
@@ -158,12 +177,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = mmu_notifier_range_blockable(nrange);
 
-	if (mmu_notifier_range_blockable(nrange))
-		mutex_lock(&hmm->lock);
-	else if (!mutex_trylock(&hmm->lock)) {
-		ret = -EAGAIN;
-		goto out;
-	}
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	hmm->notifiers++;
 	list_for_each_entry(range, &hmm->ranges, list) {
 		if (update.end < range->start || update.start >= range->end)
@@ -171,7 +185,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 
 		range->valid = false;
 	}
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	if (mmu_notifier_range_blockable(nrange))
 		down_read(&hmm->mirrors_sem);
@@ -179,16 +193,26 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 		ret = -EAGAIN;
 		goto out;
 	}
+
 	list_for_each_entry(mirror, &hmm->mirrors, list) {
-		int ret;
+		int rc;
 
-		ret = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
-		if (!update.blockable && ret == -EAGAIN)
+		rc = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
+		if (rc) {
+			if (WARN_ON(update.blockable || rc != -EAGAIN))
+				continue;
+			ret = -EAGAIN;
 			break;
+		}
 	}
 	up_read(&hmm->mirrors_sem);
 
 out:
+	if (ret) {
+		spin_lock_irqsave(&hmm->ranges_lock, flags);
+		notifiers_decrement(hmm);
+		spin_unlock_irqrestore(&hmm->ranges_lock, flags);
+	}
 	hmm_put(hmm);
 	return ret;
 }
@@ -197,23 +221,14 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
 	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
+	unsigned long flags;
 
 	if (!kref_get_unless_zero(&hmm->kref))
 		return;
 
-	mutex_lock(&hmm->lock);
-	hmm->notifiers--;
-	if (!hmm->notifiers) {
-		struct hmm_range *range;
-
-		list_for_each_entry(range, &hmm->ranges, list) {
-			if (range->valid)
-				continue;
-			range->valid = true;
-		}
-		wake_up_all(&hmm->wq);
-	}
-	mutex_unlock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
+	notifiers_decrement(hmm);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	hmm_put(hmm);
 }
@@ -866,6 +881,7 @@ int hmm_range_register(struct hmm_range *range,
 {
 	unsigned long mask = ((1UL << page_shift) - 1UL);
 	struct hmm *hmm = mirror->hmm;
+	unsigned long flags;
 
 	range->valid = false;
 	range->hmm = NULL;
@@ -887,7 +903,7 @@ int hmm_range_register(struct hmm_range *range,
 	kref_get(&hmm->kref);
 
 	/* Initialize range to track CPU page table updates. */
-	mutex_lock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 
 	range->hmm = hmm;
 	list_add(&range->list, &hmm->ranges);
@@ -898,7 +914,7 @@ int hmm_range_register(struct hmm_range *range,
 	 */
 	if (!hmm->notifiers)
 		range->valid = true;
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	return 0;
 }
@@ -914,13 +930,14 @@ EXPORT_SYMBOL(hmm_range_register);
 void hmm_range_unregister(struct hmm_range *range)
 {
 	struct hmm *hmm = range->hmm;
+	unsigned long flags;
 
 	if (WARN_ON(range->end <= range->start))
 		return;
 
-	mutex_lock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	list_del(&range->list);
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	/* Drop reference taken by hmm_range_register() */
 	range->valid = false;
-- 
2.21.0

