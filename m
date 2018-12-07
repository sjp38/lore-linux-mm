Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 942B26B7F46
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 02:36:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so1568980edz.15
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 23:36:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18-v6si1007283ejz.304.2018.12.06.23.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 23:36:26 -0800 (PST)
Subject: Re: [PATCHv2] mm/pageblock: throw compiling time error if
 pageblock_bits can not hold MIGRATE_TYPES
References: <1544158388-20832-1-git-send-email-kernelfans@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7aa8d326-cffc-f2b6-2c03-01d9bd4c54b4@suse.cz>
Date: Fri, 7 Dec 2018 08:36:24 +0100
MIME-Version: 1.0
In-Reply-To: <1544158388-20832-1-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>

On 12/7/18 5:53 AM, Pingfan Liu wrote:
> Currently, NR_PAGEBLOCK_BITS and MIGRATE_TYPES are not associated by code.
> If someone adds extra migrate type, then he may forget to enlarge the
> NR_PAGEBLOCK_BITS. Hence it requires some way to fix.
> NR_PAGEBLOCK_BITS depends on MIGRATE_TYPES, while these macro
> spread on two different .h file with reverse dependency, it is a little
> hard to refer to MIGRATE_TYPES in pageblock-flag.h. This patch tries to
> remind such relation in compiling-time.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  include/linux/pageblock-flags.h | 5 +++--
>  mm/page_alloc.c                 | 3 ++-
>  2 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
> index 9132c5c..fe0aec4 100644
> --- a/include/linux/pageblock-flags.h
> +++ b/include/linux/pageblock-flags.h
> @@ -25,11 +25,12 @@
>  
>  #include <linux/types.h>
>  
> +#define PB_migratetype_bits 3
>  /* Bit indices that affect a whole block of pages */
>  enum pageblock_bits {
>  	PB_migrate,
> -	PB_migrate_end = PB_migrate + 3 - 1,
> -			/* 3 bits required for migrate types */
> +	PB_migrate_end = PB_migrate + PB_migratetype_bits - 1,
> +			/* n bits required for migrate types */
>  	PB_migrate_skip,/* If set the block is skipped by compaction */
>  
>  	/*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2ec9cc4..1a22d8d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -425,7 +425,8 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
>  	unsigned long bitidx, word_bitidx;
>  	unsigned long old_word, word;
>  
> -	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);

Why delete this one? It's for something a bit different and also still
valid.

> +	BUILD_BUG_ON(order_base_2(MIGRATE_TYPES)
> +		!= (PB_migratetype_bits - 1));

I think this should use the '>' operator. It's fine if there are less
types than what can fit into 3 bits. AFAICS for !CONFIG_DMA and
!CONFIG_MEMORY_ISOLATION there are just 4 types that fit into 2 bits...

>  
>  	bitmap = get_pageblock_bitmap(page, pfn);
>  	bitidx = pfn_to_bitidx(page, pfn);
> 
