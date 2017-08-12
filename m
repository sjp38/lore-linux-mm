Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D845B6B02B4
	for <linux-mm@kvack.org>; Sat, 12 Aug 2017 07:26:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r187so62713132pfr.8
        for <linux-mm@kvack.org>; Sat, 12 Aug 2017 04:26:10 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o29si1876017pli.288.2017.08.12.04.26.09
        for <linux-mm@kvack.org>;
        Sat, 12 Aug 2017 04:26:09 -0700 (PDT)
Date: Sat, 12 Aug 2017 12:26:03 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Message-ID: <20170812112603.GB16374@remoulade>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809200755.11234-5-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Wed, Aug 09, 2017 at 02:07:49PM -0600, Tycho Andersen wrote:
> From: Juerg Haefliger <juerg.haefliger@hpe.com>
> 
> Add a hook for flushing a single TLB entry on arm64.
> 
> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> Tested-by: Tycho Andersen <tycho@docker.com>
> ---
>  arch/arm64/include/asm/tlbflush.h | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/arch/arm64/include/asm/tlbflush.h b/arch/arm64/include/asm/tlbflush.h
> index af1c76981911..8e0c49105d3e 100644
> --- a/arch/arm64/include/asm/tlbflush.h
> +++ b/arch/arm64/include/asm/tlbflush.h
> @@ -184,6 +184,14 @@ static inline void flush_tlb_kernel_range(unsigned long start, unsigned long end
>  	isb();
>  }
>  
> +static inline void __flush_tlb_one(unsigned long addr)
> +{
> +	dsb(ishst);
> +	__tlbi(vaae1is, addr >> 12);
> +	dsb(ish);
> +	isb();
> +}

Is this going to be called by generic code?

It would be nice if we could drop 'kernel' into the name, to make it clear this
is intended to affect the kernel mappings, which have different maintenance
requirements to user mappings.

We should be able to implement this more simply as:

flush_tlb_kernel_page(unsigned long addr)
{
	flush_tlb_kernel_range(addr, addr + PAGE_SIZE);
}

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
