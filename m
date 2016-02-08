Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DAEE1828DF
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 17:07:17 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so79971820pab.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 14:07:17 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id y22si49115458pfi.57.2016.02.08.14.07.16
        for <linux-mm@kvack.org>;
        Mon, 08 Feb 2016 14:07:16 -0800 (PST)
Date: Mon, 8 Feb 2016 15:06:50 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v8 6/9] dax: add support for fsync/msync
Message-ID: <20160208220650.GG2343@linux.intel.com>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452230879-18117-7-git-send-email-ross.zwisler@linux.intel.com>
 <878u2xrjrw.fsf@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878u2xrjrw.fsf@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Monakhov <dmonlist@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

On Sat, Feb 06, 2016 at 05:33:07PM +0300, Dmitry Monakhov wrote:
> Ross Zwisler <ross.zwisler@linux.intel.com> writes:
<>
> > +static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
> IMHO it would be sane to call that function as dax_radix_entry_insert() 

I think I may have actually had it named that at some point. :)  I changed it
because it doesn't always insert an entry - in the read case for example we
insert a clean entry, and then on the following dax_pfn_mkwrite() we call back
in and mark it as dirty.

<>
> > +/*
> > + * Flush the mapping to the persistent domain within the byte range of [start,
> > + * end]. This is required by data integrity operations to ensure file data is
> > + * on persistent storage prior to completion of the operation.
> > + */
> > +int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
> > +		loff_t end)
> > +{
> > +	struct inode *inode = mapping->host;
> > +	struct block_device *bdev = inode->i_sb->s_bdev;
> > +	pgoff_t indices[PAGEVEC_SIZE];
> > +	pgoff_t start_page, end_page;
> > +	struct pagevec pvec;
> > +	void *entry;
> > +	int i, ret = 0;
> > +
> > +	if (WARN_ON_ONCE(inode->i_blkbits != PAGE_SHIFT))
> > +		return -EIO;
> > +
> > +	rcu_read_lock();
> > +	entry = radix_tree_lookup(&mapping->page_tree, start & PMD_MASK);
> > +	rcu_read_unlock();
> > +
> > +	/* see if the start of our range is covered by a PMD entry */
> > +	if (entry && RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
> > +		start &= PMD_MASK;
> > +
> > +	start_page = start >> PAGE_CACHE_SHIFT;
> > +	end_page = end >> PAGE_CACHE_SHIFT;
> > +
> > +	tag_pages_for_writeback(mapping, start_page, end_page);
> > +
> > +	pagevec_init(&pvec, 0);
> > +	while (1) {
> > +		pvec.nr = find_get_entries_tag(mapping, start_page,
> > +				PAGECACHE_TAG_TOWRITE, PAGEVEC_SIZE,
> > +				pvec.pages, indices);
> > +
> > +		if (pvec.nr == 0)
> > +			break;
> > +
> > +		for (i = 0; i < pvec.nr; i++) {
> > +			ret = dax_writeback_one(bdev, mapping, indices[i],
> > +					pvec.pages[i]);
> > +			if (ret < 0)
> > +				return ret;
> > +		}
> I think it would be more efficient to use batched locking like follows:
>                 spin_lock_irq(&mapping->tree_lock);
> 		for (i = 0; i < pvec.nr; i++) {
>                     struct blk_dax_ctl dax[PAGEVEC_SIZE];                
>                     radix_tree_tag_clear(page_tree, indices[i], PAGECACHE_TAG_TOWRITE);
>                     /* It is also reasonable to merge adjacent dax
>                      * regions in to one */
>                     dax[i].sector = RADIX_DAX_SECTOR(entry);
>                     dax[i].size = (type == RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);                    
> 
>                 }
>                 spin_unlock_irq(&mapping->tree_lock);
>                	if (blk_queue_enter(q, true) != 0)
>                     goto error;
>                 for (i = 0; i < pvec.nr; i++) {
>                     rc = bdev_direct_access(bdev, dax[i]);
>                     wb_cache_pmem(dax[i].addr, dax[i].size);
>                 }
>                 ret = blk_queue_exit(q, true)

I guess this could be more efficient, but as Jan said in his response we're
currently focused on correctness.  I also wonder if it would be measurably
better?

In any case, Jan is right - you have to clear the TOWRITE tag only after
you've flushed, and you also need to include the entry verification code from
dax_writeback_one() after you grab the tree lock.  Basically, I believe all
the code in dax_writeback_one() is needed - this change would essentially just
be inlining that code in dax_writeback_mapping_range() so you could do
multiple operations without giving up a lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
