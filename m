Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7746B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 13:04:45 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id d142so3365709oih.4
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 10:04:45 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l7si6101669otk.351.2018.03.08.10.04.43
        for <linux-mm@kvack.org>;
        Thu, 08 Mar 2018 10:04:43 -0800 (PST)
Date: Thu, 8 Mar 2018 18:04:47 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page table
Message-ID: <20180308180446.GF14918@arm.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
 <20180307183227.17983-2-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180307183227.17983-2-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com, guohanjun@huawei.com, wxf.wang@hisilicon.com, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

Hi Toshi,

Thanks for the patches!

On Wed, Mar 07, 2018 at 11:32:26AM -0700, Toshi Kani wrote:
> On architectures with CONFIG_HAVE_ARCH_HUGE_VMAP set, ioremap()
> may create pud/pmd mappings.  Kernel panic was observed on arm64
> systems with Cortex-A75 in the following steps as described by
> Hanjun Guo.
> 
> 1. ioremap a 4K size, valid page table will build,
> 2. iounmap it, pte0 will set to 0;
> 3. ioremap the same address with 2M size, pgd/pmd is unchanged,
>    then set the a new value for pmd;
> 4. pte0 is leaked;
> 5. CPU may meet exception because the old pmd is still in TLB,
>    which will lead to kernel panic.
> 
> This panic is not reproducible on x86.  INVLPG, called from iounmap,
> purges all levels of entries associated with purged address on x86.
> x86 still has memory leak.
> 
> Add two interfaces, pud_free_pmd_page() and pmd_free_pte_page(),
> which clear a given pud/pmd entry and free up a page for the lower
> level entries.
> 
> This patch implements their stub functions on x86 and arm64, which
> work as workaround.
> 
> Reported-by: Lei Li <lious.lilei@hisilicon.com>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Wang Xuefeng <wxf.wang@hisilicon.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Hanjun Guo <guohanjun@huawei.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Borislav Petkov <bp@suse.de>
> ---
>  arch/arm64/mm/mmu.c           |   10 ++++++++++
>  arch/x86/mm/pgtable.c         |   20 ++++++++++++++++++++
>  include/asm-generic/pgtable.h |   10 ++++++++++
>  lib/ioremap.c                 |    6 ++++--
>  4 files changed, 44 insertions(+), 2 deletions(-)

[...]

> diff --git a/lib/ioremap.c b/lib/ioremap.c
> index b808a390e4c3..54e5bbaa3200 100644
> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -91,7 +91,8 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
>  
>  		if (ioremap_pmd_enabled() &&
>  		    ((next - addr) == PMD_SIZE) &&
> -		    IS_ALIGNED(phys_addr + addr, PMD_SIZE)) {
> +		    IS_ALIGNED(phys_addr + addr, PMD_SIZE) &&
> +		    pmd_free_pte_page(pmd)) {

I find it a bit weird that we're postponing this to the subsequent map. If
we want to address the break-before-make issue that was causing a panic on
arm64, then I think it would be better to do this on the unmap path to avoid
duplicating TLB invalidation.

Will
