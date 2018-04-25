Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 981496B025F
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 19:46:51 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j186so17427532qkd.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 16:46:51 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p10si1849505qvc.285.2018.04.25.16.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 16:46:49 -0700 (PDT)
Date: Wed, 25 Apr 2018 16:46:22 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH] iomap: add a swapfile activation function
Message-ID: <20180425234622.GC1661@magnolia>
References: <20180418025023.GM24738@magnolia>
 <20180424173539.GB25233@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424173539.GB25233@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Apr 24, 2018 at 10:35:39AM -0700, Christoph Hellwig wrote:
> This looks much better than using bmap, but I still think that
> having the swap code build its own ineffecient extents maps is
> a horible idea..

The iomaps that are fed to the actor function are limited in length by
the underlying filesystem's extent records, so if we allocate a single
16GB physical extent, xfs creates two 2^20 block extent records and calls
the actor on both extents.  add_swap_extent merges those into a single
internal extent record behind the scenes to satisfy its own requirements
and reduce memory usage.  The current separation of duties means that
the mm code doesn't care about what the fs does internally and the fs
doesn't know or care about what the mm does with the information
afterwards.

Hey memory management developers, what do you all think of this?
Nobody I cornered at LSF pointed out any problems.

(I mean, we /could/ just treat the swapfile as an unbreakable rdma/dax
style lease, but ugh...)

--D

> 
> On Tue, Apr 17, 2018 at 07:50:23PM -0700, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > Add a new iomap_swapfile_activate function so that filesystems can
> > activate swap files without having to use the obsolete and slow bmap
> > function.
> > 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> >  fs/iomap.c            |   99 +++++++++++++++++++++++++++++++++++++++++++++++++
> >  fs/xfs/xfs_aops.c     |   12 ++++++
> >  include/linux/iomap.h |    7 +++
> >  3 files changed, 118 insertions(+)
> > 
> > diff --git a/fs/iomap.c b/fs/iomap.c
> > index afd1635..ace921b 100644
> > --- a/fs/iomap.c
> > +++ b/fs/iomap.c
> > @@ -1089,3 +1089,102 @@ iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
> >  	return ret;
> >  }
> >  EXPORT_SYMBOL_GPL(iomap_dio_rw);
> > +
> > +/* Swapfile activation */
> > +
> > +struct iomap_swapfile_info {
> > +	struct swap_info_struct *sis;
> > +	uint64_t lowest_ppage;		/* lowest physical addr seen (pages) */
> > +	uint64_t highest_ppage;		/* highest physical addr seen (pages) */
> > +	unsigned long expected_page_no;	/* next logical offset wanted (pages) */
> > +	int nr_extents;			/* extent count */
> > +};
> > +
> > +static loff_t iomap_swapfile_activate_actor(struct inode *inode, loff_t pos,
> > +		loff_t count, void *data, struct iomap *iomap)
> > +{
> > +	struct iomap_swapfile_info *isi = data;
> > +	unsigned long page_no = iomap->offset >> PAGE_SHIFT;
> > +	unsigned long nr_pages = iomap->length >> PAGE_SHIFT;
> > +	uint64_t first_ppage = iomap->addr >> PAGE_SHIFT;
> > +	uint64_t last_ppage = ((iomap->addr + iomap->length) >> PAGE_SHIFT) - 1;
> > +
> > +	/* Only one bdev per swap file. */
> > +	if (iomap->bdev != isi->sis->bdev)
> > +		goto err;
> > +
> > +	/* Must be aligned to a page boundary. */
> > +	if ((iomap->offset & ~PAGE_MASK) || (iomap->addr & ~PAGE_MASK) ||
> > +	    (iomap->length & ~PAGE_MASK))
> > +		goto err;
> > +
> > +	/* Only real or unwritten extents. */
> > +	if (iomap->type != IOMAP_MAPPED && iomap->type != IOMAP_UNWRITTEN)
> > +		goto err;
> > +
> > +	/* No sparse files. */
> > +	if (isi->expected_page_no != page_no)
> > +		goto err;
> > +
> > +	/* No uncommitted metadata or shared blocks or inline data. */
> > +	if (iomap->flags & (IOMAP_F_DIRTY | IOMAP_F_SHARED |
> > +			    IOMAP_F_DATA_INLINE))
> > +		goto err;
> > +
> > +	/*
> > +	 * Calculate how much swap space we're adding; the first page contains
> > +	 * the swap header and doesn't count.
> > +	 */
> > +	if (page_no == 0)
> > +		first_ppage++;
> > +	if (isi->lowest_ppage > first_ppage)
> > +		isi->lowest_ppage = first_ppage;
> > +	if (isi->highest_ppage < last_ppage)
> > +		isi->highest_ppage = last_ppage;
> > +
> > +	/* Add extent, set up for the next call. */
> > +	isi->nr_extents += add_swap_extent(isi->sis, page_no, nr_pages,
> > +			first_ppage);
> > +	isi->expected_page_no = page_no + nr_pages;
> > +
> > +	return count;
> > +err:
> > +	pr_err("swapon: swapfile has holes\n");
> > +	return -EINVAL;
> > +}
> > +
> > +int iomap_swapfile_activate(struct swap_info_struct *sis,
> > +		struct file *swap_file, sector_t *pagespan,
> > +		const struct iomap_ops *ops)
> > +{
> > +	struct iomap_swapfile_info isi = {
> > +		.sis = sis,
> > +		.lowest_ppage = (sector_t)-1ULL,
> > +	};
> > +	struct address_space *mapping = swap_file->f_mapping;
> > +	struct inode *inode = mapping->host;
> > +	loff_t pos = 0;
> > +	loff_t len = i_size_read(inode);
> > +	loff_t ret;
> > +
> > +	ret = filemap_write_and_wait(inode->i_mapping);
> > +	if (ret)
> > +		return ret;
> > +
> > +	while (len > 0) {
> > +		ret = iomap_apply(inode, pos, len, IOMAP_REPORT,
> > +				ops, &isi, iomap_swapfile_activate_actor);
> > +		if (ret <= 0)
> > +			return ret;
> > +
> > +		pos += ret;
> > +		len -= ret;
> > +	}
> > +
> > +	*pagespan = 1 + isi.highest_ppage - isi.lowest_ppage;
> > +	sis->max = isi.expected_page_no;
> > +	sis->pages = isi.expected_page_no - 1;
> > +	sis->highest_bit = isi.expected_page_no - 1;
> > +	return isi.nr_extents;
> > +}
> > +EXPORT_SYMBOL_GPL(iomap_swapfile_activate);
> > diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> > index 0ab824f..80de476 100644
> > --- a/fs/xfs/xfs_aops.c
> > +++ b/fs/xfs/xfs_aops.c
> > @@ -1475,6 +1475,16 @@ xfs_vm_set_page_dirty(
> >  	return newly_dirty;
> >  }
> >  
> > +static int
> > +xfs_iomap_swapfile_activate(
> > +	struct swap_info_struct		*sis,
> > +	struct file			*swap_file,
> > +	sector_t			*span)
> > +{
> > +	sis->bdev = xfs_find_bdev_for_inode(file_inode(swap_file));
> > +	return iomap_swapfile_activate(sis, swap_file, span, &xfs_iomap_ops);
> > +}
> > +
> >  const struct address_space_operations xfs_address_space_operations = {
> >  	.readpage		= xfs_vm_readpage,
> >  	.readpages		= xfs_vm_readpages,
> > @@ -1488,6 +1498,7 @@ const struct address_space_operations xfs_address_space_operations = {
> >  	.migratepage		= buffer_migrate_page,
> >  	.is_partially_uptodate  = block_is_partially_uptodate,
> >  	.error_remove_page	= generic_error_remove_page,
> > +	.swap_activate		= xfs_iomap_swapfile_activate,
> >  };
> >  
> >  const struct address_space_operations xfs_dax_aops = {
> > @@ -1495,4 +1506,5 @@ const struct address_space_operations xfs_dax_aops = {
> >  	.direct_IO		= noop_direct_IO,
> >  	.set_page_dirty		= noop_set_page_dirty,
> >  	.invalidatepage		= noop_invalidatepage,
> > +	.swap_activate		= xfs_iomap_swapfile_activate,
> >  };
> > diff --git a/include/linux/iomap.h b/include/linux/iomap.h
> > index 19a07de..66d1c35 100644
> > --- a/include/linux/iomap.h
> > +++ b/include/linux/iomap.h
> > @@ -106,4 +106,11 @@ typedef int (iomap_dio_end_io_t)(struct kiocb *iocb, ssize_t ret,
> >  ssize_t iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
> >  		const struct iomap_ops *ops, iomap_dio_end_io_t end_io);
> >  
> > +struct file;
> > +struct swap_info_struct;
> > +
> > +int iomap_swapfile_activate(struct swap_info_struct *sis,
> > +		struct file *swap_file, sector_t *pagespan,
> > +		const struct iomap_ops *ops);
> > +
> >  #endif /* LINUX_IOMAP_H */
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> ---end quoted text---
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
