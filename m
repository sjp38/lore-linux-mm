Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFEE68E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 07:02:51 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id z22so101644oto.11
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 04:02:51 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y23si1478802otj.129.2018.12.07.04.02.50
        for <linux-mm@kvack.org>;
        Fri, 07 Dec 2018 04:02:50 -0800 (PST)
Subject: Re: [PATCH V5 4/7] arm64: mm: Offset TTBR1 to allow 52-bit
 PTRS_PER_PGD
References: <20181206225042.11548-1-steve.capper@arm.com>
 <20181206225042.11548-5-steve.capper@arm.com>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <bc7581b3-2cb9-b11f-d33f-4999cbff3a0f@arm.com>
Date: Fri, 7 Dec 2018 12:04:21 +0000
MIME-Version: 1.0
In-Reply-To: <20181206225042.11548-5-steve.capper@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com

On 12/06/2018 10:50 PM, Steve Capper wrote:
> Enabling 52-bit VAs on arm64 requires that the PGD table expands from 64
> entries (for the 48-bit case) to 1024 entries. This quantity,
> PTRS_PER_PGD is used as follows to compute which PGD entry corresponds
> to a given virtual address, addr:
> 
> pgd_index(addr) -> (addr >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)
> 
> Userspace addresses are prefixed by 0's, so for a 48-bit userspace
> address, uva, the following is true:
> (uva >> PGDIR_SHIFT) & (1024 - 1) == (uva >> PGDIR_SHIFT) & (64 - 1)
> 
> In other words, a 48-bit userspace address will have the same pgd_index
> when using PTRS_PER_PGD = 64 and 1024.
> 
> Kernel addresses are prefixed by 1's so, given a 48-bit kernel address,
> kva, we have the following inequality:
> (kva >> PGDIR_SHIFT) & (1024 - 1) != (kva >> PGDIR_SHIFT) & (64 - 1)
> 
> In other words a 48-bit kernel virtual address will have a different
> pgd_index when using PTRS_PER_PGD = 64 and 1024.
> 
> If, however, we note that:
> kva = 0xFFFF << 48 + lower (where lower[63:48] == 0b)
> and, PGDIR_SHIFT = 42 (as we are dealing with 64KB PAGE_SIZE)
> 
> We can consider:
> (kva >> PGDIR_SHIFT) & (1024 - 1) - (kva >> PGDIR_SHIFT) & (64 - 1)
>   = (0xFFFF << 6) & 0x3FF - (0xFFFF << 6) & 0x3F	// "lower" cancels out
>   = 0x3C0
> 
> In other words, one can switch PTRS_PER_PGD to the 52-bit value globally
> provided that they increment ttbr1_el1 by 0x3C0 * 8 = 0x1E00 bytes when
> running with 48-bit kernel VAs (TCR_EL1.T1SZ = 16).
> 
> For kernel configuration where 52-bit userspace VAs are possible, this
> patch offsets ttbr1_el1 and sets PTRS_PER_PGD corresponding to the
> 52-bit value.
> 
> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Steve Capper <steve.capper@arm.com>
> 
> ---
> 
> Changed in V5, removed ttbr1 save/restore logic for software PAN as
> hardware PAN is a mandatory ARMv8.1 feature anyway. The logic to enable
> 52-bit VAs has also been changed to depend on
> ARM64_PAN || !ARM64_SW_TTBR0_PAN
> (in a later patch)
> 
> This patch is new in V4 of the series
> ---
>   arch/arm64/include/asm/assembler.h     | 23 +++++++++++++++++++++++
>   arch/arm64/include/asm/pgtable-hwdef.h |  9 +++++++++
>   arch/arm64/kernel/head.S               |  1 +
>   arch/arm64/kernel/hibernate-asm.S      |  1 +
>   arch/arm64/mm/proc.S                   |  4 ++++
>   5 files changed, 38 insertions(+)
> 
> diff --git a/arch/arm64/include/asm/assembler.h b/arch/arm64/include/asm/assembler.h
> index 6142402c2eb4..e2fe378d2a63 100644
> --- a/arch/arm64/include/asm/assembler.h
> +++ b/arch/arm64/include/asm/assembler.h
> @@ -515,6 +515,29 @@ USER(\label, ic	ivau, \tmp2)			// invalidate I line PoU
>   	mrs	\rd, sp_el0
>   	.endm
>   
> +/*
> + * Offset ttbr1 to allow for 48-bit kernel VAs set with 52-bit PTRS_PER_PGD.
> + * orr is used as it can cover the immediate value (and is idempotent).
> + * In future this may be nop'ed out when dealing with 52-bit kernel VAs.
> + * 	ttbr: Value of ttbr to set, modified.
> + */
> +	.macro	offset_ttbr1, ttbr
> +#ifdef CONFIG_ARM64_52BIT_VA
> +	orr	\ttbr, \ttbr, #TTBR1_BADDR_4852_OFFSET
> +#endif
> +	.endm
> +
> +/*
> + * Perform the reverse of offset_ttbr1.
> + * bic is used as it can cover the immediate value and, in future, won't need
> + * to be nop'ed out when dealing with 52-bit kernel VAs.
> + */
> +	.macro	restore_ttbr1, ttbr
> +#ifdef CONFIG_ARM64_52BIT_VA
> +	bic	\ttbr, \ttbr, #TTBR1_BADDR_4852_OFFSET
> +#endif
> +	.endm
> +

The above operation is safe as long as the TTBR1_BADDR_4852_OFFSET is
aligned to 2^6 or more. Otherwise we could corrupt the Bits[51:48]
of the BADDR stored in TTBR1[5:2] and thus the TTBR1:BADDR must be 
aligned to 64bytes minimum as per v8.2LVA restrictions. Since we have
restricted the VA_BITS to 48, we should be safe here.


Do we need a BUILD_BUG_ON() or something to check if this is still valid?

Eitherway,

Reviewed-by: Suzuki K Poulose <suzuki.poulose@arm.com>
