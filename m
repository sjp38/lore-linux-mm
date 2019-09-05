Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA34AC00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:19:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B03A520828
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:19:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B03A520828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34F626B0285; Thu,  5 Sep 2019 13:19:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D80A6B0287; Thu,  5 Sep 2019 13:19:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 179196B0288; Thu,  5 Sep 2019 13:19:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id E42996B0285
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:19:45 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 85F65180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:19:45 +0000 (UTC)
X-FDA: 75901529130.05.grass87_8f46afb0dff57
X-HE-Tag: grass87_8f46afb0dff57
X-Filterd-Recvd-Size: 5477
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:19:44 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 52F09337;
	Thu,  5 Sep 2019 10:19:43 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5215C3F718;
	Thu,  5 Sep 2019 10:19:41 -0700 (PDT)
Date: Thu, 5 Sep 2019 18:19:39 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: hch@lst.de, wahrenst@gmx.net, marc.zyngier@arm.com, robh+dt@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-riscv@lists.infradead.org, Will Deacon <will@kernel.org>,
	f.fainelli@gmail.com, robin.murphy@arm.com,
	linux-kernel@vger.kernel.org, mbrugger@suse.com,
	linux-rpi-kernel@lists.infradead.org, phill@raspberrypi.org,
	m.szyprowski@samsung.com
Subject: Re: [PATCH v3 3/4] arm64: use both ZONE_DMA and ZONE_DMA32
Message-ID: <20190905171939.GF31268@arrakis.emea.arm.com>
References: <20190902141043.27210-1-nsaenzjulienne@suse.de>
 <20190902141043.27210-4-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190902141043.27210-4-nsaenzjulienne@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 04:10:41PM +0200, Nicolas Saenz Julienne wrote:
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 8956c22634dd..f02a4945aeac 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -50,6 +50,13 @@
>  s64 memstart_addr __ro_after_init = -1;
>  EXPORT_SYMBOL(memstart_addr);
>  
> +/*
> + * We create both ZONE_DMA and ZONE_DMA32. ZONE_DMA covers the first 1G of
> + * memory as some devices, namely the Raspberry Pi 4, have peripherals with
> + * this limited view of the memory. ZONE_DMA32 will cover the rest of the 32
> + * bit addressable memory area.
> + */
> +phys_addr_t arm64_dma_phys_limit __ro_after_init;
>  phys_addr_t arm64_dma32_phys_limit __ro_after_init;
>  
>  #ifdef CONFIG_KEXEC_CORE
> @@ -164,9 +171,9 @@ static void __init reserve_elfcorehdr(void)
>  }
>  #endif /* CONFIG_CRASH_DUMP */
>  /*
> - * Return the maximum physical address for ZONE_DMA32 (DMA_BIT_MASK(32)). It
> - * currently assumes that for memory starting above 4G, 32-bit devices will
> - * use a DMA offset.
> + * Return the maximum physical address for ZONE_DMA32 (DMA_BIT_MASK(32)) and
> + * ZONE_DMA (DMA_BIT_MASK(30)) respectively. It currently assumes that for
> + * memory starting above 4G, 32-bit devices will use a DMA offset.
>   */
>  static phys_addr_t __init max_zone_dma32_phys(void)
>  {
> @@ -174,12 +181,23 @@ static phys_addr_t __init max_zone_dma32_phys(void)
>  	return min(offset + (1ULL << 32), memblock_end_of_DRAM());
>  }
>  
> +static phys_addr_t __init max_zone_dma_phys(void)
> +{
> +	phys_addr_t offset = memblock_start_of_DRAM() & GENMASK_ULL(63, 32);
> +
> +	return min(offset + (1ULL << ARCH_ZONE_DMA_BITS),
> +		   memblock_end_of_DRAM());
> +}

I think we could squash these two functions into a single one with a
"bits" argument that is either 32 or ARCH_ZONE_DMA_BITS.

> +
>  #ifdef CONFIG_NUMA
>  
>  static void __init zone_sizes_init(unsigned long min, unsigned long max)
>  {
>  	unsigned long max_zone_pfns[MAX_NR_ZONES]  = {0};
>  
> +#ifdef CONFIG_ZONE_DMA
> +	max_zone_pfns[ZONE_DMA] = PFN_DOWN(arm64_dma_phys_limit);
> +#endif
>  #ifdef CONFIG_ZONE_DMA32
>  	max_zone_pfns[ZONE_DMA32] = PFN_DOWN(arm64_dma32_phys_limit);
>  #endif
> @@ -195,13 +213,17 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
>  	struct memblock_region *reg;
>  	unsigned long zone_size[MAX_NR_ZONES], zhole_size[MAX_NR_ZONES];
>  	unsigned long max_dma32 = min;
> +	unsigned long max_dma = min;
>  
>  	memset(zone_size, 0, sizeof(zone_size));
>  
> -	/* 4GB maximum for 32-bit only capable devices */
> +#ifdef CONFIG_ZONE_DMA
> +	max_dma = PFN_DOWN(arm64_dma_phys_limit);
> +	zone_size[ZONE_DMA] = max_dma - min;
> +#endif
>  #ifdef CONFIG_ZONE_DMA32
>  	max_dma32 = PFN_DOWN(arm64_dma32_phys_limit);
> -	zone_size[ZONE_DMA32] = max_dma32 - min;
> +	zone_size[ZONE_DMA32] = max_dma32 - max_dma;
>  #endif
>  	zone_size[ZONE_NORMAL] = max - max_dma32;

Does this still work if we have ZONE_DMA32 disabled but ZONE_DMA
enabled? You could use a max(max_dma32, max_dma) or just update
max_dma32 to max_dma in the CONFIG_ZONE_DMA block.

> @@ -213,11 +235,17 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
>  
>  		if (start >= max)
>  			continue;
> -
> +#ifdef CONFIG_ZONE_DMA
> +		if (start < max_dma) {
> +			unsigned long dma_end = min_not_zero(end, max_dma);
> +			zhole_size[ZONE_DMA] -= dma_end - start;
> +		}
> +#endif
>  #ifdef CONFIG_ZONE_DMA32
>  		if (start < max_dma32) {
> -			unsigned long dma_end = min(end, max_dma32);
> -			zhole_size[ZONE_DMA32] -= dma_end - start;
> +			unsigned long dma32_end = min(end, max_dma32);
> +			unsigned long dma32_start = max(start, max_dma);
> +			zhole_size[ZONE_DMA32] -= dma32_end - dma32_start;
>  		}
>  #endif
>  		if (end > max_dma32) {

Similar comment here.

-- 
Catalin

