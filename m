Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 438156B02A4
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 10:58:18 -0400 (EDT)
Date: Sat, 10 Jul 2010 22:58:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: what is the point of nr_pages information for the flusher
 thread?
Message-ID: <20100710145806.GA6628@localhost>
References: <20100707231611.GA24281@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100707231611.GA24281@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Here are some of my findings.

On Thu, Jul 08, 2010 at 07:16:11AM +0800, Christoph Hellwig wrote:
> Currently there's three possible values we pass into the flusher thread
> for the nr_pages arguments:

The current wb_writeback_work.nr_pages parameter semantic is actually quite
different from the _min_pages argument in 2.6.30. Current semantic is
"max pages to write", the old one is "min pages to write (until all written)".

current wb_writeback():

        for (;;) {
                /*
                 * Stop writeback when nr_pages has been consumed
                 */
                if (work->nr_pages <= 0)
                        break;

2.6.30 background_writeout(_min_pages):

                if (global_page_state(NR_FILE_DIRTY) +
                        global_page_state(NR_UNSTABLE_NFS) < background_thresh
                                && min_pages <= 0)
                        break;

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
> 
> The LONG_MAX cases are triviall explained, as we ignore the nr_to_write
> value for data integrity writepage in the lowlevel writeback code, and
> the for_background in bdi_start_background_writeback has it's own check
> for the background threshold.  So far so good, and now it gets
> interesting.

Yeah.
 
> Why does writeback_inodes_sb add the number of used inodes into a value
> that is in units of pages?  And why don't the other callers do this?

The 2.6.30 sync_inodes_sb() has this comment:

 * We add in the number of potentially dirty inodes, because each inode write
 * can dirty pagecache in the underlying blockdev.
 
The periodic writeback also referenced it:

        nr_pages = global_page_state(NR_FILE_DIRTY) +
                        global_page_state(NR_UNSTABLE_NFS) +
                        (inodes_stat.nr_inodes - inodes_stat.nr_unused);

        if (nr_pages) {
                struct wb_writeback_work work = {
                        .nr_pages       = nr_pages,

Here it looks more sane to do

        if (wb_has_dirty_io(wb)) {
                struct wb_writeback_work work = {
                        .nr_pages       = LONG_MAX,


> But seriously, how is the _global_ number of dirty and unstable pages
> a good indicator for the amount of writeback per-bdi or superblock
> anyway?

Good point.
 
> Somehow I'd feel much better about doing this calculation all the way
> down in wb_writeback instead of the callers so we'll at least have
> one documented place for these insanities.

I guess the current "max pages to write" semantic serves as a poor
man's live-lock prevention guard. sync() want that semantic (in this
sense the old "min pages to write" has never worked as expected). When
proper live-lock preventions are ready, this guard will no longer be
necessary.

However the current semantic is not suitable for other users. "To write at most
nr_pages until hitting background dirty threshold" is basically a no-op,
because the callers may as well let the normal background writeback do the job
for them.

For example, laptop_mode_timer_fn() actually want to write the whole world, so
it wants nr_pages=LONG_MAX with the old "min pages to write" semantic.

There are other cases that try to write some pages
- free_more_memory()
- do_try_to_free_pages() 
- ubifs shrink_liability()
- ext4 ext4_nonda_switch()

They don't really know or care about the exact nr_pages to write.
The latter two functions even sync everything for simplicity..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
