Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD9A6B4E4A
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 13:18:22 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 32so12433237ots.15
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 10:18:22 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q131si2007900oia.181.2018.11.28.10.18.20
        for <linux-mm@kvack.org>;
        Wed, 28 Nov 2018 10:18:20 -0800 (PST)
Date: Wed, 28 Nov 2018 18:18:15 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm/memblock: skip kmemleak for kasan_init()
Message-ID: <20181128181815.GN3563@arrakis.emea.arm.com>
References: <1543426833-24378-1-git-send-email-cai@gmx.us>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543426833-24378-1-git-send-email-cai@gmx.us>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@gmx.us>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rppt@linux.vnet.ibm.com, aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 28, 2018 at 12:40:33PM -0500, Qian Cai wrote:
> Kmemleak does not play well with KASAN (tested on both HPE Apollo 70 and
> Huawei TaiShan 2280 aarch64 servers).
> 
> After calling start_kernel()->setup_arch()->kasan_init(), kmemleak early
> log buffer went from something like 280 to 260000 which caused kmemleak
> disabled and crash dump memory reservation failed. The multitude of
> kmemleak_alloc() calls is from,
> 
> for_each_memblock(memory, reg) x \
> while (pgdp++, addr = next, addr != end) x \
> while (pudp++, addr = next, addr != end && pud_none(READ_ONCE(*pudp))) \
> while (pmdp++, addr = next, addr != end && pmd_none(READ_ONCE(*pmdp))) \
> while (ptep++, addr = next, addr != end && pte_none(READ_ONCE(*ptep)))
> 
> Signed-off-by: Qian Cai <cai@gmx.us>

Sorry, I didn't get the chance to investigate this further. Hopefully
early next week.

> diff --git a/mm/memblock.c b/mm/memblock.c
> index 9a2d5ae..fd78e39 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1412,6 +1412,8 @@ static void * __init memblock_alloc_internal(
>  done:
>  	ptr = phys_to_virt(alloc);
>  
> +/* Skip kmemleak for kasan_init() due to high volume. */
> +#ifndef CONFIG_KASAN
>  	/*
>  	 * The min_count is set to 0 so that bootmem allocated blocks
>  	 * are never reported as leaks. This is because many of these blocks
> @@ -1419,6 +1421,7 @@ static void * __init memblock_alloc_internal(
>  	 * looked up by kmemleak.
>  	 */
>  	kmemleak_alloc(ptr, size, 0, 0);
> +#endif

This may render kmemleak unusable since it is not aware of the memblock
allocations and it would trigger lots of false positives.

-- 
Catalin
