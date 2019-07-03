Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C9BFC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:22:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 387872189E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:22:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="o4SEJPOO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 387872189E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C83788E000A; Wed,  3 Jul 2019 13:22:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0BDE8E0001; Wed,  3 Jul 2019 13:22:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAD3F8E000A; Wed,  3 Jul 2019 13:22:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 842458E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 13:22:29 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o16so3660159qtj.6
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 10:22:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=t4iv+JkVQXMDn9U21ZE8onfcueQ7442WkhT3/Dcpa4M=;
        b=MDYPGHkTY5qgaUHPWrMsfqs96qgIgiuY5gxBGL+SJyWQ6jJ2zb6IPavKyI8Kl2vz6Q
         cMuVagt5LmH1nFr6Thg1LJ+0TeJFdkw+zX3NytKTENKaPozThB8Ma2p60wrAxWMgkSjn
         lK1jBd5L+A/o7XXkbU7+lDqhPiDUSTYxDeebbExdhKc5lpC1Gz2FyWplZLCRtrsTOABw
         /gbV++Vv8qgiGhOJA3JaE4sYkhVslg21ArX2P+e+1ksRTS2mvYlhihGOxCdyqRxWm+hc
         AHCRogqPGPFYX5zS6XVG8UEn+nGDG+pVTlzRZFBtFq113yFbboF73XCFl9BQ1GsXsbF2
         o16g==
X-Gm-Message-State: APjAAAVeV3Q7e6iR8SaKzG123bBujh/a0vYwt2fIDd+RDQPAqeEWCf2L
	VETX0kH4iXGNtV844tZH/ZHPyNk3Sf3l/nzo0OLqWf1t/ZtV58ns9V+G//ZAIOJN1ZBioLAWNOz
	jDUN6tEhTUEkyVfmX+w/w7XRzB/eYHZw6zKD+5cPIAnVqtGjbrBB/ZEM9X2089E0+5Q==
X-Received: by 2002:a81:4c3:: with SMTP id 186mr23678473ywe.462.1562174549252;
        Wed, 03 Jul 2019 10:22:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvRVtU7zgkpyVzLlHd4grFAHvvUdoNovIHbvJ8arvfCUxrMpTGmx+Wgbk9lt8CDgbFIUCf
X-Received: by 2002:a81:4c3:: with SMTP id 186mr23678413ywe.462.1562174548462;
        Wed, 03 Jul 2019 10:22:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562174548; cv=none;
        d=google.com; s=arc-20160816;
        b=QIt69/c0i/msCr9FH2y9iznmDbAAmrWU8ldgqrsvxUkBIhC1XhjvO7sAYd+zoUjL54
         W4+FBBkhwq0isxB4RJjjC6WyDD9NyFGtYal08KiiR3jXnau21qfbtlFgcQyaFqVFK1FE
         JvzYXF1of+niGSBdGGiVeBfZiRa7Jb+vcV27H+aZMx/GrC6iehFSTuRNQ1BespielU7J
         GAioPoNcOqBanBUHCfDJo2tmkhOe1KP3hnlzFkVle5JCV8gbk7njFTza6/djOkuir5TU
         5XSEf4jXqz+uw2FsD376nS6G4gTibfnWLuk47Y6Prx8qhKgOq2NyLe23fCZI6gpdtwN+
         kz7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=t4iv+JkVQXMDn9U21ZE8onfcueQ7442WkhT3/Dcpa4M=;
        b=ujAFxhJpZnlwrgeHZWLVbk73SSdlitC92CTvCq3XXB4joh5zz+DMyv+cQ1h69u+PSB
         4L8iKmDroooNuM3tFoEdxvX9lwnsJ4g0KPkk7PSG/LmusCOMRnC9GF7NBjX2Nw8u76uS
         beV4GdSs7+v4eyd0WFZ/YQKMVJbZsJ/D0jkBgmo5LY4aAeRxg7C7bGYkiH5ESiDwY8q+
         6mV3BLIxGZQ7StHGckaC4123aKJB013eM5O9N1nLX+b37k5363DjJ3JdmQm0QDyTSSHG
         Y4IDYxx61CpCUo88tLo4fGQ2qomDADZJJyk4hlmjpAie6DbcZm3nG+EtsxnlP5PHYNkZ
         LMoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=o4SEJPOO;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id c200si1324584ywc.330.2019.07.03.10.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 10:22:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=o4SEJPOO;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d1ce44f0000>; Wed, 03 Jul 2019 10:22:23 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 03 Jul 2019 10:22:27 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 03 Jul 2019 10:22:27 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 3 Jul
 2019 17:22:23 +0000
Subject: Re: [PATCH 18/22] mm: return valid info from hmm_range_unregister
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: Ira Weiny <ira.weiny@intel.com>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-nvdimm@lists.01.org>, <linux-pci@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
References: <20190701062020.19239-1-hch@lst.de>
 <20190701062020.19239-19-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <0cc37cca-4f3a-40bb-0059-bf3880c171b8@nvidia.com>
Date: Wed, 3 Jul 2019 10:22:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190701062020.19239-19-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1562174544; bh=t4iv+JkVQXMDn9U21ZE8onfcueQ7442WkhT3/Dcpa4M=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=o4SEJPOOrRcVRLndEm7Zo7kTSy5FZf0UU7cSYb6tblR8H1EUMVX5E/0FjYzJrSpko
	 wz/tUydScQzFM1TJuHIP9tIFH+twnUQBk37KA0HVngw9EftV5QqHG2Tqfjp2J8EPuI
	 cOTG6KhoZMk2Kh1KQh0nP3AEh0uE4jVMnBYCBTkXTdSVmN+wIcMvLmh+GM9psOeZBs
	 3aY56IDBUR2I0RSrHwqu9wiz9+2bNfCk3CTpCrQB/Pq2QpA4D4k/ASPiYqwdt5SsHr
	 E0w4jAe1UNn6ayNyaW96+0ynvEfH+IEp7CDyfnUEVKIhxGZ7F5A0JKPp7wK4+C0AuG
	 0J+QqvUEgD4RQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/30/19 11:20 PM, Christoph Hellwig wrote:
> Checking range->valid is trivial and has no meaningful cost, but
> nicely simplifies the fastpath in typical callers.  Also remove the
> hmm_vma_range_done function, which now is a trivial wrapper around
> hmm_range_unregister.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_svm.c |  2 +-
>   include/linux/hmm.h                   | 11 +----------
>   mm/hmm.c                              |  6 +++++-
>   3 files changed, 7 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
> index 8c92374afcf2..9d40114d7949 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_svm.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
> @@ -652,7 +652,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
>   		ret = hmm_vma_fault(&svmm->mirror, &range, true);
>   		if (ret == 0) {
>   			mutex_lock(&svmm->mutex);
> -			if (!hmm_vma_range_done(&range)) {
> +			if (!hmm_range_unregister(&range)) {
>   				mutex_unlock(&svmm->mutex);
>   				goto again;
>   			}
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 0fa8ea34ccef..4b185d286c3b 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -465,7 +465,7 @@ int hmm_range_register(struct hmm_range *range,
>   		       unsigned long start,
>   		       unsigned long end,
>   		       unsigned page_shift);
> -void hmm_range_unregister(struct hmm_range *range);
> +bool hmm_range_unregister(struct hmm_range *range);
>   long hmm_range_snapshot(struct hmm_range *range);
>   long hmm_range_fault(struct hmm_range *range, bool block);
>   long hmm_range_dma_map(struct hmm_range *range,
> @@ -487,15 +487,6 @@ long hmm_range_dma_unmap(struct hmm_range *range,
>    */
>   #define HMM_RANGE_DEFAULT_TIMEOUT 1000
>   
> -/* This is a temporary helper to avoid merge conflict between trees. */
> -static inline bool hmm_vma_range_done(struct hmm_range *range)
> -{
> -	bool ret = hmm_range_valid(range);
> -
> -	hmm_range_unregister(range);
> -	return ret;
> -}
> -
>   /* This is a temporary helper to avoid merge conflict between trees. */
>   static inline int hmm_vma_fault(struct hmm_mirror *mirror,
>   				struct hmm_range *range, bool block)
> diff --git a/mm/hmm.c b/mm/hmm.c
> index de35289df20d..c85ed7d4e2ce 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -920,11 +920,14 @@ EXPORT_SYMBOL(hmm_range_register);
>    *
>    * Range struct is used to track updates to the CPU page table after a call to
>    * hmm_range_register(). See include/linux/hmm.h for how to use it.
> + *
> + * Returns if the range was still valid at the time of unregistering.

Since this is an exported function, we should have kernel-doc comments.
That is probably a separate patch but at least this line could be:
Return: True if the range was still valid at the time of unregistering.

>    */
> -void hmm_range_unregister(struct hmm_range *range)
> +bool hmm_range_unregister(struct hmm_range *range)
>   {
>   	struct hmm *hmm = range->hmm;
>   	unsigned long flags;
> +	bool ret = range->valid;
>   
>   	spin_lock_irqsave(&hmm->ranges_lock, flags);
>   	list_del_init(&range->list);
> @@ -941,6 +944,7 @@ void hmm_range_unregister(struct hmm_range *range)
>   	 */
>   	range->valid = false;
>   	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
> +	return ret;
>   }
>   EXPORT_SYMBOL(hmm_range_unregister);
>   
> 

