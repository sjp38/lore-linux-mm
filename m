Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7AE2C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:51:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 649BF206BA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 07:51:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 649BF206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02E1F6B0003; Tue, 23 Apr 2019 03:51:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF78F6B0006; Tue, 23 Apr 2019 03:51:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAF7D6B0007; Tue, 23 Apr 2019 03:51:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B037A6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 03:51:51 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id t30so3794993qtj.19
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 00:51:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=SLAA2+NbwTcwhRW8JAz0qZVZgl2wMbOXPVNc9grUX8I=;
        b=drhwYmqZrf4FI50+2TsGAlrmosCLsmR4IO2yEg4rwnDyk6cmEYkwleRNHDWqdd5C/u
         1bh+mSIB135pvPwqN91bM5HIrSlVu0ASftoF6K/+RO4284p4Lcqs7KQOb6qbrN4r0MJc
         7UmVxSIKU16YcSAIcMqr5DAI5i4+oSdKE7d9vAgqTu1y6yWcOssUEfr4ps85r1DHOTID
         8hYLPCeJndfJG1Yrt8NC+85tI97G+nC37f1TR6Z7M6I3KYp0Se5QtpocraEZ4zQWvUKe
         oN3HTgMoJ+Bm+uPrhEE3lWiQsUWRTUnXVyBLAG50MI9K2Ag073r8w4YHF1lfI6mS+Qew
         MA3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXRDEGVIicpbr759zk1PoEA5albBRrgN4nBGffHc4ZfqtCdiSOy
	huE1PMhdQPf15huMiyPcTG3vmk2jaMqBzPyXe0X7pIleBQ5qZ703Mr1dYm+IzCoy25vmUd1JVIH
	Hj5t0KNpUcNOlU5X7qWdD1BpskQA2+hWn7Oj4HsiSP9aPeKCTfS3zVPMrM1251baD0w==
X-Received: by 2002:a05:620a:11b5:: with SMTP id c21mr18291254qkk.222.1556005911436;
        Tue, 23 Apr 2019 00:51:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJ5vhK0XvLOQGIJaIzlBhMtJmCRKhrHjUASWjWCe9hGYS0UJcqa8gdUfxksbEuM3N7TJJl
X-Received: by 2002:a05:620a:11b5:: with SMTP id c21mr18291225qkk.222.1556005910642;
        Tue, 23 Apr 2019 00:51:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556005910; cv=none;
        d=google.com; s=arc-20160816;
        b=Zf7jATglTkJ7ekBe9rxmT54ylJI6BIZ7hO6DuoHLZU6xEbHT8/9duEBFqyotsuet7o
         nCmwm1r92EhTA/6Esu1gX70oZGj4mVUP68rf5RA0R4Cc/U/67DUIVN0rCd+zf4JoLtED
         YQaBNG3HaigdqmevCOZepZuOQhdBLH0W2hNKHkQ3Uxe0hQHk1KFeBSBs2/VkSUmoQu2h
         2mkXx5UwYglSvApggsog+f6HFIAgfh528KN8osfNHHcxmQXFQIYhJf25XGOWLg1jYJNZ
         xOE7b8CCJC8+Vd6fE2U8JiHFYdPXemyISh1xa8EDev25B5jt6pg9bq+t7JPC8GksOxl/
         MS7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=SLAA2+NbwTcwhRW8JAz0qZVZgl2wMbOXPVNc9grUX8I=;
        b=kfg6rhdcezgbVv+jmFlT22r4I1sXypeTewK59pYpShtkDdssHd+31Di7NpQwconT1R
         zsyOQO6XUsCJUkD5pSTSbHTBTkgs58FLalrHQoPVZ07bP+d2OUQLDO1u+JyGSExEnWWq
         QobzxlmktN/2BiJelZnPO8Tnvyzgk6O2vXVavB3rZSY/K91bziSTlNsVq//QDIw8whyx
         IbiE3GwPwlHNkKQ80OmQh6oh5WECq4ztvLi+JrIJ979h2jN9Fy/uPwhzru7S8jjHKnwK
         dLTUQXgqknZZb93QM8XgpP2m24MhDNKZLbwNFBDcYw/PdnR3UnTXCxE84tAQBB7XMaZo
         rS9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w13si3287593qtw.84.2019.04.23.00.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 00:51:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A67563086265;
	Tue, 23 Apr 2019 07:51:49 +0000 (UTC)
Received: from [10.36.117.135] (ovpn-117-135.ams2.redhat.com [10.36.117.135])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DAA0F5F9AC;
	Tue, 23 Apr 2019 07:51:45 +0000 (UTC)
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 Mark Rutland <mark.rutland@arm.com>
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
 <5c8e4a69-8c71-85e1-3275-c04f84bde639@arm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <14364fe5-0999-0c60-d109-af22c13deafa@redhat.com>
Date: Tue, 23 Apr 2019 09:51:45 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <5c8e4a69-8c71-85e1-3275-c04f84bde639@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 23 Apr 2019 07:51:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23.04.19 09:45, Anshuman Khandual wrote:
> 
> 
> On 04/23/2019 01:07 PM, David Hildenbrand wrote:
>> On 23.04.19 09:31, Anshuman Khandual wrote:
>>>
>>>
>>> On 04/18/2019 10:58 AM, Anshuman Khandual wrote:
>>>> On 04/17/2019 11:09 PM, Mark Rutland wrote:
>>>>> On Wed, Apr 17, 2019 at 10:15:35PM +0530, Anshuman Khandual wrote:
>>>>>> On 04/17/2019 07:51 PM, Mark Rutland wrote:
>>>>>>> On Wed, Apr 17, 2019 at 03:28:18PM +0530, Anshuman Khandual wrote:
>>>>>>>> On 04/15/2019 07:18 PM, Mark Rutland wrote:
>>>>>>>>> On Sun, Apr 14, 2019 at 11:29:13AM +0530, Anshuman Khandual wrote:
>>>>>
>>>>>>>>>> +	spin_unlock(&init_mm.page_table_lock);
>>>>>>>>>
>>>>>>>>> What precisely is the page_table_lock intended to protect?
>>>>>>>>
>>>>>>>> Concurrent modification to kernel page table (init_mm) while clearing entries.
>>>>>>>
>>>>>>> Concurrent modification by what code?
>>>>>>>
>>>>>>> If something else can *modify* the portion of the table that we're
>>>>>>> manipulating, then I don't see how we can safely walk the table up to
>>>>>>> this point without holding the lock, nor how we can safely add memory.
>>>>>>>
>>>>>>> Even if this is to protect something else which *reads* the tables,
>>>>>>> other code in arm64 which modifies the kernel page tables doesn't take
>>>>>>> the lock.
>>>>>>>
>>>>>>> Usually, if you can do a lockless walk you have to verify that things
>>>>>>> didn't change once you've taken the lock, but we don't follow that
>>>>>>> pattern here.
>>>>>>>
>>>>>>> As things stand it's not clear to me whether this is necessary or
>>>>>>> sufficient.
>>>>>>
>>>>>> Hence lets take more conservative approach and wrap the entire process of
>>>>>> remove_pagetable() under init_mm.page_table_lock which looks safe unless
>>>>>> in the worst case when free_pages() gets stuck for some reason in which
>>>>>> case we have bigger memory problem to deal with than a soft lock up.
>>>>>
>>>>> Sorry, but I'm not happy with _any_ solution until we understand where
>>>>> and why we need to take the init_mm ptl, and have made some effort to
>>>>> ensure that the kernel correctly does so elsewhere. It is not sufficient
>>>>> to consider this code in isolation.
>>>>
>>>> We will have to take the kernel page table lock to prevent assumption regarding
>>>> present or future possible kernel VA space layout. Wrapping around the entire
>>>> remove_pagetable() will be at coarse granularity but I dont see why it should
>>>> not sufficient atleast from this particular tear down operation regardless of
>>>> how this might affect other kernel pgtable walkers.
>>>>
>>>> IIUC your concern is regarding other parts of kernel code (arm64/generic) which
>>>> assume that kernel page table wont be changing and hence they normally walk the
>>>> table without holding pgtable lock. Hence those current pgtabe walker will be
>>>> affected after this change.
>>>>
>>>>>
>>>>> IIUC, before this patch we never clear non-leaf entries in the kernel
>>>>> page tables, so readers don't presently need to take the ptl in order to
>>>>> safely walk down to a leaf entry.
>>>>
>>>> Got it. Will look into this.
>>>>
>>>>>
>>>>> For example, the arm64 ptdump code never takes the ptl, and as of this
>>>>> patch it will blow up if it races with a hot-remove, regardless of
>>>>> whether the hot-remove code itself holds the ptl.
>>>>
>>>> Got it. Are there there more such examples where this can be problematic. I
>>>> will be happy to investigate all such places and change/add locking scheme
>>>> in there to make them work with memory hot remove.
>>>>
>>>>>
>>>>> Note that the same applies to the x86 ptdump code; we cannot assume that
>>>>> just because x86 does something that it happens to be correct.
>>>>
>>>> I understand. Will look into other non-x86 platforms as well on how they are
>>>> dealing with this.
>>>>
>>>>>
>>>>> I strongly suspect there are other cases that would fall afoul of this,
>>>>> in both arm64 and generic code.
>>>
>>> On X86
>>>
>>> - kernel_physical_mapping_init() takes the lock for pgtable page allocations as well
>>>   as all leaf level entries including large mappings.
>>>
>>> On Power
>>>
>>> - remove_pagetable() take an overall high level init_mm.page_table_lock as I had
>>>   suggested before. __map_kernel_page() calls [pud|pmd|pte]_alloc_[kernel] which
>>>   allocates page table pages are protected with init_mm.page_table_lock but then
>>>   the actual setting of the leaf entries are not (unlike x86)
>>>
>>> 	arch_add_memory()
>>> 		create_section_mapping()
>>> 			radix__create_section_mapping()
>>> 				create_physical_mapping()
>>> 					__map_kernel_page()
>>> On arm64.
>>>
>>> Both kernel page table dump and linear mapping (__create_pgd_mapping on init_mm)
>>> will require init_mm.page_table_lock to be really safe against this new memory
>>> hot remove code. I will do the necessary changes as part of this series next time
>>> around. IIUC there is no equivalent generic feature for ARM64_PTDUMP_CORE/DEBUGFS.
>>> 	 > 
>>>> Will start looking into all such possible cases both on arm64 and generic.
>>>> Mean while more such pointers would be really helpful.
>>>
>>> Generic usage for init_mm.pagetable_lock
>>>
>>> Unless I have missed something else these are the generic init_mm kernel page table
>>> modifiers at runtime (at least which uses init_mm.page_table_lock)
>>>
>>> 	1. ioremap_page_range()		/* Mapped I/O memory area */
>>> 	2. apply_to_page_range()	/* Change existing kernel linear map */
>>> 	3. vmap_page_range()		/* Vmalloc area */
>>>
>>> A. IOREMAP
>>>
>>> ioremap_page_range()
>>> 	ioremap_p4d_range()
>>> 		p4d_alloc()
>>> 		ioremap_try_huge_p4d() -> p4d_set_huge() -> set_p4d()
>>> 		ioremap_pud_range()
>>> 			pud_alloc()
>>> 			ioremap_try_huge_pud() -> pud_set_huge() -> set_pud()
>>> 			ioremap_pmd_range()
>>> 				pmd_alloc()
>>> 				ioremap_try_huge_pmd() -> pmd_set_huge() -> set_pmd()
>>> 				ioremap_pte_range()
>>> 					pte_alloc_kernel()
>>> 						set_pte_at() -> set_pte()
>>> B. APPLY_TO_PAGE_RANGE
>>>
>>> apply_to_page_range()
>>> 	apply_to_p4d_range()
>>> 		p4d_alloc()
>>> 		apply_to_pud_range()
>>> 			pud_alloc()
>>> 			apply_to_pmd_range()
>>> 				pmd_alloc()
>>> 				apply_to_pte_range()
>>> 					pte_alloc_kernel()
>>>
>>> C. VMAP_PAGE_RANGE
>>>
>>> vmap_page_range()
>>> vmap_page_range_noflush()
>>> 	vmap_p4d_range()
>>> 		p4d_alloc()
>>> 		vmap_pud_range()
>>> 			pud_alloc()
>>> 			vmap_pmd_range()
>>> 				pmd_alloc()
>>> 				vmap_pte_range()
>>> 					pte_alloc_kernel()
>>> 					set_pte_at()
>>>
>>> In all of the above.
>>>
>>> - Page table pages [p4d|pud|pmd|pte]_alloc_[kernel] settings are protected with init_mm.page_table_lock
>>> - Should not it require init_mm.page_table_lock for all leaf level (PUD|PMD|PTE) modification as well ?
>>> - Should not this require init_mm.page_table_lock for page table walk itself ?
>>>
>>> Not taking an overall lock for all these three operations will potentially race with an ongoing memory
>>> hot remove operation which takes an overall lock as proposed. Wondering if this has this been safe till
>>> now ?
>>>
>>
>> All memory add/remove operations are currently guarded by
>> mem_hotplug_lock as far as I know.
> 
> Right but it seems like it guards against concurrent memory hot add or remove operations with
> respect to memory block, sections, sysfs etc. But does it cover with respect to other init_mm
> modifiers or accessors ?
> 

Don't think so, it's purely for memory add/remove via
add_memory/remove_memory/devm_memremap_pages, not anything beyond that.
Whoever uses get_online_mems/put_online_mems is save in respect to that
- mostly slab/slub.

-- 

Thanks,

David / dhildenb

