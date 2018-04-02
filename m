Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 780F06B0011
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 02:57:45 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r69so13275203ioe.20
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 23:57:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h63sor6222315ioa.172.2018.04.01.23.57.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Apr 2018 23:57:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1522636236-12625-4-git-send-email-hejianet@gmail.com>
References: <1522636236-12625-1-git-send-email-hejianet@gmail.com> <1522636236-12625-4-git-send-email-hejianet@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 2 Apr 2018 08:57:44 +0200
Message-ID: <CAKv+Gu8dO=fn+MLvZEGzJMvw6u1vMaACz5utBzE4YLLFduGRFQ@mail.gmail.com>
Subject: Re: [PATCH v5 3/5] mm/memblock: introduce memblock_search_pfn_regions()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

On 2 April 2018 at 04:30, Jia He <hejianet@gmail.com> wrote:
> This api is the preparation for further optimizing early_pfn_valid
>

Please add more explanatation here of what it is you are doing and why.


> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
> ---
>  include/linux/memblock.h | 2 ++
>  mm/memblock.c            | 9 +++++++++
>  2 files changed, 11 insertions(+)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 0257aee..a0127b3 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -203,6 +203,8 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
>              i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>
> +int memblock_search_pfn_regions(unsigned long pfn);
> +
>  /**
>   * for_each_free_mem_range - iterate through free memblock areas
>   * @i: u64 used as loop variable
> diff --git a/mm/memblock.c b/mm/memblock.c
> index ba7c878..0f4004c 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1617,6 +1617,15 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
>         return -1;
>  }
>
> +/* search memblock with the input pfn, return the region idx */
> +int __init_memblock memblock_search_pfn_regions(unsigned long pfn)
> +{
> +       struct memblock_type *type = &memblock.memory;
> +       int mid = memblock_search(type, PFN_PHYS(pfn));
> +
> +       return mid;
> +}
> +
>  bool __init memblock_is_reserved(phys_addr_t addr)
>  {
>         return memblock_search(&memblock.reserved, addr) != -1;
> --
> 2.7.4
>
