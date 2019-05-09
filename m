Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EAD2C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B034217D7
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:48:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B034217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B7F46B0006; Thu,  9 May 2019 17:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 967FD6B0007; Thu,  9 May 2019 17:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87ED06B0008; Thu,  9 May 2019 17:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51E086B0006
	for <linux-mm@kvack.org>; Thu,  9 May 2019 17:48:44 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e20so2510616pgm.16
        for <linux-mm@kvack.org>; Thu, 09 May 2019 14:48:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=OIQNx2d/+mVTowVXtcojaWTvLZRNQX8jh2h/mheu//g=;
        b=nVBHHhbpxZsTJSMrudNRxVpYlemL+1UdMn07iqGr9tLxLiNWD8DKflmHyaZKr4Svyp
         v0V4wgykZR7iQDwo9lvVRAKl1nk/eyM/39kOih1TPK0bVVpP5xsAzwXYZU7geTSdwjCk
         d5ByMNMqG9ngF9MpEWZoqK1b3B1RFXrd8IFi7wgXvWPiceuDpEcAhoL/1vWFj+bL0RF0
         LgpIPI2e0PuQExZHpUJtgzFsK6QIkv1+omma5pjkig0kb5kNlvjlGB7bsw2dA2xd8I4J
         GUKoaPmgQfGT5ehCrlHXlZOJ6IqSKO9tLeaP63UUiItiG6NrS7IZmN/YDlit1345FKfB
         xBuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX5/bCBkq8+c4qrWTlLeYGOaYvjf7+9s0r5DbrYB3+N68TanALN
	c0pZgmnOlFiKznjGeMqEzp1kyA4la/hOsNaY3G41Vu8ia+5AK01LelLL4c2qfOPdvWGwFNjDcEb
	ffZHC3StaimCI4Vq6ZwF3SZfb9oF4PZnQ1ZNXFavNDGchRSgUNXqDvdTEc8AGLjfHvg==
X-Received: by 2002:a63:cf:: with SMTP id 198mr8574856pga.228.1557438523887;
        Thu, 09 May 2019 14:48:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+/kcUlbUSRnWYvMvhqNrFQHbSQm5M4sHX4Ia/KSt1golcUmwi/3CJL8/AjdSpuSaVu/QT
X-Received: by 2002:a63:cf:: with SMTP id 198mr8574791pga.228.1557438522921;
        Thu, 09 May 2019 14:48:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557438522; cv=none;
        d=google.com; s=arc-20160816;
        b=gVVhN4wN2qBKfM9Bib/bdusNspUAyB9RYbDCokQm2JCvsY6zod/FCWB0dFKUd0qNDo
         kOixwHULEy+HS2pBC1td2ymc/1s4P9aZMq/r8+JH/rkE1La1qpHt+QP6pgMDWfIX3Slg
         PtRNB0/uweC2Ys33NLotLTcUXPEWWhkZ7mf+vXr7Qy/4bQ/Sae+/tmGwX9hZgD3BARfC
         y3iY4R6Odz1JNPvQinPzQ5M5wJQ8afD8yIxmMYc2Xr+0KdozZ1/hJOJAL43YjPReLo0f
         2sTNMqBPoLwEEs6u+y1kw2RVol7M96EDntPC9nt8wnZyHAfLPTDfqy3HvWT4/xmkQrvG
         NLVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=OIQNx2d/+mVTowVXtcojaWTvLZRNQX8jh2h/mheu//g=;
        b=NKEfbbKz5h9Zw7/ivM7ZJ6mlgrgx1cqBNng4JyDeG5Ycit+sJHdWoiCpweepe365OM
         PfVojg5qQzuoXiTKwlAfxqwOERVED11LOdWpn+rbUfy+qWkjD3saaPxzg/RdhBZD/hsL
         2Ivvj8h7QL361B01NJ1hfM08JyOIyUyYI4FIM6crXEROKzBTDQpEtgtNVcsSBAsTWonr
         XA4QslNWLz2R8tyUsQVtA16yUcO/ieRVSrt5DkOHk40TYBYTYBRWFaS2cqr+MER7MEWQ
         jJvbVkGSoRe2k056UQ4qROcVn4e7zboUO54uCNXFvFkzd5XR4HEThQiAmyLZxQkSrL6X
         3c0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id c25si4948368pfr.94.2019.05.09.14.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 14:48:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TRHcHwW_1557438515;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRHcHwW_1557438515)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 05:48:39 +0800
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
To: Jan Stancek <jstancek@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Nadav Amit <namit@vmware.com>, Will Deacon <will.deacon@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, npiggin@gmail.com,
 minchan@kernel.org, Mel Gorman <mgorman@suse.de>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <84720bb8-bf3d-8c10-d675-0670f13b2efc@linux.alibaba.com>
 <249230644.21949166.1557435998550.JavaMail.zimbra@redhat.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6f606e4f-d151-0c43-11f4-4a78e6dfabbf@linux.alibaba.com>
Date: Thu, 9 May 2019 14:48:35 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <249230644.21949166.1557435998550.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/9/19 2:06 PM, Jan Stancek wrote:
> ----- Original Message -----
>>
>> On 5/9/19 11:24 AM, Peter Zijlstra wrote:
>>> On Thu, May 09, 2019 at 05:36:29PM +0000, Nadav Amit wrote:
>>>>> On May 9, 2019, at 3:38 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>>>>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>>>>> index 99740e1dd273..fe768f8d612e 100644
>>>>> --- a/mm/mmu_gather.c
>>>>> +++ b/mm/mmu_gather.c
>>>>> @@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>>>>> 		unsigned long start, unsigned long end)
>>>>> {
>>>>> 	/*
>>>>> -	 * If there are parallel threads are doing PTE changes on same range
>>>>> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
>>>>> -	 * flush by batching, a thread has stable TLB entry can fail to flush
>>>>> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
>>>>> -	 * forcefully if we detect parallel PTE batching threads.
>>>>> +	 * Sensible comment goes here..
>>>>> 	 */
>>>>> -	if (mm_tlb_flush_nested(tlb->mm)) {
>>>>> -		__tlb_reset_range(tlb);
>>>>> -		__tlb_adjust_range(tlb, start, end - start);
>>>>> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
>>>>> +		/*
>>>>> +		 * Since we're can't tell what we actually should have
>>>>> +		 * flushed flush everything in the given range.
>>>>> +		 */
>>>>> +		tlb->start = start;
>>>>> +		tlb->end = end;
>>>>> +		tlb->freed_tables = 1;
>>>>> +		tlb->cleared_ptes = 1;
>>>>> +		tlb->cleared_pmds = 1;
>>>>> +		tlb->cleared_puds = 1;
>>>>> +		tlb->cleared_p4ds = 1;
>>>>> 	}
>>>>>
>>>>> 	tlb_flush_mmu(tlb);
>>>> As a simple optimization, I think it is possible to hold multiple nesting
>>>> counters in the mm, similar to tlb_flush_pending, for freed_tables,
>>>> cleared_ptes, etc.
>>>>
>>>> The first time you set tlb->freed_tables, you also atomically increase
>>>> mm->tlb_flush_freed_tables. Then, in tlb_flush_mmu(), you just use
>>>> mm->tlb_flush_freed_tables instead of tlb->freed_tables.
>>> That sounds fraught with races and expensive; I would much prefer to not
>>> go there for this arguably rare case.
>>>
>>> Consider such fun cases as where CPU-0 sees and clears a PTE, CPU-1
>>> races and doesn't see that PTE. Therefore CPU-0 sets and counts
>>> cleared_ptes. Then if CPU-1 flushes while CPU-0 is still in mmu_gather,
>>> it will see cleared_ptes count increased and flush that granularity,
>>> OTOH if CPU-1 flushes after CPU-0 completes, it will not and potentiall
>>> miss an invalidate it should have had.
>>>
>>> This whole concurrent mmu_gather stuff is horrible.
>>>
>>>     /me ponders more....
>>>
>>> So I think the fundamental race here is this:
>>>
>>> 	CPU-0				CPU-1
>>>
>>> 	tlb_gather_mmu(.start=1,	tlb_gather_mmu(.start=2,
>>> 		       .end=3);			       .end=4);
>>>
>>> 	ptep_get_and_clear_full(2)
>>> 	tlb_remove_tlb_entry(2);
>>> 	__tlb_remove_page();
>>> 					if (pte_present(2)) // nope
>>>
>>> 					tlb_finish_mmu();
>>>
>>> 					// continue without TLBI(2)
>>> 					// whoopsie
>>>
>>> 	tlb_finish_mmu();
>>> 	  tlb_flush()		->	TLBI(2)
>> I'm not quite sure if this is the case Jan really met. But, according to
>> his test, once correct tlb->freed_tables and tlb->cleared_* are set, his
>> test works well.
> My theory was following sequence:
>
> t1: map_write_unmap()                 t2: dummy()
>
>    map_address = mmap()
>    map_address[i] = 'b'
>    munmap(map_address)
>    downgrade_write(&mm->mmap_sem);
>    unmap_region()
>    tlb_gather_mmu()
>      inc_tlb_flush_pending(tlb->mm);
>    free_pgtables()
>      tlb->freed_tables = 1
>      tlb->cleared_pmds = 1
>
>                                          pthread_exit()
>                                          madvise(thread_stack, 8M, MADV_DONTNEED)

I'm not quite familiar with the implementation detail of pthread_exit(), 
does pthread_exit() call MADV_DONTNEED all the time? I don't see your 
test call it. If so this pattern is definitely possible.

>                                            zap_page_range()
>                                              tlb_gather_mmu()
>                                                inc_tlb_flush_pending(tlb->mm);
>
>    tlb_finish_mmu()
>      if (mm_tlb_flush_nested(tlb->mm))
>        __tlb_reset_range()
>          tlb->freed_tables = 0
>          tlb->cleared_pmds = 0
>      __flush_tlb_range(last_level = 0)
>    ...
>    map_address = mmap()
>      map_address[i] = 'b'
>        <page fault loop>
>        # PTE appeared valid to me,
>        # so I suspected stale TLB entry at higher level as result of "freed_tables = 0"
>
>
> I'm happy to apply/run any debug patches to get more data that would help.
>
>>>
>>> And we can fix that by having tlb_finish_mmu() sync up. Never let a
>>> concurrent tlb_finish_mmu() complete until all concurrenct mmu_gathers
>>> have completed.
>> Not sure if this will scale well.
>>
>>> This should not be too hard to make happen.
>>

