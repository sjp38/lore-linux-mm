From: Rudmer van Dijk <rudmer@legolas.dynup.net>
Subject: Re: 2.5.69-mm7
Date: Mon, 19 May 2003 15:19:38 +0200
References: <20030519012336.44d0083a.akpm@digeo.com> <200305191230.06092.rudmer@legolas.dynup.net> <20030519103826.GC8978@holomorphy.com>
In-Reply-To: <20030519103826.GC8978@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200305191519.39085.rudmer@legolas.dynup.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 19 May 2003 12:38, William Lee Irwin III wrote:
> On Mon, May 19, 2003 at 12:30:05PM +0200, Rudmer van Dijk wrote:
> > and this became broken:
> > if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.69-mm7; fi
> > WARNING: /lib/modules/2.5.69-mm7/kernel/fs/ext2/ext2.ko needs unknown
> > symbol __bread_wq
> > __bread_wq is introduced in -mm7, someone forgot to export it?
>
> Try this patch please.

it works! 
thanks,

	Rudmer

>
> -- wli
>
>
> diff -prauN mm7-2.5.69-1/fs/buffer.c mm7-2.5.69-2A/fs/buffer.c
> --- mm7-2.5.69-1/fs/buffer.c	2003-05-19 01:18:03.000000000 -0700
> +++ mm7-2.5.69-2A/fs/buffer.c	2003-05-19 03:14:27.000000000 -0700
> @@ -1490,6 +1490,7 @@ __bread(struct block_device *bdev, secto
>  		bh = __bread_slow(bh);
>  	return bh;
>  }
> +EXPORT_SYMBOL(__bread);
>
>
>  struct buffer_head *
> @@ -1502,7 +1503,7 @@ __bread_wq(struct block_device *bdev, se
>  		bh = __bread_slow_wq(bh, wait);
>  	return bh;
>  }
> -EXPORT_SYMBOL(__bread);
> +EXPORT_SYMBOL(__bread_wq);
>
>  /*
>   * invalidate_bh_lrus() is called rarely - at unmount.  Because it is only
> for diff -prauN mm7-2.5.69-1/kernel/ksyms.c mm7-2.5.69-2A/kernel/ksyms.c
> --- mm7-2.5.69-1/kernel/ksyms.c	2003-05-19 01:18:08.000000000 -0700 +++
> mm7-2.5.69-2A/kernel/ksyms.c	2003-05-19 03:17:20.000000000 -0700 @@ -123,6
> +123,7 @@ EXPORT_SYMBOL(get_unmapped_area);
>  EXPORT_SYMBOL(init_mm);
>  EXPORT_SYMBOL(blk_queue_bounce);
>  EXPORT_SYMBOL(blk_congestion_wait);
> +EXPORT_SYMBOL(blk_congestion_wait_wq);
>  #ifdef CONFIG_HIGHMEM
>  EXPORT_SYMBOL(kmap_high);
>  EXPORT_SYMBOL(kunmap_high);
> @@ -216,6 +217,7 @@ EXPORT_SYMBOL(sync_dirty_buffer);
>  EXPORT_SYMBOL(submit_bh);
>  EXPORT_SYMBOL(unlock_buffer);
>  EXPORT_SYMBOL(__wait_on_buffer);
> +EXPORT_SYMBOL(__wait_on_buffer_wq);
>  EXPORT_SYMBOL(blockdev_direct_IO);
>  EXPORT_SYMBOL(block_write_full_page);
>  EXPORT_SYMBOL(block_read_full_page);
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
