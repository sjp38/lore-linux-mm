Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7C86B0036
	for <linux-mm@kvack.org>; Fri, 15 Aug 2014 02:12:41 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so2837077pdb.5
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 23:12:41 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id gj11si6797096pbd.171.2014.08.14.23.12.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 23:12:40 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so2960838pad.36
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 23:12:38 -0700 (PDT)
Date: Fri, 15 Aug 2014 15:11:38 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] zram: add num_discards for discarded pages stat
Message-ID: <20140815061138.GA940@swordfish>
References: <001201cfb838$fb0ac4a0$f1204de0$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001201cfb838$fb0ac4a0$f1204de0$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chao Yu <chao2.yu@samsung.com>
Cc: minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, 'Jerome Marchand' <jmarchan@redhat.com>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Andrew Morton' <akpm@linux-foundation.org>

On (08/15/14 11:27), Chao Yu wrote:
> Now we have supported handling discard request which is sended by filesystem,
> but no interface could be used to show information of discard.
> This patch adds num_discards to stat discarded pages, then export it to sysfs
> for displaying.
> 

a side question: we account discarded pages via slot free notify in
notify_free and via req_discard in num_discards. how about accounting
both of them in num_discards? because, after all, they account a number
of discarded pages (zram_free_page()). or there any particular reason we
want to distinguish.

	-ss

> Signed-off-by: Chao Yu <chao2.yu@samsung.com>
> ---
>  Documentation/ABI/testing/sysfs-block-zram | 10 ++++++++++
>  drivers/block/zram/zram_drv.c              |  3 +++
>  drivers/block/zram/zram_drv.h              |  1 +
>  3 files changed, 14 insertions(+)
> 
> diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
> index 70ec992..fa8936e 100644
> --- a/Documentation/ABI/testing/sysfs-block-zram
> +++ b/Documentation/ABI/testing/sysfs-block-zram
> @@ -57,6 +57,16 @@ Description:
>  		The failed_writes file is read-only and specifies the number of
>  		failed writes happened on this device.
>  
> +
> +What:		/sys/block/zram<id>/num_discards
> +Date:		August 2014
> +Contact:	Chao Yu <chao2.yu@samsung.com>
> +Description:
> +		The num_discards file is read-only and specifies the number of
> +		physical blocks which are discarded by this device. These blocks
> +		are included in discard request which is sended by filesystem as
> +		the blocks are no longer used.
> +
>  What:		/sys/block/zram<id>/max_comp_streams
>  Date:		February 2014
>  Contact:	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index d00831c..904e7a5 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -606,6 +606,7 @@ static void zram_bio_discard(struct zram *zram, u32 index,
>  		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  		zram_free_page(zram, index);
>  		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
> +		atomic64_inc(&zram->stats.num_discards);
>  		index++;
>  		n -= PAGE_SIZE;
>  	}
> @@ -866,6 +867,7 @@ ZRAM_ATTR_RO(num_reads);
>  ZRAM_ATTR_RO(num_writes);
>  ZRAM_ATTR_RO(failed_reads);
>  ZRAM_ATTR_RO(failed_writes);
> +ZRAM_ATTR_RO(num_discards);
>  ZRAM_ATTR_RO(invalid_io);
>  ZRAM_ATTR_RO(notify_free);
>  ZRAM_ATTR_RO(zero_pages);
> @@ -879,6 +881,7 @@ static struct attribute *zram_disk_attrs[] = {
>  	&dev_attr_num_writes.attr,
>  	&dev_attr_failed_reads.attr,
>  	&dev_attr_failed_writes.attr,
> +	&dev_attr_num_discards.attr,
>  	&dev_attr_invalid_io.attr,
>  	&dev_attr_notify_free.attr,
>  	&dev_attr_zero_pages.attr,
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index e0f725c..2994aaf 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -86,6 +86,7 @@ struct zram_stats {
>  	atomic64_t num_writes;	/* --do-- */
>  	atomic64_t failed_reads;	/* can happen when memory is too low */
>  	atomic64_t failed_writes;	/* can happen when memory is too low */
> +	atomic64_t num_discards;	/* no. of discarded pages */
>  	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
>  	atomic64_t notify_free;	/* no. of swap slot free notifications */
>  	atomic64_t zero_pages;		/* no. of zero filled pages */
> -- 
> 2.0.1.474.g72c7794
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
