Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C50F7C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:25:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 732CC208E3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:24:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Jzl10aMI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 732CC208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D6996B000C; Fri,  7 Jun 2019 14:24:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 686796B000E; Fri,  7 Jun 2019 14:24:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 575A26B0266; Fri,  7 Jun 2019 14:24:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 39E876B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:24:49 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v15so2745053ybe.13
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:24:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=xt8hRcHzLeQkLBeS1/P3+kfd7HxoS8TOq54zYdn437c=;
        b=d8J7I0uABBb6BA0QHinYRXXScO/QQ1Cb2/O8a9bMLMtXnRxwuHn4z+O3/VDkPD6/3c
         pOGj1eUU8vH3UYQhene234Do+FQgNOccImgzUZsWXVdjh9+qC1dxo/X5/WTV/GofCpRN
         7Eg7wTmtp52zGRTreLE/zid6NFHE/+ZQNnS4dL9P0s1eIcSSGhYeAG2TsDZYTlzg+87M
         oJHuYqHr1mPnuIYyDj/RsqlYGivbAkYPnJZAgnRP+H+DzfYDSeeKibDR0afesh5Jq+yC
         VWaNhbRXmQDV5pMgw6Y42RbKtBEjRF85EaRLlK/jwmjxr+1RSEXqUubCmua9yeZWlMtN
         LTBQ==
X-Gm-Message-State: APjAAAXOhLb5nZ/vR3HHKIqeG/CHoLFTRgbZD9HwekTzLWJmLrXD0778
	t2Jcqamqb/tyrsb3AuaA2RsnPDG2J68Hq/SYxKoISxhnOWSK4u51feO7qgkL/W1GAKBs8rStfja
	YXB3i8LUzHwIK26ntgwOD7icLmp/VhQ8ce9y1guT46eIGy1Zq0HuesduJ0cch2sXIQg==
X-Received: by 2002:a25:cc0f:: with SMTP id l15mr17163788ybf.506.1559931889014;
        Fri, 07 Jun 2019 11:24:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGI3Wqj9gKemj3bspraDvj5AQufBeowxWfxr1rY301h9aaK5+5I2QHVboEXUC8jJGWyMXE
X-Received: by 2002:a25:cc0f:: with SMTP id l15mr17163752ybf.506.1559931888345;
        Fri, 07 Jun 2019 11:24:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559931888; cv=none;
        d=google.com; s=arc-20160816;
        b=bs68sCrraSCGKstvtdKHEFBlM3VyNAoxkmjrX58JuTr6Nz7fIMrnQbwvUwT0GefnST
         pqQCRqVIY0p4vjaaBEdtV78oeSATs5MTUuQiNUAHJPG+ziWxpWsP+nuCvpGl3LlXALno
         fwoIcmymgHf/aQF1YoZ7YgHdt0mD6RUwx2w++SgFSAwBuuUykTmZErSlOk4euR0RnAFf
         zaqihQZ//7D0oGDgFKTMkXA+PCNZfpYp7MURII+QIXuaC7tbKHa+Q8CZaexWhNv71p6N
         PAQdg+YruwRft0cB94Ff9HFS32RJ+uTMptv48MCNqDQaGlW4WV0MT4DOfKUquJ66gYYB
         YZMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=xt8hRcHzLeQkLBeS1/P3+kfd7HxoS8TOq54zYdn437c=;
        b=hReUR5JJfGxCQI29na4oxMfd67X+JoTwFSvpWuJB30cS75+j1BMkAFZwOePRihbK9P
         9auBejOdvleVTcvc8RyQIB4iJKYIyVbrX1NvfuGd5OiddaTsDZqlKbEXmHaI8SB14ZmF
         cEyzcv9ZgGg/I3wf/lIDdr6FkJYkTiHdn+p3rPWRsoQQltpQjevuZ+UFB5TRip9uy1aZ
         9LM36R6ti/mhkCxDTjedNAdvtiea5zMYdpsPO0Xa7uMFSnGoQ1AoJe0DxDgn9p4X8kxF
         RW4FfDj1F+9OireES1cEZgmO4dK4W2szySTaKaMDhy7Q+3kxk5nWyVzUxi86JyrcfNi0
         QKeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Jzl10aMI;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id o11si725151ywm.41.2019.06.07.11.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 11:24:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Jzl10aMI;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfaabef0000>; Fri, 07 Jun 2019 11:24:47 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 11:24:47 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 07 Jun 2019 11:24:47 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 18:24:44 +0000
Subject: Re: [PATCH v2 hmm 02/11] mm/hmm: Use hmm_mirror not mm as an argument
 for hmm_range_register
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-3-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <4a391bd4-287c-5f13-3bca-c6a46ff8d08c@nvidia.com>
Date: Fri, 7 Jun 2019 11:24:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-3-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559931887; bh=xt8hRcHzLeQkLBeS1/P3+kfd7HxoS8TOq54zYdn437c=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Jzl10aMIEyNyvMJQOea9/cem8BK3fdX7N7BBW39ZQ2ZTnhr3i9Bg45PYwohda1UY9
	 LkcU8MB8OKdUMSj8b6yUghIjjinGIugW4aSBllEIx7TVCfwzbApXGQL3P9ClD/AN2z
	 Yv3rNjAyUFe/mSLyYvWlzlYj8psKbq2qMRJzEB+cKi7ZRC9AQCwhtNhX/CDYSmifhd
	 OgQAo1Xs1VMOWXccxd1U6MRqnzkHVOsG3cy4I45UtG8jiXu1hu6emUv1Z1CwQxFrGP
	 /0qhySFwJdt1mao3BY0IXnmpWfz2Fu3UMQQ3D0H/L5X1ETwrAIQVgVzM8gB201RZnz
	 ZlKK89hwVr+aw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> Ralph observes that hmm_range_register() can only be called by a driver
> while a mirror is registered. Make this clear in the API by passing in the
> mirror structure as a parameter.
> 
> This also simplifies understanding the lifetime model for struct hmm, as
> the hmm pointer must be valid as part of a registered mirror so all we
> need in hmm_register_range() is a simple kref_get.
> 
> Suggested-by: Ralph Campbell <rcampbell@nvidia.com>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

You might CC Ben for the nouveau part.
CC: Ben Skeggs <bskeggs@redhat.com>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>


> ---
> v2
> - Include the oneline patch to nouveau_svm.c
> ---
>   drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
>   include/linux/hmm.h                   |  7 ++++---
>   mm/hmm.c                              | 15 ++++++---------
>   3 files changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
> index 93ed43c413f0bb..8c92374afcf227 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_svm.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
> @@ -649,7 +649,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
>   		range.values = nouveau_svm_pfn_values;
>   		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
>   again:
> -		ret = hmm_vma_fault(&range, true);
> +		ret = hmm_vma_fault(&svmm->mirror, &range, true);
>   		if (ret == 0) {
>   			mutex_lock(&svmm->mutex);
>   			if (!hmm_vma_range_done(&range)) {
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 688c5ca7068795..2d519797cb134a 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -505,7 +505,7 @@ static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
>    * Please see Documentation/vm/hmm.rst for how to use the range API.
>    */
>   int hmm_range_register(struct hmm_range *range,
> -		       struct mm_struct *mm,
> +		       struct hmm_mirror *mirror,
>   		       unsigned long start,
>   		       unsigned long end,
>   		       unsigned page_shift);
> @@ -541,7 +541,8 @@ static inline bool hmm_vma_range_done(struct hmm_range *range)
>   }
>   
>   /* This is a temporary helper to avoid merge conflict between trees. */
> -static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> +static inline int hmm_vma_fault(struct hmm_mirror *mirror,
> +				struct hmm_range *range, bool block)
>   {
>   	long ret;
>   
> @@ -554,7 +555,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>   	range->default_flags = 0;
>   	range->pfn_flags_mask = -1UL;
>   
> -	ret = hmm_range_register(range, range->vma->vm_mm,
> +	ret = hmm_range_register(range, mirror,
>   				 range->start, range->end,
>   				 PAGE_SHIFT);
>   	if (ret)
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 547002f56a163d..8796447299023c 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -925,13 +925,13 @@ static void hmm_pfns_clear(struct hmm_range *range,
>    * Track updates to the CPU page table see include/linux/hmm.h
>    */
>   int hmm_range_register(struct hmm_range *range,
> -		       struct mm_struct *mm,
> +		       struct hmm_mirror *mirror,
>   		       unsigned long start,
>   		       unsigned long end,
>   		       unsigned page_shift)
>   {
>   	unsigned long mask = ((1UL << page_shift) - 1UL);
> -	struct hmm *hmm;
> +	struct hmm *hmm = mirror->hmm;
>   
>   	range->valid = false;
>   	range->hmm = NULL;
> @@ -945,15 +945,12 @@ int hmm_range_register(struct hmm_range *range,
>   	range->start = start;
>   	range->end = end;
>   
> -	hmm = hmm_get_or_create(mm);
> -	if (!hmm)
> -		return -EFAULT;
> -
>   	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL || hmm->dead) {
> -		hmm_put(hmm);
> +	if (hmm->mm == NULL || hmm->dead)
>   		return -EFAULT;
> -	}
> +
> +	range->hmm = hmm;
> +	kref_get(&hmm->kref);
>   
>   	/* Initialize range to track CPU page table updates. */
>   	mutex_lock(&hmm->lock);
> 

