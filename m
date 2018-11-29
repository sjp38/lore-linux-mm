Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA806B539C
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 12:00:23 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id d7so1349498oif.5
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 09:00:23 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g11si1140158oic.175.2018.11.29.09.00.21
        for <linux-mm@kvack.org>;
        Thu, 29 Nov 2018 09:00:21 -0800 (PST)
Date: Thu, 29 Nov 2018 17:00:16 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] mm/memblock: skip kmemleak for kasan_init()
Message-ID: <20181129170016.GD22027@arrakis.emea.arm.com>
References: <1543442925-17794-1-git-send-email-cai@gmx.us>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543442925-17794-1-git-send-email-cai@gmx.us>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@gmx.us>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rppt@linux.vnet.ibm.com, aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 28, 2018 at 05:08:45PM -0500, Qian Cai wrote:
> Kmemleak does not play well with KASAN (tested on both HPE Apollo 70 and
> Huawei TaiShan 2280 aarch64 servers).
> 
> After calling start_kernel()->setup_arch()->kasan_init(), kmemleak early
> log buffer went from something like 280 to 260000 which caused kmemleak
> disabled and crash dump memory reservation failed. The multitude of
> kmemleak_alloc() calls is from nested loops while KASAN is setting up
> full memory mappings, so let early kmemleak allocations skip those
> memblock_alloc_internal() calls came from kasan_init() given that those
> early KASAN memory mappings should not reference to other memory.
> Hence, no kmemleak false positives.
> 
> kasan_init
>   kasan_map_populate [1]
>     kasan_pgd_populate [2]
>       kasan_pud_populate [3]
>         kasan_pmd_populate [4]
>           kasan_pte_populate [5]
>             kasan_alloc_zeroed_page
>               memblock_alloc_try_nid
>                 memblock_alloc_internal
>                   kmemleak_alloc
> 
> [1] for_each_memblock(memory, reg)
> [2] while (pgdp++, addr = next, addr != end)
> [3] while (pudp++, addr = next, addr != end && pud_none(READ_ONCE(*pudp)))
> [4] while (pmdp++, addr = next, addr != end && pmd_none(READ_ONCE(*pmdp)))
> [5] while (ptep++, addr = next, addr != end && pte_none(READ_ONCE(*ptep)))
> 
> Signed-off-by: Qian Cai <cai@gmx.us>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

(for both the kmemleak and arm64 changes)
