Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98704C468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:52:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A60320652
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:52:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="o3/Dw8k5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A60320652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 031CF6B0006; Fri,  7 Jun 2019 14:52:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F23FC6B000A; Fri,  7 Jun 2019 14:52:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEBE86B000C; Fri,  7 Jun 2019 14:52:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD8366B0006
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:52:39 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id n7so2812374ybk.7
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:52:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=JqPVjfnMUsVeriG51gkWP6yZJVSw9KGyEZqOWsZkh5s=;
        b=fd3qKt80rFS2VXDwGK+AI0OQYDkJkINP7jmo5CkFOC64k+6/7CQZ340UPz4Ai56mQc
         2eXKmCPI/j4LdejT2pQcDZ7Ny6HxANfj5zFwA5vekwuBX884YNdXS6TthoX16wwf8tHV
         0qQkGHpOgqRai2lMoCRUh7L0pQSIf+orG3/ihmNa4MWF1fOby2kdio30DhiuVRUqvIlm
         xa3K5slWNuHG6AQi9dmXZN5t5WCq91vUemk6sraIcXNaiLjBBFdyRZjZPa7TSiUmyuBI
         Z4/RCpk/VtPeCkp4FqEDl+1tdKAjJib11AAZHZQyON4US3EdQlgZlzxWpHnkWs40/0n7
         fbtQ==
X-Gm-Message-State: APjAAAUdC/yZsjLWFJO0FE4FBRR/RIPNXlDpLGAiZeBYZHekWwERZ6os
	bM/cC2U7jQY1sMOJ5b5L76PIeqZc0Iju9GoTeh6jSYu3ClbO9nAF8lKs/cW4TDA9gXZ0uDrW9vt
	2XFDKjZ3g5YkLXAfFWaCxvH4Vemq++A8yTickwUHSic1LBzam4vaxxu3nnB3+ftNYvA==
X-Received: by 2002:a25:ce05:: with SMTP id x5mr20473374ybe.339.1559933559485;
        Fri, 07 Jun 2019 11:52:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMYVgDPEFnHoWA4FbTUTEXn9RXvg04rjJvpMc8W3K1EeGbuMkYe+7lukdo4CwqfNdO35EB
X-Received: by 2002:a25:ce05:: with SMTP id x5mr20473344ybe.339.1559933558755;
        Fri, 07 Jun 2019 11:52:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559933558; cv=none;
        d=google.com; s=arc-20160816;
        b=hQxRQNFEUKbiXXdNIjFeDjhPYItWXqSRGf9h8F3agRsfm6gXT1uBkiB8tXoO+CJ8nz
         uEVcswFK/iK1NJ6bUBckRQ4YRB6XhMCf0n+d+PyVY75cxDoThPTddAyBZczsTSdjAayc
         lRhlBj8qr6wnQgLfm+peB8/lW0eV8fOgYQjwuL9UypDemGzsqPe59fXmhUL5zd5vIbtH
         2M2KCUg5seipvQASdJZDmBQC75QT4w4V8xFx5tAbYtw7f6L3O7eFeYKwipsNuYkmZGeP
         D0GEu4fAxozDTNmQ674Xlbbq73LUEdbXljlpfS5BLFALNkUSSXcVoVvcgf4r8zlW8yan
         ipwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=JqPVjfnMUsVeriG51gkWP6yZJVSw9KGyEZqOWsZkh5s=;
        b=UcDrZPuNEiXRbna0B5S615IIe5dJnHwoOHbfulm49oPFzWLElW3kvd6LlPjP/FBLQE
         fkShO3g2PzOVAqE7d4vRHXa8rIgjKY+mHNQyFCq0AIlFCpyX36gevhTWxIvPEYvXAvcz
         kawWmYL25z1AElqrP7fRRdhDTG2mz9leogkmBrJGISQjEXCG4JqsFRRGSHitFIho/lLZ
         CdGjyPnWoVtpH4Jja9srVPWigpdpUcmPA67v1JXjvHJQOd6VmomQevQjF2fi9cDj1s6t
         tcaCGKKz9XCXeURN3DTaSbi5oF4cMQHWHKLBCaomGhPD8F6pbAKTnFOAo7sL7Iou17FB
         x5Ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="o3/Dw8k5";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f76si496337ywb.226.2019.06.07.11.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 11:52:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="o3/Dw8k5";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfab2730000>; Fri, 07 Jun 2019 11:52:35 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 11:52:37 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 11:52:37 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 18:52:33 +0000
Subject: Re: [PATCH v2 hmm 04/11] mm/hmm: Simplify hmm_get_or_create and make
 it reliable
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-5-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <b4a65f1c-3c77-4d87-ef73-105a228ef5c5@nvidia.com>
Date: Fri, 7 Jun 2019 11:52:32 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-5-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559933555; bh=JqPVjfnMUsVeriG51gkWP6yZJVSw9KGyEZqOWsZkh5s=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=o3/Dw8k5XmUikUSMfkLR2Ul1W+S62I/WdXmLNUJUPldK6bbzIkRUXYmeVUKur2tk2
	 hRglFo1y61L9h+ML/qFrFBzlZlDUM6JlOgJpCsG3r6s9WEWXEfgT1glvkbOjZlKqjm
	 GE1lNjGpCideng6jNvECw+LuqNOBghJgxhxohC/SiemfE+Cd5+SeVW8/L90bgqv5/N
	 gdoay8YDSEOL7LQDzr4xYrLARW7Ve+n/eVSP9mk6HKh6mmn2JLgEggrUhXzxQ4P2uI
	 kYPKIYY6R/zyYKv/J0WRHRpC08/YADLNQQAEAjjEqo8sQf09L6FJF5RFB0CGoWQXMj
	 VAlrl2LTDd8qA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> As coded this function can false-fail in various racy situations. Make it
> reliable by running only under the write side of the mmap_sem and avoiding
> the false-failing compare/exchange pattern.
> 
> Also make the locking very easy to understand by only ever reading or
> writing mm->hmm while holding the write side of the mmap_sem.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
> v2:
> - Fix error unwind of mmgrab (Jerome)
> - Use hmm local instead of 2nd container_of (Jerome)
> ---
>   mm/hmm.c | 80 ++++++++++++++++++++------------------------------------
>   1 file changed, 29 insertions(+), 51 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index cc7c26fda3300e..dc30edad9a8a02 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -40,16 +40,6 @@
>   #if IS_ENABLED(CONFIG_HMM_MIRROR)
>   static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
>   
> -static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
> -{
> -	struct hmm *hmm = READ_ONCE(mm->hmm);
> -
> -	if (hmm && kref_get_unless_zero(&hmm->kref))
> -		return hmm;
> -
> -	return NULL;
> -}
> -
>   /**
>    * hmm_get_or_create - register HMM against an mm (HMM internal)
>    *
> @@ -64,11 +54,20 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>    */
>   static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>   {
> -	struct hmm *hmm = mm_get_hmm(mm);
> -	bool cleanup = false;
> +	struct hmm *hmm;
>   
> -	if (hmm)
> -		return hmm;
> +	lockdep_assert_held_exclusive(&mm->mmap_sem);
> +
> +	if (mm->hmm) {
> +		if (kref_get_unless_zero(&mm->hmm->kref))
> +			return mm->hmm;
> +		/*
> +		 * The hmm is being freed by some other CPU and is pending a
> +		 * RCU grace period, but this CPU can NULL now it since we
> +		 * have the mmap_sem.
> +		 */
> +		mm->hmm = NULL;
> +	}
>   
>   	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
>   	if (!hmm)
> @@ -83,57 +82,36 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>   	hmm->notifiers = 0;
>   	hmm->dead = false;
>   	hmm->mm = mm;
> -	mmgrab(hmm->mm);
> -
> -	spin_lock(&mm->page_table_lock);
> -	if (!mm->hmm)
> -		mm->hmm = hmm;
> -	else
> -		cleanup = true;
> -	spin_unlock(&mm->page_table_lock);
>   
> -	if (cleanup)
> -		goto error;
> -
> -	/*
> -	 * We should only get here if hold the mmap_sem in write mode ie on
> -	 * registration of first mirror through hmm_mirror_register()
> -	 */
>   	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
> -	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
> -		goto error_mm;
> +	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
> +		kfree(hmm);
> +		return NULL;
> +	}
>   
> +	mmgrab(hmm->mm);
> +	mm->hmm = hmm;
>   	return hmm;
> -
> -error_mm:
> -	spin_lock(&mm->page_table_lock);
> -	if (mm->hmm == hmm)
> -		mm->hmm = NULL;
> -	spin_unlock(&mm->page_table_lock);
> -error:
> -	mmdrop(hmm->mm);
> -	kfree(hmm);
> -	return NULL;
>   }
>   
>   static void hmm_free_rcu(struct rcu_head *rcu)
>   {
> -	kfree(container_of(rcu, struct hmm, rcu));
> +	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
> +
> +	down_write(&hmm->mm->mmap_sem);
> +	if (hmm->mm->hmm == hmm)
> +		hmm->mm->hmm = NULL;
> +	up_write(&hmm->mm->mmap_sem);
> +	mmdrop(hmm->mm);
> +
> +	kfree(hmm);
>   }
>   
>   static void hmm_free(struct kref *kref)
>   {
>   	struct hmm *hmm = container_of(kref, struct hmm, kref);
> -	struct mm_struct *mm = hmm->mm;
> -
> -	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
>   
> -	spin_lock(&mm->page_table_lock);
> -	if (mm->hmm == hmm)
> -		mm->hmm = NULL;
> -	spin_unlock(&mm->page_table_lock);
> -
> -	mmdrop(hmm->mm);
> +	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
>   	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
>   }
>   
> 

