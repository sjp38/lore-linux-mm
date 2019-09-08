Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B30FEC4360D
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 21:27:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81D2A21907
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 21:27:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81D2A21907
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C3666B0003; Sun,  8 Sep 2019 17:27:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 074976B0006; Sun,  8 Sep 2019 17:27:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECC0C6B0007; Sun,  8 Sep 2019 17:27:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0021.hostedemail.com [216.40.44.21])
	by kanga.kvack.org (Postfix) with ESMTP id CBDC26B0003
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 17:27:20 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 647E4824CA38
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 21:27:20 +0000 (UTC)
X-FDA: 75913039440.08.field79_58e38e0ca412
X-HE-Tag: field79_58e38e0ca412
X-Filterd-Recvd-Size: 2953
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 21:27:18 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C23C2337;
	Sun,  8 Sep 2019 14:27:16 -0700 (PDT)
Received: from huawei_p9_lite.cambridge.arm.com (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AC4243F67D;
	Sun,  8 Sep 2019 14:27:13 -0700 (PDT)
Date: Sun, 8 Sep 2019 22:27:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: hch@lst.de, wahrenst@gmx.net, marc.zyngier@arm.com, robh+dt@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-riscv@lists.infradead.org, Will Deacon <will@kernel.org>,
	f.fainelli@gmail.com, robin.murphy@arm.com,
	linux-kernel@vger.kernel.org, mbrugger@suse.com,
	linux-rpi-kernel@lists.infradead.org, phill@raspberrypi.org,
	m.szyprowski@samsung.com
Subject: Re: [PATCH v4 3/4] arm64: use both ZONE_DMA and ZONE_DMA32
Message-ID: <20190908212711.GA84759@huawei_p9_lite.cambridge.arm.com>
References: <20190906120617.18836-1-nsaenzjulienne@suse.de>
 <20190906120617.18836-4-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906120617.18836-4-nsaenzjulienne@suse.de>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 02:06:14PM +0200, Nicolas Saenz Julienne wrote:
> @@ -430,7 +454,7 @@ void __init arm64_memblock_init(void)
>  
>  	high_memory = __va(memblock_end_of_DRAM() - 1) + 1;
>  
> -	dma_contiguous_reserve(arm64_dma32_phys_limit);
> +	dma_contiguous_reserve(arm64_dma_phys_limit ? : arm64_dma32_phys_limit);
>  }
>  
>  void __init bootmem_init(void)
> @@ -534,6 +558,7 @@ static void __init free_unused_memmap(void)
>  void __init mem_init(void)
>  {
>  	if (swiotlb_force == SWIOTLB_FORCE ||
> +	    max_pfn > (arm64_dma_phys_limit >> PAGE_SHIFT) ||
>  	    max_pfn > (arm64_dma32_phys_limit >> PAGE_SHIFT))
>  		swiotlb_init(1);

So here we want to initialise the swiotlb only if we need bounce
buffers. Prior to this patch, we assumed that swiotlb is needed if
max_pfn is beyond the reach of 32-bit devices. With ZONE_DMA, we need to
lower this limit to arm64_dma_phys_limit.

If ZONE_DMA is enabled, just comparing max_pfn with arm64_dma_phys_limit
is sufficient since the dma32 one limit always higher. However, if
ZONE_DMA is disabled, arm64_dma_phys_limit is 0, so we may initialise
swiotlb unnecessarily. I guess you need a similar check to the
dma_contiguous_reserve() above.

With that:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Unless there are other objections, I can queue this series for 5.5 in a
few weeks time (too late for 5.4).

-- 
Catalin

