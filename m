Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CEE8C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 297CA2084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 297CA2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A09B36B0010; Wed,  3 Apr 2019 15:33:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9685B6B0269; Wed,  3 Apr 2019 15:33:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 792396B026A; Wed,  3 Apr 2019 15:33:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 517586B0010
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:33 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c67so173443qkg.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=D34hwzoykzfsqSBqKRSRJ/FelzSzzzD2ynA/IC+Vq1g=;
        b=crrxhaqwZSIGmXhGrszfi/jVQYsMbypovD9HgxoeRjFp9Aa0I7NYE4uYk4qjOm77uX
         Hfrjjslb55ICTm+BJQCcF6VhmyCnUpoBFVI/c3hNtHNvd5BFwMUkUzAVCpGoZgROrk10
         5hI6HPIRY5JsKBGZNWA1fvXTCJBsvYHgMVBiZdntEen+gc4LwZ4V9Ud7luNU0+VWXyGc
         3B1vDt2STkP++qcSfUhrCj3XPttmhkb0DSBSjjrdmQaNeAG7UpboeiS/yVgMuK8GIOzi
         lfTWQiEbkNAtinhEnORxHWFPihTGMLMt0+hC2zQrpnZOeCfM/byz93z+UWsHDArsYonN
         lKxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVSvCcoQrubBHD410fbDO+8HwQuRMCPoFu17ZtwDBY2a6QefQlK
	F2WZxuHqnlHVsdmg8HSI5LbxAk25/hcIXKFIqlxpp6UCFNOGeBK0384UZcC3XR4vXb6Wfj42l4S
	LSS6tsX79N0m1GMEAYbnDsqpr25vmDkWAatwJWqRtsmXIU9zEwENrKF2jDBXEyWO3OA==
X-Received: by 2002:a0c:b3c4:: with SMTP id b4mr1287240qvf.176.1554320013066;
        Wed, 03 Apr 2019 12:33:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfLkD32XWClxVdKNRBTd0ye6Wc5qMuLuz6CuxrDApCcqdhB3opNFmwxXEWLH6yhmLUbC58
X-Received: by 2002:a0c:b3c4:: with SMTP id b4mr1287190qvf.176.1554320012228;
        Wed, 03 Apr 2019 12:33:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320012; cv=none;
        d=google.com; s=arc-20160816;
        b=BEuhHXHbwEQYraT4rixcJBYS32FnBhP3uRhGvscyheO/AdxHdeXtTLNRcSJmw1KMQE
         lgCAoIJ9qnVnnbWSTy+6qOF+n4gDTsV8X5W7hiXtnHwvd1M/Ny2Gze4R3hRLuqNQyMh3
         hScN5vnRO01bGBtlm0tbMAXA0XrMhEQ92U9DlLCnMysAZWR3OayErgM7sRbdMR896Wz6
         WsXgigxPsu/ESUVHJ9PBWqmHnbS7FpFtRADu0PhrANk7E4v016qQES4vey8rqOLQZww9
         ebD+7YkYlcwlQTZcyQSCefG7uPP1ZG6aGRgn9B1eiOxzFkhsK33/ZnM3nBQeC5nhJhe5
         OfEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=D34hwzoykzfsqSBqKRSRJ/FelzSzzzD2ynA/IC+Vq1g=;
        b=0FCLHbW2qyEvJRS4CeUW6vL3D97xGvCvm+xuJQ1RZcN9BI7zSmL5dunVkiAgrBJ7sn
         POv+R2YAg2miu0ocEn+8hnEZbiuSJ+bEqcy5GR2JuJ6UFRkKzR/MWMLhFFNkJvZghfBb
         NOtjSqKD8VqPGjTmjUfWtsYlhomHPa3ah1hA2OjtteIARSOnabY+iJaZXS7uIn3X4G/f
         UqYeTILJALPrlTfzPh/vqcnz5QUO2jyE1pvXhY4hOeuT1mtTtx9VTPa3enO7BYUCT51o
         +xEhWIwmxRjK5xbTiS+pSHH9XGDALUmlKyBmjFMb5ewoqOZx731CY9UupsVcsPYvMnVo
         Ebjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 9si503129qvu.126.2019.04.03.12.33.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6882A3003B36;
	Wed,  3 Apr 2019 19:33:31 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6A8266012C;
	Wed,  3 Apr 2019 19:33:30 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v3 02/12] mm/hmm: use reference counting for HMM struct v3
Date: Wed,  3 Apr 2019 15:33:08 -0400
Message-Id: <20190403193318.16478-3-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 03 Apr 2019 19:33:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Every time i read the code to check that the HMM structure does not
vanish before it should thanks to the many lock protecting its removal
i get a headache. Switch to reference counting instead it is much
easier to follow and harder to break. This also remove some code that
is no longer needed with refcounting.

Changes since v2:
    - Renamed hmm_register() to hmm_get_or_create() updated comments
      accordingly
Changes since v1:
    - removed bunch of useless check (if API is use with bogus argument
      better to fail loudly so user fix their code)
    - s/hmm_get/mm_get_hmm/

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/hmm.h |   2 +
 mm/hmm.c            | 190 ++++++++++++++++++++++++++++----------------
 2 files changed, 124 insertions(+), 68 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index ad50b7b4f141..716fc61fa6d4 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -131,6 +131,7 @@ enum hmm_pfn_value_e {
 /*
  * struct hmm_range - track invalidation lock on virtual address range
  *
+ * @hmm: the core HMM structure this range is active against
  * @vma: the vm area struct for the range
  * @list: all range lock are on a list
  * @start: range virtual start address (inclusive)
@@ -142,6 +143,7 @@ enum hmm_pfn_value_e {
  * @valid: pfns array did not change since it has been fill by an HMM function
  */
 struct hmm_range {
+	struct hmm		*hmm;
 	struct vm_area_struct	*vma;
 	struct list_head	list;
 	unsigned long		start;
diff --git a/mm/hmm.c b/mm/hmm.c
index fe1cd87e49ac..919d78fd21c5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -50,6 +50,7 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
  */
 struct hmm {
 	struct mm_struct	*mm;
+	struct kref		kref;
 	spinlock_t		lock;
 	struct list_head	ranges;
 	struct list_head	mirrors;
@@ -57,24 +58,33 @@ struct hmm {
 	struct rw_semaphore	mirrors_sem;
 };
 
-/*
- * hmm_register - register HMM against an mm (HMM internal)
+static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
+{
+	struct hmm *hmm = READ_ONCE(mm->hmm);
+
+	if (hmm && kref_get_unless_zero(&hmm->kref))
+		return hmm;
+
+	return NULL;
+}
+
+/**
+ * hmm_get_or_create - register HMM against an mm (HMM internal)
  *
  * @mm: mm struct to attach to
+ * Returns: returns an HMM object, either by referencing the existing
+ *          (per-process) object, or by creating a new one.
  *
- * This is not intended to be used directly by device drivers. It allocates an
- * HMM struct if mm does not have one, and initializes it.
+ * This is not intended to be used directly by device drivers. If mm already
+ * has an HMM struct then it get a reference on it and returns it. Otherwise
+ * it allocates an HMM struct, initializes it, associate it with the mm and
+ * returns it.
  */
-static struct hmm *hmm_register(struct mm_struct *mm)
+static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 {
-	struct hmm *hmm = READ_ONCE(mm->hmm);
+	struct hmm *hmm = mm_get_hmm(mm);
 	bool cleanup = false;
 
-	/*
-	 * The hmm struct can only be freed once the mm_struct goes away,
-	 * hence we should always have pre-allocated an new hmm struct
-	 * above.
-	 */
 	if (hmm)
 		return hmm;
 
@@ -86,6 +96,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	hmm->mmu_notifier.ops = NULL;
 	INIT_LIST_HEAD(&hmm->ranges);
 	spin_lock_init(&hmm->lock);
+	kref_init(&hmm->kref);
 	hmm->mm = mm;
 
 	spin_lock(&mm->page_table_lock);
@@ -106,7 +117,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
 		goto error_mm;
 
-	return mm->hmm;
+	return hmm;
 
 error_mm:
 	spin_lock(&mm->page_table_lock);
@@ -118,9 +129,41 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	return NULL;
 }
 
+static void hmm_free(struct kref *kref)
+{
+	struct hmm *hmm = container_of(kref, struct hmm, kref);
+	struct mm_struct *mm = hmm->mm;
+
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
+
+	spin_lock(&mm->page_table_lock);
+	if (mm->hmm == hmm)
+		mm->hmm = NULL;
+	spin_unlock(&mm->page_table_lock);
+
+	kfree(hmm);
+}
+
+static inline void hmm_put(struct hmm *hmm)
+{
+	kref_put(&hmm->kref, hmm_free);
+}
+
 void hmm_mm_destroy(struct mm_struct *mm)
 {
-	kfree(mm->hmm);
+	struct hmm *hmm;
+
+	spin_lock(&mm->page_table_lock);
+	hmm = mm_get_hmm(mm);
+	mm->hmm = NULL;
+	if (hmm) {
+		hmm->mm = NULL;
+		spin_unlock(&mm->page_table_lock);
+		hmm_put(hmm);
+		return;
+	}
+
+	spin_unlock(&mm->page_table_lock);
 }
 
 static int hmm_invalidate_range(struct hmm *hmm, bool device,
@@ -165,7 +208,7 @@ static int hmm_invalidate_range(struct hmm *hmm, bool device,
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm_mirror *mirror;
-	struct hmm *hmm = mm->hmm;
+	struct hmm *hmm = mm_get_hmm(mm);
 
 	down_write(&hmm->mirrors_sem);
 	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
@@ -186,13 +229,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 						  struct hmm_mirror, list);
 	}
 	up_write(&hmm->mirrors_sem);
+
+	hmm_put(hmm);
 }
 
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *range)
 {
+	struct hmm *hmm = mm_get_hmm(range->mm);
 	struct hmm_update update;
-	struct hmm *hmm = range->mm->hmm;
+	int ret;
 
 	VM_BUG_ON(!hmm);
 
@@ -200,14 +246,16 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	update.end = range->end;
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = range->blockable;
-	return hmm_invalidate_range(hmm, true, &update);
+	ret = hmm_invalidate_range(hmm, true, &update);
+	hmm_put(hmm);
+	return ret;
 }
 
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *range)
 {
+	struct hmm *hmm = mm_get_hmm(range->mm);
 	struct hmm_update update;
-	struct hmm *hmm = range->mm->hmm;
 
 	VM_BUG_ON(!hmm);
 
@@ -216,6 +264,7 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = true;
 	hmm_invalidate_range(hmm, false, &update);
+	hmm_put(hmm);
 }
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
@@ -241,24 +290,13 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
 	if (!mm || !mirror || !mirror->ops)
 		return -EINVAL;
 
-again:
-	mirror->hmm = hmm_register(mm);
+	mirror->hmm = hmm_get_or_create(mm);
 	if (!mirror->hmm)
 		return -ENOMEM;
 
 	down_write(&mirror->hmm->mirrors_sem);
-	if (mirror->hmm->mm == NULL) {
-		/*
-		 * A racing hmm_mirror_unregister() is about to destroy the hmm
-		 * struct. Try again to allocate a new one.
-		 */
-		up_write(&mirror->hmm->mirrors_sem);
-		mirror->hmm = NULL;
-		goto again;
-	} else {
-		list_add(&mirror->list, &mirror->hmm->mirrors);
-		up_write(&mirror->hmm->mirrors_sem);
-	}
+	list_add(&mirror->list, &mirror->hmm->mirrors);
+	up_write(&mirror->hmm->mirrors_sem);
 
 	return 0;
 }
@@ -273,33 +311,18 @@ EXPORT_SYMBOL(hmm_mirror_register);
  */
 void hmm_mirror_unregister(struct hmm_mirror *mirror)
 {
-	bool should_unregister = false;
-	struct mm_struct *mm;
-	struct hmm *hmm;
+	struct hmm *hmm = READ_ONCE(mirror->hmm);
 
-	if (mirror->hmm == NULL)
+	if (hmm == NULL)
 		return;
 
-	hmm = mirror->hmm;
 	down_write(&hmm->mirrors_sem);
 	list_del_init(&mirror->list);
-	should_unregister = list_empty(&hmm->mirrors);
+	/* To protect us against double unregister ... */
 	mirror->hmm = NULL;
-	mm = hmm->mm;
-	hmm->mm = NULL;
 	up_write(&hmm->mirrors_sem);
 
-	if (!should_unregister || mm == NULL)
-		return;
-
-	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
-
-	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
-	spin_unlock(&mm->page_table_lock);
-
-	kfree(hmm);
+	hmm_put(hmm);
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
 
@@ -708,23 +731,29 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	struct mm_walk mm_walk;
 	struct hmm *hmm;
 
+	range->hmm = NULL;
+
 	/* Sanity check, this really should not happen ! */
 	if (range->start < vma->vm_start || range->start >= vma->vm_end)
 		return -EINVAL;
 	if (range->end < vma->vm_start || range->end > vma->vm_end)
 		return -EINVAL;
 
-	hmm = hmm_register(vma->vm_mm);
+	hmm = hmm_get_or_create(vma->vm_mm);
 	if (!hmm)
 		return -ENOMEM;
-	/* Caller must have registered a mirror, via hmm_mirror_register() ! */
-	if (!hmm->mmu_notifier.ops)
+
+	/* Check if hmm_mm_destroy() was call. */
+	if (hmm->mm == NULL) {
+		hmm_put(hmm);
 		return -EINVAL;
+	}
 
 	/* FIXME support hugetlb fs */
 	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
 			vma_is_dax(vma)) {
 		hmm_pfns_special(range);
+		hmm_put(hmm);
 		return -EINVAL;
 	}
 
@@ -736,6 +765,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 		 * operations such has atomic access would not work.
 		 */
 		hmm_pfns_clear(range, range->pfns, range->start, range->end);
+		hmm_put(hmm);
 		return -EPERM;
 	}
 
@@ -758,6 +788,12 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	mm_walk.pte_hole = hmm_vma_walk_hole;
 
 	walk_page_range(range->start, range->end, &mm_walk);
+	/*
+	 * Transfer hmm reference to the range struct it will be drop inside
+	 * the hmm_vma_range_done() function (which _must_ be call if this
+	 * function return 0).
+	 */
+	range->hmm = hmm;
 	return 0;
 }
 EXPORT_SYMBOL(hmm_vma_get_pfns);
@@ -802,25 +838,27 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
  */
 bool hmm_vma_range_done(struct hmm_range *range)
 {
-	unsigned long npages = (range->end - range->start) >> PAGE_SHIFT;
-	struct hmm *hmm;
+	bool ret = false;
 
-	if (range->end <= range->start) {
+	/* Sanity check this really should not happen. */
+	if (range->hmm == NULL || range->end <= range->start) {
 		BUG();
 		return false;
 	}
 
-	hmm = hmm_register(range->vma->vm_mm);
-	if (!hmm) {
-		memset(range->pfns, 0, sizeof(*range->pfns) * npages);
-		return false;
-	}
-
-	spin_lock(&hmm->lock);
+	spin_lock(&range->hmm->lock);
 	list_del_rcu(&range->list);
-	spin_unlock(&hmm->lock);
+	ret = range->valid;
+	spin_unlock(&range->hmm->lock);
 
-	return range->valid;
+	/* Is the mm still alive ? */
+	if (range->hmm->mm == NULL)
+		ret = false;
+
+	/* Drop reference taken by hmm_vma_fault() or hmm_vma_get_pfns() */
+	hmm_put(range->hmm);
+	range->hmm = NULL;
+	return ret;
 }
 EXPORT_SYMBOL(hmm_vma_range_done);
 
@@ -880,25 +918,31 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 	struct hmm *hmm;
 	int ret;
 
+	range->hmm = NULL;
+
 	/* Sanity check, this really should not happen ! */
 	if (range->start < vma->vm_start || range->start >= vma->vm_end)
 		return -EINVAL;
 	if (range->end < vma->vm_start || range->end > vma->vm_end)
 		return -EINVAL;
 
-	hmm = hmm_register(vma->vm_mm);
+	hmm = hmm_get_or_create(vma->vm_mm);
 	if (!hmm) {
 		hmm_pfns_clear(range, range->pfns, range->start, range->end);
 		return -ENOMEM;
 	}
-	/* Caller must have registered a mirror using hmm_mirror_register() */
-	if (!hmm->mmu_notifier.ops)
+
+	/* Check if hmm_mm_destroy() was call. */
+	if (hmm->mm == NULL) {
+		hmm_put(hmm);
 		return -EINVAL;
+	}
 
 	/* FIXME support hugetlb fs */
 	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
 			vma_is_dax(vma)) {
 		hmm_pfns_special(range);
+		hmm_put(hmm);
 		return -EINVAL;
 	}
 
@@ -910,6 +954,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 		 * operations such has atomic access would not work.
 		 */
 		hmm_pfns_clear(range, range->pfns, range->start, range->end);
+		hmm_put(hmm);
 		return -EPERM;
 	}
 
@@ -945,7 +990,16 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 		hmm_pfns_clear(range, &range->pfns[i], hmm_vma_walk.last,
 			       range->end);
 		hmm_vma_range_done(range);
+		hmm_put(hmm);
+	} else {
+		/*
+		 * Transfer hmm reference to the range struct it will be drop
+		 * inside the hmm_vma_range_done() function (which _must_ be
+		 * call if this function return 0).
+		 */
+		range->hmm = hmm;
 	}
+
 	return ret;
 }
 EXPORT_SYMBOL(hmm_vma_fault);
-- 
2.17.2

