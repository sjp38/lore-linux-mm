Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8750E6B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 22:08:57 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so10749611pdb.5
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 19:08:56 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id sl2si29558260pac.75.2014.08.19.19.08.54
        for <linux-mm@kvack.org>;
        Tue, 19 Aug 2014 19:08:56 -0700 (PDT)
Date: Wed, 20 Aug 2014 11:09:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: add num_discards for discarded pages stat
Message-ID: <20140820020924.GD32620@bbox>
References: <001201cfb838$fb0ac4a0$f1204de0$@samsung.com>
 <20140815061138.GA940@swordfish>
 <002d01cfbb70$ea7410c0$bf5c3240$@samsung.com>
 <20140819112500.GA2484@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140819112500.GA2484@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Chao Yu <chao2.yu@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, 'Jerome Marchand' <jmarchan@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>

Hi Sergey,

On Tue, Aug 19, 2014 at 08:25:00PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (08/19/14 13:45), Chao Yu wrote:
> > > On (08/15/14 11:27), Chao Yu wrote:
> > > > Now we have supported handling discard request which is sended by filesystem,
> > > > but no interface could be used to show information of discard.
> > > > This patch adds num_discards to stat discarded pages, then export it to sysfs
> > > > for displaying.
> > > >
> > > 
> > > a side question: we account discarded pages via slot free notify in
> > > notify_free and via req_discard in num_discards. how about accounting
> > > both of them in num_discards? because, after all, they account a number
> > > of discarded pages (zram_free_page()). or there any particular reason we
> > > want to distinguish.
> > 
> > Yeah, I agree with you as I have no such reason unless there are our users'
> > explicitly requirement for showing notify_free/num_discards separately later.
> > 
> > How do you think of sending another patch to merge these two counts?
> > 
> 
> Minchan, what do you think? let's account discarded pages in one place.

First of all, I'd like to know why we need num_discards.
It should be in description and depends on it whether we should merge both
counts or separate.

Thanks.



> 
> > One more thing is that I am missing to update document of zram, sorry about
> > that, let me update it in v2.
> 
> thanks.
> 
> 	-ss
> 
> > Thanks,
> > Yu
> > 
> > > 
> > > 	-ss
> > > 
> > > > Signed-off-by: Chao Yu <chao2.yu@samsung.com>
> > > > ---
> > > >  Documentation/ABI/testing/sysfs-block-zram | 10 ++++++++++
> > > >  drivers/block/zram/zram_drv.c              |  3 +++
> > > >  drivers/block/zram/zram_drv.h              |  1 +
> > > >  3 files changed, 14 insertions(+)
> > > >
> > > > diff --git a/Documentation/ABI/testing/sysfs-block-zram
> > > b/Documentation/ABI/testing/sysfs-block-zram
> > > > index 70ec992..fa8936e 100644
> > > > --- a/Documentation/ABI/testing/sysfs-block-zram
> > > > +++ b/Documentation/ABI/testing/sysfs-block-zram
> > > > @@ -57,6 +57,16 @@ Description:
> > > >  		The failed_writes file is read-only and specifies the number of
> > > >  		failed writes happened on this device.
> > > >
> > > > +
> > > > +What:		/sys/block/zram<id>/num_discards
> > > > +Date:		August 2014
> > > > +Contact:	Chao Yu <chao2.yu@samsung.com>
> > > > +Description:
> > > > +		The num_discards file is read-only and specifies the number of
> > > > +		physical blocks which are discarded by this device. These blocks
> > > > +		are included in discard request which is sended by filesystem as
> > > > +		the blocks are no longer used.
> > > > +
> > > >  What:		/sys/block/zram<id>/max_comp_streams
> > > >  Date:		February 2014
> > > >  Contact:	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > > > index d00831c..904e7a5 100644
> > > > --- a/drivers/block/zram/zram_drv.c
> > > > +++ b/drivers/block/zram/zram_drv.c
> > > > @@ -606,6 +606,7 @@ static void zram_bio_discard(struct zram *zram, u32 index,
> > > >  		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
> > > >  		zram_free_page(zram, index);
> > > >  		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
> > > > +		atomic64_inc(&zram->stats.num_discards);
> > > >  		index++;
> > > >  		n -= PAGE_SIZE;
> > > >  	}
> > > > @@ -866,6 +867,7 @@ ZRAM_ATTR_RO(num_reads);
> > > >  ZRAM_ATTR_RO(num_writes);
> > > >  ZRAM_ATTR_RO(failed_reads);
> > > >  ZRAM_ATTR_RO(failed_writes);
> > > > +ZRAM_ATTR_RO(num_discards);
> > > >  ZRAM_ATTR_RO(invalid_io);
> > > >  ZRAM_ATTR_RO(notify_free);
> > > >  ZRAM_ATTR_RO(zero_pages);
> > > > @@ -879,6 +881,7 @@ static struct attribute *zram_disk_attrs[] = {
> > > >  	&dev_attr_num_writes.attr,
> > > >  	&dev_attr_failed_reads.attr,
> > > >  	&dev_attr_failed_writes.attr,
> > > > +	&dev_attr_num_discards.attr,
> > > >  	&dev_attr_invalid_io.attr,
> > > >  	&dev_attr_notify_free.attr,
> > > >  	&dev_attr_zero_pages.attr,
> > > > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> > > > index e0f725c..2994aaf 100644
> > > > --- a/drivers/block/zram/zram_drv.h
> > > > +++ b/drivers/block/zram/zram_drv.h
> > > > @@ -86,6 +86,7 @@ struct zram_stats {
> > > >  	atomic64_t num_writes;	/* --do-- */
> > > >  	atomic64_t failed_reads;	/* can happen when memory is too low */
> > > >  	atomic64_t failed_writes;	/* can happen when memory is too low */
> > > > +	atomic64_t num_discards;	/* no. of discarded pages */
> > > >  	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
> > > >  	atomic64_t notify_free;	/* no. of swap slot free notifications */
> > > >  	atomic64_t zero_pages;		/* no. of zero filled pages */
> > > > --
> > > > 2.0.1.474.g72c7794
> > > >
> > > >
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
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
