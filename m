Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A116F6B0007
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:02:57 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r9so11271845ioa.11
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 02:02:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u130sor6773itc.138.2018.03.13.02.02.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 02:02:56 -0700 (PDT)
Date: Tue, 13 Mar 2018 18:02:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv2 2/2] zram: drop max_zpage_size and use
 zs_huge_class_size()
Message-ID: <20180313090249.GA240650@rodete-desktop-imager.corp.google.com>
References: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
 <20180306070639.7389-3-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180306070639.7389-3-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi Sergey,

Sorry for being late.
I love this patchset! Just a minor below.

On Tue, Mar 06, 2018 at 04:06:39PM +0900, Sergey Senozhatsky wrote:
> This patch removes ZRAM's enforced "huge object" value and uses
> zsmalloc huge-class watermark instead, which makes more sense.
> 
> TEST
> - I used a 1G zram device, LZO compression back-end, original
>   data set size was 444MB. Looking at zsmalloc classes stats the
>   test ended up to be pretty fair.
> 
> BASE ZRAM/ZSMALLOC
> =====================
> zram mm_stat
> 
> 498978816 191482495 199831552        0 199831552    15634        0
> 
> zsmalloc classes
> 
>  class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage freeable
> ...
>    151  2448           0            0          1240       1240        744                3        0
>    168  2720           0            0          4200       4200       2800                2        0
>    190  3072           0            0         10100      10100       7575                3        0
>    202  3264           0            0           380        380        304                4        0
>    254  4096           0            0         10620      10620      10620                1        0
> 
>  Total                 7           46        106982     106187      48787                         0
> 
> PATCHED ZRAM/ZSMALLOC
> =====================
> 
> zram mm_stat
> 
> 498978816 182579184 194248704        0 194248704    15628        0
> 
> zsmalloc classes
> 
>  class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage freeable
> ...
>    151  2448           0            0          1240       1240        744                3        0
>    168  2720           0            0          4200       4200       2800                2        0
>    190  3072           0            0         10100      10100       7575                3        0
>    202  3264           0            0          7180       7180       5744                4        0
>    254  4096           0            0          3820       3820       3820                1        0
> 
>  Total                 8           45        106959     106193      47424                         0
> 
> As we can see, we reduced the number of objects stored in class-4096,
> because a huge number of objects which we previously forcibly stored
> in class-4096 now stored in non-huge class-3264. This results in lower
> memory consumption:
>  - zsmalloc now uses 47424 physical pages, which is less than 48787
>    pages zsmalloc used before.
> 
>  - objects that we store in class-3264 share zspages. That's why overall
>    the number of pages that both class-4096 and class-3264 consumed went
>    down from 10924 to 9564.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  drivers/block/zram/zram_drv.c |  9 ++++++++-
>  drivers/block/zram/zram_drv.h | 16 ----------------
>  2 files changed, 8 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 85110e7931e5..1b8082e6d2f5 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -44,6 +44,11 @@ static const char *default_compressor = "lzo";
>  
>  /* Module params (documentation at end) */
>  static unsigned int num_devices = 1;
> +/*
> + * Pages that compress to sizes equals or greater than this are stored
> + * uncompressed in memory.
> + */
> +static size_t huge_class_size;
>  
>  static void zram_free_page(struct zram *zram, size_t index);
>  
> @@ -786,6 +791,8 @@ static bool zram_meta_alloc(struct zram *zram, u64 disksize)
>  		return false;
>  	}
>  
> +	if (!huge_class_size)
> +		huge_class_size = zs_huge_class_size();

If it is static, we can do this in zram_init? I believe it's more readable in that
it's never changed betweens zram instances.
