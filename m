Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E1A336B01B7
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 18:22:00 -0400 (EDT)
Date: Fri, 18 Jun 2010 15:21:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: Implement writeback livelock avoidance using
 page tagging
Message-Id: <20100618152128.bb0db798.akpm@linux-foundation.org>
In-Reply-To: <1276706031-29421-3-git-send-email-jack@suse.cz>
References: <1276706031-29421-1-git-send-email-jack@suse.cz>
	<1276706031-29421-3-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jun 2010 18:33:51 +0200
Jan Kara <jack@suse.cz> wrote:

> We try to avoid livelocks of writeback when some steadily creates
> dirty pages in a mapping we are writing out. For memory-cleaning
> writeback, using nr_to_write works reasonably well but we cannot
> really use it for data integrity writeback. This patch tries to
> solve the problem.
> 
> The idea is simple: Tag all pages that should be written back
> with a special tag (TOWRITE) in the radix tree. This can be done
> rather quickly and thus livelocks should not happen in practice.
> Then we start doing the hard work of locking pages and sending
> them to disk only for those pages that have TOWRITE tag set.
> 
> Note: Adding new radix tree tag grows radix tree node from 288 to
> 296 bytes for 32-bit archs and from 552 to 560 bytes for 64-bit archs.
> However, the number of slab/slub items per page remains the same
> (13 and 7 respectively).
> 
>
> ...
>
> +void tag_pages_for_writeback(struct address_space *mapping,
> +			     pgoff_t start, pgoff_t end)
> +{
> +	unsigned long tagged;
> +
> +	do {
> +		spin_lock_irq(&mapping->tree_lock);
> +		tagged = radix_tree_range_tag_if_tagged(&mapping->page_tree,
> +				&start, end, WRITEBACK_TAG_BATCH,
> +				PAGECACHE_TAG_DIRTY, PAGECACHE_TAG_TOWRITE);
> +		spin_unlock_irq(&mapping->tree_lock);
> +		cond_resched();
> +	} while (tagged >= WRITEBACK_TAG_BATCH);
> +}

grumble.  (tagged > WRITEBACK_TAG_BATCH) would be a bug, wouldn't it? 
So the ">=" is hiding a bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
