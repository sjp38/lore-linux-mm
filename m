Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49B84C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAFC12133D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAFC12133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 885FD6B026F; Wed,  3 Apr 2019 15:33:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E23B6B026D; Wed,  3 Apr 2019 15:33:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5987C6B0272; Wed,  3 Apr 2019 15:33:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2656B026D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:39 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 54so114407qtn.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1slSSF5ggjKW1CRbI3lXLqNclzMYmdvCruVVukHeqUA=;
        b=ZLm9KQGZGVQW88Hu3Pu7Mi2X4XYE8JumgPGzIjjTUDafsLMLXq9EGKbccpv0TkfUWq
         3xDh9pS2bI2/JkqN/eDmtVDHJO7bkvjwN0D07Hb0SYdBh+wyNsNh39cC8ap3JKw4l9SH
         /OgJa508RT6Pdt+6aVmcBUoFV7JS79RNjyav9qYVZ+w12zs2Ms1i1APJfUjtFL3hlA7m
         D4N+Ixbp87VAMUUCmcNCPG1FlAJH138bbRMTvWwBe7Nc9qkO/IAUxbNNbHoU08AZosJC
         rQFhtfxax7BA6fl89efAfwJiKoVluOztcpTY9YXgj9Ni8AmMSfIWOT/2xRNFrk68B14I
         3vYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXLcUGQ0wKJYfu67Moq+zxOo5H+OkGDrAEIQC1ejptkplO6BP7Y
	yZQcBUhzlde09CwPj+dq6txRTEre1yluXutb8IpuuE/mxFe1Cs0AKMQUETi+bi06Aqzu6vTgAPb
	QcNSl3sz9QKWhMzgjv38Vjn8TJ1yCtW33nrj9d2RQDmJCNc5iA0DDoFM7FwVwdlSJ1Q==
X-Received: by 2002:a05:620a:103c:: with SMTP id a28mr1590908qkk.284.1554320018786;
        Wed, 03 Apr 2019 12:33:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhVs8diP3T5PskkhDHkjla5PaAs9ObBc3TZr9xIZxMBxRY48xOW55bbstwS7BvtcoIflAO
X-Received: by 2002:a05:620a:103c:: with SMTP id a28mr1590815qkk.284.1554320017142;
        Wed, 03 Apr 2019 12:33:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320017; cv=none;
        d=google.com; s=arc-20160816;
        b=torzxmhrxpHEGYqZUz47dUAvH6A/1dIULOkOww3bvqqV6kuyKUF+TlaJVCuj6b5NU6
         jFO0uufwK4vYlKJJB+3vSs1OeRVYer3Qm1Lt626JP0pqyU93VEKg6+/w6JBgdvSMvLkh
         +W4LANnx90VRYje5xc5hr54Gj5m9b8s/TsCdxpbu8t9nXT074a8cpsDJru2WjVF7fl9v
         Hzs/1TLsHG06KosSvQAVKvOdNlC+MKdKZs8c9UAzBN9uDMdax//bUAOStdz8BPi3ksCE
         a6sUfK7G/Kw7DBRb+EzNgHPB/lUcn3Nbr76mPnD39lehQnfqW4V5n1iZ4GZ/JO1dWG+r
         9rLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1slSSF5ggjKW1CRbI3lXLqNclzMYmdvCruVVukHeqUA=;
        b=j3ZQ28mTn4UpdBTwVTZbNTzNCnN5OzSqXbr3+1YvJaA1htDlCmmqWVfTy+n1stsMhK
         j3u8jnPd/UhXjvVth8ZmZcxIHM7tzGH0vxvbBu95wUkIdZCkm+ZMx9mRGP4NBPwHkWLO
         0MANtC7w0aUWPbreiWvs9uNnwV5+SnKG5/Jcu4gUFDMg4kizddWcnjFaqpOcEGFlIOvR
         BA2aBAO+BtjEajV9vRrrtw+rGqkDJ8YgBRlz3A+nOFfATF17c4MOnX/IUdtNmR58KrBI
         AXz1qGAnRpNyjM+7qH5X76GnYncJsICQHkGg0Ic30VrFlNGYkv8NKvkSXUlYNWUOPK8P
         sNbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 28si1639505qvl.218.2019.04.03.12.33.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 540D9308FF17;
	Wed,  3 Apr 2019 19:33:36 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 915516012C;
	Wed,  3 Apr 2019 19:33:34 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 06/12] mm/hmm: improve driver API to work and wait over a range v3
Date: Wed,  3 Apr 2019 15:33:12 -0400
Message-Id: <20190403193318.16478-7-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 03 Apr 2019 19:33:36 +0000 (UTC)
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

Changes since v2:
    - Updated documentation to match new API.
    - Added more comments in old API temporary wrapper.
    - Consolidated documentation in hmm.rst to avoid out of sync.
Changes since v1:
    - squashed: Dan Carpenter: potential deadlock in nonblocking code

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>
---
 Documentation/vm/hmm.rst |  25 +-
 include/linux/hmm.h      | 145 ++++++++---
 mm/hmm.c                 | 531 +++++++++++++++++++--------------------
 3 files changed, 387 insertions(+), 314 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 61f073215a8d..945d5fb6d14a 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -217,17 +217,33 @@ Locking with the update() callback is the most important aspect the driver must
       range.flags = ...;
       range.values = ...;
       range.pfn_shift = ...;
+      hmm_range_register(&range);
+
+      /*
+       * Just wait for range to be valid, safe to ignore return value as we
+       * will use the return value of hmm_range_snapshot() below under the
+       * mmap_sem to ascertain the validity of the range.
+       */
+      hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
 
  again:
       down_read(&mm->mmap_sem);
-      range.vma = ...;
       ret = hmm_range_snapshot(&range);
       if (ret) {
           up_read(&mm->mmap_sem);
+          if (ret == -EAGAIN) {
+            /*
+             * No need to check hmm_range_wait_until_valid() return value
+             * on retry we will get proper error with hmm_range_snapshot()
+             */
+            hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
+            goto again;
+          }
+          hmm_mirror_unregister(&range);
           return ret;
       }
       take_lock(driver->update);
-      if (!hmm_vma_range_done(vma, &range)) {
+      if (!range.valid) {
           release_lock(driver->update);
           up_read(&mm->mmap_sem);
           goto again;
@@ -235,14 +251,15 @@ Locking with the update() callback is the most important aspect the driver must
 
       // Use pfns array content to update device page table
 
+      hmm_mirror_unregister(&range);
       release_lock(driver->update);
       up_read(&mm->mmap_sem);
       return 0;
  }
 
 The driver->update lock is the same lock that the driver takes inside its
-update() callback. That lock must be held before hmm_vma_range_done() to avoid
-any race with a concurrent CPU page table update.
+update() callback. That lock must be held before checking the range.valid
+field to avoid any race with a concurrent CPU page table update.
 
 HMM implements all this on top of the mmu_notifier API because we wanted a
 simpler API and also to be able to perform optimizations latter on like doing
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index e9afd23c2eac..ec4bfa91648f 100644
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
@@ -357,51 +415,66 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
 
 /*
- * To snapshot the CPU page table, call hmm_vma_get_pfns(), then take a device
- * driver lock that serializes device page table updates, then call
- * hmm_vma_range_done(), to check if the snapshot is still valid. The same
- * device driver page table update lock must also be used in the
- * hmm_mirror_ops.sync_cpu_device_pagetables() callback, so that CPU page
- * table invalidation serializes on it.
- *
- * YOU MUST CALL hmm_vma_range_done() ONCE AND ONLY ONCE EACH TIME YOU CALL
- * hmm_range_snapshot() WITHOUT ERROR !
- *
- * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE INVALID !
+ * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
+int hmm_range_register(struct hmm_range *range,
+		       struct mm_struct *mm,
+		       unsigned long start,
+		       unsigned long end);
+void hmm_range_unregister(struct hmm_range *range);
 long hmm_range_snapshot(struct hmm_range *range);
-bool hmm_vma_range_done(struct hmm_range *range);
-
+long hmm_range_fault(struct hmm_range *range, bool block);
 
 /*
- * Fault memory on behalf of device driver. Unlike handle_mm_fault(), this will
- * not migrate any device memory back to system memory. The HMM pfn array will
- * be updated with the fault result and current snapshot of the CPU page table
- * for the range.
- *
- * The mmap_sem must be taken in read mode before entering and it might be
- * dropped by the function if the block argument is false. In that case, the
- * function returns -EAGAIN.
- *
- * Return value does not reflect if the fault was successful for every single
- * address or not. Therefore, the caller must to inspect the HMM pfn array to
- * determine fault status for each address.
- *
- * Trying to fault inside an invalid vma will result in -EINVAL.
+ * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
  *
- * See the function description in mm/hmm.c for further documentation.
+ * When waiting for mmu notifiers we need some kind of time out otherwise we
+ * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
+ * wait already.
  */
-long hmm_range_fault(struct hmm_range *range, bool block);
+#define HMM_RANGE_DEFAULT_TIMEOUT 1000
+
+/* This is a temporary helper to avoid merge conflict between trees. */
+static inline bool hmm_vma_range_done(struct hmm_range *range)
+{
+	bool ret = hmm_range_valid(range);
+
+	hmm_range_unregister(range);
+	return ret;
+}
 
 /* This is a temporary helper to avoid merge conflict between trees. */
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
+		/*
+		 * The mmap_sem was taken by driver we release it here and
+		 * returns -EAGAIN which correspond to mmap_sem have been
+		 * drop in the old API.
+		 */
+		up_read(&range->vma->vm_mm->mmap_sem);
+		return -EAGAIN;
+	}
+
+	ret = hmm_range_fault(range, block);
+	if (ret <= 0) {
+		if (ret == -EBUSY || !ret) {
+			/* Same as above  drop mmap_sem to match old API. */
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
index b7e4034d96e1..3e07f32b94f8 100644
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
 static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
 {
 	struct hmm *hmm = READ_ONCE(mm->hmm);
@@ -91,12 +71,15 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
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
@@ -158,6 +141,7 @@ void hmm_mm_destroy(struct mm_struct *mm)
 	mm->hmm = NULL;
 	if (hmm) {
 		hmm->mm = NULL;
+		hmm->dead = true;
 		spin_unlock(&mm->page_table_lock);
 		hmm_put(hmm);
 		return;
@@ -166,43 +150,22 @@ void hmm_mm_destroy(struct mm_struct *mm)
 	spin_unlock(&mm->page_table_lock);
 }
 
-static int hmm_invalidate_range(struct hmm *hmm, bool device,
-				const struct hmm_update *update)
+static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
+	struct hmm *hmm = mm_get_hmm(mm);
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
-	struct hmm *hmm = mm_get_hmm(mm);
+	wake_up_all(&hmm->wq);
+	mutex_unlock(&hmm->lock);
 
 	down_write(&hmm->mirrors_sem);
 	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
@@ -228,36 +191,80 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 }
 
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
-			const struct mmu_notifier_range *range)
+			const struct mmu_notifier_range *nrange)
 {
-	struct hmm *hmm = mm_get_hmm(range->mm);
+	struct hmm *hmm = mm_get_hmm(nrange->mm);
+	struct hmm_mirror *mirror;
 	struct hmm_update update;
-	int ret;
+	struct hmm_range *range;
+	int ret = 0;
 
 	VM_BUG_ON(!hmm);
 
-	update.start = range->start;
-	update.end = range->end;
+	update.start = nrange->start;
+	update.end = nrange->end;
 	update.event = HMM_UPDATE_INVALIDATE;
-	update.blockable = range->blockable;
-	ret = hmm_invalidate_range(hmm, true, &update);
+	update.blockable = nrange->blockable;
+
+	if (nrange->blockable)
+		mutex_lock(&hmm->lock);
+	else if (!mutex_trylock(&hmm->lock)) {
+		ret = -EAGAIN;
+		goto out;
+	}
+	hmm->notifiers++;
+	list_for_each_entry(range, &hmm->ranges, list) {
+		if (update.end < range->start || update.start >= range->end)
+			continue;
+
+		range->valid = false;
+	}
+	mutex_unlock(&hmm->lock);
+
+	if (nrange->blockable)
+		down_read(&hmm->mirrors_sem);
+	else if (!down_read_trylock(&hmm->mirrors_sem)) {
+		ret = -EAGAIN;
+		goto out;
+	}
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
-	struct hmm *hmm = mm_get_hmm(range->mm);
-	struct hmm_update update;
+	struct hmm *hmm = mm_get_hmm(nrange->mm);
 
 	VM_BUG_ON(!hmm);
 
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
 	hmm_put(hmm);
 }
 
@@ -409,7 +416,6 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
 {
 	struct hmm_range *range = hmm_vma_walk->range;
 
-	*fault = *write_fault = false;
 	if (!hmm_vma_walk->fault)
 		return;
 
@@ -448,10 +454,11 @@ static void hmm_range_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
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
@@ -706,162 +713,155 @@ static void hmm_pfns_special(struct hmm_range *range)
 }
 
 /*
- * hmm_range_snapshot() - snapshot CPU page table for a range
+ * hmm_range_register() - start tracking change to CPU page table over a range
  * @range: range
- * Returns: number of valid pages in range->pfns[] (from range start
- *          address). This may be zero. If the return value is negative,
- *          then one of the following values may be returned:
+ * @mm: the mm struct for the range of virtual address
+ * @start: start virtual address (inclusive)
+ * @end: end virtual address (exclusive)
+ * Returns 0 on success, -EFAULT if the address space is no longer valid
  *
- *           -EINVAL  invalid arguments or mm or virtual address are in an
- *                    invalid vma (ie either hugetlbfs or device file vma).
- *           -EPERM   For example, asking for write, when the range is
- *                    read-only
- *           -EAGAIN  Caller needs to retry
- *           -EFAULT  Either no valid vma exists for this range, or it is
- *                    illegal to access the range
- *
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
 
-	hmm = hmm_get_or_create(vma->vm_mm);
-	if (!hmm)
-		return -ENOMEM;
+	range->start = start;
+	range->end = end;
+
+	range->hmm = hmm_get_or_create(mm);
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
+	mutex_unlock(&range->hmm->lock);
 
-	/* Is the mm still alive ? */
-	if (range->hmm->mm == NULL)
-		ret = false;
-
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
@@ -893,96 +893,79 @@ EXPORT_SYMBOL(hmm_vma_range_done);
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
 
-	hmm = hmm_get_or_create(vma->vm_mm);
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

