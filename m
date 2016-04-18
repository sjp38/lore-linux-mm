Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7779F6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 04:11:27 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id js7so161486310obc.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 01:11:27 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id e10si21282997iof.34.2016.04.18.01.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 01:11:26 -0700 (PDT)
Received: by mail-ig0-x22a.google.com with SMTP id g8so73601353igr.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 01:11:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460920476-14320-1-git-send-email-kuleshovmail@gmail.com>
References: <1460920476-14320-1-git-send-email-kuleshovmail@gmail.com>
Date: Mon, 18 Apr 2016 10:11:26 +0200
Message-ID: <CAKv+Gu-F8bJfg9zpa5oFMT6tj2Wd1mBx8O-ag1asav_HsR0tfw@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: move memblock_{add,reserve}_region into memblock_{add,reserve}
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Tony Luck <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Gibson <david@gibson.dropbear.id.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 17 April 2016 at 21:14, Alexander Kuleshov <kuleshovmail@gmail.com> wrote:
> From: 0xAX <kuleshovmail@gmail.com>
>
> The memblock_add_region() and memblock_reserve_region do not nothing specific
> before the call of the memblock_add_range(), only print debug output.
>
> We can do the same in the memblock_add() and memblock_reserve() since both
> memblock_add_region() and memblock_reserve_region are not used by anybody
> outside of memblock.c and the memblock_{add,reserve}() have the same set of
> flags and nids.
>
> Since the memblock_add_region() and memblock_reserve_region() anyway will be
> inlined, there will not be functional changes, but will improve code readability
> a little.
>
> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>

Acked-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  mm/memblock.c | 28 ++++++----------------------
>  1 file changed, 6 insertions(+), 22 deletions(-)
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index b570ddd..3b93daa 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -606,22 +606,14 @@ int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
>         return memblock_add_range(&memblock.memory, base, size, nid, 0);
>  }
>
> -static int __init_memblock memblock_add_region(phys_addr_t base,
> -                                               phys_addr_t size,
> -                                               int nid,
> -                                               unsigned long flags)
> +int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
>  {
>         memblock_dbg("memblock_add: [%#016llx-%#016llx] flags %#02lx %pF\n",
>                      (unsigned long long)base,
>                      (unsigned long long)base + size - 1,
> -                    flags, (void *)_RET_IP_);
> -
> -       return memblock_add_range(&memblock.memory, base, size, nid, flags);
> -}
> +                    0UL, (void *)_RET_IP_);
>
> -int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
> -{
> -       return memblock_add_region(base, size, MAX_NUMNODES, 0);
> +       return memblock_add_range(&memblock.memory, base, size, MAX_NUMNODES, 0);
>  }
>
>  /**
> @@ -732,22 +724,14 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
>         return memblock_remove_range(&memblock.reserved, base, size);
>  }
>
> -static int __init_memblock memblock_reserve_region(phys_addr_t base,
> -                                                  phys_addr_t size,
> -                                                  int nid,
> -                                                  unsigned long flags)
> +int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
>  {
>         memblock_dbg("memblock_reserve: [%#016llx-%#016llx] flags %#02lx %pF\n",
>                      (unsigned long long)base,
>                      (unsigned long long)base + size - 1,
> -                    flags, (void *)_RET_IP_);
> -
> -       return memblock_add_range(&memblock.reserved, base, size, nid, flags);
> -}
> +                    0UL, (void *)_RET_IP_);
>
> -int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
> -{
> -       return memblock_reserve_region(base, size, MAX_NUMNODES, 0);
> +       return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, 0);
>  }
>
>  /**
> --
> 2.8.0.rc3.212.g1f992f2.dirty
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
