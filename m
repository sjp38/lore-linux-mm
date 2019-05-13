Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC6A0C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 23:01:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 838FE20862
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 23:01:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 838FE20862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B2516B0003; Mon, 13 May 2019 19:01:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 264D46B0006; Mon, 13 May 2019 19:01:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 151A96B0007; Mon, 13 May 2019 19:01:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D28E56B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 19:01:22 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d9so1322697pfo.13
        for <linux-mm@kvack.org>; Mon, 13 May 2019 16:01:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=ReV0bYQv8ayk11Es0G4Hu/TDA1Y1fvs0TT3jCLrPm2k=;
        b=BcEPln4goheByT/MfBV48BaUlW83zWkvVxzHpqaNtTo5Ndl3U2XWqfOnvDGZubsvso
         UfkfUroRwfsNc7P3itvAMGz92fQTfo1Qz44TgVpRdb8NTMMO3fiRsXlA36xsY6aPTNbp
         sVZZXdRQGO8v/PSfs7IlCf0qfDxa4ZZVJbVr2nNGIxoiUENbfMFJ+T93zxzo+eBa6N8H
         zGcG2Yp2h2V2bLCiXNcVZbyxiei57vhql3Guxo2e/bT6xE3S+83etKmShwE9U//LsJfN
         Qe+sjNKBsHsUAwTDMfsaG/4a30S03Q/0qn2fkYhr7l8Ge3ThIHzn99uOtpXkqPCdpMvI
         n94w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXWcq0j4hkk4rt22XjEljimmBEqw3MMXmLZWh0SuuqWeS3ykxry
	c0DxCIxXlzNKUhNEl95kr19WGXpa+FFj2kwfftEyz+pVBeOqHU9qJoASXRcazxUxC45K6jNHUlU
	sgxIf3t2LgTUPz0IiFvw4IfOs7ZSzEp5KD3ofXz10yZh0AYtnqG4K6tEJTZHnExH48A==
X-Received: by 2002:a62:640e:: with SMTP id y14mr18150776pfb.109.1557788482507;
        Mon, 13 May 2019 16:01:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBXS4+nCVnwk1GmE+c0olVgQauWWlIJHek/znKtGAmOlg0l320NanRh0bgMVKt/MJ0YBj8
X-Received: by 2002:a62:640e:: with SMTP id y14mr18150692pfb.109.1557788481576;
        Mon, 13 May 2019 16:01:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557788481; cv=none;
        d=google.com; s=arc-20160816;
        b=ufkuZNXIpdYogPG5e6l1DY6pIdc+PI/BjX++5U7Ynj05rtwOpea/WOj9A7XZYwU8dk
         wiOchPMNusp01UCL2gzKFTxSAz7YzxhbnC/D5SWWVIjfYB4cwJrlCGmsOZttGzBXdkvb
         ceyp1QyDnwScVoLKfNrWmK9zLrgJzGysbLVUlYrltray72eQVfMfT/Hgzxh5Fh+xhuLI
         RoHzo+ExaYKQ7bFixqqjuTUvUF7S7G8GVjvB0Aaxc9iCurvG13st/fgFiJMdUBckBDpf
         CJGLeL6jCkFFvE+JIMEYQae+3Zlk1KID9Wg83asfxl5S2OlzCqOCCeDwkncwxnVjtotH
         Kubg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ReV0bYQv8ayk11Es0G4Hu/TDA1Y1fvs0TT3jCLrPm2k=;
        b=t9A0ekE9iU9QCx0tMTawWlkk2BzgeN6YFcFAHzvpnk1xnSvGJTlxjhicgdkuXrpMIv
         NADXq7e73OaAUs7qGwij0eXxu1Q1zPFxIb6nRvwkstTdSFGTZ9Dc+5NRbHTrlQhUSxxp
         Phx9ZDsIN+k1KywctXbS4g0YCn0440+gulabQNICoTnmFw/GO8Z/DjmQLwx/iC3fXKY4
         ZNnNsfrW+UDtBQKZXCbrCW/xddaZLvyGnDefxPK4XW4A0gVXFI4Gyq+L1mYaXu5umYer
         6auSOzSGY9zd6enLayuyLd5/Ep4TUUfSgkerLNYvyBdfCBN76QbUIcTGaPUuE5a+GQ13
         GP5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id z14si18622178pgs.556.2019.05.13.16.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 16:01:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R791e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TRe7atb_1557788475;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRe7atb_1557788475)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 14 May 2019 07:01:18 +0800
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
To: Will Deacon <will.deacon@arm.com>
Cc: jstancek@redhat.com, peterz@infradead.org, namit@vmware.com,
 minchan@kernel.org, mgorman@suse.de, stable@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513163804.GB10754@fuggles.cambridge.arm.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <360170d7-b16f-f130-f930-bfe54be9747a@linux.alibaba.com>
Date: Mon, 13 May 2019 16:01:09 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190513163804.GB10754@fuggles.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/13/19 9:38 AM, Will Deacon wrote:
> On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>> index 99740e1..469492d 100644
>> --- a/mm/mmu_gather.c
>> +++ b/mm/mmu_gather.c
>> @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>>   {
>>   	/*
>>   	 * If there are parallel threads are doing PTE changes on same range
>> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
>> -	 * flush by batching, a thread has stable TLB entry can fail to flush
>> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
>> -	 * forcefully if we detect parallel PTE batching threads.
>> +	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
>> +	 * flush by batching, one thread may end up seeing inconsistent PTEs
>> +	 * and result in having stale TLB entries.  So flush TLB forcefully
>> +	 * if we detect parallel PTE batching threads.
>> +	 *
>> +	 * However, some syscalls, e.g. munmap(), may free page tables, this
>> +	 * needs force flush everything in the given range. Otherwise this
>> +	 * may result in having stale TLB entries for some architectures,
>> +	 * e.g. aarch64, that could specify flush what level TLB.
>>   	 */
>> -	if (mm_tlb_flush_nested(tlb->mm)) {
>> -		__tlb_reset_range(tlb);
>> -		__tlb_adjust_range(tlb, start, end - start);
>> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
>> +		/*
>> +		 * Since we can't tell what we actually should have
>> +		 * flushed, flush everything in the given range.
>> +		 */
>> +		tlb->freed_tables = 1;
>> +		tlb->cleared_ptes = 1;
>> +		tlb->cleared_pmds = 1;
>> +		tlb->cleared_puds = 1;
>> +		tlb->cleared_p4ds = 1;
>> +
>> +		/*
>> +		 * Some architectures, e.g. ARM, that have range invalidation
>> +		 * and care about VM_EXEC for I-Cache invalidation, need force
>> +		 * vma_exec set.
>> +		 */
>> +		tlb->vma_exec = 1;
>> +
>> +		/* Force vma_huge clear to guarantee safer flush */
>> +		tlb->vma_huge = 0;
>> +
>> +		tlb->start = start;
>> +		tlb->end = end;
>>   	}
> Whilst I think this is correct, it would be interesting to see whether
> or not it's actually faster than just nuking the whole mm, as I mentioned
> before.
>
> At least in terms of getting a short-term fix, I'd prefer the diff below
> if it's not measurably worse.

I did a quick test with ebizzy (96 threads with 5 iterations) on my x86 
VM, it shows slightly slowdown on records/s but much more sys time spent 
with fullmm flush, the below is the data.

                                     nofullmm                 fullmm
ops (records/s)              225606                  225119
sys (s)                            0.69                        1.14

It looks the slight reduction of records/s is caused by the increase of 
sys time.

>
> Will
>
> --->8
>
> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index 99740e1dd273..cc251422d307 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -251,8 +251,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>   	 * forcefully if we detect parallel PTE batching threads.
>   	 */
>   	if (mm_tlb_flush_nested(tlb->mm)) {
> +		tlb->fullmm = 1;
>   		__tlb_reset_range(tlb);
> -		__tlb_adjust_range(tlb, start, end - start);
> +		tlb->freed_tables = 1;
>   	}
>   
>   	tlb_flush_mmu(tlb);

