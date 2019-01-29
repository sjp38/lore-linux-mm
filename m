Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7B02C282D1
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 785E920989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 785E920989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3207F8E0007; Tue, 29 Jan 2019 11:54:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 254BF8E0001; Tue, 29 Jan 2019 11:54:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 035708E0007; Tue, 29 Jan 2019 11:54:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C776C8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:47 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id f22so22130645qkm.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qN02vtl3Eti1Qs0mRWCMA6xUmr1GQzcP08f9KOc7rhE=;
        b=biYmyh+NIB7oYfahDlpt1YAmT4kwybYWOdW1meKiL9imOAcqTxdsID92dZbTocue+U
         gN/GB9Q3PlgSlhX0SJcg6b3zdgFMER/pj9lu5tP+pt9TudI5wShEYKAVSJKU/Vc1gKJn
         QGuh9BW7rD36Zh06SYoGACTKygaQHXESz6nTDv5JvqctOsTJv9p0KNPjSLbXS67AddTI
         yelCmgOCA8fDM6bVYCUaHN9kNQCQcSy88F94fRIgwCWylzgco6F86ySiUeWuFEgsHYKP
         zVfj+E3DClOUFmgK4Xt6Ua4UxvEP/BwDcFKw+Vl6xI2CFxRT/JW4nxs8b0VnYEGFTRaD
         mItA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukd2Iin8OH4LoPbSzcMKW1Noq6N8Dd4n+5ohR32i7RGG3Y7z2his
	5ln6RY4rqFB0aXJcr/NwRq7IaqPtObNHdKrRswrouAMKe8vJeyipeyRx7w70TBqVgnovczNsTAZ
	JN55rFcyfjnlY4fJU4kfseTgCgN44d10x7aa1Wyonf8gfrJeNlEvxbWg7t1JuCi/ndQ==
X-Received: by 2002:a37:9543:: with SMTP id x64mr24437793qkd.158.1548780887504;
        Tue, 29 Jan 2019 08:54:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5jTf67NzBVoBtNUnwJn/zttQR7XYLELyttHO0Mff+BWKi4jfDFslOx/VcmZ12Bk8jz+tVz
X-Received: by 2002:a37:9543:: with SMTP id x64mr24437721qkd.158.1548780886432;
        Tue, 29 Jan 2019 08:54:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780886; cv=none;
        d=google.com; s=arc-20160816;
        b=IqGTKL3dOed/V34JqiCH1THg8gXralpYQ0hc/ulHwqHFYdUy/KfFDUO1Lscm6hyh0Y
         ztiYSNA9fVtSOze1vyu4goygFAMZHiFYvHlzZw2ObARv28NSZhHfPieIvz6Cz0Rxm/SN
         OZTWFeRI2pqgkp4PSdEAUZJfLNxKU+bVt6jtrajpjvbmWAYyIpxsnQ5wXUsYac0WT/WW
         T1HYoqyLi8R4AdHuEpUuug8o/T6ZY0QO9/0IQGwzdd4wnXrCIxFYLJLfpP9Ml+vsQ50a
         5yBRt7ZG/Sm7Q4k0dsMrUGJZJ/yXeHXGgTE10Yp5NoFmyIVGxUMqeGwV0riZ38pCxPcm
         B44w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qN02vtl3Eti1Qs0mRWCMA6xUmr1GQzcP08f9KOc7rhE=;
        b=H6/CVj+yFguIN6oXxuvF/us5sO8YyWjD2kdX9nYwYc8YQf7J59RXXqlwmSHUY0vdjv
         FWL6P4pQUERRuGcR00b73SAM/NILLtOiT010XbYVfa6edfqMCf7By5gma5d3aXiLA80O
         SrZpBidhgG89aG8rR4xTt88JbGIW0FGMHwsiuJxn/ArMRpRBmUdNdlnlltO6DZxMtyhl
         YyhIlzIBhDQgmzptRPAnN/aZMeeUH/fOAQ13bDmByo3+2bU3RS5yb8LTqNPl/79Zgwsw
         JpibgQKxuPSD2UEJppkGnyH0uL7Qq0l8pWTTzrXQSFTIr4SrycCzuH2/9gYFgMzHpDat
         BlsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f188si1478893qkb.226.2019.01.29.08.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:46 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 90637A37BA;
	Tue, 29 Jan 2019 16:54:45 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5EB63102BCEB;
	Tue, 29 Jan 2019 16:54:43 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 05/10] mm/hmm: improve driver API to work and wait over a range
Date: Tue, 29 Jan 2019 11:54:23 -0500
Message-Id: <20190129165428.3931-6-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 29 Jan 2019 16:54:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

A common use case for HMM mirror is user trying to mirror a range
and before they could program the hardware it get invalidated by
some core mm event. Instead of having user re-try right away to
mirror the range provide a completion mechanism for them to wait
for any active invalidation affecting the range.

This also changes how hmm_range_snapshot() and hmm_range_fault()
works by not relying on vma so that we can drop the mmap_sem
when waiting and lookup the vma again on retry.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 208 +++++++++++++++---
 mm/hmm.c            | 526 +++++++++++++++++++++-----------------------
 2 files changed, 430 insertions(+), 304 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index ccf2b630447e..93dc88edc293 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -77,8 +77,34 @@
 #include <linux/migrate.h>
 #include <linux/memremap.h>
 #include <linux/completion.h>
+#include <linux/mmu_notifier.h>
 
-struct hmm;
+
+/*
+ * struct hmm - HMM per mm struct
+ *
+ * @mm: mm struct this HMM struct is bound to
+ * @lock: lock protecting ranges list
+ * @ranges: list of range being snapshotted
+ * @mirrors: list of mirrors for this mm
+ * @mmu_notifier: mmu notifier to track updates to CPU page table
+ * @mirrors_sem: read/write semaphore protecting the mirrors list
+ * @wq: wait queue for user waiting on a range invalidation
+ * @notifiers: count of active mmu notifiers
+ * @dead: is the mm dead ?
+ */
+struct hmm {
+	struct mm_struct	*mm;
+	struct kref		kref;
+	struct mutex		lock;
+	struct list_head	ranges;
+	struct list_head	mirrors;
+	struct mmu_notifier	mmu_notifier;
+	struct rw_semaphore	mirrors_sem;
+	wait_queue_head_t	wq;
+	long			notifiers;
+	bool			dead;
+};
 
 /*
  * hmm_pfn_flag_e - HMM flag enums
@@ -155,6 +181,38 @@ struct hmm_range {
 	bool			valid;
 };
 
+/*
+ * hmm_range_wait_until_valid() - wait for range to be valid
+ * @range: range affected by invalidation to wait on
+ * @timeout: time out for wait in ms (ie abort wait after that period of time)
+ * Returns: true if the range is valid, false otherwise.
+ */
+static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
+					      unsigned long timeout)
+{
+	/* Check if mm is dead ? */
+	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
+		range->valid = false;
+		return false;
+	}
+	if (range->valid)
+		return true;
+	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
+			   msecs_to_jiffies(timeout));
+	/* Return current valid status just in case we get lucky */
+	return range->valid;
+}
+
+/*
+ * hmm_range_valid() - test if a range is valid or not
+ * @range: range
+ * Returns: true if the range is valid, false otherwise.
+ */
+static inline bool hmm_range_valid(struct hmm_range *range)
+{
+	return range->valid;
+}
+
 /*
  * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
  * @range: range use to decode HMM pfn value
@@ -357,51 +415,133 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
 
 /*
- * To snapshot the CPU page table, call hmm_vma_get_pfns(), then take a device
- * driver lock that serializes device page table updates, then call
- * hmm_vma_range_done(), to check if the snapshot is still valid. The same
- * device driver page table update lock must also be used in the
- * hmm_mirror_ops.sync_cpu_device_pagetables() callback, so that CPU page
- * table invalidation serializes on it.
+ * To snapshot the CPU page table you first have to call hmm_range_register()
+ * to register the range. If hmm_range_register() return an error then some-
+ * thing is horribly wrong and you should fail loudly. If it returned true then
+ * you can wait for the range to be stable with hmm_range_wait_until_valid()
+ * function, a range is valid when there are no concurrent changes to the CPU
+ * page table for the range.
+ *
+ * Once the range is valid you can call hmm_range_snapshot() if that returns
+ * without error then you can take your device page table lock (the same lock
+ * you use in the HMM mirror sync_cpu_device_pagetables() callback). After
+ * taking that lock you have to check the range validity, if it is still valid
+ * (ie hmm_range_valid() returns true) then you can program the device page
+ * table, otherwise you have to start again. Pseudo code:
+ *
+ *      mydevice_prefault(mydevice, mm, start, end)
+ *      {
+ *          struct hmm_range range;
+ *          ...
  *
- * YOU MUST CALL hmm_vma_range_done() ONCE AND ONLY ONCE EACH TIME YOU CALL
- * hmm_range_snapshot() WITHOUT ERROR !
+ *          ret = hmm_range_register(&range, mm, start, end);
+ *          if (ret)
+ *              return ret;
  *
- * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE INVALID !
- */
-long hmm_range_snapshot(struct hmm_range *range);
-bool hmm_vma_range_done(struct hmm_range *range);
-
-
-/*
- * Fault memory on behalf of device driver. Unlike handle_mm_fault(), this will
- * not migrate any device memory back to system memory. The HMM pfn array will
- * be updated with the fault result and current snapshot of the CPU page table
- * for the range.
+ *          down_read(mm->mmap_sem);
+ *      again:
+ *
+ *          if (!hmm_range_wait_until_valid(&range, TIMEOUT)) {
+ *              up_read(&mm->mmap_sem);
+ *              hmm_range_unregister(range);
+ *              // Handle time out, either sleep or retry or something else
+ *              ...
+ *              return -ESOMETHING; || goto again;
+ *          }
+ *
+ *          ret = hmm_range_snapshot(&range); or hmm_range_fault(&range);
+ *          if (ret == -EAGAIN) {
+ *              down_read(mm->mmap_sem);
+ *              goto again;
+ *          } else if (ret == -EBUSY) {
+ *              goto again;
+ *          }
+ *
+ *          up_read(&mm->mmap_sem);
+ *          if (ret) {
+ *              hmm_range_unregister(range);
+ *              return ret;
+ *          }
+ *
+ *          // It might not have snap-shoted the whole range but only the first
+ *          // npages, the return values is the number of valid pages from the
+ *          // start of the range.
+ *          npages = ret;
  *
- * The mmap_sem must be taken in read mode before entering and it might be
- * dropped by the function if the block argument is false. In that case, the
- * function returns -EAGAIN.
+ *          ...
  *
- * Return value does not reflect if the fault was successful for every single
- * address or not. Therefore, the caller must to inspect the HMM pfn array to
- * determine fault status for each address.
+ *          mydevice_page_table_lock(mydevice);
+ *          if (!hmm_range_valid(range)) {
+ *              mydevice_page_table_unlock(mydevice);
+ *              goto again;
+ *          }
  *
- * Trying to fault inside an invalid vma will result in -EINVAL.
+ *          mydevice_populate_page_table(mydevice, range, npages);
+ *          ...
+ *          mydevice_take_page_table_unlock(mydevice);
+ *          hmm_range_unregister(range);
  *
- * See the function description in mm/hmm.c for further documentation.
+ *          return 0;
+ *      }
+ *
+ * The same scheme apply to hmm_range_fault() (ie replace hmm_range_snapshot()
+ * with hmm_range_fault() in above pseudo code).
+ *
+ * YOU MUST CALL hmm_range_unregister() ONCE AND ONLY ONCE EACH TIME YOU CALL
+ * hmm_range_register() AND hmm_range_register() RETURNED TRUE ! IF YOU DO NOT
+ * FOLLOW THIS RULE MEMORY CORRUPTION WILL ENSUE !
  */
+int hmm_range_register(struct hmm_range *range,
+		       struct mm_struct *mm,
+		       unsigned long start,
+		       unsigned long end);
+void hmm_range_unregister(struct hmm_range *range);
+long hmm_range_snapshot(struct hmm_range *range);
 long hmm_range_fault(struct hmm_range *range, bool block);
 
+/*
+ * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
+ *
+ * When waiting for mmu notifiers we need some kind of time out otherwise we
+ * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
+ * wait already.
+ */
+#define HMM_RANGE_DEFAULT_TIMEOUT 1000
+
 /* This is a temporary helper to avoid merge conflict between trees. */
+static inline bool hmm_vma_range_done(struct hmm_range *range)
+{
+	bool ret = hmm_range_valid(range);
+
+	hmm_range_unregister(range);
+	return ret;
+}
+
 static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 {
-	long ret = hmm_range_fault(range, block);
-	if (ret == -EBUSY)
-		ret = -EAGAIN;
-	else if (ret == -EAGAIN)
-		ret = -EBUSY;
-	return ret < 0 ? ret : 0;
+	long ret;
+
+	ret = hmm_range_register(range, range->vma->vm_mm,
+				 range->start, range->end);
+	if (ret)
+		return (int)ret;
+
+	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
+		up_read(&range->vma->vm_mm->mmap_sem);
+		return -EAGAIN;
+	}
+
+	ret = hmm_range_fault(range, block);
+	if (ret <= 0) {
+		if (ret == -EBUSY || !ret) {
+			up_read(&range->vma->vm_mm->mmap_sem);
+			ret = -EBUSY;
+		} else if (ret == -EAGAIN)
+			ret = -EBUSY;
+		hmm_range_unregister(range);
+		return ret;
+	}
+	return 0;
 }
 
 /* Below are for HMM internal use only! Not to be used by device driver! */
diff --git a/mm/hmm.c b/mm/hmm.c
index 04235455b4d2..860ebe5d4b07 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -38,26 +38,6 @@
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
-/*
- * struct hmm - HMM per mm struct
- *
- * @mm: mm struct this HMM struct is bound to
- * @lock: lock protecting ranges list
- * @ranges: list of range being snapshotted
- * @mirrors: list of mirrors for this mm
- * @mmu_notifier: mmu notifier to track updates to CPU page table
- * @mirrors_sem: read/write semaphore protecting the mirrors list
- */
-struct hmm {
-	struct mm_struct	*mm;
-	struct kref		kref;
-	spinlock_t		lock;
-	struct list_head	ranges;
-	struct list_head	mirrors;
-	struct mmu_notifier	mmu_notifier;
-	struct rw_semaphore	mirrors_sem;
-};
-
 static inline struct hmm *hmm_get(struct mm_struct *mm)
 {
 	struct hmm *hmm = READ_ONCE(mm->hmm);
@@ -87,12 +67,15 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
 	if (!hmm)
 		return NULL;
+	init_waitqueue_head(&hmm->wq);
 	INIT_LIST_HEAD(&hmm->mirrors);
 	init_rwsem(&hmm->mirrors_sem);
 	hmm->mmu_notifier.ops = NULL;
 	INIT_LIST_HEAD(&hmm->ranges);
-	spin_lock_init(&hmm->lock);
+	mutex_init(&hmm->lock);
 	kref_init(&hmm->kref);
+	hmm->notifiers = 0;
+	hmm->dead = false;
 	hmm->mm = mm;
 
 	spin_lock(&mm->page_table_lock);
@@ -154,6 +137,7 @@ void hmm_mm_destroy(struct mm_struct *mm)
 	mm->hmm = NULL;
 	if (hmm) {
 		hmm->mm = NULL;
+		hmm->dead = true;
 		spin_unlock(&mm->page_table_lock);
 		hmm_put(hmm);
 		return;
@@ -162,43 +146,22 @@ void hmm_mm_destroy(struct mm_struct *mm)
 	spin_unlock(&mm->page_table_lock);
 }
 
-static int hmm_invalidate_range(struct hmm *hmm, bool device,
-				const struct hmm_update *update)
+static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
+	struct hmm *hmm = hmm_get(mm);
 	struct hmm_mirror *mirror;
 	struct hmm_range *range;
 
-	spin_lock(&hmm->lock);
-	list_for_each_entry(range, &hmm->ranges, list) {
-		if (update->end < range->start || update->start >= range->end)
-			continue;
+	/* Report this HMM as dying. */
+	hmm->dead = true;
 
+	/* Wake-up everyone waiting on any range. */
+	mutex_lock(&hmm->lock);
+	list_for_each_entry(range, &hmm->ranges, list) {
 		range->valid = false;
 	}
-	spin_unlock(&hmm->lock);
-
-	if (!device)
-		return 0;
-
-	down_read(&hmm->mirrors_sem);
-	list_for_each_entry(mirror, &hmm->mirrors, list) {
-		int ret;
-
-		ret = mirror->ops->sync_cpu_device_pagetables(mirror, update);
-		if (!update->blockable && ret == -EAGAIN) {
-			up_read(&hmm->mirrors_sem);
-			return -EAGAIN;
-		}
-	}
-	up_read(&hmm->mirrors_sem);
-
-	return 0;
-}
-
-static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
-{
-	struct hmm_mirror *mirror;
-	struct hmm *hmm = hmm_get(mm);
+	wake_up_all(&hmm->wq);
+	mutex_unlock(&hmm->lock);
 
 	down_write(&hmm->mirrors_sem);
 	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
@@ -224,44 +187,88 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 }
 
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
-			const struct mmu_notifier_range *range)
+			const struct mmu_notifier_range *nrange)
 {
+	struct hmm *hmm = hmm_get(nrange->mm);
+	struct hmm_mirror *mirror;
 	struct hmm_update update;
-	struct hmm *hmm = hmm_get(range->mm);
-	int ret;
+	struct hmm_range *range;
+	int ret = 0;
 
 	VM_BUG_ON(!hmm);
 
 	/* Check if hmm_mm_destroy() was call. */
 	if (hmm->mm == NULL)
-		return 0;
+		goto out;
 
-	update.start = range->start;
-	update.end = range->end;
+	update.start = nrange->start;
+	update.end = nrange->end;
 	update.event = HMM_UPDATE_INVALIDATE;
-	update.blockable = range->blockable;
-	ret = hmm_invalidate_range(hmm, true, &update);
+	update.blockable = nrange->blockable;
+
+	if (!nrange->blockable && !mutex_trylock(&hmm->lock)) {
+		ret = -EAGAIN;
+		goto out;
+	} else
+		mutex_lock(&hmm->lock);
+	hmm->notifiers++;
+	list_for_each_entry(range, &hmm->ranges, list) {
+		if (update.end < range->start || update.start >= range->end)
+			continue;
+
+		range->valid = false;
+	}
+	mutex_unlock(&hmm->lock);
+
+
+	if (!nrange->blockable && !down_read_trylock(&hmm->mirrors_sem)) {
+		ret = -EAGAIN;
+		goto out;
+	} else
+		down_read(&hmm->mirrors_sem);
+	list_for_each_entry(mirror, &hmm->mirrors, list) {
+		int ret;
+
+		ret = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
+		if (!update.blockable && ret == -EAGAIN) {
+			up_read(&hmm->mirrors_sem);
+			ret = -EAGAIN;
+			goto out;
+		}
+	}
+	up_read(&hmm->mirrors_sem);
+
+out:
 	hmm_put(hmm);
 	return ret;
 }
 
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
-			const struct mmu_notifier_range *range)
+			const struct mmu_notifier_range *nrange)
 {
-	struct hmm_update update;
-	struct hmm *hmm = hmm_get(range->mm);
+	struct hmm *hmm = hmm_get(nrange->mm);
 
 	VM_BUG_ON(!hmm);
 
 	/* Check if hmm_mm_destroy() was call. */
 	if (hmm->mm == NULL)
-		return;
+		goto out;
 
-	update.start = range->start;
-	update.end = range->end;
-	update.event = HMM_UPDATE_INVALIDATE;
-	update.blockable = true;
-	hmm_invalidate_range(hmm, false, &update);
+	mutex_lock(&hmm->lock);
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
+	mutex_unlock(&hmm->lock);
+
+out:
 	hmm_put(hmm);
 }
 
@@ -413,7 +420,6 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
 {
 	struct hmm_range *range = hmm_vma_walk->range;
 
-	*fault = *write_fault = false;
 	if (!hmm_vma_walk->fault)
 		return;
 
@@ -452,10 +458,11 @@ static void hmm_range_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
 		return;
 	}
 
+	*fault = *write_fault = false;
 	for (i = 0; i < npages; ++i) {
 		hmm_pte_need_fault(hmm_vma_walk, pfns[i], cpu_flags,
 				   fault, write_fault);
-		if ((*fault) || (*write_fault))
+		if ((*write_fault))
 			return;
 	}
 }
@@ -710,156 +717,152 @@ static void hmm_pfns_special(struct hmm_range *range)
 }
 
 /*
- * hmm_range_snapshot() - snapshot CPU page table for a range
+ * hmm_range_register() - start tracking change to CPU page table over a range
  * @range: range
- * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
- *          permission (for instance asking for write and range is read only),
- *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
- *          vma or it is illegal to access that range), number of valid pages
- *          in range->pfns[] (from range start address).
+ * @mm: the mm struct for the range of virtual address
+ * @start: start virtual address (inclusive)
+ * @end: end virtual address (exclusive)
+ * Returns 0 on success, -EFAULT if the address space is no longer valid
  *
- * This snapshots the CPU page table for a range of virtual addresses. Snapshot
- * validity is tracked by range struct. See hmm_vma_range_done() for further
- * information.
+ * Track updates to the CPU page table see include/linux/hmm.h
  */
-long hmm_range_snapshot(struct hmm_range *range)
+int hmm_range_register(struct hmm_range *range,
+		       struct mm_struct *mm,
+		       unsigned long start,
+		       unsigned long end)
 {
-	struct vm_area_struct *vma = range->vma;
-	struct hmm_vma_walk hmm_vma_walk;
-	struct mm_walk mm_walk;
-	struct hmm *hmm;
-
+	range->start = start & PAGE_MASK;
+	range->end = end & PAGE_MASK;
+	range->valid = false;
 	range->hmm = NULL;
 
-	/* Sanity check, this really should not happen ! */
-	if (range->start < vma->vm_start || range->start >= vma->vm_end)
-		return -EINVAL;
-	if (range->end < vma->vm_start || range->end > vma->vm_end)
+	if (range->start >= range->end)
 		return -EINVAL;
 
-	hmm = hmm_register(vma->vm_mm);
-	if (!hmm)
-		return -ENOMEM;
+	range->hmm = hmm_register(mm);
+	if (!range->hmm)
+		return -EFAULT;
 
 	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL) {
-		hmm_put(hmm);
-		return -EINVAL;
+	if (range->hmm->mm == NULL || range->hmm->dead) {
+		hmm_put(range->hmm);
+		return -EFAULT;
 	}
 
-	/* FIXME support hugetlb fs */
-	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
-			vma_is_dax(vma)) {
-		hmm_pfns_special(range);
-		hmm_put(hmm);
-		return -EINVAL;
-	}
+	/* Initialize range to track CPU page table update */
+	mutex_lock(&range->hmm->lock);
 
-	if (!(vma->vm_flags & VM_READ)) {
-		/*
-		 * If vma do not allow read access, then assume that it does
-		 * not allow write access, either. Architecture that allow
-		 * write without read access are not supported by HMM, because
-		 * operations such has atomic access would not work.
-		 */
-		hmm_pfns_clear(range, range->pfns, range->start, range->end);
-		hmm_put(hmm);
-		return -EPERM;
-	}
+	list_add_rcu(&range->list, &range->hmm->ranges);
 
-	/* Initialize range to track CPU page table update */
-	spin_lock(&hmm->lock);
-	range->valid = true;
-	list_add_rcu(&range->list, &hmm->ranges);
-	spin_unlock(&hmm->lock);
-
-	hmm_vma_walk.fault = false;
-	hmm_vma_walk.range = range;
-	mm_walk.private = &hmm_vma_walk;
-	hmm_vma_walk.last = range->start;
-
-	mm_walk.vma = vma;
-	mm_walk.mm = vma->vm_mm;
-	mm_walk.pte_entry = NULL;
-	mm_walk.test_walk = NULL;
-	mm_walk.hugetlb_entry = NULL;
-	mm_walk.pmd_entry = hmm_vma_walk_pmd;
-	mm_walk.pte_hole = hmm_vma_walk_hole;
-
-	walk_page_range(range->start, range->end, &mm_walk);
 	/*
-	 * Transfer hmm reference to the range struct it will be drop inside
-	 * the hmm_vma_range_done() function (which _must_ be call if this
-	 * function return 0).
+	 * If there are any concurrent notifiers we have to wait for them for
+	 * the range to be valid (see hmm_range_wait_until_valid()).
 	 */
-	range->hmm = hmm;
-	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
+	if (!range->hmm->notifiers)
+		range->valid = true;
+	mutex_unlock(&range->hmm->lock);
+
+	return 0;
 }
-EXPORT_SYMBOL(hmm_range_snapshot);
+EXPORT_SYMBOL(hmm_range_register);
 
 /*
- * hmm_vma_range_done() - stop tracking change to CPU page table over a range
- * @range: range being tracked
- * Returns: false if range data has been invalidated, true otherwise
+ * hmm_range_unregister() - stop tracking change to CPU page table over a range
+ * @range: range
  *
  * Range struct is used to track updates to the CPU page table after a call to
- * either hmm_vma_get_pfns() or hmm_vma_fault(). Once the device driver is done
- * using the data,  or wants to lock updates to the data it got from those
- * functions, it must call the hmm_vma_range_done() function, which will then
- * stop tracking CPU page table updates.
- *
- * Note that device driver must still implement general CPU page table update
- * tracking either by using hmm_mirror (see hmm_mirror_register()) or by using
- * the mmu_notifier API directly.
- *
- * CPU page table update tracking done through hmm_range is only temporary and
- * to be used while trying to duplicate CPU page table contents for a range of
- * virtual addresses.
- *
- * There are two ways to use this :
- * again:
- *   hmm_vma_get_pfns(range); or hmm_vma_fault(...);
- *   trans = device_build_page_table_update_transaction(pfns);
- *   device_page_table_lock();
- *   if (!hmm_vma_range_done(range)) {
- *     device_page_table_unlock();
- *     goto again;
- *   }
- *   device_commit_transaction(trans);
- *   device_page_table_unlock();
- *
- * Or:
- *   hmm_vma_get_pfns(range); or hmm_vma_fault(...);
- *   device_page_table_lock();
- *   hmm_vma_range_done(range);
- *   device_update_page_table(range->pfns);
- *   device_page_table_unlock();
+ * hmm_range_register(). See include/linux/hmm.h for how to use it.
  */
-bool hmm_vma_range_done(struct hmm_range *range)
+void hmm_range_unregister(struct hmm_range *range)
 {
-	bool ret = false;
-
 	/* Sanity check this really should not happen. */
-	if (range->hmm == NULL || range->end <= range->start) {
-		BUG();
-		return false;
-	}
+	if (range->hmm == NULL || range->end <= range->start)
+		return;
 
-	spin_lock(&range->hmm->lock);
+	mutex_lock(&range->hmm->lock);
 	list_del_rcu(&range->list);
-	ret = range->valid;
-	spin_unlock(&range->hmm->lock);
-
-	/* Is the mm still alive ? */
-	if (range->hmm->mm == NULL)
-		ret = false;
+	mutex_unlock(&range->hmm->lock);
 
-	/* Drop reference taken by hmm_vma_fault() or hmm_vma_get_pfns() */
+	/* Drop reference taken by hmm_range_register() */
+	range->valid = false;
 	hmm_put(range->hmm);
 	range->hmm = NULL;
-	return ret;
 }
-EXPORT_SYMBOL(hmm_vma_range_done);
+EXPORT_SYMBOL(hmm_range_unregister);
+
+/*
+ * hmm_range_snapshot() - snapshot CPU page table for a range
+ * @range: range
+ * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
+ *          permission (for instance asking for write and range is read only),
+ *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
+ *          vma or it is illegal to access that range), number of valid pages
+ *          in range->pfns[] (from range start address).
+ *
+ * This snapshots the CPU page table for a range of virtual addresses. Snapshot
+ * validity is tracked by range struct. See in include/linux/hmm.h for example
+ * on how to use.
+ */
+long hmm_range_snapshot(struct hmm_range *range)
+{
+	unsigned long start = range->start, end;
+	struct hmm_vma_walk hmm_vma_walk;
+	struct hmm *hmm = range->hmm;
+	struct vm_area_struct *vma;
+	struct mm_walk mm_walk;
+
+	/* Check if hmm_mm_destroy() was call. */
+	if (hmm->mm == NULL || hmm->dead)
+		return -EFAULT;
+
+	do {
+		/* If range is no longer valid force retry. */
+		if (!range->valid)
+			return -EAGAIN;
+
+		vma = find_vma(hmm->mm, start);
+		if (vma == NULL || (vma->vm_flags & VM_SPECIAL))
+			return -EFAULT;
+
+		/* FIXME support hugetlb fs/dax */
+		if (is_vm_hugetlb_page(vma) || vma_is_dax(vma)) {
+			hmm_pfns_special(range);
+			return -EINVAL;
+		}
+
+		if (!(vma->vm_flags & VM_READ)) {
+			/*
+			 * If vma do not allow read access, then assume that it
+			 * does not allow write access, either. HMM does not
+			 * support architecture that allow write without read.
+			 */
+			hmm_pfns_clear(range, range->pfns,
+				range->start, range->end);
+			return -EPERM;
+		}
+
+		range->vma = vma;
+		hmm_vma_walk.last = start;
+		hmm_vma_walk.fault = false;
+		hmm_vma_walk.range = range;
+		mm_walk.private = &hmm_vma_walk;
+		end = min(range->end, vma->vm_end);
+
+		mm_walk.vma = vma;
+		mm_walk.mm = vma->vm_mm;
+		mm_walk.pte_entry = NULL;
+		mm_walk.test_walk = NULL;
+		mm_walk.hugetlb_entry = NULL;
+		mm_walk.pmd_entry = hmm_vma_walk_pmd;
+		mm_walk.pte_hole = hmm_vma_walk_hole;
+
+		walk_page_range(start, end, &mm_walk);
+		start = end;
+	} while (start < range->end);
+
+	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
+}
+EXPORT_SYMBOL(hmm_range_snapshot);
 
 /*
  * hmm_range_fault() - try to fault some address in a virtual address range
@@ -893,96 +896,79 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  */
 long hmm_range_fault(struct hmm_range *range, bool block)
 {
-	struct vm_area_struct *vma = range->vma;
-	unsigned long start = range->start;
+	unsigned long start = range->start, end;
 	struct hmm_vma_walk hmm_vma_walk;
+	struct hmm *hmm = range->hmm;
+	struct vm_area_struct *vma;
 	struct mm_walk mm_walk;
-	struct hmm *hmm;
 	int ret;
 
-	range->hmm = NULL;
-
-	/* Sanity check, this really should not happen ! */
-	if (range->start < vma->vm_start || range->start >= vma->vm_end)
-		return -EINVAL;
-	if (range->end < vma->vm_start || range->end > vma->vm_end)
-		return -EINVAL;
+	/* Check if hmm_mm_destroy() was call. */
+	if (hmm->mm == NULL || hmm->dead)
+		return -EFAULT;
 
-	hmm = hmm_register(vma->vm_mm);
-	if (!hmm) {
-		hmm_pfns_clear(range, range->pfns, range->start, range->end);
-		return -ENOMEM;
-	}
+	do {
+		/* If range is no longer valid force retry. */
+		if (!range->valid) {
+			up_read(&hmm->mm->mmap_sem);
+			return -EAGAIN;
+		}
 
-	/* Check if hmm_mm_destroy() was call. */
-	if (hmm->mm == NULL) {
-		hmm_put(hmm);
-		return -EINVAL;
-	}
+		vma = find_vma(hmm->mm, start);
+		if (vma == NULL || (vma->vm_flags & VM_SPECIAL))
+			return -EFAULT;
 
-	/* FIXME support hugetlb fs */
-	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
-			vma_is_dax(vma)) {
-		hmm_pfns_special(range);
-		hmm_put(hmm);
-		return -EINVAL;
-	}
+		/* FIXME support hugetlb fs/dax */
+		if (is_vm_hugetlb_page(vma) || vma_is_dax(vma)) {
+			hmm_pfns_special(range);
+			return -EINVAL;
+		}
 
-	if (!(vma->vm_flags & VM_READ)) {
-		/*
-		 * If vma do not allow read access, then assume that it does
-		 * not allow write access, either. Architecture that allow
-		 * write without read access are not supported by HMM, because
-		 * operations such has atomic access would not work.
-		 */
-		hmm_pfns_clear(range, range->pfns, range->start, range->end);
-		hmm_put(hmm);
-		return -EPERM;
-	}
+		if (!(vma->vm_flags & VM_READ)) {
+			/*
+			 * If vma do not allow read access, then assume that it
+			 * does not allow write access, either. HMM does not
+			 * support architecture that allow write without read.
+			 */
+			hmm_pfns_clear(range, range->pfns,
+				range->start, range->end);
+			return -EPERM;
+		}
 
-	/* Initialize range to track CPU page table update */
-	spin_lock(&hmm->lock);
-	range->valid = true;
-	list_add_rcu(&range->list, &hmm->ranges);
-	spin_unlock(&hmm->lock);
-
-	hmm_vma_walk.fault = true;
-	hmm_vma_walk.block = block;
-	hmm_vma_walk.range = range;
-	mm_walk.private = &hmm_vma_walk;
-	hmm_vma_walk.last = range->start;
-
-	mm_walk.vma = vma;
-	mm_walk.mm = vma->vm_mm;
-	mm_walk.pte_entry = NULL;
-	mm_walk.test_walk = NULL;
-	mm_walk.hugetlb_entry = NULL;
-	mm_walk.pmd_entry = hmm_vma_walk_pmd;
-	mm_walk.pte_hole = hmm_vma_walk_hole;
+		range->vma = vma;
+		hmm_vma_walk.last = start;
+		hmm_vma_walk.fault = true;
+		hmm_vma_walk.block = block;
+		hmm_vma_walk.range = range;
+		mm_walk.private = &hmm_vma_walk;
+		end = min(range->end, vma->vm_end);
+
+		mm_walk.vma = vma;
+		mm_walk.mm = vma->vm_mm;
+		mm_walk.pte_entry = NULL;
+		mm_walk.test_walk = NULL;
+		mm_walk.hugetlb_entry = NULL;
+		mm_walk.pmd_entry = hmm_vma_walk_pmd;
+		mm_walk.pte_hole = hmm_vma_walk_hole;
+
+		do {
+			ret = walk_page_range(start, end, &mm_walk);
+			start = hmm_vma_walk.last;
+
+			/* Keep trying while the range is valid. */
+		} while (ret == -EBUSY && range->valid);
+
+		if (ret) {
+			unsigned long i;
+
+			i = (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
+			hmm_pfns_clear(range, &range->pfns[i],
+				hmm_vma_walk.last, range->end);
+			return ret;
+		}
+		start = end;
 
-	do {
-		ret = walk_page_range(start, range->end, &mm_walk);
-		start = hmm_vma_walk.last;
-		/* Keep trying while the range is valid. */
-	} while (ret == -EBUSY && range->valid);
-
-	if (ret) {
-		unsigned long i;
-
-		i = (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
-		hmm_pfns_clear(range, &range->pfns[i], hmm_vma_walk.last,
-			       range->end);
-		hmm_vma_range_done(range);
-		hmm_put(hmm);
-		return ret;
-	} else {
-		/*
-		 * Transfer hmm reference to the range struct it will be drop
-		 * inside the hmm_vma_range_done() function (which _must_ be
-		 * call if this function return 0).
-		 */
-		range->hmm = hmm;
-	}
+	} while (start < range->end);
 
 	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
 }
-- 
2.17.2

