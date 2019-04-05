Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8507C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 03:03:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22E62217D4
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 03:03:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22E62217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95E986B000C; Thu,  4 Apr 2019 23:03:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 917976B000D; Thu,  4 Apr 2019 23:03:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FBBD6B000E; Thu,  4 Apr 2019 23:03:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 590316B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 23:03:56 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id 81so1996163vkn.19
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 20:03:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=8n1ufHNp8l7e+vRcjJT0MsQkEFINzxGVulJL7Wf2aKM=;
        b=UAyCHMbmbLdiP1x9kC0qH72k0JqWtrVhHt9OYLLz4m2XrJq14QGE6k3jUIC77C5wCV
         NikMsMTAqeGoLh/DMPp/RXcWdWqB+fww+4m54Z8lWs4rKzs/xqci7cb2vNYwx/ou9C4A
         75+GKWUyJYYS9KmWGsZiObrOcipIKabafGN+PskjfEMjcBcS25iRRbnUaRLJ3EPnJV3n
         rEBC1txhE03ClqQh/NKvw1rCEmIQRDA0zNU541LqYXmM8RL+Yozv8CLdH/xmkFPKYvhZ
         Sy+W2mO2E/aEG1cAnZu/1rU5VPvCKnw2FwfD6dgBQ0mGxUe3feovM7qlPdojTbt1KOzC
         h7rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUnrnbrw+ZmvbKb0gDH5WMYaJqBk76lzHdVxRhoz2vGce0Buxl3
	UxT966+N2TXVwAsZ73HG4p4Of6DOKX4bEdb9cwX/MKA5y+P2Vag4dWJFTiaxLlFEw96H6dflTde
	oSHlMVMHOcUlFItnND1+QWJ4iFTma7/J/UGiU9LkPP5A9I0F9x5k9hF2IOBkUWo6EdA==
X-Received: by 2002:a1f:b4ce:: with SMTP id d197mr6330281vkf.57.1554433435976;
        Thu, 04 Apr 2019 20:03:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBK5lkdMW/XWScFYwoLH5XBesypmPaj1d+ZVbBSAdm9zZAuSCfD5dxMd/W9K6DAEUR2Ffu
X-Received: by 2002:a1f:b4ce:: with SMTP id d197mr6330235vkf.57.1554433435048;
        Thu, 04 Apr 2019 20:03:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554433435; cv=none;
        d=google.com; s=arc-20160816;
        b=WTZVuWywGTfPp6j5YgqHBkK2UGT5syDfWQNntHCJ5rG1A/HAIuLmvTMrv86SS0xhkL
         4ZtTWwGghfR5jBY7wkI/S6VbMvFvj8NgPOKojLFiuVvUK95Bpt9dLhAI28PJf014u1Rq
         5nE2mIWLViLGPjgQLkJ9jFHV7YUcgcujPp8SUywICM8wMuB9Po4dSgtQHod0Vskoa4We
         LEKy/vRWTpp42Cl4DKCJpOEXZpG2ogTQtaOhsUw9Cn3hw/p+bB8WM8PErYy4b1Rbura5
         MWem1Bw5ieuevhMxioPQOvPDvMAahzTRQIwNghwo7+L7bki1HMheuuHU7RN6oqiPOFQd
         twUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=8n1ufHNp8l7e+vRcjJT0MsQkEFINzxGVulJL7Wf2aKM=;
        b=akkEstCYpEG4TUEUwYSHzFIDIpf4UVylF9XHMxpXsbOv4p/r606Gsk3MuduevzR1Gj
         g6bIZKK/zwyL+14iywzw47v4WirADdWvplgjOEl++YgyqM4g+nogKvk7V3S5L3eSVQXJ
         ngTvXdlPvxBn5Kswogz2WdhXbLwEVB5HP1KYd2Crp9XwInEnOQKfZGthApG5mbTn3/UH
         +AylUgEww7leMzOEzBuf8zHGRIcmB5V3gpUg8iy0TjEfDMZ/YSy5dqbNwfFMT4WEOnJA
         suZ2z2wlQxXnTkIqLPpawLJKuQYOdyvH2VlMLvYqoBx0QYs8MX4HEj1g0AnpHr5Ertqy
         /Vvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id l21si6803910vso.72.2019.04.04.20.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 20:03:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 77E4C68E05D71F357661;
	Fri,  5 Apr 2019 11:03:49 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.408.0; Fri, 5 Apr 2019
 11:03:41 +0800
Subject: Re: [PATCH 1/3] arm64: kdump: support reserving crashkernel above 4G
To: Mike Rapoport <rppt@linux.ibm.com>
References: <20190403030546.23718-1-chenzhou10@huawei.com>
 <20190403030546.23718-2-chenzhou10@huawei.com>
 <20190404144618.GB6433@rapoport-lnx>
CC: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<takahiro.akashi@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <kexec@lists.infradead.org>,
	<linux-mm@kvack.org>, <wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <59ef4532-2402-3887-2794-b503827fac5a@huawei.com>
Date: Fri, 5 Apr 2019 11:03:39 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <20190404144618.GB6433@rapoport-lnx>
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

On 2019/4/4 22:46, Mike Rapoport wrote:
> Hi,
> 
> On Wed, Apr 03, 2019 at 11:05:44AM +0800, Chen Zhou wrote:
>> When crashkernel is reserved above 4G in memory, kernel should
>> reserve some amount of low memory for swiotlb and some DMA buffers.
>>
>> Kernel would try to allocate at least 256M below 4G automatically
>> as x86_64 if crashkernel is above 4G. Meanwhile, support
>> crashkernel=X,[high,low] in arm64.
>>
>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>> ---
>>  arch/arm64/kernel/setup.c |  3 ++
>>  arch/arm64/mm/init.c      | 71 +++++++++++++++++++++++++++++++++++++++++++++--
>>  2 files changed, 71 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
>> index 413d566..82cd9a0 100644
>> --- a/arch/arm64/kernel/setup.c
>> +++ b/arch/arm64/kernel/setup.c
>> @@ -243,6 +243,9 @@ static void __init request_standard_resources(void)
>>  			request_resource(res, &kernel_data);
>>  #ifdef CONFIG_KEXEC_CORE
>>  		/* Userspace will find "Crash kernel" region in /proc/iomem. */
>> +		if (crashk_low_res.end && crashk_low_res.start >= res->start &&
>> +		    crashk_low_res.end <= res->end)
>> +			request_resource(res, &crashk_low_res);
>>  		if (crashk_res.end && crashk_res.start >= res->start &&
>>  		    crashk_res.end <= res->end)
>>  			request_resource(res, &crashk_res);
>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>> index 6bc1350..ceb2a25 100644
>> --- a/arch/arm64/mm/init.c
>> +++ b/arch/arm64/mm/init.c
>> @@ -64,6 +64,57 @@ EXPORT_SYMBOL(memstart_addr);
>>  phys_addr_t arm64_dma_phys_limit __ro_after_init;
>>  
>>  #ifdef CONFIG_KEXEC_CORE
>> +static int __init reserve_crashkernel_low(void)
>> +{
>> +	unsigned long long base, low_base = 0, low_size = 0;
>> +	unsigned long total_low_mem;
>> +	int ret;
>> +
>> +	total_low_mem = memblock_mem_size(1UL << (32 - PAGE_SHIFT));
>> +
>> +	/* crashkernel=Y,low */
>> +	ret = parse_crashkernel_low(boot_command_line, total_low_mem, &low_size, &base);
>> +	if (ret) {
>> +		/*
>> +		 * two parts from lib/swiotlb.c:
>> +		 * -swiotlb size: user-specified with swiotlb= or default.
>> +		 *
>> +		 * -swiotlb overflow buffer: now hardcoded to 32k. We round it
>> +		 * to 8M for other buffers that may need to stay low too. Also
>> +		 * make sure we allocate enough extra low memory so that we
>> +		 * don't run out of DMA buffers for 32-bit devices.
>> +		 */
>> +		low_size = max(swiotlb_size_or_default() + (8UL << 20), 256UL << 20);
>> +	} else {
>> +		/* passed with crashkernel=0,low ? */
>> +		if (!low_size)
>> +			return 0;
>> +	}
>> +
>> +	low_base = memblock_find_in_range(0, 1ULL << 32, low_size, SZ_2M);
>> +	if (!low_base) {
>> +		pr_err("Cannot reserve %ldMB crashkernel low memory, please try smaller size.\n",
>> +				(unsigned long)(low_size >> 20));
>> +		return -ENOMEM;
>> +	}
>> +
>> +	ret = memblock_reserve(low_base, low_size);
>> +	if (ret) {
>> +		pr_err("%s: Error reserving crashkernel low memblock.\n", __func__);
>> +		return ret;
>> +	}
>> +
>> +	pr_info("Reserving %ldMB of low memory at %ldMB for crashkernel (System RAM: %ldMB)\n",
>> +			(unsigned long)(low_size >> 20),
>> +			(unsigned long)(low_base >> 20),
>> +			(unsigned long)(total_low_mem >> 20));
>> +
>> +	crashk_low_res.start = low_base;
>> +	crashk_low_res.end   = low_base + low_size - 1;
>> +
>> +	return 0;
>> +}
>> +
>>  /*
>>   * reserve_crashkernel() - reserves memory for crash kernel
>>   *
>> @@ -74,19 +125,28 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
>>  static void __init reserve_crashkernel(void)
>>  {
>>  	unsigned long long crash_base, crash_size;
>> +	bool high = false;
>>  	int ret;
>>  
>>  	ret = parse_crashkernel(boot_command_line, memblock_phys_mem_size(),
>>  				&crash_size, &crash_base);
>>  	/* no crashkernel= or invalid value specified */
>> -	if (ret || !crash_size)
>> -		return;
>> +	if (ret || !crash_size) {
>> +		/* crashkernel=X,high */
>> +		ret = parse_crashkernel_high(boot_command_line, memblock_phys_mem_size(),
>> +				&crash_size, &crash_base);
>> +		if (ret || !crash_size)
>> +			return;
>> +		high = true;
>> +	}
>>  
>>  	crash_size = PAGE_ALIGN(crash_size);
>>  
>>  	if (crash_base == 0) {
>>  		/* Current arm64 boot protocol requires 2MB alignment */
>> -		crash_base = memblock_find_in_range(0, ARCH_LOW_ADDRESS_LIMIT,
>> +		crash_base = memblock_find_in_range(0,
>> +				high ? memblock_end_of_DRAM()
>> +				: ARCH_LOW_ADDRESS_LIMIT,
>>  				crash_size, SZ_2M);
>>  		if (crash_base == 0) {
>>  			pr_warn("cannot allocate crashkernel (size:0x%llx)\n",
>> @@ -112,6 +172,11 @@ static void __init reserve_crashkernel(void)
>>  	}
>>  	memblock_reserve(crash_base, crash_size);
>>  
>> +	if (crash_base >= SZ_4G && reserve_crashkernel_low()) {
>> +		memblock_free(crash_base, crash_size);
>> +		return;
>> +	}
>> +
> 
> This very reminds what x86 does. Any chance some of the code can be reused
> rather than duplicated?

As i said in the comment, i transport reserve_crashkernel_low() from x86_64. There are minor
differences. In arm64, we don't need to do insert_resource(), we do request_resource()
in request_standard_resources() later.

How about doing like this:

move common reserve_crashkernel_low() code into kernel/kexec_core.c.
and do in x86 like this:
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -573,9 +573,12 @@ static void __init reserve_crashkernel(void)
                return;
        }

-       if (crash_base >= (1ULL << 32) && reserve_crashkernel_low()) {
-               memblock_free(crash_base, crash_size);
-               return;
+       if (crash_base >= (1ULL << 32)) {
+               if (reserve_crashkernel_low()) {
+                       memblock_free(crash_base, crash_size);
+                       return;
+               } else
+                       insert_resource(&iomem_resource, &crashk_low_res);
        }

> 
>>  	pr_info("crashkernel reserved: 0x%016llx - 0x%016llx (%lld MB)\n",
>>  		crash_base, crash_base + crash_size, crash_size >> 20);
>>  
>> -- 
>> 2.7.4
>>
> 

