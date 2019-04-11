Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66E91C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:18:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12AA22133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:18:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12AA22133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6A686B000D; Thu, 11 Apr 2019 08:18:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF34E6B000E; Thu, 11 Apr 2019 08:18:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BB6B6B0010; Thu, 11 Apr 2019 08:18:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6845D6B000D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:18:04 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id q82so2639358oif.7
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 05:18:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=lV9v4QI3VRc59CIFPRPm3j1eXyQoUcISpLjsOAIoeHs=;
        b=CF333g5mOeCbR5xt3EoTD04ya6iJ+ziqvm5pthOH8Th+aM1NPVzgBj402v0Aym6uQF
         fg7I5mxKVqlE96Pt/880NbXMn6kJIJYu5PHEswqcqdplFv5LY07PkIeQH9eMReRbzDCc
         LBxydfiWVEeIkkB5jpsPNJ24ZMdCIPKuoOBg5YwuFvCAT22DLFEuE0K/KGL950Iyu+9U
         xxbQ4GC1G2YL2DoR4/qbCQeyk+7+k3hBrpuuLmuTUx927fun+glT1rRmku70YuI6NZVe
         3RK0W/1JJywybmSW8ZwxMYm60hvf5THX7VzafyCLI+TnQHoGx5x+n+c9rSOL2ZqLuj2j
         VKZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUV7j6spd0nvAV/AvX7I9uYVeVulmxcC6RSE4/JKVHgDc7D+64V
	HnoNt1HZZNdTdcSLT8rhsKynfTna6EEgGtcl15nNAE9HXrhIagrQvoMvz1+fkl1F5vUnpIBLHNc
	KwoQzyYO6HyvLwzRTDjPFYyOhQC2U7OF7YlgsQmzXeILgzi3tBCCm251Lz0gpUa4iWw==
X-Received: by 2002:a05:6830:51:: with SMTP id d17mr30470973otp.178.1554985083975;
        Thu, 11 Apr 2019 05:18:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwh97TL/Fjv1aNgbAwxgos7Mi23vsa+5X9Ib04hzfvkY7Uydgxi/75NaeII+NqxLgCJy2w
X-Received: by 2002:a05:6830:51:: with SMTP id d17mr30470905otp.178.1554985082833;
        Thu, 11 Apr 2019 05:18:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554985082; cv=none;
        d=google.com; s=arc-20160816;
        b=UWC61EbByHykKxwy+s9+zI3f5/jFSDU/4hNyecorZQvdbvAjNQ0CKiYnBtmy1xX0ev
         v4WOoUm/qvh7jNEPucYuO4oEDadkmiA9v+InCj0E2cMuRqMKqmRr/0tzHSuBd4n89dRR
         aJ08qk2T+Dvq4ddx7JQZwWmpYfH5BvmUV7iopdoHmftkg0rTcDyL2DMQTHrUb9N6p31o
         aOwp2s6StNIiEF4KW0CnS0Jgyiw6rZfckvpHsFpz78yniCFjWb0RERDk1TtCtSB5Z+za
         vZFpqg9UPQHcE0qsUsIT7cFrRnZiUwoim1cbAmvo4rg7GSvntDu1U+7s+U/VWvN8AyCh
         ellQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=lV9v4QI3VRc59CIFPRPm3j1eXyQoUcISpLjsOAIoeHs=;
        b=MgChxW4n5Rf9iXIpkFRWmax5BzZIOuyFPiYIZh1T+d4L+Xlps5cQK5nb+Jo9gdpMpx
         QRFlHoSHEHTiSLrtUXBPDTitS2ajKBszY9S01kYM07EGGF4+6rey46jqkx+1ee+AjntF
         N9mmNZmZW4Lhzq5uCjYlvNvsIz6OsZwJmP6anRQ1YFyyxc7/5/YUgBI8GLCbLbD/tPM6
         rDbvPbi5kEQyf5AUfqRgZqyAp3hU3DiOaoZG8xSEMog/fojx0sr+Sk0ESECRo8PYofXD
         BZfzLvZ7qjBUNs+58SciVePqqJxrHJ7gyNXv4gwKtRp6FhGfwe8t4eAA/z/9ewotwLO/
         szdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id h23si18098560oic.12.2019.04.11.05.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 05:18:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id B924959CB1E64FCBE285;
	Thu, 11 Apr 2019 20:17:56 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS407-HUB.china.huawei.com
 (10.3.19.207) with Microsoft SMTP Server id 14.3.408.0; Thu, 11 Apr 2019
 20:17:46 +0800
Subject: Re: [PATCH v3 3/4] arm64: kdump: support more than one crash kernel
 regions
To: Mike Rapoport <rppt@linux.ibm.com>
References: <20190409102819.121335-1-chenzhou10@huawei.com>
 <20190409102819.121335-4-chenzhou10@huawei.com>
 <20190410130917.GC17196@rapoport-lnx>
CC: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <137bef2e-8726-fd8f-1cb0-7592074f7870@huawei.com>
Date: Thu, 11 Apr 2019 20:17:43 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <20190410130917.GC17196@rapoport-lnx>
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

This overall looks well.
Replacing memblock_cap_memory_range() with memblock_cap_memory_ranges() was what i wanted
to do in v1, sorry for don't express that clearly.

But there are some issues as below. After fixing this, it can work correctly.

On 2019/4/10 21:09, Mike Rapoport wrote:
> Hi,
> 
> On Tue, Apr 09, 2019 at 06:28:18PM +0800, Chen Zhou wrote:
>> After commit (arm64: kdump: support reserving crashkernel above 4G),
>> there may be two crash kernel regions, one is below 4G, the other is
>> above 4G.
>>
>> Crash dump kernel reads more than one crash kernel regions via a dtb
>> property under node /chosen,
>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
>>
>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>> ---
>>  arch/arm64/mm/init.c     | 66 ++++++++++++++++++++++++++++++++++++++++--------
>>  include/linux/memblock.h |  6 +++++
>>  mm/memblock.c            |  7 ++---
>>  3 files changed, 66 insertions(+), 13 deletions(-)
>>
>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>> index 3bebddf..0f18665 100644
>> --- a/arch/arm64/mm/init.c
>> +++ b/arch/arm64/mm/init.c
>> @@ -65,6 +65,11 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
>>  
>>  #ifdef CONFIG_KEXEC_CORE
>>  
>> +/* at most two crash kernel regions, low_region and high_region */
>> +#define CRASH_MAX_USABLE_RANGES	2
>> +#define LOW_REGION_IDX			0
>> +#define HIGH_REGION_IDX			1
>> +
>>  /*
>>   * reserve_crashkernel() - reserves memory for crash kernel
>>   *
>> @@ -297,8 +302,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>  		const char *uname, int depth, void *data)
>>  {
>>  	struct memblock_region *usablemem = data;
>> -	const __be32 *reg;
>> -	int len;
>> +	const __be32 *reg, *endp;
>> +	int len, nr = 0;
>>  
>>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
>>  		return 0;
>> @@ -307,22 +312,63 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
>>  		return 1;
>>  
>> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
>> +	endp = reg + (len / sizeof(__be32));
>> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
>> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
>> +
>> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
>> +			break;
>> +	}
>>  
>>  	return 1;
>>  }
>>  
>>  static void __init fdt_enforce_memory_region(void)
>>  {
>> -	struct memblock_region reg = {
>> -		.size = 0,
>> -	};
>> +	int i, cnt = 0;
>> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
> 
> I only now noticed that fdt_enforce_memory_region() uses memblock_region to
> pass the ranges around. If we'd switch to memblock_type instead, the
> implementation of memblock_cap_memory_ranges() would be really
> straightforward. Can you check if the below patch works for you? 
> 
>>From e476d584098e31273af573e1a78e308880c5cf28 Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.ibm.com>
> Date: Wed, 10 Apr 2019 16:02:32 +0300
> Subject: [PATCH] memblock: extend memblock_cap_memory_range to multiple ranges
> 
> The memblock_cap_memory_range() removes all the memory except the range
> passed to it. Extend this function to recieve memblock_type with the
> regions that should be kept. This allows switching to simple iteration over
> memblock arrays with 'for_each_mem_range' to remove the unneeded memory.
> 
> Enable use of this function in arm64 for reservation of multile regions for
> the crash kernel.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/arm64/mm/init.c     | 34 ++++++++++++++++++++++++----------
>  include/linux/memblock.h |  2 +-
>  mm/memblock.c            | 45 ++++++++++++++++++++++-----------------------
>  3 files changed, 47 insertions(+), 34 deletions(-)
> 
>  
> -void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
> +void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
>  {
> -	int start_rgn, end_rgn;
> -	int i, ret;
> -
> -	if (!size)
> -		return;
> -
> -	ret = memblock_isolate_range(&memblock.memory, base, size,
> -						&start_rgn, &end_rgn);
> -	if (ret)
> -		return;
> -
> -	/* remove all the MAP regions */
> -	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
> -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> -			memblock_remove_region(&memblock.memory, i);
> +	phys_addr_t start, end;
> +	u64 i;
>  
> -	for (i = start_rgn - 1; i >= 0; i--)
> -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> -			memblock_remove_region(&memblock.memory, i);
> +	/* truncate memory while skipping NOMAP regions */
> +	for_each_mem_range(i, &memblock.memory, regions_to_keep, NUMA_NO_NODE,
> +			   MEMBLOCK_NONE, &start, &end, NULL)
> +		memblock_remove(start, end);

1. use memblock_remove(start, size) instead of memblock_remove(start, end).

2. There is a another hidden issue. We couldn't mix __next_mem_range()(called by for_each_mem_range) operation
with remove operation because __next_mem_range() records the index of last time. If we do remove between
__next_mem_range(), the index may be mess.

Therefore, we could do remove operation after for_each_mem_range like this, solution A:
 void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
 {
-	phys_addr_t start, end;
-	u64 i;
+	phys_addr_t start[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
+	phys_addr_t end[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
+	u64 i, nr = 0;

 	/* truncate memory while skipping NOMAP regions */
 	for_each_mem_range(i, &memblock.memory, regions_to_keep, NUMA_NO_NODE,
-			   MEMBLOCK_NONE, &start, &end, NULL)
-		memblock_remove(start, end);
+			   MEMBLOCK_NONE, &start[nr], &end[nr], NULL)
+		nr++;
+	for (i = 0; i < nr; i++)
+		memblock_remove(start[i], end[i] - start[i]);

 	/* truncate the reserved regions */
+	nr = 0;
 	for_each_mem_range(i, &memblock.reserved, regions_to_keep, NUMA_NO_NODE,
-			   MEMBLOCK_NONE, &start, &end, NULL)
-		memblock_remove_range(&memblock.reserved, start, end);
+			   MEMBLOCK_NONE, &start[nr], &end[nr], NULL)
+		nr++;
+	for (i = 0; i < nr; i++)
+		memblock_remove_range(&memblock.reserved, start[i],
+				end[i] - start[i]);
 }

But a warning occurs when compiling:
  CALL    scripts/atomic/check-atomics.sh
  CALL    scripts/checksyscalls.sh
  CHK     include/generated/compile.h
  CC      mm/memblock.o
mm/memblock.c: In function ‘memblock_cap_memory_ranges’:
mm/memblock.c:1635:1: warning: the frame size of 36912 bytes is larger than 2048 bytes [-Wframe-larger-than=]
 }

another solution is my implementation in v1, solution B:
+void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
+{
+   int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
+   int i, j, ret, nr = 0;
+   memblock_region *regs = regions_to_keep->regions;
+
+   nr = regions_to_keep -> cnt;
+   if (!nr)
+       return;
+
+   /* remove all the MAP regions */
+   for (i = memblock.memory.cnt - 1; i >= end_rgn[nr - 1]; i--)
+       if (!memblock_is_nomap(&memblock.memory.regions[i]))
+           memblock_remove_region(&memblock.memory, i);
+
+   for (i = nr - 1; i > 0; i--)
+       for (j = start_rgn[i] - 1; j >= end_rgn[i - 1]; j--)
+           if (!memblock_is_nomap(&memblock.memory.regions[j]))
+               memblock_remove_region(&memblock.memory, j);
+
+   for (i = start_rgn[0] - 1; i >= 0; i--)
+       if (!memblock_is_nomap(&memblock.memory.regions[i]))
+           memblock_remove_region(&memblock.memory, i);
+
+   /* truncate the reserved regions */
+   memblock_remove_range(&memblock.reserved, 0, regs[0].base);
+
+   for (i = nr - 1; i > 0; i--)
+       memblock_remove_range(&memblock.reserved,
+               regs[i - 1].base + regs[i - 1].size,
+		regs[i].base - regs[i - 1].base - regs[i - 1].size);
+
+   memblock_remove_range(&memblock.reserved,
+           regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
+}

solution A: 	phys_addr_t start[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
		phys_addr_t end[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
start, end is physical addr

solution B: 	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
start_rgn, end_rgn is rgn index		

Solution B do less remove operations and with no warning comparing to solution A.
I think solution B is better, could you give some suggestions?

>  
>  	/* truncate the reserved regions */
> -	memblock_remove_range(&memblock.reserved, 0, base);
> -	memblock_remove_range(&memblock.reserved,
> -			base + size, PHYS_ADDR_MAX);
> +	for_each_mem_range(i, &memblock.reserved, regions_to_keep, NUMA_NO_NODE,
> +			   MEMBLOCK_NONE, &start, &end, NULL)
> +		memblock_remove_range(&memblock.reserved, start, end);

There are the same issues as above.

>  }
>  
>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>  {
> +	struct memblock_region rgn = {
> +		.base = 0,
> +	};
> +
> +	struct memblock_type region_to_keep = {
> +		.cnt = 1,
> +		.max = 1,
> +		.regions = &rgn,
> +	};
> +
>  	phys_addr_t max_addr;
>  
>  	if (!limit)
> @@ -1646,7 +1644,8 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>  	if (max_addr == PHYS_ADDR_MAX)
>  		return;
>  
> -	memblock_cap_memory_range(0, max_addr);
> +	region_to_keep.regions[0].size = max_addr;
> +	memblock_cap_memory_ranges(&region_to_keep);
>  }
>  
>  static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
> 

Thanks,
Chen Zhou

