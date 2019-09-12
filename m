Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E353ECDE20
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 08:37:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1B93208C2
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 08:37:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1B93208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D0886B0003; Thu, 12 Sep 2019 04:37:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A8A76B0005; Thu, 12 Sep 2019 04:37:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BE206B0006; Thu, 12 Sep 2019 04:37:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0231.hostedemail.com [216.40.44.231])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0856B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 04:37:48 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id DEEB1181AC9AE
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 08:37:47 +0000 (UTC)
X-FDA: 75925615374.01.dress32_43f1f6518a35f
X-HE-Tag: dress32_43f1f6518a35f
X-Filterd-Recvd-Size: 5472
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 08:37:46 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BB8C01000;
	Thu, 12 Sep 2019 01:37:45 -0700 (PDT)
Received: from [10.162.41.127] (p8cg001049571a15.blr.arm.com [10.162.41.127])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6006D3F71F;
	Thu, 12 Sep 2019 01:37:39 -0700 (PDT)
Subject: Re: [PATCH V7 3/3] arm64/mm: Enable memory hot remove
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 will@kernel.org, mark.rutland@arm.com, mhocko@suse.com, ira.weiny@intel.com,
 david@redhat.com, cai@lca.pw, logang@deltatee.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com,
 mgorman@techsingularity.net, osalvador@suse.de, ard.biesheuvel@arm.com,
 steve.capper@arm.com, broonie@kernel.org, valentin.schneider@arm.com,
 Robin.Murphy@arm.com, steven.price@arm.com, suzuki.poulose@arm.com
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
 <1567503958-25831-4-git-send-email-anshuman.khandual@arm.com>
 <20190910161759.GI14442@C02TF0J2HF1T.local>
 <9a7a82cd-77d0-bcab-3028-7be0599b0a10@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <93dc87f9-b0e5-140c-fb6c-1fa3d438381f@arm.com>
Date: Thu, 12 Sep 2019 14:07:49 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <9a7a82cd-77d0-bcab-3028-7be0599b0a10@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/12/2019 09:58 AM, Anshuman Khandual wrote:
> 
> On 09/10/2019 09:47 PM, Catalin Marinas wrote:
>> On Tue, Sep 03, 2019 at 03:15:58PM +0530, Anshuman Khandual wrote:
>>> @@ -770,6 +1022,28 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>>>  void vmemmap_free(unsigned long start, unsigned long end,
>>>  		struct vmem_altmap *altmap)
>>>  {
>>> +#ifdef CONFIG_MEMORY_HOTPLUG
>>> +	/*
>>> +	 * FIXME: We should have called remove_pagetable(start, end, true).
>>> +	 * vmemmap and vmalloc virtual range might share intermediate kernel
>>> +	 * page table entries. Removing vmemmap range page table pages here
>>> +	 * can potentially conflict with a concurrent vmalloc() allocation.
>>> +	 *
>>> +	 * This is primarily because vmalloc() does not take init_mm ptl for
>>> +	 * the entire page table walk and it's modification. Instead it just
>>> +	 * takes the lock while allocating and installing page table pages
>>> +	 * via [p4d|pud|pmd|pte]_alloc(). A concurrently vanishing page table
>>> +	 * entry via memory hot remove can cause vmalloc() kernel page table
>>> +	 * walk pointers to be invalid on the fly which can cause corruption
>>> +	 * or worst, a crash.
>>> +	 *
>>> +	 * So free_empty_tables() gets called where vmalloc and vmemmap range
>>> +	 * do not overlap at any intermediate level kernel page table entry.
>>> +	 */
>>> +	unmap_hotplug_range(start, end, true);
>>> +	if (!vmalloc_vmemmap_overlap)
>>> +		free_empty_tables(start, end);
>>> +#endif
>>>  }
>>>  #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
> Hello Catalin,
> 
>> I wonder whether we could simply ignore the vmemmap freeing altogether,
>> just leave it around and not unmap it. This way, we could call
> This would have been an option (even if we just ignore for a moment that
> it might not be the cleanest possible method) if present memory hot remove
> scenarios involved just system RAM of comparable sizes.
> 
> But with persistent memory which will be plugged in as ZONE_DEVICE might
> ask for a vmem_atlamp based vmemmap mapping where the backing memory comes
> from the persistent memory range itself not from existing system RAM. IIRC
> altmap support was originally added because the amount persistent memory on
> a system might be order of magnitude higher than that of regular system RAM.
> During normal memory hot add (without altmap) would have caused great deal
> of consumption from system RAM just for persistent memory range's vmemmap
> mapping. In order to avoid such a scenario altmap was created to allocate
> vmemmap mapping backing memory from the device memory range itself.
> 
> In such cases vmemmap must be unmapped and it's backing memory freed up for
> the complete removal of persistent memory which originally requested for
> altmap based vmemmap backing.
> 
> Just as a reference, the upcoming series which enables altmap support on
> arm64 tries to allocate vmemmap mapping backing memory from the device range
> itself during memory hot add and free them up during memory hot remove. Those
> methods will not be possible if memory hot-remove does not really free up
> vmemmap backing storage.
> 
> https://patchwork.kernel.org/project/linux-mm/list/?series=139299
> 

Just to add in here. There is an ongoing work which will enable allocating
memory from the hot-add range itself even for normal system RAM. So this
might not be specific to ZONE_DEVICE based device/persistent memory alone
for a long time.

https://lore.kernel.org/lkml/20190725160207.19579-1-osalvador@suse.de/

