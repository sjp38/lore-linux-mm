Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 065046B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 12:05:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v19-v6so5941492eds.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 09:05:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c37-v6si918517eda.459.2018.07.02.09.05.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 09:05:14 -0700 (PDT)
Date: Mon, 2 Jul 2018 18:05:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/sparse: Make sparse_init_one_section void and remove
 check
Message-ID: <20180702160512.GF19043@dhcp22.suse.cz>
References: <20180702154325.12196-1-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702154325.12196-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, bhe@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Mon 02-07-18 17:43:25, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> sparse_init_one_section() is being called from two sites:
> sparse_init() and sparse_add_one_section().
> The former calls it from a for_each_present_section_nr() loop,
> and the latter marks the section as present before calling it.
> This means that when sparse_init_one_section() gets called, we already know
> that the section is present.
> So there is no point to double check that in the function.
> 
> This removes the check and makes the function void.

Looks good.

> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/sparse.c | 12 +++---------
>  1 file changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index b2848cc6e32a..f55e79fda03e 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -264,19 +264,14 @@ struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pn
>  	return ((struct page *)coded_mem_map) + section_nr_to_pfn(pnum);
>  }
>  
> -static int __meminit sparse_init_one_section(struct mem_section *ms,
> +static void __meminit sparse_init_one_section(struct mem_section *ms,
>  		unsigned long pnum, struct page *mem_map,
>  		unsigned long *pageblock_bitmap)
>  {
> -	if (!present_section(ms))
> -		return -EINVAL;
> -
>  	ms->section_mem_map &= ~SECTION_MAP_MASK;
>  	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
>  							SECTION_HAS_MEM_MAP;
>   	ms->pageblock_flags = pageblock_bitmap;
> -
> -	return 1;
>  }
>  
>  unsigned long usemap_size(void)
> @@ -801,12 +796,11 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>  #endif
>  
>  	section_mark_present(ms);
> -
> -	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
> +	sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
>  out:
>  	pgdat_resize_unlock(pgdat, &flags);
> -	if (ret <= 0) {
> +	if (ret < 0) {
>  		kfree(usemap);
>  		__kfree_section_memmap(memmap, altmap);
>  	}
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
