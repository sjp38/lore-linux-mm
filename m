Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7520EC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 19:10:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 437E920656
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 19:10:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 437E920656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2A446B0003; Thu,  9 May 2019 15:10:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB3606B0006; Thu,  9 May 2019 15:10:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A534F6B0007; Thu,  9 May 2019 15:10:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 854056B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 15:10:23 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id v193so3003088itv.9
        for <linux-mm@kvack.org>; Thu, 09 May 2019 12:10:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=+5bN/ksySqKBSesJxdmmg0hvlpKokHjNtD46sWehC28=;
        b=AQiliF7EmrxR8klU9TlRI2aI7YK3PjPgKn42awGMKsANkGfrsGi5nc8+XJUGk2tnEH
         Sk9hVuxEcndM87ee9WV7UGO28Q9l8bG16cj2eQpPUhtfCzjyltTpkGdSrX6PIyueazv9
         zipwTcfKEchsW1FmjVQzFdUPqVhxKJ9+h3yVe4dnhinpsZgmmPOGGrTDNL3ChQmM/3pY
         +s7a+4Dz7UdKOKc5KqbF+xzXGa4vMd1Z1uKWnaJGQGF9PS3wBLbgQ+q6M6rF2jKrmYmj
         JvKZf/bGOnGMt0xiph9l0Uitj9YD50X1BBr8zwmM8Onxcco7t1JH4ZD17btv4pxVcQdZ
         +4jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXd7uDSu9T7URwLMKcSz/op0ZU4tSnA07udSQwovdEO/Dj1Op3V
	qJ3pBYI5L/JZ2pY1lCcfqhLeP8ED4T3ZZIWloBQjWRd0H26lrDiuOYSWBC2W9MMvKbInegBE/2+
	2M8Hcuj5M+x1afaQOGUn6/qdEBcfdS+/tV2hhLnJHS9/Qg/lP82bVve9sGRPAmxT96w==
X-Received: by 2002:a02:9565:: with SMTP id y92mr4855814jah.110.1557429023323;
        Thu, 09 May 2019 12:10:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJF4WiaEp0xKzS44Z8NECIGXLzZiJbIt1aJuHDLdvsCldtaCe7HRYLRJGNVTpfszxtm0LS
X-Received: by 2002:a02:9565:: with SMTP id y92mr4855730jah.110.1557429022188;
        Thu, 09 May 2019 12:10:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557429022; cv=none;
        d=google.com; s=arc-20160816;
        b=bGzrzj3s/UeJziRP/NhIhwe+5nxnJr1CkWVgjyxcmPhQu+bLht9TGYZkUrEkSjzv6/
         9dl3u9Oiketd3y5uK8zNaF4HC1b7S/wWW3WWE/1bUVYhO7avrx0Pw8K/IZyh0K1VPTDs
         PomqFIvReDuHu7B6NUTodsc6sbu5Z3kfAR4av5RHvUBEQ+2rTykiuibY4X98j+30DGNz
         yMUNjgwQnGqF8p8TSr8aFR2G2wDHWfnxzy67Va+zPBRrEV927xvmF+CY57TFFMljyC+6
         sI5iE22ur7aEz3AyGBZKYYf26WE7jYkhUSgg1fWnfLEmKMwcBlHVqt7Amth+W5zlJaIb
         tomA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+5bN/ksySqKBSesJxdmmg0hvlpKokHjNtD46sWehC28=;
        b=cAf/plIzaHlfSzxek/4W46buJq54n61gzvG/47U6zmBKcjTW12A+Xb2nPQmqm3l2xK
         mr/FoV9i9j7KIjEtcfKkHGtQD9zzhqfadY5JJG9HxGxeCuMF1oVMh7nXxKey+eHSxrSh
         HVaXn+93WIOhF5fJKFDaE39zpgCw2qDh+Vo11AoS45hqQKy6oWjFw/Qi6G0rqZeXIVtf
         2yUjFbPzptnCHHWd5c0L2nzRgLoQSnRKU6tEx/1ePs5hHcuZC+HP7T1gonJt/ianHIQN
         bIesbJHE6Z52ta3dEVkdh49+ti72OMLGGpZrj0ShYLuIsd9XwMbjy10W51FgLo1CCBRZ
         hQAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id 188si2027839ita.95.2019.05.09.12.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 12:10:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TRHKq3L_1557429003;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRHKq3L_1557429003)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 03:10:07 +0800
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
To: Peter Zijlstra <peterz@infradead.org>, Nadav Amit <namit@vmware.com>
Cc: Will Deacon <will.deacon@arm.com>,
 "jstancek@redhat.com" <jstancek@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 "stable@vger.kernel.org" <stable@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>,
 "npiggin@gmail.com" <npiggin@gmail.com>,
 "minchan@kernel.org" <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <84720bb8-bf3d-8c10-d675-0670f13b2efc@linux.alibaba.com>
Date: Thu, 9 May 2019 12:10:02 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190509182435.GA2623@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/9/19 11:24 AM, Peter Zijlstra wrote:
> On Thu, May 09, 2019 at 05:36:29PM +0000, Nadav Amit wrote:
>>> On May 9, 2019, at 3:38 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>>> index 99740e1dd273..fe768f8d612e 100644
>>> --- a/mm/mmu_gather.c
>>> +++ b/mm/mmu_gather.c
>>> @@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>>> 		unsigned long start, unsigned long end)
>>> {
>>> 	/*
>>> -	 * If there are parallel threads are doing PTE changes on same range
>>> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
>>> -	 * flush by batching, a thread has stable TLB entry can fail to flush
>>> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
>>> -	 * forcefully if we detect parallel PTE batching threads.
>>> +	 * Sensible comment goes here..
>>> 	 */
>>> -	if (mm_tlb_flush_nested(tlb->mm)) {
>>> -		__tlb_reset_range(tlb);
>>> -		__tlb_adjust_range(tlb, start, end - start);
>>> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
>>> +		/*
>>> +		 * Since we're can't tell what we actually should have
>>> +		 * flushed flush everything in the given range.
>>> +		 */
>>> +		tlb->start = start;
>>> +		tlb->end = end;
>>> +		tlb->freed_tables = 1;
>>> +		tlb->cleared_ptes = 1;
>>> +		tlb->cleared_pmds = 1;
>>> +		tlb->cleared_puds = 1;
>>> +		tlb->cleared_p4ds = 1;
>>> 	}
>>>
>>> 	tlb_flush_mmu(tlb);
>> As a simple optimization, I think it is possible to hold multiple nesting
>> counters in the mm, similar to tlb_flush_pending, for freed_tables,
>> cleared_ptes, etc.
>>
>> The first time you set tlb->freed_tables, you also atomically increase
>> mm->tlb_flush_freed_tables. Then, in tlb_flush_mmu(), you just use
>> mm->tlb_flush_freed_tables instead of tlb->freed_tables.
> That sounds fraught with races and expensive; I would much prefer to not
> go there for this arguably rare case.
>
> Consider such fun cases as where CPU-0 sees and clears a PTE, CPU-1
> races and doesn't see that PTE. Therefore CPU-0 sets and counts
> cleared_ptes. Then if CPU-1 flushes while CPU-0 is still in mmu_gather,
> it will see cleared_ptes count increased and flush that granularity,
> OTOH if CPU-1 flushes after CPU-0 completes, it will not and potentiall
> miss an invalidate it should have had.
>
> This whole concurrent mmu_gather stuff is horrible.
>
>    /me ponders more....
>
> So I think the fundamental race here is this:
>
> 	CPU-0				CPU-1
>
> 	tlb_gather_mmu(.start=1,	tlb_gather_mmu(.start=2,
> 		       .end=3);			       .end=4);
>
> 	ptep_get_and_clear_full(2)
> 	tlb_remove_tlb_entry(2);
> 	__tlb_remove_page();
> 					if (pte_present(2)) // nope
>
> 					tlb_finish_mmu();
>
> 					// continue without TLBI(2)
> 					// whoopsie
>
> 	tlb_finish_mmu();
> 	  tlb_flush()		->	TLBI(2)

I'm not quite sure if this is the case Jan really met. But, according to 
his test, once correct tlb->freed_tables and tlb->cleared_* are set, his 
test works well.

>
>
> And we can fix that by having tlb_finish_mmu() sync up. Never let a
> concurrent tlb_finish_mmu() complete until all concurrenct mmu_gathers
> have completed.

Not sure if this will scale well.

>
> This should not be too hard to make happen.

