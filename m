Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29810C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:41:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D54B822ADA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:41:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D54B822ADA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7082D6B0006; Fri, 26 Jul 2019 05:41:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DFA78E0003; Fri, 26 Jul 2019 05:41:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CE758E0002; Fri, 26 Jul 2019 05:41:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 390256B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:41:51 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o16so46909719qtj.6
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:41:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=vLmZMsscvqEWs/x6Z2lixyDzkokAhAFyTXY34scfbmc=;
        b=VzQgqzZd8tFVcMRSpYqMNvZGZqFq69Ets33VLkPOwKrrZZETUsdg7K7+dTGkTmIRcy
         K/Qel1Cb/5YJL2mEmdNCO3VXaZYT9zivltMbbpKPA1JvaixOwymt5nspprax1E6QchN+
         mTraa/FDLcEiHQUEe5WK4PspAI0FrczY8X1iLsm31rYULIqBRueCQaqf4J1N7sfEpKE3
         dDroL7xc4HDjOiqgcAR7Ou5//ggQv7oBis/a0hIaMF7MS4hISqUQ2op2vcK01vCxXTGA
         CALmyCXs5vtTeClReSc9vu5hfs6sFu5vh0htkHGkcW1chFaYyaZ6knUVxh49ePxaci9u
         J+NA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVGgSbkR4wH+ENV9Q8JLyhqB/fHQsXXWHXHy6j/GG7C1g6SCuSw
	QWn703QplvCPRrfIv/CpX8R0ElhPGVNdkpHiAbaE2UWKNTgEijAouRwuk192pLNgM0F3JYnn9B9
	DRn+/dGAZsdHrZ13X5y7HshMHXuor/98skJT1sei+NvCoQl4nl4M5D05uWLXuT0tKyA==
X-Received: by 2002:a05:620a:11ba:: with SMTP id c26mr55695062qkk.201.1564134110948;
        Fri, 26 Jul 2019 02:41:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwWwx6OArpx2IKW1kEyFWCuy01EvOI5is39xJSawlsxrR/iUX4oiOWQEtRCe+ZL24DqdnF
X-Received: by 2002:a05:620a:11ba:: with SMTP id c26mr55695024qkk.201.1564134110058;
        Fri, 26 Jul 2019 02:41:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564134110; cv=none;
        d=google.com; s=arc-20160816;
        b=WfIbnMqeHQvQxmQz/FN0b0LG8u2yjJKCjUTRS0AoYypgx82ZwEuB/A3Rtc+q/iVZ+m
         t6zdlwxp6ih1RkNvwBt5Buc6n13+JPlPDQRKH93+8DwqRmaALSpURh7tgy3MqFEfcFif
         5lJfp6vY4bMxOA9/JalHwx4X9+m8eqVBUWv450e7Vf5DqWJUmFOHj2238vpn7PLmggnI
         g+E8n9c4Wq9Aiv9Dra/AvprlUtq8AgAwUjWBg3YXALlg66wOMDLh8108WwlenFDHuJO3
         dFnz2A6gcNsg2uBzceElLzNidY/VzevG9SnwSsJr8EWIxmOYmlLlhL6f0LskwFnLzZSV
         7afw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=vLmZMsscvqEWs/x6Z2lixyDzkokAhAFyTXY34scfbmc=;
        b=a0Oy6ylC5h99CmpiA3ND9yqg9RcPXj8EF/xiDyGlQWEGSc6Ws3EDjQeTgm2Cu07pbd
         a+N7mXa9ygN6gLPu9K0FWQcBHxWeVbHoYtWMqz/Pv59pSuz9SRvrWOiflJmT5uEtiiny
         i2gV0aq6d8mE4DLEeyXSElfBMGGSO7tqsdCMc++pzYyt+v5+Zujr2ehLinI7pyrEnOwq
         vCKCGrb7o9syeO2lDmDe1/ZgIG/wAo2EiovvbYbxWVFqd5DQ8bHbTww6ZQNwoRJ24FQo
         yE66Cw4Kek/EPeFAZnITVMoyWFPdWhvjljjqK1QmlMquHhtrIDw2d1+oHsFWo/vFazXp
         sBZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h13si32376100qkh.330.2019.07.26.02.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 02:41:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1974D3092656;
	Fri, 26 Jul 2019 09:41:49 +0000 (UTC)
Received: from [10.36.116.244] (ovpn-116-244.ams2.redhat.com [10.36.116.244])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F161B5DA97;
	Fri, 26 Jul 2019 09:41:46 +0000 (UTC)
Subject: Re: [PATCH v3 2/5] mm: Introduce a new Vmemmap page-type
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, mhocko@suse.com, anshuman.khandual@arm.com,
 Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190725160207.19579-3-osalvador@suse.de>
 <7e8746ac-6a66-d73c-9f2a-4fc53c7e4c04@redhat.com>
 <20190726092548.GA26268@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <dbd19aea-fe18-ec42-7932-f03109cb399e@redhat.com>
Date: Fri, 26 Jul 2019 11:41:46 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190726092548.GA26268@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 26 Jul 2019 09:41:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.07.19 11:25, Oscar Salvador wrote:
> On Fri, Jul 26, 2019 at 10:48:54AM +0200, David Hildenbrand wrote:
>>> Signed-off-by: Oscar Salvador <osalvador@suse.de>
>>> ---
>>>  include/linux/mm.h         | 17 +++++++++++++++++
>>>  include/linux/mm_types.h   |  5 +++++
>>>  include/linux/page-flags.h | 19 +++++++++++++++++++
>>>  3 files changed, 41 insertions(+)
>>>
>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>> index 45f0ab0ed4f7..432175f8f8d2 100644
>>> --- a/include/linux/mm.h
>>> +++ b/include/linux/mm.h
>>> @@ -2904,6 +2904,23 @@ static inline bool debug_guardpage_enabled(void) { return false; }
>>>  static inline bool page_is_guard(struct page *page) { return false; }
>>>  #endif /* CONFIG_DEBUG_PAGEALLOC */
>>>  
>>> +static __always_inline struct page *vmemmap_head(struct page *page)
>>> +{
>>> +	return (struct page *)page->vmemmap_head;
>>> +}
>>> +
>>> +static __always_inline unsigned long vmemmap_nr_sections(struct page *page)
>>> +{
>>> +	struct page *head = vmemmap_head(page);
>>> +	return head->vmemmap_sections;
>>> +}
>>> +
>>> +static __always_inline unsigned long vmemmap_nr_pages(struct page *page)
>>> +{
>>> +	struct page *head = vmemmap_head(page);
>>> +	return head->vmemmap_pages - (page - head);
>>> +}
>>> +
>>>  #if MAX_NUMNODES > 1
>>>  void __init setup_nr_node_ids(void);
>>>  #else
>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>>> index 6a7a1083b6fb..51dd227f2a6b 100644
>>> --- a/include/linux/mm_types.h
>>> +++ b/include/linux/mm_types.h
>>> @@ -170,6 +170,11 @@ struct page {
>>>  			 * pmem backed DAX files are mapped.
>>>  			 */
>>>  		};
>>> +		struct {        /* Vmemmap pages */
>>> +			unsigned long vmemmap_head;
>>> +			unsigned long vmemmap_sections; /* Number of sections */
>>> +			unsigned long vmemmap_pages;    /* Number of pages */
>>> +		};
>>>  
>>>  		/** @rcu_head: You can use this to free a page by RCU. */
>>>  		struct rcu_head rcu_head;
>>> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
>>> index f91cb8898ff0..75f302a532f9 100644
>>> --- a/include/linux/page-flags.h
>>> +++ b/include/linux/page-flags.h
>>> @@ -708,6 +708,7 @@ PAGEFLAG_FALSE(DoubleMap)
>>>  #define PG_kmemcg	0x00000200
>>>  #define PG_table	0x00000400
>>>  #define PG_guard	0x00000800
>>> +#define PG_vmemmap     0x00001000
>>>  
>>>  #define PageType(page, flag)						\
>>>  	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
>>> @@ -764,6 +765,24 @@ PAGE_TYPE_OPS(Table, table)
>>>   */
>>>  PAGE_TYPE_OPS(Guard, guard)
>>>  
>>> +/*
>>> + * Vmemmap pages refers to those pages that are used to create the memmap
>>> + * array, and reside within the same memory range that was hotppluged, so
>>> + * they are self-hosted. (see include/linux/memory_hotplug.h)
>>> + */
>>> +PAGE_TYPE_OPS(Vmemmap, vmemmap)
>>> +static __always_inline void SetPageVmemmap(struct page *page)
>>> +{
>>> +	__SetPageVmemmap(page);
>>> +	__SetPageReserved(page);
>>
>> So, the issue with some vmemmap pages is that the "struct pages" reside
>> on the memory they manage. (it is nice, but complicated - e.g. when
>> onlining/offlining)
> 
> Hi David,
> 
> Not really.
> Vemmap pages are just skipped when onling/offlining handling.
> We do not need them to a) send to the buddy and b) migrate them over.
> A look at patch#4 will probably help, as the crux of the matter is there.

Right, but you have to hinder onlining code from trying to reinitialize
the vmemmap - when you try to online the first memory block. Will dive
into the details (patch #4) next (maybe not today, but early next week) :)

> 
>>
>> I would expect that you properly initialize the struct pages for the
>> vmemmap pages (now it gets confusing :) ) when adding memory. The other
>> struct pages are initialized when onlining/offlining.
>>
>> So, at this point, the pages should already be marked reserved, no? Or
>> are the struct pages for the vmemmap never initialized?
>>
>> What zone do these vmemmap pages have? They are not assigned to any zone
>> and will never be :/
> 
> This patch is only a preparation, the real "fun" is in patch#4.
> 
> Vmemmap pages initialization occurs in mhp_mark_vmemmap_pages, called from
> __add_pages() (patch#4).
> In there we a) mark the page as vmemmap and b) initialize the fields we need to
> track some medata (sections, pages and head).
> 
> In __init_single_page(), when onlining, the rest of the fields will be set up
> properly (zone, refcount, etc).
> 
> Chunk from patch#4:
> 
> static void __meminit __init_single_page(struct page *page, unsigned long pfn,
>                                 unsigned long zone, int nid)
> {
>         if (PageVmemmap(page))
>                 /*
>                  * Vmemmap pages need to preserve their state.
>                  */
>                 goto preserve_state;

Can you be sure there are no false positives? (if I remember correctly,
this memory might be completely uninitialized - I might be wrong)

> 
>         mm_zero_struct_page(page);
>         page_mapcount_reset(page);
>         INIT_LIST_HEAD(&page->lru);
> preserve_state:
>         init_page_count(page);
>         set_page_links(page, zone, nid, pfn);
>         page_cpupid_reset_last(page);
>         page_kasan_tag_reset(page);
> 
> So, vmemmap pages will fall within the same zone as the range we are adding,
> that does not change.

I wonder if that is the right thing to do, hmmmm, because they are
effectively not part of that zone (not online)

Will have a look at the details :)

> 
>>> +}
>>> +
>>> +static __always_inline void ClearPageVmemmap(struct page *page)
>>> +{
>>> +	__ClearPageVmemmap(page);
>>> +	__ClearPageReserved(page);
>>
>> You sure you want to clear the reserved flag here? Is this function
>> really needed?
>>
>> (when you add memory, you can mark all relevant pages as vmemmap pages,
>> which is valid until removing the memory)
>>
>> Let's draw a picture so I am not confused
>>
>> [ ------ added memory ------ ]
>> [ vmemmap]
>>
>> The first page of the added memory is a vmemmap page AND contains its
>> own vmemmap, right?
> 
> Not only the first page.
> Depending on how large is the chunk you are adding, the number of vmemmap
> pages will vary, because we need to cover the memmaps for the range.
> 
> e.g:
> 
>  - 128MB (1 section) = 512 vmemmap pages at the beginning of the range
>  - 256MB (2 section) = 1024 vmemmap pages at the beginning of the range
>  ...
> 

Right.

>> When adding memory, you would initialize set all struct pages of the
>> vmemmap (residing on itself) and set them to SetPageVmemmap().
>>
>> When removing memory, there is nothing to do, all struct pages are
>> dropped. So why do we need the ClearPageVmemmap() ?
> 
> Well, it is not really needed as we only call ClearPageVmemmap when we are
> actually removing the memory with vmemmap_free()->...
> So one could argue that since the memory is going away, there is no need
> to clear anything in there.
> 
> I just made it for consistency purposes.
> 
> Can drop it if feeling strong here.

Not strong, was just wondering why that is needed at all in the big
picture :)

-- 

Thanks,

David / dhildenb

