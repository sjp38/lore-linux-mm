Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E14BF6B0089
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 19:52:37 -0500 (EST)
Date: Tue, 7 Dec 2010 16:51:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] writeback: enabling-gate for light dirtied bdi
Message-Id: <20101207165111.d79735c1.akpm@linux-foundation.org>
In-Reply-To: <20101205064430.GA15027@localhost>
References: <20101205064430.GA15027@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Dec 2010 14:44:30 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> I noticed that my NFSROOT test system goes slow responding when there
> is heavy dd to a local disk. Traces show that the NFSROOT's bdi_limit
> is near 0 and many tasks in the system are repeatedly stuck in
> balance_dirty_pages().
> 
> There are two related problems:
> 
> - light dirtiers at one device (more often than not the rootfs) get
>   heavily impacted by heavy dirtiers on another independent device
> 
> - the light dirtied device does heavy throttling because bdi_limit=0,
>   and the heavy throttling may in turn withhold its bdi_limit in 0 as
>   it cannot dirty fast enough to grow up the bdi's proportional weight.
> 
> Fix it by introducing some "low pass" gate, which is a small (<=8MB)
> value reserved by others and can be safely "stole" from the current
> global dirty margin.  It does not need to be big to help the bdi gain
> its initial weight.
> 

The changelog refers to something called "bdi_limit".  But there is no
such thing.  It occurs nowhere in the Linux tree and it has never
before been used in a changelog.

Can we please use carefully-chosen terminology and make sure that
everyone can easily understand what the terms are referring to?

I'm assuming from context that you've created a new term to refer to
the bdi_dirty_limit() return value for this bdi.


And ... oh geeze, you made me look at the code.  Grumbles forthcoming.

> 
> Peter, I suspect this will do good for 2.6.37. Please help review, thanks!
> 
>  include/linux/writeback.h |    3 ++-
>  mm/backing-dev.c          |    2 +-
>  mm/page-writeback.c       |   23 +++++++++++++++++++++--
>  3 files changed, 24 insertions(+), 4 deletions(-)
> 
> --- linux-next.orig/mm/page-writeback.c	2010-12-05 14:29:24.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2010-12-05 14:31:39.000000000 +0800
> @@ -444,7 +444,9 @@ void global_dirty_limits(unsigned long *
>   * The bdi's share of dirty limit will be adapting to its throughput and
>   * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
>   */
> -unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
> +unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
> +			      unsigned long dirty,
> +			      unsigned long dirty_pages)

Forgot to update the bdi_dirty_limit() kerneldoc.

While you're there, please document the bdi_dirty_limit() return value.

<looks>

It mentions "100" a  lot.  ah-hah!  It returns a 0..99 percentage!

<looks further>

No, ratelimit_pages() compares it with a variable called dirty_pages,
so it returns an absolute number of pages!

But maybe ratelimit_pages() is buggy.

<looks further>

balance_dirty_pages() passes the bdi_dirty_limit() return value to
task_dirty_limit() which secretly takes a number-of-pages arg and
secretly returns a number-of-pages return value.

So I will pronounce with moderate confidence that bdi_dirty_limit()
returns a page count!

See what I mean?  It shouldn't be that hard!

>  {
>  	u64 bdi_dirty;
>  	long numerator, denominator;
> @@ -459,6 +461,22 @@ unsigned long bdi_dirty_limit(struct bac
>  	do_div(bdi_dirty, denominator);
>  
>  	bdi_dirty += (dirty * bdi->min_ratio) / 100;
> +
> +	/*
> +	 * There is a chicken and egg problem: when bdi A (eg. /pub) is heavy
> +	 * dirtied and bdi B (eg. /) is light dirtied hence has 0 dirty limit,
> +	 * tasks writing to B always get heavily throttled and bdi B's dirty
> +	 * limit may never be able to grow up from 0.
> +	 *
> +	 * So if we can dirty N more pages globally, honour N/2 to the bdi that
> +	 * runs low. To provide such a global margin, we slightly decrease all
> +	 * heavy dirtied bdi's limit.
> +	 */
> +	if (bdi_dirty < (dirty - dirty_pages) / 2 && dirty > dirty_pages)
> +		bdi_dirty = (dirty - dirty_pages) / 2;
> +	else
> +		bdi_dirty -= min(bdi_dirty / 128, 8192ULL >> (PAGE_SHIFT-10));

Good lord, what have we done.

Ho hum.

This problem isn't specific to NFS, is it?  All backing-devices start
out with a bdi_limit (which doesn't actually exist) of zero, yes?  And
this "bdi_limit" is a per-bdi state which is stored via some
undescribed means in some or all of `completions',
`write_bandwidth_update_time', `write_bandwidth', `dirty_exceeded',
`min_ratio', `max_ratio' and `max_prop_frac'.  All of which are
undocumented, naturally.


I admire your ability to work on this code, I really do.  I haven't
looked at it in detail for a year or so and I am aghast at its opacity.
This makes it extremely hard to review any changes to it.  This is a
problem.  And I don't think I can (or will) review this patch for these
reasons.  My dummy is thoroughly spat out.


And what's up with that 8192?  I assume it refers to pages?  32MB?  So
if we're working on eight devices concurrently on a 256MB machine, what
happens?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
