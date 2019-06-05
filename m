Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4312C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:29:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA287206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:29:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA287206C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33FF06B026A; Wed,  5 Jun 2019 12:29:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F1DF6B026B; Wed,  5 Jun 2019 12:29:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B8ED6B026C; Wed,  5 Jun 2019 12:29:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFCF66B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 12:29:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k15so6509147eda.6
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 09:29:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KWiykMrJ0Wehpl9rCCmYj+0S3O6qYbz3gWC70Yyu9FI=;
        b=AHb5FhMcXqPhogI1O1Olz25aWR92zxL7a90jG6n5ydxW7dYjVBd+58iXVUBQ26MITu
         IfAwK/uEYm0X3y11kozD8hMeweZG9OLc4pwQUhZkYVYCdQTUOUYynftaTUveBmfSGuii
         eSjhfarbxm9kJrGgxqpXdaSFAMma79PWLJi75NZdp1WaVVlxuIQeynOsYoKh9/eWk2jO
         Z6AWj6WiJ8s4ScVjQaW0ROKfIA7BkgO7NgQLS6oyvXLcbSLqeO8yo7/YL68/WF9KsZ38
         TZkkk/hYfQHuSntYHUaHOZLtwbSr0Dejnu4ezZ8gf1x0i9D843PtOG6kQPPABUfQacq7
         lzqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: APjAAAVuiwl7cPTmzmgPyLimlqvtvhYBPsvWFWkesbxVAB65ztuY9Jrz
	lawvLlPUsYJe+4u1wb/CMNqLqHeulgRGLQnR/Y45DMWXukjCZHciGBQgHCNCMMdUJcV9duUYMXr
	GR5wSQpYQGvC7QbREe606NfXmnkbzXFnMZmEUZb2kFd6XBq6CV36sqOdjijL0GBDewg==
X-Received: by 2002:a17:906:2650:: with SMTP id i16mr9678464ejc.40.1559752168321;
        Wed, 05 Jun 2019 09:29:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKKOzIKXEUWn9YrDGWddv6FJmnmYBQdW6SIMjuZpUJlNniQPPzVJxOyYVHdFbty2dyjRhE
X-Received: by 2002:a17:906:2650:: with SMTP id i16mr9678387ejc.40.1559752167305;
        Wed, 05 Jun 2019 09:29:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559752167; cv=none;
        d=google.com; s=arc-20160816;
        b=bvw6B9LaxjltSSeQiaEEBpJuUsvrfEHv6ZZP88w0GuMhMg1rfO+GE5giFFJYpFO6Ga
         InRUkq+QkXXzOGlSA4Y15gywISeHQWJHPxWG9gPx0bbxBOk3O0n/aHLlUBDLzxmz6/SI
         WiaIW+4HoMz9hhWUA066UePxAw4H8QjcbkG1mB5NZlW0txzU5UypLKELzH9NSp5XpQUr
         LT0k7Lsgsu16OodBrwSEIwyc1kXT4byhNFPUrHPwdrrjp4cUfYoxTBsvsBwO5CrGDcOy
         jXD5grPtkFHIRTVeAqfNJG2hAgnKYvpWK/o0vpTW9oJhmy/2KghhIXDSpLT9gZDGPTiy
         7SPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=KWiykMrJ0Wehpl9rCCmYj+0S3O6qYbz3gWC70Yyu9FI=;
        b=I61X25ApFjY70p/fZKS9iSa1UVEC/5cYoQ09LgVME+lvW6xFDQRgzBpZNnjSRAtrx8
         CoDsQW1Y7OWiNoRHIpfFLfDjc0yEhbXlqPWOcwFlkpcFuBsV5GPrlFqBUCnRVCU1ZXL9
         /5Idp/toWxZYCNV36/yGRE9T0GjC9lBA3S7xWvk09qFACwnO4MkTkyTUWTscWgY1wJdh
         LzREOhtnHvEMh7kWB9t/+pKGga843uaZ1Rf49LcwNuFo28StKdq7iqn/akDvEq09I4bt
         E4wl8qF8/WnGqtIcrJSobKxnixfuEqv863GkJNj5rgQZY/vmqOIMEIVdAofU4p5qQ4Bq
         Y9BA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f3si7268013ejb.138.2019.06.05.09.29.26
        for <linux-mm@kvack.org>;
        Wed, 05 Jun 2019 09:29:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1DFE2374;
	Wed,  5 Jun 2019 09:29:26 -0700 (PDT)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0FBED3F5AF;
	Wed,  5 Jun 2019 09:29:22 -0700 (PDT)
Subject: Re: [PATCH 1/4] x86: kdump: move reserve_crashkernel_low() into
 kexec_core.c
To: Chen Zhou <chenzhou10@huawei.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org,
 ard.biesheuvel@linaro.org, rppt@linux.ibm.com, tglx@linutronix.de,
 mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com, horms@verge.net.au,
 takahiro.akashi@linaro.org, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org,
 wangkefeng.wang@huawei.com
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <20190507035058.63992-2-chenzhou10@huawei.com>
From: James Morse <james.morse@arm.com>
Message-ID: <6585f047-063c-6d6c-4967-1d8a472f30f4@arm.com>
Date: Wed, 5 Jun 2019 17:29:21 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190507035058.63992-2-chenzhou10@huawei.com>
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
> In preparation for supporting reserving crashkernel above 4G
> in arm64 as x86_64 does, move reserve_crashkernel_low() into
> kexec/kexec_core.c.


> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index 905dae8..9ee33b6 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -463,59 +460,6 @@ static void __init memblock_x86_reserve_range_setup_data(void)
>  # define CRASH_ADDR_HIGH_MAX	MAXMEM
>  #endif
>  
> -static int __init reserve_crashkernel_low(void)
> -{
> -#ifdef CONFIG_X86_64

The behaviour of this #ifdef has disappeared, won't 32bit x86 now try and reserve a chunk
of unnecessary 'low' memory?

[...]


> @@ -579,9 +523,13 @@ static void __init reserve_crashkernel(void)
>  		return;
>  	}
>  
> -	if (crash_base >= (1ULL << 32) && reserve_crashkernel_low()) {
> -		memblock_free(crash_base, crash_size);
> -		return;
> +	if (crash_base >= (1ULL << 32)) {
> +		if (reserve_crashkernel_low()) {
> +			memblock_free(crash_base, crash_size);
> +			return;
> +		}
> +
> +		insert_resource(&iomem_resource, &crashk_low_res);


Previously reserve_crashkernel_low() was #ifdefed to do nothing if !CONFIG_X86_64, I don't
see how 32bit is skipping this reservation...


>  	}
>  
>  	pr_info("Reserving %ldMB of memory at %ldMB for crashkernel (System RAM: %ldMB)\n",
> diff --git a/include/linux/kexec.h b/include/linux/kexec.h
> index b9b1bc5..096ad63 100644
> --- a/include/linux/kexec.h
> +++ b/include/linux/kexec.h
> @@ -63,6 +63,10 @@
>  
>  #define KEXEC_CORE_NOTE_NAME	CRASH_CORE_NOTE_NAME
>  
> +#ifndef CRASH_ALIGN
> +#define CRASH_ALIGN SZ_128M
> +#endif

Why 128M? Wouldn't we rather each architecture tells us its minimum alignment?


> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index d714044..3492abd 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -39,6 +39,8 @@
>  #include <linux/compiler.h>
>  #include <linux/hugetlb.h>
>  #include <linux/frame.h>
> +#include <linux/memblock.h>
> +#include <linux/swiotlb.h>
>  
>  #include <asm/page.h>
>  #include <asm/sections.h>
> @@ -96,6 +98,60 @@ int kexec_crash_loaded(void)
>  }
>  EXPORT_SYMBOL_GPL(kexec_crash_loaded);
>  
> +int __init reserve_crashkernel_low(void)
> +{
> +	unsigned long long base, low_base = 0, low_size = 0;
> +	unsigned long total_low_mem;
> +	int ret;
> +
> +	total_low_mem = memblock_mem_size(1UL << (32 - PAGE_SHIFT));
> +
> +	/* crashkernel=Y,low */
> +	ret = parse_crashkernel_low(boot_command_line, total_low_mem,
> +			&low_size, &base);
> +	if (ret) {
> +		/*
> +		 * two parts from lib/swiotlb.c:
> +		 * -swiotlb size: user-specified with swiotlb= or default.
> +		 *
> +		 * -swiotlb overflow buffer: now hardcoded to 32k. We round it
> +		 * to 8M for other buffers that may need to stay low too. Also
> +		 * make sure we allocate enough extra low memory so that we
> +		 * don't run out of DMA buffers for 32-bit devices.
> +		 */
> +		low_size = max(swiotlb_size_or_default() + (8UL << 20),

SZ_8M?

> +				256UL << 20);

SZ_256M?


> +	} else {
> +		/* passed with crashkernel=0,low ? */
> +		if (!low_size)
> +			return 0;
> +	}
> +
> +	low_base = memblock_find_in_range(0, 1ULL << 32, low_size, CRASH_ALIGN);
> +	if (!low_base) {
> +		pr_err("Cannot reserve %ldMB crashkernel low memory, please try smaller size.\n",
> +		       (unsigned long)(low_size >> 20));
> +		return -ENOMEM;
> +	}
> +
> +	ret = memblock_reserve(low_base, low_size);
> +	if (ret) {
> +		pr_err("%s: Error reserving crashkernel low memblock.\n",
> +				__func__);
> +		return ret;
> +	}
> +
> +	pr_info("Reserving %ldMB of low memory at %ldMB for crashkernel (System low RAM: %ldMB)\n",
> +		(unsigned long)(low_size >> 20),
> +		(unsigned long)(low_base >> 20),
> +		(unsigned long)(total_low_mem >> 20));
> +
> +	crashk_low_res.start = low_base;
> +	crashk_low_res.end   = low_base + low_size - 1;
> +
> +	return 0;
> +}


Thanks,

James

