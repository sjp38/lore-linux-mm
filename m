Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47702C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 17:25:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06C0120850
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 17:25:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06C0120850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 988606B0007; Tue, 14 May 2019 13:25:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 938896B0008; Tue, 14 May 2019 13:25:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8277A6B000A; Tue, 14 May 2019 13:25:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 491216B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 13:25:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id m12so15009pls.10
        for <linux-mm@kvack.org>; Tue, 14 May 2019 10:25:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=0yhDS6xEOFGbhUYlW6OLQutQI+Jr+pZfSaEGSPPsQEU=;
        b=PadX7LpIEQaQ96YDB9UlZR4WgiLwS7tSuKsizDsqa1SKntr/kQUklj/hQKCmKhdzXg
         KXfG0flVKd/LQqLJHXQMhg6BGg9VDa4VaPRPxZeBbT5xMaacTfJzgx9kKjvvVbnaCy+y
         dqmL9BZM9EMedThBkFMuH5kwZiCnHwjJkQS33z1wXFkiEdFuYdx/l6fsOZjnxadoldWA
         pv6i7qbtNgAtKSqGbl/iluX6Q3ifbDUZtcyIRLA8l3olnFJ0hGFWsTqzo5h5QORnetvO
         +5wEQLefOjl81gLUqeyLKsVfbBXBksMrhhDbVFcJ/nevzjjE97Brk8G0AvZXXPCxbqd6
         ojHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUMGZhw0nlpcvi6ZcONOUlZMs3ZD9Z3StAol5jO5aIeHAHbHKaC
	QroWVnWA5OjInJjvJCiKD2gQfGdnCXfBqz5+Ij101w5khQy7/7yrN1kze9T45lRqHXv3Kg9TXaS
	I0VhRgzaq7Ge0GXtE0my+B78o1g5StDBiiQfpW2Nmn4S1rdcDsPtzkNP9zqelCJB5EQ==
X-Received: by 2002:a62:fc56:: with SMTP id e83mr3171393pfh.27.1557854750892;
        Tue, 14 May 2019 10:25:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydFCl/p7p0seRiLL3QKnOahliH+7FalkscMHt7oFhwC8t58ScKUpI/1dYRaDSwVV5lhOUG
X-Received: by 2002:a62:fc56:: with SMTP id e83mr3171325pfh.27.1557854750041;
        Tue, 14 May 2019 10:25:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557854750; cv=none;
        d=google.com; s=arc-20160816;
        b=qoySV5JMrZgEcVgxGiH9i/nT2y5r7D4dphDOA2pMEUYMnU4qT6Mkk6SA5adSeHBoWO
         3hm+3k29ThS7e1h1B6fyHINTNYFz9CG3pNoXnlSMjQ0nO7NbbEdJCDwswLmER2M1AwAM
         0TUXFRJn8MdHLqCtoaLBmA5cdMU+53Pif0ytmF0GiA51jbIH8XfxDwgiZT+R5d6VczXX
         D7MKEQMyDjSaG0KJPc1GAixpjd4qFFS/+lbJWdVXRRG7KyDCNstTC3kTYJBsb5JJqTSQ
         fH/5W3snvBay5BcxkvIwTFEBPR+i1xvhr8aYaWJ5k1mqYQwBTrh9lhI4bARAj8qezFY6
         C/VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0yhDS6xEOFGbhUYlW6OLQutQI+Jr+pZfSaEGSPPsQEU=;
        b=vxp8PHzLSNQCwLAmEL9rtphZe8K/Qq8QiirT1dgNZHZ8/spWXcNZ6ZtuytNAuQD6Fs
         Nshgez47V6AILl9Yyua6roU4bGtgmSqVB5Hum8DCtx18jl90mSOhMOUki+hSolradMZe
         IqAbigLskqhXG4GqBZSCMkS+tFkH9goyIks72wWrG7jI6FzBWsvzIjMxf6qWLsPOHRGZ
         b/YXNRPPPbIb/ns/NylGdkqYrmQMDiIu7dtTqfs28Zs9h/ehAkRgjk7ityzyggJcE6bU
         001U7VJ0Yzb+uSc47y8ft9MB5mvnTBnPRevYdFzbo8f4qgAovsDW6XNMbrZJbXetXwlh
         g+TA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id v1si20361485plo.191.2019.05.14.10.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 10:25:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R761e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TRk4ZGG_1557854744;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRk4ZGG_1557854744)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 15 May 2019 01:25:47 +0800
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
To: Will Deacon <will.deacon@arm.com>
Cc: jstancek@redhat.com, peterz@infradead.org, namit@vmware.com,
 minchan@kernel.org, mgorman@suse.de, stable@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513163804.GB10754@fuggles.cambridge.arm.com>
 <360170d7-b16f-f130-f930-bfe54be9747a@linux.alibaba.com>
 <20190514145445.GB2825@fuggles.cambridge.arm.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <21905828-d08d-a9a7-5ff9-2383f4fdce0f@linux.alibaba.com>
Date: Tue, 14 May 2019 10:25:43 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190514145445.GB2825@fuggles.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/14/19 7:54 AM, Will Deacon wrote:
> On Mon, May 13, 2019 at 04:01:09PM -0700, Yang Shi wrote:
>>
>> On 5/13/19 9:38 AM, Will Deacon wrote:
>>> On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
>>>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>>>> index 99740e1..469492d 100644
>>>> --- a/mm/mmu_gather.c
>>>> +++ b/mm/mmu_gather.c
>>>> @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>>>>    {
>>>>    	/*
>>>>    	 * If there are parallel threads are doing PTE changes on same range
>>>> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
>>>> -	 * flush by batching, a thread has stable TLB entry can fail to flush
>>>> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
>>>> -	 * forcefully if we detect parallel PTE batching threads.
>>>> +	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
>>>> +	 * flush by batching, one thread may end up seeing inconsistent PTEs
>>>> +	 * and result in having stale TLB entries.  So flush TLB forcefully
>>>> +	 * if we detect parallel PTE batching threads.
>>>> +	 *
>>>> +	 * However, some syscalls, e.g. munmap(), may free page tables, this
>>>> +	 * needs force flush everything in the given range. Otherwise this
>>>> +	 * may result in having stale TLB entries for some architectures,
>>>> +	 * e.g. aarch64, that could specify flush what level TLB.
>>>>    	 */
>>>> -	if (mm_tlb_flush_nested(tlb->mm)) {
>>>> -		__tlb_reset_range(tlb);
>>>> -		__tlb_adjust_range(tlb, start, end - start);
>>>> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
>>>> +		/*
>>>> +		 * Since we can't tell what we actually should have
>>>> +		 * flushed, flush everything in the given range.
>>>> +		 */
>>>> +		tlb->freed_tables = 1;
>>>> +		tlb->cleared_ptes = 1;
>>>> +		tlb->cleared_pmds = 1;
>>>> +		tlb->cleared_puds = 1;
>>>> +		tlb->cleared_p4ds = 1;
>>>> +
>>>> +		/*
>>>> +		 * Some architectures, e.g. ARM, that have range invalidation
>>>> +		 * and care about VM_EXEC for I-Cache invalidation, need force
>>>> +		 * vma_exec set.
>>>> +		 */
>>>> +		tlb->vma_exec = 1;
>>>> +
>>>> +		/* Force vma_huge clear to guarantee safer flush */
>>>> +		tlb->vma_huge = 0;
>>>> +
>>>> +		tlb->start = start;
>>>> +		tlb->end = end;
>>>>    	}
>>> Whilst I think this is correct, it would be interesting to see whether
>>> or not it's actually faster than just nuking the whole mm, as I mentioned
>>> before.
>>>
>>> At least in terms of getting a short-term fix, I'd prefer the diff below
>>> if it's not measurably worse.
>> I did a quick test with ebizzy (96 threads with 5 iterations) on my x86 VM,
>> it shows slightly slowdown on records/s but much more sys time spent with
>> fullmm flush, the below is the data.
>>
>>                                      nofullmm                 fullmm
>> ops (records/s)              225606                  225119
>> sys (s)                            0.69                        1.14
>>
>> It looks the slight reduction of records/s is caused by the increase of sys
>> time.
> That's not what I expected, and I'm unable to explain why moving to fullmm
> would /increase/ the system time. I would've thought the time spent doing
> the invalidation would decrease, with the downside that the TLB is cold
> when returning back to userspace.
>
> FWIW, I ran 10 iterations of ebizzy on my arm64 box using a vanilla 5.1
> kernel and the numbers are all over the place (see below). I think
> deducing anything meaningful from this benchmark will be a challenge.

Yes, it looks so. What else benchmark do you suggest?

>
> Will
>
> --->8
>
> 306090 records/s
> real 10.00 s
> user 1227.55 s
> sys   0.54 s
> 323547 records/s
> real 10.00 s
> user 1262.95 s
> sys   0.82 s
> 409148 records/s
> real 10.00 s
> user 1266.54 s
> sys   0.94 s
> 341507 records/s
> real 10.00 s
> user 1263.49 s
> sys   0.66 s
> 375910 records/s
> real 10.00 s
> user 1259.87 s
> sys   0.82 s
> 376152 records/s
> real 10.00 s
> user 1265.76 s
> sys   0.96 s
> 358862 records/s
> real 10.00 s
> user 1251.13 s
> sys   0.72 s
> 358164 records/s
> real 10.00 s
> user 1243.48 s
> sys   0.85 s
> 332148 records/s
> real 10.00 s
> user 1260.93 s
> sys   0.70 s
> 367021 records/s
> real 10.00 s
> user 1264.06 s
> sys   1.43 s

