Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6B4BB8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 01:22:31 -0500 (EST)
Date: Fri, 4 Mar 2011 17:22:17 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 06/27] btrfs: lower the dirty balance poll interval
Message-ID: <20110304062217.GE25368@dastard>
References: <20110303064505.718671603@intel.com>
 <20110303074949.419321686@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110303074949.419321686@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Theodore Ts'o <tytso@mit.edu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 03, 2011 at 02:45:11PM +0800, Wu Fengguang wrote:
> Call balance_dirty_pages_ratelimit_nr() on every 32 pages dirtied.
> 
> Tests show that original larger intervals can easily make the bdi
> dirty limit exceeded on 100 concurrent dd.
> 
> CC: Chris Mason <chris.mason@oracle.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/btrfs/file.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> --- linux-next.orig/fs/btrfs/file.c	2011-03-02 20:15:19.000000000 +0800
> +++ linux-next/fs/btrfs/file.c	2011-03-02 20:35:07.000000000 +0800
> @@ -949,9 +949,8 @@ static ssize_t btrfs_file_aio_write(stru
>  	}
>  
>  	iov_iter_init(&i, iov, nr_segs, count, num_written);
> -	nrptrs = min((iov_iter_count(&i) + PAGE_CACHE_SIZE - 1) /
> -		     PAGE_CACHE_SIZE, PAGE_CACHE_SIZE /
> -		     (sizeof(struct page *)));
> +	nrptrs = min(DIV_ROUND_UP(iov_iter_count(&i), PAGE_CACHE_SIZE),
> +		     min(32UL, PAGE_CACHE_SIZE / sizeof(struct page *)));

You're basically hardcoding the maximum to 32 pages here, because
PAGE_CACHE_SIZE / sizeof(page *) is always going to be much larger
than 32.

This means that you are effectively neutering the large write
efficiencies of btrfs - you're reducing the delayed allocation sizes
from 512 * PAGE_CACHE_SIZE down to 32 * PAGE_CACHE_SIZE. This will
increase the overhead of the write process for btrfs for large IOs.

Also, I've got some multipage write modifications that allow 1024
pages at a time between mapping/allocation calls with XFS - once
again for improving the efficiencies of the extent
mapping/allocations in the write path. If the new writeback
throttling algorithms don't work with large numbers of pages being
copied in a single go, then that's a problem.

As it is, if 100 concurrent dd's can overrun the dirty limit w/ 512
pages at a time, then 1000 concurrent dd's w/ 32 pages at a time is
just as likely to overrun it, too. We support 4096 CPU systems, so a
few thousand concurrent writers is not out of the question. Hence I
don't think just reducing the number of pages between dirty balance
calls is a sufficient solution....

Cheers,

Dave..
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
