Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3142C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:36:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70E60217D6
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:36:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70E60217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20AEB6B0007; Thu,  9 May 2019 14:36:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E1C16B0008; Thu,  9 May 2019 14:36:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D0F16B000A; Thu,  9 May 2019 14:36:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7C7E6B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 14:36:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a90so2047504plc.7
        for <linux-mm@kvack.org>; Thu, 09 May 2019 11:36:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=MNZi0wb7i89e7LGK+vmwloLSRrvJFBs0CaspD1gInGA=;
        b=BnPzqK+fLlnRdFoIsm2yqKEmtm6YQTWRGqMFX3F/wquHMvnDb5zS0eL+0Nso3axlNf
         8wSrf2qn+b9RtpdMzl9DEF/bIp5lOeb37Ck89tWBMYNNYVBUzYVQoG3DwIfrZNUG3fwM
         kukviKhbZJrpdHr/zqsvj6iqdRPLXDxeDgAO2K/g40R1seCauF4VrlLPxFniUQ1y+MOB
         V2EHXlg7o6uXGbw4XvdQn/Gsri21L0EX5T37hDKRQ3LrNZ8pcXg9ZhPBMi5sZEbNEdcR
         iuddTUBYD2+nE2rBAFBaEn1g4lhTcv3oXPOUAwhdqLMzlzx1soTmJFYLSOmdpb/XWNxT
         V2ZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVYph0jbm9yzM+0Nn6CwhG1305cZFPb4gECqOqeVtrU6fGmgqmD
	5ZJ2L3DcwMs/suruNggwFU/aIKAiCHmCIkZdoX9Kv6ZLWkyy2UeNgZz99ufgSkIvEOs4QcvlgAU
	2M2x5qlqKQxa00/SS30c56iw9l6tYeDs5bQEjjPvuyFofbxFrNwthII6wwvxTVZ1Qww==
X-Received: by 2002:a17:902:a01:: with SMTP id 1mr7271627plo.36.1557426964417;
        Thu, 09 May 2019 11:36:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgSlX/oxoM5NYzXZg4pc92/lvJw5lfOFxq+htUeBUizsoIPSt4tEkGZ+TcKdbqh8ua6k6R
X-Received: by 2002:a17:902:a01:: with SMTP id 1mr7271553plo.36.1557426963743;
        Thu, 09 May 2019 11:36:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557426963; cv=none;
        d=google.com; s=arc-20160816;
        b=B8xi5UoEIDBYpiXFBIb2wNTrAgI0tmyD7UpjkgvPK0jcMh4gG2t8LlD69lGdZ1+twL
         z6W03jJCh1Rhfv4UfwpvFcR5vPmyDGFpvM0Sy6leLpK0/Hbjtt4AJuS5WklY7cJ4QfNZ
         ZH5Vjl+GFsnBBW1gbohKnjVV/PShbk7P1aKpHImavIMO44iz/olDIAaejKNnCLoscZsj
         kTr3pJvGUYnXEwGxjXgsnfRgkpoiCh2L0s4ev95gAS2QgfW4mfww4Jv3OtbKRZx+WALo
         cWE9FFppaCPTY482InWAo+SUaoUbCFkcA0N3Dp1UhXMPrRhgOejb/i3LTMccQtk02+BF
         sXqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MNZi0wb7i89e7LGK+vmwloLSRrvJFBs0CaspD1gInGA=;
        b=wNEs4EbNwN/9KzjeR1xiQs5Jgp1Bukm+uDYuecTnZ+uZjTF9xogL68+B2o7YWIRVxT
         IHgPLeqevOYL1UHF10xWA1esJDySZhEKXCd39ts/qXNK2LiYGtqxV3XA66M5+6eJL4jI
         ARZ9WYksrt9BOKKPomEqYLkNles9vdlFMSUOo+E001aS9DwkQugQ5TLBbTNWxlOxTXMc
         /peOjyZfk2vKIA+p1xjiSZY5yXySK2o3Yoz7Uiz9/EDlxab5mS4HEVwHrtP7tkevrEME
         KnY3Cn6N+QFZjrmvVngyQ5Q1ej6EuDsYwmk1eoeLUpWhPRpu3Ja2gEepWOcpvs+QnANG
         PoVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id g10si3957806pgs.397.2019.05.09.11.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 11:36:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TRHO45d_1557426956;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRHO45d_1557426956)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 02:36:00 +0800
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
To: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>
Cc: jstancek@redhat.com, akpm@linux-foundation.org, stable@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, namit@vmware.com,
 minchan@kernel.org, Mel Gorman <mgorman@suse.de>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <20190509105446.GL2650@hirez.programming.kicks-ass.net>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6a907073-67ec-04fe-aaae-c1adcb62e3df@linux.alibaba.com>
Date: Thu, 9 May 2019 11:35:55 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190509105446.GL2650@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/9/19 3:54 AM, Peter Zijlstra wrote:
> On Thu, May 09, 2019 at 12:38:13PM +0200, Peter Zijlstra wrote:
>
>> That's tlb->cleared_p*, and yes agreed. That is, right until some
>> architecture has level dependent TLBI instructions, at which point we'll
>> need to have them all set instead of cleared.
>> Anyway; am I correct in understanding that the actual problem is that
>> we've cleared freed_tables and the ARM64 tlb_flush() will then not
>> invalidate the cache and badness happens?
>>
>> Because so far nobody has actually provided a coherent description of
>> the actual problem we're trying to solve. But I'm thinking something
>> like the below ought to do.
> There's another 'fun' issue I think. For architectures like ARM that
> have range invalidation and care about VM_EXEC for I$ invalidation, the
> below doesn't quite work right either.
>
> I suspect we also have to force: tlb->vma_exec = 1.

Isn't the below code in tlb_flush enough to guarantee this?

...
} else if (tlb->end) {
                struct vm_area_struct vma = {
                        .vm_mm = tlb->mm,
                        .vm_flags = (tlb->vma_exec ? VM_EXEC    : 0) |
                                    (tlb->vma_huge ? VM_HUGETLB : 0),
                };
...

>
> And I don't think there's an architecture that cares, but depending on
> details I can construct cases where any setting of tlb->vm_hugetlb is
> wrong, so that is _awesome_. But I suspect the sane thing for now is to
> force it 0.
>
>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>> index 99740e1dd273..fe768f8d612e 100644
>> --- a/mm/mmu_gather.c
>> +++ b/mm/mmu_gather.c
>> @@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>>   		unsigned long start, unsigned long end)
>>   {
>>   	/*
>> -	 * If there are parallel threads are doing PTE changes on same range
>> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
>> -	 * flush by batching, a thread has stable TLB entry can fail to flush
>> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
>> -	 * forcefully if we detect parallel PTE batching threads.
>> +	 * Sensible comment goes here..
>>   	 */
>> -	if (mm_tlb_flush_nested(tlb->mm)) {
>> -		__tlb_reset_range(tlb);
>> -		__tlb_adjust_range(tlb, start, end - start);
>> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
>> +		/*
>> +		 * Since we're can't tell what we actually should have
>> +		 * flushed flush everything in the given range.
>> +		 */
>> +		tlb->start = start;
>> +		tlb->end = end;
>> +		tlb->freed_tables = 1;
>> +		tlb->cleared_ptes = 1;
>> +		tlb->cleared_pmds = 1;
>> +		tlb->cleared_puds = 1;
>> +		tlb->cleared_p4ds = 1;
>>   	}
>>   
>>   	tlb_flush_mmu(tlb);

