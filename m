Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83BA0C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:22:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39A4B217D7
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:22:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39A4B217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD8E96B0003; Thu,  9 May 2019 14:22:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B89726B0006; Thu,  9 May 2019 14:22:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A78266B0007; Thu,  9 May 2019 14:22:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9EA6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 14:22:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l16so2115756pfb.23
        for <linux-mm@kvack.org>; Thu, 09 May 2019 11:22:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=mnmouUtKMX0JwjrZ/Qz1fplep/p5DYJz/EuSS62dbLo=;
        b=atscZN/x1h5+iFZrB7KJ7emJ1km836y/lLI4+8AIzFdcgrOCq77RdMvFzWyRvTLpPE
         qG1cVR1L1Q2qlsso64dA0axeFi0GvMObqBJ//3aUTwMEy955RHzpFJuVsTG1PPTJhaaP
         P3lBvFPgM3oCMpQJyCffg/9MeH/3cakw8PLKHTySALNs5NF9NLzHxyTHfZYxeeU332oi
         hWsPL/8xA71ctjD9ohmMrfXSaIUHyJMNBGWzPRxRK85DBaNRy9qv+3DtgX0N4byrHWwq
         brnwo4ldRPG1ySz3d8Ok4REOXAr5yolempObbTTlp54mBkMWYmksQtfpFXjYMEW9Lbvu
         9/YA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVl3NQu42RT6N1cRdfX2FbMCun6/YdGVgyraB9bswxikWhfYybK
	GXtBBgZELJ+qewfO6kyTsV4VVFzjN8iPauj33CNARLpY1sXn81ApJGGYVVRZbi/JH2wdJGDouJg
	2Bl0WWM4xVuHfD7AvZ2Tp6i/iHK6HBnSY2hQnJwkllp6JmM4Z8Xuf/Nu4we3u5Wda3Q==
X-Received: by 2002:aa7:8493:: with SMTP id u19mr7242014pfn.233.1557426166070;
        Thu, 09 May 2019 11:22:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDw9lSuEkXdYxcLTRDYnwRapN5ZQMyGrH66qHF8zygsZDU1dDjNETASXCQwb0AQKu8Yslq
X-Received: by 2002:aa7:8493:: with SMTP id u19mr7241885pfn.233.1557426164959;
        Thu, 09 May 2019 11:22:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557426164; cv=none;
        d=google.com; s=arc-20160816;
        b=nWCaO44mvR6jAKXq6fGXbfVstSNmHtWN894WKP6smuD883+Qt+ynvPdmeeYmYNTiK4
         f+UjbrNYkn6tXJrWQHQRKV1VQEgKw9IJZvzbU/07tiOsBIM2Ft2hxlxqpL651NJXxEGO
         mDOf4PQkAf3H+5+s0hPhoNYJO7CGRj618KeTU20yWC4mwR+S25299oGFCZt+Udw5qxwv
         FOrvYuVSazrQUki8MTSscLWd1frV8sXMg1KIZhk1X+WPGHaRHPC7wb18oJthgyTqvzqE
         L1DX84ov9z/cbmc8qN1pHZUqZZ9T8b2uhCKXxXH1E05Iq+FYDMmzbO9fxSr47DHHvbwd
         hOJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=mnmouUtKMX0JwjrZ/Qz1fplep/p5DYJz/EuSS62dbLo=;
        b=Iz71sdMQYdMGFBicCB073/gtAFkxmOqPW9SIEta6BO52SGt+UB8IMOPGOEf8M/vseY
         Vzx7HnmBlpxQBmU3fKC6j/EwaDlPPtvzBMH1nKUHgDGfSUvLq0InI4JhGaJKzIpht2xr
         XGeDQNbOE5gs/4uFiBqpjvkNv3mW5KoKbflWE5avvKX+3Qqm0W4sUP0EValH7IlH17AX
         UekRJOsQ0+rIthdj13anCa4sGvcQVsknHMWi0fOWFTBb/cAUaXB4tnhhODx5atLnZZtq
         gmKVjv2sBIf1IInVzgrejYQcwl4skVdyG+XnWwBynr95NQrv6NMjHMpKZrh90TkJmq6E
         znoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id s7si4121114pgr.287.2019.05.09.11.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 11:22:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TRHI4lD_1557426158;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRHI4lD_1557426158)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 02:22:41 +0800
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
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <df1247c3-a5dc-e4aa-cf0f-674f74f31d1f@linux.alibaba.com>
Date: Thu, 9 May 2019 11:22:37 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190509103813.GP2589@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/9/19 3:38 AM, Peter Zijlstra wrote:
> On Thu, May 09, 2019 at 09:37:26AM +0100, Will Deacon wrote:
>> Hi all, [+Peter]
> Right, mm/mmu_gather.c has a MAINTAINERS entry; use it.

Sorry for that, I didn't realize we have mmu_gather maintainers. I 
should run maintainer.pl.

>
> Also added Nadav and Minchan who've poked at this issue before. And Mel,
> because he loves these things :-)
>
>> Apologies for the delay; I'm attending a conference this week so it's tricky
>> to keep up with email.
>>
>> On Wed, May 08, 2019 at 05:34:49AM +0800, Yang Shi wrote:
>>> A few new fields were added to mmu_gather to make TLB flush smarter for
>>> huge page by telling what level of page table is changed.
>>>
>>> __tlb_reset_range() is used to reset all these page table state to
>>> unchanged, which is called by TLB flush for parallel mapping changes for
>>> the same range under non-exclusive lock (i.e. read mmap_sem).  Before
>>> commit dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in
>>> munmap"), MADV_DONTNEED is the only one who may do page zapping in
>>> parallel and it doesn't remove page tables.  But, the forementioned commit
>>> may do munmap() under read mmap_sem and free page tables.  This causes a
>>> bug [1] reported by Jan Stancek since __tlb_reset_range() may pass the
> Please don't _EVER_ refer to external sources to describe the actual bug
> a patch is fixing. That is the primary purpose of the Changelog.
>
> Worse, the email you reference does _NOT_ describe the actual problem.
> Nor do you.

Sure, will articulate the real bug in the commit log.

>
>>> wrong page table state to architecture specific TLB flush operations.
>> Yikes. Is it actually safe to run free_pgtables() concurrently for a given
>> mm?
> Yeah.. sorta.. it's been a source of 'interesting' things. This really
> isn't the first issue here.
>
> Also, change_protection_range() is 'fun' too.
>
>>> So, removing __tlb_reset_range() sounds sane.  This may cause more TLB
>>> flush for MADV_DONTNEED, but it should be not called very often, hence
>>> the impact should be negligible.
>>>
>>> The original proposed fix came from Jan Stancek who mainly debugged this
>>> issue, I just wrapped up everything together.
>> I'm still paging the nested flush logic back in, but I have some comments on
>> the patch below.
>>
>>> [1] https://lore.kernel.org/linux-mm/342bf1fd-f1bf-ed62-1127-e911b5032274@linux.alibaba.com/T/#m7a2ab6c878d5a256560650e56189cfae4e73217f
>>>
>>> Reported-by: Jan Stancek <jstancek@redhat.com>
>>> Tested-by: Jan Stancek <jstancek@redhat.com>
>>> Cc: Will Deacon <will.deacon@arm.com>
>>> Cc: stable@vger.kernel.org
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> Signed-off-by: Jan Stancek <jstancek@redhat.com>
>>> ---
>>>   mm/mmu_gather.c | 7 ++++---
>>>   1 file changed, 4 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>>> index 99740e1..9fd5272 100644
>>> --- a/mm/mmu_gather.c
>>> +++ b/mm/mmu_gather.c
>>> @@ -249,11 +249,12 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>>>   	 * flush by batching, a thread has stable TLB entry can fail to flush
>> Urgh, we should rewrite this comment while we're here so that it makes sense...
> Yeah, that's atrocious. We should put the actual race in there.
>
>>>   	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
>>>   	 * forcefully if we detect parallel PTE batching threads.
>>> +	 *
>>> +	 * munmap() may change mapping under non-excluse lock and also free
>>> +	 * page tables.  Do not call __tlb_reset_range() for it.
>>>   	 */
>>> -	if (mm_tlb_flush_nested(tlb->mm)) {
>>> -		__tlb_reset_range(tlb);
>>> +	if (mm_tlb_flush_nested(tlb->mm))
>>>   		__tlb_adjust_range(tlb, start, end - start);
>>> -	}
>> I don't think we can elide the call __tlb_reset_range() entirely, since I
>> think we do want to clear the freed_pXX bits to ensure that we walk the
>> range with the smallest mapping granule that we have. Otherwise couldn't we
>> have a problem if we hit a PMD that had been cleared, but the TLB
>> invalidation for the PTEs that used to be linked below it was still pending?
> That's tlb->cleared_p*, and yes agreed. That is, right until some
> architecture has level dependent TLBI instructions, at which point we'll
> need to have them all set instead of cleared.
>
>> Perhaps we should just set fullmm if we see that here's a concurrent
>> unmapper rather than do a worst-case range invalidation. Do you have a feeling
>> for often the mm_tlb_flush_nested() triggers in practice?
> Quite a bit for certain workloads I imagine, that was the whole point of
> doing it.
>
> Anyway; am I correct in understanding that the actual problem is that
> we've cleared freed_tables and the ARM64 tlb_flush() will then not
> invalidate the cache and badness happens?

Yes.

>
> Because so far nobody has actually provided a coherent description of
> the actual problem we're trying to solve. But I'm thinking something
> like the below ought to do.

Thanks for the suggestion, will do in v2.

>
>
> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index 99740e1dd273..fe768f8d612e 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>   		unsigned long start, unsigned long end)
>   {
>   	/*
> -	 * If there are parallel threads are doing PTE changes on same range
> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> -	 * flush by batching, a thread has stable TLB entry can fail to flush
> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> -	 * forcefully if we detect parallel PTE batching threads.
> +	 * Sensible comment goes here..
>   	 */
> -	if (mm_tlb_flush_nested(tlb->mm)) {
> -		__tlb_reset_range(tlb);
> -		__tlb_adjust_range(tlb, start, end - start);
> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
> +		/*
> +		 * Since we're can't tell what we actually should have
> +		 * flushed flush everything in the given range.
> +		 */
> +		tlb->start = start;
> +		tlb->end = end;
> +		tlb->freed_tables = 1;
> +		tlb->cleared_ptes = 1;
> +		tlb->cleared_pmds = 1;
> +		tlb->cleared_puds = 1;
> +		tlb->cleared_p4ds = 1;
>   	}
>   
>   	tlb_flush_mmu(tlb);

