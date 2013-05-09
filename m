Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 536E96B0033
	for <linux-mm@kvack.org>; Thu,  9 May 2013 16:15:46 -0400 (EDT)
Received: by mail-ve0-f172.google.com with SMTP id b10so3224352vea.31
        for <linux-mm@kvack.org>; Thu, 09 May 2013 13:15:45 -0700 (PDT)
Date: Thu, 9 May 2013 16:15:42 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH v3] mm: remove compressed copy from zram in-memory
Message-ID: <20130509201540.GB5273@localhost.localdomain>
References: <1368056517-31065-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368056517-31065-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Shaohua Li <shli@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>

On Thu, May 09, 2013 at 08:41:57AM +0900, Minchan Kim wrote:

Hey Michan,
Just a couple of syntax corrections. The code comment could also
benefit from this.

Otherwise it looks OK to me.

> Swap subsystem does lazy swap slot free with expecting the page
                     ^-a                       ^- the expectation that
> would be swapped out again so we can avoid unnecessary write.
                                ^--that it
> 
> But the problem in in-memory swap(ex, zram) is that it consumes
                  ^^-with
> memory space until vm_swap_full(ie, used half of all of swap device)
> condition meet. It could be bad if we use multiple swap device,
           ^- 'is'   ^^^^^ - 'would'                       ^^^^^-devices                    
> small in-memory swap and big storage swap or in-memory swap alone.
                      ^-,                   ^-,
> 
> This patch makes swap subsystem free swap slot as soon as swap-read
> is completed and make the swapcache page dirty so the page should
                       ^-makes                      ^-'that the'
> be written out the swap device to reclaim it.
> It means we never lose it.
> 
> I tested this patch with kernel compile workload.
                          ^-a
> 
> 1. before
> 
> compile time : 9882.42
> zram max wasted space by fragmentation: 13471881 byte
> memory space consumed by zram: 174227456 byte
> the number of slot free notify: 206684
> 
> 2. after
> 
> compile time : 9653.90
> zram max wasted space by fragmentation: 11805932 byte
> memory space consumed by zram: 154001408 byte
> the number of slot free notify: 426972
> 
> * changelog from v3
>   * Rebased on next-20130508
> 
> * changelog from v1
>   * Add more comment
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>
> Cc: Shaohua Li <shli@kernel.org>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/page_io.c | 35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index a294076..527db57 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -21,6 +21,7 @@
>  #include <linux/writeback.h>
>  #include <linux/frontswap.h>
>  #include <linux/aio.h>
> +#include <linux/blkdev.h>
>  #include <asm/pgtable.h>
>  
>  static struct bio *get_swap_bio(gfp_t gfp_flags,
> @@ -82,8 +83,42 @@ void end_swap_bio_read(struct bio *bio, int err, struct batch_complete *batch)
>  				iminor(bio->bi_bdev->bd_inode),
>  				(unsigned long long)bio->bi_sector);
>  	} else {
> +		struct swap_info_struct *sis;
> +
>  		SetPageUptodate(page);
> +		sis = page_swap_info(page);
> +		if (sis->flags & SWP_BLKDEV) {
> +			/*
> +			 * Swap subsystem does lazy swap slot free with
> +			 * expecting the page would be swapped out again
> +			 * so we can avoid unnecessary write if the page
> +			 * isn't redirty.
> +			 * It's good for real swap storage  because we can
> +			 * reduce unnecessary I/O and enhance wear-leveling
> +			 * if you use SSD as swap device.
> +			 * But if you use in-memory swap device(ex, zram),
> +			 * it causes duplicated copy between uncompressed
> +			 * data in VM-owned memory and compressed data in
> +			 * zram-owned memory. So let's free zram-owned memory
> +			 * and make the VM-owned decompressed page *dirty*
> +			 * so the page should be swap out somewhere again if
> +			 * we want to reclaim it, again.
> +			 */
> +			struct gendisk *disk = sis->bdev->bd_disk;
> +			if (disk->fops->swap_slot_free_notify) {
> +				swp_entry_t entry;
> +				unsigned long offset;
> +
> +				entry.val = page_private(page);
> +				offset = swp_offset(entry);
> +
> +				SetPageDirty(page);
> +				disk->fops->swap_slot_free_notify(sis->bdev,
> +						offset);
> +			}
> +		}
>  	}
> +
>  	unlock_page(page);
>  	bio_put(bio);
>  }
> -- 
> 1.8.2.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
