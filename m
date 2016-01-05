Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id EBCA46B0006
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 06:13:59 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id f206so18714003wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 03:13:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 82si4634664wmp.31.2016.01.05.03.13.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 03:13:58 -0800 (PST)
Date: Tue, 5 Jan 2016 12:13:58 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 4/7] dax: add support for fsync/msync
Message-ID: <20160105111358.GD2724@quack.suse.cz>
References: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450899560-26708-5-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450899560-26708-5-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Wed 23-12-15 12:39:17, Ross Zwisler wrote:
> To properly handle fsync/msync in an efficient way DAX needs to track dirty
> pages so it is able to flush them durably to media on demand.
> 
> The tracking of dirty pages is done via the radix tree in struct
> address_space.  This radix tree is already used by the page writeback
> infrastructure for tracking dirty pages associated with an open file, and
> it already has support for exceptional (non struct page*) entries.  We
> build upon these features to add exceptional entries to the radix tree for
> DAX dirty PMD or PTE pages at fault time.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
...
> +static int dax_writeback_one(struct block_device *bdev,
> +		struct address_space *mapping, pgoff_t index, void *entry)
> +{
> +	struct radix_tree_root *page_tree = &mapping->page_tree;
> +	int type = RADIX_DAX_TYPE(entry);
> +	struct radix_tree_node *node;
> +	struct blk_dax_ctl dax;
> +	void **slot;
> +	int ret = 0;
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	/*
> +	 * Regular page slots are stabilized by the page lock even
> +	 * without the tree itself locked.  These unlocked entries
> +	 * need verification under the tree lock.
> +	 */
> +	if (!__radix_tree_lookup(page_tree, index, &node, &slot))
> +		goto unlock;
> +	if (*slot != entry)
> +		goto unlock;
> +
> +	/* another fsync thread may have already written back this entry */
> +	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> +		goto unlock;
> +
> +	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
> +
> +	if (WARN_ON_ONCE(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD)) {
> +		ret = -EIO;
> +		goto unlock;
> +	}
> +
> +	dax.sector = RADIX_DAX_SECTOR(entry);
> +	dax.size = (type == RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);
> +	spin_unlock_irq(&mapping->tree_lock);
> +
> +	/*
> +	 * We cannot hold tree_lock while calling dax_map_atomic() because it
> +	 * eventually calls cond_resched().
> +	 */
> +	ret = dax_map_atomic(bdev, &dax);
> +	if (ret < 0)
> +		return ret;
> +
> +	if (WARN_ON_ONCE(ret < dax.size)) {
> +		ret = -EIO;
> +		dax_unmap_atomic(bdev, &dax);
> +		return ret;
> +	}
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	/*
> +	 * We need to revalidate our radix entry while holding tree_lock
> +	 * before we do the writeback.
> +	 */

Do we really need to revalidate here? dax_map_atomic() makes sure the addr
& size is still part of the device. I guess you are concerned that due to
truncate or similar operation those sectors needn't belong to the same file
anymore but we don't really care about flushing sectors for someone else,
do we?

Otherwise the patch looks good to me.

> +	if (!__radix_tree_lookup(page_tree, index, &node, &slot))
> +		goto unmap;
> +	if (*slot != entry)
> +		goto unmap;
> +
> +	wb_cache_pmem(dax.addr, dax.size);
> + unmap:
> +	dax_unmap_atomic(bdev, &dax);
> + unlock:
> +	spin_unlock_irq(&mapping->tree_lock);
> +	return ret;
> +}

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
