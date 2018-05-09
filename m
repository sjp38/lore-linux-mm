Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 569F66B052A
	for <linux-mm@kvack.org>; Wed,  9 May 2018 11:20:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k27-v6so23427277wre.23
        for <linux-mm@kvack.org>; Wed, 09 May 2018 08:20:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b25-v6si1168525eda.333.2018.05.09.08.20.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 08:20:02 -0700 (PDT)
Date: Wed, 9 May 2018 17:20:02 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 1/2] iomap: add a swapfile activation function
Message-ID: <20180509152002.kuqjfpyzlxdc7izg@quack2.suse.cz>
References: <20180503174659.GD4127@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180503174659.GD4127@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, cyberax@amazon.com, jack@suse.cz, osandov@osandov.com, Eryu Guan <guaneryu@gmail.com>

On Thu 03-05-18 10:46:59, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Add a new iomap_swapfile_activate function so that filesystems can
> activate swap files without having to use the obsolete and slow bmap
> function.  This enables XFS to support fallocate'd swap files and
> swap files on realtime devices.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
> v3: catch null iomap addr, fix too-short extent detection
> v2: document the swap file layout requirements, combine adjacent
>     real/unwritten extents, align reported swap extents to physical page
>     size boundaries, fix compiler errors when swap disabled
> ---
>  fs/iomap.c            |  162 +++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/xfs/xfs_aops.c     |   12 ++++
>  include/linux/iomap.h |   11 +++
>  3 files changed, 185 insertions(+)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index afd163586aa0..ac7115492366 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -27,6 +27,7 @@
>  #include <linux/task_io_accounting_ops.h>
>  #include <linux/dax.h>
>  #include <linux/sched/signal.h>
> +#include <linux/swap.h>
>  
>  #include "internal.h"
>  
> @@ -1089,3 +1090,164 @@ iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(iomap_dio_rw);
> +
> +/* Swapfile activation */
> +
> +#ifdef CONFIG_SWAP
> +struct iomap_swapfile_info {
> +	struct iomap iomap;		/* accumulated iomap */
> +	struct swap_info_struct *sis;
> +	uint64_t lowest_ppage;		/* lowest physical addr seen (pages) */
> +	uint64_t highest_ppage;		/* highest physical addr seen (pages) */
> +	unsigned long nr_pages;		/* number of pages collected */
> +	int nr_extents;			/* extent count */
> +};
> +
> +/*
> + * Collect physical extents for this swap file.  Physical extents reported to
> + * the swap code must be trimmed to align to a page boundary.  The logical
> + * offset within the file is irrelevant since the swapfile code maps logical
> + * page numbers of the swap device to the physical page-aligned extents.
> + */
> +static int iomap_swapfile_add_extent(struct iomap_swapfile_info *isi)
> +{
> +	struct iomap *iomap = &isi->iomap;
> +	unsigned long nr_pages;
> +	uint64_t first_ppage;
> +	uint64_t first_ppage_reported;
> +	uint64_t last_ppage;
> +	int error;
> +
> +	/*
> +	 * Round the start up and the end down so that the physical
> +	 * extent aligns to a page boundary.
> +	 */
> +	first_ppage = ALIGN(iomap->addr, PAGE_SIZE) >> PAGE_SHIFT;
> +	last_ppage = (ALIGN_DOWN(iomap->addr + iomap->length, PAGE_SIZE) >>
> +			PAGE_SHIFT) - 1;

But this can still end up underflowing last_ppage to (unsigned long)-1 and
the following test won't trigger?

> +
> +	/* Skip too-short physical extents. */
> +	if (first_ppage > last_ppage)
> +		return 0;

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
