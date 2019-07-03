Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 427C9C06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:49:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E889F218A4
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Ay8VbsRT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E889F218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E937D6B000D; Wed,  3 Jul 2019 13:48:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E43E58E000D; Wed,  3 Jul 2019 13:48:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0B578E0001; Wed,  3 Jul 2019 13:48:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A93296B000D
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 13:48:59 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t196so4041745qke.0
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 10:48:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=eH+hzh0l+0B3OvYJxCh+IGNb5c8I2ai/DLR8P5b1Gdg=;
        b=Z96Z4/tft44C0OMv1e5MZTKwm+jeZ4a8emZGZLUPbFUO58eZizOcApSmWLZ2+nGvcM
         6u6VPPYo8ewIboEbF5Q9Nlg2e/OjXbdJUxYcbKEp84UrJpRaPq30CJNUeGz8qNcI0Rw4
         +DuX+y9cP8OOMFf89s8GZ9OIaK6mWchecumjqpWjIImPe6PC9G0UnqhqjVdsSkJciNjF
         C82IA2/zKygMDJKhfBkFZmWh1KPrHdD7sST+H9C2iEppnvMOfLYeW0QPf+Sdu+cD/x/2
         hskG0PNABnrHHdkLLKDZ/5+H288megg2+VkdgzN+r7XxLImqWM/ttHctsJxzWuG2Ww9v
         3Udg==
X-Gm-Message-State: APjAAAXCqfp8IQZQc0Eo8mgK4lF8bcAKkPt+q92VPLw60VbwbRQT8zq5
	MsHLAYJubl1Z9CvIxr8UD2W1hK6qcEvZEoa6I8ZnUsDvFMlqv3RFtjojtXGl1yZwPAWrvoNPaC1
	qV0fDrF9oZwJUdYWROrOIYfy+L6Twkjt0xDDqSRY+WJ6AVX/iR+T4V/vDQykke91n7g==
X-Received: by 2002:a25:3a01:: with SMTP id h1mr23921085yba.311.1562176139390;
        Wed, 03 Jul 2019 10:48:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDFNfHjaXoVzwEUkJSho9iTyKfks+E/xqfb47wjDYDM9t7LmFDFR0nKRZb9V2GnB12YgX0
X-Received: by 2002:a25:3a01:: with SMTP id h1mr23921045yba.311.1562176138609;
        Wed, 03 Jul 2019 10:48:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562176138; cv=none;
        d=google.com; s=arc-20160816;
        b=JZZcVcFe2aVbKAKwNkuns+AlRgRIOBxokyGvI9lUp8svx0TBn2SY7xqiqd8REvgye4
         Swj4UOLh3gsSXyHkQ8cto3++WLpOLwDVK++06LdboEuFJxqtSLIIf7+Z5E7gJmC6ZXzb
         Xz7tyAJfHaWz6Ovig3URTOEXfa6eelVhPbaIBzyIgtB1Iufm53+u2uPLVOcRPmgEYZ3b
         XffcanzhDPsam9E/hJ7MCDJJ5XDBCD6x3sJ9liDxv9oH8AzlBNC9MqL4poVbF9txLTFI
         j6oMTjUHROd5pnI57f56Ifs9v8F0+5Ws+JNY3msDLXTWfzJ/EZRjG3q/WYr2TVscrKxW
         9aYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=eH+hzh0l+0B3OvYJxCh+IGNb5c8I2ai/DLR8P5b1Gdg=;
        b=meMA/KNQW40xlR/CqCSlk9X3cWfksZsiNjf0RyUkGsrNLi2TTljRrxhaD2j/lTL+1a
         dCObkN6u7Qgbkwv69IxtdZ1QCAGPs65rFKSLyjXLLhm/4A1dBL2azIpS7ETpXAqXXKTV
         +K2NxHXpEHx1kYEXPnJbc0ELZZK7iqyGB6B24ROZ7HUL/PgxFVmDiLvjZkql+khd3kXC
         c9P+qbJbRjkbO0QfPXHwFI2xK8IUgg5CyzlgFm2j1zL2iM/eqrKo3dt60or3r0TjL18r
         jKnJ/WMuwx67PCNsjG5hRHOrniI18XHdGbopdLtKNUdliru+o1Cn9xsUWmEPHTUoXkuR
         W2+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Ay8VbsRT;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d67si1377582ywf.407.2019.07.03.10.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 10:48:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Ay8VbsRT;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d1cea8d0000>; Wed, 03 Jul 2019 10:49:01 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 03 Jul 2019 10:48:57 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 03 Jul 2019 10:48:57 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 3 Jul
 2019 17:48:56 +0000
Subject: Re: [PATCH 20/22] mm: move hmm_vma_fault to nouveau
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: Ira Weiny <ira.weiny@intel.com>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-nvdimm@lists.01.org>, <linux-pci@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
References: <20190701062020.19239-1-hch@lst.de>
 <20190701062020.19239-21-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <a3108540-e431-2513-650e-3bb143f7f161@nvidia.com>
Date: Wed, 3 Jul 2019 10:48:56 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190701062020.19239-21-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1562176141; bh=eH+hzh0l+0B3OvYJxCh+IGNb5c8I2ai/DLR8P5b1Gdg=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Ay8VbsRTZTawUVfdzioIYIEAkcetDCOkhbNxdQJcvtz4stk7arryEenoHujt1/2Jo
	 9qabL8azIqOiMeLK/MmV2RdioTWJ7NHHpyYSja96yymhsq5pBbZbq97MIq3te+bAon
	 bs/Y/N0PPXMcy80SSaxbmJfYk6pMoQA8kkl1Ls1aRu5u632sW+H7HBlI5Pggo5kNhJ
	 Z5Ye/IWvj2SfBBlM/ouo9ZRmRqtA5+sXZVvBCZwaDotWg8dOVc5/PjPHQVSEz7m+w2
	 xG3ZCO20Q1WNDTk3PwLykbGWuLgysV2ZM43Fuxe3QHUC/X7lOS7GHRSq7jkUakqGEU
	 +f5bFGz1+9oxA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/30/19 11:20 PM, Christoph Hellwig wrote:
> hmm_vma_fault is marked as a legacy API to get rid of, but quite suites
> the current nouvea flow.  Move it to the only user in preparation for

I didn't quite parse the phrase "quite suites the current nouvea flow."
s/nouvea/nouveau/

> fixing a locking bug involving caller and callee.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

I see where you are going with this and it
looks like straightforward code movement so,

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_svm.c | 54 ++++++++++++++++++++++++++-
>   include/linux/hmm.h                   | 54 ---------------------------
>   2 files changed, 53 insertions(+), 55 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
> index 9d40114d7949..e831f4184a17 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_svm.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
> @@ -36,6 +36,13 @@
>   #include <linux/sort.h>
>   #include <linux/hmm.h>
>   
> +/*
> + * When waiting for mmu notifiers we need some kind of time out otherwise we
> + * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
> + * wait already.
> + */
> +#define NOUVEAU_RANGE_FAULT_TIMEOUT 1000
> +
>   struct nouveau_svm {
>   	struct nouveau_drm *drm;
>   	struct mutex mutex;
> @@ -475,6 +482,51 @@ nouveau_svm_fault_cache(struct nouveau_svm *svm,
>   		fault->inst, fault->addr, fault->access);
>   }
>   
> +static int
> +nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
> +		    bool block)
> +{
> +	long ret;
> +
> +	/*
> +	 * With the old API the driver must set each individual entries with
> +	 * the requested flags (valid, write, ...). So here we set the mask to
> +	 * keep intact the entries provided by the driver and zero out the
> +	 * default_flags.
> +	 */
> +	range->default_flags = 0;
> +	range->pfn_flags_mask = -1UL;
> +
> +	ret = hmm_range_register(range, mirror,
> +				 range->start, range->end,
> +				 PAGE_SHIFT);
> +	if (ret)
> +		return (int)ret;
> +
> +	if (!hmm_range_wait_until_valid(range, NOUVEAU_RANGE_FAULT_TIMEOUT)) {
> +		/*
> +		 * The mmap_sem was taken by driver we release it here and
> +		 * returns -EAGAIN which correspond to mmap_sem have been
> +		 * drop in the old API.
> +		 */
> +		up_read(&range->vma->vm_mm->mmap_sem);
> +		return -EAGAIN;
> +	}
> +
> +	ret = hmm_range_fault(range, block);
> +	if (ret <= 0) {
> +		if (ret == -EBUSY || !ret) {
> +			/* Same as above, drop mmap_sem to match old API. */
> +			up_read(&range->vma->vm_mm->mmap_sem);
> +			ret = -EBUSY;
> +		} else if (ret == -EAGAIN)
> +			ret = -EBUSY;
> +		hmm_range_unregister(range);
> +		return ret;
> +	}
> +	return 0;
> +}
> +
>   static int
>   nouveau_svm_fault(struct nvif_notify *notify)
>   {
> @@ -649,7 +701,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
>   		range.values = nouveau_svm_pfn_values;
>   		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
>   again:
> -		ret = hmm_vma_fault(&svmm->mirror, &range, true);
> +		ret = nouveau_range_fault(&svmm->mirror, &range, true);
>   		if (ret == 0) {
>   			mutex_lock(&svmm->mutex);
>   			if (!hmm_range_unregister(&range)) {
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 4b185d286c3b..3457cf9182e5 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -478,60 +478,6 @@ long hmm_range_dma_unmap(struct hmm_range *range,
>   			 dma_addr_t *daddrs,
>   			 bool dirty);
>   
> -/*
> - * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
> - *
> - * When waiting for mmu notifiers we need some kind of time out otherwise we
> - * could potentialy wait for ever, 1000ms ie 1s sounds like a long time to
> - * wait already.
> - */
> -#define HMM_RANGE_DEFAULT_TIMEOUT 1000
> -
> -/* This is a temporary helper to avoid merge conflict between trees. */
> -static inline int hmm_vma_fault(struct hmm_mirror *mirror,
> -				struct hmm_range *range, bool block)
> -{
> -	long ret;
> -
> -	/*
> -	 * With the old API the driver must set each individual entries with
> -	 * the requested flags (valid, write, ...). So here we set the mask to
> -	 * keep intact the entries provided by the driver and zero out the
> -	 * default_flags.
> -	 */
> -	range->default_flags = 0;
> -	range->pfn_flags_mask = -1UL;
> -
> -	ret = hmm_range_register(range, mirror,
> -				 range->start, range->end,
> -				 PAGE_SHIFT);
> -	if (ret)
> -		return (int)ret;
> -
> -	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> -		/*
> -		 * The mmap_sem was taken by driver we release it here and
> -		 * returns -EAGAIN which correspond to mmap_sem have been
> -		 * drop in the old API.
> -		 */
> -		up_read(&range->vma->vm_mm->mmap_sem);
> -		return -EAGAIN;
> -	}
> -
> -	ret = hmm_range_fault(range, block);
> -	if (ret <= 0) {
> -		if (ret == -EBUSY || !ret) {
> -			/* Same as above, drop mmap_sem to match old API. */
> -			up_read(&range->vma->vm_mm->mmap_sem);
> -			ret = -EBUSY;
> -		} else if (ret == -EAGAIN)
> -			ret = -EBUSY;
> -		hmm_range_unregister(range);
> -		return ret;
> -	}
> -	return 0;
> -}
> -
>   /* Below are for HMM internal use only! Not to be used by device driver! */
>   static inline void hmm_mm_init(struct mm_struct *mm)
>   {
> 

