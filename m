Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A959E6B0539
	for <linux-mm@kvack.org>; Wed,  9 May 2018 13:11:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c4-v6so27438989qtp.9
        for <linux-mm@kvack.org>; Wed, 09 May 2018 10:11:47 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n55-v6si3798827qtf.313.2018.05.09.10.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 10:11:46 -0700 (PDT)
Date: Wed, 9 May 2018 10:11:24 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v3 1/2] iomap: add a swapfile activation function
Message-ID: <20180509171124.GD9510@magnolia>
References: <20180503174659.GD4127@magnolia>
 <20180509152002.kuqjfpyzlxdc7izg@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509152002.kuqjfpyzlxdc7izg@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, cyberax@amazon.com, osandov@osandov.com, Eryu Guan <guaneryu@gmail.com>

On Wed, May 09, 2018 at 05:20:02PM +0200, Jan Kara wrote:
> On Thu 03-05-18 10:46:59, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > Add a new iomap_swapfile_activate function so that filesystems can
> > activate swap files without having to use the obsolete and slow bmap
> > function.  This enables XFS to support fallocate'd swap files and
> > swap files on realtime devices.
> > 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> > v3: catch null iomap addr, fix too-short extent detection
> > v2: document the swap file layout requirements, combine adjacent
> >     real/unwritten extents, align reported swap extents to physical page
> >     size boundaries, fix compiler errors when swap disabled
> > ---
> >  fs/iomap.c            |  162 +++++++++++++++++++++++++++++++++++++++++++++++++
> >  fs/xfs/xfs_aops.c     |   12 ++++
> >  include/linux/iomap.h |   11 +++
> >  3 files changed, 185 insertions(+)
> > 
> > diff --git a/fs/iomap.c b/fs/iomap.c
> > index afd163586aa0..ac7115492366 100644
> > --- a/fs/iomap.c
> > +++ b/fs/iomap.c
> > @@ -27,6 +27,7 @@
> >  #include <linux/task_io_accounting_ops.h>
> >  #include <linux/dax.h>
> >  #include <linux/sched/signal.h>
> > +#include <linux/swap.h>
> >  
> >  #include "internal.h"
> >  
> > @@ -1089,3 +1090,164 @@ iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
> >  	return ret;
> >  }
> >  EXPORT_SYMBOL_GPL(iomap_dio_rw);
> > +
> > +/* Swapfile activation */
> > +
> > +#ifdef CONFIG_SWAP
> > +struct iomap_swapfile_info {
> > +	struct iomap iomap;		/* accumulated iomap */
> > +	struct swap_info_struct *sis;
> > +	uint64_t lowest_ppage;		/* lowest physical addr seen (pages) */
> > +	uint64_t highest_ppage;		/* highest physical addr seen (pages) */
> > +	unsigned long nr_pages;		/* number of pages collected */
> > +	int nr_extents;			/* extent count */
> > +};
> > +
> > +/*
> > + * Collect physical extents for this swap file.  Physical extents reported to
> > + * the swap code must be trimmed to align to a page boundary.  The logical
> > + * offset within the file is irrelevant since the swapfile code maps logical
> > + * page numbers of the swap device to the physical page-aligned extents.
> > + */
> > +static int iomap_swapfile_add_extent(struct iomap_swapfile_info *isi)
> > +{
> > +	struct iomap *iomap = &isi->iomap;
> > +	unsigned long nr_pages;
> > +	uint64_t first_ppage;
> > +	uint64_t first_ppage_reported;
> > +	uint64_t last_ppage;
> > +	int error;
> > +
> > +	/*
> > +	 * Round the start up and the end down so that the physical
> > +	 * extent aligns to a page boundary.
> > +	 */
> > +	first_ppage = ALIGN(iomap->addr, PAGE_SIZE) >> PAGE_SHIFT;
> > +	last_ppage = (ALIGN_DOWN(iomap->addr + iomap->length, PAGE_SIZE) >>
> > +			PAGE_SHIFT) - 1;
> 
> But this can still end up underflowing last_ppage to (unsigned long)-1 and
> the following test won't trigger?

Yeah, I'll fix it and resubmit.  Thx for catching this.

--D

> > +
> > +	/* Skip too-short physical extents. */
> > +	if (first_ppage > last_ppage)
> > +		return 0;
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
