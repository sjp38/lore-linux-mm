Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D87EC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:04:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F104A2173E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:04:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F104A2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 577226B0005; Wed, 17 Jul 2019 17:04:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5288F8E0003; Wed, 17 Jul 2019 17:04:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43D988E0001; Wed, 17 Jul 2019 17:04:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B15D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:04:03 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so12642360pls.17
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:04:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=dc5GGP81UqJM9IyBCyZsSUkvAKgyIoizxHsE9yMPEfk=;
        b=QYoqAOUUk3ohvIyyO/9D2o0ZzEeOg+m/O5e+9XiP0ZHBKUtEsC7el3RBCZz83Yp/Wp
         ljGTpx85Q9NNr4L1Pcto8+EYHx3lcKVsYXOfQCNKcFyGia5zZDvc//5lZQ4eKyKTZIj3
         M4v+LsG4+tBOMeUl5eAUegwmaWDzmdkd0mTexTllrqTavebE+zdSiSmDCA+xgzOqB9Dp
         90QA4VNh5gwRpoP48fZoZSSg8GVhXPdguHldxjLh7b8fMd8D0kph4l55lD3iRNfLAnDf
         INl63D+UjP/qMy110uGQQ22/0OPqScg8I/ewGeUGm3TkgkUzjhFhK3Gs76IkIaVAiUBw
         ggCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVoa0H1P4LDvzveiS0I+2LuChSI6HuOUAHhBu8JEdPhJpJOXDeq
	F36vPgto5P309N59XZPHD+UHtnR5cq5uMwq8EMUXqzsEDoonIO0sS4EzA87luwC9p7j+ASqmdov
	pc1S3lJ6NHZa7+X+vIuBK72QjU6H3AiBdDez33gMQ1kWJDB8DFMHsiT/Wyv8yYRDzgg==
X-Received: by 2002:a17:90a:2190:: with SMTP id q16mr45080236pjc.23.1563397442634;
        Wed, 17 Jul 2019 14:04:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJAWQVWpS56J+Wul295evK8UokuBMDxpUeFr58lnRXm6Vdd507QGS9tqrNvqHr+8FY+Qc/
X-Received: by 2002:a17:90a:2190:: with SMTP id q16mr45080172pjc.23.1563397441791;
        Wed, 17 Jul 2019 14:04:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563397441; cv=none;
        d=google.com; s=arc-20160816;
        b=cMOlyJuToaC2Slzj963oJL3Bs/o7D119tCV0vd7m6SUB69kQL9eG2x7Qy51A1WFvV7
         NWPEUYSLgVHNNNYhcz61v2cqWLWZzOKmnIooLn4fs4BqqdSrjmveotV2dDuVtFQmgk+/
         pmXiGVGqD5ifbna3YzsaXtmSuPpaUQ1lnrzsHZKAtCbIu2kB7qPR3MhVujwrn6B+EiP1
         LMSTHieqOh38A/CCetI/xB9hxyd5HjD+4ka1aS5mQzoO6GhCdMXrB0nc4/VAwN2DB+ZG
         tDH6i5TowZFtcBN58YfLeiuQXrsHhieSKsgH6BqVk+fNMm7rtZlSpcgrEwRKUKOIv5lV
         vPqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dc5GGP81UqJM9IyBCyZsSUkvAKgyIoizxHsE9yMPEfk=;
        b=hmZa/ie+Dbs+WFP6UMZV91W6blFCkR+XXQ72T+ukIzOTclz7rphWCIPcH+MLmrqPDz
         hurNYRLqcdm8T5IzEXt3HCG4pD7vRMIY6U+4rQGOksVTXdOxHFHS0csH2+w24Fqulr73
         SiTh7SFh7aYIdx2MLDUBDGYySQjpFTslReam2vrLwozLTIQxMtMN5kIeZ8QtjI5TZ0XX
         bfZH1nqmFDkFeVtYmR8fG6t0it3fBJ1JCIFEugTburH6+9+SVj5QIANETP9fNbd8b/cd
         Ii/NJWvbrfjm1/DLVQGfb8flcM0tcvQ8bdt5ODdTPPW8PImKeIMtvPR1pRhTWcpZd9Nd
         SB9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id i6si9234270pfb.122.2019.07.17.14.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 14:04:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R241e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TX91ZqP_1563397435;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX91ZqP_1563397435)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 05:03:58 +0800
Subject: Re: [v3 PATCH 1/2] mm: thp: make transhuge_vma_suitable available for
 anonymous THP
To: Hugh Dickins <hughd@google.com>
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, vbabka@suse.cz,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560401041-32207-2-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.LSU.2.11.1907171207080.1177@eggly.anvils>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <85d8060b-76ab-76d8-1fc5-496e07378722@linux.alibaba.com>
Date: Wed, 17 Jul 2019 14:03:55 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1907171207080.1177@eggly.anvils>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/17/19 12:43 PM, Hugh Dickins wrote:
> On Thu, 13 Jun 2019, Yang Shi wrote:
>
>> The transhuge_vma_suitable() was only available for shmem THP, but
>> anonymous THP has the same check except pgoff check.  And, it will be
>> used for THP eligible check in the later patch, so make it available for
>> all kind of THPs.  This also helps reduce code duplication slightly.
>>
>> Since anonymous THP doesn't have to check pgoff, so make pgoff check
>> shmem vma only.
> Yes, I think you are right to avoid the pgoff check on anonymous.
> I had originally thought that it would work out okay even with the
> pgoff check on anonymous, and usually it would: but could give the
> wrong answer on an mremap-moved anonymous area.
>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: David Rientjes <rientjes@google.com>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Almost Acked-by me, but there's one nit I'd much prefer to change:
> sorry for being such a late nuisance...
>
>> ---
>>   mm/huge_memory.c |  2 +-
>>   mm/internal.h    | 25 +++++++++++++++++++++++++
>>   mm/memory.c      | 13 -------------
>>   3 files changed, 26 insertions(+), 14 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 9f8bce9..4bc2552 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -691,7 +691,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
>>   	struct page *page;
>>   	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
>>   
>> -	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
>> +	if (!transhuge_vma_suitable(vma, haddr))
>>   		return VM_FAULT_FALLBACK;
>>   	if (unlikely(anon_vma_prepare(vma)))
>>   		return VM_FAULT_OOM;
>> diff --git a/mm/internal.h b/mm/internal.h
>> index 9eeaf2b..7f096ba 100644
>> --- a/mm/internal.h
>> +++ b/mm/internal.h
>> @@ -555,4 +555,29 @@ static inline bool is_migrate_highatomic_page(struct page *page)
>>   
>>   void setup_zone_pageset(struct zone *zone);
>>   extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
>> +
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
>> +static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
>> +		unsigned long haddr)
>> +{
>> +	/* Don't have to check pgoff for anonymous vma */
>> +	if (!vma_is_anonymous(vma)) {
>> +		if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
>> +			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
>> +			return false;
>> +	}
>> +
>> +	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
>> +		return false;
>> +	return true;
>> +}
>> +#else
>> +static inline bool transhuge_vma_suitable(struct vma_area_struct *vma,
>> +		unsigned long haddr)
>> +{
>> +	return false;
>> +}
>> +#endif
>> +
>>   #endif	/* __MM_INTERNAL_H */
> ... maybe I'm just not much of a fan of mm/internal.h (where at last you
> find odd bits and pieces which you had expected to find elsewhere), and
> maybe others will disagree: but I'd say transhuge_vma_suitable() surely
> belongs in include/linux/huge_mm.h, near __transparent_hugepage_enabled().
>
> But then your correct use of vma_is_anonymous() gets more complicated:
> because that declaration is over in include/linux/mm.h; and although
> linux/mm.h includes linux/huge_mm.h, vma_is_anonymous() comes lower down.
>
> However... linux/mm.h's definition of vma_set_anonymous() comes higher
> up, and it would make perfect sense to move vma_is_anonymous up to just
> after vma_set_anonymous(), wouldn't it?  Should vma_is_shmem() and
> vma_is_stack_for_current() declarations move with it? Probably yes:
> they make more sense near vma_is_anonymous() than where they were.

Thanks for the thorough instructions. Will fix this in v4.

>
> Hugh
>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 96f1d47..2286424 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -3205,19 +3205,6 @@ static vm_fault_t pte_alloc_one_map(struct vm_fault *vmf)
>>   }
>>   
>>   #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
>> -
>> -#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
>> -static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
>> -		unsigned long haddr)
>> -{
>> -	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
>> -			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
>> -		return false;
>> -	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
>> -		return false;
>> -	return true;
>> -}
>> -
>>   static void deposit_prealloc_pte(struct vm_fault *vmf)
>>   {
>>   	struct vm_area_struct *vma = vmf->vma;
>> -- 
>> 1.8.3.1

