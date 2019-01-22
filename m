Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B88028E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 03:55:26 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so9178753eda.3
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 00:55:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c1-v6si4896291ejf.257.2019.01.22.00.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 00:55:25 -0800 (PST)
Date: Tue, 22 Jan 2019 09:55:24 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: cleanup usemap_size() when SPARSEMEM is
 not set
Message-ID: <20190122085524.GE4087@dhcp22.suse.cz>
References: <20190118234905.27597-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190118234905.27597-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Sat 19-01-19 07:49:05, Wei Yang wrote:
> Two cleanups in this patch:
> 
>   * since pageblock_nr_pages == (1 << pageblock_order), the roundup()
>     and right shift pageblock_order could be replaced with
>     DIV_ROUND_UP()

Why is this change worth it?

>   * use BITS_TO_LONGS() to get number of bytes for bitmap
> 
> This patch also fix one typo in comment.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/page_alloc.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d295c9bc01a8..d7073cedd087 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6352,7 +6352,7 @@ static void __init calculate_node_totalpages(struct pglist_data *pgdat,
>  /*
>   * Calculate the size of the zone->blockflags rounded to an unsigned long
>   * Start by making sure zonesize is a multiple of pageblock_order by rounding
> - * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
> + * up. Then use 1 NR_PAGEBLOCK_BITS width of bits per pageblock, finally

why do you change this?

>   * round what is now in bits to nearest long in bits, then return it in
>   * bytes.
>   */
> @@ -6361,12 +6361,9 @@ static unsigned long __init usemap_size(unsigned long zone_start_pfn, unsigned l
>  	unsigned long usemapsize;
>  
>  	zonesize += zone_start_pfn & (pageblock_nr_pages-1);
> -	usemapsize = roundup(zonesize, pageblock_nr_pages);
> -	usemapsize = usemapsize >> pageblock_order;
> +	usemapsize = DIV_ROUND_UP(zonesize, pageblock_nr_pages);
>  	usemapsize *= NR_PAGEBLOCK_BITS;
> -	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
> -
> -	return usemapsize / 8;
> +	return BITS_TO_LONGS(usemapsize) * sizeof(unsigned long);
>  }
>  
>  static void __ref setup_usemap(struct pglist_data *pgdat,
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
