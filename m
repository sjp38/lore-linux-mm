Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 8CD516B0010
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 18:50:02 -0500 (EST)
Date: Mon, 4 Feb 2013 08:50:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 1/4] zram: Fix deadlock bug in partial read/write
Message-ID: <20130203235000.GA2688@blaptop>
References: <1359935171-12749-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359935171-12749-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, jmarchan@redhat.com, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Pekka Enberg <penberg@kernel.org>

Hi Greg,

I added all Acked-by and rebased on next-20130202.
Please apply this.

On Mon, Feb 04, 2013 at 08:46:08AM +0900, Minchan Kim wrote:
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
> Acked-by: Jerome Marchand <jmarchan@redhat.com>
> Acked-by: Nitin Gupta <ngupta@vflare.org>
> [ penberg@kernel.org: don't use GFP_ATOMIC ]
> Signed-off-by: Pekka Enberg <penberg@kernel.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zram/zram_drv.c |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> index 941b7c6..262265e 100644
> --- a/drivers/staging/zram/zram_drv.c
> +++ b/drivers/staging/zram/zram_drv.c
> @@ -217,11 +217,12 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
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
> @@ -268,7 +269,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  		 * This is a partial IO. We need to read the full page
>  		 * before to write the changes.
>  		 */
> -		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
>  		if (!uncmem) {
>  			pr_info("Error allocating temp memory!\n");
>  			ret = -ENOMEM;
> -- 
> 1.7.9.5
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
