Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14E686B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 06:26:19 -0400 (EDT)
Date: Mon, 11 Jul 2011 06:26:09 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
Message-ID: <20110711102609.GA5953@infradead.org>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701145935.GB29530@suse.de>
 <20110702024219.GT561@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110702024219.GT561@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, xfs@oss.sgi.com, jack@suse.cz, linux-mm@kvack.org

On Sat, Jul 02, 2011 at 12:42:19PM +1000, Dave Chinner wrote:
> To tell the truth, I don't think anyone really cares how ext3
> performs these days. XFS seems to be the filesystem that brings out
> all the bad behaviour in the mm subsystem....

Maybe that's because XFS actually plays by the rules?

btrfs simply rejects all attempts from kswapd to write back, as it
has the following check:

	if (current->flags & PF_MEMALLOC) {
		redirty_page_for_writepage(wbc, page);
		unlock_page(page);
		return 0;
	}

while XFS tries to play nice and allow writeback from kswapd:

	if ((current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC)
		goto redirty;

ext4 can't perform delalloc conversions from writepage:

	if (walk_page_buffers(NULL, page_bufs, 0, len, NULL,
			      ext4_bh_delay_or_unwritten)) {
		/*
		 * We don't want to do block allocation, so redirty
		 * the page and return.  We may reach here when we do
		 * a journal commit via journal_submit_inode_data_buffers.
		 * We can also reach here via shrink_page_list
		 */
		goto redirty_pages;
	}

so any normal worklaods that don't involve overwrites will every get
any writeback from kswapd.

This should tell us that the VM can live just fine without doing
writeback from kswapd, as otherwise all systems using btrfs or ext4
would have completely fallen over.

It also suggested we should have standardized helpers in the VFS to work
around the braindead VM behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
