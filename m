Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8DD788D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 08:51:13 -0500 (EST)
Date: Tue, 1 Mar 2011 21:51:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: IO-less dirty throttling V6 results available
Message-ID: <20110301135109.GA15166@localhost>
References: <20110222142543.GA13132@localhost>
 <20110223151322.GA13637@localhost>
 <20110224152509.GA22513@localhost>
 <20110224185632.GJ23042@quack.suse.cz>
 <20110225144412.GA19448@localhost>
 <20110228172211.GB20805@quack.suse.cz>
 <20110301095508.GA637@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110301095508.GA637@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan.kim@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, Sorin Faibish <sfaibish@emc.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 01, 2011 at 05:55:08PM +0800, Wu Fengguang wrote:
> On Tue, Mar 01, 2011 at 01:22:11AM +0800, Jan Kara wrote:
> > On Fri 25-02-11 22:44:12, Wu Fengguang wrote:
> > > On Fri, Feb 25, 2011 at 02:56:32AM +0800, Jan Kara wrote:

> > > > more subtle things like how the algorithm behaves for tasks that are not IO
> > > > bound for most of the time (or do less IO). Any good metrics here? More
> > > > things we could compare?
> > > 
> > > For non IO bound tasks, there are fio job files that do different
> > > dirty rates.  I have not run them though, as the bandwidth based
> > > algorithm obviously assigns higher bandwidth to light dirtiers :)
> >   Yes :) But I'd be interested how our algorithms behave in such cases...
> 
> OK, will do more tests later.

Just tested an fio job that starts one aggressive dirtier and three
more tasks doing 2, 4, 8 MB/s writes, and the outputs are impressive :)

In all tested filesystems, the three rate limited dirtiers are all
running at their expected speed. They are not throttled at all because
their dirty rates are still lower than the heaviest dirtier task. Here
are the progress graphs.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/btrfs-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-45/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/ext2-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-58/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/ext3-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-33/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/ext4-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-39/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/ext4_wb-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-51/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/xfs-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-26/balance_dirty_pages-task-bw.png

Except for ext4, the slope of the three lines are exactly 2, 4, 8 MB/s
(the 2MB/s line is even a bit higher than expected)

The below graph shows that ext4 is not actually throttling the task,
as almost all "pause" fields are 0 or negative numbers.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/ext4_wb-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-51/balance_dirty_pages-pause.png

So the abnormal increase of the slopes should be caused by the redirty
events, as can also be confirmed by the larger and larger gaps between
the dirtied pages and written pages.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/RATES-2-4-8/ext4-fio-rates-128k-8p-2975M-2.6.38-rc6-dt6+-2011-03-01-20-39/global_dirtied_written.png

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
