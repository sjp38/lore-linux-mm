Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 536DAC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 02:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F121C206DF
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 02:17:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F121C206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90A7E6B000C; Thu,  4 Apr 2019 22:17:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BA6C6B000D; Thu,  4 Apr 2019 22:17:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A9BE6B000E; Thu,  4 Apr 2019 22:17:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 483DC6B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 22:17:29 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id s184so2140221oig.19
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 19:17:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=5EXWNx4XVhZicy/gXHezfs418pH8qCwraCozTIOzitE=;
        b=eK67/mlgnwUrjx3xu5TV5N5xKbjQsD8kK6BD5JHt+8sSJBPecfpL48eZmoa69dWsHj
         pMl5BMOggvBCALweK7Z+6D1DEDY1avmJM5ugk6W+A7bFND07Gb5ETsLDv0a/Q9fNf3V+
         nGDb3MXq22pQrtJEja0OuQZXYf5K2Bo/lpfyyk/6DL1QEXLplGgD2sjznX8L1uTg0pMg
         R88t9Zz7/p9gXaNtZlohvjK9yYthQM4seUWuRoGEj6znsGzPXxvYf7fUtxxliUFTYIZC
         t9ApN3CHlLvHd9oXd6WunRqbgAdBQLD2YksgSpc4gmqn8TB/I0k6czjDcuhruU+imjVP
         vlIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAWu6px/a74Ne2ZKKVg8J8M8lAdE4YQcWlGORLmyGO+0POrN492h
	UMSdXuxX51F9/Nfd9cRseTJ51e2Bjt7ftM9lMMpaCK4htTiI6DSQNU4vwZySodor9J66bVGGQzE
	1TqKIIDC5S8PFoG37koCOCt1qPAMvreD3ZKhh4U1odufWefGes72N5U5Ap2dfXkLFJQ==
X-Received: by 2002:aca:ecd1:: with SMTP id k200mr5540776oih.15.1554430648963;
        Thu, 04 Apr 2019 19:17:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIZ84O0DRji4eqEBK2RMC2Cn8/pZzrb9RBE2IeFO5cgumnfQL4eQqHZAkbd68VNdFsjKYn
X-Received: by 2002:aca:ecd1:: with SMTP id k200mr5540728oih.15.1554430647868;
        Thu, 04 Apr 2019 19:17:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554430647; cv=none;
        d=google.com; s=arc-20160816;
        b=FDVrwzTBfKsYAVnEl4xj+GfNqw2Rj9fALIfwrQmhJt0f3u2pKwVCFkWaut+fXFCtQl
         rZc41Y7idcXbHhJMEEccxh850XdrXkPQfB3rslUBaHuYE9M8wyGQ0hvYTNHAN+i6Wf9j
         aZ4EW3fVXmfSF/ygf8oG7e0d2buMMEherVUAms97gSviM/HtCRHGlqjb1opHh2mSB4AU
         L0FcY57Kf0rfqU3UOzSmH2qAW8l2veguFuNXcVAN/3T9WEAeNDBaBe5OxMRVH/iN17WD
         p2RYfN10vL7fB2vzw1GBNioVx5u9aiK/sddJc9WqxnrMPDL+SOuH7oggOwaLsVHpxNno
         iKXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=5EXWNx4XVhZicy/gXHezfs418pH8qCwraCozTIOzitE=;
        b=p6J+sGnb8AIfjgcYJGAWyn1GXLhiLJUtqtpumdJInT24r1MyIeiNUpMRdn84eJvCHB
         mJcH+0hmrADUGdMsPQ6t9FqLo1UPxAj6P1KUaeTAUw1hL4zkOcnXt4gq4BxUjvDxtihe
         KmHXTp5Uf/tTAu1Z/cGAuGXRX3thel4hEFA91ufINmVP0xHkYoKdH6/ei7/ZRN4gMSgL
         w9e/d5AtpqbbbTX0igJtxruAXdQKIPX+5v88mWxuGQEDI243bm/2zBNqP354BTlspjPB
         RB+XlT99RjoTVK+d7HmYDLhXxxuB2JqmvESoj+/SwL/oJ5bIR0SrWg3DA5SU3WURzs4y
         Pl6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id k70si9181095oih.18.2019.04.04.19.17.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 19:17:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 900A4657617139DA5EEF;
	Fri,  5 Apr 2019 10:17:21 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Fri, 5 Apr 2019
 10:17:15 +0800
Subject: Re: [PATCH 2/3] arm64: kdump: support more than one crash kernel
 regions
To: Mike Rapoport <rppt@linux.ibm.com>
References: <20190403030546.23718-1-chenzhou10@huawei.com>
 <20190403030546.23718-3-chenzhou10@huawei.com>
 <20190403112929.GA7715@rapoport-lnx>
 <f98a5559-3659-fb35-3765-15861e70a796@huawei.com>
 <20190404144408.GA6433@rapoport-lnx>
CC: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<takahiro.akashi@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <kexec@lists.infradead.org>,
	<linux-mm@kvack.org>, <wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <783b8712-ddb1-a52b-81ee-0c6a216e5b7d@huawei.com>
Date: Fri, 5 Apr 2019 10:17:13 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <20190404144408.GA6433@rapoport-lnx>
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

On 2019/4/4 22:44, Mike Rapoport wrote:
> Hi,
> 
> On Wed, Apr 03, 2019 at 09:51:27PM +0800, Chen Zhou wrote:
>> Hi Mike,
>>
>> On 2019/4/3 19:29, Mike Rapoport wrote:
>>> On Wed, Apr 03, 2019 at 11:05:45AM +0800, Chen Zhou wrote:
>>>> After commit (arm64: kdump: support reserving crashkernel above 4G),
>>>> there may be two crash kernel regions, one is below 4G, the other is
>>>> above 4G.
>>>>
>>>> Crash dump kernel reads more than one crash kernel regions via a dtb
>>>> property under node /chosen,
>>>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
>>>>
>>>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>>>> ---
>>>>  arch/arm64/mm/init.c     | 37 +++++++++++++++++++++++++------------
>>>>  include/linux/memblock.h |  1 +
>>>>  mm/memblock.c            | 40 ++++++++++++++++++++++++++++++++++++++++
>>>>  3 files changed, 66 insertions(+), 12 deletions(-)
>>>>
>>>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>>>> index ceb2a25..769c77a 100644
>>>> --- a/arch/arm64/mm/init.c
>>>> +++ b/arch/arm64/mm/init.c
>>>> @@ -64,6 +64,8 @@ EXPORT_SYMBOL(memstart_addr);
>>>>  phys_addr_t arm64_dma_phys_limit __ro_after_init;
>>>>  
>>>>  #ifdef CONFIG_KEXEC_CORE
>>>> +# define CRASH_MAX_USABLE_RANGES        2
>>>> +
>>>>  static int __init reserve_crashkernel_low(void)
>>>>  {
>>>>  	unsigned long long base, low_base = 0, low_size = 0;
>>>> @@ -346,8 +348,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>>  		const char *uname, int depth, void *data)
>>>>  {
>>>>  	struct memblock_region *usablemem = data;
>>>> -	const __be32 *reg;
>>>> -	int len;
>>>> +	const __be32 *reg, *endp;
>>>> +	int len, nr = 0;
>>>>  
>>>>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
>>>>  		return 0;
>>>> @@ -356,22 +358,33 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
>>>>  		return 1;
>>>>  
>>>> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>>> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>>> +	endp = reg + (len / sizeof(__be32));
>>>> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
>>>> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>>> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>>> +
>>>> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
>>>> +			break;
>>>> +	}
>>>>  
>>>>  	return 1;
>>>>  }
>>>>  
>>>>  static void __init fdt_enforce_memory_region(void)
>>>>  {
>>>> -	struct memblock_region reg = {
>>>> -		.size = 0,
>>>> -	};
>>>> -
>>>> -	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
>>>> -
>>>> -	if (reg.size)
>>>> -		memblock_cap_memory_range(reg.base, reg.size);
>>>> +	int i, cnt = 0;
>>>> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
>>>> +
>>>> +	memset(regs, 0, sizeof(regs));
>>>> +	of_scan_flat_dt(early_init_dt_scan_usablemem, regs);
>>>> +
>>>> +	for (i = 0; i < CRASH_MAX_USABLE_RANGES; i++)
>>>> +		if (regs[i].size)
>>>> +			cnt++;
>>>> +		else
>>>> +			break;
>>>> +	if (cnt)
>>>> +		memblock_cap_memory_ranges(regs, cnt);
>>>
>>> Why not simply call memblock_cap_memory_range() for each region?
>>
>> Function memblock_cap_memory_range() removes all memory type ranges except specified range.
>> So if we call memblock_cap_memory_range() for each region simply, there will be no usable-memory
>> on kdump capture kernel.
> 
> Thanks for the clarification.
> I still think that memblock_cap_memory_ranges() is overly complex. 
> 
> How about doing something like this:
> 
> Cap the memory range for [min(regs[*].start, max(regs[*].end)] and then
> removing the range in the middle?

Yes, that would be ok. But that would do one more memblock_cap_memory_range operation.
That is, if there are n regions, we need to do (n + 1) operations, which doesn't seem to
matter.

I agree with you, your idea is better.

Thanks,
Chen Zhou

>  
>> Thanks,
>> Chen Zhou
>>
>>>
>>>>  }
>>>>  
>>>>  void __init arm64_memblock_init(void)
>>>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>>>> index 47e3c06..aeade34 100644
>>>> --- a/include/linux/memblock.h
>>>> +++ b/include/linux/memblock.h
>>>> @@ -446,6 +446,7 @@ phys_addr_t memblock_start_of_DRAM(void);
>>>>  phys_addr_t memblock_end_of_DRAM(void);
>>>>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
>>>>  void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
>>>> +void memblock_cap_memory_ranges(struct memblock_region *regs, int cnt);
>>>>  void memblock_mem_limit_remove_map(phys_addr_t limit);
>>>>  bool memblock_is_memory(phys_addr_t addr);
>>>>  bool memblock_is_map_memory(phys_addr_t addr);
>>>> diff --git a/mm/memblock.c b/mm/memblock.c
>>>> index 28fa8926..1a7f4ee7c 100644
>>>> --- a/mm/memblock.c
>>>> +++ b/mm/memblock.c
>>>> @@ -1697,6 +1697,46 @@ void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
>>>>  			base + size, PHYS_ADDR_MAX);
>>>>  }
>>>>  
>>>> +void __init memblock_cap_memory_ranges(struct memblock_region *regs, int cnt)
>>>> +{
>>>> +	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
>>>> +	int i, j, ret, nr = 0;
>>>> +
>>>> +	for (i = 0; i < cnt; i++) {
>>>> +		ret = memblock_isolate_range(&memblock.memory, regs[i].base,
>>>> +				regs[i].size, &start_rgn[i], &end_rgn[i]);
>>>> +		if (ret)
>>>> +			break;
>>>> +		nr++;
>>>> +	}
>>>> +	if (!nr)
>>>> +		return;
>>>> +
>>>> +	/* remove all the MAP regions */
>>>> +	for (i = memblock.memory.cnt - 1; i >= end_rgn[nr - 1]; i--)
>>>> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
>>>> +			memblock_remove_region(&memblock.memory, i);
>>>> +
>>>> +	for (i = nr - 1; i > 0; i--)
>>>> +		for (j = start_rgn[i] - 1; j >= end_rgn[i - 1]; j--)
>>>> +			if (!memblock_is_nomap(&memblock.memory.regions[j]))
>>>> +				memblock_remove_region(&memblock.memory, j);
>>>> +
>>>> +	for (i = start_rgn[0] - 1; i >= 0; i--)
>>>> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
>>>> +			memblock_remove_region(&memblock.memory, i);
>>>> +
>>>> +	/* truncate the reserved regions */
>>>> +	memblock_remove_range(&memblock.reserved, 0, regs[0].base);
>>>> +
>>>> +	for (i = nr - 1; i > 0; i--)
>>>> +		memblock_remove_range(&memblock.reserved,
>>>> +				regs[i].base, regs[i - 1].base + regs[i - 1].size);
>>>> +
>>>> +	memblock_remove_range(&memblock.reserved,
>>>> +			regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
>>>> +}
>>>> +
>>>>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>>>>  {
>>>>  	phys_addr_t max_addr;
>>>> -- 
>>>> 2.7.4
>>>>
>>>
>>
> 

