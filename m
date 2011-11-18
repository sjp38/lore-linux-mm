Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDC96B002D
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 16:35:34 -0500 (EST)
Date: Fri, 18 Nov 2011 22:35:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/5] mm: compaction: Determine if dirty pages can be
 migreated without blocking within ->migratepage
Message-ID: <20111118213530.GA6323@redhat.com>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321635524-8586-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321635524-8586-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 18, 2011 at 04:58:43PM +0000, Mel Gorman wrote:
> +	/* async case, we cannot block on lock_buffer so use trylock_buffer */
> +	do {
> +		get_bh(bh);
> +		if (!trylock_buffer(bh)) {
> +			/*
> +			 * We failed to lock the buffer and cannot stall in
> +			 * async migration. Release the taken locks
> +			 */
> +			struct buffer_head *failed_bh = bh;
> +			bh = head;
> +			do {
> +				unlock_buffer(bh);
> +				put_bh(bh);
> +				bh = bh->b_this_page;
> +			} while (bh != failed_bh);
> +			return false;

here if blocksize is < PAGE_SIZE you're leaking one get_bh
(memleak). If blocksize is PAGE_SIZE (common) you're unlocking a
locked bh leading to fs corruption.
> +	if (!buffer_migrate_lock_buffers(head, sync)) {
> +		/*
> +		 * We have to revert the radix tree update. If this returns
> +		 * non-zero, it either means that the page count changed
> +		 * which "can't happen" or the slot changed from underneath
> +		 * us in which case someone operated on a page that did not
> +		 * have buffers fully migrated which is alarming so warn
> +		 * that it happened.
> +		 */
> +		WARN_ON(migrate_page_move_mapping(mapping, page, newpage));

speculative pagecache lookups can actually increase the count, the
freezing is released before returning from
migrate_page_move_mapping. It's not alarming that pagecache lookup
flips bit all over the place. The only way to stop them is the
page_freeze_refs.

folks who wants low latency or no memory overhead should simply
disable compaction. In my tests these "lowlatency" changes, notably
the change in vmscan that is already upstream breaks thp allocation
reliability, the __GFP_NO_KSWAPD check too should be dropped I think,
it's good thing we dropped it because the sync migrate is needed or
the above pages with bh to migrate would become "unmovable" despite
they're allocated in "movable" pageblocks.

The workload to test is:

cp /dev/sda /dev/null &
cp /dev/zero /media/someusb/zero &
wait free memory to reach minimum level
./largepage (allocate some gigabyte of hugepages)
grep thp /proc/vmstat

Anything that leads to a thp allocation failure rate of this workload
of 50% should be banned and all compaction patches (including vmscan
changes) should go through the above workload.

I got back to the previous state and there's <10% of failures even in
the above workload (and close to 100% in normal load but it's harder
to define normal load while the above is pretty easy to define).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
