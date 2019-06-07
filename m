Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD383C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:29:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4019520868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:29:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="HdsYw5tu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4019520868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 935BB6B026E; Fri,  7 Jun 2019 16:29:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E6DA6B026F; Fri,  7 Jun 2019 16:29:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AEC26B0270; Fri,  7 Jun 2019 16:29:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2D66B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:29:35 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id q79so3140902ywg.13
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:29:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=yYVtcUZ4S+/W6zepHFlsNYbywsPo3R3lOZVdolpu61Y=;
        b=JSjMR9gNurLjL7V1Dq5xg0Hnq9tpgA++LavzH7rmcSGNwQqs8+p8KYmSYnYH/wZgZl
         WUVZd9XYCe6dRvvY770dOMr22/bpVthfV6W08XQbeEdtnp6m1d5+eAdHy/c/BNzftiuq
         s4hUmrg+nnBigZjSpM2EJMaW0iFV8joD5xswPeGhR7wxEgfqL+d4a/zw9k/4N3NwqzRY
         VwVq0uPHkfUT9wAp7M/cqUZcYH3Vam3UF8N/e8IHxjLu5Qbu/mtJKvwuMtDWKettDFCY
         y9y1UuEKCy6fyWUjY5GDBb443qU72RWq98hX3X3hHNjhYE2J7872e8vWu3cviZ9S2OqS
         OhwQ==
X-Gm-Message-State: APjAAAU95b2rYXdTd6N48LqbzPo8rWMqi3tilFUvoBkP7APSZqdrUHcU
	xDjaFLzTkLU05UNqvhd9BMLfceUc76UPDxgeIuuYT20PKn4FsL1v+SRlEAb/buOBeQK/iEITb7E
	gLig3l/fYN8lWoadS2D9HmTt5rwVyD5BeysbjFDnda6VgtTCA6tyqemkSVSnjh9jwwQ==
X-Received: by 2002:a25:ca8c:: with SMTP id a134mr19308987ybg.68.1559939375067;
        Fri, 07 Jun 2019 13:29:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGiXQcHxCxY+xzzlmBRMrVlFGNv5RNcGeD6aC60yCXbk+rhRHm2Ol9gvKKfJ+IruuabMwa
X-Received: by 2002:a25:ca8c:: with SMTP id a134mr19308964ybg.68.1559939374274;
        Fri, 07 Jun 2019 13:29:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559939374; cv=none;
        d=google.com; s=arc-20160816;
        b=sPXrKMHwfiWNDpM4peQuQb9rCpkNPNWQUTBc3uqXvKhl+GMM6NLMh/Z8nEsP5VGiym
         c+EEji/Kk0A91k1izFoyJSUYNrdOIPuFc6UOGSCzi8Xu80La5woiZz1ryx8JrjVGeUJ3
         JPLb3LzWQPwxNMNDgg6JY5LKR9QXedCy7GTGCsIfcsjxfKnx2E/z3uSo/JiQyn5q8Gfk
         DnSSO9iHZ5fAnH2GYn2KffZkKQkCoTwgVL37J1oBBJVsqgHd4HQX/iG3HjN90YBLfgXy
         6FCIeaQIJH+A27mRbGRlHszpy0AdqrMx2nXZRvOn4bQvCQnOaUDChlqxiDNQcAo21ZQF
         wdzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=yYVtcUZ4S+/W6zepHFlsNYbywsPo3R3lOZVdolpu61Y=;
        b=iR4drq/s7XS9ClgSPgwBqXho+TetEx9Pf45kAFlb8GQZhrHf1mr9AVNFkxHzS5UhoC
         yGqi92KIgww2QaD+A6lVzTPxX0DLk3um4wNpY5sjZyGRTKATlk/VwgXugKY21vWm5Lfy
         giIEhDdHNYiK1+lqGpOr729Lf6c+FrJcanEPl1g6dRTnSIrZkav2W5AJw1O2cy5TC3Fn
         gFokjlU4nJAxAaksmvm7Ypgb+K409WM8MlkMucowcvG1+x5GjS0GMTSlMSyZZ9rsmpfv
         rZbvEjBiDM6gIsA0jaei469ra6Xs9DuhUrkoinp55q7knkBXU6K76RqBZ4sgGsT4kkWU
         dMzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=HdsYw5tu;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id c124si884481ybf.261.2019.06.07.13.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:29:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=HdsYw5tu;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfac91e0000>; Fri, 07 Jun 2019 13:29:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 13:29:33 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 13:29:33 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 20:29:33 +0000
Subject: Re: [PATCH v2 hmm 06/11] mm/hmm: Hold on to the mmget for the
 lifetime of the range
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-7-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <0991d7e3-091f-67d0-25a6-3d1f491db0a8@nvidia.com>
Date: Fri, 7 Jun 2019 13:29:32 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-7-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559939358; bh=yYVtcUZ4S+/W6zepHFlsNYbywsPo3R3lOZVdolpu61Y=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=HdsYw5tumz5N98qHW3VtBIlaGYNQK46DtmRgGWkNRA6wGhIbKibst+Ukddk1jUBXg
	 gyWB6VF5Ewdl29IycHsMEmwo932SoEbNqMQaKcnN5Ox0CLqhC+u8H/ydXoVptu0pBx
	 XxqXRfcEpgVIe8yOrEXNjReO8UFV+G4b9OaTRX4eo8KBLJXwPpuogaGtVqs2Co2Pg7
	 7PNBtkd/s1t02WrR3iuWzUq5HYM6uBUlnFXZ323M9EUnVfO9TCVyE2a1GhvV1y1n4M
	 US0lBSHQXdKy1QZ1Z2mSYzLFEEFZF9txVxIg5mnFkpYJA0c6azkArozVtq7crCF6zh
	 pUY9hER+RrHqQ==
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

Looks good to me.
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
> v2:
>   - Use Jerome's idea of just holding the mmget() for the range lifetime,
>     rework the patch to use that as as simplification to remove dead in
>     one step
> ---
>   include/linux/hmm.h | 26 --------------------------
>   mm/hmm.c            | 28 ++++++++++------------------
>   2 files changed, 10 insertions(+), 44 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 2ab35b40992b24..0e20566802967a 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -91,7 +91,6 @@
>    * @mirrors_sem: read/write semaphore protecting the mirrors list
>    * @wq: wait queue for user waiting on a range invalidation
>    * @notifiers: count of active mmu notifiers
> - * @dead: is the mm dead ?
>    */
>   struct hmm {
>   	struct mm_struct	*mm;
> @@ -104,7 +103,6 @@ struct hmm {
>   	wait_queue_head_t	wq;
>   	struct rcu_head		rcu;
>   	long			notifiers;
> -	bool			dead;
>   };
>   
>   /*
> @@ -469,30 +467,6 @@ struct hmm_mirror {
>   int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
>   void hmm_mirror_unregister(struct hmm_mirror *mirror);
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
>   /*
>    * Please see Documentation/vm/hmm.rst for how to use the range API.
>    */
> diff --git a/mm/hmm.c b/mm/hmm.c
> index dc30edad9a8a02..f67ba32983d9f1 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -80,7 +80,6 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>   	mutex_init(&hmm->lock);
>   	kref_init(&hmm->kref);
>   	hmm->notifiers = 0;
> -	hmm->dead = false;
>   	hmm->mm = mm;
>   
>   	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
> @@ -124,20 +123,17 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   {
>   	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>   	struct hmm_mirror *mirror;
> -	struct hmm_range *range;
>   
>   	/* hmm is in progress to free */
>   	if (!kref_get_unless_zero(&hmm->kref))
>   		return;
>   
> -	/* Report this HMM as dying. */
> -	hmm->dead = true;
> -
> -	/* Wake-up everyone waiting on any range. */
>   	mutex_lock(&hmm->lock);
> -	list_for_each_entry(range, &hmm->ranges, list)
> -		range->valid = false;
> -	wake_up_all(&hmm->wq);
> +	/*
> +	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
> +	 * prevented as long as a range exists.
> +	 */
> +	WARN_ON(!list_empty(&hmm->ranges));
>   	mutex_unlock(&hmm->lock);
>   
>   	down_write(&hmm->mirrors_sem);
> @@ -909,8 +905,8 @@ int hmm_range_register(struct hmm_range *range,
>   	range->start = start;
>   	range->end = end;
>   
> -	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL || hmm->dead)
> +	/* Prevent hmm_release() from running while the range is valid */
> +	if (!mmget_not_zero(hmm->mm))
>   		return -EFAULT;
>   
>   	range->hmm = hmm;
> @@ -955,6 +951,7 @@ void hmm_range_unregister(struct hmm_range *range)
>   
>   	/* Drop reference taken by hmm_range_register() */
>   	range->valid = false;
> +	mmput(hmm->mm);
>   	hmm_put(hmm);
>   	range->hmm = NULL;
>   }
> @@ -982,10 +979,7 @@ long hmm_range_snapshot(struct hmm_range *range)
>   	struct vm_area_struct *vma;
>   	struct mm_walk mm_walk;
>   
> -	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL || hmm->dead)
> -		return -EFAULT;
> -
> +	lockdep_assert_held(&hmm->mm->mmap_sem);
>   	do {
>   		/* If range is no longer valid force retry. */
>   		if (!range->valid)
> @@ -1080,9 +1074,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>   	struct mm_walk mm_walk;
>   	int ret;
>   
> -	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL || hmm->dead)
> -		return -EFAULT;
> +	lockdep_assert_held(&hmm->mm->mmap_sem);
>   
>   	do {
>   		/* If range is no longer valid force retry. */
> 

