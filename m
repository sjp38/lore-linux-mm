Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FFDAC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 03:47:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28C9120854
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 03:47:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28C9120854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE9B26B000D; Thu,  4 Apr 2019 23:47:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9A716B0266; Thu,  4 Apr 2019 23:47:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 989CD6B0269; Thu,  4 Apr 2019 23:47:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAE86B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 23:47:43 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a2so2352067otk.13
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 20:47:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=+yoHYpdFLQqRLhUy3qPe91CdrytEGQklqL0SW6JDqo8=;
        b=s60+aKUGZCeO4BI5UT3oOxtX4gJ/IzHMdmdrb2u9mOh4ZY3TLzYHX1zDRwbct0UPUj
         rrMPji70Ht5sG+tS07+WazWUILXIr4KnPGStkWWdCfUX9lqmO40uqZthA00d/FG+LABk
         D/CB4nyXpD7Vy85pOABm8g4DvfxtD3xyF6yrgMllsFZ0rxeRTifXz8AM8Xp1mbIa+uxv
         ZeYbU73LtoOsR38ju63taSsOv4lLLYsk0BqU1KPvBubLMNE8vgmshoEh8Ffz3E5mYDSn
         vKUQ2uRY3yOGfAZ4Cws2LHOBFoVixxot6u3dFNZ88FBzcnaeUPBM3priZekhgBAYtCZv
         9Uyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAXaTPtExxkX+2+8G0eO7TGBMRnM3KujmwJxr1QMGUHee1OxN877
	hgRRWiSpAIAghqC9I/xBtJSsZDPIOtPZeDohkWjDwE5KYDplR1p/o7MxxwiUWK/mjF/xGBHogRe
	+msr8+yEidy6YGNKZatntK2pwGCSV2eOtMD9GAIrqNkkNaiBzDnfykiGVbaIGAMSabg==
X-Received: by 2002:aca:4f48:: with SMTP id d69mr5640838oib.78.1554436062973;
        Thu, 04 Apr 2019 20:47:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziRA+5PsoHGF/UfJWIOZ0LJ6b4/ChYL0fXhsr4KjgC5Oa4uzkBiYipw8pzRVnwi2gE+zAl
X-Received: by 2002:aca:4f48:: with SMTP id d69mr5640797oib.78.1554436061879;
        Thu, 04 Apr 2019 20:47:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554436061; cv=none;
        d=google.com; s=arc-20160816;
        b=vjSr7NnYKr9GDfydh3AxMHDteh2GsNdnmzsAU/zyNslmd/VqnqsRZFp0+Su/7cGMQa
         N/U5+PTr7lyA9n/BkTQoCA/3OCZPqAiW5y7UPgNkRVqAm6EElKsTXFAOg3jDjdGaMpJA
         MeaxrmOn3rI+OZzuyPhtWwMQEO63q6mdpC8F1cSNdo/Vr6MuYWHWeyF7X73IIjiEP/Zq
         gkwgpzhj58RJNa3XHuCwXOnPo7RrV/NN9nG2vMsNwZYSgeS0zld+eMnVOY2QmtYgtIon
         iiX2A+IrdiT3HOkkaFTdV3TuyVhu8h8nkKtalv16UL7VAuI9qbc883X+6T1Pn3vG91Mt
         dzog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=+yoHYpdFLQqRLhUy3qPe91CdrytEGQklqL0SW6JDqo8=;
        b=YwCdNq7nvihPWzKPrl3O+6nrIg5d7nSRUUb48LhSg6mMP5ZDvVJKjYZBVNF8e9nbRy
         rfhQPuifQb7zgMW+eOtDGyYN9aMf+E189ASlVJO+f0BQcq/od7FpYFbwEi8SaT2ti9JO
         PdHMzh7S2RijbHr/SL+SxlTCssTbAvJs2wfVT+OarJHkSqebaYQNlNTxN16ce1nTicqo
         mzmfm//GZ04GNFnLSx//qaqEt5M12vqefIxQMJL2K2Sjtw3yNB6v1ur+Qx0X9j5QLlUX
         k8eKVPjW87s2LyiJmQgrdpdMPqiW/3+40gV9+gxb1RPUZsjp2UYmrGwmnEh7BSw5f94q
         Nl5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id b185si6360418oia.111.2019.04.04.20.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 20:47:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 210BC442ADFA0137B934;
	Fri,  5 Apr 2019 11:47:37 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Fri, 5 Apr 2019
 11:47:28 +0800
Subject: Re: [PATCH 2/3] arm64: kdump: support more than one crash kernel
 regions
To: Mike Rapoport <rppt@linux.ibm.com>
References: <20190403030546.23718-1-chenzhou10@huawei.com>
 <20190403030546.23718-3-chenzhou10@huawei.com>
 <20190403112929.GA7715@rapoport-lnx>
 <f98a5559-3659-fb35-3765-15861e70a796@huawei.com>
 <20190404144408.GA6433@rapoport-lnx>
 <783b8712-ddb1-a52b-81ee-0c6a216e5b7d@huawei.com>
CC: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<takahiro.akashi@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <kexec@lists.infradead.org>,
	<linux-mm@kvack.org>, <wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <4b188535-c12d-e05b-9154-2c2d580f903b@huawei.com>
Date: Fri, 5 Apr 2019 11:47:27 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <783b8712-ddb1-a52b-81ee-0c6a216e5b7d@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On 2019/4/5 10:17, Chen Zhou wrote:
> Hi Mike,
> 
> On 2019/4/4 22:44, Mike Rapoport wrote:
>> Hi,
>>
>> On Wed, Apr 03, 2019 at 09:51:27PM +0800, Chen Zhou wrote:
>>> Hi Mike,
>>>
>>> On 2019/4/3 19:29, Mike Rapoport wrote:
>>>> On Wed, Apr 03, 2019 at 11:05:45AM +0800, Chen Zhou wrote:
>>>>> After commit (arm64: kdump: support reserving crashkernel above 4G),
>>>>> there may be two crash kernel regions, one is below 4G, the other is
>>>>> above 4G.
>>>>>
>>>>> Crash dump kernel reads more than one crash kernel regions via a dtb
>>>>> property under node /chosen,
>>>>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
>>>>>
>>>>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>>>>> ---
>>>>>  arch/arm64/mm/init.c     | 37 +++++++++++++++++++++++++------------
>>>>>  include/linux/memblock.h |  1 +
>>>>>  mm/memblock.c            | 40 ++++++++++++++++++++++++++++++++++++++++
>>>>>  3 files changed, 66 insertions(+), 12 deletions(-)
>>>>>
>>>>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>>>>> index ceb2a25..769c77a 100644
>>>>> --- a/arch/arm64/mm/init.c
>>>>> +++ b/arch/arm64/mm/init.c
>>>>> @@ -64,6 +64,8 @@ EXPORT_SYMBOL(memstart_addr);
>>>>>  phys_addr_t arm64_dma_phys_limit __ro_after_init;
>>>>>  
>>>>>  #ifdef CONFIG_KEXEC_CORE
>>>>> +# define CRASH_MAX_USABLE_RANGES        2
>>>>> +
>>>>>  static int __init reserve_crashkernel_low(void)
>>>>>  {
>>>>>  	unsigned long long base, low_base = 0, low_size = 0;
>>>>> @@ -346,8 +348,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>>>  		const char *uname, int depth, void *data)
>>>>>  {
>>>>>  	struct memblock_region *usablemem = data;
>>>>> -	const __be32 *reg;
>>>>> -	int len;
>>>>> +	const __be32 *reg, *endp;
>>>>> +	int len, nr = 0;
>>>>>  
>>>>>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
>>>>>  		return 0;
>>>>> @@ -356,22 +358,33 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>>>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
>>>>>  		return 1;
>>>>>  
>>>>> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>>>> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>>>> +	endp = reg + (len / sizeof(__be32));
>>>>> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
>>>>> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>>>> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>>>> +
>>>>> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
>>>>> +			break;
>>>>> +	}
>>>>>  
>>>>>  	return 1;
>>>>>  }
>>>>>  
>>>>>  static void __init fdt_enforce_memory_region(void)
>>>>>  {
>>>>> -	struct memblock_region reg = {
>>>>> -		.size = 0,
>>>>> -	};
>>>>> -
>>>>> -	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
>>>>> -
>>>>> -	if (reg.size)
>>>>> -		memblock_cap_memory_range(reg.base, reg.size);
>>>>> +	int i, cnt = 0;
>>>>> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
>>>>> +
>>>>> +	memset(regs, 0, sizeof(regs));
>>>>> +	of_scan_flat_dt(early_init_dt_scan_usablemem, regs);
>>>>> +
>>>>> +	for (i = 0; i < CRASH_MAX_USABLE_RANGES; i++)
>>>>> +		if (regs[i].size)
>>>>> +			cnt++;
>>>>> +		else
>>>>> +			break;
>>>>> +	if (cnt)
>>>>> +		memblock_cap_memory_ranges(regs, cnt);
>>>>
>>>> Why not simply call memblock_cap_memory_range() for each region?
>>>
>>> Function memblock_cap_memory_range() removes all memory type ranges except specified range.
>>> So if we call memblock_cap_memory_range() for each region simply, there will be no usable-memory
>>> on kdump capture kernel.
>>
>> Thanks for the clarification.
>> I still think that memblock_cap_memory_ranges() is overly complex. 
>>
>> How about doing something like this:
>>
>> Cap the memory range for [min(regs[*].start, max(regs[*].end)] and then
>> removing the range in the middle?
> 
> Yes, that would be ok. But that would do one more memblock_cap_memory_range operation.
> That is, if there are n regions, we need to do (n + 1) operations, which doesn't seem to
> matter.
> 
> I agree with you, your idea is better.
> 
> Thanks,
> Chen Zhou

Sorry, just ignore my previous reply, I got that wrong.

I think it carefully, we can cap the memory range for [min(regs[*].start, max(regs[*].end)]
firstly. But how to remove the middle ranges, we still can't use memblock_cap_memory_range()
directly and the extra remove operation may be complex.

For more than one regions, i think add a new memblock_cap_memory_ranges() may be better.
Besides, memblock_cap_memory_ranges() is also applicable for one region.

How about replace memblock_cap_memory_range() with memblock_cap_memory_ranges()?

Thanks,
Chen Zhou

> 
>>  
>>> Thanks,
>>> Chen Zhou
>>>
>>>>
>>>>>  }
>>>>>  
>>>>>  void __init arm64_memblock_init(void)
>>>>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>>>>> index 47e3c06..aeade34 100644
>>>>> --- a/include/linux/memblock.h
>>>>> +++ b/include/linux/memblock.h
>>>>> @@ -446,6 +446,7 @@ phys_addr_t memblock_start_of_DRAM(void);
>>>>>  phys_addr_t memblock_end_of_DRAM(void);
>>>>>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
>>>>>  void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
>>>>> +void memblock_cap_memory_ranges(struct memblock_region *regs, int cnt);
>>>>>  void memblock_mem_limit_remove_map(phys_addr_t limit);
>>>>>  bool memblock_is_memory(phys_addr_t addr);
>>>>>  bool memblock_is_map_memory(phys_addr_t addr);
>>>>> diff --git a/mm/memblock.c b/mm/memblock.c
>>>>> index 28fa8926..1a7f4ee7c 100644
>>>>> --- a/mm/memblock.c
>>>>> +++ b/mm/memblock.c
>>>>> @@ -1697,6 +1697,46 @@ void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
>>>>>  			base + size, PHYS_ADDR_MAX);
>>>>>  }
>>>>>  
>>>>> +void __init memblock_cap_memory_ranges(struct memblock_region *regs, int cnt)
>>>>> +{
>>>>> +	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
>>>>> +	int i, j, ret, nr = 0;
>>>>> +
>>>>> +	for (i = 0; i < cnt; i++) {
>>>>> +		ret = memblock_isolate_range(&memblock.memory, regs[i].base,
>>>>> +				regs[i].size, &start_rgn[i], &end_rgn[i]);
>>>>> +		if (ret)
>>>>> +			break;
>>>>> +		nr++;
>>>>> +	}
>>>>> +	if (!nr)
>>>>> +		return;
>>>>> +
>>>>> +	/* remove all the MAP regions */
>>>>> +	for (i = memblock.memory.cnt - 1; i >= end_rgn[nr - 1]; i--)
>>>>> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
>>>>> +			memblock_remove_region(&memblock.memory, i);
>>>>> +
>>>>> +	for (i = nr - 1; i > 0; i--)
>>>>> +		for (j = start_rgn[i] - 1; j >= end_rgn[i - 1]; j--)
>>>>> +			if (!memblock_is_nomap(&memblock.memory.regions[j]))
>>>>> +				memblock_remove_region(&memblock.memory, j);
>>>>> +
>>>>> +	for (i = start_rgn[0] - 1; i >= 0; i--)
>>>>> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
>>>>> +			memblock_remove_region(&memblock.memory, i);
>>>>> +
>>>>> +	/* truncate the reserved regions */
>>>>> +	memblock_remove_range(&memblock.reserved, 0, regs[0].base);
>>>>> +
>>>>> +	for (i = nr - 1; i > 0; i--)
>>>>> +		memblock_remove_range(&memblock.reserved,
>>>>> +				regs[i].base, regs[i - 1].base + regs[i - 1].size);
>>>>> +
>>>>> +	memblock_remove_range(&memblock.reserved,
>>>>> +			regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
>>>>> +}
>>>>> +
>>>>>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>>>>>  {
>>>>>  	phys_addr_t max_addr;
>>>>> -- 
>>>>> 2.7.4
>>>>>
>>>>
>>>
>>
> 
> 
> .
> 

