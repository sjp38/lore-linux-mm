Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4739B6B0011
	for <linux-mm@kvack.org>; Wed,  2 May 2018 16:30:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u10-v6so1216727pgp.8
        for <linux-mm@kvack.org>; Wed, 02 May 2018 13:30:20 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id i89si3127059pfd.117.2018.05.02.13.30.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 13:30:19 -0700 (PDT)
Date: Wed, 2 May 2018 13:29:55 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH] iomap: add a swapfile activation function
Message-ID: <20180502202955.GA4112@magnolia>
References: <20180418025023.GM24738@magnolia>
 <20180421123301.v7bbofc2joaibpi6@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180421123301.v7bbofc2joaibpi6@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org

On Sat, Apr 21, 2018 at 02:33:01PM +0200, Jan Kara wrote:
> On Tue 17-04-18 19:50:23, Darrick J. Wong wrote:
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
> 
> Reporting error in this case does not look equivalent to
> generic_swapfile_activate()? That function just skips blocks with
> insufficient alignment...

Yes, I've fixed this to emulate more closely the behavior of the old
bmap implementation, so now we collect physically contiguous iomaps
and trim the accumulated iomap to satisfy the page alignment
requirements.

> And I'm actually puzzled why alignment of physical block is needed but
> that's independent question.

I'm not sure why either. :)

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
> 
> And here add_swap_extent() can return error.

Fixed, thanks.

--D

> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
