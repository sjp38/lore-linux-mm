Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85E49C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 17:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A4132075B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 17:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A4132075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B31E16B0271; Tue,  4 Jun 2019 13:52:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE1DE6B0273; Tue,  4 Jun 2019 13:52:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AAAE6B0277; Tue,  4 Jun 2019 13:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78A2A6B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 13:52:07 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id b70so87885vsd.19
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 10:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Mlnc1PENy6BubUC3qMTM4yUW1mdnZfFrWQ6xDaxH6ek=;
        b=MhXPn8EOBnnDJiNxMQDq5GMQ/Mg9/DpySU6Tj72WdUdxnYqT9s51AELxZBshOYom3R
         Dh5PiDFSjTimOYdqDUr6CoYR7Kd/Z1sapMNlEyhTs9GwVgqdyzya+cC4/zX/ddK+vMHj
         g6/F/h/EAfkixXvvcbomjuWnXbi5heUsgEq+riuNbJhZFM6b9kFbn1TfSKw3k9bvdP8I
         mZ47pb3/nJ8JVAJ/B7DC0G3m5ytQ/5tQ+eSZs+rP/jw9pkI3YAYHUZ4QZwKJxGlxd7f2
         bOT5PyOXW8OFIdIy/N3IZPi+zblXNVq+jGqJ5vFqZgSPH+JKZXK2TEnjMZMim7pqtua6
         ++MQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXGFZ3jqgEpKzhAdKf4/tkJTG+2Y1KKCzVIk2tEaEFfSZ2hy2Ym
	oEz8AetrkiK3On5HMiObecDcr7GsUegbcIfEjCBGPge2pPO3BgfpWb/fPIxDaSVLa2GnMfKxJbB
	2JNXhCeAkGwCLSEXfDtkM7DRWXGWgv9fUzCVFdUDfG9UGR/c13v9aFTPnxk29uMetCw==
X-Received: by 2002:a1f:56c3:: with SMTP id k186mr8310611vkb.24.1559670727120;
        Tue, 04 Jun 2019 10:52:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkhAQFUCqSqRZv2k7M1biC+x+rbbSXB4uSoL7zRdoc9FRqnyZkPbiuPOV2u/IHL2lXiIJ+
X-Received: by 2002:a1f:56c3:: with SMTP id k186mr8310530vkb.24.1559670726095;
        Tue, 04 Jun 2019 10:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559670726; cv=none;
        d=google.com; s=arc-20160816;
        b=Pgq2Xsig0FHW034hVv/cSZDE1h7VaEMAmL/szmKe7TYLesV5ZrYufYTgFBKIQVqWEb
         HJIPc4/Wj00rDUdhh7+dKhbvoVGTB4loR9XdtQtbL7lBU1DWM+hZEbmxeT9jiuUe9xSj
         f5qRmdAkzrUay2a0UHvlUm4ARLSjNlCI1HItpqIqRwa35gnqf5XYIdCqbfAElarjjoZR
         tJam8K6y9jnigl4P1o+b4ZphGwpq9aZXtlMbc4y3PQfmzPekimhA0DGWUnLH07V78VZT
         olX5cGYWDCHKUmY4uViXfrcx4nkIU1IVSYbeeqgyRY+BdmUJ2ODXa2PL7XA/+64G2rP8
         K5AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Mlnc1PENy6BubUC3qMTM4yUW1mdnZfFrWQ6xDaxH6ek=;
        b=ZHpXAfzKHQVAWNoraHRmU+HMRPGHQ/jZDkKFnD1vPc6JRC47CfHQyHYhytZUpzIO2x
         VKquAT4CNRNVOcMVoa3/P3/WuBcpOvdExFRTQ9hRp8GFBVAM1ASeLp0L22hUsO2sqytG
         dD+RcM1XHE5Fu7zyFYaUvmxXJkAgyyFxSm0jlSIDTgVw1IeRKALOnkMsPrTkZCJ9IhQ5
         ipoUJcdbvl9kCl5ukUJda+IwNbXiC4+KJLcy8aLeRdAYbmbGnO0PA1WvIIg3o0oaT9I9
         +RCVRJV7VikI0cl1+AYyBQNbIkTfxoCWkjA4DtvdQCm38QXgZSFi0TQ7jZdNa+KpRrSq
         ps4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k11si3532313uaj.103.2019.06.04.10.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 10:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DC01AC04FFF1;
	Tue,  4 Jun 2019 17:51:59 +0000 (UTC)
Received: from [10.36.116.79] (ovpn-116-79.ams2.redhat.com [10.36.116.79])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 735B9600CC;
	Tue,  4 Jun 2019 17:51:53 +0000 (UTC)
Subject: Re: [PATCH v3 04/11] arm64/mm: Add temporary arch_remove_memory()
 implementation
To: Robin Murphy <robin.murphy@arm.com>, Wei Yang <richard.weiyang@gmail.com>
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
 <7a5b8c8d-f1bb-9c7e-9809-405af374fecd@arm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <4f2a87e9-7fd6-4b2b-892d-52482a330235@redhat.com>
Date: Tue, 4 Jun 2019 19:51:52 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <7a5b8c8d-f1bb-9c7e-9809-405af374fecd@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 04 Jun 2019 17:52:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.06.19 19:36, Robin Murphy wrote:
> On 04/06/2019 07:56, David Hildenbrand wrote:
>> On 03.06.19 23:41, Wei Yang wrote:
>>> On Mon, May 27, 2019 at 01:11:45PM +0200, David Hildenbrand wrote:
>>>> A proper arch_remove_memory() implementation is on its way, which also
>>>> cleanly removes page tables in arch_add_memory() in case something goes
>>>> wrong.
>>>
>>> Would this be better to understand?
>>>
>>>      removes page tables created in arch_add_memory
>>
>> That's not what this sentence expresses. Have a look at
>> arch_add_memory(), in case  __add_pages() fails, the page tables are not
>> removed. This will also be fixed by Anshuman in the same shot.
>>
>>>
>>>>
>>>> As we want to use arch_remove_memory() in case something goes wrong
>>>> during memory hotplug after arch_add_memory() finished, let's add
>>>> a temporary hack that is sufficient enough until we get a proper
>>>> implementation that cleans up page table entries.
>>>>
>>>> We will remove CONFIG_MEMORY_HOTREMOVE around this code in follow up
>>>> patches.
>>>>
>>>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>>>> Cc: Will Deacon <will.deacon@arm.com>
>>>> Cc: Mark Rutland <mark.rutland@arm.com>
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>>>> Cc: Chintan Pandya <cpandya@codeaurora.org>
>>>> Cc: Mike Rapoport <rppt@linux.ibm.com>
>>>> Cc: Jun Yao <yaojun8558363@gmail.com>
>>>> Cc: Yu Zhao <yuzhao@google.com>
>>>> Cc: Robin Murphy <robin.murphy@arm.com>
>>>> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
>>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>>> ---
>>>> arch/arm64/mm/mmu.c | 19 +++++++++++++++++++
>>>> 1 file changed, 19 insertions(+)
>>>>
>>>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>>>> index a1bfc4413982..e569a543c384 100644
>>>> --- a/arch/arm64/mm/mmu.c
>>>> +++ b/arch/arm64/mm/mmu.c
>>>> @@ -1084,4 +1084,23 @@ int arch_add_memory(int nid, u64 start, u64 size,
>>>> 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>>>> 			   restrictions);
>>>> }
>>>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>>>> +void arch_remove_memory(int nid, u64 start, u64 size,
>>>> +			struct vmem_altmap *altmap)
>>>> +{
>>>> +	unsigned long start_pfn = start >> PAGE_SHIFT;
>>>> +	unsigned long nr_pages = size >> PAGE_SHIFT;
>>>> +	struct zone *zone;
>>>> +
>>>> +	/*
>>>> +	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
>>>> +	 * adding fails). Until then, this function should only be used
>>>> +	 * during memory hotplug (adding memory), not for memory
>>>> +	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
>>>> +	 * unlocked yet.
>>>> +	 */
>>>> +	zone = page_zone(pfn_to_page(start_pfn));
>>>
>>> Compared with arch_remove_memory in x86. If altmap is not NULL, zone will be
>>> retrieved from page related to altmap. Not sure why this is not the same?
>>
>> This is a minimal implementation, sufficient for this use case here. A
>> full implementation is in the works. For now, this function will not be
>> used with an altmap (ZONE_DEVICE is not esupported for arm64 yet).
> 
> FWIW the other pieces of ZONE_DEVICE are now due to land in parallel, 
> but as long as we don't throw the ARCH_ENABLE_MEMORY_HOTREMOVE switch 
> then there should still be no issue. Besides, given that we should 
> consistently ignore the altmap everywhere at the moment, it may even 
> work out regardless.

Thanks for the info.

> 
> One thing stands out about the failure path thing, though - if 
> __add_pages() did fail, can it still be guaranteed to have initialised 
> the memmap such that page_zone() won't return nonsense? Last time I 

if __add_pages() fails, then arch_add_memory() fails and
arch_remove_memory() will not be called in the context of this series.
Only if it succeeded.

> looked that was still a problem when removing memory which had been 
> successfully added, but never onlined (although I do know that 
> particular case was already being discussed at the time, and I've not 
> been paying the greatest attention since).

Yes, that part is next on my list. It works but is ugly. The memory
removal process should not care about zones at all.

Slowly moving into the right direction :)

> 
> Robin.
> 


-- 

Thanks,

David / dhildenb

