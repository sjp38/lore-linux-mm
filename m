Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF717828E1
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:44:17 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id 128so146999973wmz.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:44:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si41322105wjx.10.2016.02.08.01.44.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:44:16 -0800 (PST)
Date: Mon, 8 Feb 2016 10:44:30 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v8 6/9] dax: add support for fsync/msync
Message-ID: <20160208094430.GA9451@quack.suse.cz>
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

On Sat 06-02-16 17:33:07, Dmitry Monakhov wrote:
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

We need to clear the radix tree tag only after flushing caches. But in
principle I agree that some batching of radix tree tag manipulations should
be doable. But frankly so far we have issues with correctness so speed is
not our main concern.

> > +	}
> > +	wmb_pmem();
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
> > +
> >  static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
> >  			struct vm_area_struct *vma, struct vm_fault *vmf)
> >  {
> > @@ -363,6 +532,11 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
> >  	}
> >  	dax_unmap_atomic(bdev, &dax);
> >  
> > +	error = dax_radix_entry(mapping, vmf->pgoff, dax.sector, false,
> > +			vmf->flags & FAULT_FLAG_WRITE);
> > +	if (error)
> > +		goto out;
> > +
> >  	error = vm_insert_mixed(vma, vaddr, dax.pfn);
> >  
> >   out:
> > @@ -487,6 +661,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> >  		delete_from_page_cache(page);
> >  		unlock_page(page);
> >  		page_cache_release(page);
> > +		page = NULL;
> >  	}
> I've realized that I do not understand why dax_fault code works at all.
> During dax_fault we want to remove page from mapping and insert dax-entry
>  Basically code looks like follows:
> 0 page = find_get_page()
> 1 lock_page(page)
> 2 delete_from_page_cache(page);
> 3 unlock_page(page);
> 4 dax_insert_mapping(inode, &bh, vma, vmf);
> 
> BUT what on earth protects us from other process to reinsert page again
> after step(2) but before (4)?

Nothing, it's a bug and Ross / Matthew are working on fixing it...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
