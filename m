Return-Path: <SRS0=4eAG=W4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C108C3A5A8
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 20:35:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1D5121897
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 20:35:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mvxfW2Rt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1D5121897
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87A0B6B0010; Sun,  1 Sep 2019 16:35:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 829E26B0266; Sun,  1 Sep 2019 16:35:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71B106B0269; Sun,  1 Sep 2019 16:35:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0207.hostedemail.com [216.40.44.207])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADF66B0010
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 16:35:21 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E02516D77
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 20:35:20 +0000 (UTC)
X-FDA: 75887506800.24.leaf22_1187ce5ad405f
X-HE-Tag: leaf22_1187ce5ad405f
X-Filterd-Recvd-Size: 5606
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 20:35:20 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id h195so1136570pfe.5
        for <linux-mm@kvack.org>; Sun, 01 Sep 2019 13:35:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=UMz9j13CPipWdVYjch4adDtFWXAtjYrNSKsSdKhSILc=;
        b=mvxfW2Rt8/0uJ/cwQTEzc73ZEEki9DlUFiE5zlUcm3w4ZfNRAEYIWuarl+f8hwy6JY
         5DFaenL7to7Y3eZdBjobZpoLP5jUacAsTXheeGrznPYzl1I6PTTul1/dKs4tyHj82I41
         5io3t1x3adYBQBDjUbpL2Jy8v/kPnnjL22wlnPAi2hZpWpbDEjYZolEVXPJRsLBvMxDa
         az1bUoS+nkrh8YpQaxjLf+OadAonPIdMpPoMRJc69s67xUVpGcUNGBx7Z26Q6iAUdD+9
         PQBZnrrtuzCX41GtyguSJU4y75FDfcWA1Dx6wRXpx65hEnMTh+dHJg1xb3AXyuzaLLKl
         n8BA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:to:cc:references:from:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=UMz9j13CPipWdVYjch4adDtFWXAtjYrNSKsSdKhSILc=;
        b=LXQerBAGFRL/3qgrhpjObgIHmXmCpHjNAgO6uhmwJH/g6O/0Shoj+WDZ84ImYXsOUh
         HpzqfGcdXoZdkOkNf8HU0L+1mHm3H4pYfn4hV/s9m3RO2eDs7Pfi4alfImuESri1fuL4
         L1/5N6ZqcV1L89nteN8swJ6kOc7uyaZsVYByFgBfiZVzyAGC1jkmTtx71r9xYZwV8x7c
         Kr6ab11FDRc0EtxfziFTxXZxMEh9vOm9XOzq0pEUbEC/yBioJp5sqs5aJgLRgYEVz841
         g/hz0qgmEO3DTsqpMIPLyjLjB7gtAO2xgO5SEcf6fedgDA78iWBy87Vp9+exrAf7GuPq
         IUOQ==
X-Gm-Message-State: APjAAAX2wu5lZhVgGxvU3tEzQUOKIuf2hfSQOAWhP+NJXDdG/XB85zJd
	tQWYrYWUmkS37C25YK+lccQ=
X-Google-Smtp-Source: APXvYqzDuqMnY2mVqsHstoNFhTFtZtR0N4sRPNa9WtkN7E4Z8qlDxM2h2ZN0mOnp1q1WaDWiylowGA==
X-Received: by 2002:a65:640a:: with SMTP id a10mr21967201pgv.338.1567370119245;
        Sun, 01 Sep 2019 13:35:19 -0700 (PDT)
Received: from server.roeck-us.net ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id r4sm8176158pji.7.2019.09.01.13.35.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Sep 2019 13:35:18 -0700 (PDT)
Subject: Re: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 =?UTF-8?Q?Thomas_Hellstr=c3=b6m?= <thomas@shipmail.org>,
 Jerome Glisse <jglisse@redhat.com>, Steven Price <steven.price@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Thomas Hellstrom <thellstrom@vmware.com>
References: <20190828141955.22210-1-hch@lst.de>
 <20190828141955.22210-3-hch@lst.de> <20190901184530.GA18656@roeck-us.net>
 <20190901193601.GB5208@mellanox.com>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <b26ac5ae-a90c-7db5-a26c-3ace2f1530c7@roeck-us.net>
Date: Sun, 1 Sep 2019 13:35:16 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190901193601.GB5208@mellanox.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/1/19 12:36 PM, Jason Gunthorpe wrote:
> On Sun, Sep 01, 2019 at 11:45:30AM -0700, Guenter Roeck wrote:
>> On Wed, Aug 28, 2019 at 04:19:54PM +0200, Christoph Hellwig wrote:
>>> The mm_walk structure currently mixed data and code.  Split out the
>>> operations vectors into a new mm_walk_ops structure, and while we
>>> are changing the API also declare the mm_walk structure inside the
>>> walk_page_range and walk_page_vma functions.
>>>
>>> Based on patch from Linus Torvalds.
>>>
>>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>> Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>
>>> Reviewed-by: Steven Price <steven.price@arm.com>
>>> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
>>
>> When building csky:defconfig:
>>
>> In file included from mm/madvise.c:30:
>> mm/madvise.c: In function 'madvise_free_single_vma':
>> arch/csky/include/asm/tlb.h:11:11: error:
>> 	invalid type argument of '->' (have 'struct mmu_gather')
> 
> I belive the macros above are missing brackets.. Can you confirm the
> below takes care of things? I'll add a patch if so
> 

Good catch. Yes, that fixes the build problem.

Guenter

> diff --git a/arch/csky/include/asm/tlb.h b/arch/csky/include/asm/tlb.h
> index 8c7cc097666f04..fdff9b8d70c811 100644
> --- a/arch/csky/include/asm/tlb.h
> +++ b/arch/csky/include/asm/tlb.h
> @@ -8,14 +8,14 @@
>   
>   #define tlb_start_vma(tlb, vma) \
>   	do { \
> -		if (!tlb->fullmm) \
> -			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
> +		if (!(tlb)->fullmm) \
> +			flush_cache_range(vma, (vma)->vm_start, (vma)->vm_end); \
>   	}  while (0)
>   
>   #define tlb_end_vma(tlb, vma) \
>   	do { \
> -		if (!tlb->fullmm) \
> -			flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
> +		if (!(tlb)->fullmm) \
> +			flush_tlb_range(vma, (vma)->vm_start, (vma)->vm_end); \
>   	}  while (0)
>   
>   #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
> 
> Thanks,
> Jason
> 


