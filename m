Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 309E3C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 03:11:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E931B20663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 03:11:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E931B20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 849F36B0003; Sun, 23 Jun 2019 23:11:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FB218E0002; Sun, 23 Jun 2019 23:11:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 710218E0001; Sun, 23 Jun 2019 23:11:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2189F6B0003
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 23:11:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s7so18252476edb.19
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 20:11:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=IH1uOF6E2yT2MkaeJ1+Qe/SvhagWe+4Qnde0s8p3jNY=;
        b=KbyfKSYlh7+s9Bpj6WHiOoEYnaSijFWzoVUFulPcEzpL4REDhd0lLx4UkPM5u+Qpdg
         HgcZ2TAB0cpki/Jy0buhOtMUJ7hz13vWVaWJ06T1w9gEtgjSfIEq6tAqCX91BooLd3o6
         4m3I4NIQDkH60dPK64ZDp24BLJ3Qe6vsEAEvwDS20Hf/x/bfl/zpUe+Hb1LyjEPeprl2
         CVUdGi2hvt+RCCdrkqDc/ARq4mbCuXmQUT+YZodkg9dyAYOgNTjBntiiYdMEKQ18Yh8R
         cuCbfg/tI+jUlM6M+Y2S0C6f/WYoNwi0MHcewZfEt1OEDAABzZ47/NUWNRWj6No6zP9i
         +C5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXply3X5gudp74diz/ytMpVNxrWfMOH+9hOyLh9QLVOUeE0aYAn
	HEtnmOCyY18EimxhRa5II5Be9d0mUu0qxGoECxMBOlgAU0LfqVZ5dA98mhm/RwY8oi6zYs1Eb2/
	Kx2s/BQcsL86NuhStxu+db5zmIH99zZOBW35Z18DIbg9N3XstvQ3avNpq7jtvEPU40w==
X-Received: by 2002:a50:92a5:: with SMTP id k34mr136071117eda.90.1561345905680;
        Sun, 23 Jun 2019 20:11:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIxr1CLh9W0ji1nBHxKRHmTuAmtK2fFUXlBzdn4qCmWe9yi1fJeBcs1FfPw//Zsa/tIKfa
X-Received: by 2002:a50:92a5:: with SMTP id k34mr136071072eda.90.1561345904918;
        Sun, 23 Jun 2019 20:11:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561345904; cv=none;
        d=google.com; s=arc-20160816;
        b=noRW4WSm98edMqo8PTlFo0PAmqXwP0ouUtiu8hpSGDHIwEeShsmDMEa88WdWSPDc3K
         PZbvgGYW618Vv7bZ0nOI/zNibPW6d3yG2ZqOWPW3TXGosP+bBDQE12Lg1sXBZf0zh+WN
         rjMofPZxI6o+xzKxTwiMGCUHb5GBJkbLdUMxltKSQCVcqAfMzpDIN3x+X5kD3TzMSjyI
         iR9j7gopf9rLpzEBS2TRpg6pFCn8oIOmC18AXAnIiBfZ2vDlVgcncLjm14HWl7bCopJJ
         vyWKCooPERYSmbQ9eJWs+0WcKH7vcRC2NVe875Rp4g3lNTMwRd2vHweclxQG9BjwBUF1
         BZ7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=IH1uOF6E2yT2MkaeJ1+Qe/SvhagWe+4Qnde0s8p3jNY=;
        b=wvTzggjsy+xS88QC40S4Df/GPM75oWkDpki+n5iyIhwe99aGkOf/fIYCXCVB7Y0Mq8
         ohGGh34PCHDkLfS2zDUuJYGQBAD6mVhl92F89WIbljfIFwdo1aEQwbVo50/0ZqDonaws
         KRBesYJkdYtYDFCz2RIETiub4vbjXFPTLNUruEBivCFSkbW9QxunWoB/7eREWfSJYf7v
         shJTg6WGoW1pp9uXUOge8nR7jYwnnStcHZS5LTYc51Z1xg1EhXHbchkaW6PK8nL61Ipq
         MXd2mKA99rCEOU1BGo0SPaEbbIO7BORt99WuTTA37B6aD5HeNdc2hrlaDiL/9rjH+fuz
         vVXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id x7si8498513edm.177.2019.06.23.20.11.43
        for <linux-mm@kvack.org>;
        Sun, 23 Jun 2019 20:11:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A9D382B;
	Sun, 23 Jun 2019 20:11:42 -0700 (PDT)
Received: from [10.162.41.123] (p8cg001049571a15.blr.arm.com [10.162.41.123])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 559003F246;
	Sun, 23 Jun 2019 20:11:37 -0700 (PDT)
Subject: Re: [PATCH V6 3/3] arm64/mm: Enable memory hot remove
To: Steve Capper <Steve.Capper@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon
 <Will.Deacon@arm.com>, Mark Rutland <Mark.Rutland@arm.com>,
 "mhocko@suse.com" <mhocko@suse.com>,
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
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <4c3bd9f9-d805-5977-6201-8517f2fc1da4@arm.com>
Date: Mon, 24 Jun 2019 08:42:02 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190621143540.GA3376@capper-debian.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/21/2019 08:05 PM, Steve Capper wrote:
> Hi Anshuman,
> 
> On Wed, Jun 19, 2019 at 09:47:40AM +0530, Anshuman Khandual wrote:
>> The arch code for hot-remove must tear down portions of the linear map and
>> vmemmap corresponding to memory being removed. In both cases the page
>> tables mapping these regions must be freed, and when sparse vmemmap is in
>> use the memory backing the vmemmap must also be freed.
>>
>> This patch adds a new remove_pagetable() helper which can be used to tear
>> down either region, and calls it from vmemmap_free() and
>> ___remove_pgd_mapping(). The sparse_vmap argument determines whether the
>> backing memory will be freed.
>>
>> remove_pagetable() makes two distinct passes over the kernel page table.
>> In the first pass it unmaps, invalidates applicable TLB cache and frees
>> backing memory if required (vmemmap) for each mapped leaf entry. In the
>> second pass it looks for empty page table sections whose page table page
>> can be unmapped, TLB invalidated and freed.
>>
>> While freeing intermediate level page table pages bail out if any of its
>> entries are still valid. This can happen for partially filled kernel page
>> table either from a previously attempted failed memory hot add or while
>> removing an address range which does not span the entire page table page
>> range.
>>
>> The vmemmap region may share levels of table with the vmalloc region.
>> There can be conflicts between hot remove freeing page table pages with
>> a concurrent vmalloc() walking the kernel page table. This conflict can
>> not just be solved by taking the init_mm ptl because of existing locking
>> scheme in vmalloc(). Hence unlike linear mapping, skip freeing page table
>> pages while tearing down vmemmap mapping.
>>
>> While here update arch_add_memory() to handle __add_pages() failures by
>> just unmapping recently added kernel linear mapping. Now enable memory hot
>> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
>>
>> This implementation is overall inspired from kernel page table tear down
>> procedure on X86 architecture.
>>
>> Acked-by: David Hildenbrand <david@redhat.com>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
> 
> FWIW:
> Acked-by: Steve Capper <steve.capper@arm.com>

Thanks Steve.

> 
> One minor comment below though.
> 
>>  arch/arm64/Kconfig  |   3 +
>>  arch/arm64/mm/mmu.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++++--
>>  2 files changed, 284 insertions(+), 9 deletions(-)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 6426f48..9375f26 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -270,6 +270,9 @@ config HAVE_GENERIC_GUP
>>  config ARCH_ENABLE_MEMORY_HOTPLUG
>>  	def_bool y
>>  
>> +config ARCH_ENABLE_MEMORY_HOTREMOVE
>> +	def_bool y
>> +
>>  config SMP
>>  	def_bool y
>>  
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index 93ed0df..9e80a94 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -733,6 +733,250 @@ int kern_addr_valid(unsigned long addr)
>>  
>>  	return pfn_valid(pte_pfn(pte));
>>  }
>> +
>> +#ifdef CONFIG_MEMORY_HOTPLUG
>> +static void free_hotplug_page_range(struct page *page, size_t size)
>> +{
>> +	WARN_ON(!page || PageReserved(page));
>> +	free_pages((unsigned long)page_address(page), get_order(size));
>> +}
> 
> We are dealing with power of 2 number of pages, it makes a lot more
> sense (to me) to replace the size parameter with order.
> 
> Also, all the callers are for known compile-time sizes, so we could just
> translate the size parameter as follows to remove any usage of get_order?
> PAGE_SIZE -> 0
> PMD_SIZE -> PMD_SHIFT - PAGE_SHIFT
> PUD_SIZE -> PUD_SHIFT - PAGE_SHIFT

Sure this can be changed but I remember Mark wanted to have this on size
instead of order which I proposed initially.

