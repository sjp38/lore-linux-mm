Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE468C06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:32:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B93C521882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:32:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jFQPczeo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B93C521882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 552058E000B; Wed,  3 Jul 2019 13:32:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D9708E0001; Wed,  3 Jul 2019 13:32:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 352D58E000B; Wed,  3 Jul 2019 13:32:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 157C28E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 13:32:44 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id r58so3730489qtb.5
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 10:32:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=h5APIAGCLtc3sbvDunYYsjAxWo0bLP7WU/0gBEeeI0w=;
        b=iJofYU7NIeSI5pwATBsqLLw8R015C5ZfIEIfTj8a8hv/GNE4xZuRXhiQ7PbJtgJet7
         DGRK2Apy4cQeuKr77qItiaKX17X8oMb97xHQvBMSXhnsZqfqhgeGEzh76lsciLoeDovN
         /QKrQj1FJJKOrHHFyc8fIjcBl4udE3KtLemynL/Bb+0KErwaUg5YdHybcV7qBX/9TzPR
         jkpyiJ5cHEf5A2qe+6CDb1oThG3CreIZl0Y/8qR4CI9oliTJ1Krr/DGh+pj95xZUmCgT
         /2vDoWNB+BLpJ4yaoyzXHxGiq4WR6FFtpfdrVq9IownxOZ6rxL/htJmDZDqz/XJyyQgv
         PaYA==
X-Gm-Message-State: APjAAAUVKrDyE9EK/v4wTkyoKFGIJBJ+68LLU8vzcdCzFbBKjlTPlV0T
	fecGIcbqJz+kaSIVAGM6W/d7Si4HnhJ0xzNSUlr4mNMrmOuLZWWKzP9+3tIvFl+AbEAoIAIRN7S
	wl2e4SQyzlGV7kZpFJBHpcIfxeoty27txiIpS1s80sluFiwaKdccP3r9LPgQ2FIU28g==
X-Received: by 2002:a25:d857:: with SMTP id p84mr12175919ybg.48.1562175163835;
        Wed, 03 Jul 2019 10:32:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcqs8fN8pdVER9lMxSgAMLeTcNFY56HPRWiT/BcNE+ZgpvgYqr1STS4JWVTbv7zVdHtOYU
X-Received: by 2002:a25:d857:: with SMTP id p84mr12175872ybg.48.1562175163250;
        Wed, 03 Jul 2019 10:32:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562175163; cv=none;
        d=google.com; s=arc-20160816;
        b=l+zNkelaMz3ZfEPXZmGIAA4BYzmctWQgNsdATNEVaMqR+/e7icwqd7vq6hYIJbWWwr
         FFQ+KnU98oURc/slsRj5uvQ2xCFc+SC0TQLYuYn6yqY+1Jn6Tl8BJyU74BlUvjC8dyCj
         OxQaR5nIy8oGqd7+j33bA4p+J69FRckfTy50jpuZGC+2hI8UoX20C87xi98OlDwYQW+s
         NEJseOCG3zo5AA397wGGng6xXCzjKX8KGwHFKycvpSfhYYXSvBvGgLYWUuDTL58hzEAG
         Jea7jl4JMzi0XWXfTMIHDNS8bkN3KLDAw+LUDxltWIMChY8I0LobeKopDV+HwvSLX8Xc
         DIKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=h5APIAGCLtc3sbvDunYYsjAxWo0bLP7WU/0gBEeeI0w=;
        b=MDaCULcDq+D73b7pnzYY2FzU7tuQnJJYGPgcRpcMWDPOcG3yxLIu2sHeIrewQkCg4F
         K6UzZq8IEPcAs5l9h4ZCmiihIoXgH9XwjiJ939IltOeMzceLyJ6WUO7gOgx/tVt7KUih
         gIN7mSWGrpGMk3gpDx6BgRz5ydfh+G4tScP0ahQGwmLl87j1Dx4499D5rNXbw1dmFF0b
         hZAVunnHsyD8+IkRz4AbK+qmkNkGLqjvoBej0vwSzV1i66zfl8yTSoqXmH+9rGMfZ2zR
         +QTmxmm9R2XFfEHTLhG4YGuTsXHzcrZt387eAQj32InMoVxmT+mNkZp6vyTP+d1xPf2W
         xGOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jFQPczeo;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id f131si1395506ybg.17.2019.07.03.10.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 10:32:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jFQPczeo;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d1ce6b90000>; Wed, 03 Jul 2019 10:32:41 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 03 Jul 2019 10:32:42 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 03 Jul 2019 10:32:42 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 3 Jul
 2019 17:32:40 +0000
Subject: Re: [PATCH 19/22] mm: always return EBUSY for invalid ranges in
 hmm_range_{fault,snapshot}
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: Ira Weiny <ira.weiny@intel.com>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-nvdimm@lists.01.org>, <linux-pci@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
References: <20190701062020.19239-1-hch@lst.de>
 <20190701062020.19239-20-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <85c88d71-2c25-38ff-a4a3-bfd66fff72b7@nvidia.com>
Date: Wed, 3 Jul 2019 10:32:39 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190701062020.19239-20-hch@lst.de>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1562175161; bh=h5APIAGCLtc3sbvDunYYsjAxWo0bLP7WU/0gBEeeI0w=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=jFQPczeoa9GgO31iCc1i+leEDWlzjjir863TTILBB/y92fjmJ/f1sRLtX+VAJ+7kT
	 w92vvah6B8huA4GwU+UVeQT0gcXzN2h0pOn1OhPiqQgIiYhz+alEB4KdiyBILqdNjF
	 iPKpJwcfB8ejE/ycfI+hpo2hU5HhQCvtjkyBzaQyOAlSWgEb0SBv3a75TxnJ6bQu96
	 N0rQy1PEp6S5xBst7hP92U8L+tvob0E2tubrjAKpvUgVgwpry+THodovSht9UYcLga
	 YagJXvoKcVLlFOE7Nc+UP4wF3Mu6pxJqPDNSCJG6taQO+xhoGrUVb+lnZnXTS7ATQt
	 SJRIeqmOivyvQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/30/19 11:20 PM, Christoph Hellwig wrote:
> We should not have two different error codes for the same condition.  In
> addition this really complicates the code due to the special handling of
> EAGAIN that drops the mmap_sem due to the FAULT_FLAG_ALLOW_RETRY logic
> in the core vm.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

Probably should update the "Return:" comment above
hmm_range_snapshot() too.

> ---
>   mm/hmm.c | 8 +++-----
>   1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c85ed7d4e2ce..d125df698e2b 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -974,7 +974,7 @@ long hmm_range_snapshot(struct hmm_range *range)
>   	do {
>   		/* If range is no longer valid force retry. */
>   		if (!range->valid)
> -			return -EAGAIN;
> +			return -EBUSY;
>   
>   		vma = find_vma(hmm->mm, start);
>   		if (vma == NULL || (vma->vm_flags & device_vma))
> @@ -1069,10 +1069,8 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>   
>   	do {
>   		/* If range is no longer valid force retry. */
> -		if (!range->valid) {
> -			up_read(&hmm->mm->mmap_sem);
> -			return -EAGAIN;
> -		}
> +		if (!range->valid)
> +			return -EBUSY;
>   
>   		vma = find_vma(hmm->mm, start);
>   		if (vma == NULL || (vma->vm_flags & device_vma))
> 

