Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BAA788D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:06:33 -0500 (EST)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1PvB2t-0006VZ-Ke
	for linux-mm@kvack.org; Thu, 03 Mar 2011 16:06:31 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PvB2r-0008PT-HW
	for linux-mm@kvack.org; Thu, 03 Mar 2011 16:06:29 +0000
Subject: Re: [PATCH 09/27] nfs: writeback pages wait queue
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110303074949.809203319@intel.com>
References: <20110303064505.718671603@intel.com>
	 <20110303074949.809203319@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Mar 2011 17:08:01 +0100
Message-ID: <1299168481.1310.56.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Chris Mason <chris.mason@oracle.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 2011-03-03 at 14:45 +0800, Wu Fengguang wrote:
> +static void nfs_wakeup_congested(long nr,
> +                                struct backing_dev_info *bdi,
> +                                wait_queue_head_t *wqh)
> +{
> +       long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
> +
> +       if (nr < 2 * limit - min(limit / 8, NFS_WAIT_PAGES)) {
> +               if (test_bit(BDI_sync_congested, &bdi->state)) {
> +                       clear_bdi_congested(bdi, BLK_RW_SYNC);
> +                       smp_mb__after_clear_bit();
> +               }
> +               if (waitqueue_active(&wqh[BLK_RW_SYNC]))
> +                       wake_up(&wqh[BLK_RW_SYNC]);
> +       }
> +       if (nr < limit - min(limit / 8, NFS_WAIT_PAGES)) {
> +               if (test_bit(BDI_async_congested, &bdi->state)) {
> +                       clear_bdi_congested(bdi, BLK_RW_ASYNC);
> +                       smp_mb__after_clear_bit();
> +               }
> +               if (waitqueue_active(&wqh[BLK_RW_ASYNC]))
> +                       wake_up(&wqh[BLK_RW_ASYNC]);
> +       }
> +} 

memory barriers want a comment - always - explaining what they order and
against whoem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
