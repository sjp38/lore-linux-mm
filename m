Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8646B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 03:08:53 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p14so7434375wmc.0
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 00:08:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j185sor3894963wma.24.2018.03.08.00.08.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Mar 2018 00:08:51 -0800 (PST)
Date: Thu, 8 Mar 2018 09:08:47 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: Add interfaces to free unused page table
Message-ID: <20180308080847.dvwd3w6wuhwsg3qo@gmail.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
 <20180307183227.17983-2-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180307183227.17983-2-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com, guohanjun@huawei.com, will.deacon@arm.com, wxf.wang@hisilicon.com, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Toshi Kani <toshi.kani@hpe.com> wrote:

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

Where does x86 iounmap() do that?

> x86 still has memory leak.
> Add two interfaces, pud_free_pmd_page() and pmd_free_pte_page(),
> which clear a given pud/pmd entry and free up a page for the lower
> level entries.
> 
> This patch implements their stub functions on x86 and arm64, which
> work as workaround.

At minimum the ordering of the patches is very confusing: why don't you introduce 
the new methods in patch #1, and then use them in patch #2?

Also please double check the coding style of your patches, there's a number of 
obvious problems of outright bad patterns and also cases where you clearly don't 
try to follow the (correct) style of existing code.

Thanks,

	Ingo
