Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 74A536B0006
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 04:47:55 -0500 (EST)
Message-ID: <50FE6025.2080609@redhat.com>
Date: Tue, 22 Jan 2013 10:47:17 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/4] zram: Fix deadlock bug in partial write
References: <1358813253-20913-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1358813253-20913-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 01/22/2013 01:07 AM, Minchan Kim wrote:
> Now zram allocates new page with GFP_KERNEL in zram I/O path
> if IO is partial. Unfortunately, It may cuase deadlock with
> reclaim path so this patch solves the problem.
> 
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Jerome Marchand <jmarchan@redhat.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> 
> We could use GFP_IO instead of GFP_ATOMIC in zram_bvec_read with
> some modification related to buffer allocation in case of partial IO.
> But it needs more churn and prevent merge this patch into stable
> if we should send this to stable so I'd like to keep it as simple
> as possbile. GFP_IO usage could be separate patch after we merge it.
> Thanks.

I'd rather have a preallocated buffer for that. It would make
zram_bvec_read/write() simpler (no need to deal with an allocation
failure or to free the buffer) and it would be consistent with the way
other similar buffer works (compress_workmem/buffer).

Jerome

> 
>  drivers/staging/zram/zram_drv.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> index 61fb8f1..b285b3a 100644
> --- a/drivers/staging/zram/zram_drv.c
> +++ b/drivers/staging/zram/zram_drv.c
> @@ -220,7 +220,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
>  	user_mem = kmap_atomic(page);
>  	if (is_partial_io(bvec))
>  		/* Use  a temporary buffer to decompress the page */
> -		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +		uncmem = kmalloc(PAGE_SIZE, GFP_ATOMIC);
>  	else
>  		uncmem = user_mem;
>  
> @@ -268,7 +268,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  		 * This is a partial IO. We need to read the full page
>  		 * before to write the changes.
>  		 */
> -		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
>  		if (!uncmem) {
>  			pr_info("Error allocating temp memory!\n");
>  			ret = -ENOMEM;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
