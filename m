Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A50D16B0006
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 18:38:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v3so2236823pfm.21
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 15:38:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n18si2774775pfi.262.2018.03.14.15.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 15:38:37 -0700 (PDT)
Date: Wed, 14 Mar 2018 15:38:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] mm/vmalloc: Add interfaces to free unmapped page
 table
Message-Id: <20180314153835.68e75da3fdc18b27ad0e290c@linux-foundation.org>
In-Reply-To: <20180314180155.19492-2-toshi.kani@hpe.com>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
	<20180314180155.19492-2-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com, guohanjun@huawei.com, will.deacon@arm.com, wxf.wang@hisilicon.com, willy@infradead.org, cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, 14 Mar 2018 12:01:54 -0600 Toshi Kani <toshi.kani@hpe.com> wrote:

> On architectures with CONFIG_HAVE_ARCH_HUGE_VMAP set, ioremap()
> may create pud/pmd mappings.  Kernel panic was observed on arm64
> systems with Cortex-A75 in the following steps as described by
> Hanjun Guo.
> 
>  1. ioremap a 4K size, valid page table will build,
>  2. iounmap it, pte0 will set to 0;
>  3. ioremap the same address with 2M size, pgd/pmd is unchanged,
>     then set the a new value for pmd;
>  4. pte0 is leaked;
>  5. CPU may meet exception because the old pmd is still in TLB,
>     which will lead to kernel panic.
> 
> This panic is not reproducible on x86.  INVLPG, called from iounmap,
> purges all levels of entries associated with purged address on x86.
> x86 still has memory leak.
> 
> The patch changes the ioremap path to free unmapped page table(s) since
> doing so in the unmap path has the following issues:
> 
>  - The iounmap() path is shared with vunmap().  Since vmap() only
>    supports pte mappings, making vunmap() to free a pte page is an
>    overhead for regular vmap users as they do not need a pte page
>    freed up.
>  - Checking if all entries in a pte page are cleared in the unmap path
>    is racy, and serializing this check is expensive.
>  - The unmap path calls free_vmap_area_noflush() to do lazy TLB purges.
>    Clearing a pud/pmd entry before the lazy TLB purges needs extra TLB
>    purge.
> 
> Add two interfaces, pud_free_pmd_page() and pmd_free_pte_page(),
> which clear a given pud/pmd entry and free up a page for the lower
> level entries.
> 
> This patch implements their stub functions on x86 and arm64, which
> work as workaround.
> 

whoops.

--- a/include/asm-generic/pgtable.h~mm-vmalloc-add-interfaces-to-free-unmapped-page-table-fix
+++ a/include/asm-generic/pgtable.h
@@ -1014,7 +1014,7 @@ static inline int pud_free_pmd_page(pud_
 {
 	return 0;
 }
-static inline int pmd_free_pte_page(pud_t *pmd)
+static inline int pmd_free_pte_page(pmd_t *pmd)
 {
 	return 0;
 }
_
