Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B83CC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:12:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8C1A20868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:12:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="GwkD8xsC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8C1A20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 866D96B000A; Fri,  7 Jun 2019 14:12:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EFD36B000C; Fri,  7 Jun 2019 14:12:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68F1D6B000E; Fri,  7 Jun 2019 14:12:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 444006B000A
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:12:19 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id t141so2771361ywe.23
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:12:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=yvViGcleFu6fAY5Z1ueRI2Sd+W1uzOgNJahahekeWt4=;
        b=AeNUpdWdAJxTLEWdOEVWrsNyHiM7NQEQqePqwhPvBUQ+5xvK2oEBSFSpmrDogIxbTV
         uYvwj4Cvh1jcdZKkcGy1UfE0cksGLyRsLOCGgyZKxD6xUEJWlQ1zGe+uHbNzADVam7wR
         ENdwy3kjy/uMo9Ja54/kVV5pnwjSkChyrY52ej0Ex/a5E9soJfWjyGEA88a+1nKody0v
         4RkGN5nQhFNHs2DsKbq9QshDV1qemqyDA1SLHzlh3buwyHBBfeAyOsV+crExw/k57OnY
         t2F7OAwTMuww5Bofke4eXDM1zAwsosdCXmNfdsT/FLxCJ1xjtbYp3eSKF771otd4C3Bw
         LWzg==
X-Gm-Message-State: APjAAAWJWf9wWtlMbsaKlD+6fAwKWZ4gpk2Nz8EWz0XwsGsorSR9bzIU
	RCXytM6peSVmXhW8NbvdMaL6xrQ2ZmGPhHUJIQ8DIvQSidRMaGAH0dUoVVT4P1CTb4tUENINzmg
	/VyPf9e0BUerGabppzFHQbrahkeB7V45V9iuK3OplquMFYz81yukRSx9St0Zc2BnT+Q==
X-Received: by 2002:a81:6987:: with SMTP id e129mr24474186ywc.283.1559931139036;
        Fri, 07 Jun 2019 11:12:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzc5E5o8LBOsh03L4I2WFG7Vt5UYAHTBmp0Xge4eF0Wdrv1mUkWGn0IZFy5M+zmJ/DXGnd
X-Received: by 2002:a81:6987:: with SMTP id e129mr24474145ywc.283.1559931138271;
        Fri, 07 Jun 2019 11:12:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559931138; cv=none;
        d=google.com; s=arc-20160816;
        b=lbme1Kn21nqsnx06fX0eFARm5YE7GYXTgjE2eLSQrTS4kF45E3HylWd22XUl3kCCHt
         j7AjGXDRKO/6SrKN96siNDGOAK4xxkpDyTHZGj9vI8PITrp3UYyxgWJW1xpAmw2//tRK
         +mW2lfiAiw75ei0KjRznK8EZwg6iyLbeZH/aumyGyTpL7wWOfTpDVK7cG9TB4WKHwItD
         eBYlh1PwFhv++sYetJFNdzCRZ5qDOAxdbGTneNL3I9FIAFPGCIlvM0Kbutqv1yinAD0+
         AqY481YyhPsO1x57MjRYGxNg+1VIa/57hgNe2mdl6DA3KwAnz16aJaAmEVnMiJ9EYOp3
         c9iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=yvViGcleFu6fAY5Z1ueRI2Sd+W1uzOgNJahahekeWt4=;
        b=nM+kQ+w/Jgz6lAP+zTJW+y+afR4DuGk/ntkdn+FXR77z6BuRp48gyxlju/dO8d5KeI
         GfagqURBIYQwy4i/18I+UCTJG8Rwvkn9f609Y3UDZviKDd73ssbvaL2tLnfe4kq/9lR5
         mKutUJxZOHvV96z5czPbi+YKI8bfYovfzDiM5xR+h7aow5T99PyVNWVXYvUmtnyG1ptF
         c5Wo0nOawNAAQH/jwpePWEOh7oAQ39zq4/YbTlhopAYJiAxah/PCNWrUIMzeLSQYnTi5
         jwY+Lelqv34gmBoAukE7ZmbV+5tQsR9L1/E5G6vT1a0E4HDkTCr0no24Wh3IbBDMfcIo
         p+cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=GwkD8xsC;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id v2si976132ywg.387.2019.06.07.11.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 11:12:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=GwkD8xsC;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfaa8f10000>; Fri, 07 Jun 2019 11:12:02 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 11:12:17 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 07 Jun 2019 11:12:17 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 18:12:14 +0000
Subject: Re: [PATCH v2 hmm 01/11] mm/hmm: fix use after free with struct hmm
 in the mmu notifiers
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-2-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <377cadfa-180e-9a6a-49df-0c2c27ae6fb3@nvidia.com>
Date: Fri, 7 Jun 2019 11:12:14 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-2-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559931122; bh=yvViGcleFu6fAY5Z1ueRI2Sd+W1uzOgNJahahekeWt4=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=GwkD8xsCGHW0KQ7XDbv8wawHd+SJN+lRqrAQpT/q6IxU90uItm8+7KTvX+8unVVF7
	 Vz00qV1V8aOiQueD3BHPHHGFZQnANCqbwbnRRbBFwh3oJhF3aWr4/aVmfy0TkhKL+W
	 lmrPKNeaNFVPyriJVct/0VeUfyZ1MufFzoGvniQz+6lRXlnYRx5V3xeqPhkXlq2I54
	 ZO79+tNGlAT4Ihs91XWeiX8VLNCv226zJTLdk0nY1y9xEBj/6xZQqrOC13Y2hVUrI/
	 ZBcxJUBuG8iMwDX7QBnuTnYytNPULKEzM6tmkNK9OnPziujs0OLxsvUVUEuBUQVLdA
	 TOS8OF+mbpUPw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> mmu_notifier_unregister_no_release() is not a fence and the mmu_notifier
> system will continue to reference hmm->mn until the srcu grace period
> expires.
> 
> Resulting in use after free races like this:
> 
>           CPU0                                     CPU1
>                                                 __mmu_notifier_invalidate_range_start()
>                                                   srcu_read_lock
>                                                   hlist_for_each ()
>                                                     // mn == hmm->mn
> hmm_mirror_unregister()
>    hmm_put()
>      hmm_free()
>        mmu_notifier_unregister_no_release()
>           hlist_del_init_rcu(hmm-mn->list)
> 			                           mn->ops->invalidate_range_start(mn, range);
> 					             mm_get_hmm()
>        mm->hmm = NULL;
>        kfree(hmm)
>                                                       mutex_lock(&hmm->lock);
> 
> Use SRCU to kfree the hmm memory so that the notifiers can rely on hmm
> existing. Get the now-safe hmm struct through container_of and directly
> check kref_get_unless_zero to lock it against free.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

You can add
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
> v2:
> - Spell 'free' properly (Jerome/Ralph)
> ---
>   include/linux/hmm.h |  1 +
>   mm/hmm.c            | 25 +++++++++++++++++++------
>   2 files changed, 20 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 092f0234bfe917..688c5ca7068795 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -102,6 +102,7 @@ struct hmm {
>   	struct mmu_notifier	mmu_notifier;
>   	struct rw_semaphore	mirrors_sem;
>   	wait_queue_head_t	wq;
> +	struct rcu_head		rcu;
>   	long			notifiers;
>   	bool			dead;
>   };
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 8e7403f081f44a..547002f56a163d 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -113,6 +113,11 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>   	return NULL;
>   }
>   
> +static void hmm_free_rcu(struct rcu_head *rcu)
> +{
> +	kfree(container_of(rcu, struct hmm, rcu));
> +}
> +
>   static void hmm_free(struct kref *kref)
>   {
>   	struct hmm *hmm = container_of(kref, struct hmm, kref);
> @@ -125,7 +130,7 @@ static void hmm_free(struct kref *kref)
>   		mm->hmm = NULL;
>   	spin_unlock(&mm->page_table_lock);
>   
> -	kfree(hmm);
> +	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
>   }
>   
>   static inline void hmm_put(struct hmm *hmm)
> @@ -153,10 +158,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
>   
>   static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   {
> -	struct hmm *hmm = mm_get_hmm(mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>   	struct hmm_mirror *mirror;
>   	struct hmm_range *range;
>   
> +	/* hmm is in progress to free */
> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return;
> +
>   	/* Report this HMM as dying. */
>   	hmm->dead = true;
>   
> @@ -194,13 +203,15 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   			const struct mmu_notifier_range *nrange)
>   {
> -	struct hmm *hmm = mm_get_hmm(nrange->mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>   	struct hmm_mirror *mirror;
>   	struct hmm_update update;
>   	struct hmm_range *range;
>   	int ret = 0;
>   
> -	VM_BUG_ON(!hmm);
> +	/* hmm is in progress to free */
> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return 0;
>   
>   	update.start = nrange->start;
>   	update.end = nrange->end;
> @@ -245,9 +256,11 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   static void hmm_invalidate_range_end(struct mmu_notifier *mn,
>   			const struct mmu_notifier_range *nrange)
>   {
> -	struct hmm *hmm = mm_get_hmm(nrange->mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>   
> -	VM_BUG_ON(!hmm);
> +	/* hmm is in progress to free */
> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return;
>   
>   	mutex_lock(&hmm->lock);
>   	hmm->notifiers--;
> 

