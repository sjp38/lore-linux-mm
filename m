Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93AFEC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3416020850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="kJzXO444"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3416020850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32A756B0273; Thu, 13 Jun 2019 20:45:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F0BE6B0274; Thu, 13 Jun 2019 20:45:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 065FF6B0275; Thu, 13 Jun 2019 20:45:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE5DC6B0273
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:45:00 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c4so639207qkd.16
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:45:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=81jT1Hdc80WGYZ0NolRfY9wVErFdmf0CnSOj/bK3nzo=;
        b=UPq1okH3V47Sy+JwyRhmDq9Rouw1kTtrWII9HyXsN3jM/GL3v6R7TAXLz/9MDcJlUU
         mfScxiuuGMgsXS9QBTHTLzUUBP/we+wNnv7oMzEm3w0MOvgYTCx3SQMXLF7aeDWW6BXh
         Y5/0S79EAgn1bZPKExJDsP9bcZEH1n1nQuO5vWZu6e2egRsY0j+NARBebJ1EL7Nmol2R
         YagTVKxB3Trkjbf0fgd2st7g7AgzZ+hPx0/CK5viA/XHaIBwG4U8KFZ+4xZHEA6yDBO0
         MyQuZN+xFj+4WoVl/ZAbHomYJ4/XyyQsjR3lMfAp+I0vqMlS/N5GXGM+YN+ap7y/Yeo9
         VYcw==
X-Gm-Message-State: APjAAAXBSfLJf/UdkS/ly+n3Qk0+RYra99Sj1o1/anDWktRwa9zcX7T4
	i52KT9IOft/IothDWSEJjq8z4CZwbSgPKcPOAK63vCZUWqynJMDKUadZOt0t88Wc0n3jFeMoGRl
	ScpOYwnrlO/4O02AFQqiQECZgwYGsEL81Yk/pBmAVrO6+Rkyuix7dc9glV8inVpUr/A==
X-Received: by 2002:a37:7c05:: with SMTP id x5mr71159457qkc.313.1560473100604;
        Thu, 13 Jun 2019 17:45:00 -0700 (PDT)
X-Received: by 2002:a37:7c05:: with SMTP id x5mr71159424qkc.313.1560473099858;
        Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473099; cv=none;
        d=google.com; s=arc-20160816;
        b=UTJ5c66E2UndTql+guJQ/VtZ1H3vkhLfY2bOXusINFm6nck5gXFsj+i/+5i88NRHlJ
         CJBbo+gqNyrXpFhR4MsuvlqB52NZZ5zmgYBx5kov9V6jGMYyCMMMguu7fx1ZVHu8NJYc
         09hCZEdxjNpYFbrIX/l+2EN2ePuq3joAzbngMQEItNRKqENei6uJ/usqfo+0UU+IkbLr
         aHgsq87wqJnSrKEfBtM2G/NXH3FeNV4fKCYdBg9phGTHcwgtyw1Qk56/ZLO79/qMOPPx
         z4ViiF/ui4Vh8dCEbLpoRek9Jo2TwTlt7ApKji+wxnONGuqP/TNg5QlCkBNXHb0bMBxW
         HZkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=81jT1Hdc80WGYZ0NolRfY9wVErFdmf0CnSOj/bK3nzo=;
        b=Bty+75oPq22v+9gQASff8/fLwuTUz40eUmkZA8QEYC9OSIsLrsCIfBtXovhh6PNElf
         gxUEe0VLKhoiPz+0mSBWc9/7ngBpNE9DDmZAi3/7ipHgOWHGxY7qr6GW/j2Zh9C7eb3h
         QtpXQwyZE7oulf3KB2s5QdEbeSpbHaI2wRO3t0ARI6X2jMcSBmrk/ZfAoB2Wv/j9J9lu
         hMhhIetldcAur3YGBi5O3n3IXO51eub10QKAp6j+9o1FKm8AiM6my/1MttUCASNcALuQ
         0OoUYNjPg9L5f87meElyrwesPDlAHv22i24U5Pamy/QfSxPFo7/2HgJ+JtSiUU6sMgtL
         1eVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=kJzXO444;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w1sor1009267qvf.73.2019.06.13.17.44.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=kJzXO444;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=81jT1Hdc80WGYZ0NolRfY9wVErFdmf0CnSOj/bK3nzo=;
        b=kJzXO444RBh00bh7hl3AxI0tIXExReIacqR5hmZGVB/6O2TxYzqutiFQfsr4MDUAv8
         wCBoArV0Ho5b23f6oN/r3cbv5i9u9XYGWevXpsUuafVa4rMh8Li+8TSsMcLyTYxfzKNd
         iMm+0vRb+qSK6K4qKnf3QAfbRS8WkHLXwRL82O0/+MxT69BHfBer1KbhPSo7UAdtHxtl
         Quupwe3y5+dEUrrEHpCsVgVJCiyZ35e+8ARRZsziW+azHgQiqcHz2E/7IPNRpVG3unMJ
         cddZbQk+ZL6uk83JsBLSVP50bQsfaNZatZde6LJ9+w+IwAMgEIIss93Hv8qv8WHSIJoS
         AKGg==
X-Google-Smtp-Source: APXvYqzrXFiUSgzqu3ffxXhDqird+PVtZh0YXGYvXI5ZHYMZM5dV6GcQ4Vg9uZ1+KYqYHu1zRMYt4w==
X-Received: by 2002:a0c:bd9a:: with SMTP id n26mr5905854qvg.25.1560473099585;
        Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r5sm756136qkc.42.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKs-0005Kc-4A; Thu, 13 Jun 2019 21:44:54 -0300
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
Subject: [PATCH v3 hmm 12/12] mm/hmm: Fix error flows in hmm_invalidate_range_start
Date: Thu, 13 Jun 2019 21:44:50 -0300
Message-Id: <20190614004450.20252-13-jgg@ziepe.ca>
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
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 include/linux/hmm.h |  2 +-
 mm/hmm.c            | 77 +++++++++++++++++++++++++++------------------
 2 files changed, 48 insertions(+), 31 deletions(-)

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
index c0d43302fd6b2f..1172a4f0206963 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -67,7 +67,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	init_rwsem(&hmm->mirrors_sem);
 	hmm->mmu_notifier.ops = NULL;
 	INIT_LIST_HEAD(&hmm->ranges);
-	mutex_init(&hmm->lock);
+	spin_lock_init(&hmm->ranges_lock);
 	kref_init(&hmm->kref);
 	hmm->notifiers = 0;
 	hmm->mm = mm;
@@ -124,18 +124,19 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
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
@@ -151,6 +152,23 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
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
@@ -158,6 +176,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	struct hmm_mirror *mirror;
 	struct hmm_update update;
 	struct hmm_range *range;
+	unsigned long flags;
 	int ret = 0;
 
 	if (!kref_get_unless_zero(&hmm->kref))
@@ -168,12 +187,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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
@@ -181,7 +195,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 
 		range->valid = false;
 	}
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	if (mmu_notifier_range_blockable(nrange))
 		down_read(&hmm->mirrors_sem);
@@ -189,16 +203,26 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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
@@ -207,23 +231,14 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
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
@@ -876,6 +891,7 @@ int hmm_range_register(struct hmm_range *range,
 {
 	unsigned long mask = ((1UL << page_shift) - 1UL);
 	struct hmm *hmm = mirror->hmm;
+	unsigned long flags;
 
 	range->valid = false;
 	range->hmm = NULL;
@@ -894,7 +910,7 @@ int hmm_range_register(struct hmm_range *range,
 		return -EFAULT;
 
 	/* Initialize range to track CPU page table updates. */
-	mutex_lock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 
 	range->hmm = hmm;
 	kref_get(&hmm->kref);
@@ -906,7 +922,7 @@ int hmm_range_register(struct hmm_range *range,
 	 */
 	if (!hmm->notifiers)
 		range->valid = true;
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	return 0;
 }
@@ -922,10 +938,11 @@ EXPORT_SYMBOL(hmm_range_register);
 void hmm_range_unregister(struct hmm_range *range)
 {
 	struct hmm *hmm = range->hmm;
+	unsigned long flags;
 
-	mutex_lock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	list_del(&range->list);
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	/* Drop reference taken by hmm_range_register() */
 	mmput(hmm->mm);
-- 
2.21.0

