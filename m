Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B63E56B00EE
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:09:07 -0400 (EDT)
Date: Thu, 18 Aug 2011 22:08:56 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v9 12/13] memcg: create support routines for page
 writeback
Message-ID: <20110818200856.GD12426@quack.suse.cz>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
 <1313597705-6093-13-git-send-email-gthelen@google.com>
 <20110818103803.c2617804.kamezawa.hiroyu@jp.fujitsu.com>
 <20110818023610.GA12514@localhost>
 <20110818101248.GA12426@quack.suse.cz>
 <20110818121714.GA1883@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110818121714.GA1883@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, "Li, Shaohua" <shaohua.li@intel.com>, "Shi, Alex" <alex.shi@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>

On Thu 18-08-11 20:17:14, Wu Fengguang wrote:
> On Thu, Aug 18, 2011 at 06:12:48PM +0800, Jan Kara wrote:
> > On Thu 18-08-11 10:36:10, Wu Fengguang wrote:
> > > Subject: squeeze max-pause area and drop pass-good area
> > > Date: Tue Aug 16 13:37:14 CST 2011
> > > 
> > > Remove the pass-good area introduced in ffd1f609ab10 ("writeback:
> > > introduce max-pause and pass-good dirty limits") and make the
> > > max-pause area smaller and safe.
> > > 
> > > This fixes ~30% performance regression in the ext3 data=writeback
> > > fio_mmap_randwrite_64k/fio_mmap_randrw_64k test cases, where there are
> > > 12 JBOD disks, on each disk runs 8 concurrent tasks doing reads+writes.
> > > 
> > > Using deadline scheduler also has a regression, but not that big as
> > > CFQ, so this suggests we have some write starvation.
> > > 
> > > The test logs show that
> > > 
> > > - the disks are sometimes under utilized
> > > 
> > > - global dirty pages sometimes rush high to the pass-good area for
> > >   several hundred seconds, while in the mean time some bdi dirty pages
> > >   drop to very low value (bdi_dirty << bdi_thresh).
> > >   Then suddenly the global dirty pages dropped under global dirty
> > >   threshold and bdi_dirty rush very high (for example, 2 times higher
> > >   than bdi_thresh). During which time balance_dirty_pages() is not
> > >   called at all.
> > > 
> > > So the problems are
> > > 
> > > 1) The random writes progress so slow that they break the assumption of
> > > the max-pause logic that "8 pages per 200ms is typically more than
> > > enough to curb heavy dirtiers".
> > > 
> > > 2) The max-pause logic ignored task_bdi_thresh and thus opens the
> > >    possibility for some bdi's to over dirty pages, leading to
> > >    (bdi_dirty >> bdi_thresh) and then (bdi_thresh >> bdi_dirty) for others.
> > > 
> > > 3) The higher max-pause/pass-good thresholds somehow leads to some bad
> > >    swing of dirty pages.
> > > 
> > > The fix is to allow the task to slightly dirty over task_bdi_thresh, but
> > > no way to exceed bdi_dirty and/or global dirty_thresh.
> > > 
> > > Tests show that it fixed the JBOD regression completely (both behavior
> > > and performance), while still being able to cut down large pause times
> > > in balance_dirty_pages() for single-disk cases.
> > > 
> > > Reported-by: Li Shaohua <shaohua.li@intel.com>
> > > Tested-by: Li Shaohua <shaohua.li@intel.com>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > >  include/linux/writeback.h |   11 -----------
> > >  mm/page-writeback.c       |   15 ++-------------
> > >  2 files changed, 2 insertions(+), 24 deletions(-)
> > > 
> > > --- linux.orig/mm/page-writeback.c	2011-08-18 09:52:59.000000000 +0800
> > > +++ linux/mm/page-writeback.c	2011-08-18 10:28:57.000000000 +0800
> > > @@ -786,21 +786,10 @@ static void balance_dirty_pages(struct a
> > >  		 * 200ms is typically more than enough to curb heavy dirtiers;
> > >  		 * (b) the pause time limit makes the dirtiers more responsive.
> > >  		 */
> > > -		if (nr_dirty < dirty_thresh +
> > > -			       dirty_thresh / DIRTY_MAXPAUSE_AREA &&
> > > +		if (nr_dirty < dirty_thresh &&
> > > +		    bdi_dirty < (task_bdi_thresh + bdi_thresh) / 2 &&
> > >  		    time_after(jiffies, start_time + MAX_PAUSE))
> > >  			break;
> >   This looks definitely much safer than the original patch since we now
> > always observe global dirty limit.
> 
> Yeah.
> 
> > I just wonder: We have throttled the
> > task because bdi_nr_reclaimable > task_bdi_thresh.
> 
> Not necessarily. It's possible (bdi_nr_reclaimable < task_bdi_thresh)
> for the whole loop. And the 200ms pause that trigger the above test
> may totally come from the io_schedule_timeout() calls.
> 
> > Now in practice there
> > should be some pages under writeback and this task should have submitted
> > even more just a while ago. So the condition
> >   bdi_dirty < (task_bdi_thresh + bdi_thresh) / 2
> 
> I guess the writeback_inodes_wb() call is irrelevant for the above
> test, because writeback_inodes_wb() transfers reclaimable pages to
> writeback pages, with the total bdi_dirty value staying the same.
> Not to mention the fact that both the bdi_dirty and bdi_nr_reclaimable
> variables have not been updated between writeback_inodes_wb() and the
> max-pause test.
  Right, that comment was a bit off.

> > looks still relatively weak. Shouldn't there be
> >   bdi_nr_reclaimable < (task_bdi_thresh + bdi_thresh) / 2?
> 
> That's much easier condition to satisfy..
  Argh, sorry. I was mistaken by the name of the variable - I though it
contains only dirty pages on the bdi but it also contains pages under
writeback and bdi_nr_reclaimable is the one that contains only dirty pages.
So your patch does exactly what I had in mind. You can add:
  Acked-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
