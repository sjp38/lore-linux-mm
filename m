Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C26BC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:07:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 950E3205F4
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:07:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="u2TOk2aU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 950E3205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C0358E0003; Thu,  1 Aug 2019 04:07:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 222D48E0001; Thu,  1 Aug 2019 04:07:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09CD98E0003; Thu,  1 Aug 2019 04:07:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACCC78E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:07:08 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id n13so13531516wmi.4
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:07:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=g+A39RrdNsk5NIAgz6cbkqFXnqluhsaENg8UQpREXDE=;
        b=KOUVMPGhxWt6q9p0nLBQb+Zzt5iK2RZkT15z88fx1cWPLGLkIVlrGgmS8PEIs85X2W
         d/WOys4T0wZc+1QfWPD+Uu3FrYYa26b5PcZwbHrDiJO23KoM/YHXXVuHQxqCLk9MH5ay
         SChRs8vd6kNf9ON3E7C85IV8LrPrmIWePKIN74nNmOjqmZwY1bRmHWirHJ78/lanYeLb
         UybxfNcPghMhazh31AmHdQkNV6N7kKCtfyVZMOVhtGr5j7ic5BeNkZ4XhcjQ4dlB1ACo
         FWE+P8c/osqYDjYoWMfGZ6mFTxqjYYv14d/6taTR5s8kj3e0etpKJPwx6l5oqBY/IAgW
         KIVA==
X-Gm-Message-State: APjAAAUL315d1vY4Bjxj8vWzzj/jGI9+2n3WdNQoxKm0QhOZvepT2NzD
	HKB2qFQN3AAW8s59+j7gGkcF8YkhSE/gw5TA4ZDJhzDjVAmNW91cJgWAGhciiq0IaA54oNlNjsV
	MWsVNVmXSU2xzxKcZh3f91QPy+jYd5nI/u9tWqGZf+IAG5edkycH+Thj5b+DzbbOPKg==
X-Received: by 2002:a1c:305:: with SMTP id 5mr85521311wmd.101.1564646828150;
        Thu, 01 Aug 2019 01:07:08 -0700 (PDT)
X-Received: by 2002:a1c:305:: with SMTP id 5mr85521214wmd.101.1564646827078;
        Thu, 01 Aug 2019 01:07:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564646827; cv=none;
        d=google.com; s=arc-20160816;
        b=RZLrNVHfuvWOmNIhGrvHVSZBij6Md5KIBm7sJZoDGPm0bF0XT3GjpMxOtEjf3wgNTa
         W/tiLs4irlEfbf7vc5GoDK4VNdi7RkKJpPgiWAzuqgsF8tuG7+r5naikCw4xL7tkiCu/
         Tf8ZEEWKRqjwnQ67LaDZNLwGpFWCGyUCPYlWrVZs+1GZFJJzXijUMNekISsC+srnQYcG
         tXOR7IQmHifplU04TbzabFGY03253vL3+MRIjrvIAm7FJb00fF2kNmcHvV9CN01UwKa4
         LAR4xSgbHtGBZE3xrJ0wHwpvMGb1UV664CBmL2dYk7x3IdFVRq8GTaalZHeyFGZJ8pmz
         f7Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=g+A39RrdNsk5NIAgz6cbkqFXnqluhsaENg8UQpREXDE=;
        b=wwIIO+AmgTCXpB+8KKRZpL179cjch8z5jkjIgFhAeTgqlOQcz11wX5qhyzBTkVS/ro
         smtOjNVF30QUKDlq1fqk3u5nIwknFqeXGXmSC8b2gUKGkZ70YPWH3UX3FR/5Sor6tNEh
         W4LUiUO6z1K+52yzjfATsD7X4i0YehHdFL0CEXHeuygQnpnew71F/ewViNWUwPvnU9EH
         IpuZFli3G6upaPiiwRlXrUfxe4/qhxUeO9dT5GIHkbsxikIUy+2hKfmfuy4VqoOLyUls
         1k6+MQlWFCf590Yt+Y6zlY+ffHMpxatV9q0hY5YIJQOLlD76gOdtxdFSWyM5YlSIsL01
         BBxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=u2TOk2aU;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12sor40168797wmf.23.2019.08.01.01.07.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 01:07:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=u2TOk2aU;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=g+A39RrdNsk5NIAgz6cbkqFXnqluhsaENg8UQpREXDE=;
        b=u2TOk2aUUxlciAz+S8fOw5ayEP5pxbanqpxoufcriztE503QaytjsfI44gjK93c4QO
         dVvcNshn6LEorrP7xMHWDjDwSJDHwfu9rr//ENrK//P/JGBiyvFKlS9HN9pxi9vAmshI
         JJMflJqGqOeIo1/OuWDprzizazOtEOuDzwoi5Iq+SB7KdbVeO2nIfjCdSEMb0fJveqYx
         zxREg7xesyR6VqxYmn9zuDDBcdduiRHLhpT6pGZct2AQq9M2eIzI2J7qvBQKw73KbGbk
         BmuBTVInsEUIKbHecZ0fv342yaPj3QrS5dmEkSZzo9vW5XurX1pxsLqpMir0kWwN0vpf
         loYA==
X-Google-Smtp-Source: APXvYqzTOK2O5h5i7JW+1tMKyl/PkCpm0VE489+sVZTr8Okvaw+gBGpGHjDiT6ztuZuItrRRz1jLp8E/08KPJe5mXB4=
X-Received: by 2002:a7b:c0d0:: with SMTP id s16mr99294214wmh.136.1564646826613;
 Thu, 01 Aug 2019 01:07:06 -0700 (PDT)
MIME-Version: 1.0
References: <1563861073-47071-1-git-send-email-guohanjun@huawei.com> <1563861073-47071-2-git-send-email-guohanjun@huawei.com>
In-Reply-To: <1563861073-47071-2-git-send-email-guohanjun@huawei.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 1 Aug 2019 11:06:55 +0300
Message-ID: <CAKv+Gu-YVrCbUfPQQhO+SSrqq4iempwQN481op6uf+q2tD-0=A@mail.gmail.com>
Subject: Re: [PATCH v12 1/2] mm: page_alloc: introduce memblock_next_valid_pfn()
 (again) for arm64
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Jia He <hejianet@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Will Deacon <will@kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jul 2019 at 08:53, Hanjun Guo <guohanjun@huawei.com> wrote:
>
> From: Jia He <hejianet@gmail.com>
>
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But it causes
> possible panic on x86 due to specific memory mapping on x86_64 which will
> skip valid pfns as well, so Daniel Vacek reverted it later.
>
> But as suggested by Daniel Vacek, it is fine to using memblock to skip
> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
>
> Daniel said:
> "On arm and arm64, memblock is used by default. But generic version of
> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
> not always return the next valid one but skips more resulting in some
> valid frames to be skipped (as if they were invalid). And that's why
> kernel was eventually crashing on some !arm machines."
>
> Introduce a new config option CONFIG_HAVE_MEMBLOCK_PFN_VALID and only
> selected for arm64, using the new config option to guard the
> memblock_next_valid_pfn().
>
> This was tested on a HiSilicon Kunpeng920 based ARM64 server, the speedup
> is pretty impressive for bootmem_init() at boot:
>
> with 384G memory,
> before: 13310ms
> after:  1415ms
>
> with 1T memory,
> before: 20s
> after:  2s
>
> Suggested-by: Daniel Vacek <neelx@redhat.com>
> Signed-off-by: Jia He <hejianet@gmail.com>
> Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
> ---
>  arch/arm64/Kconfig     |  1 +
>  include/linux/mmzone.h |  9 +++++++++
>  mm/Kconfig             |  3 +++
>  mm/memblock.c          | 31 +++++++++++++++++++++++++++++++
>  mm/page_alloc.c        |  4 +++-
>  5 files changed, 47 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 697ea0510729..058eb26579be 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -893,6 +893,7 @@ config ARCH_FLATMEM_ENABLE
>
>  config HAVE_ARCH_PFN_VALID
>         def_bool y
> +       select HAVE_MEMBLOCK_PFN_VALID
>
>  config HW_PERF_EVENTS
>         def_bool y
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 70394cabaf4e..24cb6bdb1759 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1325,6 +1325,10 @@ static inline int pfn_present(unsigned long pfn)
>  #endif
>
>  #define early_pfn_valid(pfn)   pfn_valid(pfn)
> +#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
> +extern unsigned long memblock_next_valid_pfn(unsigned long pfn);
> +#define next_valid_pfn(pfn)    memblock_next_valid_pfn(pfn)
> +#endif
>  void sparse_init(void);
>  #else
>  #define sparse_init()  do {} while (0)
> @@ -1347,6 +1351,11 @@ struct mminit_pfnnid_cache {
>  #define early_pfn_valid(pfn)   (1)
>  #endif
>
> +/* fallback to default definitions */
> +#ifndef next_valid_pfn
> +#define next_valid_pfn(pfn)    (pfn + 1)
> +#endif
> +
>  void memory_present(int nid, unsigned long start, unsigned long end);
>
>  /*
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..c578374b6413 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -132,6 +132,9 @@ config HAVE_MEMBLOCK_NODE_MAP
>  config HAVE_MEMBLOCK_PHYS_MAP
>         bool
>
> +config HAVE_MEMBLOCK_PFN_VALID
> +       bool
> +
>  config HAVE_GENERIC_GUP
>         bool
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7d4f61ae666a..d57ba51bb9cd 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1251,6 +1251,37 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>         return 0;
>  }
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> +
> +#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
> +unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
> +{
> +       struct memblock_type *type = &memblock.memory;
> +       unsigned int right = type->cnt;
> +       unsigned int mid, left = 0;
> +       phys_addr_t addr = PFN_PHYS(++pfn);
> +
> +       do {
> +               mid = (right + left) / 2;
> +
> +               if (addr < type->regions[mid].base)
> +                       right = mid;
> +               else if (addr >= (type->regions[mid].base +
> +                                 type->regions[mid].size))
> +                       left = mid + 1;
> +               else {
> +                       /* addr is within the region, so pfn is valid */
> +                       return pfn;
> +               }
> +       } while (left < right);
> +
> +       if (right == type->cnt)
> +               return -1UL;
> +       else
> +               return PHYS_PFN(type->regions[right].base);
> +}
> +EXPORT_SYMBOL(memblock_next_valid_pfn);
> +#endif /* CONFIG_HAVE_MEMBLOCK_PFN_VALID */
> +
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>  /**
>   * __next_mem_pfn_range_in_zone - iterator for for_each_*_range_in_zone()
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..70933c40380a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5811,8 +5811,10 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>                  * function.  They do not exist on hotplugged memory.
>                  */
>                 if (context == MEMMAP_EARLY) {
> -                       if (!early_pfn_valid(pfn))
> +                       if (!early_pfn_valid(pfn)) {
> +                               pfn = next_valid_pfn(pfn) - 1;

This is the thing I objected to previously: subtracting 1 so the pfn++
in the for() produces the correct value.

Could we instead pull the next() operation into the for() construct as
the third argument?

>                                 continue;
> +                       }
>                         if (!early_pfn_in_nid(pfn, nid))
>                                 continue;
>                         if (overlap_memmap_init(zone, &pfn))
> --
> 2.19.1
>

