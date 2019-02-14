Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50C97C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:48:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B74B218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:48:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B74B218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A91468E0002; Thu, 14 Feb 2019 10:48:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A16648E0001; Thu, 14 Feb 2019 10:48:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B7FE8E0002; Thu, 14 Feb 2019 10:48:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECA38E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:48:04 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so2611980edt.23
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:48:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=2G5EnVokUcunJUSB9C/94aSf+MUUP6QJ9XGvC+J4emI=;
        b=BTjgadRZTONFrimOJEIJ2QDbO2IbV3DZ4wwd3VsI4L2GJygEHY3sRyBqOp/VPhBPni
         hnAbMIMP21MoMGp/gF4AyJjPG+O9mqiKImIXkID7tg9mRS1+gHmtsQMpPym2LKJL3jTf
         yqgRPTrjQu53dE3CYOoTVBKG/sin2IUzjRWTeQDDKyGfp/1CIDM559A95naJK7Z58fMM
         7NSP0pRtZAEfDKcKrMLWcUhNOmc71qzBosRa1X3ocHmMuESRcNNRXGyZneaNfp8fnHGc
         5jyWW56wbEkU8K+jEJ5bdnOKZIdRdkO8BjdyscVdjOYFrAupw/iwQ5YYOi77DGymGTXq
         +nmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of marc.zyngier@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=marc.zyngier@arm.com
X-Gm-Message-State: AHQUAubM8PCrxBPXm7isjHJwpXbTOqMNN/Zf7fxZX5XL1LRAhtyDZ7jD
	uwDZpuUZA1vtrPE9fRidlYlmejhUW1cy28xqj+5vRNXpAmg+QV0NZp84MYVhBaPmqgKylF3KhLe
	uoRHfU4W7UU2IxCmMsYxLrZEJ6eUEOUqkISfkHo453p48hQaRj0+ppGJMDrRSObBKUA==
X-Received: by 2002:a50:bdc8:: with SMTP id z8mr3676951edh.46.1550159283722;
        Thu, 14 Feb 2019 07:48:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZqExatMUgcgZX0v2e1A0qP1ZQx/l+iGW+2gROI2Z22P1nkYjk0Za3yXgjxLiDJMy+h1UAp
X-Received: by 2002:a50:bdc8:: with SMTP id z8mr3676879edh.46.1550159282402;
        Thu, 14 Feb 2019 07:48:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550159282; cv=none;
        d=google.com; s=arc-20160816;
        b=xTJU9LYBkBqTb8HcEsEpVgdv/ET3bfjls3bcxgL+z921n7daBf5QB84vBfRZWJ5oIT
         gOFSFRuru3MhVnLJmj8gBBT2ISb2+fdkMXQcwbi2Dd4hKUWewXrNQXPzTE8pTyv9Esc3
         BPShHu9vp9qOYUGfOkoYpfOKf7ICEOx20L0DoigR//yL19LCDszQrhBs3Dn1MY/s9PWr
         54lynkMYHog+wZK8JQs7b9Cg44KjJLct1AEi1BBuEkqX4kYazh77yKhOTESnaJfuOf0w
         6kcEfhuwefw7P8Owrc6NE2sNI2qQQN301nrBfcUNQmNVEzfEykfQ/HFZnvfYptypPuIH
         xSSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=2G5EnVokUcunJUSB9C/94aSf+MUUP6QJ9XGvC+J4emI=;
        b=Li7gCnVTHQipQmGywzoXjRsrCj4A+n56cSFXRcyYzQr93DxnW/IB9JL9RxCF5Ws1eK
         wp01KN3XooXsJXR8SepAfPqhz/+wVQmGQI21tlq5ieoVelFMgo3ffNpdsgaspJ5q8lHm
         /ERFDwu86AJeSxnxuEJiUwdoF9ipdOUXbmwkUKNjQUtLn2r3d2vNM6MfSwBJncWprhV0
         vzGVff7bqPMactrm5YcJZPhw5FkHtZVBZ+o1jC0gg8Lvbi5U20VtUi6AOeyjP/FgJpsC
         vXrStMDXlWNeeX/ItU8UmnahzCMaNN8kDdnlPnEhsyjdnr6nqW3IUzsc8Pe8tZ5up7xb
         sbBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of marc.zyngier@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=marc.zyngier@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a37si1301747edd.321.2019.02.14.07.48.01
        for <linux-mm@kvack.org>;
        Thu, 14 Feb 2019 07:48:02 -0800 (PST)
Received-SPF: pass (google.com: domain of marc.zyngier@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of marc.zyngier@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=marc.zyngier@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 14010EBD;
	Thu, 14 Feb 2019 07:48:01 -0800 (PST)
Received: from [10.1.196.62] (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AD0BA3F575;
	Thu, 14 Feb 2019 07:47:59 -0800 (PST)
Subject: Re: [PATCH 1/2] arm64: account for GICv3 LPI tables in static
 memblock reserve table
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-efi@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
 James Morse <james.morse@arm.com>, linux-mm@kvack.org
References: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
 <20190213132738.10294-2-ard.biesheuvel@linaro.org>
From: Marc Zyngier <marc.zyngier@arm.com>
Openpgp: preference=signencrypt
Autocrypt: addr=marc.zyngier@arm.com; prefer-encrypt=mutual; keydata=
 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
Organization: ARM Ltd
Message-ID: <325ae70b-6520-a186-c65f-8ab29a5be3a5@arm.com>
Date: Thu, 14 Feb 2019 15:47:58 +0000
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190213132738.10294-2-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ard,

On 13/02/2019 13:27, Ard Biesheuvel wrote:
> In the irqchip and EFI code, we have what basically amounts to a quirk
> to work around a peculiarity in the GICv3 architecture, which permits
> the system memory address of LPI tables to be programmable only once
> after a CPU reset. This means kexec kernels must use the same memory
> as the first kernel, and thus ensure that this memory has not been
> given out for other purposes by the time the ITS init code runs, which
> is not very early for secondary CPUs.
> 
> On systems with many CPUs, these reservations could overflow the
> memblock reservation table, and this was addressed in commit
> eff896288872 ("efi/arm: Defer persistent reservations until after
> paging_init()"). However, this turns out to have made things worse,
> since the allocation of page tables and heap space for the resized
> memblock reservation table itself may overwrite the regions we are
> attempting to reserve, which may cause all kinds of corruption,
> also considering that the ITS will still be poking bits into that
> memory in response to incoming MSIs.
> 
> So instead, let's grow the static memblock reservation table on such
> systems so it can accommodate these reservations at an earlier time.
> This will permit us to revert the above commit in a subsequent patch.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  arch/arm64/include/asm/memory.h | 11 +++++++++++
>  include/linux/memblock.h        |  3 ---
>  mm/memblock.c                   | 10 ++++++++--
>  3 files changed, 19 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
> index e1ec947e7c0c..7e2b13cdd970 100644
> --- a/arch/arm64/include/asm/memory.h
> +++ b/arch/arm64/include/asm/memory.h
> @@ -332,6 +332,17 @@ static inline void *phys_to_virt(phys_addr_t x)
>  #define virt_addr_valid(kaddr)		\
>  	(_virt_addr_is_linear(kaddr) && _virt_addr_valid(kaddr))
>  
> +/*
> + * Given that the GIC architecture permits ITS implementations that can only be
> + * configured with a LPI table address once, GICv3 systems with many CPUs may
> + * end up reserving a lot of different regions after a kexec for their LPI
> + * tables, as we are forced to reuse the same memory after kexec (and thus
> + * reserve it persistently with EFI beforehand)
> + */
> +#if defined(CONFIG_EFI) && defined(CONFIG_ARM_GIC_V3_ITS)
> +#define INIT_MEMBLOCK_RESERVED_REGIONS	(INIT_MEMBLOCK_REGIONS + 2 * NR_CPUS)

Since GICv3 has 1 pending table per CPU, plus one global property table,
can we make this 2 * NR_CPUS + 1? Or is that enough already?

> +#endif
> +
>  #include <asm-generic/memory_model.h>
>  
>  #endif
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 64c41cf45590..859b55b66db2 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -29,9 +29,6 @@ extern unsigned long max_pfn;
>   */
>  extern unsigned long long max_possible_pfn;
>  
> -#define INIT_MEMBLOCK_REGIONS	128
> -#define INIT_PHYSMEM_REGIONS	4
> -
>  /**
>   * enum memblock_flags - definition of memory region attributes
>   * @MEMBLOCK_NONE: no special request
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 022d4cbb3618..a526c3ab8390 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -26,6 +26,12 @@
>  
>  #include "internal.h"
>  
> +#define INIT_MEMBLOCK_REGIONS		128
> +#define INIT_PHYSMEM_REGIONS		4
> +#ifndef INIT_MEMBLOCK_RESERVED_REGIONS
> +#define INIT_MEMBLOCK_RESERVED_REGIONS	INIT_MEMBLOCK_REGIONS
> +#endif
> +
>  /**
>   * DOC: memblock overview
>   *
> @@ -92,7 +98,7 @@ unsigned long max_pfn;
>  unsigned long long max_possible_pfn;
>  
>  static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
> -static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
> +static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_RESERVED_REGIONS] __initdata_memblock;
>  #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
>  static struct memblock_region memblock_physmem_init_regions[INIT_PHYSMEM_REGIONS] __initdata_memblock;
>  #endif
> @@ -105,7 +111,7 @@ struct memblock memblock __initdata_memblock = {
>  
>  	.reserved.regions	= memblock_reserved_init_regions,
>  	.reserved.cnt		= 1,	/* empty dummy entry */
> -	.reserved.max		= INIT_MEMBLOCK_REGIONS,
> +	.reserved.max		= INIT_MEMBLOCK_RESERVED_REGIONS,
>  	.reserved.name		= "reserved",
>  
>  #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> 

Otherwise:

Acked-by: Marc Zyngier <marc.zyngier@arm.com>

	M.
-- 
Jazz is not dead. It just smells funny...

