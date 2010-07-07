Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7429F6B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 19:16:39 -0400 (EDT)
Date: Wed, 7 Jul 2010 19:16:11 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: what is the point of nr_pages information for the flusher thread?
Message-ID: <20100707231611.GA24281@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, mel@csn.ul.ie, akpm@linux-foundation.org, npiggin@suse.de
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently there's three possible values we pass into the flusher thread
for the nr_pages arguments:

 - in sync_inodes_sb and bdi_start_background_writeback:

	LONG_MAX

 - in writeback_inodes_sb and wb_check_old_data_flush:

	global_page_state(NR_FILE_DIRTY) +
	global_page_state(NR_UNSTABLE_NFS) +
	(inodes_stat.nr_inodes - inodes_stat.nr_unused)

 - in wakeup_flusher_threads and laptop_mode_timer_fn:

	global_page_state(NR_FILE_DIRTY) +
	global_page_state(NR_UNSTABLE_NFS)

The LONG_MAX cases are triviall explained, as we ignore the nr_to_write
value for data integrity writepage in the lowlevel writeback code, and
the for_background in bdi_start_background_writeback has it's own check
for the background threshold.  So far so good, and now it gets
interesting.

Why does writeback_inodes_sb add the number of used inodes into a value
that is in units of pages?  And why don't the other callers do this?

But seriously, how is the _global_ number of dirty and unstable pages
a good indicator for the amount of writeback per-bdi or superblock
anyway?

Somehow I'd feel much better about doing this calculation all the way
down in wb_writeback instead of the callers so we'll at least have
one documented place for these insanities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
