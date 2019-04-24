Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF8C1C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 05:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 687A92148D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 05:59:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 687A92148D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C29F56B0005; Wed, 24 Apr 2019 01:59:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB11B6B0006; Wed, 24 Apr 2019 01:59:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A52076B0007; Wed, 24 Apr 2019 01:59:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8F76B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 01:59:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e22so9238894edd.9
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 22:59:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=iyaoBtjrf3Al6KtC2RbgldakEO39ShWQ0SV9Np35UIg=;
        b=T/gcmbP99aEQ8XcI6syyamiUAtcCnt9bfVbQbSkzOU6sG+8PuC+d9INxS7wq3bVsPj
         6Wp4UJERXp5KM50ukDgHa9FXMnc2oRDUTSB8v12DqgSkWZ1eUVsNsvNu9w2qXiF9l+g9
         hCby6UKbzuHjXRg3sdPDaTtExdFDwShI2AwWFOy38YmMOx/xi2bTDSQYG8mjP3tKYPNk
         4wCBTe42DEUiAa8KAvakBod7++KwXnuu4yzM/ZM/Yoi9fl070EKYic3k8cHT3vXuFuwZ
         dKnDULJdF1R5Q3bNHZJoKS/hkEA39x2JViLxIaCJayTXLAlckojob4hr/EPsUlMNd2yn
         WsgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVcw/bI1ml+IGyhEmiInRb5grE7EzzEgUr0Ap5FJ3/IZZY/+6PM
	lzCqheF8INEQei38qUu7tGEqV2mou9vmZwIL0U5gRaSOdc9gZXAu+NZgW8Sc6qmIK88vxgvsG8T
	EssLoEHmhnNorCfXSEIXCxLs1lHdmua8EDOcMjSDp0YZTBxxXrvajlteb4xlZg750EQ==
X-Received: by 2002:a17:906:288f:: with SMTP id o15mr3352214ejd.282.1556085577748;
        Tue, 23 Apr 2019 22:59:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0WPnGOzRE/MJfTl89EIuLdLFkrYuPkbzKH/Z/FUnx1/8V7ecHtc5gqe+OkWS+gSjl4vNd
X-Received: by 2002:a17:906:288f:: with SMTP id o15mr3352173ejd.282.1556085576732;
        Tue, 23 Apr 2019 22:59:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556085576; cv=none;
        d=google.com; s=arc-20160816;
        b=vEOAFedJAlR9ZFCBMMVGlgetf0co3SvrI4caTMb+hIHweiGlfoIXP5xkZ+1uh70jrd
         1Phaa6uqnFn/IyXBtlkcSPKhczIIANIjUvUsWTxbIQb6j2qXDYvL/n4n8h9+cAxdBfKf
         vg3cdIpLcCHgndHI9f1KHVnqXu4nsDN9rvg2zEVplP4eH6Mg0Ptgncm4DsbuBOYXtH1M
         3vMbdj3+SS7cOlZpW2HDMUhPCD9ycZE4s1deWiQ9LT2BWjw+P9QgSCjO5PUKIsERe8Aw
         WOYfyIWaP6aNfrUrf/dKTFqdD28NVoPxyWGe/S9J52rUSaZn4Geh9KCYZq5AUd4u3JgR
         Ga5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=iyaoBtjrf3Al6KtC2RbgldakEO39ShWQ0SV9Np35UIg=;
        b=Z7HWvbQMVv1j9g9LYZGbll9517+UsOzNgLLIpFtt/f8O6NvcYCjE+3zI9KcWE95iGZ
         /LxMJ9VkSRPjm8WcgiD7iONNNFpbDF226LdRm0d5h3am21facQgAwU7U6TruysBk8fNS
         0jau6al9JpVKo0/s5f55DDeWM/vC/16eQn5fAS1rVxPFszTPIhLu/Vavfw/B421H29vZ
         9GhvjwXn1GpuSi1jG7o6y2PZp+OrZagoNiRS3j10Q6kYiqImZiZvY2oDvtooHlorSeej
         ZsVoJgimDKoIw0h1xUpGIhrsFHxp27yWyCE4tEFPYmnX7Z9+PSp/Ocmg6suAVLsGkm5t
         NIbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k9si149028ejd.118.2019.04.23.22.59.36
        for <linux-mm@kvack.org>;
        Tue, 23 Apr 2019 22:59:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3AFDCA78;
	Tue, 23 Apr 2019 22:59:35 -0700 (PDT)
Received: from [10.163.1.68] (unknown [10.163.1.68])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7260F3F5AF;
	Tue, 23 Apr 2019 22:59:27 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com, mhocko@suse.com, mgorman@techsingularity.net,
 james.morse@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 david@redhat.com, cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
 <20190415134841.GC13990@lakrids.cambridge.arm.com>
 <2faba38b-ab79-2dda-1b3c-ada5054d91fa@arm.com>
 <20190417142154.GA393@lakrids.cambridge.arm.com>
 <bba0b71c-2d04-d589-e2bf-5de37806548f@arm.com>
 <20190417173948.GB15589@lakrids.cambridge.arm.com>
 <1bdae67b-fcd6-7868-8a92-c8a306c04ec6@arm.com>
 <97413c39-a4a9-ea1b-7093-eb18f950aad7@arm.com>
 <20190423160525.GD56999@lakrids.cambridge.arm.com>
Message-ID: <ebb9aba0-5ca3-41ed-4183-9d72a354f529@arm.com>
Date: Wed, 24 Apr 2019 11:29:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190423160525.GD56999@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/23/2019 09:35 PM, Mark Rutland wrote:
> On Tue, Apr 23, 2019 at 01:01:58PM +0530, Anshuman Khandual wrote:
>> Generic usage for init_mm.pagetable_lock
>>
>> Unless I have missed something else these are the generic init_mm kernel page table
>> modifiers at runtime (at least which uses init_mm.page_table_lock)
>>
>> 	1. ioremap_page_range()		/* Mapped I/O memory area */
>> 	2. apply_to_page_range()	/* Change existing kernel linear map */
>> 	3. vmap_page_range()		/* Vmalloc area */
> 
> Internally, those all use the __p??_alloc() functions to handle racy
> additions by transiently taking the PTL when installing a new table, but
> otherwise walk kernel tables _without_ the PTL held. Note that none of
> these ever free an intermediate level of table.

Right they dont free intermediate level page table but I was curious about the
only the leaf level modifications.

> 
> I believe that the idea is that operations on separate VMAs should never

I guess you meant kernel virtual range with 'VMA' but not the actual VMA which is
vm_area_struct applicable only for the user space not the kernel.

> conflict at the leaf level, and operations on the same VMA should be
> serialised somehow w.r.t. that VMA.

AFAICT see there is nothing other than hotplug lock i.e mem_hotplug_lock which
prevents concurrent init_mm modifications and the current situation is only safe
because some how these VA areas dont overlap with respect to intermediate page
table level spans.

> 
> AFAICT, these functions are _never_ called on the linear/direct map or
> vmemmap VA ranges, and whether or not these can conflict with hot-remove
> is entirely dependent on whether those ranges can share a level of table
> with the vmalloc region.

Right but all these VA ranges (linear, vmemmap, vmalloc) are wired in on init_mm
hence wondering if it is prudent to assume layout scheme which varies a lot based
on different architectures while deciding possible race protections. Wondering why
these user should not call [get|put]_online_mems() to prevent race with hotplug.
Will try this out.

Unless generic MM expects these VA ranges (linear, vmemmap, vmalloc) layout to be
in certain manner from the platform guaranteeing non-overlap at intermediate level
page table spans. Only then we would not a lock.
 
> 
> Do you know how likely that is to occur? e.g. what proportion of the

TBH I dont know.

> vmalloc region may share a level of table with the linear or vmemmap
> regions in a typical arm64 or x86 configuration? Can we deliberately
> provoke this failure case?

I have not enumerated those yet but there are multiple configs on arm64 and
probably on x86 which decides kernel VA space layout causing these potential
races. But regardless its not right to assume on vmalloc range span and not
take a lock.

Not sure how to provoke this failure case from user space with simple hotplug
because vmalloc physical allocation normally cannot be controlled without a
hacked kernel change.

> 
> [...]
> 
>> In all of the above.
>>
>> - Page table pages [p4d|pud|pmd|pte]_alloc_[kernel] settings are
>>   protected with init_mm.page_table_lock
> 
> Racy addition is protect in this manner.

Right.

> 
>> - Should not it require init_mm.page_table_lock for all leaf level
>>   (PUD|PMD|PTE) modification as well ?
> 
> As above, I believe that the PTL is assumed to not be necessary there
> since other mutual exclusion should be in effect to prevent racy
> modification of leaf entries.

Wondering what are those mutual exclusions other than the memory hotplug lock.
Again if its on kernel VA space layout assumptions its not a good idea.

> 
>> - Should not this require init_mm.page_table_lock for page table walk
>>   itself ?
>>
>> Not taking an overall lock for all these three operations will
>> potentially race with an ongoing memory hot remove operation which
>> takes an overall lock as proposed. Wondering if this has this been
>> safe till now ?
> 
> I suspect that the answer is that hot-remove is not thoroughly
> stress-tested today, and conflicts are possible but rare.

Will make these generic modifiers call [get|put]_online_mems() in a separate
patch at least to protect themselves from memory hot remove operation.

> 
> As above, can we figure out how likely conflicts are, and try to come up
> with a stress test?

Will try something out by hot plugging a memory range without actually onlining it
while there is another vmalloc stress running on the system.

> 
> Is it possible to avoid these specific conflicts (ignoring ptdump) by
> aligning VA regions such that they cannot share intermediate levels of
> table?

Kernel VA space layout is platform specific where core MM does not mandate much. 
Hence generic modifiers should not make any assumptions regarding it but protect
themselves with locks. Doing any thing other than that is just pushing the problem
to future.

