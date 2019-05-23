Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05D42C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 23:38:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8302C2133D
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 23:38:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="mD5Bb1lj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8302C2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDF236B0005; Thu, 23 May 2019 19:38:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E90476B0006; Thu, 23 May 2019 19:38:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D56746B0007; Thu, 23 May 2019 19:38:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B06C86B0005
	for <linux-mm@kvack.org>; Thu, 23 May 2019 19:38:36 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b81so6886886ywc.8
        for <linux-mm@kvack.org>; Thu, 23 May 2019 16:38:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=b2p6msGZOO1o6S/1xXYAPaJstC2ds8NUPA6vMi5IZfQ=;
        b=biR+eOZi/Ubiubg3RFqAhsVjzZx4WkqUpr6z3Zo54tPbQtEZ4+WM3bqARHEw3T4Wk9
         JeC99YTfR47D6fSw3KowXuq2wk01I5nmsxnMwsHNl+8hDIBfKsgaG/wf5vPl5bNVxhTN
         9b5fujV4VSsEi82u4iGJ/JTrIsZ+2qDwAdI4/iQL2np88XNDojDPSB05ZP9mCZlGlpzf
         l2Zn20XOnJkBxLvfqc9+m0V5C4ga0GjZfkB7+KJXUpxLJrKymk/Ze/5FG7InofwyhSfx
         BJYGAidIYbGlvbiBMCs3/ZcKzxXUcwFptyFjx8qAsQqfrKPJiXCaIRDf86vks61jCAYv
         uvag==
X-Gm-Message-State: APjAAAXkp2iM69d+KYy8vbGjmQgptYbhgmiVpOluyuWUU2S2yA8pUiop
	U0EoCh9hDy1PYT/po6vqLk6r6/dmrEZnTOMT+SllAyKnR150OdovwmkX+I1WZ76tcH2DJoYN9ys
	l3c7PSKlk1XmYs5/txox+6rFH1x2rGZ3hEJ1bLvskmlbuY5tMzQv5bDl/IzB1YcFWCw==
X-Received: by 2002:a25:cc51:: with SMTP id l78mr21485829ybf.215.1558654716411;
        Thu, 23 May 2019 16:38:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/BejNxOMDVtMuJrI63Uk7l6+ZTogbo1TOKIv3NAeTuxGL6gxzGFI5epAXAjYin93wbW0+
X-Received: by 2002:a25:cc51:: with SMTP id l78mr21485792ybf.215.1558654715381;
        Thu, 23 May 2019 16:38:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558654715; cv=none;
        d=google.com; s=arc-20160816;
        b=QNio0iCcPRGKYCETijwd7GLVxCGDGuZuxHFBpQvDqFCE4EwcUkAnL1Zh0QZgrflMLS
         yZ8JCYsOHtcHu7sTle7UJFxQJYsv2HX6FCru+xIa58a5OomHC9OrQgm14WJvw/Vk9Ncm
         2TkuV7vrLQdNjU/wVvbhEA9to/KmaNzvbET5riOoixyVZhtyaTENWgfwLk53xfEokp5/
         968ZFeFhTPIXAn2byir9tyLYO1cBsXqs3WzUsD+A9ih9T48w43q+7fPqKxqSk2luE4OP
         TtpviGP6CL7XuRssjRkuZRbUtwn59mQdOKQcqltWh0wo01KWbVooj/2iYJL+rPkIrBx+
         Bjtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=b2p6msGZOO1o6S/1xXYAPaJstC2ds8NUPA6vMi5IZfQ=;
        b=gNhi++ou0QJpdcD4QGa8E6AXT0m13LvFS8Y6rf+6VBWLN1FN8yILm3gY3twEbH6wtn
         iIHMcJ361Fwpmayaw1L/CK1oq7u8i9us8B8OaSWxgCMQY2EdYqeX97W+zw9Ws02J6Okq
         uw1i2cInyb78n7l8RZ6xLyI11abX9p1FFc1hsvU4YkkjPGKUYVpNLrHZ0DMMxk/AxeF1
         lE24dwalkWXAsUkRAqj8tVFx87SAuBW0z0r4XFG2IYSfhH89AH8XjJsyICcvcOp/h5Ne
         lLMt9GW6tATPDtykFMWHvhyiPYaFFlFr62CyzRHRtdvcetGpJnvqu7h9Xbo+pfZ6VE46
         bMgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=mD5Bb1lj;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id f125si283216ybg.28.2019.05.23.16.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 16:38:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=mD5Bb1lj;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce72efa0000>; Thu, 23 May 2019 16:38:34 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 23 May 2019 16:38:34 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 23 May 2019 16:38:34 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 23 May
 2019 23:38:28 +0000
Subject: Re: [RFC PATCH 04/11] mm/hmm: Simplify hmm_get_or_create and make it
 reliable
To: Jason Gunthorpe <jgg@ziepe.ca>, <linux-rdma@vger.kernel.org>,
	<linux-mm@kvack.org>, Jerome Glisse <jglisse@redhat.com>, John Hubbard
	<jhubbard@nvidia.com>
CC: Jason Gunthorpe <jgg@mellanox.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-5-jgg@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <6945b6c9-338a-54e6-64df-2590d536910a@nvidia.com>
Date: Thu, 23 May 2019 16:38:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190523153436.19102-5-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558654714; bh=b2p6msGZOO1o6S/1xXYAPaJstC2ds8NUPA6vMi5IZfQ=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=mD5Bb1ljRlQVnOXf6N0+Gn9PipOahIO4xwqqHApUTi/EQT0VsA0WHW2c+jZ+K/Ivv
	 kbjwUw3D5GzhyV8DdOOjCYiBzzfpCingWfKO4uAbnhG4W7uhia7Ct2QqYZZMn7inO/
	 M0rvAfHN0iWUHpU8LCbyNsafRXJjPqMO/ri8AmZgMRJKDwg4w7mgYlG9pr3UpvrjxD
	 nvomTrVL/nhavUBfbEkKcqhg3sth0el6LVCvn3gqK8ucxmI1xVERb7evMyEIV0WYrj
	 RxkbiMWNNyNOHxc99Caepn8sfrDO7xtk3xIy3yDNJBfpxIsNh08cFSYqM6peYzPjJR
	 US6/8Q6ULMK1g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/23/19 8:34 AM, Jason Gunthorpe wrote:
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
>   mm/hmm.c | 75 ++++++++++++++++++++------------------------------------
>   1 file changed, 27 insertions(+), 48 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index e27058e92508b9..ec54be54d81135 100644
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
> +	lockdep_assert_held_exclusive(mm->mmap_sem);
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

Shouldn't there be a "return NULL;" here so it doesn't fall through and
allocate a struct hmm below?

> +	}
>   
>   	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
>   	if (!hmm)
> @@ -85,54 +84,34 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>   	hmm->mm = mm;
>   	mmgrab(hmm->mm);
>   
> -	spin_lock(&mm->page_table_lock);
> -	if (!mm->hmm)
> -		mm->hmm = hmm;
> -	else
> -		cleanup = true;
> -	spin_unlock(&mm->page_table_lock);
> -
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
> +	mm->hmm = hmm;
>   	return hmm;
> -
> -error_mm:
> -	spin_lock(&mm->page_table_lock);
> -	if (mm->hmm == hmm)
> -		mm->hmm = NULL;
> -	spin_unlock(&mm->page_table_lock);
> -error:
> -	kfree(hmm);
> -	return NULL;
>   }
>   
>   static void hmm_fee_rcu(struct rcu_head *rcu)

I see Jerome already saw and named this hmm_free_rcu()
which I agree with.

>   {
> +	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
> +
> +	down_write(&hmm->mm->mmap_sem);
> +	if (hmm->mm->hmm == hmm)
> +		hmm->mm->hmm = NULL;
> +	up_write(&hmm->mm->mmap_sem);
> +	mmdrop(hmm->mm);
> +
>   	kfree(container_of(rcu, struct hmm, rcu));
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
>   	mmu_notifier_call_srcu(&hmm->rcu, hmm_fee_rcu);
>   }
>   
> 

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------

