Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3117B6B323F
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 13:35:22 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id w24so690518otk.22
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 10:35:22 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j4si9645860otp.25.2018.11.23.10.35.20
        for <linux-mm@kvack.org>;
        Fri, 23 Nov 2018 10:35:21 -0800 (PST)
Date: Fri, 23 Nov 2018 18:35:16 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V3 4/5] arm64: mm: introduce 52-bit userspace support
Message-ID: <20181123183516.GM3360@arrakis.emea.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-5-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114133920.7134-5-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, jcm@redhat.com, ard.biesheuvel@linaro.org

On Wed, Nov 14, 2018 at 01:39:19PM +0000, Steve Capper wrote:
> diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
> index 2e05bcd944c8..56c3ccabeffe 100644
> --- a/arch/arm64/include/asm/pgalloc.h
> +++ b/arch/arm64/include/asm/pgalloc.h
> @@ -27,7 +27,11 @@
>  #define check_pgt_cache()		do { } while (0)
>  
>  #define PGALLOC_GFP	(GFP_KERNEL | __GFP_ZERO)
> +#ifdef CONFIG_ARM64_52BIT_VA
> +#define PGD_SIZE	((1 << (52 - PGDIR_SHIFT)) * sizeof(pgd_t))
> +#else
>  #define PGD_SIZE	(PTRS_PER_PGD * sizeof(pgd_t))
> +#endif

This introduces a mismatch between PTRS_PER_PGD and PGD_SIZE. While it
happens not to corrupt any memory (we allocate a full page for pgdirs),
the compiler complains about the memset() in map_entry_trampoline()
since tramp_pg_dir[] is smaller.

-- 
Catalin
