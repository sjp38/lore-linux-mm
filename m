Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 251866B0005
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 20:32:29 -0500 (EST)
Date: Wed, 30 Jan 2013 10:32:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RESEND PATCH v5 1/4] zram: Fix deadlock bug in partial write
Message-ID: <20130130013226.GA2580@blaptop>
References: <1359333506-13599-1-git-send-email-minchan@kernel.org>
 <CAOJsxLFg_5uhZsvPmVVC0nnsZLGpkJ0W6mHa=aavmguLGuTTnA@mail.gmail.com>
 <20130128232145.GA2666@blaptop>
 <5107760ca0614_5bf811b9fe4132b@golgotha.mail>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5107760ca0614_5bf811b9fe4132b@golgotha.mail>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, stable@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>

On Tue, Jan 29, 2013 at 09:11:08AM +0200, Pekka Enberg wrote:
> On Tue, Jan 29, 2013 at 1:21 AM, Minchan Kim <minchan@kernel.org> wrote:
> > How about this?
> > ------------------------- >8 -------------------------------
> > 
> > From 9f8756ae0b0f2819f93cb94dcd38da372843aa12 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Mon, 21 Jan 2013 13:58:52 +0900
> > Subject: [RESEND PATCH v5 1/4] zram: Fix deadlock bug in partial read/write
> > 
> > Now zram allocates new page with GFP_KERNEL in zram I/O path
> > if IO is partial. Unfortunately, It may cause deadlock with
> > reclaim path like below.
> > 
> > write_page from fs
> > fs_lock
> > allocation(GFP_KERNEL)
> > reclaim
> > pageout
> > 				write_page from fs
> > 				fs_lock <-- deadlock
> > 
> > This patch fixes it by using GFP_ATOMIC and GFP_NOIO.
> > In read path, we called kmap_atomic so that we need GFP_ATOMIC
> > while we need GFP_NOIO in write path.
> 
> The patch description makes sense now. Thanks!
> 
> On Tue, Jan 29, 2013 at 1:21 AM, Minchan Kim <minchan@kernel.org> wrote:
> > We could use GFP_IO instead of GFP_ATOMIC in zram_bvec_read with
> > some modification related to buffer allocation in case of partial IO.
> > But it needs more churn and prevent merge this patch into stable
> > if we should send this to stable so I'd like to keep it as simple
> > as possbile. GFP_IO usage could be separate patch after we merge it.
> 
> I don't see why something like below couldn't be merged for stable.
> Going for GFP_ATOMIC might seem like the simplest thing to go for but
> usually bites you in the end.

Looks good to me. I will resend it.
Thanks, Pekka.

> 
> 			Pekka
> 
> ------------------------- >8 -------------------------------
> 
> >From 936a12b423c58542628d6fd683e859f752eb3d41 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Mon, 21 Jan 2013 13:58:52 +0900
> Subject: [PATCH] zram: Fix deadlock bug in partial read/write
> 
> Now zram allocates new page with GFP_KERNEL in zram I/O path
> if IO is partial. Unfortunately, It may cause deadlock with
> reclaim path like below.
> 
> write_page from fs
> fs_lock
> allocation(GFP_KERNEL)
> reclaim
> pageout
> 				write_page from fs
> 				fs_lock <-- deadlock
> 
> This patch fixes it by using GFP_NOIO.  In read path, we
> reorganize code flow so that kmap_atomic is called after the
> GFP_NOIO allocation.
> 
> Cc: stable@vger.kernel.org
> Cc: Jerome Marchand <jmarchan@redhat.com>
> Acked-by: Nitin Gupta <ngupta@vflare.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> [ penberg@kernel.org: don't use GFP_ATOMIC ]
> Signed-off-by: Pekka Enberg <penberg@kernel.org>
> ---
>  drivers/staging/zram/zram_drv.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> index f2a73bd..071e058 100644
> --- a/drivers/staging/zram/zram_drv.c
> +++ b/drivers/staging/zram/zram_drv.c
> @@ -228,11 +228,12 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
>  		return 0;
>  	}
>  
> -	user_mem = kmap_atomic(page);
>  	if (is_partial_io(bvec))
>  		/* Use  a temporary buffer to decompress the page */
> -		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
> -	else
> +		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
> +
> +	user_mem = kmap_atomic(page);
> +	if (!is_partial_io(bvec))
>  		uncmem = user_mem;
>  
>  	if (!uncmem) {
> @@ -279,7 +280,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  		 * This is a partial IO. We need to read the full page
>  		 * before to write the changes.
>  		 */
> -		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
>  		if (!uncmem) {
>  			pr_info("Error allocating temp memory!\n");
>  			ret = -ENOMEM;
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
