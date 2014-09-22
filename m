Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7396B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 16:41:12 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lj1so4738800pab.4
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:41:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qo10si17338411pac.133.2014.09.22.13.41.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 13:41:11 -0700 (PDT)
Date: Mon, 22 Sep 2014 13:41:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 1/5] zram: generalize swap_slot_free_notify
Message-Id: <20140922134109.f61195768841a3b300e6b81e@linux-foundation.org>
In-Reply-To: <1411344191-2842-2-git-send-email-minchan@kernel.org>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
	<1411344191-2842-2-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Mon, 22 Sep 2014 09:03:07 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Currently, swap_slot_free_notify is used for zram to free
> duplicated copy page for memory efficiency when it knows
> there is no reference to the swap slot.
> 
> This patch generalizes it to be able to use for other
> swap hint to communicate with VM.
> 

I really think we need to do a better job of documenting the code.

> index 94d93b1f8b53..c262bfbeafa9 100644
> --- a/Documentation/filesystems/Locking
> +++ b/Documentation/filesystems/Locking
> @@ -405,7 +405,7 @@ prototypes:
>  	void (*unlock_native_capacity) (struct gendisk *);
>  	int (*revalidate_disk) (struct gendisk *);
>  	int (*getgeo)(struct block_device *, struct hd_geometry *);
> -	void (*swap_slot_free_notify) (struct block_device *, unsigned long);
> +	int (*swap_hint) (struct block_device *, unsigned int, void *);
>  
>  locking rules:
>  			bd_mutex
> @@ -418,7 +418,7 @@ media_changed:		no
>  unlock_native_capacity:	no
>  revalidate_disk:	no
>  getgeo:			no
> -swap_slot_free_notify:	no	(see below)
> +swap_hint:		no	(see below)

This didn't tell anyone anythnig much.

> index d78b245bae06..22a37764c409 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -926,7 +926,8 @@ error:
>  	bio_io_error(bio);
>  }
>  
> -static void zram_slot_free_notify(struct block_device *bdev,
> +/* this callback is with swap_lock and sometimes page table lock held */

OK, that was useful.

It's called "page_table_lock".

Also *which* page_table_lock?  current->mm?

> +static int zram_slot_free_notify(struct block_device *bdev,
>  				unsigned long index)
>  {
>  	struct zram *zram;
>
> ...
>
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -1609,6 +1609,10 @@ static inline bool blk_integrity_is_initialized(struct gendisk *g)
>  
>  #endif /* CONFIG_BLK_DEV_INTEGRITY */
>  
> +enum swap_blk_hint {
> +	SWAP_FREE,
> +};

This would be a great place to document SWAP_FREE.

>  struct block_device_operations {
>  	int (*open) (struct block_device *, fmode_t);
>  	void (*release) (struct gendisk *, fmode_t);
> @@ -1624,8 +1628,7 @@ struct block_device_operations {
>  	void (*unlock_native_capacity) (struct gendisk *);
>  	int (*revalidate_disk) (struct gendisk *);
>  	int (*getgeo)(struct block_device *, struct hd_geometry *);
> -	/* this callback is with swap_lock and sometimes page table lock held */
> -	void (*swap_slot_free_notify) (struct block_device *, unsigned long);
> +	int (*swap_hint)(struct block_device *, unsigned int, void *);

And this would be a suitable place to document ->swap_hint().

- Hint from who to who?  Is it the caller providing the callee a hint
  or is the caller asking the callee for a hint?

- What is the meaning of the return value?

- What are the meaning of the arguments?

Please don't omit the argument names like this.  They are useful!  How
is a reader to know what that "unsigned int" and "void *" actually
*do*?

The second arg-which-doesn't-have-a-name should have had type
swap_blk_hint, yes?

swap_blk_hint should be called swap_block_hint.  I assume that's what
"blk" means.  Why does the name have "block" in there anyway?  It has
something to do with disk blocks?  How is anyone supposed to work that
out?

->swap_hint was converted to return an `int', but all the callers
simply ignore the return value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
