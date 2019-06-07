Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32148C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1920207E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:15:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="X3TwxqkB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1920207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 625166B0003; Thu,  6 Jun 2019 23:15:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FD6E6B0008; Thu,  6 Jun 2019 23:15:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C3696B000A; Thu,  6 Jun 2019 23:15:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5066B0003
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 23:15:05 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 71so321388oti.2
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 20:15:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=mCcWZEzpCTsPipMN71Lz9uMR0MoE4eiC77/meSFaMEQ=;
        b=bhPJpNGFXMiPLqP3OwBhJS/bY/CDgU4WylRu9CPz2xYM7MBhe74lqN7d9TqAqYPcD4
         vHaMn2Iv52RwQwjPHP379Vw8pjqb7e/2Ve6uQvA1dMo1GznntlzevvtBXyK57WIN6Vqm
         L0sZoGT4JK9NLkdVD9QI3VG+SFdjVf98dPo/XhtsFVEkBnXHNgHPrzxzB9OC7EuVR4hL
         7mcgP3vJswVqtGY7KBfmWna0oOXGBcooRql7HmB4JmZ5M0mC5UAbbvsova/FkxhZYQLq
         5BI5kJOSgWZK4tkSbZ/nBf9yUjcdnT09/8y9LpK1FfVg925/HDsbfUJuSKeIlNxTqYKF
         O+gw==
X-Gm-Message-State: APjAAAUtjAQ7shxBgZcS3Eojxd5l1iaRIVmBRiOckM3l6AdGgNrkAcV4
	V0t1AdepIkAtnQY50TVhvyOkUvKRuDiAyy9ASLjJqfcxvCFuoNGjmRoQmtXheZqryd1/5IhIXOn
	Q5tJTZYR9/Ck44UFxCRx6q12rkUcRq4e09UTNwpRctNKRBJc7TXsJDWMTkYCs31B8hw==
X-Received: by 2002:a9d:3c5:: with SMTP id f63mr10352049otf.210.1559877304757;
        Thu, 06 Jun 2019 20:15:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZwGtmLIFpSxzhbpV3jsOsEuqMLAJYc7hp8vBM2j9sBUrecCsNmvX3642v62TahigIC8wk
X-Received: by 2002:a9d:3c5:: with SMTP id f63mr10352020otf.210.1559877303865;
        Thu, 06 Jun 2019 20:15:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559877303; cv=none;
        d=google.com; s=arc-20160816;
        b=W7DmTI6y4OgS1dl0qbiTKFMJVJ1QYAXZsMXoU0q9U3/ERAfjvKfz+IBXWi3IifDGoj
         emJpzqzIUUTaO7ati4g1vQMFW7hemsxCqE/8rF7vp+3/oGryJ5jf3WzNryBD5sGExLAw
         eugzPk/uNVS2UbTlwQ9FCNFkazo7r4C5c2yIXJVruIrmbuQmcAekXOckDgt0EZsb+7LC
         DqE0P9NJj7qckugegYBRcSNGSzJ/rAmcScQbl0BA+y6fB0H4SR+Bg3pZs5otAVEMOlDh
         eiZVZYkAiBMGHiqBbo60k0I6AvG19lEO++nR7lHtXmUkUNnFQNKSmyvOYLTRRXSVyrlx
         0Mvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=mCcWZEzpCTsPipMN71Lz9uMR0MoE4eiC77/meSFaMEQ=;
        b=bDkuWtuo2OwmDvTVHSm6+5aobeU305Bci1fRJZY2NtZDUO2y8Qj8LD8UxS+78KdL74
         4KaJ1UcLPYVQj9WXlNUVN+L6yduTH3O2MySBMyG8Bobkc/olspNjwhFPPgi7EThQmL92
         Ik85wndGhDTSgJPGkMsfCBv3FPRXYiNJgfa7408AzY/rfbHnIWF6L/qU8OOygvc37MF7
         QRe1CjtRt14hCp4e49EmvfDYuozPNdUmaQRmdx1lucSsey+pznjpxJVMmNBosFXdJOm2
         vYDMERgi3j7fyg8FaCC7BZNsdzRO99LTNAb7ITdNZWRevyMoHTBFYsHtL6Tf24ekDwd0
         QiIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=X3TwxqkB;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id c83si638711oif.99.2019.06.06.20.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 20:15:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=X3TwxqkB;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9d6b60000>; Thu, 06 Jun 2019 20:15:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 20:15:03 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 06 Jun 2019 20:15:03 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 03:15:00 +0000
Subject: Re: [PATCH v2 hmm 06/11] mm/hmm: Hold on to the mmget for the
 lifetime of the range
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-7-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <326c4ed3-5232-4a58-7501-d27f763a9b56@nvidia.com>
Date: Thu, 6 Jun 2019 20:15:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-7-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559877303; bh=mCcWZEzpCTsPipMN71Lz9uMR0MoE4eiC77/meSFaMEQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=X3TwxqkBds3ij5FnWrqRL99V47aBaPIKWcjKrhPbF0tav64A16LFWGRp/3prKJxOK
	 phms8zB0OSFinWSxdr/cB++D0LDlUH3N5UvWsrk1CCcJbTbBwhkrQ4E1+v90nzrj7k
	 YYvBlH+G1S8iFPxp5OH509NjsD+9sPDp3P/J31eCGssrLFN+u/4tOZn6dirtjhTmZ7
	 l/vJNbS+XdQqGpddyIoHpge99rIroRbjtwxxbZMprAAdPWtOPGQvo9E0KX7JEFJRwm
	 I1NnL/nWUEGanUITplh4wTCfa5OcGDDyeFK2b3bpd5NAAO0W3TRpsZf9yMeXyfnUSy
	 2ZyzoEM/ZeRCw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> Range functions like hmm_range_snapshot() and hmm_range_fault() call
> find_vma, which requires hodling the mmget() and the mmap_sem for the mm.
> 
> Make this simpler for the callers by holding the mmget() inside the range
> for the lifetime of the range. Other functions that accept a range should
> only be called if the range is registered.
> 
> This has the side effect of directly preventing hmm_release() from
> happening while a range is registered. That means range->dead cannot be
> false during the lifetime of the range, so remove dead and
> hmm_mirror_mm_is_alive() entirely.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> ---
> v2:
>  - Use Jerome's idea of just holding the mmget() for the range lifetime,
>    rework the patch to use that as as simplification to remove dead in
>    one step
> ---
>  include/linux/hmm.h | 26 --------------------------
>  mm/hmm.c            | 28 ++++++++++------------------
>  2 files changed, 10 insertions(+), 44 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 2ab35b40992b24..0e20566802967a 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -91,7 +91,6 @@
>   * @mirrors_sem: read/write semaphore protecting the mirrors list
>   * @wq: wait queue for user waiting on a range invalidation
>   * @notifiers: count of active mmu notifiers
> - * @dead: is the mm dead ?
>   */
>  struct hmm {
>  	struct mm_struct	*mm;
> @@ -104,7 +103,6 @@ struct hmm {
>  	wait_queue_head_t	wq;
>  	struct rcu_head		rcu;
>  	long			notifiers;
> -	bool			dead;
>  };
>  
>  /*
> @@ -469,30 +467,6 @@ struct hmm_mirror {
>  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
>  void hmm_mirror_unregister(struct hmm_mirror *mirror);
>  
> -/*
> - * hmm_mirror_mm_is_alive() - test if mm is still alive
> - * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
> - * Return: false if the mm is dead, true otherwise
> - *
> - * This is an optimization, it will not always accurately return false if the
> - * mm is dead; i.e., there can be false negatives (process is being killed but
> - * HMM is not yet informed of that). It is only intended to be used to optimize
> - * out cases where the driver is about to do something time consuming and it
> - * would be better to skip it if the mm is dead.
> - */
> -static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
> -{
> -	struct mm_struct *mm;
> -
> -	if (!mirror || !mirror->hmm)
> -		return false;
> -	mm = READ_ONCE(mirror->hmm->mm);
> -	if (mirror->hmm->dead || !mm)
> -		return false;
> -
> -	return true;
> -}
> -
>  /*
>   * Please see Documentation/vm/hmm.rst for how to use the range API.
>   */
> diff --git a/mm/hmm.c b/mm/hmm.c
> index dc30edad9a8a02..f67ba32983d9f1 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -80,7 +80,6 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  	mutex_init(&hmm->lock);
>  	kref_init(&hmm->kref);
>  	hmm->notifiers = 0;
> -	hmm->dead = false;
>  	hmm->mm = mm;
>  
>  	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
> @@ -124,20 +123,17 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
>  	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>  	struct hmm_mirror *mirror;
> -	struct hmm_range *range;
>  
>  	/* hmm is in progress to free */
>  	if (!kref_get_unless_zero(&hmm->kref))
>  		return;
>  
> -	/* Report this HMM as dying. */
> -	hmm->dead = true;
> -
> -	/* Wake-up everyone waiting on any range. */
>  	mutex_lock(&hmm->lock);
> -	list_for_each_entry(range, &hmm->ranges, list)
> -		range->valid = false;
> -	wake_up_all(&hmm->wq);
> +	/*
> +	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
> +	 * prevented as long as a range exists.
> +	 */
> +	WARN_ON(!list_empty(&hmm->ranges));
>  	mutex_unlock(&hmm->lock);
>  
>  	down_write(&hmm->mirrors_sem);
> @@ -909,8 +905,8 @@ int hmm_range_register(struct hmm_range *range,
>  	range->start = start;
>  	range->end = end;
>  
> -	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL || hmm->dead)
> +	/* Prevent hmm_release() from running while the range is valid */
> +	if (!mmget_not_zero(hmm->mm))
>  		return -EFAULT;
>  
>  	range->hmm = hmm;
> @@ -955,6 +951,7 @@ void hmm_range_unregister(struct hmm_range *range)
>  
>  	/* Drop reference taken by hmm_range_register() */
>  	range->valid = false;
> +	mmput(hmm->mm);
>  	hmm_put(hmm);
>  	range->hmm = NULL;
>  }
> @@ -982,10 +979,7 @@ long hmm_range_snapshot(struct hmm_range *range)
>  	struct vm_area_struct *vma;
>  	struct mm_walk mm_walk;
>  
> -	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL || hmm->dead)
> -		return -EFAULT;
> -
> +	lockdep_assert_held(&hmm->mm->mmap_sem);
>  	do {
>  		/* If range is no longer valid force retry. */
>  		if (!range->valid)
> @@ -1080,9 +1074,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>  	struct mm_walk mm_walk;
>  	int ret;
>  
> -	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL || hmm->dead)
> -		return -EFAULT;
> +	lockdep_assert_held(&hmm->mm->mmap_sem);
>  
>  	do {
>  		/* If range is no longer valid force retry. */
> 

Nice cleanup.

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
-- 
John Hubbard
NVIDIA

