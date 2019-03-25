Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC759C10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 998152087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 998152087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6986B000C; Mon, 25 Mar 2019 10:40:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 141CC6B000A; Mon, 25 Mar 2019 10:40:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB5D06B000E; Mon, 25 Mar 2019 10:40:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B483F6B000A
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:18 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id i124so8722617qkf.14
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7ONGTr4kZBuzxpe8M2z5Jy/Fc61VQBkFLKoCUtjqGXY=;
        b=onD4LrU38RLiYboAdPCgPZKKeOduDF5UB0i/P5ftJYo76xRl/7V9Yj6MNLyVIkM0Xb
         vaWVnmf1mqv+PT8lEUJGzoxX2Z6npZ2lGuMOdT2DZ1vMuGTSSsaVrnIz9sdedtNqnT87
         5Ou4H7g5MtUso7TcQuIsu0Bi02EFeLqELzkO4lNPGHv2N8gIx4sslC1Cq94jLHidL9nt
         DUCauiXy7xxy52uGEJd+2L8m9QrUkkQNj9SFlYI9+4zJWYu9S5YI8r7WYHBWL/G32654
         dqAGwrvxgwqHgYsrZc5UkfiScAkflQWTjAb2pRxL1XCFG5sdYmtqStqhqb2Hn3pXnbtA
         CWKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXoQL18AXbjRM1vBHAEEcaFJj4a1xCpB1xGSlSUsSl245ZNJUFe
	rzzxkBHC+Zolh16mpDAF0K+WYn6zG7rHGWOnz5zsU2VOy6AKXulwGrYynmcpjmlt2A9cho7XKzU
	N2F9Y1FIrzBBH6CC+3Rvz7sYP2uFtMQ8SPfKYqBLFpxwOm2mgjcTItzWjmWETG7HI4Q==
X-Received: by 2002:ae9:e417:: with SMTP id q23mr17949285qkc.29.1553524818457;
        Mon, 25 Mar 2019 07:40:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKJHRRihScJwyooMNBntqi6jGoblocBp1XqGlZulia9I7EU8WL+6SAWw9D18+WULdROutY
X-Received: by 2002:ae9:e417:: with SMTP id q23mr17949197qkc.29.1553524817022;
        Mon, 25 Mar 2019 07:40:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524817; cv=none;
        d=google.com; s=arc-20160816;
        b=jp3oIp/jx2AjvqG0cB2BUxmkYX2v3h0FCv6St4rrJv47v0b9B8zj5jGr1+9RB3q4uI
         j7zSPI3jJuE38IoMAif2T8yMf1JlRwWDw8xtcU/DMUB1jFao47yC5SNdHl/sTgpQcoBZ
         z5j07Z7ZTHZYBRlCR69M5kkA0xVR09+1uG4emo7CS4UPmuX5UvdMxjZHeChxVW05cVgp
         KlcrcCBYbWBZp+wF1Brensx0sZ8GvfMLOXI4u4R01t+Z/DKdJS0EuF4rXR71om61Pw/r
         DDn6Ye+KMIM3ZV0/IM9lqeLlPUw5Rg8sQ4o03HvrvU1dNJlwoNLBNH3l42k0pQ9SFdPO
         dD7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7ONGTr4kZBuzxpe8M2z5Jy/Fc61VQBkFLKoCUtjqGXY=;
        b=0lwVEsDiHzoitqlvHoHZLyIVHxVrbqTLOuDkZMMnH9qr+dpdNrrdGMGBd8FBxD55S9
         x5eDI+Uvt5UlFi7H59B+p0FZ8cB1ZALZPq/rXg4+76HADqCN4AS9T0EAONjDw3TbTkPv
         GyCASQ331BTslGtCFcuy7/Mp093N/FoZjXQG2Y3qcaQMg4yUqkf2frOENRs3HpSfRBOk
         kZ4WDcj4VBWvT0L1vuXEGGNfsIarxEz+XleV1/E3TpQXEfuYv/w4z5udwF54LX98Jdrw
         4A40Cy/kCvfGN2CyHG0SoQP82D2tc34nugcQJa86J+0b/5E764/Xsk3ACD0qS4FmXOQq
         Qr7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g203si1742440qkb.218.2019.03.25.07.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3699C3083363;
	Mon, 25 Mar 2019 14:40:16 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 744A21001DE4;
	Mon, 25 Mar 2019 14:40:15 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
Date: Mon, 25 Mar 2019 10:40:02 -0400
Message-Id: <20190325144011.10560-3-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 25 Mar 2019 14:40:16 +0000 (UTC)
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
 mm/hmm.c            | 170 ++++++++++++++++++++++++++++----------------
 2 files changed, 112 insertions(+), 60 deletions(-)

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
index fe1cd87e49ac..306e57f7cded 100644
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
@@ -57,6 +58,16 @@ struct hmm {
 	struct rw_semaphore	mirrors_sem;
 };
 
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
 /*
  * hmm_register - register HMM against an mm (HMM internal)
  *
@@ -67,14 +78,9 @@ struct hmm {
  */
 static struct hmm *hmm_register(struct mm_struct *mm)
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
 
@@ -86,6 +92,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	hmm->mmu_notifier.ops = NULL;
 	INIT_LIST_HEAD(&hmm->ranges);
 	spin_lock_init(&hmm->lock);
+	kref_init(&hmm->kref);
 	hmm->mm = mm;
 
 	spin_lock(&mm->page_table_lock);
@@ -106,7 +113,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
 		goto error_mm;
 
-	return mm->hmm;
+	return hmm;
 
 error_mm:
 	spin_lock(&mm->page_table_lock);
@@ -118,9 +125,41 @@ static struct hmm *hmm_register(struct mm_struct *mm)
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
@@ -165,7 +204,7 @@ static int hmm_invalidate_range(struct hmm *hmm, bool device,
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct hmm_mirror *mirror;
-	struct hmm *hmm = mm->hmm;
+	struct hmm *hmm = mm_get_hmm(mm);
 
 	down_write(&hmm->mirrors_sem);
 	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
@@ -186,13 +225,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
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
 
@@ -200,14 +242,16 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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
 
@@ -216,6 +260,7 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = true;
 	hmm_invalidate_range(hmm, false, &update);
+	hmm_put(hmm);
 }
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
@@ -241,24 +286,13 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
 	if (!mm || !mirror || !mirror->ops)
 		return -EINVAL;
 
-again:
 	mirror->hmm = hmm_register(mm);
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
@@ -273,33 +307,18 @@ EXPORT_SYMBOL(hmm_mirror_register);
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
 
@@ -708,6 +727,8 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	struct mm_walk mm_walk;
 	struct hmm *hmm;
 
+	range->hmm = NULL;
+
 	/* Sanity check, this really should not happen ! */
 	if (range->start < vma->vm_start || range->start >= vma->vm_end)
 		return -EINVAL;
@@ -717,14 +738,18 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	hmm = hmm_register(vma->vm_mm);
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
 
@@ -736,6 +761,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 		 * operations such has atomic access would not work.
 		 */
 		hmm_pfns_clear(range, range->pfns, range->start, range->end);
+		hmm_put(hmm);
 		return -EPERM;
 	}
 
@@ -758,6 +784,12 @@ int hmm_vma_get_pfns(struct hmm_range *range)
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
@@ -802,25 +834,27 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
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
 
@@ -880,6 +914,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 	struct hmm *hmm;
 	int ret;
 
+	range->hmm = NULL;
+
 	/* Sanity check, this really should not happen ! */
 	if (range->start < vma->vm_start || range->start >= vma->vm_end)
 		return -EINVAL;
@@ -891,14 +927,18 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
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
 
@@ -910,6 +950,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 		 * operations such has atomic access would not work.
 		 */
 		hmm_pfns_clear(range, range->pfns, range->start, range->end);
+		hmm_put(hmm);
 		return -EPERM;
 	}
 
@@ -945,7 +986,16 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
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

