Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A29696B0099
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 00:38:02 -0500 (EST)
Date: Thu, 16 Dec 2010 13:37:57 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 18/35] writeback: start background writeback earlier
Message-ID: <20101216053757.GA14681@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150328.526742344@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101213150328.526742344@intel.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 13, 2010 at 10:47:04PM +0800, Wu, Fengguang wrote:
> It's possible for some one to suddenly eat lots of memory,
> leading to sudden drop of global dirty limit. So a dirtier
> task may get hard throttled immediately without some previous
> balance_dirty_pages() call to invoke background writeback.
> 
> In this case we need to check for background writeback earlier in the
> loop to avoid stucking the application for very long time. This was not
> a problem before the IO-less balance_dirty_pages() because it will try
> to write something and then break out of the loop regardless of the
> global limit.
> 
> Another scheme this check will help is, the dirty limit is too close to
> the background threshold, so that someone manages to jump directly into
> the pause threshold (background+dirty)/2.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> --- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:16.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2010-12-13 21:46:17.000000000 +0800
> @@ -748,6 +748,9 @@ static void balance_dirty_pages(struct a
>  				    bdi_stat(bdi, BDI_WRITEBACK);
>  		}
>  
> +		if (unlikely(!writeback_in_progress(bdi)))
> +			bdi_start_background_writeback(bdi);
> +
>  		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
>  
>  		/*
> 

The above patch allows this simplification.
---
Subject: writeback: start background writeback earlier - handle laptop mode
Date: Wed Dec 15 20:15:54 CST 2010

The laptop mode handling can be simplified since we've kick background
writeback inside the balance_dirty_pages() loop on dirty_exceeded.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-15 20:14:33.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-15 20:15:39.000000000 +0800
@@ -891,8 +891,10 @@ pause:
 	 * In normal mode, we start background writeout at the lower
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
-	if ((laptop_mode && dirty_exceeded) ||
-	    (!laptop_mode && (nr_reclaimable > background_thresh)))
+	if (laptop_mode)
+		return;
+
+	if (nr_reclaimable > background_thresh)
 		bdi_start_background_writeback(bdi);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
