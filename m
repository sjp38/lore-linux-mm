Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A8FDC6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 00:44:38 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id r10so5718387pdi.39
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 21:44:38 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id fe3si18434456pdb.183.2014.09.22.21.44.36
        for <linux-mm@kvack.org>;
        Mon, 22 Sep 2014 21:44:37 -0700 (PDT)
Date: Tue, 23 Sep 2014 13:45:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 1/5] zram: generalize swap_slot_free_notify
Message-ID: <20140923044512.GA8325@bbox>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
 <1411344191-2842-2-git-send-email-minchan@kernel.org>
 <20140922134109.f61195768841a3b300e6b81e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140922134109.f61195768841a3b300e6b81e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

Hi Andrew,

On Mon, Sep 22, 2014 at 01:41:09PM -0700, Andrew Morton wrote:
> On Mon, 22 Sep 2014 09:03:07 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Currently, swap_slot_free_notify is used for zram to free
> > duplicated copy page for memory efficiency when it knows
> > there is no reference to the swap slot.
> > 
> > This patch generalizes it to be able to use for other
> > swap hint to communicate with VM.
> > 
> 
> I really think we need to do a better job of documenting the code.
> 
> > index 94d93b1f8b53..c262bfbeafa9 100644
> > --- a/Documentation/filesystems/Locking
> > +++ b/Documentation/filesystems/Locking
> > @@ -405,7 +405,7 @@ prototypes:
> >  	void (*unlock_native_capacity) (struct gendisk *);
> >  	int (*revalidate_disk) (struct gendisk *);
> >  	int (*getgeo)(struct block_device *, struct hd_geometry *);
> > -	void (*swap_slot_free_notify) (struct block_device *, unsigned long);
> > +	int (*swap_hint) (struct block_device *, unsigned int, void *);
> >  
> >  locking rules:
> >  			bd_mutex
> > @@ -418,7 +418,7 @@ media_changed:		no
> >  unlock_native_capacity:	no
> >  revalidate_disk:	no
> >  getgeo:			no
> > -swap_slot_free_notify:	no	(see below)
> > +swap_hint:		no	(see below)
> 
> This didn't tell anyone anythnig much.

Yeb. :(

> 
> > index d78b245bae06..22a37764c409 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -926,7 +926,8 @@ error:
> >  	bio_io_error(bio);
> >  }
> >  
> > -static void zram_slot_free_notify(struct block_device *bdev,
> > +/* this callback is with swap_lock and sometimes page table lock held */
> 
> OK, that was useful.
> 
> It's called "page_table_lock".
> 
> Also *which* page_table_lock?  current->mm?

It depends on ALLOC_SPLIT_PTLOCKS so it could be page->ptl, too.
So, it would be better to call it as *ptlock*?
Since it's ptlock, it isn't related to which mm struct.
What we should make sure is just ptlock which belong to the page
table pointed to this swap page.

So, I want this.

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index c262bfbeafa9..19d2726e34f4 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -423,8 +423,8 @@ swap_hint:		no	(see below)
 media_changed, unlock_native_capacity and revalidate_disk are called only from
 check_disk_change().
 
-swap_slot_free_notify is called with swap_lock and sometimes the page lock
-held.
+swap_hint is called with swap_info_struct->lock and sometimes the ptlock
+of the page table pointed to the swap page.
 
 
 --------------------------- file_operations -------------------------------

> 
> > +static int zram_slot_free_notify(struct block_device *bdev,
> >  				unsigned long index)
> >  {
> >  	struct zram *zram;
> >
> > ...
> >
> > --- a/include/linux/blkdev.h
> > +++ b/include/linux/blkdev.h
> > @@ -1609,6 +1609,10 @@ static inline bool blk_integrity_is_initialized(struct gendisk *g)
> >  
> >  #endif /* CONFIG_BLK_DEV_INTEGRITY */
> >  
> > +enum swap_blk_hint {
> > +	SWAP_FREE,
> > +};
> 
> This would be a great place to document SWAP_FREE.

Yes,

> 
> >  struct block_device_operations {
> >  	int (*open) (struct block_device *, fmode_t);
> >  	void (*release) (struct gendisk *, fmode_t);
> > @@ -1624,8 +1628,7 @@ struct block_device_operations {
> >  	void (*unlock_native_capacity) (struct gendisk *);
> >  	int (*revalidate_disk) (struct gendisk *);
> >  	int (*getgeo)(struct block_device *, struct hd_geometry *);
> > -	/* this callback is with swap_lock and sometimes page table lock held */
> > -	void (*swap_slot_free_notify) (struct block_device *, unsigned long);
> > +	int (*swap_hint)(struct block_device *, unsigned int, void *);
> 
> And this would be a suitable place to document ->swap_hint().

If we consider to be able to add more hints in future so it could
be verbose, IMO, it would be better to desribe it in enum swap_hint. :)

> 
> - Hint from who to who?  Is it the caller providing the callee a hint
>   or is the caller asking the callee for a hint?
> 
> - What is the meaning of the return value?
> 
> - What are the meaning of the arguments?

Okay.

> 
> Please don't omit the argument names like this.  They are useful!  How
> is a reader to know what that "unsigned int" and "void *" actually
> *do*?

Yes.

> 
> The second arg-which-doesn't-have-a-name should have had type
> swap_blk_hint, yes?

Yes.

> 
> swap_blk_hint should be called swap_block_hint.  I assume that's what
> "blk" means.  Why does the name have "block" in there anyway?  It has
> something to do with disk blocks?  How is anyone supposed to work that
> out?

Yeb, I think we don't need block in name. I will remove it.

> 
> ->swap_hint was converted to return an `int', but all the callers
> simply ignore the return value.

You're right. All caller doesn't use it in this patch but this patch
makes it generalize and in later patch, SWAP_FULL will use it so
I want to make return as int. One more thought, SWAP_FULL could use
void * as output param so we could remove return value, finally.
I will consider it, too.

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
