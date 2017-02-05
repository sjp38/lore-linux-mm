Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7180C6B0033
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 09:21:04 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so80477367pfx.1
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 06:21:04 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id u17si26249085pgn.198.2017.02.05.06.21.02
        for <linux-mm@kvack.org>;
        Sun, 05 Feb 2017 06:21:03 -0800 (PST)
Date: Sun, 5 Feb 2017 23:21:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170205142100.GA9611@bbox>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1486111347-112972-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
In-Reply-To: <1486111347-112972-1-git-send-email-zhouxianrong@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, willy@infradead.org, iamjoonsoo.kim@lge.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

Hi zhouxianrong,

On Fri, Feb 03, 2017 at 04:42:27PM +0800, zhouxianrong@huawei.com wrote:
> From: zhouxianrong <zhouxianrong@huawei.com>
> 
> test result as listed below:
> 
> zero   pattern_char pattern_short pattern_int pattern_long total   (unit)
> 162989 14454        3534          23516       2769         3294399 (page)
> 
> statistics for the result:
> 
>         zero  pattern_char  pattern_short  pattern_int  pattern_long
> AVERAGE 0.745696298 0.085937175 0.015957701 0.131874915 0.020533911
> STDEV   0.035623777 0.016892402 0.004454534 0.021657123 0.019420072
> MAX     0.973813421 0.222222222 0.021409518 0.211812245 0.176512625
> MIN     0.645431905 0.004634398 0           0           0

The description in old version was better for justifying same page merging
feature.

> 
> Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
> ---
>  drivers/block/zram/zram_drv.c |  124 +++++++++++++++++++++++++++++++----------
>  drivers/block/zram/zram_drv.h |   11 ++--
>  2 files changed, 103 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index e5ab7d9..6a8c9c5 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -95,6 +95,17 @@ static void zram_clear_flag(struct zram_meta *meta, u32 index,
>  	meta->table[index].value &= ~BIT(flag);
>  }
>  
> +static inline void zram_set_element(struct zram_meta *meta, u32 index,
> +			unsigned long element)
> +{
> +	meta->table[index].element = element;
> +}
> +
> +static inline void zram_clear_element(struct zram_meta *meta, u32 index)
> +{
> +	meta->table[index].element = 0;
> +}
> +
>  static size_t zram_get_obj_size(struct zram_meta *meta, u32 index)
>  {
>  	return meta->table[index].value & (BIT(ZRAM_FLAG_SHIFT) - 1);
> @@ -167,31 +178,78 @@ static inline void update_used_max(struct zram *zram,
>  	} while (old_max != cur_max);
>  }
>  
> -static bool page_zero_filled(void *ptr)
> +static inline void zram_fill_page(char *ptr, unsigned long value)
> +{
> +	int i;
> +	unsigned long *page = (unsigned long *)ptr;
> +
> +	if (likely(value == 0)) {
> +		clear_page(ptr);
> +	} else {
> +		for (i = 0; i < PAGE_SIZE / sizeof(*page); i++)
> +			page[i] = value;
> +	}
> +}
> +
> +static inline void zram_fill_page_partial(char *ptr, unsigned int size,
> +		unsigned long value)
> +{
> +	int i;
> +	unsigned long *page;
> +
> +	if (likely(value == 0)) {
> +		memset(ptr, 0, size);
> +		return;
> +	}
> +
> +	i = ((unsigned long)ptr) % sizeof(*page);
> +	if (i) {
> +		while (i < sizeof(*page)) {
> +			*ptr++ = (value >> (i * 8)) & 0xff;
> +			--size;
> +			++i;
> +		}
> +	}
> +

I don't think we need this part because block layer works with sector
size or multiple times of it so it must be aligned unsigned long.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
