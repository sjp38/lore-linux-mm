Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3718C6B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 01:46:31 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so8775440pdi.20
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 22:46:30 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id gl10si25064283pbd.139.2014.08.18.22.46.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 18 Aug 2014 22:46:30 -0700 (PDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAJ000SNHDEBU60@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 19 Aug 2014 14:46:26 +0900 (KST)
From: Chao Yu <chao2.yu@samsung.com>
References: <001201cfb838$fb0ac4a0$f1204de0$@samsung.com>
 <20140815061138.GA940@swordfish>
In-reply-to: <20140815061138.GA940@swordfish>
Subject: RE: [PATCH] zram: add num_discards for discarded pages stat
Date: Tue, 19 Aug 2014 13:45:25 +0800
Message-id: <002d01cfbb70$ea7410c0$bf5c3240$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>
Cc: minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, 'Jerome Marchand' <jmarchan@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>

> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behalf Of Sergey
> Senozhatsky
> Sent: Friday, August 15, 2014 2:12 PM
> To: Chao Yu
> Cc: minchan@kernel.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org; ngupta@vflare.org;
> 'Jerome Marchand'; 'Sergey Senozhatsky'; 'Andrew Morton'
> Subject: Re: [PATCH] zram: add num_discards for discarded pages stat
> 
> On (08/15/14 11:27), Chao Yu wrote:
> > Now we have supported handling discard request which is sended by filesystem,
> > but no interface could be used to show information of discard.
> > This patch adds num_discards to stat discarded pages, then export it to sysfs
> > for displaying.
> >
> 
> a side question: we account discarded pages via slot free notify in
> notify_free and via req_discard in num_discards. how about accounting
> both of them in num_discards? because, after all, they account a number
> of discarded pages (zram_free_page()). or there any particular reason we
> want to distinguish.

Yeah, I agree with you as I have no such reason unless there are our users'
explicitly requirement for showing notify_free/num_discards separately later.

How do you think of sending another patch to merge these two counts?

One more thing is that I am missing to update document of zram, sorry about
that, let me update it in v2.

Thanks,
Yu

> 
> 	-ss
> 
> > Signed-off-by: Chao Yu <chao2.yu@samsung.com>
> > ---
> >  Documentation/ABI/testing/sysfs-block-zram | 10 ++++++++++
> >  drivers/block/zram/zram_drv.c              |  3 +++
> >  drivers/block/zram/zram_drv.h              |  1 +
> >  3 files changed, 14 insertions(+)
> >
> > diff --git a/Documentation/ABI/testing/sysfs-block-zram
> b/Documentation/ABI/testing/sysfs-block-zram
> > index 70ec992..fa8936e 100644
> > --- a/Documentation/ABI/testing/sysfs-block-zram
> > +++ b/Documentation/ABI/testing/sysfs-block-zram
> > @@ -57,6 +57,16 @@ Description:
> >  		The failed_writes file is read-only and specifies the number of
> >  		failed writes happened on this device.
> >
> > +
> > +What:		/sys/block/zram<id>/num_discards
> > +Date:		August 2014
> > +Contact:	Chao Yu <chao2.yu@samsung.com>
> > +Description:
> > +		The num_discards file is read-only and specifies the number of
> > +		physical blocks which are discarded by this device. These blocks
> > +		are included in discard request which is sended by filesystem as
> > +		the blocks are no longer used.
> > +
> >  What:		/sys/block/zram<id>/max_comp_streams
> >  Date:		February 2014
> >  Contact:	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index d00831c..904e7a5 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -606,6 +606,7 @@ static void zram_bio_discard(struct zram *zram, u32 index,
> >  		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
> >  		zram_free_page(zram, index);
> >  		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
> > +		atomic64_inc(&zram->stats.num_discards);
> >  		index++;
> >  		n -= PAGE_SIZE;
> >  	}
> > @@ -866,6 +867,7 @@ ZRAM_ATTR_RO(num_reads);
> >  ZRAM_ATTR_RO(num_writes);
> >  ZRAM_ATTR_RO(failed_reads);
> >  ZRAM_ATTR_RO(failed_writes);
> > +ZRAM_ATTR_RO(num_discards);
> >  ZRAM_ATTR_RO(invalid_io);
> >  ZRAM_ATTR_RO(notify_free);
> >  ZRAM_ATTR_RO(zero_pages);
> > @@ -879,6 +881,7 @@ static struct attribute *zram_disk_attrs[] = {
> >  	&dev_attr_num_writes.attr,
> >  	&dev_attr_failed_reads.attr,
> >  	&dev_attr_failed_writes.attr,
> > +	&dev_attr_num_discards.attr,
> >  	&dev_attr_invalid_io.attr,
> >  	&dev_attr_notify_free.attr,
> >  	&dev_attr_zero_pages.attr,
> > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> > index e0f725c..2994aaf 100644
> > --- a/drivers/block/zram/zram_drv.h
> > +++ b/drivers/block/zram/zram_drv.h
> > @@ -86,6 +86,7 @@ struct zram_stats {
> >  	atomic64_t num_writes;	/* --do-- */
> >  	atomic64_t failed_reads;	/* can happen when memory is too low */
> >  	atomic64_t failed_writes;	/* can happen when memory is too low */
> > +	atomic64_t num_discards;	/* no. of discarded pages */
> >  	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
> >  	atomic64_t notify_free;	/* no. of swap slot free notifications */
> >  	atomic64_t zero_pages;		/* no. of zero filled pages */
> > --
> > 2.0.1.474.g72c7794
> >
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
