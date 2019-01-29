Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92229C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3417A20989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3417A20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A47848E0003; Tue, 29 Jan 2019 11:54:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F5D78E0001; Tue, 29 Jan 2019 11:54:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 823608E0003; Tue, 29 Jan 2019 11:54:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 499598E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:41 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a199so22078282qkb.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dYSEonfMHD0KMzmNcwh/ReESOay5XsdPiDMnqImW2JM=;
        b=uLLBeIv5Of/OhDaagIRGfxzqsh2hX0TZabBhisy6hpWZcpjSB1kkmvsSvNvw6AYtjC
         T09QdG473945gLWhsnvqimSW32QKOUVgmuX3RwDXdUFseKP4XXNlkRi4RusnRw0MkbTS
         XraIUPlbwcIvkJW1hAkPFFTIzC2BszNn0ilz8IXjKbx+DoT/pKIJLeJknkoQqaOSIW+N
         PGq1n6tUAO2y7VphMSroIJqQRskBJQzUez6ZRtS7IhFtCZXadSK460RYS4CyrgcqbYRX
         JnsgHky10tnfBozqYGIjtxUusOxc80ysrO1qYBkZxt8fv964Si6yIYUXuEZtu2h+Xghv
         HWpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcaMT9JnW0gaa3LsMZLRVqu+ccLNbKlf0cvITUIiaL7feeagd9c
	TFJrurcK+0rGi94B1Ziy7ykiXnyGIzUvV8Yj9fWEiE2uwNgVqD7N8M3yNowMd/lPTm6iC+U3NtI
	cfqNNoggt8CkyNnAYTYYy2WNEnNyzSa3eHwsYEV6kfPd7+TVvBpEZezLhqH/Ltizjzg==
X-Received: by 2002:ac8:668c:: with SMTP id d12mr25631846qtp.242.1548780881004;
        Tue, 29 Jan 2019 08:54:41 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6VepIYAJF0yEqFkYoZh4cDRWlO1s7hSPeit1o/YqjqhBfhMerkXKbrSZFl7aE58mFn8U8w
X-Received: by 2002:ac8:668c:: with SMTP id d12mr25631806qtp.242.1548780880346;
        Tue, 29 Jan 2019 08:54:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780880; cv=none;
        d=google.com; s=arc-20160816;
        b=rg64qBr7A/nc+akDSDkcLefzBZGrLCfmn90F/prkwqIoJSiAprKBnlYAyG+BfTyuwf
         GpJkYiKrs5yNm0O8u00uV5rdycR/e7ZJM0pzVRGm91Lyo78Sn+clNjOFgRpIxOexTmri
         j7ds6HZZ7p7m5KiGNd1I6XA2bth707Tdm7S0P90QyVbV9Bq7GFUnvutbB8y5hwUDmj5c
         wQBNJidniBXH7z+/P0oUO854m9KR9RxGUNA63A3MXkyGoAk+YiJ9bOfi7so7hAb/ffXv
         CSN1PCYuXxcV8TseRmjPpwmh9iiiFCFeNdUaR2Vszvfwg3Eyq8xR/3yY/LEtQzRCbZOG
         XrZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dYSEonfMHD0KMzmNcwh/ReESOay5XsdPiDMnqImW2JM=;
        b=PO4sZTFRMGWNVS5A94xwgdSq00kREaM6ol4mD29V5xL9M2K6hIbqKtoGLMkAyrUO7O
         nDpncRUpp9zp/c9VgezYWR2mE15FWi4fC4XzP2PnV5cRLmiCpkK4727zGdbpuiNUxpfD
         jaaweSvEuO5pPdXdufPwc9d6ZcimYsnyzXQmYEKIWxjgZgMhw6E2iuBTwpct3UMVx3GV
         vlTXHHFjlOnlGFDYaK91NVR9KYS9sQUnuNYtJv2/S37umlnpTMjtx9dfzOYpwGP7F2Mn
         rmGHvezGYX9/QtN0WEDbdkewrLbuGkTEHLarDZnSfBJ6I9FNbrKWHkkLSUvDU1nCNebU
         aFmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p78si1683979qke.233.2019.01.29.08.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:40 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 828BC8667E;
	Tue, 29 Jan 2019 16:54:39 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 59C10103BAAD;
	Tue, 29 Jan 2019 16:54:38 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 01/10] mm/hmm: use reference counting for HMM struct
Date: Tue, 29 Jan 2019 11:54:19 -0500
Message-Id: <20190129165428.3931-2-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 29 Jan 2019 16:54:39 +0000 (UTC)
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

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/hmm.h |   2 +
 mm/hmm.c            | 178 +++++++++++++++++++++++++++++---------------
 2 files changed, 120 insertions(+), 60 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 66f9ebbb1df3..bd6e058597a6 100644
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
index a04e4b810610..b9f384ea15e9 100644
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
 
+static inline struct hmm *hmm_get(struct mm_struct *mm)
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
+	struct hmm *hmm = hmm_get(mm);
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
+	hmm = hmm_get(mm);
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
+	struct hmm *hmm = hmm_get(mm);
 
 	down_write(&hmm->mirrors_sem);
 	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
@@ -186,36 +225,50 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 						  struct hmm_mirror, list);
 	}
 	up_write(&hmm->mirrors_sem);
+
+	hmm_put(hmm);
 }
 
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 			const struct mmu_notifier_range *range)
 {
 	struct hmm_update update;
-	struct hmm *hmm = range->mm->hmm;
+	struct hmm *hmm = hmm_get(range->mm);
+	int ret;
 
 	VM_BUG_ON(!hmm);
 
+	/* Check if hmm_mm_destroy() was call. */
+	if (hmm->mm == NULL)
+		return 0;
+
 	update.start = range->start;
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
 	struct hmm_update update;
-	struct hmm *hmm = range->mm->hmm;
+	struct hmm *hmm = hmm_get(range->mm);
 
 	VM_BUG_ON(!hmm);
 
+	/* Check if hmm_mm_destroy() was call. */
+	if (hmm->mm == NULL)
+		return;
+
 	update.start = range->start;
 	update.end = range->end;
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = true;
 	hmm_invalidate_range(hmm, false, &update);
+	hmm_put(hmm);
 }
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
@@ -241,24 +294,13 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
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
@@ -273,33 +315,18 @@ EXPORT_SYMBOL(hmm_mirror_register);
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
 
@@ -708,6 +735,8 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	struct mm_walk mm_walk;
 	struct hmm *hmm;
 
+	range->hmm = NULL;
+
 	/* Sanity check, this really should not happen ! */
 	if (range->start < vma->vm_start || range->start >= vma->vm_end)
 		return -EINVAL;
@@ -717,14 +746,18 @@ int hmm_vma_get_pfns(struct hmm_range *range)
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
 
@@ -736,6 +769,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 		 * operations such has atomic access would not work.
 		 */
 		hmm_pfns_clear(range, range->pfns, range->start, range->end);
+		hmm_put(hmm);
 		return -EPERM;
 	}
 
@@ -758,6 +792,12 @@ int hmm_vma_get_pfns(struct hmm_range *range)
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
@@ -802,25 +842,27 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
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
 
@@ -880,6 +922,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 	struct hmm *hmm;
 	int ret;
 
+	range->hmm = NULL;
+
 	/* Sanity check, this really should not happen ! */
 	if (range->start < vma->vm_start || range->start >= vma->vm_end)
 		return -EINVAL;
@@ -891,14 +935,18 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
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
 
@@ -910,6 +958,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 		 * operations such has atomic access would not work.
 		 */
 		hmm_pfns_clear(range, range->pfns, range->start, range->end);
+		hmm_put(hmm);
 		return -EPERM;
 	}
 
@@ -945,7 +994,16 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
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

