Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5D56B6B00EE
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 02:19:43 -0400 (EDT)
Date: Sun, 7 Aug 2011 14:19:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
Message-ID: <20110807061931.GA3287@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.002914580@intel.com>
 <20110806143531.GA1512@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110806143531.GA1512@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Aug 06, 2011 at 10:35:31PM +0800, Andrea Righi wrote:
> On Sat, Aug 06, 2011 at 04:44:51PM +0800, Wu Fengguang wrote:
> > Add two fields to task_struct.
> > 
> > 1) account dirtied pages in the individual tasks, for accuracy
> > 2) per-task balance_dirty_pages() call intervals, for flexibility
> > 
> > The balance_dirty_pages() call interval (ie. nr_dirtied_pause) will
> > scale near-sqrt to the safety gap between dirty pages and threshold.
> > 
> > XXX: The main problem of per-task nr_dirtied is, if 10k tasks start
> > dirtying pages at exactly the same time, each task will be assigned a
> > large initial nr_dirtied_pause, so that the dirty threshold will be
> > exceeded long before each task reached its nr_dirtied_pause and hence
> > call balance_dirty_pages().
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> A minor nitpick below.
> 
> Reviewed-by: Andrea Righi <andrea@betterlinux.com>

Thank you.

> > +/*
> >   * balance_dirty_pages() must be called by processes which are generating dirty
> >   * data.  It looks at the number of dirty pages in the machine and will force
> >   * the caller to perform writeback if the system is over `vm_dirty_ratio'.
> 
> I think we should also fix the comment of balance_dirty_pages(), now
> that it's IO-less for the caller. Maybe something like:
> 
> /*
>  * balance_dirty_pages() must be called by processes which are generating dirty
>  * data.  It looks at the number of dirty pages in the machine and will force
>  * the caller to wait once crossing the dirty threshold. If we're over
>  * `background_thresh' then the writeback threads are woken to perform some
>  * writeout.
>  */

Good catch! I'll add this change to the next patch:

 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
- * the caller to perform writeback if the system is over `vm_dirty_ratio'.
+ * the caller to wait once crossing the (background_thresh + dirty_thresh) / 2.
  * If we're over `background_thresh' then the writeback threads are woken to
  * perform some writeout.
  */

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
