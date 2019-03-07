Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B220C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 21:40:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB74420851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 21:40:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB74420851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 776948E0004; Thu,  7 Mar 2019 16:40:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 725DD8E0002; Thu,  7 Mar 2019 16:40:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 615CF8E0004; Thu,  7 Mar 2019 16:40:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35B258E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 16:40:27 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id i3so16549593qtc.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 13:40:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Bu74ToVAmovyJc0HjrYzpDAkT3Av0lUiygL4XkvkEtQ=;
        b=Tpy4fZ5kxN0ri3hBMgoPOyScwjWa/0fs17I0hfKZI14qyCALTydtPx4JIrSj0yBdhU
         fM8BHJc53LoD72wCkq+HkdmXfbbRp5Cwpj7K9nkRh1dnZ5K8PnCTlyrtoeDHDFN1U5XM
         kbSk/mOuOLjdVjka+7r7WWvJFdcnuJZZ8u4A9X34XDQuoAaeO74pdwSNXfg+NJCi2Sdl
         U99AtZhJqqmaUcmsrMQ2A8fQq01JJGn9bjv4T3fkQOcfI5GYGRlwnpWITsxWddl+7LPw
         0yUR1gIhqfrouJTfRRYOpZ99S2yWd4+vi8VGMfC9RLAWzKVBtKAQO/LpjPYTpT965pbA
         xdBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhCsAfkMljXu1+Pnrq+Wy5OJKdQERH6Aj+62t4fzv7YqOHlhTW
	qCEJ4Dtud3oOjCGKKwSwvq35N5BKNlJ9HBfHMNy5e7mPKGohbOaKjfKBC3weShq3HOXZ/ehNJnb
	ZqCNav9cpEVzfDiYVWIi2m9G5/c/fTRvKFo8wxw/sEK4BKiTpMxOpOraeoo7N9bB+BQ==
X-Received: by 2002:ac8:312c:: with SMTP id g41mr12309628qtb.22.1551994826874;
        Thu, 07 Mar 2019 13:40:26 -0800 (PST)
X-Google-Smtp-Source: APXvYqw3IVhf2GcmKQr1Zc83PqhJCx1e78g8fYQ2OuSnDQsDVyVf9rueDWFrTyh9SgNC4+0eOdFz
X-Received: by 2002:ac8:312c:: with SMTP id g41mr12309566qtb.22.1551994825830;
        Thu, 07 Mar 2019 13:40:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551994825; cv=none;
        d=google.com; s=arc-20160816;
        b=TxkrBK54JoBGCjxYlwgok0WyFgnz6iLuI8SXSCnRldt4JLGNmHVNosd3b3+9oOJQK6
         FDqKtjZEqXT5pbhs7bf6EqHal+EpEz3h6DRDoe2kIK6lCsOn6lNwOW1p5GNpFtxe8Y/X
         XVhDssJiycBcQy60614wARcSPve9dHot94BRSMnrvugNiMx82RywDFX859FVSl/3GX0T
         /HgmR/GGvX3kJAyLaCZ4qQK3VExfmA4bVykzok6/Nyj/W2GgVvHBsKJe/4xLzfid1glY
         kZtJiWC7pKrazlXBLw82HOMQ6lx9ZglkI+uutSX4E8f08BGmXQH5vMQ7kJpsb7K9Fw33
         eh7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Bu74ToVAmovyJc0HjrYzpDAkT3Av0lUiygL4XkvkEtQ=;
        b=vhFHgDasNyZP8c82s/N5CNs1ZqiO1g8/1zMXjZ52XSMyA/OLftG2XP04AbZI+UNO7I
         sV+PdbsSaLo0x/WqwP6GsEeY74d9OPL/I2no8tPMNqhpTYWb7CreMlSfdLU60WxGhkG4
         z0xMdJdvuUa1NVMoJsxLk3Lqsern5OR8Flez5u231XSs1pnrAd4D00DOQ1vY6T2ZVdOV
         Sc17wM+3kXUbXXpf99legF1a4xjTPN1OmqCz/OhkjURUuJnfCjALdvzqqKaE+vb5R8l3
         wAhJkO3/AHQF6uPzbsFVIWe6tXnaWGhLgfDE1/WI95z+pAHjHC2h87oCob6vJZcVaTKe
         kFuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si3115539qtp.312.2019.03.07.13.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 13:40:25 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EC4BE5F7A7;
	Thu,  7 Mar 2019 21:40:24 +0000 (UTC)
Received: from [10.36.116.67] (ovpn-116-67.ams2.redhat.com [10.36.116.67])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 453F160141;
	Thu,  7 Mar 2019 21:40:10 +0000 (UTC)
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
Date: Thu, 7 Mar 2019 22:40:09 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 07 Mar 2019 21:40:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.03.19 22:32, Alexander Duyck wrote:
> On Thu, Mar 7, 2019 at 11:30 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> On 07.03.19 20:23, Nitesh Narayan Lal wrote:
>>>
>>> On 3/7/19 1:30 PM, Alexander Duyck wrote:
>>>> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>>>>> This patch enables the kernel to scan the per cpu array
>>>>> which carries head pages from the buddy free list of order
>>>>> FREE_PAGE_HINTING_MIN_ORDER (MAX_ORDER - 1) by
>>>>> guest_free_page_hinting().
>>>>> guest_free_page_hinting() scans the entire per cpu array by
>>>>> acquiring a zone lock corresponding to the pages which are
>>>>> being scanned. If the page is still free and present in the
>>>>> buddy it tries to isolate the page and adds it to a
>>>>> dynamically allocated array.
>>>>>
>>>>> Once this scanning process is complete and if there are any
>>>>> isolated pages added to the dynamically allocated array
>>>>> guest_free_page_report() is invoked. However, before this the
>>>>> per-cpu array index is reset so that it can continue capturing
>>>>> the pages from buddy free list.
>>>>>
>>>>> In this patch guest_free_page_report() simply releases the pages back
>>>>> to the buddy by using __free_one_page()
>>>>>
>>>>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>>>> I'm pretty sure this code is not thread safe and has a few various issues.
>>>>
>>>>> ---
>>>>>  include/linux/page_hinting.h |   5 ++
>>>>>  mm/page_alloc.c              |   2 +-
>>>>>  virt/kvm/page_hinting.c      | 154 +++++++++++++++++++++++++++++++++++
>>>>>  3 files changed, 160 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
>>>>> index 90254c582789..d554a2581826 100644
>>>>> --- a/include/linux/page_hinting.h
>>>>> +++ b/include/linux/page_hinting.h
>>>>> @@ -13,3 +13,8 @@
>>>>>
>>>>>  void guest_free_page_enqueue(struct page *page, int order);
>>>>>  void guest_free_page_try_hinting(void);
>>>>> +extern int __isolate_free_page(struct page *page, unsigned int order);
>>>>> +extern void __free_one_page(struct page *page, unsigned long pfn,
>>>>> +                           struct zone *zone, unsigned int order,
>>>>> +                           int migratetype);
>>>>> +void release_buddy_pages(void *obj_to_free, int entries);
>>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>>> index 684d047f33ee..d38b7eea207b 100644
>>>>> --- a/mm/page_alloc.c
>>>>> +++ b/mm/page_alloc.c
>>>>> @@ -814,7 +814,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>>>>>   * -- nyc
>>>>>   */
>>>>>
>>>>> -static inline void __free_one_page(struct page *page,
>>>>> +inline void __free_one_page(struct page *page,
>>>>>                 unsigned long pfn,
>>>>>                 struct zone *zone, unsigned int order,
>>>>>                 int migratetype)
>>>>> diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
>>>>> index 48b4b5e796b0..9885b372b5a9 100644
>>>>> --- a/virt/kvm/page_hinting.c
>>>>> +++ b/virt/kvm/page_hinting.c
>>>>> @@ -1,5 +1,9 @@
>>>>>  #include <linux/mm.h>
>>>>>  #include <linux/page_hinting.h>
>>>>> +#include <linux/page_ref.h>
>>>>> +#include <linux/kvm_host.h>
>>>>> +#include <linux/kernel.h>
>>>>> +#include <linux/sort.h>
>>>>>
>>>>>  /*
>>>>>   * struct guest_free_pages- holds array of guest freed PFN's along with an
>>>>> @@ -16,6 +20,54 @@ struct guest_free_pages {
>>>>>
>>>>>  DEFINE_PER_CPU(struct guest_free_pages, free_pages_obj);
>>>>>
>>>>> +/*
>>>>> + * struct guest_isolated_pages- holds the buddy isolated pages which are
>>>>> + * supposed to be freed by the host.
>>>>> + * @pfn: page frame number for the isolated page.
>>>>> + * @order: order of the isolated page.
>>>>> + */
>>>>> +struct guest_isolated_pages {
>>>>> +       unsigned long pfn;
>>>>> +       unsigned int order;
>>>>> +};
>>>>> +
>>>>> +void release_buddy_pages(void *obj_to_free, int entries)
>>>>> +{
>>>>> +       int i = 0;
>>>>> +       int mt = 0;
>>>>> +       struct guest_isolated_pages *isolated_pages_obj = obj_to_free;
>>>>> +
>>>>> +       while (i < entries) {
>>>>> +               struct page *page = pfn_to_page(isolated_pages_obj[i].pfn);
>>>>> +
>>>>> +               mt = get_pageblock_migratetype(page);
>>>>> +               __free_one_page(page, page_to_pfn(page), page_zone(page),
>>>>> +                               isolated_pages_obj[i].order, mt);
>>>>> +               i++;
>>>>> +       }
>>>>> +       kfree(isolated_pages_obj);
>>>>> +}
>>>> You shouldn't be accessing __free_one_page without holding the zone
>>>> lock for the page. You might consider confining yourself to one zone
>>>> worth of hints at a time. Then you can acquire the lock once, and then
>>>> return the memory you have freed.
>>> That is correct.
>>>>
>>>> This is one of the reasons why I am thinking maybe a bit in the page
>>>> and then spinning on that bit in arch_alloc_page might be a nice way
>>>> to get around this. Then you only have to take the zone lock when you
>>>> are finding the pages you want to hint on and setting the bit
>>>> indicating they are mid hint. Otherwise you have to take the zone lock
>>>> to pull pages out, and to put them back in and the likelihood of a
>>>> lock collision is much higher.
>>> Do you think adding a new flag to the page structure will be acceptable?
>>
>> My lesson learned: forget it. If (at all) reuse some other one that
>> might be safe in that context. Hard to tell if that is even possible and
>> will be accepted upstream.
> 
> I was thinking we could probably just resort to reuse. Essentially
> what we are looking at doing is idle page tracking so my thought is to
> see if we can just reuse those bits in the buddy allocator. Then we
> would essentially have 3 stages, young, "hinting", and idle.

Haven't thought this through, but I wonder if 2 stages would even be
enough right now, But well, you have a point that idle *might* reduce
the amount of pages hinted multiple time (although that might still
happen when we want to hint with different page sizes / buddy merging).

> 
>> Spinning is not the solution. What you would want is the buddy to
>> actually skip over these pages and only try to use them (-> spin) when
>> OOM. Core mm changes (see my other reply).
> 
> It is more of a workaround. Ideally we should almost never encounter
> this anyway as what we really want to be doing is performing hints on
> cold pages, so hopefully we will be on the other end of the LRU list
> from any active allocations.
> 
>> This all sounds like future work which can be built on top of this work.
> 
> Actually I was kind of thinking about this the other way. The simple
> spin approach is a good first step. If we have a bit or two in the
> page that tells us if the page is available or not we could then
> follow-up with optimizations to only allocate either a young or idle
> page and doesn't bother with pages being "hinted", at least in the
> first pass.
> 
> As it currently stands we are only really performing hints on higher
> order pages anyway so if we happen to encounter a slight delay under
> memory pressure it probably wouldn't be that noticeable versus the

Well, the issue is that with your approach one pending hinting request
might block all other VCPUs in the worst case until hitning is done.
Something that is not possible with Niteshs approach. It will never
block allocation paths (well apart from the zone lock and the OOM
thingy). And I think this is important.

It is a fundamental design problem until we fix core mm. Your other
synchronous approach doesn't have this problem either.

> memory system having to go through and try to compact things from some
> lower order pages. In my mind us introducing a delay in memory
> allocation in the case of a collision would be preferable versus us
> triggering allocation failures.
> 

Valid points, I think to see which approach would be the better starting
point is to have a version that does what you propose and compare it.
Essentially to find out how severe this "blocking other VCPUs" thingy
can be.

-- 

Thanks,

David / dhildenb

