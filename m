Return-Path: <SRS0=SBXn=SP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98D54C10F11
	for <linux-mm@archiver.kernel.org>; Sat, 13 Apr 2019 08:14:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 202A02075B
	for <linux-mm@archiver.kernel.org>; Sat, 13 Apr 2019 08:14:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 202A02075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 734086B0007; Sat, 13 Apr 2019 04:14:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E4706B000A; Sat, 13 Apr 2019 04:14:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D24F6B000C; Sat, 13 Apr 2019 04:14:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35A026B0007
	for <linux-mm@kvack.org>; Sat, 13 Apr 2019 04:14:35 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id r14so5062769vkd.18
        for <linux-mm@kvack.org>; Sat, 13 Apr 2019 01:14:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=ftCouX3aIrsVUDVU2tEZO5TsWSM/r4gVi1ud8H3nne8=;
        b=W62w37ZekVI7O7dqKgU+7dYIYX6HfLWA6cLFztWewu3lzzhkL7UtPOjY+aI4oECZSO
         cK4h1+ehVKgcQfaqcloXnR0duhH9OHaLPuJnrVYWflcQG4jhbjt7reIeYsna1PZO/z36
         ksOSsptCMCVtCz2eXLvl5aNNuq9thJoIWypVAy9T1ga7qh5Nz8myy72hZXaI7QCyhj1Q
         EvQPFy7/oDIBsek9RHqETYfr1UU2WjtWJB/RxMqFWrv/ZeO+Lsqh8VSt5X25aZ/UVvxv
         cKMKOXlOSQM06YqPxdIah9gSk5j5Wp43UBVWw1LjJ0Vs68a6OxyWLs4mQjpE5bW3y3ma
         k64Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAXOC8y1u8FEGalMne/+yP27UJAMiwb+TLVib30jUH3EK3DdDASu
	3Ozca9YTIj3TSM+ehZZmt+9bW9taE9VpTf+/jePip94HIV349RrPxLKeiBQjVtFqHIiwTey5QbO
	LEe+vsctMjOzKqiMnB4CsWB6pGjh9CDstiKNGY4vGGUod0BfoM7F729mL1MzKJ5eKLg==
X-Received: by 2002:a67:eed5:: with SMTP id o21mr34984572vsp.4.1555143274883;
        Sat, 13 Apr 2019 01:14:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHhcyiIV1vUh+gngJU5ujNJ2PAr9TpQTTKIESb0wLrBdicEVT+eRSExzUjFz03++0OMHV3
X-Received: by 2002:a67:eed5:: with SMTP id o21mr34984553vsp.4.1555143273792;
        Sat, 13 Apr 2019 01:14:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555143273; cv=none;
        d=google.com; s=arc-20160816;
        b=l43xCXhMwv+HhB6FZWPJ6k6ldPts2CueBajC2o2vB81X0VlzL0mdTGdr7J4T5slesL
         CP3RwQA58mMWOzsTNkG4w5Nn2osLNUGckzudO6EujwSDVi5GF6TJ82eFRnHVoKfOdd3g
         eA26IAf+flFnZItEfkfNMLIZK6V1EgEvaP131S27sRshr03B66SWYdKLtfXK74PRenCW
         jYgTUEOUtOeY8d3PASufyXQjpERKSK7iurQN2MvyM++W+/hewIw8HgNPi3zM5GoTf6mR
         V+/4dnAO0ipevOrgW3Lehx1BdgOve94t8nWJ14uHYAqnnYafDZxJKuS8Z2Vscz286ZS3
         ziBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=ftCouX3aIrsVUDVU2tEZO5TsWSM/r4gVi1ud8H3nne8=;
        b=Kd+vTWB5skwzpxD8mPnXnGNuDIShqib71/35LUX+EvLSffEmhCiXPH50ekhEvMD69l
         a5adVv/K4kJgoTllTDzt5USi5zCqjkpUYCdLYfG0lZCKjOfSDfKDh5Gg0yBsGM5Vl73f
         8JGWRUw+h4yUiGvU/4GvXfST/fr6/VU2X+NjVqO0hEfZBxrDljiGk0fDz7ONoYntzvoL
         JkkfqWJgWJSnpe1SczdSsIhCN886LZ0p0NoVBjg0hbf93sBS6Uj8fShga4QiueHaOcWX
         7JcUFKNQEog2waAHraPIwd8X2KaWd+jghgDQwZ2N44pE5h/UN5P2qKgQdt7IxdE5fT3l
         AXKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id z129si2761979vkd.66.2019.04.13.01.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Apr 2019 01:14:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 53078FAE37DBDE6B4A31;
	Sat, 13 Apr 2019 16:14:27 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Sat, 13 Apr 2019
 16:14:18 +0800
Subject: Re: [PATCH v3 3/4] arm64: kdump: support more than one crash kernel
 regions
To: Mike Rapoport <rppt@linux.ibm.com>
References: <20190409102819.121335-1-chenzhou10@huawei.com>
 <20190409102819.121335-4-chenzhou10@huawei.com>
 <20190410130917.GC17196@rapoport-lnx>
 <137bef2e-8726-fd8f-1cb0-7592074f7870@huawei.com>
CC: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <673b95eb-ebdc-6fb0-e118-3dac7e04d272@huawei.com>
Date: Sat, 13 Apr 2019 16:14:16 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <137bef2e-8726-fd8f-1cb0-7592074f7870@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On 2019/4/11 20:17, Chen Zhou wrote:
> Hi Mike,
> 
> This overall looks well.
> Replacing memblock_cap_memory_range() with memblock_cap_memory_ranges() was what i wanted
> to do in v1, sorry for don't express that clearly.
> 
> But there are some issues as below. After fixing this, it can work correctly.
> 
> On 2019/4/10 21:09, Mike Rapoport wrote:
>> Hi,
>>
>> On Tue, Apr 09, 2019 at 06:28:18PM +0800, Chen Zhou wrote:
>>> After commit (arm64: kdump: support reserving crashkernel above 4G),
>>> there may be two crash kernel regions, one is below 4G, the other is
>>> above 4G.
>>>
>>> Crash dump kernel reads more than one crash kernel regions via a dtb
>>> property under node /chosen,
>>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
>>>
>>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>>> ---
>>>  arch/arm64/mm/init.c     | 66 ++++++++++++++++++++++++++++++++++++++++--------
>>>  include/linux/memblock.h |  6 +++++
>>>  mm/memblock.c            |  7 ++---
>>>  3 files changed, 66 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>>> index 3bebddf..0f18665 100644
>>> --- a/arch/arm64/mm/init.c
>>> +++ b/arch/arm64/mm/init.c
>>> @@ -65,6 +65,11 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
>>>  
>>>  #ifdef CONFIG_KEXEC_CORE
>>>  
>>> +/* at most two crash kernel regions, low_region and high_region */
>>> +#define CRASH_MAX_USABLE_RANGES	2
>>> +#define LOW_REGION_IDX			0
>>> +#define HIGH_REGION_IDX			1
>>> +
>>>  /*
>>>   * reserve_crashkernel() - reserves memory for crash kernel
>>>   *
>>> @@ -297,8 +302,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>  		const char *uname, int depth, void *data)
>>>  {
>>>  	struct memblock_region *usablemem = data;
>>> -	const __be32 *reg;
>>> -	int len;
>>> +	const __be32 *reg, *endp;
>>> +	int len, nr = 0;
>>>  
>>>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
>>>  		return 0;
>>> @@ -307,22 +312,63 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
>>>  		return 1;
>>>  
>>> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>> +	endp = reg + (len / sizeof(__be32));
>>> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
>>> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>>> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
>>> +
>>> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
>>> +			break;
>>> +	}
>>>  
>>>  	return 1;
>>>  }
>>>  
>>>  static void __init fdt_enforce_memory_region(void)
>>>  {
>>> -	struct memblock_region reg = {
>>> -		.size = 0,
>>> -	};
>>> +	int i, cnt = 0;
>>> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
>>
>> I only now noticed that fdt_enforce_memory_region() uses memblock_region to
>> pass the ranges around. If we'd switch to memblock_type instead, the
>> implementation of memblock_cap_memory_ranges() would be really
>> straightforward. Can you check if the below patch works for you? 
>>
>> >From e476d584098e31273af573e1a78e308880c5cf28 Mon Sep 17 00:00:00 2001
>> From: Mike Rapoport <rppt@linux.ibm.com>
>> Date: Wed, 10 Apr 2019 16:02:32 +0300
>> Subject: [PATCH] memblock: extend memblock_cap_memory_range to multiple ranges
>>
>> The memblock_cap_memory_range() removes all the memory except the range
>> passed to it. Extend this function to recieve memblock_type with the
>> regions that should be kept. This allows switching to simple iteration over
>> memblock arrays with 'for_each_mem_range' to remove the unneeded memory.
>>
>> Enable use of this function in arm64 for reservation of multile regions for
>> the crash kernel.
>>
>> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
>> ---
>>  arch/arm64/mm/init.c     | 34 ++++++++++++++++++++++++----------
>>  include/linux/memblock.h |  2 +-
>>  mm/memblock.c            | 45 ++++++++++++++++++++++-----------------------
>>  3 files changed, 47 insertions(+), 34 deletions(-)
>>
>>  
>> -void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
>> +void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
>>  {
>> -	int start_rgn, end_rgn;
>> -	int i, ret;
>> -
>> -	if (!size)
>> -		return;
>> -
>> -	ret = memblock_isolate_range(&memblock.memory, base, size,
>> -						&start_rgn, &end_rgn);
>> -	if (ret)
>> -		return;
>> -
>> -	/* remove all the MAP regions */
>> -	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
>> -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
>> -			memblock_remove_region(&memblock.memory, i);
>> +	phys_addr_t start, end;
>> +	u64 i;
>>  
>> -	for (i = start_rgn - 1; i >= 0; i--)
>> -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
>> -			memblock_remove_region(&memblock.memory, i);
>> +	/* truncate memory while skipping NOMAP regions */
>> +	for_each_mem_range(i, &memblock.memory, regions_to_keep, NUMA_NO_NODE,
>> +			   MEMBLOCK_NONE, &start, &end, NULL)
>> +		memblock_remove(start, end);
> 
> 1. use memblock_remove(start, size) instead of memblock_remove(start, end).
> 
> 2. There is a another hidden issue. We couldn't mix __next_mem_range()(called by for_each_mem_range) operation
> with remove operation because __next_mem_range() records the index of last time. If we do remove between
> __next_mem_range(), the index may be mess.
> 
> Therefore, we could do remove operation after for_each_mem_range like this, solution A:
>  void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
>  {
> -	phys_addr_t start, end;
> -	u64 i;
> +	phys_addr_t start[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> +	phys_addr_t end[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> +	u64 i, nr = 0;
> 
>  	/* truncate memory while skipping NOMAP regions */
>  	for_each_mem_range(i, &memblock.memory, regions_to_keep, NUMA_NO_NODE,
> -			   MEMBLOCK_NONE, &start, &end, NULL)
> -		memblock_remove(start, end);
> +			   MEMBLOCK_NONE, &start[nr], &end[nr], NULL)
> +		nr++;
> +	for (i = 0; i < nr; i++)
> +		memblock_remove(start[i], end[i] - start[i]);
> 
>  	/* truncate the reserved regions */
> +	nr = 0;
>  	for_each_mem_range(i, &memblock.reserved, regions_to_keep, NUMA_NO_NODE,
> -			   MEMBLOCK_NONE, &start, &end, NULL)
> -		memblock_remove_range(&memblock.reserved, start, end);
> +			   MEMBLOCK_NONE, &start[nr], &end[nr], NULL)
> +		nr++;
> +	for (i = 0; i < nr; i++)
> +		memblock_remove_range(&memblock.reserved, start[i],
> +				end[i] - start[i]);
>  }
> 
> But a warning occurs when compiling:
>   CALL    scripts/atomic/check-atomics.sh
>   CALL    scripts/checksyscalls.sh
>   CHK     include/generated/compile.h
>   CC      mm/memblock.o
> mm/memblock.c: In function ‘memblock_cap_memory_ranges’:
> mm/memblock.c:1635:1: warning: the frame size of 36912 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>  }
> 
> another solution is my implementation in v1, solution B:
> +void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)

----------
> +{
> +   int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
> +   int i, j, ret, nr = 0;
> +   memblock_region *regs = regions_to_keep->regions;
> +
> +   nr = regions_to_keep -> cnt;
> +   if (!nr)
> +       return;
----------
Sorry, i sent the drafts by mistake. I mixed the drafts with my tested version.
These lines replace with below.

+       int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
+       int i, j, ret, nr = 0;
+       struct memblock_region *regs = regions_to_keep->regions;
+
+       for (i = 0; i < regions_to_keep->cnt; i++) {
+               ret = memblock_isolate_range(&memblock.memory, regs[i].base,
+                               regs[i].size, &start_rgn[i], &end_rgn[i]);
+               if (ret)
+                       break;
+               nr++;
+       }
+       if (!nr)
+               return;

Thanks,
Chen Zhou

> +
> +   /* remove all the MAP regions */
> +   for (i = memblock.memory.cnt - 1; i >= end_rgn[nr - 1]; i--)
> +       if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +           memblock_remove_region(&memblock.memory, i);
> +
> +   for (i = nr - 1; i > 0; i--)
> +       for (j = start_rgn[i] - 1; j >= end_rgn[i - 1]; j--)
> +           if (!memblock_is_nomap(&memblock.memory.regions[j]))
> +               memblock_remove_region(&memblock.memory, j);
> +
> +   for (i = start_rgn[0] - 1; i >= 0; i--)
> +       if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +           memblock_remove_region(&memblock.memory, i);
> +
> +   /* truncate the reserved regions */
> +   memblock_remove_range(&memblock.reserved, 0, regs[0].base);
> +
> +   for (i = nr - 1; i > 0; i--)
> +       memblock_remove_range(&memblock.reserved,
> +               regs[i - 1].base + regs[i - 1].size,
> +		regs[i].base - regs[i - 1].base - regs[i - 1].size);
> +
> +   memblock_remove_range(&memblock.reserved,
> +           regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
> +}
> 
> solution A: 	phys_addr_t start[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> 		phys_addr_t end[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> start, end is physical addr
> 
> solution B: 	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
> start_rgn, end_rgn is rgn index		
> 
> Solution B do less remove operations and with no warning comparing to solution A.
> I think solution B is better, could you give some suggestions?
> 
>>  
>>  	/* truncate the reserved regions */
>> -	memblock_remove_range(&memblock.reserved, 0, base);
>> -	memblock_remove_range(&memblock.reserved,
>> -			base + size, PHYS_ADDR_MAX);
>> +	for_each_mem_range(i, &memblock.reserved, regions_to_keep, NUMA_NO_NODE,
>> +			   MEMBLOCK_NONE, &start, &end, NULL)
>> +		memblock_remove_range(&memblock.reserved, start, end);
> 
> There are the same issues as above.
> 
>>  }
>>  
>>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>>  {
>> +	struct memblock_region rgn = {
>> +		.base = 0,
>> +	};
>> +
>> +	struct memblock_type region_to_keep = {
>> +		.cnt = 1,
>> +		.max = 1,
>> +		.regions = &rgn,
>> +	};
>> +
>>  	phys_addr_t max_addr;
>>  
>>  	if (!limit)
>> @@ -1646,7 +1644,8 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>>  	if (max_addr == PHYS_ADDR_MAX)
>>  		return;
>>  
>> -	memblock_cap_memory_range(0, max_addr);
>> +	region_to_keep.regions[0].size = max_addr;
>> +	memblock_cap_memory_ranges(&region_to_keep);
>>  }
>>  
>>  static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
>>
> 
> Thanks,
> Chen Zhou
> 

