Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8E00E6B007E
	for <linux-mm@kvack.org>; Sun, 30 Aug 2009 12:52:24 -0400 (EDT)
Date: Sun, 30 Aug 2009 12:52:29 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090830165229.GA5189@infradead.org>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1251600858-21294-1-git-send-email-tytso@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Sat, Aug 29, 2009 at 10:54:18PM -0400, Theodore Ts'o wrote:
> MAX_WRITEBACK_PAGES was hard-coded to 1024 because of a concern of not
> holding I_SYNC for too long.  But this shouldn't be a concern since
> I_LOCK and I_SYNC have been separated.  So make it be a tunable and
> change the default to be 32768.
> 
> This change is helpful for ext4 since it means we write out large file
> in bigger chunks than just 4 megabytes at a time, so that when we have
> multiple large files in the page cache waiting for writeback, the
> files don't end up getting interleaved.  There shouldn't be any downside.
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=13930

The current writeback sizes are defintively too small, we shoved in
a hack into XFS to bump up nr_to_write to four times the value the
VM sends us to be able to saturate medium sized RAID arrays in XFS.

Turns out this was not enough and at least for Chris Masons array
we only started seaturating at * 16.  I suspect you patch will give
a similar effect.

>  /*
> + * The maximum number of pages to writeout in a single bdflush/kupdate
> + * operation.  We used to limit this to 1024 pages to avoid holding
> + * I_SYNC against an inode for a long period of times, but since
> + * I_SYNC has been separated out from I_LOCK, the only time a process
> + * waits for I_SYNC is when it is calling fsync() or otherwise forcing
> + * out the inode.
> + */
> +unsigned int max_writeback_pages = 32768;

Now while I'm sure this a a much much better default than the brain dead
previous one I suspect we really need to scale it based on the amount of
available or dirty RAM to keep larger systems busy.  Also that I_SYNC
comment doesn't make too much sense to me - if we do a sync/fsync we
do need to write out all data anyway, so waiting for bdflush/kupdate
is not a problem.  The only thing where it could matter is for Jan's
new O_SYNC implementation.

And btw, I think referring to the historic code in the comment is not
a good idea, it's just going to ocnfuse the heck out of everyone looking
at it in the future.  The information above makes sense for the commit
message.

And the other big question is how this interacts with Jens' new per-bdi
flushing code that we still hope to merge in 2.6.32.

Maybe we'll actually get some sane writeback code for the first time.

> +
> +/*
>   * Start background writeback (via pdflush) at this percentage
>   */
>  int dirty_background_ratio = 10;
> @@ -708,10 +709,10 @@ static void background_writeout(unsigned long _min_pages)
>  			break;
>  		wbc.more_io = 0;
>  		wbc.encountered_congestion = 0;
> -		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
> +		wbc.nr_to_write = max_writeback_pages;
>  		wbc.pages_skipped = 0;
>  		writeback_inodes(&wbc);
> -		min_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
> +		min_pages -= max_writeback_pages - wbc.nr_to_write;
>  		if (wbc.nr_to_write > 0 || wbc.pages_skipped > 0) {
>  			/* Wrote less than expected */
>  			if (wbc.encountered_congestion || wbc.more_io)
> @@ -783,7 +784,7 @@ static void wb_kupdate(unsigned long arg)
>  	while (nr_to_write > 0) {
>  		wbc.more_io = 0;
>  		wbc.encountered_congestion = 0;
> -		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
> +		wbc.nr_to_write = max_writeback_pages;
>  		writeback_inodes(&wbc);
>  		if (wbc.nr_to_write > 0) {
>  			if (wbc.encountered_congestion || wbc.more_io)
> @@ -791,7 +792,7 @@ static void wb_kupdate(unsigned long arg)
>  			else
>  				break;	/* All the old data is written */
>  		}
> -		nr_to_write -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
> +		nr_to_write -= max_writeback_pages - wbc.nr_to_write;
>  	}
>  	if (time_before(next_jif, jiffies + HZ))
>  		next_jif = jiffies + HZ;
> -- 
> 1.6.3.2.1.gb9f7d.dirty
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
