Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4D2620122
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:55:10 -0400 (EDT)
Subject: Re: [PATCH 3/6] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100711021748.879183413@intel.com>
References: <20100711020656.340075560@intel.com>
	 <20100711021748.879183413@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 03 Aug 2010 17:03:42 +0200
Message-ID: <1280847822.1923.597.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-07-11 at 10:06 +0800, Wu Fengguang wrote:
> plain text document attachment (writeback-less-bdi-calc.patch)
> Split get_dirty_limits() into global_dirty_limits()+bdi_dirty_limit(),
> so that the latter can be avoided when under global dirty background
> threshold (which is the normal state for most systems).

The patch looks OK, although esp with the proposed comments in the
follow up email, bdi_dirty_limit() gets a bit confusing wrt to how and
what the limit is.

Maybe its clearer to not call task_dirty_limit() from bdi_dirty_limit(),
that way the comment can focus on the device write request completion
proportion thing.

> +unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
> +			       unsigned long dirty)
> +{
> +	u64 bdi_dirty;
> +	long numerator, denominator;
> =20
> +	/*
> +	 * Calculate this BDI's share of the dirty ratio.
> +	 */
> +	bdi_writeout_fraction(bdi, &numerator, &denominator);
> =20
> +	bdi_dirty =3D (dirty * (100 - bdi_min_ratio)) / 100;
> +	bdi_dirty *=3D numerator;
> +	do_div(bdi_dirty, denominator);
> =20
> +	bdi_dirty +=3D (dirty * bdi->min_ratio) / 100;
> +	if (bdi_dirty > (dirty * bdi->max_ratio) / 100)
> +		bdi_dirty =3D dirty * bdi->max_ratio / 100;
> +
  +       return bdi_dirty;
>  }

And then add the call to task_dirty_limit() here:

> +++ linux-next/mm/backing-dev.c	2010-07-11 08:53:44.000000000 +0800
> @@ -83,7 +83,8 @@ static int bdi_debug_stats_show(struct s
>  		nr_more_io++;
>  	spin_unlock(&inode_lock);
> =20
> -	get_dirty_limits(&background_thresh, &dirty_thresh, &bdi_thresh, bdi);
> +	global_dirty_limits(&background_thresh, &dirty_thresh);
> +	bdi_thresh =3D bdi_dirty_limit(bdi, dirty_thresh);
  +       bdi_thresh =3D task_dirty_limit(current, bdi_thresh);

And add a comment to task_dirty_limit() as well, explaining its reason
for existence (protecting light/slow dirtying tasks from heavier/fast
ones).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
