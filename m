Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 06ED7280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 09:46:11 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so7698393pab.22
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 06:46:11 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id fa6si9364322pab.53.2014.10.31.06.46.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 06:46:11 -0700 (PDT)
Received: by mail-pa0-f46.google.com with SMTP id lf10so7763376pab.33
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 06:46:10 -0700 (PDT)
Date: Fri, 31 Oct 2014 22:46:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] zram: avoid kunmap_atomic a NULL pointer
Message-ID: <20141031134632.GA942@swordfish>
References: <000001cff409$bf7bfa50$3e73eef0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001cff409$bf7bfa50$3e73eef0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

On (10/30/14 14:20), Weijie Yang wrote:
> zram could kunmap_atomic a NULL pointer in a rare situation:
> a zram page become a full-zeroed page after a partial write io.
> The current code doesn't handle this case and kunmap_atomic a
> NULL porinter, which panic the kernel.
> 
> This patch fixes this issue.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

thank you, Weijie.

Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ---
>  drivers/block/zram/zram_drv.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 2ad0b5b..3920ee4 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -560,7 +560,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  	}
>  
>  	if (page_zero_filled(uncmem)) {
> -		kunmap_atomic(user_mem);
> +		if (user_mem)
> +			kunmap_atomic(user_mem);
>  		/* Free memory associated with this sector now. */
>  		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  		zram_free_page(zram, index);
> -- 
> 1.7.0.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
