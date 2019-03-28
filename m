Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8AFBC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 19:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6821D20700
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 19:08:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6821D20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07B436B026F; Thu, 28 Mar 2019 15:08:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 003286B0270; Thu, 28 Mar 2019 15:08:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE5A76B0271; Thu, 28 Mar 2019 15:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9875D6B026F
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:08:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f6so16933889pgo.15
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=RU8IfyAQFAM8iEo48URnmWs/BSFNZnqK4yhrK3iqpOo=;
        b=PIjkRx3Op2Mf9DE9onyvSzm8pHuBzDj70JvuX65qHEyFv5+rhLR7gNUte5tcNhzZ02
         J/VKF7kU/2GFX1mulbPZY45dJGCv5GUfzAZW1MQKtRHxkWcU3NJYoaPJhO3RyMnDOQv/
         JVL0s2sAj9anXBzioo5jGTzgwbAc+05UsTVaVgq4z0ZISa4TzhNawCTSXzFx/v8eagSD
         OmWd3O31J66aDRYOCZzWMBftnwN5Sm6KYs2DC4uV8dT60GdVC3Spqw4yNNP+NKigVaeS
         /MbF9JtDt/UAl03uD+h0DNO4m/LFpmCvf5nxikGNJ6ts6oweju7KO2WaG8i9WtEBykWk
         mv3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXatUJDRsUXkvUWw9QVQLNeTI/q57+XRb3Nt2t3V87d+VheYM3q
	j9ITfWU1hf0vPAvcXxl0yXQv7xyV9sEkfS/vKyMMyL1mgClukQ/uXc2s6b5VhlBsYeO5CCD0jwQ
	IdEgZ/ONmu+WvUcdu4xR1LtFELI4M1tc6mNdpJIlOnskCigJ/68U+YA+UJsTGLWE++Q==
X-Received: by 2002:aa7:8b96:: with SMTP id r22mr42474211pfd.223.1553800109235;
        Thu, 28 Mar 2019 12:08:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNSab3t+vtBFLPh5R8oPf1QbJMLry1oW39TSVc97icaFLmpOUVCbsZzF9PZXKwUaQ5St+Q
X-Received: by 2002:aa7:8b96:: with SMTP id r22mr42474129pfd.223.1553800108121;
        Thu, 28 Mar 2019 12:08:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553800108; cv=none;
        d=google.com; s=arc-20160816;
        b=Redu9cLEdloXE+x/Ic9fjR3GyNhqvY4NzmZi8xa/3uZIv9R8NjeamGzpo/kZL/+1PC
         Tmf9If+nuFcQwNIxMRMSVQna5eFN1nYJHsMZ3cvq0CYZYttzdbn34Xl71On1VF15L6ux
         vVz5SIqPJEZjblnke4qHh36W1GW8VKwwBjOt+8ei/MyVB9FDOG++WOWWZnzB9woF5RLB
         sk75k48KcZAY7PPZYi5QyJ6GIUV2rQjUDVVx9J9hveuIy41FQvpAQe6QV+fcxJ+YDi+6
         CT6Ji7FkTLs4NOOSnRYiiEudCKHyMcNBDnAaLhAivyE0DZBAcDp7yTTZN4Se3tabG1c+
         34Sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=RU8IfyAQFAM8iEo48URnmWs/BSFNZnqK4yhrK3iqpOo=;
        b=G4tYQ08frnmVfB5QytZFdSiiID6VtRAjAhiYb6ydj5d9Vbnn5uPIaOoSgCTvgBF44e
         S+9K20ySZfIg7fldurPyJmk68gztd4m/KhJYNq5yujIpTN3Sao0uywMxlE8Yxc2LrX0z
         u6njd8lK68S2FJGJMi0tTc4CwvzLqwdZQPq3Az6IROCS/K5cUYJg0Li0qxS1GMqXbh/1
         QqdBag7136/ERXH4jylKqLdz1WK5XEAakojbLBkd90FTh5LK11S8dn1DohivmlYeSGpT
         9UoUXdt0hf0HO1QxzOgm1O3iZCqJOkspkttAP832sC1grpVYfFr3sK5Ok9+hZJ8DgApB
         TVPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t5si21157454pgu.517.2019.03.28.12.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 12:08:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 12:08:27 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,281,1549958400"; 
   d="scan'208";a="332944081"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 28 Mar 2019 12:08:27 -0700
Date: Thu, 28 Mar 2019 04:07:20 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
Message-ID: <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190325144011.10560-3-jglisse@redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 10:40:02AM -0400, Jerome Glisse wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> Every time i read the code to check that the HMM structure does not
> vanish before it should thanks to the many lock protecting its removal
> i get a headache. Switch to reference counting instead it is much
> easier to follow and harder to break. This also remove some code that
> is no longer needed with refcounting.
> 
> Changes since v1:
>     - removed bunch of useless check (if API is use with bogus argument
>       better to fail loudly so user fix their code)
>     - s/hmm_get/mm_get_hmm/
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/hmm.h |   2 +
>  mm/hmm.c            | 170 ++++++++++++++++++++++++++++----------------
>  2 files changed, 112 insertions(+), 60 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index ad50b7b4f141..716fc61fa6d4 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -131,6 +131,7 @@ enum hmm_pfn_value_e {
>  /*
>   * struct hmm_range - track invalidation lock on virtual address range
>   *
> + * @hmm: the core HMM structure this range is active against
>   * @vma: the vm area struct for the range
>   * @list: all range lock are on a list
>   * @start: range virtual start address (inclusive)
> @@ -142,6 +143,7 @@ enum hmm_pfn_value_e {
>   * @valid: pfns array did not change since it has been fill by an HMM function
>   */
>  struct hmm_range {
> +	struct hmm		*hmm;
>  	struct vm_area_struct	*vma;
>  	struct list_head	list;
>  	unsigned long		start;
> diff --git a/mm/hmm.c b/mm/hmm.c
> index fe1cd87e49ac..306e57f7cded 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -50,6 +50,7 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
>   */
>  struct hmm {
>  	struct mm_struct	*mm;
> +	struct kref		kref;
>  	spinlock_t		lock;
>  	struct list_head	ranges;
>  	struct list_head	mirrors;
> @@ -57,6 +58,16 @@ struct hmm {
>  	struct rw_semaphore	mirrors_sem;
>  };
>  
> +static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
> +{
> +	struct hmm *hmm = READ_ONCE(mm->hmm);
> +
> +	if (hmm && kref_get_unless_zero(&hmm->kref))
> +		return hmm;
> +
> +	return NULL;
> +}
> +
>  /*
>   * hmm_register - register HMM against an mm (HMM internal)
>   *
> @@ -67,14 +78,9 @@ struct hmm {
>   */
>  static struct hmm *hmm_register(struct mm_struct *mm)
>  {
> -	struct hmm *hmm = READ_ONCE(mm->hmm);
> +	struct hmm *hmm = mm_get_hmm(mm);

FWIW: having hmm_register == "hmm get" is a bit confusing...

Ira

>  	bool cleanup = false;
>  
> -	/*
> -	 * The hmm struct can only be freed once the mm_struct goes away,
> -	 * hence we should always have pre-allocated an new hmm struct
> -	 * above.
> -	 */
>  	if (hmm)
>  		return hmm;
>  
> @@ -86,6 +92,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
>  	hmm->mmu_notifier.ops = NULL;
>  	INIT_LIST_HEAD(&hmm->ranges);
>  	spin_lock_init(&hmm->lock);
> +	kref_init(&hmm->kref);
>  	hmm->mm = mm;
>  
>  	spin_lock(&mm->page_table_lock);
> @@ -106,7 +113,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
>  	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
>  		goto error_mm;
>  
> -	return mm->hmm;
> +	return hmm;
>  
>  error_mm:
>  	spin_lock(&mm->page_table_lock);
> @@ -118,9 +125,41 @@ static struct hmm *hmm_register(struct mm_struct *mm)
>  	return NULL;
>  }
>  
> +static void hmm_free(struct kref *kref)
> +{
> +	struct hmm *hmm = container_of(kref, struct hmm, kref);
> +	struct mm_struct *mm = hmm->mm;
> +
> +	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (mm->hmm == hmm)
> +		mm->hmm = NULL;
> +	spin_unlock(&mm->page_table_lock);
> +
> +	kfree(hmm);
> +}
> +
> +static inline void hmm_put(struct hmm *hmm)
> +{
> +	kref_put(&hmm->kref, hmm_free);
> +}
> +
>  void hmm_mm_destroy(struct mm_struct *mm)
>  {
> -	kfree(mm->hmm);
> +	struct hmm *hmm;
> +
> +	spin_lock(&mm->page_table_lock);
> +	hmm = mm_get_hmm(mm);
> +	mm->hmm = NULL;
> +	if (hmm) {
> +		hmm->mm = NULL;
> +		spin_unlock(&mm->page_table_lock);
> +		hmm_put(hmm);
> +		return;
> +	}
> +
> +	spin_unlock(&mm->page_table_lock);
>  }
>  
>  static int hmm_invalidate_range(struct hmm *hmm, bool device,
> @@ -165,7 +204,7 @@ static int hmm_invalidate_range(struct hmm *hmm, bool device,
>  static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
>  	struct hmm_mirror *mirror;
> -	struct hmm *hmm = mm->hmm;
> +	struct hmm *hmm = mm_get_hmm(mm);
>  
>  	down_write(&hmm->mirrors_sem);
>  	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
> @@ -186,13 +225,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  						  struct hmm_mirror, list);
>  	}
>  	up_write(&hmm->mirrors_sem);
> +
> +	hmm_put(hmm);
>  }
>  
>  static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  			const struct mmu_notifier_range *range)
>  {
> +	struct hmm *hmm = mm_get_hmm(range->mm);
>  	struct hmm_update update;
> -	struct hmm *hmm = range->mm->hmm;
> +	int ret;
>  
>  	VM_BUG_ON(!hmm);
>  
> @@ -200,14 +242,16 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  	update.end = range->end;
>  	update.event = HMM_UPDATE_INVALIDATE;
>  	update.blockable = range->blockable;
> -	return hmm_invalidate_range(hmm, true, &update);
> +	ret = hmm_invalidate_range(hmm, true, &update);
> +	hmm_put(hmm);
> +	return ret;
>  }
>  
>  static void hmm_invalidate_range_end(struct mmu_notifier *mn,
>  			const struct mmu_notifier_range *range)
>  {
> +	struct hmm *hmm = mm_get_hmm(range->mm);
>  	struct hmm_update update;
> -	struct hmm *hmm = range->mm->hmm;
>  
>  	VM_BUG_ON(!hmm);
>  
> @@ -216,6 +260,7 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
>  	update.event = HMM_UPDATE_INVALIDATE;
>  	update.blockable = true;
>  	hmm_invalidate_range(hmm, false, &update);
> +	hmm_put(hmm);
>  }
>  
>  static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
> @@ -241,24 +286,13 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
>  	if (!mm || !mirror || !mirror->ops)
>  		return -EINVAL;
>  
> -again:
>  	mirror->hmm = hmm_register(mm);
>  	if (!mirror->hmm)
>  		return -ENOMEM;
>  
>  	down_write(&mirror->hmm->mirrors_sem);
> -	if (mirror->hmm->mm == NULL) {
> -		/*
> -		 * A racing hmm_mirror_unregister() is about to destroy the hmm
> -		 * struct. Try again to allocate a new one.
> -		 */
> -		up_write(&mirror->hmm->mirrors_sem);
> -		mirror->hmm = NULL;
> -		goto again;
> -	} else {
> -		list_add(&mirror->list, &mirror->hmm->mirrors);
> -		up_write(&mirror->hmm->mirrors_sem);
> -	}
> +	list_add(&mirror->list, &mirror->hmm->mirrors);
> +	up_write(&mirror->hmm->mirrors_sem);
>  
>  	return 0;
>  }
> @@ -273,33 +307,18 @@ EXPORT_SYMBOL(hmm_mirror_register);
>   */
>  void hmm_mirror_unregister(struct hmm_mirror *mirror)
>  {
> -	bool should_unregister = false;
> -	struct mm_struct *mm;
> -	struct hmm *hmm;
> +	struct hmm *hmm = READ_ONCE(mirror->hmm);
>  
> -	if (mirror->hmm == NULL)
> +	if (hmm == NULL)
>  		return;
>  
> -	hmm = mirror->hmm;
>  	down_write(&hmm->mirrors_sem);
>  	list_del_init(&mirror->list);
> -	should_unregister = list_empty(&hmm->mirrors);
> +	/* To protect us against double unregister ... */
>  	mirror->hmm = NULL;
> -	mm = hmm->mm;
> -	hmm->mm = NULL;
>  	up_write(&hmm->mirrors_sem);
>  
> -	if (!should_unregister || mm == NULL)
> -		return;
> -
> -	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
> -
> -	spin_lock(&mm->page_table_lock);
> -	if (mm->hmm == hmm)
> -		mm->hmm = NULL;
> -	spin_unlock(&mm->page_table_lock);
> -
> -	kfree(hmm);
> +	hmm_put(hmm);
>  }
>  EXPORT_SYMBOL(hmm_mirror_unregister);
>  
> @@ -708,6 +727,8 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>  	struct mm_walk mm_walk;
>  	struct hmm *hmm;
>  
> +	range->hmm = NULL;
> +
>  	/* Sanity check, this really should not happen ! */
>  	if (range->start < vma->vm_start || range->start >= vma->vm_end)
>  		return -EINVAL;
> @@ -717,14 +738,18 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>  	hmm = hmm_register(vma->vm_mm);
>  	if (!hmm)
>  		return -ENOMEM;
> -	/* Caller must have registered a mirror, via hmm_mirror_register() ! */
> -	if (!hmm->mmu_notifier.ops)
> +
> +	/* Check if hmm_mm_destroy() was call. */
> +	if (hmm->mm == NULL) {
> +		hmm_put(hmm);
>  		return -EINVAL;
> +	}
>  
>  	/* FIXME support hugetlb fs */
>  	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
>  			vma_is_dax(vma)) {
>  		hmm_pfns_special(range);
> +		hmm_put(hmm);
>  		return -EINVAL;
>  	}
>  
> @@ -736,6 +761,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>  		 * operations such has atomic access would not work.
>  		 */
>  		hmm_pfns_clear(range, range->pfns, range->start, range->end);
> +		hmm_put(hmm);
>  		return -EPERM;
>  	}
>  
> @@ -758,6 +784,12 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>  	mm_walk.pte_hole = hmm_vma_walk_hole;
>  
>  	walk_page_range(range->start, range->end, &mm_walk);
> +	/*
> +	 * Transfer hmm reference to the range struct it will be drop inside
> +	 * the hmm_vma_range_done() function (which _must_ be call if this
> +	 * function return 0).
> +	 */
> +	range->hmm = hmm;
>  	return 0;
>  }
>  EXPORT_SYMBOL(hmm_vma_get_pfns);
> @@ -802,25 +834,27 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
>   */
>  bool hmm_vma_range_done(struct hmm_range *range)
>  {
> -	unsigned long npages = (range->end - range->start) >> PAGE_SHIFT;
> -	struct hmm *hmm;
> +	bool ret = false;
>  
> -	if (range->end <= range->start) {
> +	/* Sanity check this really should not happen. */
> +	if (range->hmm == NULL || range->end <= range->start) {
>  		BUG();
>  		return false;
>  	}
>  
> -	hmm = hmm_register(range->vma->vm_mm);
> -	if (!hmm) {
> -		memset(range->pfns, 0, sizeof(*range->pfns) * npages);
> -		return false;
> -	}
> -
> -	spin_lock(&hmm->lock);
> +	spin_lock(&range->hmm->lock);
>  	list_del_rcu(&range->list);
> -	spin_unlock(&hmm->lock);
> +	ret = range->valid;
> +	spin_unlock(&range->hmm->lock);
>  
> -	return range->valid;
> +	/* Is the mm still alive ? */
> +	if (range->hmm->mm == NULL)
> +		ret = false;
> +
> +	/* Drop reference taken by hmm_vma_fault() or hmm_vma_get_pfns() */
> +	hmm_put(range->hmm);
> +	range->hmm = NULL;
> +	return ret;
>  }
>  EXPORT_SYMBOL(hmm_vma_range_done);
>  
> @@ -880,6 +914,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
>  	struct hmm *hmm;
>  	int ret;
>  
> +	range->hmm = NULL;
> +
>  	/* Sanity check, this really should not happen ! */
>  	if (range->start < vma->vm_start || range->start >= vma->vm_end)
>  		return -EINVAL;
> @@ -891,14 +927,18 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
>  		hmm_pfns_clear(range, range->pfns, range->start, range->end);
>  		return -ENOMEM;
>  	}
> -	/* Caller must have registered a mirror using hmm_mirror_register() */
> -	if (!hmm->mmu_notifier.ops)
> +
> +	/* Check if hmm_mm_destroy() was call. */
> +	if (hmm->mm == NULL) {
> +		hmm_put(hmm);
>  		return -EINVAL;
> +	}
>  
>  	/* FIXME support hugetlb fs */
>  	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
>  			vma_is_dax(vma)) {
>  		hmm_pfns_special(range);
> +		hmm_put(hmm);
>  		return -EINVAL;
>  	}
>  
> @@ -910,6 +950,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
>  		 * operations such has atomic access would not work.
>  		 */
>  		hmm_pfns_clear(range, range->pfns, range->start, range->end);
> +		hmm_put(hmm);
>  		return -EPERM;
>  	}
>  
> @@ -945,7 +986,16 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
>  		hmm_pfns_clear(range, &range->pfns[i], hmm_vma_walk.last,
>  			       range->end);
>  		hmm_vma_range_done(range);
> +		hmm_put(hmm);
> +	} else {
> +		/*
> +		 * Transfer hmm reference to the range struct it will be drop
> +		 * inside the hmm_vma_range_done() function (which _must_ be
> +		 * call if this function return 0).
> +		 */
> +		range->hmm = hmm;
>  	}
> +
>  	return ret;
>  }
>  EXPORT_SYMBOL(hmm_vma_fault);
> -- 
> 2.17.2
> 

