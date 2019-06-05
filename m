Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01B37C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8D6F206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:30:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8D6F206C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64CCD6B026C; Wed,  5 Jun 2019 12:30:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FCC46B026D; Wed,  5 Jun 2019 12:30:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C49A6B026E; Wed,  5 Jun 2019 12:30:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F075F6B026C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 12:30:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so651477eda.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 09:30:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=guh90kjB0XUjeDLm/cngyCHNYtBtUNJ42bt+oPjPHic=;
        b=s8SskYBd0tbDzujvU9XISU+OjTjYSSchQFA2FtEII8VMxXHQonxau+1MNjjIDg2c0N
         MCpNjZRdRQM4AKMY+wHzWBtDVwug2606x4ZLzGvYhKf4KSgvNFAiasdN1w//NjOriI+I
         dM9v2D8DczBDB2Nl8KKvHXLV6FVn3ML2Nb5eYB7i+eDj40hp2XSDLFXo3Dsgt7Ik1plf
         mdLOrksNC1k1H1kbzy42aB0hfZ9/KXy6oaOWM11+x+zzEvrvwejHUEIiWyd9G0JFGziZ
         S8BU8NVg45MtSDSuLPti9eazsSx8bj4rliBykFq2+YXNtXUM704UEh4rebwRVOQDW0bN
         XvqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: APjAAAWvPoQ/iAGyE/zrko5qeFJOKMeiHVs7yWYEG1cGkiTyhxeXj94L
	oZESOr/5P5ZHDyHtZEENM5uRcKG0iMngJY0IpdCQdfEtvgc2snRaN7bM+j2AiS4uao6SP3q9a3j
	VpkiZBX/cFw6DSBMAXdiq/FjWzZo2NAnKGMzc/21vQVQx8CQ/u3NQm37N5rwE+E72vA==
X-Received: by 2002:a50:94a2:: with SMTP id s31mr3633716eda.290.1559752201528;
        Wed, 05 Jun 2019 09:30:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxk0qTS9C8CdHHVyzA7ceb5r9evF17Ct6GX/KEmmBrDFYzBdMByl0MMvyj31lBE3afeUTuw
X-Received: by 2002:a50:94a2:: with SMTP id s31mr3633639eda.290.1559752200629;
        Wed, 05 Jun 2019 09:30:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559752200; cv=none;
        d=google.com; s=arc-20160816;
        b=mXdvrcljJnafKmPrbzfHCydG316thdyO+Xl8W7YEQXXn43NaPP95HAP8gIzXG21cIk
         2Lb9Wvica87WuX7lR1kHug+N6YH/uYcgG8rH03rUIycktzvBapz0HEigOIhEC1FiOtAK
         NIxpXLgKY7BfqK//eV1uo3odzf4OuDo2laVIZbiNrpLCytaqAo2l8H3K6bIBlKFAGM3/
         TgRtLtiYCmk/UFCVRuYsFc6NoMjC6IPMDn39fb/doQsObdeKB2ZCYJADXMZ68xGrF0WU
         rmhj0SQmWNYXlebiZuew/HSEsKvK0s1cfDwjqBLbmH5/0dFd2ej8z2hU82djqRKXfTcu
         k0pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=guh90kjB0XUjeDLm/cngyCHNYtBtUNJ42bt+oPjPHic=;
        b=OBay/oa5aAjbbUIlP0Mljd+M5nc/sXfSAZ5v9FaxV7nrvgLwjMwE0yPeUf0rGrojkh
         dqqZgOYjHLwbWq1oMUOgpyy8dxDSnc4q7DGS+FJI7a4P5l1nUnXLn0U3BsM0anD5bF3R
         RX3PeO6vzlcKsh1m2dyk+jOt9SPKlJjcNtmWG0PGyyhNgS+snn3LZG/Qc6yhwVaY0xr6
         zNb+2VYfq+lZRkcRUUw9/gYuRzmUJVuFxgyqx/qyAO7msiTU5tIU90j5J28A+2mLLufa
         StfU9AX2P39eDYcoAlKo4TH4P1DCBnknTwnpXUs9EJuGvraruhWaZEsutMVuaKVfaYON
         mxkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h15si3028069edb.397.2019.06.05.09.30.00
        for <linux-mm@kvack.org>;
        Wed, 05 Jun 2019 09:30:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 90C74374;
	Wed,  5 Jun 2019 09:29:59 -0700 (PDT)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A90FC3F5AF;
	Wed,  5 Jun 2019 09:29:56 -0700 (PDT)
Subject: Re: [PATCH 2/4] arm64: kdump: support reserving crashkernel above 4G
To: Chen Zhou <chenzhou10@huawei.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org,
 ard.biesheuvel@linaro.org, rppt@linux.ibm.com, tglx@linutronix.de,
 mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com, horms@verge.net.au,
 takahiro.akashi@linaro.org, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org,
 wangkefeng.wang@huawei.com
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <20190507035058.63992-3-chenzhou10@huawei.com>
From: James Morse <james.morse@arm.com>
Message-ID: <df2b659d-7406-fbfd-597d-be3a3f69abcb@arm.com>
Date: Wed, 5 Jun 2019 17:29:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190507035058.63992-3-chenzhou10@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On 07/05/2019 04:50, Chen Zhou wrote:
> When crashkernel is reserved above 4G in memory, kernel should
> reserve some amount of low memory for swiotlb and some DMA buffers.

> Meanwhile, support crashkernel=X,[high,low] in arm64. When use
> crashkernel=X parameter, try low memory first and fall back to high
> memory unless "crashkernel=X,high" is specified.

What is the 'unless crashkernel=...,high' for? I think it would be simpler to relax the
ARCH_LOW_ADDRESS_LIMIT if reserve_crashkernel_low() allocated something.

This way "crashkernel=1G" tries to allocate 1G below 4G, but fails if there isn't enough
memory. "crashkernel=1G crashkernel=16M,low" allocates 16M below 4G, which is more likely
to succeed, if it does it can then place the 1G block anywhere.


> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> index 413d566..82cd9a0 100644
> --- a/arch/arm64/kernel/setup.c
> +++ b/arch/arm64/kernel/setup.c
> @@ -243,6 +243,9 @@ static void __init request_standard_resources(void)
>  			request_resource(res, &kernel_data);
>  #ifdef CONFIG_KEXEC_CORE
>  		/* Userspace will find "Crash kernel" region in /proc/iomem. */
> +		if (crashk_low_res.end && crashk_low_res.start >= res->start &&
> +		    crashk_low_res.end <= res->end)
> +			request_resource(res, &crashk_low_res);
>  		if (crashk_res.end && crashk_res.start >= res->start &&
>  		    crashk_res.end <= res->end)
>  			request_resource(res, &crashk_res);

With both crashk_low_res and crashk_res, we end up with two entries in /proc/iomem called
"Crash kernel". Because its sorted by address, and kexec-tools stops searching when it
find "Crash kernel", you are always going to get the kernel placed in the lower portion.

I suspect this isn't what you want, can we rename crashk_low_res for arm64 so that
existing kexec-tools doesn't use it?


> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index d2adffb..3fcd739 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -74,20 +74,37 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
>  static void __init reserve_crashkernel(void)
>  {
>  	unsigned long long crash_base, crash_size;
> +	bool high = false;
>  	int ret;
>  
>  	ret = parse_crashkernel(boot_command_line, memblock_phys_mem_size(),
>  				&crash_size, &crash_base);
>  	/* no crashkernel= or invalid value specified */
> -	if (ret || !crash_size)
> -		return;
> +	if (ret || !crash_size) {
> +		/* crashkernel=X,high */
> +		ret = parse_crashkernel_high(boot_command_line,
> +				memblock_phys_mem_size(),
> +				&crash_size, &crash_base);
> +		if (ret || !crash_size)
> +			return;
> +		high = true;
> +	}
>  
>  	crash_size = PAGE_ALIGN(crash_size);
>  
>  	if (crash_base == 0) {
> -		/* Current arm64 boot protocol requires 2MB alignment */
> -		crash_base = memblock_find_in_range(0, ARCH_LOW_ADDRESS_LIMIT,
> -				crash_size, SZ_2M);
> +		/*
> +		 * Try low memory first and fall back to high memory
> +		 * unless "crashkernel=size[KMG],high" is specified.
> +		 */
> +		if (!high)
> +			crash_base = memblock_find_in_range(0,
> +					ARCH_LOW_ADDRESS_LIMIT,
> +					crash_size, CRASH_ALIGN);
> +		if (!crash_base)
> +			crash_base = memblock_find_in_range(0,
> +					memblock_end_of_DRAM(),
> +					crash_size, CRASH_ALIGN);
>  		if (crash_base == 0) {
>  			pr_warn("cannot allocate crashkernel (size:0x%llx)\n",
>  				crash_size);
> @@ -105,13 +122,18 @@ static void __init reserve_crashkernel(void)
>  			return;
>  		}
>  
> -		if (!IS_ALIGNED(crash_base, SZ_2M)) {
> +		if (!IS_ALIGNED(crash_base, CRASH_ALIGN)) {
>  			pr_warn("cannot reserve crashkernel: base address is not 2MB aligned\n");
>  			return;
>  		}
>  	}
>  	memblock_reserve(crash_base, crash_size);
>  
> +	if (crash_base >= SZ_4G && reserve_crashkernel_low()) {
> +		memblock_free(crash_base, crash_size);
> +		return;

This is going to be annoying on platforms that don't have, and don't need memory below 4G.
A "crashkernel=...,low" on these system will break crashdump. I don't think we should
expect users to know the memory layout. (I'm assuming distro's are going to add a low
reservation everywhere, just in case)

I think the 'low' region should be a small optional/best-effort extra, that kexec-tools
can't touch.


I'm afraid you've missed the ugly bit of the crashkernel reservation...

arch/arm64/mm/mmu.c::map_mem() marks the crashkernel as 'nomap' during the first pass of
page-table generation. This means it isn't mapped in the linear map. It then maps it with
page-size mappings, and removes the nomap flag.

This is done so that arch_kexec_protect_crashkres() and
arch_kexec_unprotect_crashkres() can remove the valid bits of the crashkernel mapping.
This way the old-kernel can't accidentally overwrite the crashkernel. It also saves us if
the old-kernel and the crashkernel use different memory attributes for the mapping.

As your low-memory reservation is intended to be used for devices, having it mapped by the
old-kernel as cacheable memory is going to cause problems if those CPUs aren't taken
offline and go corrupting this memory. (we did crash for a reason after all)


I think the simplest thing to do is mark the low region as 'nomap' in
reserve_crashkernel() and always leave it unmapped. We can then describe it via a
different string in /proc/iomem, something like "Crash kernel (low)". Older kexec-tools
shouldn't use it, (I assume its not using strncmp() in a way that would do this by
accident), and newer kexec-tools can know to describe it in the DT, but it can't write to it.


Thanks,

James

