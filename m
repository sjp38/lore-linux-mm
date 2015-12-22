Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D21E382F7D
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 18:51:28 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id jx14so96541686pad.2
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 15:51:28 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id n18si13248697pfi.117.2015.12.22.15.51.28
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 15:51:28 -0800 (PST)
Date: Tue, 22 Dec 2015 16:51:23 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 4/7] dax: add support for fsync/sync
Message-ID: <20151222235123.GA24124@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450502540-8744-5-git-send-email-ross.zwisler@linux.intel.com>
 <20151222144625.f400e12e362cf9b00f6ffb36@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151222144625.f400e12e362cf9b00f6ffb36@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org, xfs@oss.sgi.com, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, Dec 22, 2015 at 02:46:25PM -0800, Andrew Morton wrote:
> On Fri, 18 Dec 2015 22:22:17 -0700 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:
> 
> > To properly handle fsync/msync in an efficient way DAX needs to track dirty
> > pages so it is able to flush them durably to media on demand.
> > 
> > The tracking of dirty pages is done via the radix tree in struct
> > address_space.  This radix tree is already used by the page writeback
> > infrastructure for tracking dirty pages associated with an open file, and
> > it already has support for exceptional (non struct page*) entries.  We
> > build upon these features to add exceptional entries to the radix tree for
> > DAX dirty PMD or PTE pages at fault time.
> 
> I'm getting a few rejects here against other pending changes.  Things
> look OK to me but please do runtime test the end result as it resides
> in linux-next.  Which will be next year.

Sounds good.  I'm hoping to soon send out an updated version of this series
which merges with Dan's changes to dax.c.  Thank you for pulling these into
-mm.

> --- a/fs/dax.c~dax-add-support-for-fsync-sync-fix
> +++ a/fs/dax.c
> @@ -383,10 +383,8 @@ static void dax_writeback_one(struct add
>  	struct radix_tree_node *node;
>  	void **slot;
>  
> -	if (type != RADIX_DAX_PTE && type != RADIX_DAX_PMD) {
> -		WARN_ON_ONCE(1);
> +	if (WARN_ON_ONCE(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD))
>  		return;
> -	}

This is much cleaner, thanks.  I'll make this change throughout my set.

> > +/*
> > + * Flush the mapping to the persistent domain within the byte range of [start,
> > + * end]. This is required by data integrity operations to ensure file data is
> > + * on persistent storage prior to completion of the operation.
> > + */
> > +void dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
> > +		loff_t end)
> > +{
> > +	struct inode *inode = mapping->host;
> > +	pgoff_t indices[PAGEVEC_SIZE];
> > +	pgoff_t start_page, end_page;
> > +	struct pagevec pvec;
> > +	void *entry;
> > +	int i;
> > +
> > +	if (inode->i_blkbits != PAGE_SHIFT) {
> > +		WARN_ON_ONCE(1);
> > +		return;
> > +	}
> 
> again
> 
> > +	rcu_read_lock();
> > +	entry = radix_tree_lookup(&mapping->page_tree, start & PMD_MASK);
> > +	rcu_read_unlock();
> 
> What stabilizes the memory at *entry after rcu_read_unlock()?

Nothing in this function.  We use the entry that is currently in the tree to
know whether or not to expand the range of offsets that we need to flush.
Even if we are racing with someone, expanding our flushing range is
non-destructive.

We get a list of entries based on what is dirty later in this function via
find_get_entries_tag(), and before we take any action on those entries we
re-verify them while holding the tree_lock in dax_writeback_one().

The next version of this series will have updated version of this code which
also accounts for block device removal via dax_map_atomic() inside of
dax_writeback_one().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
