Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1866B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 17:54:59 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u36so2059887wrf.21
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 14:54:59 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l194si143706wmg.274.2018.03.07.14.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 14:54:57 -0800 (PST)
Date: Wed, 7 Mar 2018 14:54:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page
 table
Message-Id: <20180307145454.d3df4bed6d6431c52bcf271e@linux-foundation.org>
In-Reply-To: <20180307183227.17983-2-toshi.kani@hpe.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
	<20180307183227.17983-2-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com, guohanjun@huawei.com, will.deacon@arm.com, wxf.wang@hisilicon.com, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

On Wed,  7 Mar 2018 11:32:26 -0700 Toshi Kani <toshi.kani@hpe.com> wrote:

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
> index 004abf9ebf12..942f4fa341f1 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -702,4 +702,24 @@ int pmd_clear_huge(pmd_t *pmd)
>  
>  	return 0;
>  }
> +
> +/**
> + * pud_free_pmd_page - clear pud entry and free pmd page
> + *
> + * Returns 1 on success and 0 on failure (pud not cleared).
> + */
> +int pud_free_pmd_page(pud_t *pud)
> +{
> +	return pud_none(*pud);
> +}
> +
> +/**
> + * pmd_free_pte_page - clear pmd entry and free pte page
> + *
> + * Returns 1 on success and 0 on failure (pmd not cleared).
> + */
> +int pmd_free_pte_page(pmd_t *pmd)
> +{
> +	return pmd_none(*pmd);
> +}

Are these functions well named?  I mean, the comment says "clear pud
entry and free pmd page" but the implementatin does neither of those
things.  The name implies that the function frees a pmd_page but the
callsites use the function as a way of querying state.
