Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B8CD882F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 17:46:27 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id u7so66368031pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:46:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y87si2360154pfi.250.2015.12.22.14.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 14:46:27 -0800 (PST)
Date: Tue, 22 Dec 2015 14:46:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 4/7] dax: add support for fsync/sync
Message-Id: <20151222144625.f400e12e362cf9b00f6ffb36@linux-foundation.org>
In-Reply-To: <1450502540-8744-5-git-send-email-ross.zwisler@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
	<1450502540-8744-5-git-send-email-ross.zwisler@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org, xfs@oss.sgi.com, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, 18 Dec 2015 22:22:17 -0700 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> To properly handle fsync/msync in an efficient way DAX needs to track dirty
> pages so it is able to flush them durably to media on demand.
> 
> The tracking of dirty pages is done via the radix tree in struct
> address_space.  This radix tree is already used by the page writeback
> infrastructure for tracking dirty pages associated with an open file, and
> it already has support for exceptional (non struct page*) entries.  We
> build upon these features to add exceptional entries to the radix tree for
> DAX dirty PMD or PTE pages at fault time.

I'm getting a few rejects here against other pending changes.  Things
look OK to me but please do runtime test the end result as it resides
in linux-next.  Which will be next year.

>
> ...
>
> +static void dax_writeback_one(struct address_space *mapping, pgoff_t index,
> +		void *entry)
> +{
> +	struct radix_tree_root *page_tree = &mapping->page_tree;
> +	int type = RADIX_DAX_TYPE(entry);
> +	struct radix_tree_node *node;
> +	void **slot;
> +
> +	if (type != RADIX_DAX_PTE && type != RADIX_DAX_PMD) {
> +		WARN_ON_ONCE(1);
> +		return;
> +	}

--- a/fs/dax.c~dax-add-support-for-fsync-sync-fix
+++ a/fs/dax.c
@@ -383,10 +383,8 @@ static void dax_writeback_one(struct add
 	struct radix_tree_node *node;
 	void **slot;
 
-	if (type != RADIX_DAX_PTE && type != RADIX_DAX_PMD) {
-		WARN_ON_ONCE(1);
+	if (WARN_ON_ONCE(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD))
 		return;
-	}
 
 	spin_lock_irq(&mapping->tree_lock);
 	/*

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
> +	if (type == RADIX_DAX_PMD)
> +		wb_cache_pmem(RADIX_DAX_ADDR(entry), PMD_SIZE);
> +	else
> +		wb_cache_pmem(RADIX_DAX_ADDR(entry), PAGE_SIZE);
> + unlock:
> +	spin_unlock_irq(&mapping->tree_lock);
> +}
> +
> +/*
> + * Flush the mapping to the persistent domain within the byte range of [start,
> + * end]. This is required by data integrity operations to ensure file data is
> + * on persistent storage prior to completion of the operation.
> + */
> +void dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
> +		loff_t end)
> +{
> +	struct inode *inode = mapping->host;
> +	pgoff_t indices[PAGEVEC_SIZE];
> +	pgoff_t start_page, end_page;
> +	struct pagevec pvec;
> +	void *entry;
> +	int i;
> +
> +	if (inode->i_blkbits != PAGE_SHIFT) {
> +		WARN_ON_ONCE(1);
> +		return;
> +	}

again

> +	rcu_read_lock();
> +	entry = radix_tree_lookup(&mapping->page_tree, start & PMD_MASK);
> +	rcu_read_unlock();

What stabilizes the memory at *entry after rcu_read_unlock()?

> +	/* see if the start of our range is covered by a PMD entry */
> +	if (entry && RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
> +		start &= PMD_MASK;
> +
> +	start_page = start >> PAGE_CACHE_SHIFT;
> +	end_page = end >> PAGE_CACHE_SHIFT;
> +
> +	tag_pages_for_writeback(mapping, start_page, end_page);
> +
> +	pagevec_init(&pvec, 0);
> +	while (1) {
> +		pvec.nr = find_get_entries_tag(mapping, start_page,
> +				PAGECACHE_TAG_TOWRITE, PAGEVEC_SIZE,
> +				pvec.pages, indices);
> +
> +		if (pvec.nr == 0)
> +			break;
> +
> +		for (i = 0; i < pvec.nr; i++)
> +			dax_writeback_one(mapping, indices[i], pvec.pages[i]);
> +	}
> +	wmb_pmem();
> +}
> +EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
