Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FCCFC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:18:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA7F220656
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:18:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="T+UpPVnW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA7F220656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FC416B0003; Wed, 26 Jun 2019 14:18:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B50D8E0003; Wed, 26 Jun 2019 14:18:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 374978E0002; Wed, 26 Jun 2019 14:18:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 113B56B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:18:28 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id r67so6464570ywg.7
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 11:18:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=cYapjH49w+mpLgSg9Urbt+jP21Tl5ENB43gy2XeqD5U=;
        b=UAz6KNr18UPBPsHBlgEAqyF9G1Z2MvJDo8xYLitNdvfPU2Lo+ireKoTn1qgJfwZcT1
         VskhBuDi1nqneB707zpd9ptxYTfQErf0IxnHuRupv5kkifcRv/kll/2DZ3wnIi6FAmUO
         VcTVj0fwDD4Kl2hQaZr+o6mrXeXU4NV8RcK4Mujp54fgBzRRZt7FnigE+bRSA7QJxV7T
         euBuNb03GsY2cGxm02jEggRTFh5J4zjiH4NH7jR4D+7mEgs6fHM+2PTGlwCQd4KjHcrh
         6YYIr4rFb5fEuL84ba0NP1vWRPRJJpsn1FG77hX2GAL5EoRd35+jnygIZCsXaCw7aLTq
         KV8w==
X-Gm-Message-State: APjAAAX7UW0PAz6fomqBt4TZ7akwmEo80s86kKe/QKwWsnydxTGV5HYm
	6E2++2xtHlAX0z32ZHGufEQ214sLFwigd73pFixvIljZFDIX6vexSK8nEQw64XWyadmG0jJ6zIk
	51QdPxqWQEnlwneatEu7wVjvZazsOmCNUdJG1ueSJ8rm03wyqGEg3YOcTa4fBAlK0cA==
X-Received: by 2002:a25:dd7:: with SMTP id 206mr3719588ybn.98.1561573107747;
        Wed, 26 Jun 2019 11:18:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBE3ukiVw83IV7ciJ63VeOkc/tW9JkTNyXUVelWsnsIqGxn3VwoSsYHv8cAWY6LGC8uqAf
X-Received: by 2002:a25:dd7:: with SMTP id 206mr3719537ybn.98.1561573106949;
        Wed, 26 Jun 2019 11:18:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561573106; cv=none;
        d=google.com; s=arc-20160816;
        b=SLvDljP4V/AK8ApwDheS8NUlYQAd6zbZinwuj4wKLGcwmgvJ/8vwKOZQZQO6Dwjx7x
         BcgOnz9yiJOTJAtdan5ZgZh4P00kaCiG9zfZ+Xcla0p884nu5QzkX4oK9v8WZNqzlO1m
         em4LWHbCnQIKjHwrkmoINKWvgUvk4WG3Bh514bPR6cP3OHg4YFM96WMttBsAR3bCJIko
         aI7Pl1rH03qQVwo0e6t3PF+NL+uFa+wOGzxlOOdimyW85LkPoiH5EtPYmwPvLosVPi3e
         kBXj9BxYwYkheZeO91md0btnilWYB86dmVPK6KnsBYOsLWpw2y/izEJl3WOdGIeBBW6Z
         LcNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=cYapjH49w+mpLgSg9Urbt+jP21Tl5ENB43gy2XeqD5U=;
        b=E2TBrGVPFlcHHm2mfWLN9YKOpiZxCnOS8uoCMEM6+pocwU++rfqVPsrUAtFwX8Tb80
         /LDqF7lP3Zt8X1epf+khS7GF5SSGaHKXxUCFYr59ks05tB6LPObEsHggqC+gB91y/qd0
         PUsdF47KojxGMNhWuEVkN3P/mKYThLuab1o3sEU8V9EC6ZSsrXOTpgTYzpwONbLrTrcq
         zDPJbk75SJ69q5eEmh2pSTqT8tzdeJAY0WwUfnGAjMWrWX8BOb/LRgydg3gsS7ay9FU2
         YFq7WtHjOpRXBn4PQ8chMXDQJIe0TUMOPtb4bj+O0k9cYyy5XdPOryR8ziHhlGsPXR37
         tlrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=T+UpPVnW;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id l184si6903104ywf.271.2019.06.26.11.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 11:18:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=T+UpPVnW;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d13b6f10000>; Wed, 26 Jun 2019 11:18:25 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 26 Jun 2019 11:18:25 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 26 Jun 2019 11:18:25 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 26 Jun
 2019 18:18:23 +0000
Subject: Re: [PATCH v4 hmm 12/12] mm/hmm: Fix error flows in
 hmm_invalidate_range_start
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Ben Skeggs <bskeggs@redhat.com>, "Christoph
 Hellwig" <hch@lst.de>, Philip Yang <Philip.Yang@amd.com>, Ira Weiny
	<ira.weiny@intel.com>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190624210110.5098-1-jgg@ziepe.ca>
 <20190624210110.5098-13-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <035fa354-6caa-3738-b84d-20804813009a@nvidia.com>
Date: Wed, 26 Jun 2019 11:18:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190624210110.5098-13-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1561573105; bh=cYapjH49w+mpLgSg9Urbt+jP21Tl5ENB43gy2XeqD5U=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=T+UpPVnWywyEnsAY8yH8FmNePn8+ExP7J5i/rd/ELTGbm3iwXkz726U/UZsZ/ZzLr
	 eWJ3bBzDBIkWNht0+2fGMfK5t1ew2XnTyEYv9+EiXZBi7FxGjfsRVervLRjZvhM15o
	 Q8pIIKXKvSBx0gw70zrGn3mxkDos8O+HvYcpQl6Ca7ADmhB6m1w3DYStKBP0DeHE3G
	 Fj0JkJpoog3uvEq6+42SGFjW20IY27qegm+qjH/km1KatzyW8fX5cRv67UJxW7kYBe
	 XpJDp350CdiDG6Uh9m21g7QVn0/RTQDzu9Ad9/ffUuTE70megt8N0+wSJyAWDZJldF
	 efBGJNPDCEolA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/24/19 2:01 PM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> If the trylock on the hmm->mirrors_sem fails the function will return
> without decrementing the notifiers that were previously incremented. Since
> the caller will not call invalidate_range_end() on EAGAIN this will result
> in notifiers becoming permanently incremented and deadlock.
> 
> If the sync_cpu_device_pagetables() required blocking the function will
> not return EAGAIN even though the device continues to touch the
> pages. This is a violation of the mmu notifier contract.
> 
> Switch, and rename, the ranges_lock to a spin lock so we can reliably
> obtain it without blocking during error unwind.
> 
> The error unwind is necessary since the notifiers count must be held
> incremented across the call to sync_cpu_device_pagetables() as we cannot
> allow the range to become marked valid by a parallel
> invalidate_start/end() pair while doing sync_cpu_device_pagetables().
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Tested-by: Philip Yang <Philip.Yang@amd.com>
> ---
>   include/linux/hmm.h |  2 +-
>   mm/hmm.c            | 72 +++++++++++++++++++++++++++------------------
>   2 files changed, 45 insertions(+), 29 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index bf013e96525771..0fa8ea34ccef6d 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -86,7 +86,7 @@
>   struct hmm {
>   	struct mm_struct	*mm;
>   	struct kref		kref;
> -	struct mutex		lock;
> +	spinlock_t		ranges_lock;
>   	struct list_head	ranges;
>   	struct list_head	mirrors;
>   	struct mmu_notifier	mmu_notifier;
> diff --git a/mm/hmm.c b/mm/hmm.c
> index b224ea635a7716..89549eac03d506 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -64,7 +64,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>   	init_rwsem(&hmm->mirrors_sem);
>   	hmm->mmu_notifier.ops = NULL;
>   	INIT_LIST_HEAD(&hmm->ranges);
> -	mutex_init(&hmm->lock);
> +	spin_lock_init(&hmm->ranges_lock);
>   	kref_init(&hmm->kref);
>   	hmm->notifiers = 0;
>   	hmm->mm = mm;
> @@ -144,6 +144,23 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   	hmm_put(hmm);
>   }
>   
> +static void notifiers_decrement(struct hmm *hmm)
> +{
> +	lockdep_assert_held(&hmm->ranges_lock);
> +

Why not acquire the lock here and release at the end instead
of asserting the lock is held?
It looks like everywhere notifiers_decrement() is called does
that.

> +	hmm->notifiers--;
> +	if (!hmm->notifiers) {
> +		struct hmm_range *range;
> +
> +		list_for_each_entry(range, &hmm->ranges, list) {
> +			if (range->valid)
> +				continue;
> +			range->valid = true;
> +		}
> +		wake_up_all(&hmm->wq);
> +	}
> +}
> +
>   static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   			const struct mmu_notifier_range *nrange)
>   {
> @@ -151,6 +168,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   	struct hmm_mirror *mirror;
>   	struct hmm_update update;
>   	struct hmm_range *range;
> +	unsigned long flags;
>   	int ret = 0;
>   
>   	if (!kref_get_unless_zero(&hmm->kref))
> @@ -161,12 +179,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   	update.event = HMM_UPDATE_INVALIDATE;
>   	update.blockable = mmu_notifier_range_blockable(nrange);
>   
> -	if (mmu_notifier_range_blockable(nrange))
> -		mutex_lock(&hmm->lock);
> -	else if (!mutex_trylock(&hmm->lock)) {
> -		ret = -EAGAIN;
> -		goto out;
> -	}
> +	spin_lock_irqsave(&hmm->ranges_lock, flags);
>   	hmm->notifiers++;
>   	list_for_each_entry(range, &hmm->ranges, list) {
>   		if (update.end < range->start || update.start >= range->end)
> @@ -174,7 +187,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   
>   		range->valid = false;
>   	}
> -	mutex_unlock(&hmm->lock);
> +	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
>   
>   	if (mmu_notifier_range_blockable(nrange))
>   		down_read(&hmm->mirrors_sem);
> @@ -182,16 +195,26 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   		ret = -EAGAIN;
>   		goto out;
>   	}
> +
>   	list_for_each_entry(mirror, &hmm->mirrors, list) {
> -		int ret;
> +		int rc;
>   
> -		ret = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
> -		if (!update.blockable && ret == -EAGAIN)
> +		rc = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
> +		if (rc) {
> +			if (WARN_ON(update.blockable || rc != -EAGAIN))
> +				continue;
> +			ret = -EAGAIN;
>   			break;
> +		}
>   	}
>   	up_read(&hmm->mirrors_sem);
>   
>   out:
> +	if (ret) {
> +		spin_lock_irqsave(&hmm->ranges_lock, flags);
> +		notifiers_decrement(hmm);
> +		spin_unlock_irqrestore(&hmm->ranges_lock, flags);
> +	}
>   	hmm_put(hmm);
>   	return ret;
>   }
> @@ -200,23 +223,14 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
>   			const struct mmu_notifier_range *nrange)
>   {
>   	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
> +	unsigned long flags;
>   
>   	if (!kref_get_unless_zero(&hmm->kref))
>   		return;
>   
> -	mutex_lock(&hmm->lock);
> -	hmm->notifiers--;
> -	if (!hmm->notifiers) {
> -		struct hmm_range *range;
> -
> -		list_for_each_entry(range, &hmm->ranges, list) {
> -			if (range->valid)
> -				continue;
> -			range->valid = true;
> -		}
> -		wake_up_all(&hmm->wq);
> -	}
> -	mutex_unlock(&hmm->lock);
> +	spin_lock_irqsave(&hmm->ranges_lock, flags);
> +	notifiers_decrement(hmm);
> +	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
>   
>   	hmm_put(hmm);
>   }
> @@ -868,6 +882,7 @@ int hmm_range_register(struct hmm_range *range,
>   {
>   	unsigned long mask = ((1UL << page_shift) - 1UL);
>   	struct hmm *hmm = mirror->hmm;
> +	unsigned long flags;
>   
>   	range->valid = false;
>   	range->hmm = NULL;
> @@ -886,7 +901,7 @@ int hmm_range_register(struct hmm_range *range,
>   		return -EFAULT;
>   
>   	/* Initialize range to track CPU page table updates. */
> -	mutex_lock(&hmm->lock);
> +	spin_lock_irqsave(&hmm->ranges_lock, flags);
>   
>   	range->hmm = hmm;
>   	kref_get(&hmm->kref);
> @@ -898,7 +913,7 @@ int hmm_range_register(struct hmm_range *range,
>   	 */
>   	if (!hmm->notifiers)
>   		range->valid = true;
> -	mutex_unlock(&hmm->lock);
> +	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
>   
>   	return 0;
>   }
> @@ -914,10 +929,11 @@ EXPORT_SYMBOL(hmm_range_register);
>   void hmm_range_unregister(struct hmm_range *range)
>   {
>   	struct hmm *hmm = range->hmm;
> +	unsigned long flags;
>   
> -	mutex_lock(&hmm->lock);
> +	spin_lock_irqsave(&hmm->ranges_lock, flags);
>   	list_del_init(&range->list);
> -	mutex_unlock(&hmm->lock);
> +	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
>   
>   	/* Drop reference taken by hmm_range_register() */
>   	mmput(hmm->mm);
> 

