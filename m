Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 639F9C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FA91212F5
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Q0gERuJM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FA91212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F68C6B000D; Mon,  1 Jul 2019 02:21:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77F688E000E; Mon,  1 Jul 2019 02:21:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4868E000D; Mon,  1 Jul 2019 02:21:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3D36B000D
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:21:05 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id e7so6753954plt.13
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:21:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xUI/EXwYMJaY9l3WyYSFkVG5FXgw0dlvM8RM5YUiHCA=;
        b=ODrQV9HhWtfruVrz2HRZIgxZCuG8DXD++S6tLUdlRaeNk3c4MchpMa11qMFQFhAv2o
         sXqIn1EmgP+/ACrWbuaO/0j56pgI5WcLL+jy7mWgCv3+Loip4UQFChyF5/4vfmn7uc4O
         zyXEYtzT6OFbKAevIBUae8XQJJc5uBM76+vC7V39txETuG1tL/HnklQRyg33i9GARW1G
         zN149aqWr9snBQXGedc21enNX+m+Oi2TfS+gtlThJ+07cMDAiPqTgAyerOtb8YP4zlPE
         jbuUBSixiFvuAxq3yEgmpHyAWr2tUjZ4FP24d8eXW0gDRstnoT6bL9lLEGuwZI585ti8
         4R+w==
X-Gm-Message-State: APjAAAXyVx3BLGkNb14PQf1RkRgF0p0sOa5M3byHeJqRbmgvzzvVxmr4
	gcnDIl7XDmpcQyBNyqa8ZRPbiYoHaS8x7umY45pxipEFiQiEJbvCcS3rKLljwSYRjvO7BqV2ovI
	DXg1W4VwIzR52SZixqtNAq+TouMAYYL2HfadUSIeYCGT8pnXs4gYTa+MVCBpvvFc=
X-Received: by 2002:a17:90a:d595:: with SMTP id v21mr28649491pju.34.1561962064727;
        Sun, 30 Jun 2019 23:21:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8tawOdc2AxsBITk8zOeFS3ABYvDhJTv6Twy70gFVwOtM//fkrkpKxZ5r156JI9vYlb2/b
X-Received: by 2002:a17:90a:d595:: with SMTP id v21mr28649420pju.34.1561962063811;
        Sun, 30 Jun 2019 23:21:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962063; cv=none;
        d=google.com; s=arc-20160816;
        b=yQJ7/DvtjVf90t7vVA5PRXWlIYBkT1/yI2Ex7Kf+x9ZWXfshGir8XZuiM8LIBCBNJk
         u5brn0ux6VgOOZT2Nic76P9Ny8dt2sSo9sV1vqHBUly4BUvMRSbGKTSoCCGTzSqrTnTE
         8FygdAkvcIO696vYMWDIIRKVp6s0dsHsI3dQCF0VF8btM3sDANDaQPId0L5MGYe9NRp9
         PQVaTGjMBju4vmRqsXF2TQqKAwMYD0tBe70PENV7WV1igliUhQXfz6XbWSLoOev/EAQV
         zqrPycs9s9rra2E5tpUdDfJ2oq710tjjxme/pkcglAQ0U9NPUF0hzXY7bFagasKWAlip
         tCKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xUI/EXwYMJaY9l3WyYSFkVG5FXgw0dlvM8RM5YUiHCA=;
        b=Vf8TUA5CYPdz6c7Yc0uUeVc13GJBPtrY8c5YbJy+lSpTBf84ASRo0iC0nokmwlcLbc
         KLJGvhK9R+GkeA0tTD44qffOJrtltIkYfJ8VbewESHq0dhuPP3rmHGdweMtST4PTzYsv
         466TjL/CMYf6rhI6ZXJWfc/ThmiFEgozVgtb3a+ShTqyoHQTPj0vGVzKCV0j9t324+hB
         +RyWwAwxzBLBC3PbZBa8TKutTRISOTPIEyPNrSTQHB6xqX/Wo0QjIDRcKw58weycl9cT
         Lzg/Ez4PEO6EFpwQ3hUJYvETjGfAfRgRg/+zTwI+yi1fjVwnuazG2t1NrWT9/nNazQtq
         yUeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Q0gERuJM;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c36si9701601pgl.287.2019.06.30.23.21.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:21:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Q0gERuJM;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=xUI/EXwYMJaY9l3WyYSFkVG5FXgw0dlvM8RM5YUiHCA=; b=Q0gERuJMvNOrp605GuN4cJ1M8w
	FIWV4ebIUv6FBI3RY/e9YoYafpWH8qEf36FhZ1B+JT7Lzpe4jPJL0TyLoNYOIwAom5YkX90KIuBAs
	FCugeikJCBhSKewcpz4To0UewCYUuIlsx7xLlx9M/bCud13VHfjJdX3WnlwyfBQOQqv92W2L7jRK1
	OJYaYMw2MbFgd0Erln9j+jgBlpOSfBGM14S2KmssLIaGJ3lCUt9NFfFu1MSupYKHkAIis4WsOFQRQ
	IjT7S7CTC1KGyYOfrttiuICeDichO+8M5mqi65JiG5+plXAX58GbkAo6wlxHfeSulbPRc96eSgRfI
	Oxq3mJqQ==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgS-000378-TW; Mon, 01 Jul 2019 06:21:01 +0000
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
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 17/22] mm/hmm: Fix error flows in hmm_invalidate_range_start
Date: Mon,  1 Jul 2019 08:20:15 +0200
Message-Id: <20190701062020.19239-18-hch@lst.de>
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
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 include/linux/hmm.h |  2 +-
 mm/hmm.c            | 69 ++++++++++++++++++++++++++-------------------
 2 files changed, 41 insertions(+), 30 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index bf013e965257..0fa8ea34ccef 100644
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
index b224ea635a77..de35289df20d 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -64,7 +64,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	init_rwsem(&hmm->mirrors_sem);
 	hmm->mmu_notifier.ops = NULL;
 	INIT_LIST_HEAD(&hmm->ranges);
-	mutex_init(&hmm->lock);
+	spin_lock_init(&hmm->ranges_lock);
 	kref_init(&hmm->kref);
 	hmm->notifiers = 0;
 	hmm->mm = mm;
@@ -144,6 +144,25 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	hmm_put(hmm);
 }
 
+static void notifiers_decrement(struct hmm *hmm)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
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
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
+}
+
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *nrange)
 {
@@ -151,6 +170,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	struct hmm_mirror *mirror;
 	struct hmm_update update;
 	struct hmm_range *range;
+	unsigned long flags;
 	int ret = 0;
 
 	if (!kref_get_unless_zero(&hmm->kref))
@@ -161,12 +181,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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
@@ -174,7 +189,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 
 		range->valid = false;
 	}
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	if (mmu_notifier_range_blockable(nrange))
 		down_read(&hmm->mirrors_sem);
@@ -182,16 +197,23 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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
+	if (ret)
+		notifiers_decrement(hmm);
 	hmm_put(hmm);
 	return ret;
 }
@@ -204,20 +226,7 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
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
-
+	notifiers_decrement(hmm);
 	hmm_put(hmm);
 }
 
@@ -868,6 +877,7 @@ int hmm_range_register(struct hmm_range *range,
 {
 	unsigned long mask = ((1UL << page_shift) - 1UL);
 	struct hmm *hmm = mirror->hmm;
+	unsigned long flags;
 
 	range->valid = false;
 	range->hmm = NULL;
@@ -886,7 +896,7 @@ int hmm_range_register(struct hmm_range *range,
 		return -EFAULT;
 
 	/* Initialize range to track CPU page table updates. */
-	mutex_lock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 
 	range->hmm = hmm;
 	kref_get(&hmm->kref);
@@ -898,7 +908,7 @@ int hmm_range_register(struct hmm_range *range,
 	 */
 	if (!hmm->notifiers)
 		range->valid = true;
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	return 0;
 }
@@ -914,10 +924,11 @@ EXPORT_SYMBOL(hmm_range_register);
 void hmm_range_unregister(struct hmm_range *range)
 {
 	struct hmm *hmm = range->hmm;
+	unsigned long flags;
 
-	mutex_lock(&hmm->lock);
+	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	list_del_init(&range->list);
-	mutex_unlock(&hmm->lock);
+	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
 
 	/* Drop reference taken by hmm_range_register() */
 	mmput(hmm->mm);
-- 
2.20.1

