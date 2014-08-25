Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 423556B0036
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 07:01:42 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so20598029pad.39
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 04:01:39 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id t3si52878837pdp.220.2014.08.25.04.01.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Aug 2014 04:01:38 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so20871068pab.12
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 04:01:38 -0700 (PDT)
Date: Mon, 25 Aug 2014 20:01:18 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v3] zram: add num_discards for discarded pages stat
Message-ID: <20140825110118.GA933@swordfish>
References: <000201cfbde2$2ae08710$80a19530$@samsung.com>
 <20140825003610.GM17372@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140825003610.GM17372@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Chao Yu <chao2.yu@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, 'Jerome Marchand' <jmarchan@redhat.com>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Andrew Morton' <akpm@linux-foundation.org>

Hello,

On (08/25/14 09:36), Minchan Kim wrote:
> Hello Chao,
> 
> On Fri, Aug 22, 2014 at 04:21:01PM +0800, Chao Yu wrote:
> > Since we have supported handling discard request in this commit
> > f4659d8e620d08bd1a84a8aec5d2f5294a242764 (zram: support REQ_DISCARD), zram got
> > one more chance to free unused memory whenever received discard request. But
> > without stating for discard request, there is no method for user to know whether
> > discard request has been handled by zram or how many blocks were discarded by
> > zram when user wants to know the effect of discard.
> 
> My concern is that how much we are able to know the effect of discard
> exactly with your patch.
> 
> The issue I can think of is zram-swap discard.
> Now, zram handles notification from VM to free duplicated copy between
> VM-owned memory and zRAM-owned's one so discarding for zram-swap might
> be pointless overhead but your stat indicates lots of free page discarded
> without real freeing 

this is why I've moved stats accounting to the place where actual
zs_free() happens. and, frankly, I still would like to see the number
of zs_free() calls, rather than the number of slot free notifications
and REQ_DISCARD (or separately), because they all end up calling
zs_free(). iow, despite the call path, from the user point of view
they are just zs_free() -- the number of pages that's been freed by
the 3rd party and we had have to deal with that.

> so that user might think "We should keep enable
> swap discard for zRAM because the stat indicates it's really good".
> 
> In summary, wouldn't it better to have two?
> 
> num_discards,
> num_failed_discards?

do we actully need this? the only value I can think of (perhaps I'm
missing something) is that we can make sure that we need to support
both slot free and REQ_DISCARDS, or we can leave only REQ_DISCARDS.
is there anything else?

	-ss

> For it, we should modify zram_free_page has return value.
> What do other guys think?
> 
> > 
> > In this patch, we add num_discards to stat discarded pages, and export it to
> > sysfs for users.
> > 
> > * From v1
> >  * Update zram document to show num_discards in statistics list.
> > 
> > * From v2
> >  * Update description of this patch with clear goal.
> > 
> > Signed-off-by: Chao Yu <chao2.yu@samsung.com>
> > ---
> >  Documentation/ABI/testing/sysfs-block-zram | 10 ++++++++++
> >  Documentation/blockdev/zram.txt            |  1 +
> >  drivers/block/zram/zram_drv.c              |  3 +++
> >  drivers/block/zram/zram_drv.h              |  1 +
> >  4 files changed, 15 insertions(+)
> > 
> > diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
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
> > diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> > index 0595c3f..e50e18b 100644
> > --- a/Documentation/blockdev/zram.txt
> > +++ b/Documentation/blockdev/zram.txt
> > @@ -89,6 +89,7 @@ size of the disk when not in use so a huge zram is wasteful.
> >  		num_writes
> >  		failed_reads
> >  		failed_writes
> > +		num_discards
> >  		invalid_io
> >  		notify_free
> >  		zero_pages
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
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
