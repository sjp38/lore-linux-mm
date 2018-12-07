Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5422B8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 06:21:09 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id u63so1675609oie.17
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 03:21:09 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c6si1415451oto.262.2018.12.07.03.21.07
        for <linux-mm@kvack.org>;
        Fri, 07 Dec 2018 03:21:07 -0800 (PST)
Date: Fri, 7 Dec 2018 11:21:03 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V5 4/7] arm64: mm: Offset TTBR1 to allow 52-bit
 PTRS_PER_PGD
Message-ID: <20181207112102.GB23085@arrakis.emea.arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
 <20181206225042.11548-5-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181206225042.11548-5-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, ard.biesheuvel@linaro.org, suzuki.poulose@arm.com, will.deacon@arm.com, jcm@redhat.com

On Thu, Dec 06, 2018 at 10:50:39PM +0000, Steve Capper wrote:
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
>  = (0xFFFF << 6) & 0x3FF - (0xFFFF << 6) & 0x3F	// "lower" cancels out
>  = 0x3C0
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

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
