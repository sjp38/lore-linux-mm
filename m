Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3366B00EF
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 16:43:11 -0500 (EST)
Date: Wed, 12 Jan 2011 22:43:03 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/35] writeback: enabling gate limit for light dirtied
 bdi
Message-ID: <20110112214303.GC14260@quack.suse.cz>
References: <20101213144646.341970461@intel.com>
 <20101213150326.480108782@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101213150326.480108782@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  Hi Fengguang,

On Mon 13-12-10 22:46:47, Wu Fengguang wrote:
> I noticed that my NFSROOT test system goes slow responding when there
> is heavy dd to a local disk. Traces show that the NFSROOT's bdi limit
> is near 0 and many tasks in the system are repeatedly stuck in
> balance_dirty_pages().
> 
> There are two generic problems:
> 
> - light dirtiers at one device (more often than not the rootfs) get
>   heavily impacted by heavy dirtiers on another independent device
> 
> - the light dirtied device does heavy throttling because bdi limit=0,
>   and the heavy throttling may in turn withhold its bdi limit in 0 as
>   it cannot dirty fast enough to grow up the bdi's proportional weight.
> 
> Fix it by introducing some "low pass" gate, which is a small (<=32MB)
> value reserved by others and can be safely "stole" from the current
> global dirty margin.  It does not need to be big to help the bdi gain
> its initial weight.
  I'm sorry for a late reply but I didn't get earlier to your patches...

...
> -unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
> + *
> + * There is a chicken and egg problem: when bdi A (eg. /pub) is heavy dirtied
> + * and bdi B (eg. /) is light dirtied hence has 0 dirty limit, tasks writing to
> + * B always get heavily throttled and bdi B's dirty limit might never be able
> + * to grow up from 0. So we do tricks to reserve some global margin and honour
> + * it to the bdi's that run low.
> + */
> +unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
> +			      unsigned long dirty,
> +			      unsigned long dirty_pages)
>  {
>  	u64 bdi_dirty;
>  	long numerator, denominator;
>  
>  	/*
> +	 * Provide a global safety margin of ~1%, or up to 32MB for a 20GB box.
> +	 */
> +	dirty -= min(dirty / 128, 32768UL >> (PAGE_SHIFT-10));
> +
> +	/*
>  	 * Calculate this BDI's share of the dirty ratio.
>  	 */
>  	bdi_writeout_fraction(bdi, &numerator, &denominator);
> @@ -459,6 +472,15 @@ unsigned long bdi_dirty_limit(struct bac
>  	do_div(bdi_dirty, denominator);
>  
>  	bdi_dirty += (dirty * bdi->min_ratio) / 100;
> +
> +	/*
> +	 * If we can dirty N more pages globally, honour N/2 to the bdi that
> +	 * runs low, so as to help it ramp up.
> +	 */
> +	if (unlikely(bdi_dirty < (dirty - dirty_pages) / 2 &&
> +		     dirty > dirty_pages))
> +		bdi_dirty = (dirty - dirty_pages) / 2;
> +
I wonder how well this works - have you tried that? Because from my naive
understanding if we have say two drives - sda, sdb. Someone is banging sda
really hard (several processes writing to the disk as fast as they can), then
we are really close to dirty limit anyway and thus we won't give much space
for sdb to ramp up it's writeout fraction...  Didn't you intend to use
'dirty' without the safety margin subtracted in the above condition? That
would then make more sense to me (i.e. those 32MB are then used as the
ramp-up area).

If I'm right in the above, maybe you could simplify the above condition to:
if (bdi_dirty < margin)
	bdi_dirty = margin;

Effectively it seems rather similar to me and it's immediately obvious how
it behales. Global limit is enforced anyway so the logic just differs in
the number of dirtiers on ramping-up bdi you need to suck out the margin.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
