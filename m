Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6E60C28EBD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:36:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D445207E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:36:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Al0TXJZB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D445207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 334896B0306; Thu,  6 Jun 2019 22:36:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E5FD6B0308; Thu,  6 Jun 2019 22:36:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FAC16B0309; Thu,  6 Jun 2019 22:36:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9FFB6B0306
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 22:36:19 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id d204so145157oib.9
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 19:36:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=VS+EJuXcHOl/Y4VTDcHn1QB4ZCx6paXXC66trO1FQ50=;
        b=JN6NUSFVHByEaWpdt47Wv9au4sOOtBkS8guSgS+YjWsmywIXErfXFm1/aMhdU7pnZY
         3bzNUCRaOS51fFjfsgST1gGPlNqWVWRFkJjgsGtU80Sf29nhXZ1lAgWYNWS+9Z1X3H8t
         2BPCLmJq8S5YzSMmzBmuhfNqh6rtCdKHtOvxydLb3RpH0UErEw+eAYUBBN1+yco0svY+
         amzrIP1CmxwUQUhQ8jY0JTA0afLHQFh7VNpw9KVp89Fww7SZ1MS7Gmzj2wLQn7laSn/0
         x4i6EDa4jbc66oABdAYXSTnfzNmDCWfm7xPf/6URKukUsbHMsWl6clDcjyhfvvyC+3j3
         oxDA==
X-Gm-Message-State: APjAAAUgztO6XV7F8GE22Oq1wBn91oFD5RD7SDqKS6QBa9tIo6ypsLtD
	/EdR+JufAXkCe/7yUG8QbBUMRBP+0l1yg3HI60t3mRgi+YqcB9yAyWShsr2BL7EosMUpNKW+MCv
	76+C+MDQDaX41CJTFtJkoKuHbYWiBakydFf0QIvIl1kTcxqXvyNjW0ThixSW8I7MQtw==
X-Received: by 2002:a9d:62d9:: with SMTP id z25mr14858279otk.268.1559874979570;
        Thu, 06 Jun 2019 19:36:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwh5yfKNtt147ztDHTBZO2UrnPnL78hQyemlJLNBv1Ip0acomanKJHPobx3ViFrYeYwAr3T
X-Received: by 2002:a9d:62d9:: with SMTP id z25mr14858242otk.268.1559874978712;
        Thu, 06 Jun 2019 19:36:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559874978; cv=none;
        d=google.com; s=arc-20160816;
        b=iQvkKKO3lAbHTDZl7k2ck4iWpVppl+N/+pQjWTNnwEbRp/1qh6cs1T/BmnhruRnecv
         OHQlH8UPPsS4vDHkaq9nfoLwWyVRsOKIxhgVj/qK0DlAcPdF/7tl/0F2EY0pd/9wZpS0
         9NL6o//mfWDyqWeZ2En2RZBC7hT+v0skKc1iEIqMY8Fgq6lJNXu97Bud/gL2rERhjLA7
         YFDFrh4pJbHXPMG9mYJzY6hzqbVClk11a3qSv9pSi/cNTbqotiMgB6R8TlmvAlBVUWDR
         ZOr0GQpH3YcqxmOC/qs0ea4/z5ZQPHNfh8fY5zYywNmWQI+wfdJdCjmFulRSI8vglLS1
         TNYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=VS+EJuXcHOl/Y4VTDcHn1QB4ZCx6paXXC66trO1FQ50=;
        b=m8UywuT5IG2cQHitZcqpcuU0oVAhjsa6xOXNwISbby0vqhAkHdecaBq6vfOZi7PSFB
         JqhO4xVcYQnqSuQkHpy7p5ueGDwM9wWZwvSa9BocPwiYi96OcRG2n56iWNT8PRLTTcyB
         VUwtT3azUyAwlGi4BWw+shL1YYtWIFSNqwqpcbMj8Tm3HAZqs4120cOhae8wYDEnDsA+
         88Ev5TmQScFvcsjnXi/og8wbkVOmXB76JYhj9FLBgqy68KiV8BSa5lLYkggz2RsfS9qX
         6Rfhs35lxk/ayhzn329RREwfDCQQd4S+VAcK6BSLINcKmQWZIj63b5qsKXKuT8NTGIUo
         DwTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Al0TXJZB;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z186si575488oiz.28.2019.06.06.19.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 19:36:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Al0TXJZB;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9cd930000>; Thu, 06 Jun 2019 19:36:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 19:36:17 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 06 Jun 2019 19:36:17 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 02:36:16 +0000
Subject: Re: [PATCH v2 hmm 02/11] mm/hmm: Use hmm_mirror not mm as an argument
 for hmm_range_register
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-3-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <7902a4fa-f789-de3f-e448-a8cfc412f40b@nvidia.com>
Date: Thu, 6 Jun 2019 19:36:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-3-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559874963; bh=VS+EJuXcHOl/Y4VTDcHn1QB4ZCx6paXXC66trO1FQ50=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Al0TXJZBwEkVZOZLD+8oC+fGR+4awq+psveUro+gmkBw0ex9RNhYyL2afTzYC14Gr
	 8zB5XgAXfiKt5Ff+657AS8ZHpALXU0H/KUEvYt9Mi7EarnemI51LhZ5vBL29ckj1zd
	 HP+FGiZDyljWrHzzDBl3Uzj3nlWpgR9gxtx1fChJdV8n1uEp+pOMmXcSI4THVyOuz4
	 n6AOMfvn4cvrqQMM4O9BBxmDqcFBYuAjgDD0zIF/AKUB6D3WrX7nk49LFB2nZf5tzU
	 4H43m7RivZWoi8z1XfLcHDx2C0oWYchI7sQt2wgJByok8/0FGFOqi+QL4QrsnjcO0+
	 EOVIBu40QOceA==
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
> ---
> v2
> - Include the oneline patch to nouveau_svm.c
> ---
>  drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
>  include/linux/hmm.h                   |  7 ++++---
>  mm/hmm.c                              | 15 ++++++---------
>  3 files changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
> index 93ed43c413f0bb..8c92374afcf227 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_svm.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
> @@ -649,7 +649,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
>  		range.values = nouveau_svm_pfn_values;
>  		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
>  again:
> -		ret = hmm_vma_fault(&range, true);
> +		ret = hmm_vma_fault(&svmm->mirror, &range, true);
>  		if (ret == 0) {
>  			mutex_lock(&svmm->mutex);
>  			if (!hmm_vma_range_done(&range)) {
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 688c5ca7068795..2d519797cb134a 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -505,7 +505,7 @@ static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
>   * Please see Documentation/vm/hmm.rst for how to use the range API.
>   */
>  int hmm_range_register(struct hmm_range *range,
> -		       struct mm_struct *mm,
> +		       struct hmm_mirror *mirror,
>  		       unsigned long start,
>  		       unsigned long end,
>  		       unsigned page_shift);
> @@ -541,7 +541,8 @@ static inline bool hmm_vma_range_done(struct hmm_range *range)
>  }
>  
>  /* This is a temporary helper to avoid merge conflict between trees. */
> -static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> +static inline int hmm_vma_fault(struct hmm_mirror *mirror,
> +				struct hmm_range *range, bool block)
>  {
>  	long ret;
>  
> @@ -554,7 +555,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>  	range->default_flags = 0;
>  	range->pfn_flags_mask = -1UL;
>  
> -	ret = hmm_range_register(range, range->vma->vm_mm,
> +	ret = hmm_range_register(range, mirror,
>  				 range->start, range->end,
>  				 PAGE_SHIFT);
>  	if (ret)
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 547002f56a163d..8796447299023c 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -925,13 +925,13 @@ static void hmm_pfns_clear(struct hmm_range *range,
>   * Track updates to the CPU page table see include/linux/hmm.h
>   */
>  int hmm_range_register(struct hmm_range *range,
> -		       struct mm_struct *mm,
> +		       struct hmm_mirror *mirror,
>  		       unsigned long start,
>  		       unsigned long end,
>  		       unsigned page_shift)
>  {
>  	unsigned long mask = ((1UL << page_shift) - 1UL);
> -	struct hmm *hmm;
> +	struct hmm *hmm = mirror->hmm;
>  
>  	range->valid = false;
>  	range->hmm = NULL;
> @@ -945,15 +945,12 @@ int hmm_range_register(struct hmm_range *range,
>  	range->start = start;
>  	range->end = end;
>  
> -	hmm = hmm_get_or_create(mm);
> -	if (!hmm)
> -		return -EFAULT;
> -
>  	/* Check if hmm_mm_destroy() was call. */
> -	if (hmm->mm == NULL || hmm->dead) {
> -		hmm_put(hmm);
> +	if (hmm->mm == NULL || hmm->dead)
>  		return -EFAULT;
> -	}
> +
> +	range->hmm = hmm;
> +	kref_get(&hmm->kref);
>  
>  	/* Initialize range to track CPU page table updates. */
>  	mutex_lock(&hmm->lock);
> 

I'm not a qualified Nouveau reviewer, but this looks obviously correct,
so:

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
-- 
John Hubbard
NVIDIA

