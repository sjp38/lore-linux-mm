Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1757C04AB4
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:00:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4782720644
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:00:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4782720644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8465C6B0005; Sun, 19 May 2019 23:00:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F6536B0006; Sun, 19 May 2019 23:00:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E4E16B0007; Sun, 19 May 2019 23:00:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 425BE6B0005
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:00:07 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id v3so4275155oia.14
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:00:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=JWvs5+SZt/bFewaGcWX+wHkUwjOAhQ8hGzdpkMcVXn0=;
        b=PpD555lOK0799kLo8z65nrQuwVh1m93+kC6l0P5yBMnLcKFxJZ8954MieaL8DYsz5A
         jDTOTPTHz3Q2szHtQAve4caCJ8VCT8oY2N7fAr8p8RwGgWYft3AmjjOSmOWEFIJg4P0r
         y4DJIRGUYdP/TmEwtwjfezcn+bYBm48xGLhTaMcoT/8qVjOJAtZRrHb6vlIYU3xhcYcK
         1vpvh4cZblhdXjfmIuhrvcTRK57TUTSFnX1ypn9wZYazS5lB42qQqjwSEpgMPg7RFBqo
         s/8tDJR4YzpXP0BYL9j6rNo0ArmYjFclNBgzCsC+urEvFHVhEJeXJWuQUUp/RLmVtCFh
         HGwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVZZMqCWz3LfEnbmsuxggagvHKXrZCtnNpvpA7IZ+Yo1uGVsJSd
	II1pul+DfcWMi6+qAwqqBiz+kiL1nbVGKHAIhy2itUrIThMmuLhojT52qRW19niUYqsXV/Wy1d2
	xFa6d5pgf2HuZt6jV5+9ZQ/W7uv4ha0cs9di9i5U4+mJ/c0gLHsZ+X68boKLUvrF74w==
X-Received: by 2002:a9d:6c0a:: with SMTP id f10mr6647731otq.36.1558321206886;
        Sun, 19 May 2019 20:00:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyO9MSbjiArJNCa6TGV2bjsKysGmW7VPmzOl7QHSOXqyuConJG7fo9QJAikBpe6rSnZr6x/
X-Received: by 2002:a9d:6c0a:: with SMTP id f10mr6647678otq.36.1558321205946;
        Sun, 19 May 2019 20:00:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558321205; cv=none;
        d=google.com; s=arc-20160816;
        b=VlmHkrC7Dc9RXBTi9nVSYzSJmEkqo5fIYboGE47sJNttYoYVqKQPSvxyyMtjt3s2w/
         L37WL1+SQOrTnMjzvqtgqMashn+rEyTQiJukXDzzOpjSsg1xwUTjZqBoGaNC0DXFtU9N
         fbwM4R+TZl4EMqQ0KIKyzX5AvYWQTvYAoQjMW+YXjcBdR8H3scAG1liRjg7ac8wFQJZe
         rUL34/0iu5HYaNbq2obkhow5lzbdxmd64PX/8eHCE66dm00/lmjgt1T2S1j+abdu9K/F
         eG3iKKoN74jS0TT+MpJ+L7utbkQQlNIDO92MnAvq70vGLqx7iakOn9vgJEjXm++TEveS
         ZJQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=JWvs5+SZt/bFewaGcWX+wHkUwjOAhQ8hGzdpkMcVXn0=;
        b=A4YS0a1z/YE9BMrtrKkfJLu2u33TTNU7K27Zys4vLPtEdVku5T08srCsk8pMcgfXEZ
         WY1mcK3BU92Tcqom99EcqmryEWpar28H0jP92L13fsHFs9zDKG9ZM64UR9ci3YESMN+f
         06XdpKjyvQB7lY/PPhs/x2Q3dZWwJmYMwOKO/E7v1R2EDoRSqXk2HLgKqHfNn1iUief6
         CjAwXcJ8DAxsS80Y1oSj4us7SfykgMypA/MOOHMI8I6bN7RqyOJoJFLVnp1jwksHced+
         Ks9DQe0pkpivADvLrCZawkZFqYZqfSTpIsLfoiNd3blmPj+EtIiSapLl/t0Yocuv0XA5
         gbsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id f45si10045127otf.253.2019.05.19.20.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:00:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TSAtmJS_1558321155;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSAtmJS_1558321155)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 20 May 2019 10:59:45 +0800
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
To: Jan Stancek <jstancek@redhat.com>, Will Deacon <will.deacon@arm.com>
Cc: peterz@infradead.org, namit@vmware.com, minchan@kernel.org,
 mgorman@suse.de, stable@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513163804.GB10754@fuggles.cambridge.arm.com>
 <360170d7-b16f-f130-f930-bfe54be9747a@linux.alibaba.com>
 <20190514145445.GB2825@fuggles.cambridge.arm.com>
 <1158926942.23199905.1558020575293.JavaMail.zimbra@redhat.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ca6ab067-1d0c-941d-9c8b-7806af3521be@linux.alibaba.com>
Date: Mon, 20 May 2019 10:59:07 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1158926942.23199905.1558020575293.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/16/19 11:29 PM, Jan Stancek wrote:
>
> ----- Original Message -----
>> On Mon, May 13, 2019 at 04:01:09PM -0700, Yang Shi wrote:
>>>
>>> On 5/13/19 9:38 AM, Will Deacon wrote:
>>>> On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
>>>>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>>>>> index 99740e1..469492d 100644
>>>>> --- a/mm/mmu_gather.c
>>>>> +++ b/mm/mmu_gather.c
>>>>> @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>>>>>    {
>>>>>    	/*
>>>>>    	 * If there are parallel threads are doing PTE changes on same range
>>>>> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
>>>>> -	 * flush by batching, a thread has stable TLB entry can fail to flush
>>>>> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
>>>>> -	 * forcefully if we detect parallel PTE batching threads.
>>>>> +	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
>>>>> +	 * flush by batching, one thread may end up seeing inconsistent PTEs
>>>>> +	 * and result in having stale TLB entries.  So flush TLB forcefully
>>>>> +	 * if we detect parallel PTE batching threads.
>>>>> +	 *
>>>>> +	 * However, some syscalls, e.g. munmap(), may free page tables, this
>>>>> +	 * needs force flush everything in the given range. Otherwise this
>>>>> +	 * may result in having stale TLB entries for some architectures,
>>>>> +	 * e.g. aarch64, that could specify flush what level TLB.
>>>>>    	 */
>>>>> -	if (mm_tlb_flush_nested(tlb->mm)) {
>>>>> -		__tlb_reset_range(tlb);
>>>>> -		__tlb_adjust_range(tlb, start, end - start);
>>>>> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
>>>>> +		/*
>>>>> +		 * Since we can't tell what we actually should have
>>>>> +		 * flushed, flush everything in the given range.
>>>>> +		 */
>>>>> +		tlb->freed_tables = 1;
>>>>> +		tlb->cleared_ptes = 1;
>>>>> +		tlb->cleared_pmds = 1;
>>>>> +		tlb->cleared_puds = 1;
>>>>> +		tlb->cleared_p4ds = 1;
>>>>> +
>>>>> +		/*
>>>>> +		 * Some architectures, e.g. ARM, that have range invalidation
>>>>> +		 * and care about VM_EXEC for I-Cache invalidation, need force
>>>>> +		 * vma_exec set.
>>>>> +		 */
>>>>> +		tlb->vma_exec = 1;
>>>>> +
>>>>> +		/* Force vma_huge clear to guarantee safer flush */
>>>>> +		tlb->vma_huge = 0;
>>>>> +
>>>>> +		tlb->start = start;
>>>>> +		tlb->end = end;
>>>>>    	}
>>>> Whilst I think this is correct, it would be interesting to see whether
>>>> or not it's actually faster than just nuking the whole mm, as I mentioned
>>>> before.
>>>>
>>>> At least in terms of getting a short-term fix, I'd prefer the diff below
>>>> if it's not measurably worse.
>>> I did a quick test with ebizzy (96 threads with 5 iterations) on my x86 VM,
>>> it shows slightly slowdown on records/s but much more sys time spent with
>>> fullmm flush, the below is the data.
>>>
>>>                                      nofullmm                 fullmm
>>> ops (records/s)              225606                  225119
>>> sys (s)                            0.69                        1.14
>>>
>>> It looks the slight reduction of records/s is caused by the increase of sys
>>> time.
>> That's not what I expected, and I'm unable to explain why moving to fullmm
>> would /increase/ the system time. I would've thought the time spent doing
>> the invalidation would decrease, with the downside that the TLB is cold
>> when returning back to userspace.
>>
> I tried ebizzy with various parameters (malloc vs mmap, ran it for hour),
> but performance was very similar for both patches.
>
> So, I was looking for workload that would demonstrate the largest difference.
> Inspired by python xml-rpc, which can handle each request in new thread,
> I tried following [1]:
>
> 16 threads, each looping 100k times over:
>    mmap(16M)
>    touch 1 page
>    madvise(DONTNEED)
>    munmap(16M)
>
> This yields quite significant difference for 2 patches when running on
> my 46 CPU arm host. I checked it twice - applied patch, recompiled, rebooted,
> but numbers stayed +- couple seconds the same.

Thanks for the testing. I'm a little bit surprised by the significant 
difference.

I did the same test on my x86 VM (24 cores), they yield almost same number.

Given the significant improvement on arm64 with fullmm version, I'm 
going to respin the patch.

>
> Does it somewhat match your expectation?
>
> v2 patch
> ---------
> real    2m33.460s
> user    0m3.359s
> sys     15m32.307s
>
> real    2m33.895s
> user    0m2.749s
> sys     16m34.500s
>
> real    2m35.666s
> user    0m3.528s
> sys     15m23.377s
>
> real    2m32.898s
> user    0m2.789s
> sys     16m18.801s
>
> real    2m33.087s
> user    0m3.565s
> sys     16m23.815s
>
>
> fullmm version
> ---------------
> real    0m46.811s
> user    0m1.596s
> sys     1m47.500s
>
> real    0m47.322s
> user    0m1.803s
> sys     1m48.449s
>
> real    0m46.668s
> user    0m1.508s
> sys     1m47.352s
>
> real    0m46.742s
> user    0m2.007s
> sys     1m47.217s
>
> real    0m46.948s
> user    0m1.785s
> sys     1m47.906s
>
> [1] https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/mmap8.c

