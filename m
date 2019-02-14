Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6434C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:34:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F43A2229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:34:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F43A2229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 064F28E0004; Thu, 14 Feb 2019 03:34:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 017C68E0001; Thu, 14 Feb 2019 03:34:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E47188E0004; Thu, 14 Feb 2019 03:34:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B97008E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:34:01 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id s4so4870836qts.11
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 00:34:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=BYMRcSajFWY/UADzBTKF1znM4yN0s3y4BVgjt5uUhJw=;
        b=lslHJqZGHc8NaRvpO8lcH2UdHpd/3+/nOXn1WxIWgeehDyTh42kJJ/FDLUqzZeiYOj
         Gbw75E4cR858thkxc588Gx+JzbGyQ2qNu9W0ZZUx+kTUogYK9gtZvSH0Zb3iKzwiN8q8
         FN4LcP/bFPwGaAlCRE4bMCGW0N0olwe339KV1NyV1sKBjEI+XoLZ3FLeTArArOtgMiOu
         iktaZugK3+eLO9A55/RWp56RpUFT7wmMDhW7R5mBVif53Syo+7vT4v5FoBaQH+dQScIz
         Xgi0kwiZ9U3gZCnJMeEqwJhuODKCFaiUHZm8/zQ6ZjYDDfhkY8zOii846ZckxvnScy/e
         /Uwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubggJ3cTeOMwqPoUbGcC5FI3LueZqCj8uwDjQplqb7iaCDqndwl
	B3iJkgFRcFdZchDoJn8/ytHfU6nPxPz2kQoejviceO3/wYrRCHk3Lk4Mn0DFtn9W24bTXVXrWRB
	5PxIwTog6qp2ki3BNpT2phlN23pLD7ug/li5th033BcsrF7N2ijXQqUusOwbDxFxiIw==
X-Received: by 2002:ac8:1929:: with SMTP id t38mr1965275qtj.249.1550133241461;
        Thu, 14 Feb 2019 00:34:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib2kM/lzUDNyj572lUA3McH7db13bQGeQAOfJn0hLuku8l0Xjlce7E8Ug9GTe3g+sru2Z9d
X-Received: by 2002:ac8:1929:: with SMTP id t38mr1965189qtj.249.1550133240597;
        Thu, 14 Feb 2019 00:34:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550133240; cv=none;
        d=google.com; s=arc-20160816;
        b=b16ABWKcG0eWYJuui0QQyQg82pJSS0f+RP7UGf5ntA3VjjmDIoLGGzpbIeLHBq+P+2
         z7Y/rYlMkVzdLYUVFEUkAb0Ch2/+xvlAiy9xcYFzDAQVzFxmDhGh3C7PrZl8Nl9BX3eL
         uT5k1gFOz48/7gx8lMvcw5OZif19DImMTIt9kpcOncTQcA7WPlaQ5/Zyhkl1ICpzz9Ez
         bYpTOyYDZmuWIUjyRzMAVZ0c1PLQjHaFY2dig4v3YasnyDTfhJ0GZbbu5ZSsf1D7A5A/
         uiFyIXzXJm3WTuYNBK6OZK736GiBSZTlM/wvLRVBIQmu2zFoCgi45azOdQn20M7LyCSU
         JX6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=BYMRcSajFWY/UADzBTKF1znM4yN0s3y4BVgjt5uUhJw=;
        b=MvTGtTieVMpuQkoL+tn2Rt2FEKGFFwvhOPP/Z9xcuns5uIq6NulCuP5SgUQuG8VhAn
         z+hPrnj9PvEx/U0ThSJ4r8vcmuOk20bV03fSOIjxGSHOwTvSqfakfH+XGSdzfRsd2hUg
         6HkdLFVxHGKmFqhCQocGvoFn++GaYUUF+6Lvcd8aSzmGEFajTeX0ASQfXICzCOLOFMow
         5pXwY5exDMqlpzL5duCIvnT+vmCy75FGUaL0j9oallTMln1ihbYLnnB/9z9o+Z3H/M8o
         eshVh2N1Sp+I0+kU0pnuoPrAUcrVCHclYqpKQQmMKkGoT+H39C9XSruGVIcuL/JiACyW
         dUWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f37si1072641qve.169.2019.02.14.00.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 00:34:00 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1E8P8ej172426
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:34:00 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qn26491yy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:33:59 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 08:33:57 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 08:33:54 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1E8XrT9655744
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 08:33:53 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C0743A405B;
	Thu, 14 Feb 2019 08:33:53 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 10414A4054;
	Thu, 14 Feb 2019 08:33:53 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 08:33:52 +0000 (GMT)
Date: Thu, 14 Feb 2019 10:33:51 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-efi@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Marc Zyngier <marc.zyngier@arm.com>, James Morse <james.morse@arm.com>,
        linux-mm@kvack.org
Subject: Re: [PATCH 1/2] arm64: account for GICv3 LPI tables in static
 memblock reserve table
References: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
 <20190213132738.10294-2-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213132738.10294-2-ard.biesheuvel@linaro.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021408-0028-0000-0000-000003486E53
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021408-0029-0000-0000-0000240698F2
Message-Id: <20190214083350.GA9063@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140063
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

I'd suggest

s/INIT_MEMBLOCK_REGIONS/INIT_MEMORY_REGIONS
s/INIT_MEMBLOCK_RESERVED_REGIONS/INIT_RESERVED_REGIONS

Except that,

Acked-by: Mike Rapoport <rppt@linux.ibm.com>

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
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

