Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F101C28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 17:36:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 177C220848
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 17:36:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 177C220848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CCB16B0274; Tue,  4 Jun 2019 13:36:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87DE16B0276; Tue,  4 Jun 2019 13:36:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79E196B0277; Tue,  4 Jun 2019 13:36:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 284B56B0274
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 13:36:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so1430345eda.9
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 10:36:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jUpoQ7wlR2M1m2snusEKdFDracWmi3gm5oagc8bjyvc=;
        b=HMk2c7jjCQrxXqxecq/93hB50KhraFkYz+MhL5aiQN5zgiuUkluU7auZBhWtppvTtt
         zjtDi8LZzH1aO4mjDHvF1kSG8OYbHNpfTbQJxhg0z0eE/VUtBgrZxrFbswTBc3DIagJC
         mrsiDiN7ak5OCLUhCCxQczwSBcj/J7AbZbFtl3EuLoYlj5//juECHH2c+2/ytKWLUAqN
         ALESCy+BcvQrpcfFJoffldOouuayzL6h3PoAwJ75N3spqcrQKX5YcDK5MGcvVNzPZlN3
         JCUTeLv+pepWEtq4naz91de0+aCk9C7Iyy7DFZ28UY+z3cgID8PuwylTN7P3zov9P0c4
         w6Ew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAVI/YehFmBK5+oD9v54n3hYelNJVF4bbMMN7SCeYfe7CNfXY5dj
	1nH6kVhd0g5VrSyJTAY43jnHmELexDkebCglHV1WSCpW9PgwC1fy0XJzWT16UY/PhgGHAG/uYk+
	XAkQh4WGsVi0u01cRbJ2yoSXj2Fw1j2/tP1g69OJjoF0Sknu/x1dO3ih7jh7qBumZAg==
X-Received: by 2002:a50:a7a5:: with SMTP id i34mr37207190edc.294.1559669772550;
        Tue, 04 Jun 2019 10:36:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRvGMUqHquq38JqsGtlwA0cP1yw3fsDL6lhrKtAxqOg/VATxcF6rXa0n62qrmkKfg/pI2d
X-Received: by 2002:a50:a7a5:: with SMTP id i34mr37207093edc.294.1559669771640;
        Tue, 04 Jun 2019 10:36:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559669771; cv=none;
        d=google.com; s=arc-20160816;
        b=lBYmbkzdQuW0AyJ5kn5HMxH+pskdfwqR3YRt5v9ebWq+V1IeKRTiJAz/fww+WbU/wa
         jo+1nxIMnzTcSt/lfWVJiYFv1CZ5oCoHZ1yodHX6dMTDPpozBiq1XWr6LosjPk9J1TDG
         rTN/dBHF7CTKvLeY6xgUKgaCBk+z4H1jbuT4zIKanBKIeL1r0bb1VBn0s4yHYThio3nT
         +udGZ3AkQ9ilMPWWbCWQ6mZpZuZa0TwnEWbpwArLCDW6OYfo0inACzNZmfZqHxj5sKCX
         vhraQ79Q5PZmUOFYphjoc6wZIWtdA5OS6PakzXsfPsJwGfWarq9wHMWP80+ubhTfd57u
         A88w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jUpoQ7wlR2M1m2snusEKdFDracWmi3gm5oagc8bjyvc=;
        b=07I0ph0F3G86Y4Ov23XxUaPKDGGBE6EQugpIBJAl/mJa7HTjVT3P9IdjPDLiGeUZQ8
         SPpEql3dJ4FHms9pmSOPaGKTAuIGzzMcD5bzu/YzXoi1cKobqQ+EEcUsjHd+S0+VakM8
         /yF1o2CFIhAwPMMHJpCguIkff5TZYcekh5TizZfAkT2Bp3v/giwza0gqTOwtsfklcTju
         mNi7939Ni24LKCfV4wNRAgIM00ebDHlr3amt2zGfj7yy4ZSC0fvtKQP7zxSNLU9PkLJ4
         EytV+itcDp5FJzonfFBbHG2E8Wy8o/9CJi7vEFay9RVYC5M29+sLnv1jnD6o8+6vwAxw
         ftsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a26si5566700edn.354.2019.06.04.10.36.11
        for <linux-mm@kvack.org>;
        Tue, 04 Jun 2019 10:36:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 523C980D;
	Tue,  4 Jun 2019 10:36:10 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0002F3F5AF;
	Tue,  4 Jun 2019 10:36:05 -0700 (PDT)
Subject: Re: [PATCH v3 04/11] arm64/mm: Add temporary arch_remove_memory()
 implementation
To: David Hildenbrand <david@redhat.com>, Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Igor Mammedov
 <imammedo@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Chintan Pandya <cpandya@codeaurora.org>, Mike Rapoport <rppt@linux.ibm.com>,
 Jun Yao <yaojun8558363@gmail.com>, Yu Zhao <yuzhao@google.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-5-david@redhat.com>
 <20190603214139.mercn5hol2yyfl2s@master>
 <5059f68d-45d2-784e-0770-ee67060773c7@redhat.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <7a5b8c8d-f1bb-9c7e-9809-405af374fecd@arm.com>
Date: Tue, 4 Jun 2019 18:36:04 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <5059f68d-45d2-784e-0770-ee67060773c7@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/06/2019 07:56, David Hildenbrand wrote:
> On 03.06.19 23:41, Wei Yang wrote:
>> On Mon, May 27, 2019 at 01:11:45PM +0200, David Hildenbrand wrote:
>>> A proper arch_remove_memory() implementation is on its way, which also
>>> cleanly removes page tables in arch_add_memory() in case something goes
>>> wrong.
>>
>> Would this be better to understand?
>>
>>      removes page tables created in arch_add_memory
> 
> That's not what this sentence expresses. Have a look at
> arch_add_memory(), in case  __add_pages() fails, the page tables are not
> removed. This will also be fixed by Anshuman in the same shot.
> 
>>
>>>
>>> As we want to use arch_remove_memory() in case something goes wrong
>>> during memory hotplug after arch_add_memory() finished, let's add
>>> a temporary hack that is sufficient enough until we get a proper
>>> implementation that cleans up page table entries.
>>>
>>> We will remove CONFIG_MEMORY_HOTREMOVE around this code in follow up
>>> patches.
>>>
>>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>>> Cc: Will Deacon <will.deacon@arm.com>
>>> Cc: Mark Rutland <mark.rutland@arm.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>>> Cc: Chintan Pandya <cpandya@codeaurora.org>
>>> Cc: Mike Rapoport <rppt@linux.ibm.com>
>>> Cc: Jun Yao <yaojun8558363@gmail.com>
>>> Cc: Yu Zhao <yuzhao@google.com>
>>> Cc: Robin Murphy <robin.murphy@arm.com>
>>> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>> ---
>>> arch/arm64/mm/mmu.c | 19 +++++++++++++++++++
>>> 1 file changed, 19 insertions(+)
>>>
>>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>>> index a1bfc4413982..e569a543c384 100644
>>> --- a/arch/arm64/mm/mmu.c
>>> +++ b/arch/arm64/mm/mmu.c
>>> @@ -1084,4 +1084,23 @@ int arch_add_memory(int nid, u64 start, u64 size,
>>> 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>>> 			   restrictions);
>>> }
>>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>>> +void arch_remove_memory(int nid, u64 start, u64 size,
>>> +			struct vmem_altmap *altmap)
>>> +{
>>> +	unsigned long start_pfn = start >> PAGE_SHIFT;
>>> +	unsigned long nr_pages = size >> PAGE_SHIFT;
>>> +	struct zone *zone;
>>> +
>>> +	/*
>>> +	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
>>> +	 * adding fails). Until then, this function should only be used
>>> +	 * during memory hotplug (adding memory), not for memory
>>> +	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
>>> +	 * unlocked yet.
>>> +	 */
>>> +	zone = page_zone(pfn_to_page(start_pfn));
>>
>> Compared with arch_remove_memory in x86. If altmap is not NULL, zone will be
>> retrieved from page related to altmap. Not sure why this is not the same?
> 
> This is a minimal implementation, sufficient for this use case here. A
> full implementation is in the works. For now, this function will not be
> used with an altmap (ZONE_DEVICE is not esupported for arm64 yet).

FWIW the other pieces of ZONE_DEVICE are now due to land in parallel, 
but as long as we don't throw the ARCH_ENABLE_MEMORY_HOTREMOVE switch 
then there should still be no issue. Besides, given that we should 
consistently ignore the altmap everywhere at the moment, it may even 
work out regardless.

One thing stands out about the failure path thing, though - if 
__add_pages() did fail, can it still be guaranteed to have initialised 
the memmap such that page_zone() won't return nonsense? Last time I 
looked that was still a problem when removing memory which had been 
successfully added, but never onlined (although I do know that 
particular case was already being discussed at the time, and I've not 
been paying the greatest attention since).

Robin.

