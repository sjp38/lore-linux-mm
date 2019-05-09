Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97C23C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:50:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E42B217D7
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:50:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NGl7wg2c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E42B217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3C3C6B0003; Thu,  9 May 2019 17:50:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEC856B0006; Thu,  9 May 2019 17:50:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B5176B0007; Thu,  9 May 2019 17:50:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0BF6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 17:50:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h2so2483979edi.13
        for <linux-mm@kvack.org>; Thu, 09 May 2019 14:50:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BMlSqCqK74ztHAZfTWbqmYSf5DVD6ofjZO6Gjzp7WWI=;
        b=QZKzBVnbuTgwJTcZ+vPgR/m99r1ma0dx/k1BLDDySBjVnlApgT9oIPzYU/xtGqg3GQ
         K3G+zJ5FzI39XuZl8CPsUN/Isq0+9y2+Pi88yRmmzXV/qQekq/TPv+SN9MzLQSrXBVfL
         bIvXJ2MIa64TfQJOhXBORQX0lgd1SLsGsskurJYsmf9DN62ynVda5qmn/7JYB2zjK8w2
         8SvrnCq3/SK+uCZudAIhFqI5awAXpzE6m2bulYR1bjiLcMumdA+hGvsyhaN9I802RaP+
         cww1e60NUXFC3+n5TO/CKLIuqDZUMwiGZEs79ga58MOuVsGnj6YFhSTaGypjGgO1HhA8
         G1IA==
X-Gm-Message-State: APjAAAVApCTk0imOmKohOfyTxdcnnaeqcQ/lB+8+KS5oQhkMZMxZi5p0
	BA58KGe4RbR5/T8eGGMt0PRYVpp5fW8roekedebwsj4dHA9/MBT8xi/N+P36NN8fvCq/Mto/bN9
	i122Ba2GRvKajSyPE3X7eH+HnFt2wu/ONb82KQihSnhmlYWgL0b9pezOGC9MbIkwbRw==
X-Received: by 2002:a50:8818:: with SMTP id b24mr6920297edb.28.1557438637704;
        Thu, 09 May 2019 14:50:37 -0700 (PDT)
X-Received: by 2002:a50:8818:: with SMTP id b24mr6920235edb.28.1557438636863;
        Thu, 09 May 2019 14:50:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557438636; cv=none;
        d=google.com; s=arc-20160816;
        b=XhuPoDhk+wFQ5e6COWOFCgNZWTou3C3tmaU4aVLxJ5xe+jA1R1XRNzsuFm8epF58/2
         ztQxsFpeAxggqzDTHo+TJnaUPm7tyoNXl0spuWQAYrnUZinBH/MHE8+L0OsBTRiga+Jo
         WFq1ok8h7mvzhw5H0KTLTkXB8TZRVsKJgYx9y6lTJle3bTu1/eh271Tg6Ixei5wGX451
         BjEt2i0gdozg8F2mS0i6Aq1nwYwxxXbe9Xk/4IQZ8lGcksfqRRUl1FE++4MfX26eBmzb
         krjdahiCd7udmmmzxEejQbptWZeVSzN2ErZoxdKpno31N40F7QaVw0KsMvY1Z/OuI/K2
         KBMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=BMlSqCqK74ztHAZfTWbqmYSf5DVD6ofjZO6Gjzp7WWI=;
        b=CFCG52uNFLIJ3fimLOo5zM1SGg4m9ioHJxFi91m4Y1HZ2MPVtnC0aW5UVrf3op5EEp
         1l3Fpa0RZ0PguI3c/mA8aWH2KuRAWKZeLglCX5TkgteDNYfJ3b7fuxQ6fuIXou7AMvfJ
         HylJ2uvkLemNjprCC8qiQTWaW32R2nfLAb4vdHdBAx1jSN98TsixQyHNerHNgr83LI7+
         jaD/9cJ5kQY/6AX9g0lW6vQNrI9tUDUszfU6AdcW9u2wlmui/povbpHicqFLtU0gnLKA
         pVAUW0I8mXAQiCwutBMpum8CXQAUafcKsXUn62vmEpr3cMENDt0ncOjSh0gOSOq7Tfyk
         PVew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NGl7wg2c;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cc9sor1172370ejb.0.2019.05.09.14.50.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 14:50:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NGl7wg2c;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BMlSqCqK74ztHAZfTWbqmYSf5DVD6ofjZO6Gjzp7WWI=;
        b=NGl7wg2cGVpKyD9cpJHljZftn+LLkSh0SgfYuUD7pOjyCs9Ci6mgnsJnI/5YX2u2sA
         N00ub+BHjZPR67iWK7zGrSKdc2FIKgprC22Vnd+8DssY7k0hLeRClyrdM+litkTcYs5z
         wn30Qa8o0THNaD/XsPLrjqCpWhF62kj/AuENHYy+QRCEAH6uviiC55pbVSOOb7LbHdGw
         b43TyiAMIlgHR0fXTDmkpRK1aekheRqQsoO5nwvkE4LFcuDJ1jZjKz5V1h8l0HDavI8L
         LGaLQ402+MxxhMuG/j6qecZBHC9qJ7cHkd3zoNCrkpuydFRs/uCvLnQVkbwD/RSUNA0G
         Zriw==
X-Google-Smtp-Source: APXvYqymBHLkj8Y+oaiwW9YuwNj6GLPLzc74NUHJXE/g8FqI3LUNlHjOkXv2ihOrqJ30gkhHPU8rNA==
X-Received: by 2002:a17:906:45c3:: with SMTP id z3mr5444210ejq.134.1557438636558;
        Thu, 09 May 2019 14:50:36 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id v35sm890246edc.4.2019.05.09.14.50.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 14:50:35 -0700 (PDT)
Date: Thu, 9 May 2019 21:50:34 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
Message-ID: <20190509215034.jl2qejw3pzqtbu5d@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
 <20190509143151.zexjmwu3ikkmye7i@master>
 <28071389-372c-14eb-1209-02464726b4f0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28071389-372c-14eb-1209-02464726b4f0@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 04:58:56PM +0200, David Hildenbrand wrote:
>On 09.05.19 16:31, Wei Yang wrote:
>> On Tue, May 07, 2019 at 08:38:00PM +0200, David Hildenbrand wrote:
>>> Only memory to be added to the buddy and to be onlined/offlined by
>>> user space using memory block devices needs (and should have!) memory
>>> block devices.
>>>
>>> Factor out creation of memory block devices Create all devices after
>>> arch_add_memory() succeeded. We can later drop the want_memblock parameter,
>>> because it is now effectively stale.
>>>
>>> Only after memory block devices have been added, memory can be onlined
>>> by user space. This implies, that memory is not visible to user space at
>>> all before arch_add_memory() succeeded.
>>>
>>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>>> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>>> Cc: David Hildenbrand <david@redhat.com>
>>> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Ingo Molnar <mingo@kernel.org>
>>> Cc: Andrew Banman <andrew.banman@hpe.com>
>>> Cc: Oscar Salvador <osalvador@suse.de>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>>> Cc: Qian Cai <cai@lca.pw>
>>> Cc: Wei Yang <richard.weiyang@gmail.com>
>>> Cc: Arun KS <arunks@codeaurora.org>
>>> Cc: Mathieu Malaterre <malat@debian.org>
>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>> ---
>>> drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
>>> include/linux/memory.h |  2 +-
>>> mm/memory_hotplug.c    | 15 ++++-----
>>> 3 files changed, 53 insertions(+), 34 deletions(-)
>>>
>>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>>> index 6e0cb4fda179..862c202a18ca 100644
>>> --- a/drivers/base/memory.c
>>> +++ b/drivers/base/memory.c
>>> @@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
>>> 	return 0;
>>> }
>>>
>>> +static void unregister_memory(struct memory_block *memory)
>>> +{
>>> +	BUG_ON(memory->dev.bus != &memory_subsys);
>>> +
>>> +	/* drop the ref. we got via find_memory_block() */
>>> +	put_device(&memory->dev);
>>> +	device_unregister(&memory->dev);
>>> +}
>>> +
>>> /*
>>> - * need an interface for the VM to add new memory regions,
>>> - * but without onlining it.
>>> + * Create memory block devices for the given memory area. Start and size
>>> + * have to be aligned to memory block granularity. Memory block devices
>>> + * will be initialized as offline.
>>>  */
>>> -int hotplug_memory_register(int nid, struct mem_section *section)
>>> +int hotplug_memory_register(unsigned long start, unsigned long size)
>> 
>> One trivial suggestion about the function name.
>> 
>> For memory_block device, sometimes we use the full name
>> 
>>     find_memory_block
>>     init_memory_block
>>     add_memory_block
>> 
>> But sometimes we use *nick* name
>> 
>>     hotplug_memory_register
>>     register_memory
>>     unregister_memory
>> 
>> This is a little bit confusion.
>> 
>> Can we use one name convention here?
>
>We can just go for
>
>crate_memory_blocks() and free_memory_blocks(). Or do
>you have better suggestions?

s/crate/create/

Looks good to me.

>
>(I would actually even prefer "memory_block_devices", because memory
>blocks have different meanins)
>

Agree with you, this comes to my mind sometime ago :-)

>> 
>> [...]
>> 
>>> /*
>>> @@ -1106,6 +1100,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
>>> 	if (ret < 0)
>>> 		goto error;
>>>
>>> +	/* create memory block devices after memory was added */
>>> +	ret = hotplug_memory_register(start, size);
>>> +	if (ret) {
>>> +		arch_remove_memory(nid, start, size, NULL);
>> 
>> Functionally, it works I think.
>> 
>> But arch_remove_memory() would remove pages from zone. At this point, we just
>> allocate section/mmap for pages, the zones are empty and pages are not
>> connected to zone.
>> 
>> Function  zone = page_zone(page); always gets zone #0, since pages->flags is 0
>> at  this point. This is not exact.
>> 
>> Would we add some comment to mention this? Or we need to clean up
>> arch_remove_memory() to take out __remove_zone()?
>
>That is precisely what is on my list next (see cover letter).This is
>already broken when memory that was never onlined is removed again.
>So I am planning to fix that independently.
>

Sounds great :-)

Hope you would cc me in the following series.

>
>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me

