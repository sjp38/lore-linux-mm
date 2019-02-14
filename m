Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8AB9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 14:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F7DB222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 14:40:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F7DB222D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3942E8E0002; Thu, 14 Feb 2019 09:40:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 343C18E0001; Thu, 14 Feb 2019 09:40:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 233788E0002; Thu, 14 Feb 2019 09:40:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC21A8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:40:23 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d62so2608177edd.19
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 06:40:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nn6o33u4ymtx2ZyTcoKi8/bKv9lYG9oHzykGBqrVPRQ=;
        b=m+7KkFVMt4AQnpyg6Lp+o460vuPPLMQDjQ9OhoKsvq26wkcsf412oH5Non98ptrgty
         Eh5wret0dG/TPoQ0OCJJDXy7CaHxI+tQLJBhxqeWDFTffVvc6QGQLFtMeIIRTT163IXl
         K+UxUFq8UVe7qByrkBGmWsPXbv9zJOP6VZT6AQ3Q4fqf4GXxHZZSV4HwQvDfMIonAO+n
         YSmbndivPO9+e8blPPBGHoyI7+F0h/+cDoh3Ziu7gnaI22XPGdZqZ+XIqj+1BlruRD4l
         sqqX0ui4vLhCsn10jKYlwuBD6cqauiv5/xcfsDzEzUx4wuHC//WW6gNYOfZ8E6Ipr0mu
         Xr8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAua09HuyyNYjFxrDMdfRJsXX0SGHnzGavCl21imCqSihCEY7Q6DU
	39so1lbACpY/q9xfdnxkdLkESkDlftWTkK8Z2Hn6tjeiKfkO9GGbc96EYnEIjyC0yxPg12kQMTP
	SFcIqRTFaLAqG1G968Mt5bE1M2K8fSQsucBRysJ6txRPUl11vlGEdTA1n9a+V0R9vIA==
X-Received: by 2002:aa7:d798:: with SMTP id s24mr3478804edq.1.1550155223321;
        Thu, 14 Feb 2019 06:40:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ+WYnopDNnVeiYE7ErkI7Cw4RSdTeopk6GovNknZNVOpqOI9i3bhoU2QXwwx8OcBViMvQc
X-Received: by 2002:aa7:d798:: with SMTP id s24mr3478734edq.1.1550155222399;
        Thu, 14 Feb 2019 06:40:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550155222; cv=none;
        d=google.com; s=arc-20160816;
        b=dh6NxnPtnwHFcpFSDZMMTSp51/rI9lwXU2PxDXur6coqAGOch22zMRq99iNnWxoI7m
         35/E6L6gzy/TgDa9eOB4JD1G6vTl7dg4IWmxGpMk5ndTRld8DlUiLkBRWZO17jIyrSpe
         aqchv2B3hC/5BQ8HBLdju8r4ce0vQvPNaVc3EA40kIKJqRpBiqjX1b6L6L1DB1P0VRCX
         wM1z+pgbnJhiMSc1ClFKWspD9PD4a0IES7dNtyU5Ql30AvKcrbDW4ERldZQ82e8fliNi
         1N11saHFOu95ZALZ/2TITVtKLZF9pulsSagsLGZcN0kCjwcuCQ+fkS0JTjH0GYyQRdT6
         Je0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nn6o33u4ymtx2ZyTcoKi8/bKv9lYG9oHzykGBqrVPRQ=;
        b=M9IKvRib4PxGOMwh2m/RitDNPBOMeH1bMYKVbo7QTPDy+wwHvDgN0ckbU5DvFaiS9j
         bC9lDauEriY647AQz1hjre2JQE2FvdzCiILFyxEZxrb7K9C5fvKxTKjDn/m8nQs9jTP6
         sbt4dPvK2D2CWwE8jklPTUDC+7Dwn0qefykbruE7BRdAISxcfmNBQwcU0rnPmeRIJOCl
         zdGXTcpm86oIgGrXvyqMvtNXBeVt3bUbR83N0xSCIEzXM0uscFy/Ka3LSLT19dTzN/oC
         vWZ32Q6/cNhDiYZrxr72QygDQy0rc33l2qmS8SMmFD6ibiXv6eImEgUI4MF5tKXZN0c7
         338A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n1si323890eje.237.2019.02.14.06.40.22
        for <linux-mm@kvack.org>;
        Thu, 14 Feb 2019 06:40:22 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6127580D;
	Thu, 14 Feb 2019 06:40:21 -0800 (PST)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DB92F3F557;
	Thu, 14 Feb 2019 06:40:19 -0800 (PST)
Date: Thu, 14 Feb 2019 14:40:17 +0000
From: Will Deacon <will.deacon@arm.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-efi@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Marc Zyngier <marc.zyngier@arm.com>,
	James Morse <james.morse@arm.com>, linux-mm@kvack.org
Subject: Re: [PATCH 1/2] arm64: account for GICv3 LPI tables in static
 memblock reserve table
Message-ID: <20190214144017.GG31597@fuggles.cambridge.arm.com>
References: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
 <20190213132738.10294-2-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213132738.10294-2-ard.biesheuvel@linaro.org>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 02:27:37PM +0100, Ard Biesheuvel wrote:
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
> +#endif

Assuming this "ought to be enough for anybody", then:

Acked-by: Will Deacon <will.deacon@arm.com>

Will

