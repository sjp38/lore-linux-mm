Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81F53C28EBD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:29:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45EE020825
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:29:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="E08PdBQW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45EE020825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9DE26B026E; Thu,  6 Jun 2019 22:29:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B28206B0303; Thu,  6 Jun 2019 22:29:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C6F46B0306; Thu,  6 Jun 2019 22:29:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6336B026E
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 22:29:15 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id b64so280322otc.3
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 19:29:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=R2R56MRPrIqjPZeEw7fbzIpQNK89LlEqC86AIWezMqg=;
        b=gkq+ihY4Gkdw29pwgOlG7pYDNTcgDXLlIEd4Ztve5yPPbKPqMUa2OiA6P09MJ6rmFV
         32j9wvlR7kYeinmmlEL3A1OpxInWtvUe5680o7TXpcqAkPQAYOjNfCyHy1XQ9jean16a
         haLb3mKuW7oY0pFDgsQVoSNfzlajVkuxgV2gJyevy0IkgcmwiKuT+0OZ4VLXbR92bEqT
         5bLFqedBdrQyJD/OyaN4xwPgiS3Jd6BE6EQYSko1SpAjGmdJPLMPFZKaMO8apYNSl4IQ
         4FllC1D3ZO2zwbqNYbcqYwL/7l6qx73qJ3ya5ok0eZaSFJ2kEJumM7HYoe4FZ3mz0aTm
         4ejA==
X-Gm-Message-State: APjAAAUM7Fwkw6sFL2rxTQYf8W3l0b/ucGjqOa9dtv8syk2ve3l0bFRQ
	CpPncKVIPw8hnRZ91UNQq8NN3FiNWID0xRmNOERKx5XZ7arB07utO8eecI9kr8OspwbJC9zoKN8
	jCb3dxxsV9VS9p2ZaJChPVUZZyJEkuPrPxqKQ0Ll6NWU2S8kwi45g85+tsQCMiOF3wA==
X-Received: by 2002:a9d:5d1a:: with SMTP id b26mr17949787oti.50.1559874555081;
        Thu, 06 Jun 2019 19:29:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpSC/WlyxcqD9v6wVy9b2Zj1c9AJ3WtA8PgSUQqCcFljUz2OaJZxNb/XUsMRWFsq6DhrZ/
X-Received: by 2002:a9d:5d1a:: with SMTP id b26mr17949754oti.50.1559874553935;
        Thu, 06 Jun 2019 19:29:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559874553; cv=none;
        d=google.com; s=arc-20160816;
        b=x669Hv67LgLgdDNK2LCew6KKyyiR9zo/K4NFbdQJXN8U1p/Ycrq0V7ZTllkMEt7hDu
         O8hxGhi/9jxJpBciu/urjJk848NbDwUeyshar9BpH3IU7tPTOszejQ2Hqs27PKjmA86B
         DfGQbZegIDpr7Ir2BpMClF00FyBYpeoZ+llllNd5ApetXJzDx7MKR/ZOTDUIKpjd2a/N
         EKR8ZieatYjQdLoLvtFt7nx6cpNcuJZLeOXQdwCw/COK6uPy/dqgfQQzFM4NJeO7Zmcw
         ExwCStE/yE6O1qbQPvXG4+329znZ/YCgXGm4XzwfIxJ1z0W++sy8GPWaw7GCu/kCWuc9
         jYkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=R2R56MRPrIqjPZeEw7fbzIpQNK89LlEqC86AIWezMqg=;
        b=uxqzmgTLHPq7U8iZwanriBnYGCT9YrjdSmrvoI5tsf7a8cD/gbqZ+7Y5oAFLElmWdu
         Q2tliwQoEsmU+56lhIaDqPa0l59FUQhPafsKm0s5cSsdWj0SLoRvvXpi1shbmuz93Zym
         2+A1Ofn+eFBRJlKjqctDyM/ToRPL3kgTZv8XsmiUqL8PrvENdjQgWpIimc6ArwsL3peJ
         lh02fo59BjnrcWIWkb+06rP+gvWO2phe26E0sxB8Ij86eOwm1R+HaeebXWNSMtrQuoIq
         4fA2cdou+XyCbhlvqXrsUvv6c2UDI5lqJvBmd8C8e16npZpSucV5LeJztWQ3hzN2cBNS
         pshg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=E08PdBQW;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id x24si423378otk.314.2019.06.06.19.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 19:29:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=E08PdBQW;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9cbf60000>; Thu, 06 Jun 2019 19:29:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 19:29:12 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 06 Jun 2019 19:29:12 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 02:29:09 +0000
Subject: Re: [PATCH v2 hmm 01/11] mm/hmm: fix use after free with struct hmm
 in the mmu notifiers
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-2-jgg@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <9c72d18d-2924-cb90-ea44-7cd4b10b5bc2@nvidia.com>
Date: Thu, 6 Jun 2019 19:29:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-2-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559874551; bh=R2R56MRPrIqjPZeEw7fbzIpQNK89LlEqC86AIWezMqg=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=E08PdBQW7QWns3XtneChNvM+k4Mj3Hpm1wXqD3gC80a5hnrfSkAEsTdHcVOcgJ3Yd
	 RStazpAX7nsLBehKZIY9KjtLbbYBPd7OAF3nseh/PvkL2ME60LVIFHybN8vj6Trf4U
	 dLwYzLYgYQU4rUtkBtix+3NPH4uSNsbVbyeM+7Wn1dWfOK1pt5v2MY4HDk+oyMmBP5
	 TUsaNSUmRSRUai6Q/fjo61dBOSS1erxVXoD5J/7LK+KN3HTQM8d74GteYBBe9oLAF1
	 3TRo7f7ZZTZMKXtoHKhN8D1sjWGzh/qBy8UCc7s9EMXW8gxwHDTHscWUr55x7x71m4
	 x+QGJnhZ6PhJQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
...
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 8e7403f081f44a..547002f56a163d 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
...
> @@ -125,7 +130,7 @@ static void hmm_free(struct kref *kref)
>  		mm->hmm = NULL;
>  	spin_unlock(&mm->page_table_lock);
>  
> -	kfree(hmm);
> +	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);


It occurred to me to wonder if it is best to use the MMU notifier's
instance of srcu, instead of creating a separate instance for HMM.
But this really does seem appropriate, since we are after all using
this to synchronize with MMU notifier callbacks. So, fine.


>  }
>  
>  static inline void hmm_put(struct hmm *hmm)
> @@ -153,10 +158,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
>  
>  static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
> -	struct hmm *hmm = mm_get_hmm(mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>  	struct hmm_mirror *mirror;
>  	struct hmm_range *range;
>  
> +	/* hmm is in progress to free */

Well, sometimes, yes. :)

Maybe this wording is clearer (if we need any comment at all):

	/* Bail out if hmm is in the process of being freed */

> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return;
> +
>  	/* Report this HMM as dying. */
>  	hmm->dead = true;
>  
> @@ -194,13 +203,15 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  			const struct mmu_notifier_range *nrange)
>  {
> -	struct hmm *hmm = mm_get_hmm(nrange->mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>  	struct hmm_mirror *mirror;
>  	struct hmm_update update;
>  	struct hmm_range *range;
>  	int ret = 0;
>  
> -	VM_BUG_ON(!hmm);
> +	/* hmm is in progress to free */

Same here.

> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return 0;
>  
>  	update.start = nrange->start;
>  	update.end = nrange->end;
> @@ -245,9 +256,11 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>  static void hmm_invalidate_range_end(struct mmu_notifier *mn,
>  			const struct mmu_notifier_range *nrange)
>  {
> -	struct hmm *hmm = mm_get_hmm(nrange->mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>  
> -	VM_BUG_ON(!hmm);
> +	/* hmm is in progress to free */

And here.

> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return;
>  
>  	mutex_lock(&hmm->lock);
>  	hmm->notifiers--;
> 

Elegant fix. Regardless of the above chatter I added, you can add:

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
-- 
John Hubbard
NVIDIA

