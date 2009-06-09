Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 32E836B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 05:20:43 -0400 (EDT)
Date: Tue, 9 Jun 2009 11:51:55 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v5
Message-ID: <20090609095155.GA14820@wotan.suse.de>
References: <20090603846.816684333@firstfloor.org> <20090603184648.2E2131D028F@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090603184648.2E2131D028F@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: hugh.dickins@tiscali.co.uk, riel@redhat.com, chris.mason@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 03, 2009 at 08:46:47PM +0200, Andi Kleen wrote:
> +static int me_pagecache_clean(struct page *p, unsigned long pfn)
> +{
> +	struct address_space *mapping;
> +
> +	if (!isolate_lru_page(p))
> +		page_cache_release(p);
> +
> +	/*
> +	 * Now truncate the page in the page cache. This is really
> +	 * more like a "temporary hole punch"
> +	 * Don't do this for block devices when someone else
> +	 * has a reference, because it could be file system metadata
> +	 * and that's not safe to truncate.
> +	 */
> +	mapping = page_mapping(p);
> +	if (mapping && S_ISBLK(mapping->host->i_mode) && page_count(p) > 1) {
> +		printk(KERN_ERR
> +			"MCE %#lx: page looks like a unsupported file system metadata page\n",
> +			pfn);
> +		return FAILED;
> +	}

page_count check is racy. Hmm, S_ISBLK should handle xfs's private mapping.
AFAIK btrfs has a similar private mapping but a quick grep does not show
up S_IFBLK anywhere, so I don't know what the situation is there.

Unfortunately though, the linear mapping is not the only metadata mapping
a filesystem might have. Many work on directories in seperate mappings
(ext2, for example, which is where I first looked and will still oops with
your check).

Also, others may have other interesting inodes they use for metadata. Do
any of them go through the pagecache? I dont know. The ext3 journal,
for example? How does that work?

Unfortunately I don't know a good way to detect regular data mappings
easily. Ccing linux-fsdevel. Until that is worked out, you'd need to
use the safe pagecache invalidate rather than unsafe truncate.


> +	if (mapping) {
> +		truncate_inode_page(mapping, p);
> +		if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO)) {
> +			pr_debug(KERN_ERR "MCE %#lx: failed to release buffers\n",
> +				pfn);
> +			return FAILED;
> +		}
> +	}
> +	return RECOVERED;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
