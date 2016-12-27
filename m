Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6EBC6B025E
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 05:05:40 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so84509616wjb.3
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 02:05:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si49333278wjt.212.2016.12.27.02.05.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Dec 2016 02:05:39 -0800 (PST)
Date: Tue, 27 Dec 2016 11:05:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] lib: bitmap: introduce
 bitmap_find_next_zero_area_and_size
Message-ID: <20161227100535.GB7662@dhcp22.suse.cz>
References: <CGME20161226041809epcas5p1981244de55764c10f1a80d80346f3664@epcas5p1.samsung.com>
 <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, mina86@mina86.com, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, laurent.pinchart@ideasonboard.com, akinobu.mita@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Mon 26-12-16 13:18:11, Jaewon Kim wrote:
> There was no bitmap API which returns both next zero index and size of zeros
> from that index.
> 
> This is helpful to look fragmentation. This is an test code to look size of zeros.
> Test result is '10+9+994=>1013 found of total: 1024'
> 
> unsigned long search_idx, found_idx, nr_found_tot;
> unsigned long bitmap_max;
> unsigned int nr_found;
> unsigned long *bitmap;
> 
> search_idx = nr_found_tot = 0;
> bitmap_max = 1024;
> bitmap = kzalloc(BITS_TO_LONGS(bitmap_max) * sizeof(long),
> 		 GFP_KERNEL);
> 
> /* test bitmap_set offset, count */
> bitmap_set(bitmap, 10, 1);
> bitmap_set(bitmap, 20, 10);
> 
> for (;;) {
> 	found_idx = bitmap_find_next_zero_area_and_size(bitmap,
> 				bitmap_max, search_idx, &nr_found);
> 	if (found_idx >= bitmap_max)
> 		break;
> 	if (nr_found_tot == 0)
> 		printk("%u", nr_found);
> 	else
> 		printk("+%u", nr_found);
> 	nr_found_tot += nr_found;
> 	search_idx = found_idx + nr_found;
> }
> printk("=>%lu found of total: %lu\n", nr_found_tot, bitmap_max);

Who is going to use this function? I do not see any caller introduced by
this patch.

> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> ---
>  include/linux/bitmap.h |  6 ++++++
>  lib/bitmap.c           | 25 +++++++++++++++++++++++++
>  2 files changed, 31 insertions(+)
> 
> diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
> index 3b77588..b724a6c 100644
> --- a/include/linux/bitmap.h
> +++ b/include/linux/bitmap.h
> @@ -46,6 +46,7 @@
>   * bitmap_clear(dst, pos, nbits)		Clear specified bit area
>   * bitmap_find_next_zero_area(buf, len, pos, n, mask)	Find bit free area
>   * bitmap_find_next_zero_area_off(buf, len, pos, n, mask)	as above
> + * bitmap_find_next_zero_area_and_size(buf, len, pos, n, mask)	Find bit free area and its size
>   * bitmap_shift_right(dst, src, n, nbits)	*dst = *src >> n
>   * bitmap_shift_left(dst, src, n, nbits)	*dst = *src << n
>   * bitmap_remap(dst, src, old, new, nbits)	*dst = map(old, new)(src)
> @@ -123,6 +124,11 @@ extern unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
>  						    unsigned long align_mask,
>  						    unsigned long align_offset);
>  
> +extern unsigned long bitmap_find_next_zero_area_and_size(unsigned long *map,
> +							 unsigned long size,
> +							 unsigned long start,
> +							 unsigned int *nr);
> +
>  /**
>   * bitmap_find_next_zero_area - find a contiguous aligned zero area
>   * @map: The address to base the search on
> diff --git a/lib/bitmap.c b/lib/bitmap.c
> index 0b66f0e..d02817c 100644
> --- a/lib/bitmap.c
> +++ b/lib/bitmap.c
> @@ -332,6 +332,31 @@ unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
>  }
>  EXPORT_SYMBOL(bitmap_find_next_zero_area_off);
>  
> +/**
> + * bitmap_find_next_zero_area_and_size - find a contiguous aligned zero area
> + * @map: The address to base the search on
> + * @size: The bitmap size in bits
> + * @start: The bitnumber to start searching at
> + * @nr: The number of zeroed bits we've found
> + */
> +unsigned long bitmap_find_next_zero_area_and_size(unsigned long *map,
> +					     unsigned long size,
> +					     unsigned long start,
> +					     unsigned int *nr)
> +{
> +	unsigned long index, i;
> +
> +	*nr = 0;
> +	index = find_next_zero_bit(map, size, start);
> +
> +	if (index >= size)
> +		return index;
> +	i = find_next_bit(map, size, index);
> +	*nr = i - index;
> +	return index;
> +}
> +EXPORT_SYMBOL(bitmap_find_next_zero_area_and_size);
> +
>  /*
>   * Bitmap printing & parsing functions: first version by Nadia Yvette Chambers,
>   * second version by Paul Jackson, third by Joe Korty.
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
