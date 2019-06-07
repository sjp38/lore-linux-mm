Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB917C28EBD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:54:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 566B3206DF
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:54:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="VAlAdXP/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 566B3206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEA7C6B029D; Thu,  6 Jun 2019 22:54:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9AB56B02DD; Thu,  6 Jun 2019 22:54:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB1036B02FB; Thu,  6 Jun 2019 22:54:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94CC56B029D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 22:54:42 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id v4so151139oia.13
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 19:54:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=3huOKZv8HXfSbCtVJDMPY1F6+DxRnSCZ3RkJ5zBunYk=;
        b=ntNYVAAWDWoqgtpAjj1NpC4C6wZl74z4w/AXNe/MYEcBOH+T7MPzujG/IK805LYXJ7
         NgBSw5BLlljwDRRLdB+RP5yE5xpcRqacVK/5jVH1y30GUg3MjzX1s2rD9aeNc63S6i8q
         TrQTrfIdHOOeBNTx9wyq03YqZsEvv+mNzktJ3fqbm+alHIgb57yp6IWIhGW0FE+wVqeF
         u9eI72g47aZedNDU/bRv/xLMl+NuMsRPXrNAycgqI3aKEzQ2Ca4DM/IQtEvtNtVcUatU
         X2eIBMcDRijOPgTphAIBUejPBV4uxl7uQwAuxQTxw9Uj8JFHNwAdUtkCdOdZ7qx2rW3w
         TQMw==
X-Gm-Message-State: APjAAAUbaXnfiruZ0BZ+s7fcxgiqBl4WMFq6aIehRgCIdcB9vRd9AzVH
	ToY0zCCuQ0WDd9OgHkKY4vua/OPhneASEbsqguRzoNQyY8duZqUzaexHBm6/iYri/ccVlg5daQW
	pLgPH+Y9P8QUFp2/vWJNyMcHN/cVNpZnrsDhIFlyDbES+upxvvmABXavAKOMwf+LLHQ==
X-Received: by 2002:a9d:640f:: with SMTP id h15mr18441859otl.338.1559876082319;
        Thu, 06 Jun 2019 19:54:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVrGV9C7hzfYkHUraHgOLdjaGt/+qMncMQYy+w6opqbrwUJvP3mBs9RXy2kijzRY94f8wS
X-Received: by 2002:a9d:640f:: with SMTP id h15mr18441827otl.338.1559876081541;
        Thu, 06 Jun 2019 19:54:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559876081; cv=none;
        d=google.com; s=arc-20160816;
        b=PRoJ+FQ46F4oSuICxFc3T9soRG8f3gv0Zd6ncErBEayPDmjF6p0rA4dWuwHHQv4pDx
         MrPsjk+++pBLcMzh2kiHFLlw9v0IWlCHJaaXmpbvvJbb4msMo/HLheA2Hd2ffx6s4P6e
         vZC+L9I15sa/DajPNseuPPCYt6XLdJhKnnZeGwawBhbFaMseGEgigUfICi7MXfGsOfxu
         Yp45S8juA5GEKtGjvcV8HMr4Yua3eLj4whI3rv57Xvtt0+kr023d73NcnSdn8JDedhxU
         HFwMm+r4NRZUqLqqh3sXb17i8u7BIWUWwUhQNdhRxlFL3o5Vs/SyD5C0rhyxhnUD/hmg
         rXpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=3huOKZv8HXfSbCtVJDMPY1F6+DxRnSCZ3RkJ5zBunYk=;
        b=WIAq6PckotSJEZz6rLyM73pttW5oiFo6cAut58oLDNz9E0SOGmiet4yQZyuZGUbXg2
         ozWgechOdvY1/qGfVWOTovWfJj02fZ/s4alfROz3N5yNbYxqORwr74stEDLkHIZ2Z3Kv
         w68Nf+SA39yG6KmAPYDtrYYupPOZyyHFTJkLDArVVoL3Bgu6OvqaqOXeVVmxcWpvExJE
         TZU94BHrjJmSvay6IZdaiYePzo3e7tHzMcPryc/o0wcwagTZDk4ES+UOZ827KZqivcg8
         25g1FqRl50PLYwM6DP3iS5RB1mH3KiXd5XvHr99e48e76GT2tofFCOO5//gLn6Jc6Irq
         iUhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="VAlAdXP/";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id x9si436951otb.201.2019.06.06.19.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 19:54:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="VAlAdXP/";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9d1df0000>; Thu, 06 Jun 2019 19:54:25 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 19:54:40 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 06 Jun 2019 19:54:40 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 02:54:34 +0000
Subject: Re: [PATCH v2 hmm 04/11] mm/hmm: Simplify hmm_get_or_create and make
 it reliable
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-5-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f02db2c8-8639-2142-bb1d-df33240e376c@nvidia.com>
Date: Thu, 6 Jun 2019 19:54:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-5-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559876066; bh=3huOKZv8HXfSbCtVJDMPY1F6+DxRnSCZ3RkJ5zBunYk=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=VAlAdXP/WVpIOzRKqOZX3nzrP9LNlYjaF6jw7eNfW115o3TuUHozNL7b6/KHHaB8s
	 wcjJXlYEc82ETwQGSetT3w5PLrLzdGK5DH8/MtZeqVnz8NiLSQTH8cIigI2+ZFf7oC
	 zzbPSf+EnlWzzpjD8iw+IujfhuihOEgfmMQdY6nnIJoFMdysXo//Z0Z1DbyQazuu/A
	 LOcBgzViceNSzbV6lMQX4DtVeQumKafO1rxrdA8+57JmvZv1rfOC80ArBgyGKGUtHr
	 93DBAhjbe1QCT6BsjcSnkJy6C9QQqCcliCytXT7tlXmLx+gIDkr/IhwP2dv5/MkvsA
	 Cy7uig1VG9zeg==
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
> ---
> v2:
> - Fix error unwind of mmgrab (Jerome)
> - Use hmm local instead of 2nd container_of (Jerome)
> ---
>  mm/hmm.c | 80 ++++++++++++++++++++------------------------------------
>  1 file changed, 29 insertions(+), 51 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index cc7c26fda3300e..dc30edad9a8a02 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -40,16 +40,6 @@
>  #if IS_ENABLED(CONFIG_HMM_MIRROR)
>  static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
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
>  /**
>   * hmm_get_or_create - register HMM against an mm (HMM internal)
>   *
> @@ -64,11 +54,20 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>   */
>  static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  {
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
>  	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
>  	if (!hmm)
> @@ -83,57 +82,36 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>  	hmm->notifiers = 0;
>  	hmm->dead = false;
>  	hmm->mm = mm;
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
>  	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
> -	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
> -		goto error_mm;
> +	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
> +		kfree(hmm);
> +		return NULL;
> +	}
>  
> +	mmgrab(hmm->mm);
> +	mm->hmm = hmm;
>  	return hmm;
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
>  }
>  
>  static void hmm_free_rcu(struct rcu_head *rcu)
>  {
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
>  }
>  
>  static void hmm_free(struct kref *kref)
>  {
>  	struct hmm *hmm = container_of(kref, struct hmm, kref);
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
>  	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
>  }
>  
> 

Yes.

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
-- 
John Hubbard
NVIDIA

