Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B13D96B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:14:58 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b23-v6so2372414oib.16
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 03:14:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t9-v6sor1490415oth.224.2018.03.21.03.14.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 03:14:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1521619796-3846-3-git-send-email-hejianet@gmail.com>
References: <1521619796-3846-1-git-send-email-hejianet@gmail.com> <1521619796-3846-3-git-send-email-hejianet@gmail.com>
From: Daniel Vacek <neelx@redhat.com>
Date: Wed, 21 Mar 2018 11:14:57 +0100
Message-ID: <CACjP9X94yUxYWimmq1re7oTxhQUfbduVoJ0=iqPiWqV0cjUKng@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/memblock: introduce memblock_search_pfn_regions()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>

On Wed, Mar 21, 2018 at 9:09 AM, Jia He <hejianet@gmail.com> wrote:
> This api is the preparation for further optimizing early_pfn_valid
>
> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
> ---
>  include/linux/memblock.h |  2 ++
>  mm/memblock.c            | 12 ++++++++++++
>  2 files changed, 14 insertions(+)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 9471db4..5f46956 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -203,6 +203,8 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
>              i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>
> +int memblock_search_pfn_regions(unsigned long pfn);
> +
>  unsigned long memblock_next_valid_pfn(unsigned long pfn, int *last_idx);
>  /**
>   * for_each_free_mem_range - iterate through free memblock areas
> diff --git a/mm/memblock.c b/mm/memblock.c
> index a9e8da4..f50fe5b 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1659,6 +1659,18 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
>         return -1;
>  }
>
> +/* search memblock with the input pfn, return the region idx */
> +int __init_memblock memblock_search_pfn_regions(unsigned long pfn)
> +{
> +       struct memblock_type *type = &memblock.memory;
> +       int mid = memblock_search(type, PFN_PHYS(pfn));
> +
> +       if (mid == -1)
> +               return -1;

Why this?

> +       return mid;
> +}
> +
>  bool __init memblock_is_reserved(phys_addr_t addr)
>  {
>         return memblock_search(&memblock.reserved, addr) != -1;
> --
> 2.7.4
>
