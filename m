Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3009EC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:46:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0CF420645
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:46:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0CF420645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E8936B0003; Tue, 23 Apr 2019 03:46:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 698836B0006; Tue, 23 Apr 2019 03:46:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5620B6B0007; Tue, 23 Apr 2019 03:46:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00F266B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 03:45:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m47so7513453edd.15
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 00:45:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yJFw+jJQGi4dqqUFgX+UqaEIBpRzoSJcscEH8bBOMW4=;
        b=GZzionMPHk9A5lybReVShndBJLuHOOjcQRV7MoZizizud2RAnidYjAA2clnvAtWuTO
         am2igW+nbNU6TcpyejqjoetVMDpdrKL8Km7Hw8pRLY5Ym/USSp5PQb/WkBYYOe413Fuh
         RwUf3PPDwMAU0uY+DNn4XORPal4X5zfOiJmYWREKLhSTSDI+nbkPdIANbxgauHjzb4bi
         fFDBpjR02xpCv1zdB8wwDa0qp0MxElQ/wy3cMiVAUFSOulj5A3m2+uecopjWsP9A4fsG
         fhfhJuc273ROErMIlo2i8jVTf7/7c5rV3Nvyh3h3QOhyVNCb3iI1F8vMbQWyN6b42Qtl
         UGMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUkV2YcDK9fsrTCXa2pVG34h2B/7htC1/OFO1EMHSwqiDHRgLkK
	ZKYAoVBFt2cjLxVCs+vXWmPkATtCGRmd0nQ/A+28YS2JP0Y19JbFV2PWJHfdWfMW5e2TbrKAdKP
	IwtWxX5Xa6bsY9eQHhy9X20TNNiDjLhMQD1N0N7OWJlhgvAqcl2kIO/3y5iboUPVVVg==
X-Received: by 2002:a17:906:e285:: with SMTP id gg5mr11931253ejb.229.1556005559505;
        Tue, 23 Apr 2019 00:45:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvK09FXHwB1Wepi52wXa7j1i2QitOcQldHRDC75pw0evPRVjx+YBjlzFJ2VZb3Zduxcd48
X-Received: by 2002:a17:906:e285:: with SMTP id gg5mr11931202ejb.229.1556005558179;
        Tue, 23 Apr 2019 00:45:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556005558; cv=none;
        d=google.com; s=arc-20160816;
        b=AstR68DAQStX089+WS05WtcuLrXhqrj6WZlP2P9fG5l6hN/2PP+nlvg9WxWJjSaJ52
         W+5UOrLOhr2X2FCXSVxOhcaddCx7hBXPfM2SjAuDPZf2XLc6D0XcYv/AjY6fkmlPO+QO
         h3gZjmPtrxVnTNJnhh79enVHUNiMDngbe5U5hJFK+Hp0hsq2zfvcfgxX8vhVgLaoDGzo
         0yJqAwThpy31atSFfSQ7bgAM+9c2PD6Bl6cgxKBinWxevEIKMPR50l6vRbbAeCFKXVN7
         Fc1MzKXUPUJG5gSDYelPHpDSudIPjKOtwCO79ouXxZmQELngjgbVyM4wu7lD7/Lb3Rvt
         07Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yJFw+jJQGi4dqqUFgX+UqaEIBpRzoSJcscEH8bBOMW4=;
        b=OwqwklvFC0PUtUKGYDO+dOrhK1owCK3hNkUuDNDjOx2guW9Il+JR6lwmq+C5jTCKWc
         nGwFoyhVahZmj2EPe672U51AWombpLJQl2/QZoTGjHPe6QhoAGUpQaiva703mLecrBZ7
         ykuJJKjld80wPP0CSLIlsEcEuBqta8Jw6Nuy5lddDm+k9WxuN4B/0R5F8zmraBZWNgr1
         UYRyhxreEyDnU26csd1zzfa8i7K6HssSJc7W6qcXMgjse+lT8GEbP2nCX5hxedf6+j8P
         Zbw8MVSehrMI+Jqcqh7kq1Lxm9bYKxI0gbXGnzAz+TapEkINKjGPRM1yOpSzy+7uyD/U
         sNdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x3si140800ejb.94.2019.04.23.00.45.57
        for <linux-mm@kvack.org>;
        Tue, 23 Apr 2019 00:45:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 00A87374;
	Tue, 23 Apr 2019 00:45:57 -0700 (PDT)
Received: from [10.163.1.68] (unknown [10.163.1.68])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A273F3F706;
	Tue, 23 Apr 2019 00:45:42 -0700 (PDT)
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
To: David Hildenbrand <david@redhat.com>, Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com, mhocko@suse.com, mgorman@techsingularity.net,
 james.morse@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
 <20190415134841.GC13990@lakrids.cambridge.arm.com>
 <2faba38b-ab79-2dda-1b3c-ada5054d91fa@arm.com>
 <20190417142154.GA393@lakrids.cambridge.arm.com>
 <bba0b71c-2d04-d589-e2bf-5de37806548f@arm.com>
 <20190417173948.GB15589@lakrids.cambridge.arm.com>
 <1bdae67b-fcd6-7868-8a92-c8a306c04ec6@arm.com>
 <97413c39-a4a9-ea1b-7093-eb18f950aad7@arm.com>
 <3f9b39d5-e2d2-8f1b-1c66-4bd977d74f4c@redhat.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <5c8e4a69-8c71-85e1-3275-c04f84bde639@arm.com>
Date: Tue, 23 Apr 2019 13:15:43 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <3f9b39d5-e2d2-8f1b-1c66-4bd977d74f4c@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/23/2019 01:07 PM, David Hildenbrand wrote:
> On 23.04.19 09:31, Anshuman Khandual wrote:
>>
>>
>> On 04/18/2019 10:58 AM, Anshuman Khandual wrote:
>>> On 04/17/2019 11:09 PM, Mark Rutland wrote:
>>>> On Wed, Apr 17, 2019 at 10:15:35PM +0530, Anshuman Khandual wrote:
>>>>> On 04/17/2019 07:51 PM, Mark Rutland wrote:
>>>>>> On Wed, Apr 17, 2019 at 03:28:18PM +0530, Anshuman Khandual wrote:
>>>>>>> On 04/15/2019 07:18 PM, Mark Rutland wrote:
>>>>>>>> On Sun, Apr 14, 2019 at 11:29:13AM +0530, Anshuman Khandual wrote:
>>>>
>>>>>>>>> +	spin_unlock(&init_mm.page_table_lock);
>>>>>>>>
>>>>>>>> What precisely is the page_table_lock intended to protect?
>>>>>>>
>>>>>>> Concurrent modification to kernel page table (init_mm) while clearing entries.
>>>>>>
>>>>>> Concurrent modification by what code?
>>>>>>
>>>>>> If something else can *modify* the portion of the table that we're
>>>>>> manipulating, then I don't see how we can safely walk the table up to
>>>>>> this point without holding the lock, nor how we can safely add memory.
>>>>>>
>>>>>> Even if this is to protect something else which *reads* the tables,
>>>>>> other code in arm64 which modifies the kernel page tables doesn't take
>>>>>> the lock.
>>>>>>
>>>>>> Usually, if you can do a lockless walk you have to verify that things
>>>>>> didn't change once you've taken the lock, but we don't follow that
>>>>>> pattern here.
>>>>>>
>>>>>> As things stand it's not clear to me whether this is necessary or
>>>>>> sufficient.
>>>>>
>>>>> Hence lets take more conservative approach and wrap the entire process of
>>>>> remove_pagetable() under init_mm.page_table_lock which looks safe unless
>>>>> in the worst case when free_pages() gets stuck for some reason in which
>>>>> case we have bigger memory problem to deal with than a soft lock up.
>>>>
>>>> Sorry, but I'm not happy with _any_ solution until we understand where
>>>> and why we need to take the init_mm ptl, and have made some effort to
>>>> ensure that the kernel correctly does so elsewhere. It is not sufficient
>>>> to consider this code in isolation.
>>>
>>> We will have to take the kernel page table lock to prevent assumption regarding
>>> present or future possible kernel VA space layout. Wrapping around the entire
>>> remove_pagetable() will be at coarse granularity but I dont see why it should
>>> not sufficient atleast from this particular tear down operation regardless of
>>> how this might affect other kernel pgtable walkers.
>>>
>>> IIUC your concern is regarding other parts of kernel code (arm64/generic) which
>>> assume that kernel page table wont be changing and hence they normally walk the
>>> table without holding pgtable lock. Hence those current pgtabe walker will be
>>> affected after this change.
>>>
>>>>
>>>> IIUC, before this patch we never clear non-leaf entries in the kernel
>>>> page tables, so readers don't presently need to take the ptl in order to
>>>> safely walk down to a leaf entry.
>>>
>>> Got it. Will look into this.
>>>
>>>>
>>>> For example, the arm64 ptdump code never takes the ptl, and as of this
>>>> patch it will blow up if it races with a hot-remove, regardless of
>>>> whether the hot-remove code itself holds the ptl.
>>>
>>> Got it. Are there there more such examples where this can be problematic. I
>>> will be happy to investigate all such places and change/add locking scheme
>>> in there to make them work with memory hot remove.
>>>
>>>>
>>>> Note that the same applies to the x86 ptdump code; we cannot assume that
>>>> just because x86 does something that it happens to be correct.
>>>
>>> I understand. Will look into other non-x86 platforms as well on how they are
>>> dealing with this.
>>>
>>>>
>>>> I strongly suspect there are other cases that would fall afoul of this,
>>>> in both arm64 and generic code.
>>
>> On X86
>>
>> - kernel_physical_mapping_init() takes the lock for pgtable page allocations as well
>>   as all leaf level entries including large mappings.
>>
>> On Power
>>
>> - remove_pagetable() take an overall high level init_mm.page_table_lock as I had
>>   suggested before. __map_kernel_page() calls [pud|pmd|pte]_alloc_[kernel] which
>>   allocates page table pages are protected with init_mm.page_table_lock but then
>>   the actual setting of the leaf entries are not (unlike x86)
>>
>> 	arch_add_memory()
>> 		create_section_mapping()
>> 			radix__create_section_mapping()
>> 				create_physical_mapping()
>> 					__map_kernel_page()
>> On arm64.
>>
>> Both kernel page table dump and linear mapping (__create_pgd_mapping on init_mm)
>> will require init_mm.page_table_lock to be really safe against this new memory
>> hot remove code. I will do the necessary changes as part of this series next time
>> around. IIUC there is no equivalent generic feature for ARM64_PTDUMP_CORE/DEBUGFS.
>> 	 > 
>>> Will start looking into all such possible cases both on arm64 and generic.
>>> Mean while more such pointers would be really helpful.
>>
>> Generic usage for init_mm.pagetable_lock
>>
>> Unless I have missed something else these are the generic init_mm kernel page table
>> modifiers at runtime (at least which uses init_mm.page_table_lock)
>>
>> 	1. ioremap_page_range()		/* Mapped I/O memory area */
>> 	2. apply_to_page_range()	/* Change existing kernel linear map */
>> 	3. vmap_page_range()		/* Vmalloc area */
>>
>> A. IOREMAP
>>
>> ioremap_page_range()
>> 	ioremap_p4d_range()
>> 		p4d_alloc()
>> 		ioremap_try_huge_p4d() -> p4d_set_huge() -> set_p4d()
>> 		ioremap_pud_range()
>> 			pud_alloc()
>> 			ioremap_try_huge_pud() -> pud_set_huge() -> set_pud()
>> 			ioremap_pmd_range()
>> 				pmd_alloc()
>> 				ioremap_try_huge_pmd() -> pmd_set_huge() -> set_pmd()
>> 				ioremap_pte_range()
>> 					pte_alloc_kernel()
>> 						set_pte_at() -> set_pte()
>> B. APPLY_TO_PAGE_RANGE
>>
>> apply_to_page_range()
>> 	apply_to_p4d_range()
>> 		p4d_alloc()
>> 		apply_to_pud_range()
>> 			pud_alloc()
>> 			apply_to_pmd_range()
>> 				pmd_alloc()
>> 				apply_to_pte_range()
>> 					pte_alloc_kernel()
>>
>> C. VMAP_PAGE_RANGE
>>
>> vmap_page_range()
>> vmap_page_range_noflush()
>> 	vmap_p4d_range()
>> 		p4d_alloc()
>> 		vmap_pud_range()
>> 			pud_alloc()
>> 			vmap_pmd_range()
>> 				pmd_alloc()
>> 				vmap_pte_range()
>> 					pte_alloc_kernel()
>> 					set_pte_at()
>>
>> In all of the above.
>>
>> - Page table pages [p4d|pud|pmd|pte]_alloc_[kernel] settings are protected with init_mm.page_table_lock
>> - Should not it require init_mm.page_table_lock for all leaf level (PUD|PMD|PTE) modification as well ?
>> - Should not this require init_mm.page_table_lock for page table walk itself ?
>>
>> Not taking an overall lock for all these three operations will potentially race with an ongoing memory
>> hot remove operation which takes an overall lock as proposed. Wondering if this has this been safe till
>> now ?
>>
> 
> All memory add/remove operations are currently guarded by
> mem_hotplug_lock as far as I know.

Right but it seems like it guards against concurrent memory hot add or remove operations with
respect to memory block, sections, sysfs etc. But does it cover with respect to other init_mm
modifiers or accessors ?

