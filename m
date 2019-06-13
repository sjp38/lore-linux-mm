Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA651C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:27:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC380208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:27:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC380208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A7726B026F; Thu, 13 Jun 2019 07:27:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37E536B0270; Thu, 13 Jun 2019 07:27:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 294BD6B0271; Thu, 13 Jun 2019 07:27:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 003086B026F
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:27:28 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id h12so9089238otn.18
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:27:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=CIoS97Bvj3b16+NKYrdaVf7keHm9c0i+XtyufUKZ/Lw=;
        b=YkY1YPJD+dUmaVtuDd2FzrAlV8Sv28fZOHF046Jy/nmwKMGOx8WCLS/DYgEuQQirmL
         ubMl089ZaQLwySlEPhBJ6hKYftoT4khSX3y8x4pfU7wqs35VqS/psfydD0F3zxk19+5D
         kCWsFVHsc7q0U9i1XjANAxhSJrn3lLn6e+I5NV3L9WwvfiJDNpy+wdUAOrm0diW1JHnA
         XxtZvlEL3xhi9ENr3OEQNm/xXphulkWbovRRBcxOAbErVCo8mR2TWrX7SRJftV6EhMFk
         CLE5tajfmn73ikOZrnZwKecOuUEehwx6888C+5kNwXZEFqgHdpZ6Ln3MzEuswefWt1Cs
         zkrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUrfsszEfLJEWgzul8hSOe+YruuqgjByzaREjZJ6H9vAJp6Hzzx
	w+FtZPa2vf9Frkk5YBiUNQp9ise/6Xo558oit6ohoCNIRPkzL8ptelxaceTRmHUnolVnNwsAg1a
	3TFf63JgPSF3wDYXzqXABdVzhWJt00aSTFd+kjRKngG2fnXZRnPfVEhpma1xFsniuIA==
X-Received: by 2002:a05:6830:1249:: with SMTP id s9mr26175693otp.33.1560425247164;
        Thu, 13 Jun 2019 04:27:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIJbxIATLXLg9ZolFXtwE8ti8mUPtS2mMaAqUHVyMByzLuuJcAEqeyOIXaC9SOoXWgp1Hw
X-Received: by 2002:a05:6830:1249:: with SMTP id s9mr26175655otp.33.1560425246441;
        Thu, 13 Jun 2019 04:27:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560425246; cv=none;
        d=google.com; s=arc-20160816;
        b=HqktuW2gkvZVkLVEktYfIfzceZPCtoLCcJZl4zpwUt2IilT8KBvMm39zhniFRyLpm5
         UEzu4W9jm4rRGREtAnIzlM/DLYS15SPymMqrTEJQUQIII7kGqedTdAJ8tR6iiuqTORYt
         kPW++7z887gGlw9jkkY1dLUYa2UQvkxKlGwfl1odH0KGXluaf1U0ETUhO4OzpO+5YdUw
         fUFBsgJ205mxY5oA/XJR0b85kkPXCEz59PFcXu6bfHpGewbKcAIAuDoNRHm5l5lPNQwG
         gmg8RWS5vqYrEpg57HmcXkkdaT+yxSEBEfMhhMcCxT5ASYY2NRNcONnYWy7nU+s6HYut
         ifsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=CIoS97Bvj3b16+NKYrdaVf7keHm9c0i+XtyufUKZ/Lw=;
        b=Glfxcx4yw9YdraydAesml3MtwGCBJlUI3aoNNtp8rqws54iJVltIMbNfkk4r/avKem
         mO9TMRmWhqc7RBuRrouca0LkPYxJERDnEV0jhIoon/VJ+V19JBr2C9vkAYrup0GsuZG7
         F8Xu+wcypZ7NInvKL2T6G+NrfOuUTdGNUxhuMUJj0qkfrB+0HXP9XSQJA8Wskx9Imof1
         i3URs6kqBdrFoJCn0QvbtRvSppFC/7sEl8PhMrC5j24YIbEVidj0+LHnjzerceBJAMSQ
         ybWIT0Qzny8bf05hchs4eWFTdOv7E8gH/7bYTqbhErOl4NyS3jdxrHs8aZLb1K/n1WXj
         HP/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id x65si1361292oia.60.2019.06.13.04.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 04:27:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id DE7C49F1C69DB44C0B5B;
	Thu, 13 Jun 2019 19:27:22 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.439.0; Thu, 13 Jun 2019
 19:27:15 +0800
Subject: Re: [PATCH 2/4] arm64: kdump: support reserving crashkernel above 4G
To: James Morse <james.morse@arm.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <20190507035058.63992-3-chenzhou10@huawei.com>
 <df2b659d-7406-fbfd-597d-be3a3f69abcb@arm.com>
CC: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<rppt@linux.ibm.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<bp@alien8.de>, <ebiederm@xmission.com>, <horms@verge.net.au>,
	<takahiro.akashi@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <kexec@lists.infradead.org>,
	<linux-mm@kvack.org>, <wangkefeng.wang@huawei.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <d15f334c-90cd-7c09-5e54-6501e822e7f1@huawei.com>
Date: Thu, 13 Jun 2019 19:27:13 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <df2b659d-7406-fbfd-597d-be3a3f69abcb@arm.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi James,

On 2019/6/6 0:29, James Morse wrote:
> Hello,
> 
> On 07/05/2019 04:50, Chen Zhou wrote:
>> When crashkernel is reserved above 4G in memory, kernel should
>> reserve some amount of low memory for swiotlb and some DMA buffers.
> 
>> Meanwhile, support crashkernel=X,[high,low] in arm64. When use
>> crashkernel=X parameter, try low memory first and fall back to high
>> memory unless "crashkernel=X,high" is specified.
> 
> What is the 'unless crashkernel=...,high' for? I think it would be simpler to relax the
> ARCH_LOW_ADDRESS_LIMIT if reserve_crashkernel_low() allocated something.
> 
> This way "crashkernel=1G" tries to allocate 1G below 4G, but fails if there isn't enough
> memory. "crashkernel=1G crashkernel=16M,low" allocates 16M below 4G, which is more likely
> to succeed, if it does it can then place the 1G block anywhere.
> 
Yeah, this is much simpler.

> 
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
> 
> With both crashk_low_res and crashk_res, we end up with two entries in /proc/iomem called
> "Crash kernel". Because its sorted by address, and kexec-tools stops searching when it
> find "Crash kernel", you are always going to get the kernel placed in the lower portion.
> 
> I suspect this isn't what you want, can we rename crashk_low_res for arm64 so that
> existing kexec-tools doesn't use it?
>

In my patchset, in addition to the kernel patches, i also modify the kexec-tools.
  arm64: support more than one crash kernel regions(http://lists.infradead.org/pipermail/kexec/2019-April/022792.html).
In kexec-tools patch, we read all the "Crash kernel" entry and load crash kernel high.

> 
>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>> index d2adffb..3fcd739 100644
>> --- a/arch/arm64/mm/init.c
>> +++ b/arch/arm64/mm/init.c
>> @@ -74,20 +74,37 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
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
>> +		ret = parse_crashkernel_high(boot_command_line,
>> +				memblock_phys_mem_size(),
>> +				&crash_size, &crash_base);
>> +		if (ret || !crash_size)
>> +			return;
>> +		high = true;
>> +	}
>>  
>>  	crash_size = PAGE_ALIGN(crash_size);
>>  
>>  	if (crash_base == 0) {
>> -		/* Current arm64 boot protocol requires 2MB alignment */
>> -		crash_base = memblock_find_in_range(0, ARCH_LOW_ADDRESS_LIMIT,
>> -				crash_size, SZ_2M);
>> +		/*
>> +		 * Try low memory first and fall back to high memory
>> +		 * unless "crashkernel=size[KMG],high" is specified.
>> +		 */
>> +		if (!high)
>> +			crash_base = memblock_find_in_range(0,
>> +					ARCH_LOW_ADDRESS_LIMIT,
>> +					crash_size, CRASH_ALIGN);
>> +		if (!crash_base)
>> +			crash_base = memblock_find_in_range(0,
>> +					memblock_end_of_DRAM(),
>> +					crash_size, CRASH_ALIGN);
>>  		if (crash_base == 0) {
>>  			pr_warn("cannot allocate crashkernel (size:0x%llx)\n",
>>  				crash_size);
>> @@ -105,13 +122,18 @@ static void __init reserve_crashkernel(void)
>>  			return;
>>  		}
>>  
>> -		if (!IS_ALIGNED(crash_base, SZ_2M)) {
>> +		if (!IS_ALIGNED(crash_base, CRASH_ALIGN)) {
>>  			pr_warn("cannot reserve crashkernel: base address is not 2MB aligned\n");
>>  			return;
>>  		}
>>  	}
>>  	memblock_reserve(crash_base, crash_size);
>>  
>> +	if (crash_base >= SZ_4G && reserve_crashkernel_low()) {
>> +		memblock_free(crash_base, crash_size);
>> +		return;
> 
> This is going to be annoying on platforms that don't have, and don't need memory below 4G.
> A "crashkernel=...,low" on these system will break crashdump. I don't think we should
> expect users to know the memory layout. (I'm assuming distro's are going to add a low
> reservation everywhere, just in case)
> 
> I think the 'low' region should be a small optional/best-effort extra, that kexec-tools
> can't touch.
> 
> 
> I'm afraid you've missed the ugly bit of the crashkernel reservation...
> 
> arch/arm64/mm/mmu.c::map_mem() marks the crashkernel as 'nomap' during the first pass of
> page-table generation. This means it isn't mapped in the linear map. It then maps it with
> page-size mappings, and removes the nomap flag.
> 
> This is done so that arch_kexec_protect_crashkres() and
> arch_kexec_unprotect_crashkres() can remove the valid bits of the crashkernel mapping.
> This way the old-kernel can't accidentally overwrite the crashkernel. It also saves us if
> the old-kernel and the crashkernel use different memory attributes for the mapping.
> 
> As your low-memory reservation is intended to be used for devices, having it mapped by the
> old-kernel as cacheable memory is going to cause problems if those CPUs aren't taken
> offline and go corrupting this memory. (we did crash for a reason after all)
> 
> 
> I think the simplest thing to do is mark the low region as 'nomap' in
> reserve_crashkernel() and always leave it unmapped. We can then describe it via a
> different string in /proc/iomem, something like "Crash kernel (low)". Older kexec-tools
> shouldn't use it, (I assume its not using strncmp() in a way that would do this by
> accident), and newer kexec-tools can know to describe it in the DT, but it can't write to it.
> 

I did miss the bit of the crashkernel reservation. I will fix this in next version.

> 
> Thanks,
> 
> James
> 
> .
> 

Thanks,
Chen Zhou

