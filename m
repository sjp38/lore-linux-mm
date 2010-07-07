Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 660236B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 19:37:44 -0400 (EDT)
Date: Wed, 7 Jul 2010 16:37:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: what is the point of nr_pages information for the flusher
 thread?
Message-Id: <20100707163710.a46173b2.akpm@linux-foundation.org>
In-Reply-To: <20100707231611.GA24281@infradead.org>
References: <20100707231611.GA24281@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: fengguang.wu@intel.com, mel@csn.ul.ie, npiggin@suse.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jul 2010 19:16:11 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> Currently there's three possible values we pass into the flusher thread
> for the nr_pages arguments:

I assume you're referring to wakeup_flusher_threads().

>  - in sync_inodes_sb and bdi_start_background_writeback:
> 
> 	LONG_MAX
> 
>  - in writeback_inodes_sb and wb_check_old_data_flush:
> 
> 	global_page_state(NR_FILE_DIRTY) +
> 	global_page_state(NR_UNSTABLE_NFS) +
> 	(inodes_stat.nr_inodes - inodes_stat.nr_unused)
> 
>  - in wakeup_flusher_threads and laptop_mode_timer_fn:
> 
> 	global_page_state(NR_FILE_DIRTY) +
> 	global_page_state(NR_UNSTABLE_NFS)

There's also free_more_memory() and do_try_to_free_pages().

You'd need to do some deep git archeology to work out what the thinking
was at those two callsites.  My git machine is presently at the other
end of a slow link.

wakeup_flusher_threads() apepars to have been borked.  It passes
nr_pages() into *each* bdi hence can write back far more than it was
asked to.

> The LONG_MAX cases are triviall explained, as we ignore the nr_to_write
> value for data integrity writepage in the lowlevel writeback code, and
> the for_background in bdi_start_background_writeback has it's own check
> for the background threshold.  So far so good, and now it gets
> interesting.
> 
> Why does writeback_inodes_sb add the number of used inodes into a value
> that is in units of pages?  And why don't the other callers do this?

Again, git archeology is needed.  The code's been like that for some
time.  IIRC there was a bug long long ago wherein the system could have
lots of dirty inodes but zero dirty pages.  The writeback code would
say "gee, no dirty pages" and would bale out, thus failing to write the
dirty inodes.  Perhaps this hack was a "fix" for that behaviour.  Or
perhaps not.  Apparently it was so obvious that no code comment was
needed.

> But seriously, how is the _global_ number of dirty and unstable pages
> a good indicator for the amount of writeback per-bdi or superblock
> anyway?

It isn't.  This appears to have been an attempt to transport the
wakeup_pdflush() functionality into the new wakeup_flusher_threads()
regime.  Badly.

> Somehow I'd feel much better about doing this calculation all the way
> down in wb_writeback instead of the callers so we'll at least have
> one documented place for these insanities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
