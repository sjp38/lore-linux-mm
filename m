Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76E82C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:30:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FF7120851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:30:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FF7120851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C4D08E0003; Thu,  7 Mar 2019 14:30:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84B628E0002; Thu,  7 Mar 2019 14:30:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EB5E8E0003; Thu,  7 Mar 2019 14:30:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB328E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 14:30:29 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id b6so14084452qkg.4
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 11:30:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=GxJJhzGE8mLEihj1od1M7jIU1CQSil+6Kv73vhXfjHk=;
        b=rkXQtbBvKgOATF5kQ/SsdOgYx0sJQUVaXZBDORMHTHFroF/nQ0U3cb64XUH9NxPopl
         aVrMewY3lIlrA5j0UrxI5zdaaAuNkvJYSa5D6FIFCRkcc0/aPQnbl4Zqh4bu5BNuTgpa
         gj8HZJeortmVcsOr/ZgBopzimQbCgn5Isr68Sq5+gIN1pkgU4BH2dRRk8hpZvMa10BuR
         64DkmtUwgod5AHL1FiL7p8zz0fc6rscmF7qtOnLhEgmYuGptoboz40cwtIGRN/VDHy01
         jjtoVGfpjfntF5uGGyD0H20x7X4jMzEfiDuC2ui66KTvqYFFifbGbLki1AWzftWVYCqF
         4SQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWmyMZgLn4JdQFgcXNvIyZC/am2jCeClRu/X5cY2lJTpsRhRceT
	VzeJ1b/olmuT/XjdGSzx9yhOvXOBI434gSQ0dn13FKLyI7cRheUUHbWHS2xIL+f1fTEPaQQINtl
	VSDMzLHeMcSZi9SxY3NFbiFz/jY+EYulEpQrRj9KP452dDOxFRHhT1Zpm0fB6UsgWhA==
X-Received: by 2002:a37:4dc5:: with SMTP id a188mr11117648qkb.181.1551987028958;
        Thu, 07 Mar 2019 11:30:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqxeyjqR8jL+PRpX7jWtMM5r1EdjBjKkT+677QkNCxlNd4j7nteGIfhYNeblE8JRpdoK+UPa
X-Received: by 2002:a37:4dc5:: with SMTP id a188mr11117593qkb.181.1551987028043;
        Thu, 07 Mar 2019 11:30:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551987028; cv=none;
        d=google.com; s=arc-20160816;
        b=rsUS5n7Ot12T7toOxqdZ0ndac7Z3BMe8OO/1u+m8nMqXIyj4CnWdrhlQvCohikVnOt
         KyGM/DzUdLuHd9yZCLrPJlvNubwKNYfOREIHQfMpU5c27il75xvLxv9soxXu534uuvUu
         OBs+ZUTtXKQQFvz810Zwh8AZTcHVBWowsdSxLY1G4dQUf6ivhsChq/aTa7r3PaEYIEQ5
         phH7ueMtX7Kh347iOeL0bryk+uzU2ACgwNVaioBMy7zhOVn8hfC05i8YfFiAsfciCTcB
         vfMey+mWOB0hUHUp1OZnlOMtelZxQd7l65ej3t4OFjND27Xchd0sRXNvP/42P3fLmbem
         5O3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=GxJJhzGE8mLEihj1od1M7jIU1CQSil+6Kv73vhXfjHk=;
        b=IghnKneDh1kw1v/wfRO5uS2dptLEv3eUGg+4FvtFEbq6SjQ6i8FzT7tlxudNoLXian
         B6dcGJgYiLc8IZFOH9x09vcBLZS/dp90VNSDk0O/UXRKnr8WSuQBG3uRxd+cVyMYVRwv
         AbDXi8I/CgzAK6exIURa13+DaEbQQZO3db8lDnIKZmQHsFnVEOzmSMSDTIPRGM9IB7zw
         K7TRhTuuFU1vTzy7bHnsNUTn31wmd2SzzypdXVqRv76EmkWaMzSHdJlLFYiirt5CKzhL
         f+rSRm6DuUFEkgXapN5abAxvXCAlK/ScBM6IKOmWmqjDjxgCHPXw/n36PiJjA8DCPtyP
         V/4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h68si211745qkb.14.2019.03.07.11.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 11:30:28 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 12B98C04AC51;
	Thu,  7 Mar 2019 19:30:27 +0000 (UTC)
Received: from [10.36.116.67] (ovpn-116-67.ams2.redhat.com [10.36.116.67])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 52E541001DDC;
	Thu,  7 Mar 2019 19:30:08 +0000 (UTC)
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
To: Nitesh Narayan Lal <nitesh@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
Date: Thu, 7 Mar 2019 20:30:07 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 07 Mar 2019 19:30:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.03.19 20:23, Nitesh Narayan Lal wrote:
> 
> On 3/7/19 1:30 PM, Alexander Duyck wrote:
>> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>>> This patch enables the kernel to scan the per cpu array
>>> which carries head pages from the buddy free list of order
>>> FREE_PAGE_HINTING_MIN_ORDER (MAX_ORDER - 1) by
>>> guest_free_page_hinting().
>>> guest_free_page_hinting() scans the entire per cpu array by
>>> acquiring a zone lock corresponding to the pages which are
>>> being scanned. If the page is still free and present in the
>>> buddy it tries to isolate the page and adds it to a
>>> dynamically allocated array.
>>>
>>> Once this scanning process is complete and if there are any
>>> isolated pages added to the dynamically allocated array
>>> guest_free_page_report() is invoked. However, before this the
>>> per-cpu array index is reset so that it can continue capturing
>>> the pages from buddy free list.
>>>
>>> In this patch guest_free_page_report() simply releases the pages back
>>> to the buddy by using __free_one_page()
>>>
>>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>> I'm pretty sure this code is not thread safe and has a few various issues.
>>
>>> ---
>>>  include/linux/page_hinting.h |   5 ++
>>>  mm/page_alloc.c              |   2 +-
>>>  virt/kvm/page_hinting.c      | 154 +++++++++++++++++++++++++++++++++++
>>>  3 files changed, 160 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
>>> index 90254c582789..d554a2581826 100644
>>> --- a/include/linux/page_hinting.h
>>> +++ b/include/linux/page_hinting.h
>>> @@ -13,3 +13,8 @@
>>>
>>>  void guest_free_page_enqueue(struct page *page, int order);
>>>  void guest_free_page_try_hinting(void);
>>> +extern int __isolate_free_page(struct page *page, unsigned int order);
>>> +extern void __free_one_page(struct page *page, unsigned long pfn,
>>> +                           struct zone *zone, unsigned int order,
>>> +                           int migratetype);
>>> +void release_buddy_pages(void *obj_to_free, int entries);
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 684d047f33ee..d38b7eea207b 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -814,7 +814,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>>>   * -- nyc
>>>   */
>>>
>>> -static inline void __free_one_page(struct page *page,
>>> +inline void __free_one_page(struct page *page,
>>>                 unsigned long pfn,
>>>                 struct zone *zone, unsigned int order,
>>>                 int migratetype)
>>> diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
>>> index 48b4b5e796b0..9885b372b5a9 100644
>>> --- a/virt/kvm/page_hinting.c
>>> +++ b/virt/kvm/page_hinting.c
>>> @@ -1,5 +1,9 @@
>>>  #include <linux/mm.h>
>>>  #include <linux/page_hinting.h>
>>> +#include <linux/page_ref.h>
>>> +#include <linux/kvm_host.h>
>>> +#include <linux/kernel.h>
>>> +#include <linux/sort.h>
>>>
>>>  /*
>>>   * struct guest_free_pages- holds array of guest freed PFN's along with an
>>> @@ -16,6 +20,54 @@ struct guest_free_pages {
>>>
>>>  DEFINE_PER_CPU(struct guest_free_pages, free_pages_obj);
>>>
>>> +/*
>>> + * struct guest_isolated_pages- holds the buddy isolated pages which are
>>> + * supposed to be freed by the host.
>>> + * @pfn: page frame number for the isolated page.
>>> + * @order: order of the isolated page.
>>> + */
>>> +struct guest_isolated_pages {
>>> +       unsigned long pfn;
>>> +       unsigned int order;
>>> +};
>>> +
>>> +void release_buddy_pages(void *obj_to_free, int entries)
>>> +{
>>> +       int i = 0;
>>> +       int mt = 0;
>>> +       struct guest_isolated_pages *isolated_pages_obj = obj_to_free;
>>> +
>>> +       while (i < entries) {
>>> +               struct page *page = pfn_to_page(isolated_pages_obj[i].pfn);
>>> +
>>> +               mt = get_pageblock_migratetype(page);
>>> +               __free_one_page(page, page_to_pfn(page), page_zone(page),
>>> +                               isolated_pages_obj[i].order, mt);
>>> +               i++;
>>> +       }
>>> +       kfree(isolated_pages_obj);
>>> +}
>> You shouldn't be accessing __free_one_page without holding the zone
>> lock for the page. You might consider confining yourself to one zone
>> worth of hints at a time. Then you can acquire the lock once, and then
>> return the memory you have freed.
> That is correct.
>>
>> This is one of the reasons why I am thinking maybe a bit in the page
>> and then spinning on that bit in arch_alloc_page might be a nice way
>> to get around this. Then you only have to take the zone lock when you
>> are finding the pages you want to hint on and setting the bit
>> indicating they are mid hint. Otherwise you have to take the zone lock
>> to pull pages out, and to put them back in and the likelihood of a
>> lock collision is much higher.
> Do you think adding a new flag to the page structure will be acceptable?

My lesson learned: forget it. If (at all) reuse some other one that
might be safe in that context. Hard to tell if that is even possible and
will be accepted upstream.

Spinning is not the solution. What you would want is the buddy to
actually skip over these pages and only try to use them (-> spin) when
OOM. Core mm changes (see my other reply).

This all sounds like future work which can be built on top of this work.


-- 

Thanks,

David / dhildenb

