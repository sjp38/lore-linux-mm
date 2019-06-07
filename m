Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91E3CC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 23:53:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08A052084C
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 23:53:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="G/Z0t5HE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08A052084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BBE56B0276; Fri,  7 Jun 2019 19:53:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 221CC6B0278; Fri,  7 Jun 2019 19:53:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B47CA6B0279; Fri,  7 Jun 2019 19:53:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 802066B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 19:53:01 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id k10so3545559ywb.18
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 16:53:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=oyJdY8/VhzNnR6cpDJoWJYEsLy7XDJAJOH2xjhGeCO4=;
        b=srEXDxkZsxxecehf5UGsyf0SwIu4ySgq80pQSsqvnZKeZzCfQxu4cnOu/St8R2bWCl
         aNTGz9wNDLgwcqz8edvKIaKMRnEhDPFsTNeJq/qzhWpc/Ub5PfBJyHp5cLZKY6SZGKNG
         GbvRuKIg5L0n8/K2p7t0Pnv2lQoztPRIEHYIRIR+wqLVMGKaBka+7dVbced5eJFtnbDx
         Wo2WzAipdnBh+reCR4QbJY2VB1CQTLhFjzNVSXOi6aZVfTsFXO/2XtC+WqiLxW7h0IN3
         kVeCTLGycFp/bUPxvymJCaOM9uOGJA/RfR7Ckb1kLJZ5QKuIcksHDHG9uixi38H88PBX
         OzuA==
X-Gm-Message-State: APjAAAVxB5RcW4MnQPYvv2l0QsoyMeWroUpg4vwodeeLprdjbgoQSkGF
	rNbr38B0T49IuZy+2y6Y0ZTKufPUgvY7v4cPLts3Ot+MvtTbgUH9r6YH2m6rBBeq4rhgcuFRWFX
	cRxmoWskiZfx+eWXIxlMERPxcSKFCSXst3UWxsUISzlQcEI8QzByLYdw5PALBw2bgDQ==
X-Received: by 2002:a81:3358:: with SMTP id z85mr29873227ywz.251.1559951581082;
        Fri, 07 Jun 2019 16:53:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysRtbYN6AJwH96poSSizVU9dAzcGyEJF9uKCdH1jaSsZReEWTL6croytPEgC6MJzZWn1bO
X-Received: by 2002:a81:3358:: with SMTP id z85mr29873202ywz.251.1559951579961;
        Fri, 07 Jun 2019 16:52:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559951579; cv=none;
        d=google.com; s=arc-20160816;
        b=LwttBkFV38YuWHKDKOUIWx/Hnf3Dv2Ss5aTaB79RxvKzhms5QKaaldH60r+vk07wYv
         MG0q99W9xzq+JN242Gt+ISwGYOrYE4xcFb68lgFfkCCWEr06U0DwlnHqjneRmNB14mBp
         VvIT9UwTrLdyUl5zrAdI3/mYvubVO9v0mpuUdXpkSyjbLudhEtgXxqvsm0m6Ka0ErWip
         Z2yi7JYrpTTHw8OHxDm7L1xq6sSxdrVdRrA41sFQ+npcROPOM1Gakob1Kwrr8KeYMsmW
         GIUjGSaIujOiOUJNuZsNzWp9zZpK3DjQ7oglXb1T9Rlhre4MPKuOJv1HrG1BXPDFRRyD
         ue9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=oyJdY8/VhzNnR6cpDJoWJYEsLy7XDJAJOH2xjhGeCO4=;
        b=nJNGghqFVumrcdhUdTybdrgS1kxUMm0NjEMUQImF/mJj6X8vGsjIrslZ9WrRZi9QUG
         zlvrOciWSjc2RmGk3x+SavYvJc70afz+XM1z3Li60gZvx2gFGllGlx4dvz4YOJrcX+8F
         MphyIhCLKAi3edgWy8DYqePzCXzUTatGoJ6XtMYs/vZ/sbUI8hZjjEt5f/BsOIPU6J83
         PAPK6w8cIxJ0s1i9kVux5ciN8zclZmRNDUkUP67u9C1gH7gRnhAv769Q0cOENF4T2DM5
         AYHeZVudXqHXGSDIU7vkU9tlvO4sliT+qG8qyKcTec6FqtnFpJQzuqxTxvDDiSpWjgHy
         29Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="G/Z0t5HE";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s124si1053076ywg.366.2019.06.07.16.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 16:52:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="G/Z0t5HE";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfaf8cb0000>; Fri, 07 Jun 2019 16:52:43 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 16:52:58 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 07 Jun 2019 16:52:58 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 23:52:58 +0000
Subject: Re: [PATCH v2 12/11] mm/hmm: Fix error flows in
 hmm_invalidate_range_start
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190607160557.GA335@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <439b5731-0b7e-b25b-ce1a-74b34e1f9bf5@nvidia.com>
Date: Fri, 7 Jun 2019 16:52:58 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190607160557.GA335@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559951563; bh=oyJdY8/VhzNnR6cpDJoWJYEsLy7XDJAJOH2xjhGeCO4=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=G/Z0t5HEQ6C1+U2SZjj5SN/sSer+cDD1UL4TuTLJ2P6MF0NezvSg4pBAahKGVh1UL
	 AkLHcjooJisyBg3Hh6kbnM4co750jdDmvlfvtPXP3paDIbkBHEiMlCjuLxr3z0VpRs
	 S4aqZvDlPJE5eAvnXsp1lVpx5SnpO66ah+fyUFVhEwWKZaFfhDtFJ9iTpc4hTwz1aF
	 EhbY03cRzKrGcAmuiC2N2KnJAS9GGlmmtOAYAR6uMyxAx8xVn5VT1/ge2eBcr0CJHk
	 x+NnvwHEEm4q5WcEsGiLiFfsI1WnNcZv6qNMyvlfhwIeinLTWlCvEOIjnZeb1V1v1P
	 0H/z/AX0HrfXA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/7/19 9:05 AM, Jason Gunthorpe wrote:
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

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   include/linux/hmm.h |  2 +-
>   mm/hmm.c            | 77 +++++++++++++++++++++++++++------------------
>   2 files changed, 48 insertions(+), 31 deletions(-)
> 
> I almost lost this patch - it is part of the series, hasn't been
> posted before, and wasn't sent with the rest, sorry.
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
> index 4215edf737ef5b..10103a24e9b7b3 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -68,7 +68,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>   	init_rwsem(&hmm->mirrors_sem);
>   	hmm->mmu_notifier.ops = NULL;
>   	INIT_LIST_HEAD(&hmm->ranges);
> -	mutex_init(&hmm->lock);
> +	spin_lock_init(&hmm->ranges_lock);
>   	kref_init(&hmm->kref);
>   	hmm->notifiers = 0;
>   	hmm->mm = mm;
> @@ -114,18 +114,19 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   {
>   	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>   	struct hmm_mirror *mirror;
> +	unsigned long flags;
>   
>   	/* Bail out if hmm is in the process of being freed */
>   	if (!kref_get_unless_zero(&hmm->kref))
>   		return;
>   
> -	mutex_lock(&hmm->lock);
> +	spin_lock_irqsave(&hmm->ranges_lock, flags);
>   	/*
>   	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
>   	 * prevented as long as a range exists.
>   	 */
>   	WARN_ON(!list_empty(&hmm->ranges));
> -	mutex_unlock(&hmm->lock);
> +	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
>   
>   	down_read(&hmm->mirrors_sem);
>   	list_for_each_entry(mirror, &hmm->mirrors, list) {
> @@ -141,6 +142,23 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   	hmm_put(hmm);
>   }
>   
> +static void notifiers_decrement(struct hmm *hmm)
> +{
> +	lockdep_assert_held(&hmm->ranges_lock);
> +
> +	hmm->notifiers--;
> +	if (!hmm->notifiers) {
> +		struct hmm_range *range;
> +
> +		list_for_each_entry(range, &hmm->ranges, list) {
> +			if (range->valid)
> +				continue;
> +			range->valid = true;
> +		}

This just effectively sets all ranges to valid.
I'm not sure that is best.
Shouldn't hmm_range_register() start with range.valid = true and
then hmm_invalidate_range_start() set affected ranges to false?
Then this becomes just wake_up_all() if --notifiers == 0 and
hmm_range_wait_until_valid() should wait for notifiers == 0.
Otherwise, range.valid doesn't really mean it's valid.

> +		wake_up_all(&hmm->wq);
> +	}
> +}
> +
>   static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   			const struct mmu_notifier_range *nrange)
>   {
> @@ -148,6 +166,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   	struct hmm_mirror *mirror;
>   	struct hmm_update update;
>   	struct hmm_range *range;
> +	unsigned long flags;
>   	int ret = 0;
>   
>   	if (!kref_get_unless_zero(&hmm->kref))
> @@ -158,12 +177,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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
> @@ -171,7 +185,7 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   
>   		range->valid = false;
>   	}
> -	mutex_unlock(&hmm->lock);
> +	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
>   
>   	if (mmu_notifier_range_blockable(nrange))
>   		down_read(&hmm->mirrors_sem);
> @@ -179,16 +193,26 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
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
> @@ -197,23 +221,14 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
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
> @@ -866,6 +881,7 @@ int hmm_range_register(struct hmm_range *range,
>   {
>   	unsigned long mask = ((1UL << page_shift) - 1UL);
>   	struct hmm *hmm = mirror->hmm;
> +	unsigned long flags;
>   
>   	range->valid = false;
>   	range->hmm = NULL;
> @@ -887,7 +903,7 @@ int hmm_range_register(struct hmm_range *range,
>   	kref_get(&hmm->kref);
>   
>   	/* Initialize range to track CPU page table updates. */
> -	mutex_lock(&hmm->lock);
> +	spin_lock_irqsave(&hmm->ranges_lock, flags);
>   
>   	range->hmm = hmm;
>   	list_add(&range->list, &hmm->ranges);
> @@ -898,7 +914,7 @@ int hmm_range_register(struct hmm_range *range,
>   	 */
>   	if (!hmm->notifiers)
>   		range->valid = true;
> -	mutex_unlock(&hmm->lock);
> +	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
>   
>   	return 0;
>   }
> @@ -914,13 +930,14 @@ EXPORT_SYMBOL(hmm_range_register);
>   void hmm_range_unregister(struct hmm_range *range)
>   {
>   	struct hmm *hmm = range->hmm;
> +	unsigned long flags;
>   
>   	if (WARN_ON(range->end <= range->start))
>   		return;
>   
> -	mutex_lock(&hmm->lock);
> +	spin_lock_irqsave(&hmm->ranges_lock, flags);
>   	list_del(&range->list);
> -	mutex_unlock(&hmm->lock);
> +	spin_unlock_irqrestore(&hmm->ranges_lock, flags);
>   
>   	/* Drop reference taken by hmm_range_register() */
>   	range->valid = false;
> 

