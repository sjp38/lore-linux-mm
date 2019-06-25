Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D6E2C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 05:26:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8C0E20652
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 05:26:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8C0E20652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24C7B6B0003; Tue, 25 Jun 2019 01:26:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FD608E0003; Tue, 25 Jun 2019 01:26:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C4648E0002; Tue, 25 Jun 2019 01:26:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B4BED6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 01:26:52 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so23895731edb.1
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 22:26:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0OdKylyv6Kfx7u+c3BHE9VWBciy63ad+hvpspOFu6TY=;
        b=GgFXZAHAcApkJZYFiWWWQIUSDO2TDnFExyu8P7ITJA3seQwH18+oXo8Py3B5juiLf3
         4IDPC1I34hIYQ1d0nkXaHNL9K90IJbW3Mj/VW7HOoORrFYyXLIyyAVF1GimK6YXKRZ2J
         xAP3xZfx22mRW5LKu+7Hlb+pL2Q0R0tz+5Ba1tQzkhJoC+8NPyXU7xnhxaCFDm/m8TE6
         HNIkdKwSv7wFRxoszZUEhgzd4zuQFle/158jSw0tchtkUHjLzlgszTrhYzFtZD5rL9Tf
         bexGaTg6UviccMzU2rFh0iWL4RZhoIye0UgiilcCY2Ie4mZbxBQpSiIjIjQjXrmYcENQ
         a8SQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXZmZhhrWDsbwrQMXvUiNR2ao+3zkdjNKVCv2zzVEm4eW/Ydq7Y
	UR4c2aI6kQSKUFTTvaxGz1YDct19AXa4ckdXNwoYjCqIGaqbFmgar896aynIEfbo8D/iYU2psiX
	q/jXzVOOvnrW8SgTiY7b1XoG4JcjuAOGxPah+LZE6XYs0WfKJt6HQXKV2kOEn7ETfJw==
X-Received: by 2002:a17:906:d7aa:: with SMTP id pk10mr71822304ejb.125.1561440412188;
        Mon, 24 Jun 2019 22:26:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw95k47Pg5+qBWzo4FfisiBQQYQkZl/atlvtmZ0HaYNEyeLZYxY2kdbYGUH3p2ZSm/RYi95
X-Received: by 2002:a17:906:d7aa:: with SMTP id pk10mr71822248ejb.125.1561440411112;
        Mon, 24 Jun 2019 22:26:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561440411; cv=none;
        d=google.com; s=arc-20160816;
        b=Au7R4ACCH1SCR2NtyksEdEMsGxt8H/m7JLFfh1++e/72sPIOa6KHaXBtPAUWHPJGqt
         Yu/pI0MgLE537sQUtnyizMc6iGdefuhYOzptI0h2yZU5Kp0ZCJzhRRWrAeEa63Y6sQ1R
         zGP5uRXEY2lR2bb4fqt7sjKPG81ccDQw1eMVnTv6p864dh9NZH2X/yWQ3dz9zK78mnps
         b1SHF6VmC8BekSO8XpSa5f32Wp4elXkiPMI8W+mvKRzqU1RDoSo+zBtXzeSv0kqgxmSY
         XsVsUjfmxOXcyHSQ9kNxXnP4tAAT6Ix89QfiozbMTbqvEKTHNxX9cA+jy/FMeFKwjum0
         wC3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0OdKylyv6Kfx7u+c3BHE9VWBciy63ad+hvpspOFu6TY=;
        b=u2nIiZtwbfFTgqls2aQF4Ih91SXmIgPZv0Ehvhav77upKirLWGMCFNQJJyoK4hmo6Y
         hRs51nER2T4b88yILUep/UIkfG0rkU1+vsR+p76+vj7YCs0c6ZUI5VodF2FHZNk6XpP5
         aTOjK14tBBZV6iehv/FAXxx1WQgreoxdF9hmbPEYnlZZjJBnxsyvA/trZZOJo20N22Px
         kPnZhIASURoxW9g8ICy63wu+UXNp3LNTOuvQNj9oAdIQRsa//ntgTAAG6gFAoqG+FeuC
         YxAP2K6HT1clZFjDB2gjpu1FX4P8a046H1mBkDPA/8N5yrIF3/DFRJXDeKaO7eq39E3q
         BCkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w4si7810239eji.83.2019.06.24.22.26.50
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 22:26:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 34B53360;
	Mon, 24 Jun 2019 22:26:49 -0700 (PDT)
Received: from [10.163.1.179] (unknown [10.163.1.179])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0688C3F246;
	Mon, 24 Jun 2019 22:28:31 -0700 (PDT)
Subject: Re: [PATCH V6 3/3] arm64/mm: Enable memory hot remove
To: Mark Rutland <mark.rutland@arm.com>, Steve Capper <Steve.Capper@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon
 <Will.Deacon@arm.com>, "mhocko@suse.com" <mhocko@suse.com>,
 "ira.weiny@intel.com" <ira.weiny@intel.com>,
 "david@redhat.com" <david@redhat.com>, "cai@lca.pw" <cai@lca.pw>,
 "logang@deltatee.com" <logang@deltatee.com>,
 James Morse <James.Morse@arm.com>,
 "cpandya@codeaurora.org" <cpandya@codeaurora.org>,
 "arunks@codeaurora.org" <arunks@codeaurora.org>,
 "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
 "mgorman@techsingularity.net" <mgorman@techsingularity.net>,
 "osalvador@suse.de" <osalvador@suse.de>,
 Ard Biesheuvel <Ard.Biesheuvel@arm.com>, nd <nd@arm.com>
References: <1560917860-26169-1-git-send-email-anshuman.khandual@arm.com>
 <1560917860-26169-4-git-send-email-anshuman.khandual@arm.com>
 <20190621143540.GA3376@capper-debian.cambridge.arm.com>
 <20190624165148.GA9847@lakrids.cambridge.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <48f39fa1-c369-c8e2-4572-b7e016dca2d6@arm.com>
Date: Tue, 25 Jun 2019 10:57:07 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190624165148.GA9847@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/24/2019 10:22 PM, Mark Rutland wrote:
> On Fri, Jun 21, 2019 at 03:35:53PM +0100, Steve Capper wrote:
>> Hi Anshuman,
>>
>> On Wed, Jun 19, 2019 at 09:47:40AM +0530, Anshuman Khandual wrote:
>>> The arch code for hot-remove must tear down portions of the linear map and
>>> vmemmap corresponding to memory being removed. In both cases the page
>>> tables mapping these regions must be freed, and when sparse vmemmap is in
>>> use the memory backing the vmemmap must also be freed.
>>>
>>> This patch adds a new remove_pagetable() helper which can be used to tear
>>> down either region, and calls it from vmemmap_free() and
>>> ___remove_pgd_mapping(). The sparse_vmap argument determines whether the
>>> backing memory will be freed.
>>>
>>> remove_pagetable() makes two distinct passes over the kernel page table.
>>> In the first pass it unmaps, invalidates applicable TLB cache and frees
>>> backing memory if required (vmemmap) for each mapped leaf entry. In the
>>> second pass it looks for empty page table sections whose page table page
>>> can be unmapped, TLB invalidated and freed.
>>>
>>> While freeing intermediate level page table pages bail out if any of its
>>> entries are still valid. This can happen for partially filled kernel page
>>> table either from a previously attempted failed memory hot add or while
>>> removing an address range which does not span the entire page table page
>>> range.
>>>
>>> The vmemmap region may share levels of table with the vmalloc region.
>>> There can be conflicts between hot remove freeing page table pages with
>>> a concurrent vmalloc() walking the kernel page table. This conflict can
>>> not just be solved by taking the init_mm ptl because of existing locking
>>> scheme in vmalloc(). Hence unlike linear mapping, skip freeing page table
>>> pages while tearing down vmemmap mapping.
>>>
>>> While here update arch_add_memory() to handle __add_pages() failures by
>>> just unmapping recently added kernel linear mapping. Now enable memory hot
>>> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
>>>
>>> This implementation is overall inspired from kernel page table tear down
>>> procedure on X86 architecture.
>>>
>>> Acked-by: David Hildenbrand <david@redhat.com>
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>
>> FWIW:
>> Acked-by: Steve Capper <steve.capper@arm.com>
>>
>> One minor comment below though.
>>
>>>  arch/arm64/Kconfig  |   3 +
>>>  arch/arm64/mm/mmu.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++++--
>>>  2 files changed, 284 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>>> index 6426f48..9375f26 100644
>>> --- a/arch/arm64/Kconfig
>>> +++ b/arch/arm64/Kconfig
>>> @@ -270,6 +270,9 @@ config HAVE_GENERIC_GUP
>>>  config ARCH_ENABLE_MEMORY_HOTPLUG
>>>  	def_bool y
>>>  
>>> +config ARCH_ENABLE_MEMORY_HOTREMOVE
>>> +	def_bool y
>>> +
>>>  config SMP
>>>  	def_bool y
>>>  
>>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>>> index 93ed0df..9e80a94 100644
>>> --- a/arch/arm64/mm/mmu.c
>>> +++ b/arch/arm64/mm/mmu.c
>>> @@ -733,6 +733,250 @@ int kern_addr_valid(unsigned long addr)
>>>  
>>>  	return pfn_valid(pte_pfn(pte));
>>>  }
>>> +
>>> +#ifdef CONFIG_MEMORY_HOTPLUG
>>> +static void free_hotplug_page_range(struct page *page, size_t size)
>>> +{
>>> +	WARN_ON(!page || PageReserved(page));
>>> +	free_pages((unsigned long)page_address(page), get_order(size));
>>> +}
>>
>> We are dealing with power of 2 number of pages, it makes a lot more
>> sense (to me) to replace the size parameter with order.
>>
>> Also, all the callers are for known compile-time sizes, so we could just
>> translate the size parameter as follows to remove any usage of get_order?
>> PAGE_SIZE -> 0
>> PMD_SIZE -> PMD_SHIFT - PAGE_SHIFT
>> PUD_SIZE -> PUD_SHIFT - PAGE_SHIFT
> 
> Now that I look at this again, the above makes sense to me.
> 
> I'd requested the current form (which I now realise is broken), since
> back in v2 the code looked like:
> 
> static void free_pagetable(struct page *page, int order)
> {
> 	...
> 	free_pages((unsigned long)page_address(page), order);
> 	...
> }
> 
> ... with callsites looking like:
> 
> free_pagetable(pud_page(*pud), get_order(PUD_SIZE));
> 
> ... which I now see is off by PAGE_SHIFT, and we inherited that bug in
> the current code, so the calculated order is vastly larger than it
> should be. It's worrying that doesn't seem to be caught by anything in
> testing. :/

get_order() returns the minimum page allocation order for a given size
which already takes into account PAGE_SHIFT i.e get_order(PAGE_SIZE)
returns 0.

> 
> Anshuman, could you please fold in Steve's suggested change? I'll look
> at the rest of the series shortly, so no need to resend that right away,
> but it would be worth sorting out.

get_order() is already optimized for built in constants. But will replace
with absolute constants as Steve mentioned if that is preferred.

